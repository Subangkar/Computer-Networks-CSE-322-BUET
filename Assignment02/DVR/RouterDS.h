//
// Created by subangkar on 12/7/18.
//

#ifndef DVR_ROUTERDS_H
#define DVR_ROUTERDS_H

#include "Utils.h"
#include <unistd.h>
#include <ostream>
#include "Socket.h"

#define INF INFINITY
#define UP 1
#define DOWN 0

#define SHOW_ROUTING_TABLE "show"
#define RECV_ROUTING_TABLE "ntbl"
#define SEND_MESSAGE "send"
#define FORWARD_MESSAGE string("frwd")
#define UPDATE_COST "cost"
#define DRIVER_CLOCK "clk"
#define CLEAR_SCREEN "clscr"


#define NONE "\t-"


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


#endif //DVR_ROUTERDS_H
