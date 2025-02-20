/*-
 * SPDX-License-Identifier: BSD-2-Clause-FreeBSD
 *
 * Copyright (c) 2022 Milan Obuch
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $FreeBSD$
 */

/*
 * Driver for first step AXI bus reads of main memory
 *
 */

/*
 * KLD axi_mas
 * Copyright (c) 2024 Christopher R. Bowman
 */

#include <sys/cdefs.h>
__FBSDID("$FreeBSD$");

#include <sys/param.h>
#include <sys/systm.h>
#include <sys/conf.h>
#include <sys/kernel.h>
#include <sys/malloc.h>
#include <sys/module.h>
#include <sys/bus.h>
#include <machine/bus.h>
#include <sys/rman.h>
#include <sys/sysctl.h>
#include <machine/resource.h>
#include <machine/cpu.h>
#include <sys/timeet.h>
#include <sys/systm.h>  /* uprintf */

#include <dev/fdt/fdt_common.h>
#include <dev/ofw/openfirm.h>
#include <dev/ofw/ofw_bus.h>
#include <dev/ofw/ofw_bus_subr.h>

#define AXI_MAS_LOCK(sc)		mtx_lock(&(sc)->sc_mtx)
#define	AXI_MAS_UNLOCK(sc)		mtx_unlock(&(sc)->sc_mtx)
#define AXI_MAS_LOCK_INIT(sc) \
	mtx_init(&(sc)->sc_mtx, device_get_nameunit((sc)->dev),	\
	    "axi_mas", MTX_DEF)
#define AXI_MAS_LOCK_DESTROY(_sc)	mtx_destroy(&_sc->sc_mtx);

#define WR4(sc, off, val)	bus_write_4((sc)->mem_res, (off), (val))
#define RD4(sc, off)		bus_read_4((sc)->mem_res, (off))

/* Hardware driver registers */

#define	AXI_MAS_SGN			0x0000		/* Signature register                   */
#define	AXI_MAS_RADD		0x0004		/* Address to read from                 */
#define	AXI_MAS_RVAL		0x0008		/* Value read from memory               */
#define	AXI_MAS_TRIG		0x000c		/* Trigger for read from memory			*/

struct axi_mas_softc {
	device_t	dev;
	struct mtx	sc_mtx;
	struct resource *mem_res;	/* register base address */
	uint32_t read_word;			/* word in main memory to be read by AXI master */
};

static int
axi_mas_proc0(SYSCTL_HANDLER_ARGS)
{
	int error;
	struct axi_mas_softc *sc;

	sc = (struct axi_mas_softc *)arg1;

	sc->read_word = 0xcafebabe;			// set memory to a known value
static uint32_t value0 = 0;

	AXI_MAS_LOCK(sc);

	value0 = RD4(sc, AXI_MAS_RADD);

	AXI_MAS_UNLOCK(sc);

	error = sysctl_handle_int(oidp, &value0, sizeof(value0), req);
	if (error != 0 || req->newptr == NULL)
		return (error);

	value0 = (uint32_t)&sc->read_word;	// get address of known value
	WR4(sc, AXI_MAS_RADD, value0);		// write know value address to read address register

	return (0);
}

static int
axi_mas_proc1(SYSCTL_HANDLER_ARGS)
{
	int error;
static uint32_t value1 = 0x10;
	struct axi_mas_softc *sc;

	sc = (struct axi_mas_softc *)arg1;

	AXI_MAS_LOCK(sc);

	value1 = RD4(sc, AXI_MAS_RVAL);	// read register storing value read from main memory by hardware

	AXI_MAS_UNLOCK(sc);

	error = sysctl_handle_int(oidp, &value1, sizeof(value1), req);
	if (error != 0 || req->newptr == NULL)
		return (error);

	WR4(sc, AXI_MAS_RVAL, value1);

	return (0);
}

static int
axi_mas_proc2(SYSCTL_HANDLER_ARGS)
{
	int error;
static uint32_t value2 = 0x10;
	struct axi_mas_softc *sc;

	sc = (struct axi_mas_softc *)arg1;

	AXI_MAS_LOCK(sc);

	value2 = RD4(sc, AXI_MAS_TRIG);	// read register storing value read from main memory by hardware

	AXI_MAS_UNLOCK(sc);

	error = sysctl_handle_int(oidp, &value2, sizeof(value2), req);
	if (error != 0 || req->newptr == NULL)
		return (error);

	WR4(sc, AXI_MAS_TRIG, value2);

	return (0);
}

