#
#	Copyright (c) 2023 by Christopher R. Bowman. All rights reserved.
#

fake:
	(cd hardware && gmake)
	(cd software && make)

clean:
	(cd documentation && make clean)
	(cd hardware && gmake realclean)
	(cd software && make clean)
	
.PHONY: fake clean
