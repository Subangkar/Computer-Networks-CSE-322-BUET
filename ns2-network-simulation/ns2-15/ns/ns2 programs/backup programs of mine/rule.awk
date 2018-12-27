BEGIN {
# Initialization. fsDrops: packets drop. numFs: packets sent
        fsDrops = 0;
        numFs = 0;
	tcp = 0;
	ack = 0;
}
{
   action = $1;     time = $2;
   from = $3;       to = $4;
   type = $5;       pktsize = $6;
   transport_type = $7;
   flow_id = $8;    src = $9;
   dst = $10;       seq_no = $11;
   packet_id = $12; 
        if (from==1 && to==2 && action == "+") 
                numFs++;
        if (flow_id==2 && action == "d") 
                fsDrops++;
	if (transport_type == "tcp")
		tcp++;
	if (transport_type == "ack")
		ack++;
}
END {
        printf("number of packets sent:%d lost:%d\n", numFs, fsDrops);
        printf("number of tcp packets sent:%d ack received:%d\n", tcp, ack);
}

