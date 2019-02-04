# Generated by Topology Generator for Network Simulator (c) Elmurod Talipov
set val(chan)          Channel/WirelessChannel      ;# channel type
set val(prop)          Propagation/TwoRayGround     ;# radio-propagation model
set val(netif)         Phy/WirelessPhy/802_15_4     ;# network interface type
set val(mac)           Mac/802_15_4                 ;# MAC type
set val(ifq)           Queue/DropTail/PriQueue      ;# interface queue type
set val(ll)            LL                           ;# link layer type
set val(ant)           Antenna/OmniAntenna          ;# antenna model
set val(ifqlen)        100	         	    ;# max packet in ifq
set val(nn)            500			    ;# number of mobilenodes
set val(rp)            AODV			    ;# protocol tye
set val(x)             1000			    ;# X dimension of topography
set val(y)             500			    ;# Y dimension of topography
set val(stop)          500			    ;# simulation period 
set val(energymodel)   EnergyModel		    ;# Energy Model
set val(initialenergy) 100			    ;# value

set ns        		[new Simulator]
set tracefd       	[open trace-aodv-802-15-4.tr w]
set namtrace      	[open nam-aodv-802-15-4.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
Phy/WirelessPhy set CSThresh_ $dist(40m)
Phy/WirelessPhy set RXThresh_ $dist(40m)


# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

# configure the nodes
$ns node-config -adhocRouting $val(rp) \
            -llType $val(ll) \
             -macType $val(mac) \
             -ifqType $val(ifq) \
             -ifqLen $val(ifqlen) \
             -antType $val(ant) \
             -propType $val(prop) \
             -phyType $val(netif) \
             -channel [new $val(chan)] \
             -topoInstance $topo \
             -agentTrace ON \
             -routerTrace ON \
             -macTrace  OFF \
             -movementTrace OFF \
             -energyModel $val(energymodel) \
             -initialEnergy $val(initialenergy) \
             -rxPower 35.28e-3 \
             -txPower 31.32e-3 \
	     -idlePower 712e-6 \
	     -sleepPower 144e-9 
                           
             #-IncomingErrProc MultistateErrorProc \
             #-OutgoingErrProc MultistateErrorProc
             
for {set i 0} {$i < $val(nn) } { incr i } {
        set mnode_($i) [$ns node]
}



for {set i 1} {$i < $val(nn) } { incr i } {
	$mnode_($i) set X_ [ expr {$val(x) * rand()} ]
	$mnode_($i) set Y_ [ expr {$val(y) * rand()} ]
	$mnode_($i) set Z_ 0
}

# Position of Sink
$mnode_(0) set X_ [ expr {$val(x)/2} ]
$mnode_(0) set Y_ [ expr {$val(y)/2} ]
$mnode_(0) set Z_ 0.0
$mnode_(0) label "Sink"


for {set i 0} {$i < $val(nn)} { incr i } {
	$ns initial_node_pos $mnode_($i) 10
}


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $mnode_(10) $udp

set sink [new Agent/Null]
$ns attach-agent $mnode_(0) $sink

$ns connect $udp $sink
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 50
$cbr set rate_ 0.1Mb
$cbr set interval_ 2
#$cbr set random_ false

$ns at 5.0 "$cbr start"
$ns at [expr $val(stop) - 5] "$cbr stop"

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$mnode_($i) reset;"
}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at [expr $val(stop) + 0.01] "puts \"end simulation\"; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
}

$ns run


