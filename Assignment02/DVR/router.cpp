
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-noreturn"

#include "RouterDS.h"


int sockfd;
Socket socketLocal;
int bytes_received;
string routerIpAddress;


vector<string> neighbors; // neighbors list
set<string> routers;// all routers in network
vector<RoutingTableEntry> routingTable;
map<string, RoutingTableEntry> routingMap; // contains next hop,cost and dest
vector<Link> links;// all links from this

int sendClock = 0;
bool entryChanged = false;

RoutingTableEntry getRouteEntry(string row, string delim) {
	char *t = new char[row.length() + 1];
	strcpy(t, row.c_str());
	struct RoutingTableEntry rte;
	vector<string> entries;
	char *tok = strtok(t, delim.c_str());

	while (tok != NULL) {
		entries.push_back(tok);
		tok = strtok(NULL, delim.c_str());
	}

	rte.destination = entries[0];
	rte.nextHop = entries[1];
	rte.cost = atoi(entries[2].c_str());
	entries.clear();
	return rte;
}

vector<RoutingTableEntry> extractTableFromPacket(const string &packet) {
	vector<RoutingTableEntry> rt;
	char *str = new char[packet.length() + 1];
	strcpy(str, packet.c_str());
	char *token = strtok(str, ":");
	vector<string> entries;
	while (token != NULL) {
		entries.push_back(token);
		token = strtok(NULL, ":");
	}
	struct RoutingTableEntry rte;
	for (int i = 0; i < entries.size(); i++) {
		rte = getRouteEntry(entries[i], "#");
		rt.push_back(rte);
		//cout<<"dest : "<<rte.destination<<"  next : "<<rte.nextHop<<"  cost : "<<rte.cost<<endl;
	}
	return rt;
}

map<string, RoutingTableEntry> extractTable(const string &packet) {
	char *str = new char[packet.length()];
	char *token = strtok(str, ":");
	vector<string> entries;
	while (token != NULL) {
		entries.push_back(token);
		token = strtok(NULL, ":");
	}
	RoutingTableEntry rte;
	map<string, RoutingTableEntry> table;
	for (auto &entry:entries) {
		rte = getRouteEntry(entry, "#");
		table[rte.destination] = rte;
		//cout<<"dest : "<<rte.destination<<"  next : "<<rte.nextHop<<"  cost : "<<rte.cost<<endl;
	}
	delete[] str;
	return table;
}

string makeTableIntoPacket() {
	string packet = RECV_ROUTING_TABLE + socketLocal.getLocalIP();
	for (const auto &[destination, destEntry]:routingMap) {
		packet += ":" + destination + "#" + destEntry.nextHop + "#" + to_string(destEntry.cost);
	}
	return packet;
}

void printTable() {
	cout << endl << endl << endl;
	cout << "Printing Routing Table" << endl;
	cout << "\t------\t" << routerIpAddress << "\t------\t" << endl;
	cout << "Destination  \tNext Hop \tCost" << endl;
	cout << "-------------\t-------------\t-----" << endl;
	for (const auto &[dest, entry] : routingMap) {
		if (dest == socketLocal.getLocalIP()) continue;
		cout << entry << endl;
	}
	cout << "--------------------------------------" << endl;
}

int getNeighbor(const string &nip) {
	for (int i = 0; i < links.size(); i++) {
		if (nip == links[i].neighbor) {
			return i;
		}
	}
	return 0;
}

bool isNeighbor(const string &nip) {
	for (auto &link : links) {
		if (nip == link.neighbor)
			return true;
	}
	return false;
}

string makeIP(const unsigned char raw[]) {
	int ipSegment[4];
	for (int i = 0; i < 4; i++)
		ipSegment[i] = raw[i];
	string ip = to_string(ipSegment[0]) + "." + to_string(ipSegment[1]) + "." + to_string(ipSegment[2]) + "." +
	            to_string(ipSegment[3]);
	return ip;
}

