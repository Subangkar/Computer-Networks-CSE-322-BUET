################################################################802.11 in Grid topology with cross folw
set cbr_size 28
set cbr_rate 11.0Mb
set cbr_interval 1
set num_row 3 ;#number of nodes in a row
set num_col 3 ;#number of nodes in a column
set x_dim 500
set y_dim 500
set time_duration 10
set start_time 5
set parallel_start_gap 0.1
set cross_start_gap 0.2

set cbr_type CBR
set cbr_size_15 28
set cbr_rate_15 0.250Mb
#set cbr_interval 1

set collaborator_gap 25
set collaborator_row [expr $x_dim/$collaborator_gap+1];#number of collaborator in a row
set collaborator_col [expr $y_dim/$collaborator_gap+1];#number of collaborator in a row
set collaborator_num [expr $collaborator_row*$collaborator_col];#total number of collaborator

#############################################################ENERGY PARAMETERS
set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules
set val(idlepower_11) 900e-3			;#Stargate (802.11b) 
set val(rxpower_11) 925e-3			;#Stargate (802.11b)
set val(txpower_11) 1425e-3			;#Stargate (802.11b)
set val(sleeppower_11) 300e-3			;#Stargate (802.11b)
set val(transitionpower_11) 200e-3		;#Stargate (802.11b)	??????????????????????????????/
set val(transitiontime_11) 3			;#Stargate (802.11b)


set val(energymodel_15_4)    EnergyModel     ;
set val(initialenergy_15_4)  1000            ;# Initial energy in Joules
set val(idlepower_15_4) 3e-3			;#telos	(active power in spec)
set val(rxpower_15_4) 38e-3			;#telos
set val(txpower_15_4) 35e-3			;#telos
set val(sleeppower_15_4) 15e-6			;#telos
set val(transitionpower_15_4) 1.8e-6		;#telos: volt = 1.8V; sleep current of MSP430 = 1 microA; so, 1.8 micro W
set val(transitiontime_15_4) 6e-6		;#telos



#set frequency_ 2.461e+9
#Phy/WirelessPhy set Rb_ 11*1e6            ;# Bandwidth
#Phy/WirelessPhy set freq_ $frequency_

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

set val(chan_15) Channel/WirelessChannel ;# channel type
set val(prop_15) Propagation/TwoRayGround ;# radio-propagation model
set val(netif_15) Phy/WirelessPhy/802_15_4 ;# network interface type
set val(mac_15) Mac/802_15_4 ;# MAC type
#set val(mac) SMac/802_15_4 ;# MAC type
set val(ifq_15) Queue/DropTail/PriQueue ;# interface queue type
set val(ll_15) LL ;# link layer type
set val(ant_15) Antenna/OmniAntenna ;# antenna model
set val(ifqlen_15) 50 ;# max packet in ifq
set val(rp_15) AODV ;# routing protocol
set val(energymodel_15) EnergyModel;
set val(initialenergy_15) 100;



set nm 802_11_and_802_15_4_overlap_grid_tcp_with_collaborator.nam
set tr 802_11_and_802_15_4_overlap_grid_tcp_with_collaborator.tr
set topo_file topo_802_11_and_802_15_4_overlap_grid_tcp_with_collaborator.txt
# 
# Initialize ns
#
set ns_ [new Simulator]

set tracefd [open $tr w]
$ns_ trace-all $tracefd

#$ns_ use-newtrace ;# use the new wireless trace file format

set namtrace [open $nm w]
#$ns_ namtrace-all-wireless $namtrace $x_dim $y_dim

#set topofilename "topo_ex3.txt"
set topofile [open $topo_file "w"]

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $x_dim $y_dim
#$topo load_flatgrid 1000 1000

create-god [expr $num_row * $num_col * 2 ]

