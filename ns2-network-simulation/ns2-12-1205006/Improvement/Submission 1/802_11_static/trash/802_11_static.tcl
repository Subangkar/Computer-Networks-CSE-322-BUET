# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             3                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol

# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open simple.tr w]
set namfd [open wireless.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namfd 500 500
#setting up nam file


# set up topography object
set topo       [new Topography]

$topo load_flatgrid 500 500

#
# Create God
#
create-god $val(nn)

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node

$ns_ node-config -adhocRouting $val(rp) \
		 -llType $val(ll) \
		 -macType $val(mac) \
		 -ifqType $val(ifq) \
		 -ifqLen $val(ifqlen) \
		 -antType $val(ant) \
		 -propType $val(prop) \
		 -phyType $val(netif) \
		 -channelType $val(chan) \
		 -topoInstance $topo \
		 -agentTrace ON \
		 -routerTrace ON \
		 -macTrace OFF \
		 -movementTrace OFF			
		 
for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$node_(0) set X_ 5.0
$node_(0) set Y_ 2.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 390.0
$node_(1) set Y_ 385.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 10.0
$node_(2) set Y_ 305.0
$node_(2) set Z_ 0.0

#
# Now produce some simple node movements
# Node_(1) starts to move towards node_(0)
#
$ns_ at 50.0 "$node_(1) setdest 25.0 20.0 15.0" ;#comment this part
$ns_ at 10.0 "$node_(0) setdest 20.0 18.0 1.0"
$ns_ at 10.0 "$node_(2) setdest 20.0 18.0 1.0"

# Node_(1) then starts to move away from node_(0)
$ns_ at 100.0 "$node_(1) setdest 490.0 480.0 15.0" 

# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)
set tcp(0) [new Agent/TCP]
set tcp(1) [new Agent/TCP]
$ns_ attach-agent $node_(0) $tcp(0)
$ns_ attach-agent $node_(0) $tcp(1)
$tcp(0) set class_ 2
$tcp(1) set class_ 2

set sink(0) [new Agent/TCPSink]
set sink(1) [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $sink(0)
$ns_ attach-agent $node_(2) $sink(1)

$ns_ connect $tcp(0) $sink(0)
$ns_ connect $tcp(1) $sink(1)

set ftp(0) [new Application/FTP]
set ftp(1) [new Application/FTP]

$ftp(0) attach-agent $tcp(0)
$ftp(1) attach-agent $tcp(1)
$ns_ at 10.0 "$ftp(0) start" 
$ns_ at 10.0 "$ftp(1) start" 

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 150.0 "$node_($i) reset";
}
$ns_ at 150.0 "stop"
$ns_ at 150.01 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd namfd
    $ns_ flush-trace
    close $tracefd
    close $namfd

    puts "inside stop!"
    exec nam wireless.nam &
    exit 0
}

puts "Starting Simulation..."
$ns_ run