void updateRoutingTableForNeighbor(string nip, vector<RoutingTableEntry> nrt) {
	int tempCost;
	for (int i = 0; i < routers.size(); i++) {
		for (int j = 0; j < links.size(); j++) {
			if (!nip.compare(links[j].neighbor)) {
				tempCost = links[j].cost + nrt[i].cost;
				if (!nip.compare(routingTable[i].nextHop) ||
				    (tempCost < routingTable[i].cost && routerIpAddress != nrt[i].nextHop)) {
					if (routingTable[i].cost != tempCost) {
						routingTable[i].nextHop = nip;
						routingTable[i].cost = tempCost;
						entryChanged = true;
					}
					break;
				}
			}
		}
	}
	if (entryChanged)
		printTable();
	entryChanged = false;
}

void updateTable(const string &neighbor, int newCost, int oldCost) {
	for (auto &[destination, destEntry]:routingMap) {
		if (neighbor == destEntry.nextHop) { // neighbor is some of nextHop's is to be updated
			if (neighbor == destination) // dest itself nexthop
			{
				destEntry.cost = newCost; // set the new cost as it will go to neighbor
//				cout << "Updated " << routingMap[router.first] << endl;
			} else //nextHop is not dest
			{
				destEntry.cost += (newCost - oldCost); // add/sub cost as it will pass thru neighbor
			}
			entryChanged = true;
		} else if (neighbor == destination && destEntry.cost > newCost) {
			// this -> neighbor direct cost has been reduced than that of with intermediate nextHops
			destEntry.cost = newCost;
			destEntry.nextHop = neighbor;
			entryChanged = true;
		}
	}
	if (entryChanged) {
		cout << "Updated Routing Table" << endl;
		printTable();
	}
	entryChanged = false;
}

void sendTable() {
	string tablePacket = makeTableIntoPacket();
//	cout << tablePacket << " to be sent from " << socketLocal.getLocalIP() << endl;
	for (const auto &neighbor:neighbors) {
		sockaddr_in router_address = getInetSocketAddress(neighbor.data(), 4747);
		ssize_t sent_bytes = socketLocal.writeString(router_address, tablePacket);
//		cout << tablePacket << " sent to " << neighbor.data() << endl;
	}
}


void updateTableForLinkFailure(const string &neighbor) {
	for (auto &[destination, destEntry]:routingMap) {
		// only update if link failed with any hop
		if (neighbor == destEntry.nextHop) {
			if (neighbor == destination || !isNeighbor(destination)) {
				// neighbor itself via that hop or destinations thru this hop but not neighbor of this will be disconnected
				destEntry.nextHop = NONE;
				destEntry.cost = INF;
				entryChanged = true;
			} else if (isNeighbor(destination)) {
				// destinations thru this hop and not neighbor of this will be connected directly instead of hop
				destEntry.nextHop = destination;
				destEntry.cost = links[getNeighbor(destination)].cost;
				entryChanged = true;
			}
		}
	}
	if (entryChanged)printTable();
	entryChanged = false;
}

void forwardMessageToNextHop(const string &dest, const string &msg, const string &recv) {
	string nextHop = routingMap[dest].nextHop;
	if (nextHop == NONE) {
		cout << msg << " packet dropped @ " << socketLocal.getLocalIP() << endl;
		return;
	}
	string frwdMsg = FORWARD_MESSAGE + " " + dest + " " + to_string(msg.length()) + " " + msg;
	cout << "Forwarding>" << frwdMsg << endl;
	sockaddr_in router_address = getInetSocketAddress(nextHop.data(), 4747);
	socketLocal.writeString(router_address, frwdMsg);
	cout << "{" << msg << "}" << " packet forwarded to " << nextHop << " (printed by " << socketLocal.getLocalIP()
	     << ")\n";
}


int getNumberString(const string &bytes, int ndigit = 2) {
	unsigned char nums[2];
	nums[0] = (unsigned char) bytes[0];
	nums[1] = (unsigned char) bytes[1];

	int x[bytes.length()];
	x[0] = nums[0];
	x[1] = nums[1] * 256;
	return x[1] + x[0];
}

string getIPFromBytes(const string &bytes) {
	unsigned char ip[5];
	for (int i = 0; i < 4; i++) {
		ip[i] = static_cast<unsigned char>(bytes[i]);
	}
	return makeIP(ip);
}


