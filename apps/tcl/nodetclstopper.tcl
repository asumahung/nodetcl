#!/usr/bin/tclsh
#
package require comm

set PORT 9999

::comm::comm send $PORT {ROOT::deinit}

exit