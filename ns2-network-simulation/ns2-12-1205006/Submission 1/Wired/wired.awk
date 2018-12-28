BEGIN {
	max_node = 2000;
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	max_pckt = 10000;

	header = 20;	

	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;
	rEnergyEfficeincy = 0;

	nDropPackets = 0.0;

	
}

{

	strEvent = $1 ;
	rTime = $2 ;
	strType = $5 ;
	idPacket = $11;
	
	nBytes = $6;

	
	if ( strType == "cbr") {
		if (idPacket > idHighestPacket) idHighestPacket = idPacket;
		if (idPacket < idLowestPacket) idLowestPacket = idPacket;

#		if(rTime>rEndTime) rEndTime=rTime;
		if(rTime<rStartTime) {
			rStartTime=rTime;
		}

		if ( strEvent == "+" ) {
			nSentPackets += 1 ;
			rSentTime[ idPacket ] = rTime ;
		}
		if ( strEvent == "r" ) {
			nReceivedPackets += 1 ;	
			nReceivedBytes += (nBytes-header);
			rReceivedTime[ idPacket ] = rTime ;
			rDelay[idPacket] = rReceivedTime[ idPacket] - rSentTime[ idPacket ];
			rTotalDelay += rDelay[idPacket]; 

		}
		if( strEvent == "d" ) {
			nDropPackets += 1;
		}
	}

	

	
	
	if(rTime<rStartTime) rStartTime=rTime;
	if(rTime>rEndTime) rEndTime=rTime;

}

END {
	rTime = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / rTime;

	if (nSentPackets != 0) {
		rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
		rPacketDropRatio = nDropPackets / nSentPackets * 100;
	}
	
	if ( nReceivedPackets != 0 ) {
		rAverageDelay = rTotalDelay / nReceivedPackets ;
	}

	printf( "%f\n",rThroughput);
	printf( "%f\n",rAverageDelay);
	printf( "%f\n",rPacketDeliveryRatio);
	printf( "%f\n",rPacketDropRatio);
}


