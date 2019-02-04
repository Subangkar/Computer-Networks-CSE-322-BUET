################################################################802.11 in Grid topology with cross folw
set cbr_size [lindex $argv 2] ;#64 ; #[lindex $argv 2]; #4,8,16,32,64
set cbr_rate 11.0Mb
set per_11 [lindex $argv 1]
set cbr_pckt_per_sec [lindex $argv 3] ;#100
#set cbr_interval 0.00005 ; #[expr 1/[lindex $argv 2]] ;# ?????? 1 for 1 packets per second and 0.1 for 10 packets per second
set num_row [lindex $argv 0] ;#number of row
set num_col [lindex $argv 0] ;#number of column
set dist_adj_x 25
set dist_adj_y 25
set x_dim [expr $dist_adj_x*$num_col] ;#50 ; #[lindex $argv 1]
set y_dim [expr $dist_adj_y*$num_row] ;#50 ; #[lindex $argv 1]
set time_duration 15 ; #[lindex $argv 5] ;#50
set start_time 50 ;#100
set parallel_start_gap 0.0
set cross_start_gap 0.0


set cbr_pckt_per_sec_11 [expr $cbr_pckt_per_sec*$per_11/100]
set cbr_pckt_per_sec_15_4 [expr $cbr_pckt_per_sec*(100-$per_11)/100]
#set cbr_interval_11 [expr 1.0/$cbr_pckt_per_sec_11] 
#set cbr_interval_15_4 [expr 1.0/$cbr_pckt_per_sec_15_4] 
if {$cbr_pckt_per_sec_11 > 0} { 
	set cbr_interval_11 [expr 1.0/$cbr_pckt_per_sec_11] 
} else {
	set cbr_interval_11 1 ;# actually never used; non-zero value is given as otherwise some internal calculation of ns2 raises error
}

if {$cbr_pckt_per_sec_15_4 > 0} { 
	set cbr_interval_15_4 [expr 1.0/$cbr_pckt_per_sec_15_4] 
} else {
	set cbr_interval_15_4 1 ;# actually never used; non-zero value is given as otherwise some internal calculation of ns2 raises error
}


#############################################################ENERGY PARAMETERS
set val(energymodel_11)    EnergyModel     ;
set val(initialenergy_11)  1000            ;# Initial energy in Joules

set val(idlepower_11) 869.4e-3			;#LEAP (802.11g) 
set val(rxpower_11) 1560.6e-3			;#LEAP (802.11g)
set val(txpower_11) 1679.4e-3			;#LEAP (802.11g)
set val(sleeppower_11) 37.8e-3			;#LEAP (802.11g)
set val(transitionpower_11) 176.695e-3		;#LEAP (802.11g)	??????????????????????????????/
set val(transitiontime_11) 2.36			;#LEAP (802.11g)

#set val(idlepower_11) 900e-3			;#Stargate (802.11b) 
#set val(rxpower_11) 925e-3			;#Stargate (802.11b)
#set val(txpower_11) 1425e-3			;#Stargate (802.11b)
#set val(sleeppower_11) 300e-3			;#Stargate (802.11b)
#set val(transitionpower_11) 200e-3		;#Stargate (802.11b)	??????????????????????????????/
#set val(transitiontime_11) 3			;#Stargate (802.11b)

#puts "$MAC/802_11.dataRate_"
set range_11 [lindex $argv 5]

set bandwidth_11 [lindex $argv 4]

#set data_rate_11 [lindex $argv 4]
Mac/802_11 set dataRate_  11000000;#$data_rate_11 ;#11000000

puts "pck_per_sec: $cbr_pckt_per_sec pck_per_sec_11: $cbr_pckt_per_sec_11 pck_per_sec_15_4: $cbr_pckt_per_sec_15_4"
puts "pck_size:$cbr_size bandwidth: $bandwidth_11 range_11: $range_11"

#CHNG
set num_parallel_flow 0 ;#$num_row ;#[lindex $argv 0]	# along column
set num_cross_flow 0 ;#$num_col ;#[lindex $argv 0]		#along row
set num_random_flow [expr $num_row+$num_col] ;# ;#[expr ($num_row+$num_col)/2] ;# as 2 flows are created per random flow
set num_sink_flow 0 ;#[expr $num_row+$num_col] ;# ;#[expr ($num_row+$num_col)/2] ;# as 2 flows are created per sink flow
set sink_node 100 ;#sink id, dummy here; updated next

