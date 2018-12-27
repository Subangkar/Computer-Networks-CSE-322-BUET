# Vaddina Prakash Rao
# Chair of Telecommunications
# TU Dresden.

# Warning: Hardcoded paths are included !!

# COMMAND TO EXECUTE THIS SCRIPT FILE WITH A PARSING TRACE FILE: awk -f <awk-script-filename.awk> <filename.tr>

# Parse a ns2 wireless trace file and generate the following stats:
# - number of flows (senders)
# - time of simulation run
# - number of packets sent (at the Application)
# - number of packets received (at the Application)
# - number of packets dropped (at the Application)
# - number of collisions (802.11)
# - average delay
# - average throughput
# - average traffic rate (measured)

function average (array) {
    sum = 0;
    items = 0;
    for (i in array) {
        sum += array[i];
        items++;
    }
    if (sum == 0 || items == 0)
        return 0;
    else
        return sum / items;
}

function max(array) {
    for (i in array) {
        if (array[i] > largest)
            largest = array[i];
    }
    return largest;
}

function min(array) {
    smallest = 0;
    for (i in array) {
        if (0 == smallest)
            smallest = array[i];
        else if (array[i] < smallest)
            smallest = array[i];
    }
    return smallest;
}


BEGIN {

    # Records the total traffic packets sent, received and dropped.
    total_AGTpackets_sent = 0;
    total_AGTpackets_received = 0;
    total_AGTpackets_dropped = 0;

    signal=0;
    
    no_of_nodes=0;    
    route_reqs=0;
    
    no_of_flows = 0;
    
    # FOR EACH ZB PKT TYPE: CM1, CM2, CM3, ...
    
    # Variables collecting individually each zigbee packets (CM1, CM2, ...) sent, received or dropped.
    sent_ZB[11]=0;
    received_ZB[11]=0;
    dropped_ZB[11]=0;
    
    # Accumulated size of individual zigbee packets (CM1, CM2, ...) sent, received and dropped.
    sent_ZBsize[11]=0;
    received_ZBsize[11]=0;
    dropped_ZBsize[11]=0;
    
    # IRRESPECTIVE OF ZB PKT TYPE
    
    # Sum of the number of all Zigbee packets, irrespective of its type, sent, received and dropped.
    total_sent_ZBpkts=0;
    total_received_ZBpkts=0;
    total_dropped_ZBpkts=0;
    
    # Sum of the size of all Zigbee packets, irrespective of its type, sent, received and dropped.
    total_sent_ZBsize=0;
    total_received_ZBsize=0;
    total_dropped_ZBsize=0;
	 
    first_packet_sent = 0;
    last_packet_sent = 0;
    last_packet_received = 0;
    pkt_delivery_ration = 0;
    
    # Variables defining the reason for the dropped packets
    APS = 0;
    LQI = 0;

    END_ = 0;
    COL = 0;
    DUP = 0;
    ERR = 0;
    RET = 0;
    STA = 0;
    BSY = 0;
    NRTE = 0;
    LOOP = 0;
    TTL = 0;
    TOUT = 0;
    CBK = 0;
    IFQ = 0;
    ARP = 0;
    OUT = 0;

    hashes = 0;
    others = 0;

    APS_ = 0;
    LQI_ = 0;

    END__ = 0;
    COL_ = 0;
    DUP_ = 0;
    ERR_ = 0;
    RET_ = 0;
    STA_ = 0;
    BSY_ = 0;
    NRTE_ = 0;
    LOOP_ = 0;
    TTL_ = 0;
    TOUT_ = 0;
    CBK_ = 0;
    IFQ_ = 0;
    ARP_ = 0;
    OUT_ = 0;

    hashes_ = 0;
    others_ = 0;
}
{
    event = $1;
    time = $2;
    node = $3;
    type = $4;
    reason = $5;
    node2 = $5;
    packetid = $6;
    mac_sub_type=$7;
    size=$8;
    source = $11;
    dest = $10;
    energy=$14;

# strip leading and trailing _ from node
    sub(/^_*/, "", node);
    sub(/_*$/, "", node);
    
# strip trailing ] from the energy value
    sub(/]*$/, "", energy);

    if (time < simulation_start || simulation_start == 0)
        simulation_start = time;
	
    if (time > simulation_end)
        simulation_end = time;

    if (reason == "COL")
        total_collisions++;

