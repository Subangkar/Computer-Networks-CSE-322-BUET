#Create a simulator object
set ns [new Simulator]

#initializing variables
set nodes 10
set flows 5
set cbr_pckt_per_sec 200

#Tell the simulator to use dynamic routing
$ns rtproto DV

#Open the nam trace file
set nf [open wired.nam w]
set nt [open wired.tr w]
$ns namtrace-all $nf
$ns trace-all $nt

#Define necessery variables
#All Tcl scripts have access to three predefined variables.
#$argc - number items of arguments passed to a script.
#$argv - list of the arguments.
#$argv0 - name of the script.

#here's the if condition
if {[lindex $argv 0] == "node"} {
        set nodes [lindex $argv 1] 
        set flows [expr {floor($nodes/2)}] 
} elseif {[lindex $argv 0] == "rate"} {
        set cbr_pckt_per_sec [lindex $argv 1]

} elseif {[lindex $argv 0] == "flow"} {
        set flows [lindex $argv 1]
}


#Post input variables
#set cbr_interval [expr {1/cbr_pckt_per_sec}]
set cbr_interval [expr 1.0/$cbr_pckt_per_sec] 

#Define a 'finish' procedure
proc finish {} {
        global ns nf nt
        $ns flush-trace
	#Close the trace files
        close $nf
        close $nt
	#Execute nam on the trace file
        exec nam wired.nam &
        exit 0
}


#Create links between the nodes
for {set i 0} {$i < $nodes} {incr i} {
        set n($i) [$ns node]
        #Create a UDP agent and attach it to node n(0)
        set udp($i) [new Agent/UDP]
        $ns attach-agent $n($i) $udp($i)
        # Create a CBR traffic source and attach it to udp(i)
        set cbr($i) [new Application/Traffic/CBR]
        $cbr($i) set packetSize_ 500
        $cbr($i) set interval_ $cbr_interval
        $cbr($i) attach-agent $udp($i)
        #Create a Null agent (a traffic sink) and attach it to every node
        set null($i) [new Agent/Null]
        $ns attach-agent $n($i) $null($i)

        for {set j 0} {$j < $i} {incr j} {
                $ns duplex-link $n($i) $n($j) 1Mb 10ms DropTail
                #Connect the traffic source with the traffic sink
        }
}

for {set i 0} {$i <= $flows} {incr i} {
        set node1  [expr {round(floor(rand()*$nodes))}]
        set node2  [expr {round(floor(rand()*$nodes))}]

        $ns connect $udp($node1) $null($node2)
        $ns at $i "$cbr($i) start"
        #$ns rtmodel-at $i down $n($i) $n([ expr $i +1])
        #$ns rtmodel-at $j up $n($i) $n($j)
        $ns at 10.0 "$cbr($i) stop"
}




#Schedule events for the CBR agent and the network dynamics

#Call the finish procedure after 5 seconds of simulation time
$ns at 11.0 "finish"

#Run the simulation
$ns run
