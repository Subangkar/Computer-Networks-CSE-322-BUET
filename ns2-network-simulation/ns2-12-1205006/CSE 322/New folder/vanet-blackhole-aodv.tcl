# 29 Aug 2015, @moh awad, https://groups.google.com/forum/?fromgroups#!topic/ns-users/oznEEorxqJE  

# Re http://imraan-prrec.blogspot.dk/2012/05/black-hole-blackhole-attack-in-aodv.html
set val(chan) Channel/WirelessChannel ;
set val(prop) Propagation/TwoRayGround ;
set val(netif) Phy/WirelessPhy ;
set val(mac) Mac/802_11 ;
set val(ifq) Queue/DropTail/PriQueue ;
set val(ll) LL ;
set val(ant) Antenna/OmniAntenna ;
set val(ifqlen) 40 ;
set val(nn) 11;
set val(rp) AODV ;
set val(brp) blackholeAODV ; # blackhole aodv protocol mentioned here....
set val(x) 4000 ;
set val(y) 2000 ;
set val(stop) 20 ;

set ns [new Simulator]
set tracefd [open bhatk.tr w]
set namtracefd [open wrlsaodv.nam w]
$ns trace-all $tracefd
$ns use-newtrace
$ns namtrace-all-wireless $namtracefd $val(x) $val(y)
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#GOD (General Operations Director)
create-god $val(nn)
$ns node-config -adhocRouting $val(rp) \
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
-macTrace ON \
-movementTrace ON \


for {
set i 0
} {
$i < $val(nn)
} {
 incr i
} {
 
set node_($i) [$ns node]
 
}
$node_(0) label "sender"
$node_(10) label "destination"
#########################################
$ns node-config -adhocRouting $val(brp)
set node_(9) [$ns node]
#blackhole node creation
#######################################

$node_(0) set X_ 300.0
$node_(0) set Y_ 1700.0
$node_(0) set Z_ 0.0
 
$node_(1) set X_ 300.0
$node_(1) set Y_ 1800.0
$node_(1) set Z_ 0.0
 
$node_(2) set X_ 480.0
$node_(2) set Y_ 1850.0
$node_(2) set Z_ 0.0
 
$node_(3) set X_ 600.0
$node_(3) set Y_ 1900.0
$node_(3) set Z_ 0.0
 
$node_(4) set X_ 730.0
$node_(4) set Y_ 1850.0
$node_(4) set Z_ 0.0
 
$node_(5) set X_ 850.0
$node_(5) set Y_ 1750.0
$node_(5) set Z_ 0.0
 
$node_(6) set X_ 1000.0
$node_(6) set Y_ 1700.0
$node_(6) set Z_ 0.0
 
$node_(7) set X_ 400.0
$node_(7) set Y_ 1500.0
$node_(7) set Z_ 0.0
 
$node_(8) set X_ 500.0
$node_(8) set Y_ 1600.0
$node_(8) set Z_ 0.0
 
$node_(9) set X_ 670.0
$node_(9) set Y_ 1550.0
$node_(9) set Z_ 0.0
 
$node_(10) set X_ 800.0
$node_(10) set Y_ 1500.0
$node_(10) set Z_ 0.0
 
#$node_(11) set X_ 950.0
#$node_(11) set Y_ 1500.0
#$node_(11) set Z_ 0.0
 
#$node_(12) set X_ 950.0
#$node_(12) set Y_ 1500.0
#$node_(12) set Z_ 0.0
 
#$node_(13) set X_ 950.0
#$node_(13) set Y_ 1500.0
#$node_(13) set Z_ 0.0
 
 
# Generation of movements     
$ns at 0.1 "$node_(0) setdest 3300.0 150.0 10.0"        
$ns at 0.1 "$node_(1) setdest 3600.0 440.0 10.0"
$ns at 0.1 "$node_(2) setdest 3650.0 550.0 10.0"
$ns at 0.1 "$node_(3) setdest 3700.0 450.0 10.0"
$ns at 0.1 "$node_(4) setdest 3750.0 540.0 10.0"
$ns at 0.1 "$node_(5) setdest 3750.0 400.0 10.0"
$ns at 0.1 "$node_(6) setdest 3800.0 500.0 10.0"
$ns at 0.1 "$node_(7) setdest 3300.0 260.0 10.0"
$ns at 0.1 "$node_(8) setdest 3480.0 300.0 10.0"
$ns at 0.1 "$node_(9) setdest 3600.0 400.0 10.0"
$ns at 0.1 "$node_(10) setdest 3700.0 300.0 10.0"

#$ns at 10.0 "$node_(11) setdest 3700.0 300.0 10.0"

set udp [new Agent/UDP]
$udp set class_ 1
set sink [new Agent/UDP]
$ns attach-agent $node_(0) $udp
$ns attach-agent $node_(1) $sink
$ns attach-agent $node_(2) $sink
$ns attach-agent $node_(3) $sink
$ns attach-agent $node_(4) $sink
$ns attach-agent $node_(5) $sink
$ns attach-agent $node_(6) $sink
$ns attach-agent $node_(7) $sink
$ns attach-agent $node_(8) $sink
$ns attach-agent $node_(9) $sink
$ns attach-agent $node_(10) $sink
#$ns attach-agent $node_(11) $sink
$ns connect $udp $sink

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 512


$ns at 0.1 "$cbr start"
$ns at 19.0 "$cbr stop"

$ns at 0.01 "$node_(9) label \"blackhole node\""

for {set i 0} {$i < $val(nn) } {incr i} {
$ns initial_node_pos $node_($i) 10
}

for {set i 0} {$i < $val(nn) } {incr i} {
$ns at $val(stop) "$node_($i) reset"
}

$ns at $val(stop) "stop"

proc stop {} {
global ns tracefd namtracefd
$ns flush-trace
close $tracefd
close $namtracefd
exec nam wrlsaodv.nam &
exit 0
}
$ns run