# Check for the dropped packets
    if (event == "D")
        {
            if (reason == "APS")
                {
		    if (mac_sub_type == "cbr")
			APS++;
		    else
			APS_++;
		}

            else if (reason == "LQI")
                {
		    if (mac_sub_type == "cbr")
            		LQI++;
		    else
			LQI_++;
		}

            else if (reason == "END")
                {
		    if (mac_sub_type == "cbr")
            		END_++;
		    else
			END__++;
		}

            else if (reason == "COL")
                {
		    if (mac_sub_type == "cbr")
            		COL++;
		    else
			COL_++;
		}

            else if (reason == "DUP")
                {
		    if (mac_sub_type == "cbr")
            		DUP++;
		    else
			DUP_++;
		}

            else if (reason == "ERR")
                {
		    if (mac_sub_type == "cbr")
            		ERR++;
		    else
			ERR_++;
		}

            else if (reason == "RET")
                {
		    if (mac_sub_type == "cbr")
            		RET++;
		    else
			RET_++;
		}

            else if (reason == "STA")
                {
		    if (mac_sub_type == "cbr")
            		STA++;
		    else
			STA_++;
		}
            else if (reason == "BSY")
                {
		    if (mac_sub_type == "cbr")
            		BSY++;
		    else
			BSY_++;
		}
            else if (reason == "NRTE")
                {
		    if (mac_sub_type == "cbr")
            		NRTE++;
		    else
			NRTE_++;
		}

            else if (reason == "LOOP")
                {
		    if (mac_sub_type == "cbr")
            		LOOP++;
		    else
			LOOP_++;
		}

            else if (reason == "TTL")
                {
		    if (mac_sub_type == "cbr")
            		TTL++;
		    else
			TTL_++;
		}

            else if (reason == "TOUT")
                {
		    if (mac_sub_type == "cbr")
            		TOUT++;
		    else
			TOUT_++;
		}

            else if (reason == "CBK")
                {
		    if (mac_sub_type == "cbr")
            		CBK++;
		    else
			CBK_++;
		}

            else if (reason == "IFQ")
                {
		    if (mac_sub_type == "cbr")
            		IFQ++;
		    else
			IFQ_++;
		}

            else if (reason == "ARP")
                {
		    if (mac_sub_type == "cbr")
            		ARP++;
		    else
			ARP_++;
		}

            else if (reason == "OUT")
                {
		    if (mac_sub_type == "cbr")
            		OUT++;
		    else
			OUT_++;
		}
		    
            else if (reason == "---")
                {
        	    if (type == "IFQ" && mac_sub_type == "cbr")
            		hashes++;
		    else if(type == "IFQ")
			hashes_++;
		}

            else
                {
		    if (mac_sub_type == "cbr")
			others++;
		    else
			others_++;
		}
    }