static void
axi_mas_sysctl_init(struct axi_mas_softc *sc)
{
	struct sysctl_ctx_list *ctx;
	struct sysctl_oid *tree_node;
	struct sysctl_oid_list *tree;

	/*
	 * Add per-position sysctl tree/handlers.
	 */
	ctx = device_get_sysctl_ctx(sc->dev);
	tree_node = device_get_sysctl_tree(sc->dev);
	tree = SYSCTL_CHILDREN(tree_node);

	SYSCTL_ADD_PROC(ctx, tree, OID_AUTO, "read_address",
	    CTLFLAG_RW | CTLTYPE_UINT, sc, 0,
	    axi_mas_proc0, "IU", "write the read address and initiate read");

	SYSCTL_ADD_PROC(ctx, tree, OID_AUTO, "value_read",
	    CTLFLAG_RW | CTLTYPE_UINT, sc, 0,
	    axi_mas_proc1, "IU", "get the read value");
	    
	SYSCTL_ADD_PROC(ctx, tree, OID_AUTO, "trigger",
	    CTLFLAG_RW | CTLTYPE_UINT, sc, 0,
	    axi_mas_proc2, "IU", "Trigger the master interface to read from main memory");
}

static int
axi_mas_probe(device_t dev)
{


//	device_printf(dev, "probe of axi_mas\n");
	if (!ofw_bus_status_okay(dev))
		return (ENXIO);

	if (!ofw_bus_is_compatible(dev, "crb,axi_read-1.0")){
#ifdef PROBEDEBUG
		phandle_t node;
		if ((node = ofw_bus_get_node(dev)) == -1)
			return (ENXIO);
		size_t len;
		if ((len = OF_getproplen(node, "compatible")) <= 0)
			return (ENXIO);
#define	OFW_COMPAT_LEN	255
		char compat[OFW_COMPAT_LEN];
		bzero(compat, OFW_COMPAT_LEN);

		if (OF_getprop(node, "compatible", compat, OFW_COMPAT_LEN) < 0)
			return (ENXIO);

		int l;
		char *my_compat;
		my_compat = compat;
		while (len > 0) {
			device_printf(dev, "compat string: %s\n", my_compat);

			/* Slide to the next sub-string. */
			l = strlen(my_compat) + 1;
			my_compat += l;
			len -= l;
		}
#endif
		return (ENXIO);
	}
		
	//device_printf(dev, "matched axi_mas\n");
	device_set_desc(dev, "AXI Master and Slave");
	return (BUS_PROBE_DEFAULT);
}

static int
axi_mas_detach(device_t dev)
{
	struct axi_mas_softc *sc = device_get_softc(dev);

	if (sc->mem_res != NULL) {
		/* Release memory resource. */
		bus_release_resource(dev, SYS_RES_MEMORY,
				     rman_get_rid(sc->mem_res), sc->mem_res);
	}

	AXI_MAS_LOCK_DESTROY(sc);

	return (0);
}

static int
axi_mas_attach(device_t dev)
{
	struct axi_mas_softc *sc;

	device_printf(dev, "attaching axi_mas\n");
	sc = device_get_softc(dev);
	sc->dev = dev;

	int rid;

	AXI_MAS_LOCK_INIT(sc);

	/* Allocate memory. */
	rid = 0;
	sc->mem_res = bus_alloc_resource_any(dev,
		     SYS_RES_MEMORY, &rid, RF_ACTIVE);
	if (sc->mem_res == NULL) {
		device_printf(dev, "Can't allocate memory for device\n");
		axi_mas_detach(dev);
		return (ENOMEM);
	}
#define MAGIC_SIGNATURE 0xFEEDFACE
#define CHECKMAGIC
#ifdef CHECKMAGIC
int32_t value = RD4(sc, AXI_MAS_SGN);
	if (value != MAGIC_SIGNATURE) {
		device_printf(dev, "MAGIC_SIGNATURE 0xFEEDFACE not found! value = %x\n", value);
		axi_mas_detach(dev);
		return (ENXIO);
	}
#endif
	axi_mas_sysctl_init(sc);
	device_printf(dev, "axi_mas attached\n");

	return (0);

}

static device_method_t axi_mas_methods[] = {
	  /* Device interface */
	  DEVMETHOD(device_probe,	axi_mas_probe),
	  DEVMETHOD(device_attach,	axi_mas_attach),
	  DEVMETHOD(device_suspend,	bus_generic_suspend),
	  DEVMETHOD(device_resume,	bus_generic_resume),
	  DEVMETHOD(device_shutdown,	bus_generic_shutdown),
	  {0, 0}
};
 
static driver_t axi_mas_driver = {
	  "axi_mas",
	  axi_mas_methods,
	  sizeof(struct axi_mas_softc)
};
 
DRIVER_MODULE(axi_mas, simplebus, axi_mas_driver, 0, 0);
