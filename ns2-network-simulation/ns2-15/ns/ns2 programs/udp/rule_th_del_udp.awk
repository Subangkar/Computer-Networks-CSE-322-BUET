BEGIN {
	nSentPackets = 0.0 ;		
	nReceivedPackets = 0.0 ;
	rTotalDelay = 0.0 ;
	
	idHighestPacket = 0;
	idLowestPacket = 100000;
	rStartTime = 10000.0;
	rEndTime = 0.0;
	nReceivedBytes = 0;

	nDropPackets = 0.0;

}

{
	strEvent = $1 ;			rTime = $2 ;
	strAgt = $4 ;			idPacket = $6 ;
	strType = $7 ;			nBytes = $8;

	if ( strAgt == "AGT"   &&   strType == "cbr" ) {
		if (idPacket > idHighestPacket) idHighestPacket = idPacket;
		if (idPacket < idLowestPacket) idLowestPacket = idPacket;

		if(rTime>rEndTime) rEndTime=rTime;
		if(rTime<rStartTime) rStartTime=rTime;

		if ( strEvent == "s" ) {
			nSentPackets += 1 ;	rSentTime[ idPacket ] = rTime ;
#			printf("%15.5f\n", nSentPackets);
		}
#		if ( strEvent == "r" ) {
		if ( strEvent == "r" && idPacket >= idLowestPacket) {
			nReceivedPackets += 1 ;		nReceivedBytes += nBytes;
			rReceivedTime[ idPacket ] = rTime ;
			rDelay[idPacket] = rReceivedTime[ idPacket] - rSentTime[ idPacket ];
#			rTotalDelay += rReceivedTime[ idPacket] - rSentTime[ idPacket ];
			rTotalDelay += rDelay[idPacket]; 

#			printf("%15.5f   %15.5f\n", rDelay[idPacket], rReceivedTime[ idPacket] - rSentTime[ idPacket ]);
		}
	}

	if(strEvent == "D"   &&   strType == "cbr" )
	{
		nDropPackets += 1;
	}
}

END {
	rTime = rEndTime - rStartTime ;
	rThroughput = nReceivedBytes*8 / rTime;
	rPacketDeliveryRatio = nReceivedPackets / nSentPackets * 100 ;
	rPacketDropRatio = nDropPackets / nSentPackets * 100;
	if ( nReceivedPackets != 0 )
		rAverageDelay = rTotalDelay / nReceivedPackets ;

#	printf( "AverageDelay: %15.5f PacketDeliveryRatio: %10.2f\n", rAverageDelay, rPacketDeliveryRatio ) ;
	printf( "Throughput: %15.2f AverageDelay: %15.5f \nSent Packets: %15.2f Received Packets: %15.2f Dropped Packets: %15.2f \nPacketDeliveryRatio: %10.2f PacketDropRatio: %10.2f\n", rThroughput, rAverageDelay, nSentPackets, nReceivedPackets, nDropPackets, rPacketDeliveryRatio, rPacketDropRatio) ;
}


