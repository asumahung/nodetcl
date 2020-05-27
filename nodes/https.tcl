namespace eval HTTPS {
	variable socket
	variable docRoot "/home/ntvr/nodeTcl/nodes/html"
	}

proc HTTPS::server {channel clientaddr clientport} {
	variable docRoot
	
	gets $channel line
	puts "request = $line"
	set parseList [HTTPS::parseRequest $line]
	set method [lindex $parseList 0]
	set length 0
	while {[gets $channel line] > 0 } {
		puts $line
		set keyValue [split $line :]
		if {[lindex $keyValue 0] == "Content-Length"} {
			set length [string trim [lindex $keyValue 1]]
			puts "length = $length"
			}
		}
	if {$method == "POST"} {
		puts "POST"
		set line [read $channel $length]
		puts "body = $line"
		}
	puts "Finish"
	set path "${docRoot}/[lindex $parseList 1]"
	set httpVer [lindex $parseList 2]
	set date "Date: [clock format [clock seconds] -format {%a, %d %b %Y %H:%M:%S} -gmt true] GMT"
	set serverInfo "Server: nodeTcl/0.0.1a (Linux)"
	set ext [lindex $parseList 3]
	if {[file exists $path] != 1} {
		set errorFp [open "${docRoot}/http404.html" r]
		set errorStr [read $errorFp]
		set errorStr [string map [list "_PLACEHOLDER_" [lindex $parseList 0]] $errorStr]
		close $errorFp
		puts $channel "$httpVer 404 Not found"
		puts $channel $date
		puts $channel $serverInfo
		#puts $channel "Content-Length: [string length $errorStr]"
		puts $channel "Connection: Closed"
		puts $channel "Content-Type: text/html; charset=iso-8859-1"
		puts $channel ""
		puts $channel $errorStr
		} else {
		if {$ext == "html" || $ext == "css" || $ext == "js"} {
			set fp [open $path r]
			set str [read $fp]
			close $fp
			if {$ext == "html"} {
				set type "text/html"
				} elseif {$ext == "css"} {
				set type "text/css"
				} elseif {$ext == "js"} {
				set type "application/javascript"
				} else {
				set type "text/plain"
				}
			puts $channel "$httpVer 200 OK"
			puts $channel $date
			puts $channel $serverInfo
			#puts $channel "Content-Length: [string length $str]"
			puts $channel "Connection: Closed"
			puts $channel "Content-Type: $type"
			puts $channel ""
			puts $channel $str
			} elseif {$ext == "tcl"} {
			source $path
			set str [generate [lindex $parseList 3]]
			puts $channel "$httpVer 200 OK"
			puts $channel $date
			puts $channel $serverInfo
			puts $channel "Content-Length: [string length $str]"
			puts $channel "Connection: Closed"
			puts $channel "Content-Type: text/html"
			puts $channel ""
			puts $channel $str
			} else {
			set fpsize [file size $path]
			puts "size $fpsize"
			puts $channel "$httpVer 200 OK"
			puts $channel $date
			puts $channel $serverInfo
			puts $channel "Content-Length: $fpsize"
			puts $channel "Connection: Closed"
			puts $channel "Content-Type: image/jpeg"
			puts $channel ""
			set fp [open $path r]
			fconfigure $fp -encoding binary -translation binary
			fconfigure $channel -encoding binary -translation binary
			fcopy $fp $channel
			flush $channel
			close $fp
			}
		}
	
	close $channel
	return
	}

proc HTTPS::parseRequest {line} {
	set itemList [split $line]
	set method [lindex $itemList 0]
	set request [lindex $itemList 1]
	set reqList [split $request ?]
	set path [lindex $reqList 0]
	set queryList [split [lindex $reqList 1] &]
	set httpVer [lindex $itemList 2]
	set ext [lindex [split $path .] 1]
	
	return [list $method $path $httpVer $ext $queryList]
	}

proc HTTPS::parseType {ext} {
	switch $ext {
		html {
			return "text/html"
			}
		css {
			return "text/css"
			}
		js {
			return "application/javascript"
			}
		}
	}