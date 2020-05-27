package require Thread
package require tls
package require json

namespace eval ROOT {
	variable defFile "/home/ntvr/nodeTcl/conf/def.json"
	variable nodeThreadIDList {}
	}

proc ROOT::init {} {
	variable defFile
	variable nodeThreadIDList
	
	if {[catch {open $defFile r} defFp]} {
		puts $defFp
		return
		}
	set defStr [read $defFp]
	close $defFp
	if {[catch {::json::json2dict $defStr} defDict]} {
		puts $defDict
		return
		}
	foreach el $defDict {
		set keyFile [dict get $el "keyFile"]
		set crtFile [dict get $el "crtFile"]
		set portNum [dict get $el "portNum"]
		set serverName [dict get $el "serverName"]
		set callbackFile [dict get $el "callbackFile"]

		set tempThreadID [thread::create {
			source node.tcl
			thread::wait
			}]
		thread::send $tempThreadID [list NODE::init $crtFile $keyFile $serverName $portNum $callbackFile]
		lappend nodeThreadIDList $tempThreadID
		puts "Node Thread ID = $tempThreadID"
		}
	}

ROOT::init
vwait forever
