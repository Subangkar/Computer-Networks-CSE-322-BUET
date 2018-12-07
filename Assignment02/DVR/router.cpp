#include "Utils.h"
#include <unistd.h>
#include <ostream>
#include "Socket.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-noreturn"
#define INF INFINITY
#define UP 1
#define DOWN 0

#define SHOW_ROUTING_TABLE "show"
#define SEND_ROUTING_TABLE "ntbl"
#define SEND_MESSAGE "send"
#define UPDATE_COST "cost"
#define DRIVER_CLOCK "clk"
#define CLEAR_SCREEN "clscr"


#define NONE "\t-"


int sockfd;
Socket socketLocal;
int bytes_received;
string routerIpAddress;


struct RoutingTableEntry {
	string destination;
	string nextHop;
	int cost;

	RoutingTableEntry() = default;

	RoutingTableEntry(const string &destination, const string &nextHop, int cost) : destination(destination),
	                                                                                nextHop(nextHop), cost(cost) {}

	friend ostream &operator<<(ostream &os, const RoutingTableEntry &entry) {
		os << entry.destination << "\t" << setw(12) << entry.nextHop << "\t" << entry.cost;
		return os;
	}

	bool operator==(const RoutingTableEntry &rhs) const {
		return destination == rhs.destination &&
		       nextHop == rhs.nextHop &&
		       cost == rhs.cost;
	}

	bool operator!=(const RoutingTableEntry &rhs) const {
		return !(rhs == *this);
	}
};

struct Link {
	string neighbor;
	int cost;
	int recvClock;
	int status;

	Link() {
		cost = -1;
		recvClock = -1;
		status = DOWN;
	}

	Link(const string &neighbor, int cost, int recvClock, int status) : neighbor(neighbor), cost(cost),
	                                                                    recvClock(recvClock), status(status) {}

	friend ostream &operator<<(ostream &os, const Link &link1) {
		os << "neighbor: " << link1.neighbor << " cost: " << link1.cost << " recvClock: " << link1.recvClock
		   << " status: " << link1.status;
		return os;
	}

	bool operator==(const Link &rhs) const {
		return neighbor == rhs.neighbor &&
		       cost == rhs.cost &&
		       recvClock == rhs.recvClock &&
		       status == rhs.status;
	}

	bool operator!=(const Link &rhs) const {
		return !(rhs == *this);
	}
};

vector<string> neighbors; // neighbors list
set<string> routers;// all routers in network
vector<RoutingTableEntry> routingTable;
map<string, RoutingTableEntry> routingMap; // contains next hop,cost and dest
vector<Link> links;// all links from this

int sendClock = 0;
bool entryChanged = false;

