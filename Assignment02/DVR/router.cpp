
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-noreturn"

#include "RouterDS.h"

#define MAX_INPUT_SIZE 10


Socket socketLocal;


//vector<routerip_t> neighbors; // neighbors list
set<routerip_t> routers;// all routers in network
routingtable_t routingMap; // contains next hop,cost and dest
vector<Link> links;// all links from this

int sendClock = 0;
bool tableUpdated = false;

routingtable_t extractTable(const packet_t &packet) {
	routingtable_t table;
	string dest, nextHop;
	int cost;

	std::istringstream f(packet);
	std::string line;
	while (std::getline(f, line)) {
		if (line.empty()) continue;
		stringstream sstrm(line);
		sstrm >> dest >> nextHop >> cost;
		table[dest] = RoutingTableEntry(dest, nextHop, cost);
	}
	return table;
}

packet_t makeTableIntoPacket() {
	packet_t packet = RECV_ROUTING_TABLE + " " + socketLocal.getLocalIP();
	for (const auto &[destination, destEntry]:routingMap) {
		packet += "\n" + destination + " " + destEntry.nextHop + " " + to_string(destEntry.cost);
	}
	return packet;
}

void printRoutingMap(const routingtable_t &routingMap) {
	for (const auto &[dest, entry] : routingMap) {
		if (dest == socketLocal.getLocalIP()) continue;
		cout << entry << endl;
	}
}

void printRoutingTable() {
	cout << endl << endl << endl;
	cout << "Printing Routing Table" << endl;
	cout << "\t------\t" << socketLocal.getLocalIP() << "\t------\t" << endl;
	cout << "Destination  \tNext Hop \tCost" << endl;
	cout << "-------------\t-------------\t-----" << endl;
	printRoutingMap(routingMap);
	cout << "--------------------------------------" << endl;
}

void printUpdate() {
	return;
	if (tableUpdated) {
		cout << "Updated Routing Table" << endl;
		printRoutingTable();
	}
	tableUpdated = false;
}

Link &getLink(const routerip_t &routerip) {
	for (auto &link:links) {
		if (routerip == link.neighbor)
			return link;
	}
	return *links.end();
}

bool isNeighbor(const routerip_t &routerip) {
//	return IS_IN_LIST(routerip, neighbors);
	return IS_IN_LIST(Link(routerip, 0, 0, DOWN), links);
}

void sendTable() {
	auto tablePacket = makeTableIntoPacket();
//	for (const auto &neighbor:neighbors) {
//		sockaddr_in router_address = getInetSocketAddress(neighbor.data(), 4747);
//		socketLocal.writeString(router_address, tablePacket);
//	}
	for (const auto &link:links) {
		sockaddr_in router_address = getInetSocketAddress(link.neighbor.data(), 4747);
		socketLocal.writeString(router_address, tablePacket);
	}
}

void updateTableWithNewCost(const routerip_t &neighbor, int newCost, int oldCost) {
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
			tableUpdated = true;
		} else if (neighbor == destination && destEntry.cost > newCost) {
			// this -> neighbor direct cost has been reduced than that of with intermediate nextHops
			destEntry.cost = newCost;
			destEntry.nextHop = neighbor;
			tableUpdated = true;
		}
	}
	printUpdate();
}

void updateRoutingTableForNeighbor(const routerip_t &neighbor, routingtable_t &neighborRouter) {
	for (auto &[destination, destEntry]:routingMap) {
		for (const auto &link:links) {
			if (neighbor == link.neighbor) {
				cost_t cost_via_neighbor =
						neighborRouter[destination].cost == INF ? INF : (link.cost + neighborRouter[destination].cost);
				if (neighbor == destEntry.nextHop && destEntry.cost != cost_via_neighbor) {
					// cost changed @ nextHop & neighbor is the way to reach into destination
					destEntry.cost = cost_via_neighbor;
					if (cost_via_neighbor == INF) destEntry.nextHop = NONE;
					tableUpdated = true;
					break;
				} else if (cost_via_neighbor < destEntry.cost &&
				           socketLocal.getLocalIP() != neighborRouter[destination].nextHop) {
					// take less cost not creating loop
					destEntry.nextHop = neighbor;
					destEntry.cost = cost_via_neighbor;
					tableUpdated = true;
					break;
				}
			}
		}
	}
	printUpdate();
}

void updateTableForLinkFailure(const routerip_t &neighbor) {
	for (auto &[destination, destEntry]:routingMap) {
		// only update if link failed with any hop
		if (neighbor == destEntry.nextHop) {
			if (neighbor == destination || !isNeighbor(destination)) {
				// neighbor itself via that hop or destinations thru this hop but not neighbor of this will be disconnected
				destEntry.nextHop = NONE;
				destEntry.cost = INF;
				tableUpdated = true;
			} else if (isNeighbor(destination)) {
				// destinations thru this hop and not neighbor of this will be connected directly instead of hop
				destEntry.nextHop = destination;
				destEntry.cost = getLink(destination).cost;
				tableUpdated = true;
			}
		}
	}
	printUpdate();
}