set start_15_4 1000

set grid 0
set extra_time 10 ;#10

set tcp_src Agent/TCP/Newreno ;# Agent/TCP or Agent/TCP/Reno or Agent/TCP/Newreno or Agent/TCP/FullTcp/Sack or Agent/TCP/Vegas
set tcp_sink Agent/TCPSink ;# Agent/TCPSink or Agent/TCPSink/Sack1

puts "TCP"

#set tcp_src Agent/UDP
#set tcp_sink Agent/Null


# TAHOE:	Agent/TCP		Agent/TCPSink
# RENO:		Agent/TCP/Reno		Agent/TCPSink
# NEWRENO:	Agent/TCP/Newreno	Agent/TCPSink
# SACK: 	Agent/TCP/FullTcp/Sack	Agent/TCPSink/Sack1
# VEGAS:	Agent/TCP/Vegas		Agent/TCPSink
# FACK:		Agent/TCP/Fack		Agent/TCPSink
# LINUX:	Agent/TCP/Linux		Agent/TCPSink

#	http://research.cens.ucla.edu/people/estrin/resources/conferences/2007may-Stathopoulos-Lukac-Dual_Radio.pdf

#set frequency_ 2.461e+9
#Phy/WirelessPhy set Rb_ 11*1e6            ;# Bandwidth
#Phy/WirelessPhy set freq_ $frequency_

set channel_11 6
set channel_15_4 26

set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
#set val(prop) Propagation/FreeSpace ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
#set val(mac) Mac/802_15_4 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 100 ;# max packet in ifq
set val(rp) DSDV ; #[lindex $argv 4] ;# routing protocol

Mac/802_11 set syncFlag_ 1

Mac/802_11 set dutyCycle_ cbr_interval_11


############################################## st
set val(chan_15_4) Channel/WirelessChannel ;# channel type
set val(prop_15_4) Propagation/TwoRayGround ;# radio-propagation model
#set val(prop) Propagation/FreeSpace ;# radio-propagation model
#set val(netif) Phy/WirelessPhy ;# network interface type
set val(netif_15_4) Phy/WirelessPhy/802_15_4 ;# network interface type
#set val(mac) Mac/802_11 ;# MAC type
set val(mac_15_4) Mac/802_15_4 ;# MAC type
set val(ifq_15_4) Queue/DropTail/PriQueue ;# interface queue type
set val(ll_15_4) LL ;# link layer type
set val(ant_15_4) Antenna/OmniAntenna ;# antenna model
set val(ifqlen_15_4) 100 ;# max packet in ifq
set val(rp_15_4) DSDV ;# routing protocol

Mac/802_15_4 set syncFlag_ 1

Mac/802_15_4 set dutyCycle_ cbr_interval_15_4


set val(energymodel_15_4)    EnergyModel     ;
set val(initialenergy_15_4)  1000            ;# Initial energy in Joules

set val(idlepower_15_4) 56.4e-3		;#LEAP	(active power in spec)
set val(rxpower_15_4) 59.1e-3			;#LEAP
set val(txpower_15_4) 52.2e-3			;#LEAP
set val(sleeppower_15_4) 0.6e-3		;#LEAP
set val(transitionpower_15_4) 35.708e-3		;#LEAP: 
set val(transitiontime_15_4) 2.4e-3		;#LEAP

#set val(idlepower_15_4) 3e-3			;#telos	(active power in spec)
#set val(rxpower_15_4) 38e-3			;#telos
#set val(txpower_15_4) 35e-3			;#telos
#set val(sleeppower_15_4) 15e-6			;#telos
#set val(transitionpower_15_4) 1.8e-6		;#telos: volt = 1.8V; sleep current of MSP430 = 1 microA; so, 1.8 micro W
#set val(transitiontime_15_4) 6e-6		;#telos

#Mac/802_15_4 set dataRate_ 0.250Mb
############################################## end


set nm simultaneous.nam
set tr /home/ubuntu/ns2\ programs/raw_data/simultaneous.tr
set topo_file topo_simultaneous.txt

#set topo_file 5.txt
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

if {$num_sink_flow > 0} { ;#sink
	create-god [expr 2*($num_row * $num_col + 1) ]
} else {
	create-god [expr 2*($num_row * $num_col) ]
}


#remove-all-packet-headers
#add-packet-header DSDV AODV ARP LL MAC CBR IP



#set val(prop)		Propagation/TwoRayGround
#set prop	[new $val(prop)]

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