void sendMessageCMD(const string &recv) {
	//forward given message to destination router
	string src = getIPFromBytes(recv.substr(4, 4));
	string dst = getIPFromBytes(recv.substr(8, 4));
	int msgLength = getNumberString(recv.substr(12, 2));
	string msg = recv.substr(14, static_cast<unsigned long>(msgLength));
	cout << SEND_MESSAGE << "> " << src << " " << dst << " " << msgLength << " " << msg << endl;
	if (dst == socketLocal.getLocalIP()) {
		cout << msg << " packet reached destination (printed by " << dst << ")\n";
	} else
		forwardMessageToNextHop(dst, msg, recv);

}

void costUpdateCMD(const string &recv) {
	//codes for updating link cost
	string router1 = getIPFromBytes(recv.substr(4, 4));
	string router2 = getIPFromBytes(recv.substr(8, 4));
	int newCost = getNumberString(recv.substr(12, 2));
	cout << UPDATE_COST << "> " << router1 << " " << router2 << " " << newCost << endl;
	string updatedNeighbor = router1 != socketLocal.getLocalIP() ? router1 : router2;
	int oldCost = 0;
//			print_container(cout,links," - ");
	for (auto &link:links) {
		if (link.neighbor == updatedNeighbor) {
			oldCost = link.cost;
			link.cost = newCost;
		}
	}

	//codes for update table according to link cost change
	updateTable(updatedNeighbor, newCost, oldCost);
}

void forwardMessageCMD(const string &recv) {
	//forward given message to destination router
	int f1, f2, f3, f4;
	int msgLength = 0;
	sscanf(recv.data(), "%*s %d.%d.%d.%d %d", &f1, &f2, &f3, &f4, &msgLength);
	string dst = to_string(f1) + "." + to_string(f2) + "." + to_string(f3) + "." +
	             to_string(f4);
	string msg = recv.substr((FORWARD_MESSAGE + " " + dst + " " + to_string(msgLength) + " ").length(),
	                         static_cast<unsigned long>(msgLength));
	cout << FORWARD_MESSAGE << "> " << dst << " " << msgLength << " " << msg << endl;
	if (dst == socketLocal.getLocalIP()) {
		cout << msg << " packet reached destination (printed by " << dst << ")\n";
	} else
		forwardMessageToNextHop(dst, msg, recv);
}

void clockCMD(const string &recv) {
	sendClock++;
	sendTable();

	for (auto &link : links) {
		if (sendClock - link.recvClock > 3 && link.status == UP) {
			cout << "----- link down with : " << link.neighbor << " -----" << endl;
			link.status = DOWN;
			updateTableForLinkFailure(link.neighbor);
		}
	}
}

void receiveTableCMD(const string &recv) {
	string srcIP = recv.substr(4, 12);
//	cout << RECV_ROUTING_TABLE << "> from: " << srcIP << endl;
	int index = getNeighbor(srcIP);
	if (links[index].status == DOWN) {
		cout << "----- link UP with : " << links[index].neighbor << " -----" << endl;
	}
	links[index].status = UP;
	links[index].recvClock = sendClock;
	//cout<<"receiver : "<<routerIpAddress<<" sender : "<<nip<<" recv clk : "<<links[index].recvClock<<endl;
//			int length = recv.length() - 15;
//			char pckt[length];
//			for (int i = 0; i < length; i++) {
//				pckt[i] = buffer[16 + i];
//			}
//			string packet(pckt);
//			vector<RoutingTableEntry> ntbl = extractTableFromPacket(pckt);
//			updateRoutingTableForNeighbor(srcIP, ntbl);
}

void receiveCommands() {
	sockaddr_in remote_address{};
	while (true) {
		string recv = socketLocal.readString(remote_address);
		if (recv.empty()) continue;
//		cout << recv << "::" << endl;
		if (startsWith(recv, SHOW_ROUTING_TABLE)) {
			printTable();
			continue;
		}
		if (startsWith(recv, SEND_MESSAGE)) {
			sendMessageCMD(recv);
			continue;
		}
		if (startsWith(recv, FORWARD_MESSAGE)) {
			forwardMessageCMD(recv);
			continue;
		}
		if (startsWith(recv, UPDATE_COST)) {
			costUpdateCMD(recv);
			continue;
		}
		if (startsWith(recv, DRIVER_CLOCK)) {
			clockCMD(recv);
			continue;
		}
		if (startsWith(recv, RECV_ROUTING_TABLE)) {
			receiveTableCMD(recv);
			continue;
		}
	}
}