void forwardMessageToNextHop(const routerip_t &dest, const string &msg, const string &recv) {
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

routerip_t convertToIP(const string &bytes) {
	unsigned char raw[5];
	for (int i = 0; i < 4; i++) {
		raw[i] = static_cast<unsigned char>(bytes[i]);
	}
	int ipSegment[4];
	for (int i = 0; i < 4; i++)
		ipSegment[i] = raw[i];
	routerip_t ip = to_string(ipSegment[0]) + "." + to_string(ipSegment[1]) + "." + to_string(ipSegment[2]) + "." +
	                to_string(ipSegment[3]);
	return ip;
}


void sendMessageCMD(const packet_t &recv) {
	//forward given message to destination router
	string src = convertToIP(recv.substr(4, 4));
	string dst = convertToIP(recv.substr(8, 4));
	int msgLength = getNumberString(recv.substr(12, 2));
	string msg = recv.substr(14, static_cast<unsigned long>(msgLength));
	cout << SEND_MESSAGE << "> " << src << " " << dst << " " << msgLength << " " << msg << endl;
	if (dst == socketLocal.getLocalIP()) {
		cout << msg << " packet reached destination (printed by " << dst << ")\n";
	} else
		forwardMessageToNextHop(dst, msg, recv);

}

void costUpdateCMD(const packet_t &recv) {
	//codes for updating link cost
	string router1 = convertToIP(recv.substr(4, 4));
	string router2 = convertToIP(recv.substr(8, 4));
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
	updateTableWithNewCost(updatedNeighbor, newCost, oldCost);
}

void forwardMessageCMD(const packet_t &recv) {
	//forward given message to destination router
	int f1, f2, f3, f4;
	int msgLength = 0;
	sscanf(recv.data(), "%*s %d.%d.%d.%d %d", &f1, &f2, &f3, &f4, &msgLength);
	string dst = to_string(f1) + "." + to_string(f2) + "." + to_string(f3) + "." + to_string(f4);
	string msg = recv.substr((FORWARD_MESSAGE + " " + dst + " " + to_string(msgLength) + " ").length(),
	                         static_cast<unsigned long>(msgLength));
	cout << FORWARD_MESSAGE << "> " << dst << " " << msgLength << " " << msg << endl;
	if (dst == socketLocal.getLocalIP()) {
		cout << msg << " packet reached destination (printed by " << dst << ")\n";
	} else
		forwardMessageToNextHop(dst, msg, recv);
}

void clockCMD(const packet_t &recv) {
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

void receiveTableCMD(const packet_t &recv) {
	stringstream sstrm(recv);
	sstrm.ignore(std::numeric_limits<streamsize>::max(), ' ');
	string neighbor;
	sstrm >> neighbor;
	Link &link = getLink(neighbor);
	if (link == *links.end()) {
		cout << "!!! Packet received from Unknown Router: DISCARDED" << endl;
		return;
	}
	if (link.status == DOWN) {
		cout << "----- link UP with : " << link.neighbor << " -----" << endl;
	}
	link.status = UP;
	link.recvClock = sendClock;
//	cout << "--------------------------------------" << endl;
//	cout << RECV_ROUTING_TABLE << "> from: " << neighbor << endl;
//	print_container(cout,extractTableFromPacket(recv.substr(16)),"\n");
//	printRoutingMap(extractTable(recv.substr(recv.find('\n') + 1)));
//	cout << "--------------------------------------" << endl;
	routingtable_t ntbl = extractTable(recv.substr(recv.find('\n') + 1));
	updateRoutingTableForNeighbor(neighbor, ntbl);
}

void receiveCommands() {
	sockaddr_in remote_address{};
	while (true) {
		string recv = socketLocal.readString(remote_address);
		if (recv.empty()) continue;
//		cout << recv << "::" << endl;
		if (startsWith(recv, SHOW_ROUTING_TABLE)) {
			printRoutingTable();
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

void initRouter(const routerip_t &routerIp, const string &topologyFile) {
	ifstream topo(topologyFile.c_str());
	string srcRouter, destRouter;
	int cost;
	size_t nLines = 0;
	while (!topo.eof()) {
		topo >> srcRouter >> destRouter >> cost;

		routers.insert(srcRouter);
		routers.insert(destRouter);
		if (srcRouter == socketLocal.getLocalIP()) {
			if (!isNeighbor(destRouter)) {
//				neighbors.push_back(destRouter);
				links.emplace_back(destRouter, cost, 0, UP);
			}
		} else if (destRouter == socketLocal.getLocalIP()) {
			if (!isNeighbor(srcRouter)) {
//				neighbors.push_back(srcRouter);
				links.emplace_back(srcRouter, cost, 0, UP);
			}
		}
	}

	topo.close();

//	print_container(cout, links, " - ");

	for (const auto &router:routers) { //IS_IN_LIST(router, neighbors)
		if (isNeighbor(router)) {//if this router is a neighbor
			for (auto &link : links) { // add its link info to table
				if (link.neighbor == router) {
					routingMap[router] = RoutingTableEntry(router, router, link.cost);
				}
			}
		} else if (socketLocal.getLocalIP() == router) { // if itself
			routingMap[router] = RoutingTableEntry(router, router, 0);
		} else { // unreachable
			routingMap[router] = RoutingTableEntry(router, NONE, INF);
		}
	}

	printRoutingTable();
}


int main(int argc, char *argv[]) {

	if (argc != 3) {
		cout << "router : " << argv[1] << "<ip address>\n";
		exit(1);
	}


	socketLocal = Socket(argv[1], 4747);
	initRouter(argv[1], argv[2]);


	if (socketLocal.isBound()) cout << "Connection successful!!" << endl;
	else cout << "Connection failed!!!" << endl, exit(EXIT_FAILURE);

	cout << "--------------------------------------" << endl;

	receiveCommands();

	return 0;
}

#pragma clang diagnostic pop