#          		 -transitionTime 0.005 \
 

puts "start node creation"
for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_($i) [$ns_ node]
#	$node_($i) random-motion 0
	[$node_($i) set netif_(0)] set channel_number_ $channel_11
	[$node_($i) set netif_(0)] set bandwidth_ $bandwidth_11
	if {$range_11 == 100} { 
		[$node_($i) set netif_(0)] set RXThresh_ 1.61163e-08
	}

}

if {$num_sink_flow > 0} { ;#sink
	set sink_node [expr $num_row*$num_col] ;#sink id
	set node_($sink_node) [$ns_ node]
	$node_($sink_node) set X_ $x_dim
	$node_($sink_node) set Y_ $y_dim;
	$node_($sink_node) set Z_ 0.0
	puts -nonewline $topofile "SINK NODE $sink_node : at $x_dim $y_dim \n"
	if {$sink_node < $num_row*$num_col} {
		puts "*********ERROR: SINK NODE id($sink_node) is too LOW********"		
	}
	set sink_start_gap [expr 1.0/$num_sink_flow]

	[$node_($sink_node) set netif_(0)] set channel_number_ $channel_11
	[$node_($sink_node) set netif_(0)] set bandwidth_ $bandwidth_11
	if {$range_11 == 100} { 
		[$node_($sink_node) set netif_(0)] set RXThresh_ 1.61163e-08
	}
}

############################################ st
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
#Phy/WirelessPhy set CSThresh_ $dist(40m)
#Phy/WirelessPhy set RXThresh_ $dist(40m)

#$ns_ node-config -adhocRouting $val(rp_15_4) -llType $val(ll_15_4) \
#     -macType $val(mac_15_4)  -ifqType $val(ifq_15_4) \
#     -ifqLen $val(ifqlen_15_4) -antType $val(ant_15_4) \
#     -propType $val(prop_15_4) -phyType $val(netif_15_4) \
#     -channel  [new $val(chan_15_4)] -topoInstance $topo \
#     -agentTrace ON -routerTrace OFF\
#     -macTrace ON \
#     -movementTrace OFF \
#			 -energyModel $val(energymodel_15_4) \
#			 -idlePower $val(idlepower_15_4) \
#			 -rxPower $val(rxpower_15_4) \
#			 -txPower $val(txpower_15_4) \
#        		 -sleepPower $val(sleeppower_15_4) \
#         		 -transitionPower $val(transitionpower_15_4) \
#			 -transitionTime $val(transitiontime_15_4) \
#			 -initialEnergy $val(initialenergy_15_4)
#
#
##          		 -transitionTime 0.005 \


set channel_15_4 11
#set data_rate_11 1000000
#Mac/802_11 set dataRate_  $data_rate_11 ;#11000000

for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_([expr $i+$start_15_4]) [$ns_ node]
	[$node_([expr $i+$start_15_4]) set netif_(0)] set channel_number_ $channel_15_4
#	[$node_([expr $i+$start_15_4]) set netif_(0)] set RXThresh_ $dist(40m)

	[$node_([expr $i+$start_15_4]) set netif_(0)] set RXThresh_ 1.61163e-08 ;#100 m range
	[$node_([expr $i+$start_15_4]) set netif_(0)] set bandwidth_ 1e6 ;#1Mbps
}

if {$num_sink_flow > 0} { ;#sink
	set sink_node_15_4 [expr $start_15_4+$num_row*$num_col] ;#sink id
	set node_($sink_node_15_4) [$ns_ node]
	$node_($sink_node_15_4) set X_ $x_dim
	$node_($sink_node_15_4) set Y_ $y_dim;
	$node_($sink_node_15_4) set Z_ 0.0
	puts -nonewline $topofile "SINK NODE $sink_node_15_4 : at $x_dim $y_dim \n"
	if {$sink_node_15_4 < $start_15_4+$num_row*$num_col} {
		puts "*********ERROR: SINK NODE id($sink_node_15_4) is too LOW********"		
	}
	set sink_start_gap [expr 1.0/$num_sink_flow]

	[$node_($sink_node_15_4) set netif_(0)] set channel_number_ $channel_15_4
#	[$node_($sink_node_15_4) set netif_(0)] set RXThresh_ $dist(40m)

	[$node_($sink_node_15_4) set netif_(0)] set RXThresh_ 1.61163e-08  ;#100 m range
	[$node_($sink_node_15_4) set netif_(0)] set bandwidth_ 1e6 ;#1Mbps
}
############################################ end


