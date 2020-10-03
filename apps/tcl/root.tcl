package require Thread
package require tls
package require json
package require comm

set PORT 9999

namespace eval ROOT {
	variable defFile "/home/ntvr/nodeTcl/conf/def.json"
	variable nodeThreadIDList {}
	}

proc ROOT::init {inDefFile} {
	variable defFile
	variable nodeThreadIDList
	
	set defFile $inDefFile
	
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

proc ROOT::deinit {} {
	variable nodeThreadIDList
	
	foreach tid $nodeThreadIDList {
		if {thread::exists $tid} {
			thread::release $tid
			}
		}
	}