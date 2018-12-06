#include <cstdio>
#include <cstring>
#include <cstdlib>

#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include "Socket.h"

int main(int argc, char *argv[]) {

	int sockfd;
	int bind_flag;
	char buffer[1024];
	sockaddr_in server_address = getInetSocketAddress("192.168.10.100", 4747);
	sockaddr_in client_address = getInetSocketAddress(argv[1], 4747);

	if (argc != 2) {
		printf("%s <ip address>\n", argv[0]);
		exit(1);
	}

	if (!getSocket(sockfd, client_address)) printf("Bind Error");

	while (true) {
//		gets(buffer);
		fgets(buffer, 1024, stdin);
		if (!strcmp(buffer, "shutdown")) break;
		sendto(sockfd, buffer, 1024, 0, (struct sockaddr *) &server_address, sizeof(sockaddr_in));
	}

	close(sockfd);

	return 0;

}
