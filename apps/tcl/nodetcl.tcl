#!/bin/sh
#
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

source root.tcl

::comm::comm config -port $PORT

ROOT::init [lindex $argv 0]

vwait forever
