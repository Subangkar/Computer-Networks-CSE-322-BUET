//
// Created by Subangkar on 31-Jan-19.
//

#ifndef ERRORDETECTION_CRCUTILS_H
#define ERRORDETECTION_CRCUTILS_H

#include <bitset>

using namespace std;


string xorBits(string x, string y, bool leftAlign = false);

/// returns remainder
string mod2div(const string &divident, string divisor);

string computeCRC(const string &s, const string &polynomial);

/// encodes
string appendChecksumCRC(const string &s, const string &polynomial);

/// decodes
string removeChecksumCRC(const string &s, const string &polynomial);

/// returns true if okay
bool checkChecksumOkay(const string &s, const string &polynomial);

string computeCRC(const string &s, const string &polynomial) {
	auto appended_data = s + string(polynomial.length() - 1, '0');
	auto remainder = mod2div(appended_data, polynomial);
	return remainder;
}

string xorBits(string x, string y, bool leftAlign) {
	if (leftAlign) { /// 101,1010 -> 0101,1010
		if (x.length() < y.length()) x = x + string(y.length() - x.length(), '0');
		else y = y + string(x.length() - y.length(), '0');
	} else {/// 101,1010 -> 1010,1010
		if (x.length() < y.length()) x = string(y.length() - x.length(), '0') + x;
		else y = string(x.length() - y.length(), '0') + y;
	}

	string result;
	for (int i = 0; i < y.length(); ++i) {
		result += (char) ((x[i] != y[i]) + '0');
	}
	return result;
}

string mod2div(const string &divident, string divisor) {
	auto rem = divident;
	auto crc_len = divisor.length() - 1;
	int i = 0;
	while (i < (divident.length() - crc_len)) {
		if (rem[i] == '1')rem = xorBits(rem, divisor, true);
		divisor = '0' + divisor;
		++i;
	}
	return string(rem, rem.length() - crc_len, crc_len);
}

string appendChecksumCRC(const string &s, const string &polynomial) {
	return s + computeCRC(s, polynomial);
}

string removeChecksumCRC(const string &s, const string &polynomial) {
	return std::string(s, 0, s.length() - (polynomial.length() - 1));
}

// problem
bool checkChecksumOkay(const string &s, const string &polynomial) {
	auto current_crc_val = mod2div(s, polynomial);
	return atoi(current_crc_val.data()) == 0;
}

/*
 * 11011001000100 by 101
 * */

#endif //ERRORDETECTION_CRCUTILS_H