#FULL CHNG
set x_start [expr $x_dim/($num_col*2)];
set y_start [expr $y_dim/($num_row*2)];
set i 0;
while {$i < $num_row } {
#in same column
    for {set j 0} {$j < $num_col } {incr j} {
#in same row
	set m [expr $i*$num_col+$j];
#	$node_($m) set X_ [expr $i*240];
#	$node_($m) set Y_ [expr $k*240+20.0];
#CHNG
	if {$grid == 1} {
		set x_pos [expr $x_start+$j*($x_dim/$num_col)];#grid settings
		set y_pos [expr $y_start+$i*($y_dim/$num_row)];#grid settings
	} else {
		set x_pos [expr int($x_dim*rand())] ;#random settings
		set y_pos [expr int($y_dim*rand())] ;#random settings
	}
	$node_($m) set X_ $x_pos;
	$node_($m) set Y_ $y_pos;
	$node_($m) set Z_ 0.0
#	puts "$m"
	puts -nonewline $topofile "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"
#	puts "$m x: [$node_($m) set X_] y: [$node_($m) set Y_] \n"

	$node_([expr $start_15_4+$m]) set X_ $x_pos;
	$node_([expr $start_15_4+$m]) set Y_ $y_pos;
	$node_([expr $start_15_4+$m]) set Z_ 0.0
#	puts "$m"
	puts -nonewline $topofile "[expr $start_15_4+$m] x: [$node_([expr $start_15_4+$m]) set X_] y: [$node_([expr $start_15_4+$m]) set Y_] \n"
    }
    incr i;
}; 

if {$grid == 1} {
	puts "GRID topology"
} else {
	puts "RANDOM topology"
}
puts "node creation complete"












#CHNG
if {$num_parallel_flow > $num_row} {
	set num_parallel_flow $num_row
}

#CHNG
if {$num_cross_flow > $num_col} {
	set num_cross_flow $num_col
}

#CHNG
for {set i 0} {$i < [expr $num_parallel_flow + $num_cross_flow + $num_random_flow  + $num_sink_flow]} {incr i} { ;#sink
#    set udp_($i) [new Agent/UDP]
#    set null_($i) [new Agent/Null]
	set udp_($i) [new $tcp_src]
	$udp_($i) set class_ $i
	set null_($i) [new $tcp_sink]
	$udp_($i) set fid_ $i
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}

	set f_4 [expr $i+$start_15_4]	
	set udp_($f_4) [new $tcp_src]
	$udp_($f_4) set class_ $f_4
	set null_($f_4) [new $tcp_sink]
	$udp_($f_4) set fid_ $f_4
	if { [expr $f_4%2] == 0} {
		$ns_ color $f_4 Blue
	} else {
		$ns_ color $f_4 Red
	}
	
} 

################################################PARALLEL FLOW

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set udp_node $i
	set null_node [expr $i+(($num_col)*($num_row-1))];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($i)
  	$ns_ attach-agent $node_($null_node) $null_($i)
	puts -nonewline $topofile "PARALLEL: Src: $udp_node Dest: $null_node\n"

	set f_4 [expr $i+$start_15_4]	
	set udp_node $f_4
	set null_node [expr $f_4+(($num_col)*($num_row-1))];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($f_4)
  	$ns_ attach-agent $node_($null_node) $null_($f_4)
	puts -nonewline $topofile "PARALLEL: Src: $udp_node Dest: $null_node\n"
} 

#  $ns_ attach-agent $node_(0) $udp_(0)
#  $ns_ attach-agent $node_(6) $null_(0)

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
     $ns_ connect $udp_($i) $null_($i)

     set f_4 [expr $i+$start_15_4]	
     $ns_ connect $udp_($f_4) $null_($f_4)
}
#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval_11
	$cbr_($i) attach-agent $udp_($i)

        set f_4 [expr $i+$start_15_4]	
	set cbr_($f_4) [new Application/Traffic/CBR]
	$cbr_($f_4) set packetSize_ $cbr_size
	$cbr_($f_4) set rate_ $cbr_rate
	$cbr_($f_4) set interval_ $cbr_interval_15_4
	$cbr_($f_4) attach-agent $udp_($f_4)
} 

