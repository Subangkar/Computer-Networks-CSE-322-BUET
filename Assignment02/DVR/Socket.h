//
// Created by subangkar on 12/6/18.
//

#ifndef DVR_SOCKET_H
#define DVR_SOCKET_H

#include <arpa/inet.h>
#include <sys/socket.h>
//#include <unistd.h>

#include <string>


sockaddr_in getInetSocketAddress(const char *ipAddress, uint16_t port, sa_family_t sin_family = AF_INET) {
	sockaddr_in sockAddr{};
	sockAddr.sin_family = sin_family;
	sockAddr.sin_port = htons(port);
	sockAddr.sin_addr.s_addr = inet_addr(ipAddress);
	return sockAddr;
}

// returns bind flag
bool getSocket(int& sockfd,const sockaddr_in &inetSocketAddr, int domain = AF_INET, int type = SOCK_DGRAM, int protocol = 0) {
	sockfd = socket(domain, type, protocol);
	return !bind(sockfd, (struct sockaddr *) &inetSocketAddr, sizeof(sockaddr_in));
}

#endif //DVR_SOCKET_H
