#Create a simulator object
set ns [new Simulator]

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
if {$argc != 1} {
        set num 7
        puts "please give 1 argument. Taking 7 by default."
} else {
        set num [lindex $argv 0]
}


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

#Create given number of nodes
for {set i 0} {$i < $num} {incr i} {

}


#Create links between the nodes
for {set i 0} {$i < $num} {incr i} {
        set n($i) [$ns node]
        #Create a UDP agent and attach it to node n(0)
        set udp($i) [new Agent/UDP]
        $ns attach-agent $n($i) $udp($i)
        # Create a CBR traffic source and attach it to udp(i)
        set cbr($i) [new Application/Traffic/CBR]
        $cbr($i) set packetSize_ 500
        $cbr($i) set interval_ 0.005
        $cbr($i) attach-agent $udp($i)
        #Create a Null agent (a traffic sink) and attach it to every node
        set null($i) [new Agent/Null]
        $ns attach-agent $n($i) $null($i)

        for {set j 0} {$j < $i} {incr j} {
                $ns duplex-link $n($i) $n($j) 1Mb 10ms DropTail
                #Connect the traffic source with the traffic sink
        }

        set temp  [ expr $i / 2 ] 
        $ns connect $udp($i) $null($temp)
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
