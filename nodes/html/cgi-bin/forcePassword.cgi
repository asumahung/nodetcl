#!/usr/bin/tclsh
#
package require ncgi

::ncgi::parse
set newuid [::ncgi::value newuid]
puts "Content-type: application/javascript\n"
puts "var result=\"$newuid\";"