struct RoutingTableEntry getRouteEntry(string row, string delim) {
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

vector<RoutingTableEntry> extractTableFromPacket(string packet) {
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

string makeTableIntoPacket(vector<RoutingTableEntry> rt) {
	string packet = "ntbl" + routerIpAddress;
	for (int i = 0; i < rt.size(); i++) {
		packet = packet + ":" + rt[i].destination + "#" + rt[i].nextHop + "#" + to_string(rt[i].cost);
	}
	return packet;
}

void printTable() {
	cout << endl << endl << endl;
	cout << "Printing Routing Table" << endl;
	cout << "\t------\t" << routerIpAddress << "\t------\t" << endl;
	cout << "Destination  \tNext Hop \tCost" << endl;
	cout << "-------------\t-------------\t-----" << endl;
//	for (auto &routerEntry : routingTable) {
//		if (routerEntry.destination == socketLocal.getLocalIP()) continue;
////		cout << routerEntry.destination << "\t" << routerEntry.nextHop << "\t" << routerEntry.cost << endl;
//		cout << routerEntry << endl;
//	}
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

string makeIP(const unsigned char raw[]) {
	int ipSegment[4];
	for (int i = 0; i < 4; i++)
		ipSegment[i] = raw[i];
	string ip = to_string(ipSegment[0]) + "." + to_string(ipSegment[1]) + "." + to_string(ipSegment[2]) + "." +
	            to_string(ipSegment[3]);
	return ip;
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

void updateTableForCostChange(const string &neighbor, int newCost, int oldCost) {
	for (int i = 0; i < routers.size(); i++) {
		if (neighbor == (routingTable[i].nextHop)) {
			if (neighbor == (routingTable[i].destination)) {
				routingTable[i].cost = newCost;
			} else {
				routingTable[i].cost = routingTable[i].cost - oldCost + newCost;
			}
			entryChanged = true;
		} else if (neighbor == (routingTable[i].destination) && routingTable[i].cost > newCost) {
			routingTable[i].cost = newCost;
			routingTable[i].nextHop = neighbor;
			entryChanged = true;
		}
	}
	if (entryChanged)
		printTable();
	entryChanged = false;
}

void sendTable() {
	string tablePacket = makeTableIntoPacket(routingTable);
	for (int i = 0; i < neighbors.size(); i++) {
		struct sockaddr_in router_address;

		router_address.sin_family = AF_INET;
		router_address.sin_port = htons(4747);
		inet_pton(AF_INET, neighbors[i].c_str(), &router_address.sin_addr);

		int sent_bytes = sendto(sockfd, tablePacket.c_str(), 1024, 0, (struct sockaddr *) &router_address,
		                        sizeof(sockaddr_in));
		if (sent_bytes != -1) {
			//cout<<"routing table : "<<routerIpAddress<<" sent to : "<<neighbors[i]<<endl;
		}
	}
}


// missing next hop to be handled
void forwardMessageToNextHop(const string &dest, int length, const string &msg, const string &recv) {
//	string forwardPckt = "frwd#" + dest + "#" + to_string(length) + "#" + msg;
	string nextHop = routingMap[dest].nextHop;
	if (nextHop == NONE) {
		cout << msg << " packet dropped @ " << socketLocal.getLocalIP() << endl;
		return;
	}

	sockaddr_in router_address = getInetSocketAddress(nextHop.data(), 4747);
	socketLocal.writeString(router_address, recv);
	cout << msg << " packet forwarded to " << nextHop << " (printed by " << socketLocal.getLocalIP()
	     << ")\n";
}


void updateTableForLinkFailure(string nbr) {
	for (int i = 0; i < routingTable.size(); i++) {
		if (!nbr.compare(routingTable[i].nextHop)) {
			if (!nbr.compare(routingTable[i].destination) || !isNeighbor(routingTable[i].destination)) {
				routingTable[i].nextHop = "\t-";
				routingTable[i].cost = INF;
				entryChanged = true;
			} else if (isNeighbor(routingTable[i].destination)) {
				routingTable[i].nextHop = routingTable[i].destination;
				routingTable[i].cost = links[getNeighbor(routingTable[i].destination)].cost;
				entryChanged = true;
			}
		}
	}
	if (entryChanged)
		printTable();
	entryChanged = false;
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

void receiveCommands() {
	sockaddr_in remote_address{};
	int n = 0;
	while (true) {
		string recv = socketLocal.readString(remote_address);
		if (recv.empty()) continue;
		cout << recv << "::" << endl;
		if (startsWith(recv, SHOW_ROUTING_TABLE)) {
			printTable();
			continue;
		}
		if (startsWith(recv, SEND_MESSAGE)) {
			//forward given message to destination router
			string src = getIPFromBytes(recv.substr(4, 4));
			string dst = getIPFromBytes(recv.substr(8, 4));
			int msgLength = getNumberString(recv.substr(12, 2));
			string msg = recv.substr(14, static_cast<unsigned long>(msgLength));
			cout << SEND_MESSAGE << "> " << src << " " << dst << " " << msgLength << " " << msg << endl;
			if (dst == socketLocal.getLocalIP()) {
				cout << msg << " packet reached destination (printed by " << dst << ")\n";
			} else
				forwardMessageToNextHop(dst, msgLength, msg, recv);

			continue;
		}
		if (startsWith(recv, UPDATE_COST)) {
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
			} else if (startsWith(recv, SEND_ROUTING_TABLE)) {
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
			} else if (startsWith(recv, UPDATE_COST)) {
				//codes for updating link cost
				unsigned char *ip1 = new unsigned char[5];
				unsigned char *ip2 = new unsigned char[5];
				string temp1 = recv.substr(4, 4);
				string temp2 = recv.substr(8, 4);
				for (int i = 0; i < 4; i++) {
					ip1[i] = temp1[i];
					ip2[i] = temp2[i];
				}
				string sip1 = makeIP(ip1);
				string sip2 = makeIP(ip2);
				unsigned char *c1 = new unsigned char[3];
				string tempCost = recv.substr(12, 2);
				//cout<<tempCost<<endl;
				int changedCost = 0;
				c1[0] = tempCost[0];
				c1[1] = tempCost[1];
				int x0, x1;
				x0 = c1[0];
				x1 = c1[1] * 256;
				changedCost = x1 + x0;
				//cout<<changedCost<<endl;
				string nbr;
				int oldCost;
				for (int i = 0; i < links.size(); i++) {
					if (!sip1.compare(links[i].neighbor)) {
						oldCost = links[i].cost;
						links[i].cost = changedCost;
						nbr = sip1;
					} else if (!sip2.compare(links[i].neighbor)) {
						oldCost = links[i].cost;
						links[i].cost = changedCost;
						nbr = sip2;
					}
				}
				//codes for update table according to link cost change
				updateTableForCostChange(nbr, changedCost, oldCost);
			}
		}
	}
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
	else cout << "Connection failed!!!" << endl;

	cout << "--------------------------------------" << endl;

//	receive();
	receiveCommands();

	return 0;
}

#pragma clang diagnostic pop