# Check for a MAC packet
    if (event !="N")
    {
	if (event == "s")
	    {
                if (source == "a")
                    source = 10;
                else if (source == "b")
                    source = 11;
                else if (source == "c")
                    source = 12;
                else if (source == "d")
                    source = 13;
                else if (source == "e")
                    source = 14;
                else if (source == "f")
                    source = 15;
                else if (source == "10")
                    source = 16;
                else if (source == "11")
                    source = 17;
                else if (source == "12")
                    source = 18;
                else if (source == "13")
                    source = 19;
                else if (source == "14")
                    source = 20;
                else if (source == "15")
                    source = 21;
                else if (source == "16")
                    source = 22;
                else if (source == "17")
                    source = 23;
                else if (source == "18")
                    source = 24;
                else if (source == "19")
                    source = 25;
                else if (source == "1a")
                    source = 26;
                else if (source == "1b")
                    source = 27;
                else if (source == "1c")
                    source = 28;
                else if (source == "1d")
                    source = 29;
                else if (source == "1e")
                    source = 30;
                else
                    source = source;

                if (dest == "a")
                    dest = 10;
                else if (dest == "b")
                    dest = 11;
                else if (dest == "c")
                    dest = 12;
                else if (dest == "d")
                    dest = 13;
                else if (dest == "e")
                    dest = 14;
                else if (dest == "f")
                    dest = 15;
                else if (dest == "10")
                    dest = 16;
                else if (dest == "11")
                    dest = 17;
                else if (dest == "12")
                    dest = 18;
                else if (dest == "13")
                    dest = 19;
                else if (dest == "14")
                    dest = 20;
                else if (dest == "15")
                    dest = 21;
                else if (dest == "16")
                    dest = 22;
                else if (dest == "17")
                    dest = 23;
                else if (dest == "18")
                    dest = 24;
                else if (dest == "19")
                    dest = 25;
                else if (dest == "1a")
                    dest = 26;
                else if (dest == "1b")
                    dest = 27;
                else if (dest == "1c")
                    dest = 28;
                else if (dest == "1d")
                    dest = 29;
                else if (dest == "1e")
                    dest = 30;
                else
                    dest = dest;

                # The number of flows in the network, irrespective if the transmitted packets are received or not !!
                if (mac_sub_type=="cbr" && dest != "ffffffff")
                    {
                        if (no_of_flows == 0 && (source!=dest) && (source==0 || dest==0))
                        {
                            sources[no_of_flows] = source;
                            dests[no_of_flows] = dest;
                            no_of_flows++;
                        }
                        else
                        {
                            flag = 1;
                            i = 0;

                            while (i<no_of_flows && (source!=dest) && (source==0 || dest==0))
                                {
                                    if (!(sources[i]==source && dests[i]==dest))
                                        {
                                            #printf ("%d-%d :: %d :: %d-%d\n", source, dest, i, sources[i], dests[i]);
                                            #if (source == 3 && dest == 0)
                                            #printf("********************%s********************\n", $0);
                                            flag = 0;
                                        }
                                    else
                                        {
                                            flag = 1;
                                            break;
                                        }
                                    i++;
                                }

                            if (flag != 1)
                                {
                                    sources[no_of_flows] = source;
                                    dests[no_of_flows] = dest;
                                    no_of_flows++;
                                }
                        }

                        if ((source!=dest) && (source==0 || dest==0))
                            {
                                for (z=0; z<no_of_flows; z++)
                                    {
                                        if (sources[z]==source && dests[z]==dest)
                                            csma_analyze[z]++;
                                    }
                            }
                    }
	    }

	if (energy_flag[node]==0)
	    {
		initial_energy[node]=energy;
		energy_flag[node]=1;	
	    }	
	else 
	    {
		energy_used[node]=initial_energy[node]-energy;
		percent_energy_used[node] = (energy_used[node]*100)/initial_energy[node];
	    }

	if (node > no_of_nodes)
	    no_of_nodes = node;
	
	if (mac_sub_type=="AODV" && type!="MAC")
	    route_reqs++;
	
	if (type == "MAC")
	    {
		# Check for the packet types: CM1, CM2, CM3, ...etc
		if (mac_sub_type == "CM1")
		    signal = 1;
		else if (mac_sub_type == "CM2")
		    signal = 2;
		else if (mac_sub_type == "CM3")
		    signal = 3;
		else if (mac_sub_type == "CM4")
		    signal = 4;
		else if (mac_sub_type == "CM5")
		    signal = 5;
		else if (mac_sub_type == "CM6")
		    signal = 6;
		else if (mac_sub_type == "CM7")
		    signal = 7;
		else if (mac_sub_type == "CM8")
		    signal = 8;
		else if (mac_sub_type == "CM9")
		    signal = 9;
		else if (mac_sub_type == "BCN")
		    signal = 10;
		else if (mac_sub_type == "ACK")
		    signal = 11;
		else
		    signal = 0;
	
		# Based on packet type (signal, here) accumulate corresponding variables of the zigbee variable arrays.
		if (signal)
		    {
			if (event == "s")
			    {
				sent_ZB[signal] += 1;
				sent_ZBsize[signal] = size + sent_ZBsize[signal];
			    }

			else if (event == "r")
			    {
				received_ZB[signal] += 1;
				received_ZBsize[signal] = size + received_ZBsize[signal];
			    }

			else if (event == "D")
			    {
				dropped_ZB[signal] += 1;
				dropped_ZBsize[signal] = size + dropped_ZBsize[signal];
			    }
		    }
	    }
    }
    
    else if(event == "N")
	{
	    if (node2 > no_of_nodes)
		no_of_nodes = node2;
	
	    if (energy_flag[node2]==0)
		{
    		    # Note that because the energy entries in the trace file alters the previously established format, 
		    # we extract energy entries where we previously used to have the mac_sub_type. 
	
		    initial_energy[node2] = mac_sub_type;
		    energy_flag[node2] = 1;
		}
	    else
		{
		    energy_used[node2] = initial_energy[node2] - mac_sub_type;    
		    percent_energy_used[node2] = (energy_used[node2]*100)/initial_energy[node2];
		}
	}
    
    if ( type == "AGT" ) 
	{
	    nodes[node] = node; 		# Count number of nodes
	
    	    if ( time < node_start_time[node] || node_start_time[node] == 0 )
        	node_start_time[node] = time;

    	    if ( time > node_end_time[node] )
        	node_end_time[node] = time;

    	    if ( event == "s" )
		{
			
        	    if ( time < first_packet_sent || first_packet_sent == 0 )
            		first_packet_sent = time;
			
        	    if ( time > last_packet_sent )
            		last_packet_sent = time;
			
        	    # rate
        	    packets_sent[node]++;
        	    total_AGTpackets_sent++;

        	    # delay
        	    pkt_start_time[packetid] = time;
    		}
    	    else if ( event == "r" ) 
		{
        	    if ( time > last_packet_received )
            		last_packet_received = time;
        	    
		    # throughput
        	    packets_received[node]++;
        	    total_AGTpackets_received++;

        	    # delay
        	    pkt_end_time[packetid] = time;
    		}
    	    else if ( event == "D" ) 
		{
        	    total_AGTpackets_dropped++;
    		}
	}
}