$ns_ node-config -adhocRouting $val(rp) -llType $val(ll) \
     -macType $val(mac)  -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) -antType $val(ant) \
     -propType $val(prop) -phyType $val(netif) \
     -channel  [new $val(chan)] -topoInstance $topo \
     -agentTrace ON -routerTrace OFF\
     -macTrace ON \
     -movementTrace OFF \
			 -energyModel $val(energymodel_11) \
			 -idlePower $val(idlepower_11) \
			 -rxPower $val(rxpower_11) \
			 -txPower $val(txpower_11) \
          		 -sleepPower $val(sleeppower_11) \
          		 -transitionPower $val(transitionpower_11) \
			 -transitionTime $val(transitiontime_11) \
			 -initialEnergy $val(initialenergy_11)
 
for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_($i) [$ns_ node]
#	$node_($i) random-motion 0
}

set x_start [expr $x_dim/($num_row*2)];
set y_start [expr $y_dim/($num_col*2)];
set i 0;
while {$i < $num_col } {
#in same column
    for {set j 0} {$j < $num_row } {incr j} {
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
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]

	set udp_($i) [new Agent/TCP]
	$udp_($i) set class_ $i
	set null_($i) [new Agent/TCPSink]
	$udp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}
} 

################################################PARALLEL FLOW
for {set i 0} {$i < $num_row } {incr i} {
	set udp_node $i
	set null_node [expr $i+(($num_col-1)*($num_row))]
	$ns_ attach-agent $node_($udp_node) $udp_($i)
  	$ns_ attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "Src: $udp_node Dest: $null_node\n"
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
	puts -nonewline $topofile "Src: $udp_node Dest: $null_node\n"
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
	$cbr_($k) set rate_ $cbr_rate
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








########################################################################	802.15.4

#set frequency_ 2.405e+9
#Phy/WirelessPhy set Rb_ 5*1e6            ;# Bandwidth
#Phy/WirelessPhy set freq_ $frequency_

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


$ns_ node-config -adhocRouting $val(rp_15) -llType $val(ll_15) \
	     -macType $val(mac_15)  -ifqType $val(ifq_15) \
	     -ifqLen $val(ifqlen_15) -antType $val(ant_15) \
	     -propType $val(prop_15) -phyType $val(netif_15) \
	     -channel  [new $val(chan_15)] -topoInstance $topo \
	     -agentTrace ON -routerTrace OFF\
	     -macTrace ON \
	     -movementTrace OFF \
			 -energyModel $val(energymodel_15_4) \
			 -idlePower $val(idlepower_15_4) \
			 -rxPower $val(rxpower_15_4) \
			 -txPower $val(txpower_15_4) \
          		 -sleepPower $val(sleeppower_15_4) \
          		 -transitionPower $val(transitionpower_15_4) \
			 -transitionTime $val(transitiontime_15_4) \
			 -initialEnergy $val(initialenergy_15_4)

set mote_15 [expr $num_row*$num_col] 
for {set i $mote_15} {$i < [expr $num_row*$num_col*2]} {incr i} {
	set node_($i) [$ns_ node]
}

set x_start [expr $x_dim/($num_row*2)];
set y_start [expr $y_dim/($num_col*2)];
set i 0;
while {$i < [expr $num_col] } {
#in same column
    for {set j 0} {$j < $num_row } {incr j} {
#in same row
	set m [expr $i+$j*$num_col+$mote_15];
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

for {set i $mote_15} {$i < [expr $num_row*$num_col*2]} { incr i } {
	$ns_ initial_node_pos $node_($i) 4
}


##########################################################################COLLABORATORS SATART
set start_collaborator [expr $num_row*$num_col*2]
for {set i $start_collaborator} {$i < [expr $start_collaborator+$collaborator_num]} {incr i} {
	set node_($i) [$ns_ node]
#	$node_($i) random-motion 0
}

set i 0;
while {$i < $collaborator_col } {
#in same column
    for {set j 0} {$j < $collaborator_row } {incr j} {
#in same row
	set m [expr $i+$j*$collaborator_col+$start_collaborator];
	set x_pos [expr $i*($collaborator_gap)];
	set y_pos [expr $j*($collaborator_gap)];
	if {$x_pos <= $x_dim && $y_pos <= $y_dim} {
		$node_($m) set X_ $x_pos;
		$node_($m) set Y_ $y_pos;
		$node_($m) set Z_ 0.0
#		puts "$m"
		puts -nonewline $topofile "Collaborator($m)-> x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
	}
    }
    incr i;
}; 

for {set i $start_collaborator} {$i < [expr $start_collaborator+$collaborator_num]} {incr i} {
	$ns_ initial_node_pos $node_($i) 1
}

###########################################################################COLLABORATORS END


for {set i $mote_15} {$i < $num_row * $num_col*2} {incr i} {
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]
	set udp_($i) [new Agent/TCP]
	$udp_($i) set class_ $i
	set null_($i) [new Agent/TCPSink]
	$udp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}
} 


################################################PARALLEL FLOW
for {set i $mote_15} {$i < [expr $num_row+$mote_15] } {incr i} {
	set udp_node $i
	set null_node [expr $i+(($num_col-1)*($num_row))]
	$ns_ attach-agent $node_($udp_node) $udp_($i)
  	$ns_ attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "UDP Src: $udp_node NULL Dest: $null_node\n"
} 

#  $ns_ attach-agent $node_(0) $udp_(0)
#  $ns_ attach-agent $node_(6) $null_(0)

for {set i $mote_15} {$i < [expr $num_row+$mote_15] } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
}
for {set i $mote_15} {$i < [expr $num_row+$mote_15] } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set type_ $cbr_type
	$cbr_($i) set packetSize_ $cbr_size_15
	$cbr_($i) set rate_ $cbr_rate_15
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
} 