#CHNG
for {set i 0} {$i < $num_parallel_flow } {incr i} {
	if {$cbr_pckt_per_sec_11 > 0} { 
	     $ns_ at [expr $start_time+$i*$parallel_start_gap] "$cbr_($i) start"
	}

	if {$cbr_pckt_per_sec_15_4 > 0} { 
	     set f_4 [expr $i+$start_15_4]	
	     $ns_ at [expr $start_time+$i*$parallel_start_gap] "$cbr_($f_4) start" ;#retain i here
	}
}
####################################CROSS FLOW
#CHNG
set k $num_parallel_flow 
#for {set i 1} {$i < [expr $num_col-1] } {incr i} {
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	set udp_node [expr $i*$num_col];#CHNG
	set null_node [expr ($i+1)*$num_col-1];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($k)
  	$ns_ attach-agent $node_($null_node) $null_($k)
	puts -nonewline $topofile "CROSS: Src: $udp_node Dest: $null_node\n"


	set f_4 [expr $k+$start_15_4]	
	set udp_node [expr $i*$num_col+$start_15_4];#CHNG
	set null_node [expr ($i+1)*$num_col-1+$start_15_4];#CHNG
	$ns_ attach-agent $node_($udp_node) $udp_($f_4)
  	$ns_ attach-agent $node_($null_node) $null_($f_4)
	puts -nonewline $topofile "CROSS: Src: $udp_node Dest: $null_node\n"
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	$ns_ connect $udp_($k) $null_($k)

	set f_4 [expr $k+$start_15_4]	
	$ns_ connect $udp_($f_4) $null_($f_4)
	incr k
}
#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	set cbr_($k) [new Application/Traffic/CBR]
	$cbr_($k) set packetSize_ $cbr_size
	$cbr_($k) set rate_ $cbr_rate
	$cbr_($k) set interval_ $cbr_interval_11
	$cbr_($k) attach-agent $udp_($k)

	set f_4 [expr $k+$start_15_4]	
	set cbr_($f_4) [new Application/Traffic/CBR]
	$cbr_($f_4) set packetSize_ $cbr_size
	$cbr_($f_4) set rate_ $cbr_rate
	$cbr_($f_4) set interval_ $cbr_interval_15_4
	$cbr_($f_4) attach-agent $udp_($f_4)
	incr k
} 

#CHNG
set k $num_parallel_flow
#CHNG
for {set i 0} {$i < $num_cross_flow } {incr i} {
	if {$cbr_pckt_per_sec_11 > 0} { 
		$ns_ at [expr $start_time+$i*$cross_start_gap] "$cbr_($k) start"
	}

	if {$cbr_pckt_per_sec_15_4 > 0} { 
		set f_4 [expr $k+$start_15_4]	
		$ns_ at [expr $start_time+$i*$cross_start_gap] "$cbr_($f_4) start"
	}
	incr k
}
#######################################################################RANDOM FLOW
set r $k
set rt $r
set num_node [expr $num_row*$num_col]
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	set udp_node [expr int($num_node*rand())] ;# src node
	set null_node $udp_node
	while {$null_node==$udp_node} {
		set null_node [expr int($num_node*rand())] ;# dest node
	}
	$ns_ attach-agent $node_($udp_node) $udp_($rt)
  	$ns_ attach-agent $node_($null_node) $null_($rt)
	puts -nonewline $topofile "RANDOM:  Src: $udp_node Dest: $null_node\n"
	#puts -nonewline "RANDOM:  Src: $udp_node Dest: $null_node\n"

	set udp_node [expr $udp_node+$start_15_4] ;# src node
	set null_node [expr $null_node+$start_15_4]
	set f_4 [expr $rt+$start_15_4]	
	$ns_ attach-agent $node_($udp_node) $udp_($f_4)
  	$ns_ attach-agent $node_($null_node) $null_($f_4)
	puts -nonewline $topofile "RANDOM:  Src: $udp_node Dest: $null_node\n"
	#puts -nonewline "RANDOM:  Src: $udp_node Dest: $null_node\n"
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	$ns_ connect $udp_($rt) $null_($rt)

	set f_4 [expr $rt+$start_15_4]	
	$ns_ connect $udp_($f_4) $null_($f_4)
	incr rt
}
set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval_11
	$cbr_($rt) attach-agent $udp_($rt)

	set f_4 [expr $rt+$start_15_4]	
	set cbr_($f_4) [new Application/Traffic/CBR]
	$cbr_($f_4) set packetSize_ $cbr_size
	$cbr_($f_4) set rate_ $cbr_rate
	$cbr_($f_4) set interval_ $cbr_interval_15_4
	$cbr_($f_4) attach-agent $udp_($f_4)
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_random_flow+1]} {incr i} {
	if {$cbr_pckt_per_sec_11 > 0} { 
		$ns_ at [expr $start_time] "$cbr_($rt) start"
	}

	if {$cbr_pckt_per_sec_15_4 > 0} { 
		set f_4 [expr $rt+$start_15_4]	
		$ns_ at [expr $start_time] "$cbr_($f_4) start"
	}
	incr rt
}

