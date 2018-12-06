#include <cstdio>

#include "Socket.h"
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>

int main() {

	int sockfd;
	int bind_flag;
	int bytes_received;
	socklen_t addrlen;
	char buffer[1024];
	sockaddr_in server_address = getInetSocketAddress("192.168.10.100", 4747);
	sockaddr_in client_address;

	if (!getSocket(sockfd, server_address)) printf("Bind Error");

	while (true) {
		bytes_received = recvfrom(sockfd, buffer, 1024, 0, (struct sockaddr *) &client_address, &addrlen);
		printf("[%s:%d]: %s\n", inet_ntoa(client_address.sin_addr), ntohs(client_address.sin_port), buffer);
	}

	return 0;

}
