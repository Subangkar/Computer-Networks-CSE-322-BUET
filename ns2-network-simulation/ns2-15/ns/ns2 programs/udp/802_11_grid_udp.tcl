################################################################802.11 in Grid topology with cross folw
set cbr_size 28
set cbr_rate 1.0Mb
set cbr_interval 1
set num_row 10 ;#number of nodes in a row
set num_col 10 ;#number of nodes in a column
set x_dim 200
set y_dim 200
set time_duration 25
set start_time 5
set parallel_start_gap 0.1
set cross_start_gap 0.2

set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
#set val(mac) SMac/802_15_4 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(rp) DSDV ;# routing protocol

set nm 802_11_grid_udp.nam
set tr 802_11_grid_udp.tr
set topo_file topo_802_11_grid_udp.txt
# 
# Initialize ns
#
set ns_ [new Simulator]

set tracefd [open $tr w]
$ns_ trace-all $tracefd

#$ns_ use-newtrace ;# use the new wireless trace file format

set namtrace [open $nm w]
$ns_ namtrace-all-wireless $namtrace $x_dim $y_dim

#set topofilename "topo_ex3.txt"
set topofile [open $topo_file "w"]

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $x_dim $y_dim
#$topo load_flatgrid 1000 1000

create-god [expr $num_row * $num_col ]

$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace ON -routerTrace OFF\
     -macTrace ON \
     -movementTrace OFF
 
for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_($i) [$ns_ node]
#	$node_($i) random-motion 0
}

set x_start [expr $x_dim/($num_row*2)];
set y_start [expr $y_dim/($num_col*2)];
set i 0;
while {$i < $num_row } {
#in same column
    for {set j 0} {$j < $num_col } {incr j} {
#in same row
	set m [expr $i+$j*$num_col];
#	$node_($m) set X_ [expr $i*240];
#	$node_($m) set Y_ [expr $k*240+20.0];
	set x_pos [expr $x_start+$i*($x_dim/$num_row)];
	set y_pos [expr $y_start+$j*($y_dim/$num_col)];
	$node_($m) set X_ $x_pos;
	$node_($m) set Y_ $y_pos;
	$node_($m) set Z_ 0.0
#	puts "$m"
	puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
    }
    incr i;
}; 

for {set i 0} {$i < $num_row * $num_col} {incr i} {
    set udp_($i) [new Agent/UDP]
    set null_($i) [new Agent/Null]

#	set udp_($i) [new Agent/TCP]
#	$udp_($i) set class_ $i
#	set null_($i) [new Agent/TCPSink]
#	$udp_($i) set fid_ $i
#	if { [expr $i%2] == 0} {
#		$ns_ color $i Blue
#	} else {
#		$ns_ color $i Red
#	}
} 

################################################PARALLEL FLOW
for {set i 0} {$i < $num_row } {incr i} {
	set udp_node $i
	set null_node [expr $i+(($num_col-1)*($num_row))]
	$ns_ attach-agent $node_($udp_node) $udp_($i)
  	$ns_ attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "UDP Src: $udp_node NULL Dest: $null_node\n"
} 

#  $ns_ attach-agent $node_(0) $udp_(0)
#  $ns_ attach-agent $node_(6) $null_(0)

for {set i 0} {$i < $num_row } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
}
for {set i 0} {$i < $num_row } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
} 

for {set i 0} {$i < $num_row } {incr i} {
     $ns_ at [expr $start_time+$i*$parallel_start_gap] "$cbr_($i) start"
}
####################################CROSS FLOW
set k $num_row
for {set i 1} {$i < [expr $num_col-1] } {incr i} {
	set udp_node [expr $i*$num_row]
	set null_node [expr ($i+1)*$num_row-1]
	$ns_ attach-agent $node_($udp_node) $udp_($k)
  	$ns_ attach-agent $node_($null_node) $null_($k)
	puts -nonewline $topofile "UDP Src: $udp_node NULL Dest: $null_node\n"
	incr k
} 

set k $num_row
for {set i 1} {$i < [expr $num_col-1] } {incr i} {
	$ns_ connect $udp_($k) $null_($k)
	incr k
}
set k $num_row
for {set i 1} {$i < [expr $num_col-1] } {incr i} {
	set cbr_($k) [new Application/Traffic/CBR]
	$cbr_($k) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($k) set interval_ $cbr_interval
	$cbr_($k) attach-agent $udp_($k)
	incr k
} 

set k $num_row
for {set i 1} {$i < [expr $num_col-1] } {incr i} {
	$ns_ at [expr $start_time+$i*$cross_start_gap] "$cbr_($k) start"
	incr k
}

#$ns_ at 11.0234 "$cbr_(0) start"
#$ns_ at 10.4578 "$cbr_(1) start" 
#$ns_ at 12.7184 "$cbr_(2) start"
#$ns_ at 12.2456 "$cbr_(3) start" 

# Tell nodes when the simulation ends
#
for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
    $ns_ at [expr $time_duration +10.0] "$node_($i) reset";
}
$ns_ at [expr $time_duration +10.0] "finish"
$ns_ at [expr $time_duration +10.01] "$ns_ nam-end-wireless [$ns_ now]; puts \"NS Exiting...\"; $ns_ halt"

proc finish {} {
	global ns_ tracefd namtrace topofile nm
	#global ns_ topofile
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	close $topofile
        exec nam $nm &
        exit 0
}

#set opt(mobility) "position.txt"
#source $opt(mobility)
#set opt(traff) "traffic.txt"
#source $opt(traff)

for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns_ initial_node_pos $node_($i) 4
}

puts "Starting Simulation..."
$ns_ run 
#$ns_ nam-end-wireless [$ns_ now]