END {
#    for (i in flows)
#       {
#	    #printf ("this i: %d\n", i);
#	    no_of_flows++;
#	}

#    printf("no_of_flows: %d\n", no_of_flows);
    
#    for (q=0; q<no_of_flows; q++)
#    	printf ("%d - %d\n", sources[q], dests[q]);

    # find dropped packets
    if ( total_AGTpackets_sent != total_AGTpackets_received ) 
    	{
    	    for ( packetid in pkt_start_time ) 
    		{
    		    if (0 == pkt_end_time[packetid])
            		total_AGTpackets_dropped++;
    		}
    	}
    
    # throughput calculation
    for (i in nodes) 
    	{
    	    if ( packets_received[i] > 0 ) 
    		{
        	    end = node_end_time[i];
        	    start = node_start_time[i];
        	    runtime = end - start;
        	    if ( runtime > 0 ) 
    			{
            		    throughput[i] = packets_received[i]*70*8/ runtime;
    			    #printf("%d %f %f %d\n", i, start, end, throughput[i]);
        		}
    		}
    	
    	    # rate - not very accurate
    	    if ( packets_sent[i] > 2 ) 
    		{
        	    end = node_end_time[i];
        	    start = node_start_time[i];
        	    runtime = end - start;
        	    if ( runtime > 0 ) 
        	    	rate[i] = (packets_sent[i]*70*8) / runtime;
    		}
    	}
    
    # delay
    for ( pkt in pkt_end_time) 
    {
        end = pkt_end_time[pkt];
        start = pkt_start_time[pkt];
        delta = end - start;
        if ( delta > 0 ) 
            delay[pkt] = delta;
    }

    # offered load
    total_runtime = last_packet_sent - first_packet_sent;
    if ( total_runtime > 0 && total_AGTpackets_sent > 0)
        load = ((total_AGTpackets_sent * 70*8)/total_runtime) ; # n=o overhead

    printf("%d  %f  %f  %f  ", 
           average(throughput),
           min(delay),
           max(delay),
           average(delay)) >> "performance.txt";

    for (i=1; i<=11; i++)
	{
	    total_sent_ZBpkts = sent_ZBpkts + sent_ZB[i];
	    total_received_ZBpkts = total_received_ZBpkts + received_ZB[i];
	    total_dropped_ZBpkts = total_dropped_ZBpkts + dropped_ZB[i];

	    total_sent_size = total_sent_size + sent_ZBsize[i];
	    total_received_size = total_received_size + received_ZBsize[i];    
	    total_dropped_size = total_dropped_size + dropped_ZBsize[i];    
	}
    
    if (total_AGTpackets_sent != 0)
	pkt_delivery_ratio = (total_AGTpackets_received*100)/total_AGTpackets_sent;
    
    printf("%d  %d  %d  %f  ", 
	   total_AGTpackets_sent,
	   total_AGTpackets_received,
	   total_AGTpackets_dropped,
	   pkt_delivery_ratio) >> "performance.txt";
	   
#    ************** Node Energy Consumption ****************
    for (i=0; i<no_of_nodes-1; i++)
	{
	    initial_energy[0] = initial_energy[0]+initial_energy[i+1];
	    energy_used[0] = energy_used[0] + energy_used[i+1];
	    percent_energy_used[0] = percent_energy_used[0] + percent_energy_used[i+1];
	}
    
    initial_energy[0] = initial_energy[0]/no_of_nodes;
    energy_used[0] = energy_used[0]/no_of_nodes;
    percent_energy_used[0] = percent_energy_used[0]/no_of_nodes;
    
    printf("%f  %f  %f  %d  %d  %d  %f  ", 
	   initial_energy[0],
	   energy_used[0],
	   percent_energy_used[0], 
	   max(csma_analyze),
	   min(csma_analyze),
	   max(csma_analyze)-min(csma_analyze),
	   max(csma_analyze)/min(csma_analyze)) >> "performance.txt";

    printf ("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ", APS, LQI, END_, COL, DUP, ERR, RET, STA, BSY, NRTE, LOOP, TTL, TOUT, CBK, IFQ, ARP, OUT, hashes, others) >> "drops.txt";
}