#######################################################################SINK FLOW
set r $rt
set rt $r
set num_node [expr $num_row*$num_col]
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	set udp_node [expr int($num_node*rand())] ;#[expr $i-1] ;#[expr int($num_node*rand())] ;# src node
	set null_node $sink_node
	#while {$null_node==$udp_node} {
	#	set null_node [expr int($num_node*rand())] ;# dest node
	#}
	$ns_ attach-agent $node_($udp_node) $udp_($rt)
  	$ns_ attach-agent $node_($null_node) $null_($rt)
	puts -nonewline $topofile "SINK:  Src: $udp_node Dest: $null_node\n"

	set udp_node [expr $udp_node+$start_15_4] ;#[expr $i-1+$start_15_4] ;#[expr int($num_node*rand())] ;# src node
	set null_node [expr $sink_node+$start_15_4]
	#puts -nonewline "SINK:  Src: $udp_node Dest: $null_node $sink_node $start_15_4\n"
	#while {$null_node==$udp_node} {
	#	set null_node [expr int($num_node*rand())] ;# dest node
	#}
	set f_4 [expr $rt+$start_15_4]	
	$ns_ attach-agent $node_($udp_node) $udp_($f_4)
  	$ns_ attach-agent $node_($null_node) $null_($f_4)
	puts -nonewline $topofile "SINK:  Src: $udp_node Dest: $null_node\n"
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	$ns_ connect $udp_($rt) $null_($rt)

	set f_4 [expr $rt+$start_15_4]	
	$ns_ connect $udp_($f_4) $null_($f_4)
	incr rt
}
set rt $r
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval_11
	$cbr_($rt) attach-agent $udp_($rt)

	set f_4 [expr $rt+$start_15_4]	
	set cbr_($f_4) [new Application/Traffic/CBR]
	$cbr_($f_4) set packetSize_ $cbr_size
	$cbr_($f_4) set rate_ $cbr_rate
	$cbr_($f_4) set interval_ $cbr_interval_15_4
	$cbr_($f_4) attach-agent $udp_($f_4)
	incr rt
} 

set rt $r
for {set i 1} {$i < [expr $num_sink_flow+1]} {incr i} {
	if {$cbr_pckt_per_sec_11 > 0} { 
		$ns_ at [expr $start_time+$i*$sink_start_gap+rand()] "$cbr_($rt) start"
	}

	if {$cbr_pckt_per_sec_15_4 > 0} { 
		set f_4 [expr $rt+$start_15_4]	
		$ns_ at [expr $start_time+$i*$sink_start_gap+rand()] "$cbr_($f_4) start"
	}
	incr rt
}

puts "flow creation complete"
##########################################################################END OF FLOW GENERATION

# Tell nodes when the simulation ends
#
for {set i 0} {$i < [expr $num_row*$num_col] } {incr i} {
    $ns_ at [expr $start_time+$time_duration] "$node_($i) reset";

    set f_4 [expr $i+$start_15_4]	
    $ns_ at [expr $start_time+$time_duration] "$node_($f_4) reset";
}
$ns_ at [expr $start_time+$time_duration +$extra_time] "finish"
#$ns_ at [expr $start_time+$time_duration +20] "puts \"NS Exiting...\"; $ns_ halt"
$ns_ at [expr $start_time+$time_duration +$extra_time] "$ns_ nam-end-wireless [$ns_ now]; puts \"NS Exiting...\"; $ns_ halt"

$ns_ at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
$ns_ at [expr $start_time+$time_duration] "puts \"end of simulation duration\""

proc finish {} {
	puts "finishing"
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
	$ns_ initial_node_pos $node_($i) 4

        set f_4 [expr $i+$start_15_4]	
	$ns_ initial_node_pos $node_($f_4) 4
}

puts "Starting Simulation..."
$ns_ run 
#$ns_ nam-end-wireless [$ns_ now]

