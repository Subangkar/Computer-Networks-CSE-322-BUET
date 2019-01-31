//
// Created by Subangkar on 31-Jan-19.
//

#ifndef ERRORDETECTION_CRCUTILS_H
#define ERRORDETECTION_CRCUTILS_H

#include <bitset>
using namespace std;

string appendChecksumCRC(const string &s);

string removeChecksumCRC(const string &s);

/// returns true is okay
bool checkChecksumError(const string &s);


#endif //ERRORDETECTION_CRCUTILS_H