for {set i $mote_15} {$i < [expr $num_row+$mote_15] } {incr i} {
     $ns_ at [expr $start_time+($i-$mote_15)*$parallel_start_gap] "$cbr_($i) start"
}
####################################CROSS FLOW
set k [expr $num_row+$mote_15]
for {set i 1} {$i < [expr $num_col-1] } {incr i} {
	set udp_node [expr $i*$num_row+$mote_15]
	set null_node [expr ($i+1)*$num_row-1+$mote_15]
	$ns_ attach-agent $node_($udp_node) $udp_($k)
  	$ns_ attach-agent $node_($null_node) $null_($k)
	puts -nonewline $topofile "UDP Src: $udp_node NULL Dest: $null_node\n"
	incr k
} 

set k [expr $num_row+$mote_15]
for {set i 1} {$i < [expr $num_col-1] } {incr i} {
	$ns_ connect $udp_($k) $null_($k)
	incr k
}
set k [expr $num_row+$mote_15]
for {set i 1} {$i < [expr $num_col-1] } {incr i} {
	set cbr_($k) [new Application/Traffic/CBR]
	$cbr_($k) set type_ $cbr_type
	$cbr_($k) set packetSize_ $cbr_size_15
	$cbr_($k) set rate_ $cbr_rate_15
	$cbr_($k) set interval_ $cbr_interval
	$cbr_($k) attach-agent $udp_($k)
	incr k
} 

set k [expr $num_row+$mote_15]
for {set i 1} {$i < [expr $num_col-1] } {incr i} {
	$ns_ at [expr $start_time+$i*$cross_start_gap] "$cbr_($k) start"
	incr k
}


# Tell nodes when the simulation ends
#
for {set i 0} {$i < [expr $num_row*$num_col*2] } {incr i} {
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
#        exec nam $nm &
        exit 0
}

#set opt(mobility) "position.txt"
#source $opt(mobility)
#set opt(traff) "traffic.txt"
#source $opt(traff)

for {set i 0} {$i < [expr $num_row*$num_col]  } { incr i} {
	$ns_ initial_node_pos $node_($i) 8
}

puts "Starting Simulation..."
$ns_ run 
#$ns_ nam-end-wireless [$ns_ now]

