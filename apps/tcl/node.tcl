package require tls
package require Thread

namespace eval NODE {
	variable mySocket
	variable callbackFile
	variable serverName
	}

proc NODE::init {crtFile keyFile inServerName portNum inCallbackFile} {
	variable mySocket
	variable callbackFile
	# variable workerThreadID
	variable serverName
	
	set serverName $inServerName
	set callbackFile $inCallbackFile
	tls::init -certfile $crtFile -keyfile $keyFile -servername $serverName
	puts "tls::init -certfile $crtFile -keyfile $keyFile -servername $serverName"
	set mySocket [tls::socket -server NODE::server $portNum]
	puts "tls::socket -server server $portNum"
	puts "mySocket=$mySocket"
	# set workerThreadID [thread::create {
		# thread::wait
		# }]
	# thread::send $workerThreadID [list source $callbackFile]
	}

proc NODE::server {channel clientaddr clientport} {
	variable serverName
	variable callbackFile
	
	set workerThreadID [thread::create {
		thread::wait
		}]
	thread::send $workerThreadID [list source $callbackFile]
	after idle thread::transfer $workerThreadID $channel
	puts "invoked by ${clientaddr}:$clientport @[clock format [clock seconds]]"
	after idle [list thread::send -async $workerThreadID [list ${serverName}::server $channel $clientaddr $clientport]]
	after idle thread::release $workerThreadID
	return
	}