void receive() {
	sockaddr_in remote_address;
	int n = 0;
	while (true) {
		const char *buffer = socketLocal.readBytes(remote_address);
//		string recv = socketLocal.readString(remote_address);
		string recv(buffer, static_cast<unsigned long>(socketLocal.dataLength()));
		++n;
		if (bytes_received != -1) {
//			cout << "Received " << n << " : " << recv << endl;
//			string head = recv.substr(0, 4);
			if (startsWith(recv, CLEAR_SCREEN)) {
				system("clear");
			} else if (startsWith(recv, DRIVER_CLOCK)) {
				sendClock++;
				sendTable();

				for (auto &link : links) {
					if (sendClock - link.recvClock > 3 && link.status == 1) {
						cout << "----- link down with : " << link.neighbor << " -----" << endl;
						link.status = -1;
						updateTableForLinkFailure(link.neighbor);
					}
				}
			} else if (startsWith(recv, RECV_ROUTING_TABLE)) {
				string nip = recv.substr(4, 12);
				int index = getNeighbor(nip);
				links[index].status = 1;
				links[index].recvClock = sendClock;
				//cout<<"receiver : "<<routerIpAddress<<" sender : "<<nip<<" recv clk : "<<links[index].recvClock<<endl;
				int length = recv.length() - 15;
				char pckt[length];
				for (int i = 0; i < length; i++) {
					pckt[i] = buffer[16 + i];
				}
				string packet(pckt);
				vector<RoutingTableEntry> ntbl = extractTableFromPacket(pckt);
				updateRoutingTableForNeighbor(nip, ntbl);
			}
		}
	}
}


void initRouter(const string &routerIp, const string &topologyFile) {
	ifstream topo(topologyFile.c_str());
	string srcRouter, destRouter;
	int cost;


	while (!topo.eof()) {
		topo >> srcRouter >> destRouter >> cost;
//		cout << srcRouter << "-" << destRouter << "-" << cost << endl;

		routers.insert(srcRouter);
		routers.insert(destRouter);
		if (srcRouter == socketLocal.getLocalIP()) {
			if (!isNeighbor(destRouter)) {
				neighbors.push_back(destRouter);
				links.emplace_back(destRouter, cost, 0, UP);
			}
		} else if (destRouter == socketLocal.getLocalIP()) {
			if (!isNeighbor(srcRouter)) {
				neighbors.push_back(srcRouter);
				links.emplace_back(srcRouter, cost, 0, UP);
			}
		}
	}

	topo.close();

//	print_container(cout, links, " - ");

	for (const auto &router:routers) {
		if (IS_IN_LIST(router, neighbors)) {//if this router is a neighbor
			for (auto &link : links) { // add its link info to table
				if (link.neighbor == router) {
					routingTable.emplace_back(router, router, link.cost);
					routingMap[router] = RoutingTableEntry(router, router, link.cost);
				}
			}
		} else if (socketLocal.getLocalIP() == router) { // if itself
			routingTable.emplace_back(router, router, 0);
			routingMap[router] = RoutingTableEntry(router, router, 0);
		} else { // unreachable
			routingTable.emplace_back(router, NONE, INF);
			routingMap[router] = RoutingTableEntry(router, NONE, INF);
		}
	}

	printTable();
}


int main(int argc, char *argv[]) {

	if (argc != 3) {
		cout << "router : " << argv[1] << "<ip address>\n";
		exit(1);
	}


	routerIpAddress = argv[1];
	socketLocal = Socket(argv[1], 4747);
	initRouter(argv[1], argv[2]);


	if (socketLocal.isBound()) cout << "Connection successful!!" << endl;
	else cout << "Connection failed!!!" << endl, exit(EXIT_FAILURE);

	cout << "--------------------------------------" << endl;

//	receive();
	receiveCommands();

	return 0;
}

#pragma clang diagnostic pop