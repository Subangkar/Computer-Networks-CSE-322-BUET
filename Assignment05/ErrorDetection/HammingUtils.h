//
// Created by Subangkar on 31-Jan-19.
//

#ifndef ERRORDETECTION_HAMMINGUTILS_H
#define ERRORDETECTION_HAMMINGUTILS_H

#include <bitset>

using namespace std;

#define TOGGLE_BIT(x)(!(x-'0')+'0')

// for positive number only
bool isPowerOf_2(int n) {
	return n > 0 && (n & (n - 1)) == 0;
}

void printHammingCodedColoredString(const string &s);

void printHammingCodedDataBlock(const string &s, int m);

string convertToHammingPaddedDataBlock(const string &s, int m);

string convertFromHammingPaddedDataBlock(const string &s, int m);

int nhamming_redundant_bits(int m);

string computeHammingString(const string &s, int r);

string hammingPaddedString(const string &s, int m);

// also corrects
string hammingUnPaddedString(const string &s);

char hammingEvenParity(const string &s, int rpos);

char hammingOddParity(const string &s, int rpos);


string convertToHammingPaddedDataBlock(const string &s, int m) {
	string hammingBlock;
	int n = s.length() / m;//string is a multiple of m
	for (int i = 0; i < n; ++i) {
		hammingBlock += (hammingPaddedString(string(s, i * m, m), m));
	}
	return hammingBlock;
}

string convertFromHammingPaddedDataBlock(const string &s, int m) {
	string normalBlock;
	int r = nhamming_redundant_bits(m);
	int n = s.length() / m;//string is a multiple of m
	for (int i = 0; i < n; ++i) {
		normalBlock += (hammingUnPaddedString(string(s, i * (m + r), m + r)));
	}
	return normalBlock;
}

void printHammingCodedDataBlock(const string &s, int m) {
	int r = nhamming_redundant_bits(m);
	for (int i = 0; i * (m + r) < s.length(); ++i) {
		printHammingCodedColoredString(string(s, i * (m + r), m + r));
	}
}

int nhamming_redundant_bits(int m) {
	int r = 0;
	while ((1 << r) < m + r + 1) ++r; // 1<<r == 1*2^r
	return r;
}

string hammingPaddedString(const string &s, int m) {
	int r = nhamming_redundant_bits(m);
	char str[s.length() + r + 1];// +1 for NULL
	memset(str, '\0', s.length() + r + 1);

	/// adding check bits @pos = 2^x
	for (int i = 0, j = 0; i < s.length() + r; ++i) {
		if (isPowerOf_2(i + 1)) str[i] = '0';
		else str[i] = s[j++];
	}

	cout << "-----------" << endl;
	cout << computeHammingString(str, r) << endl << computeHammingString(computeHammingString(str, r), r) << endl;
	cout << "-----------" << endl;
//	/// setting parity @check_bits
//	for (int rpos = 0; rpos < r; ++rpos) {
//		str[(1 << rpos) - 1] = hammingOddParity(str, rpos);
//	}
	return computeHammingString(str, r);
}

string hammingUnPaddedString(const string &s) {
	/// finding the erroneous bit position
	int errorPos = 0;
	for (int i = 0, pow = 0; i < s.length(); ++i) {
		if (isPowerOf_2(i + 1)) {
			errorPos = ((s[i] - '0') << pow) | errorPos;
		}
	}
	string correctedString = s;
	correctedString[errorPos - 1] = TOGGLE_BIT(correctedString[errorPos - 1]);
	string str;
	/// deleting check bits @pos = 2^x
	for (int i = 0; i < correctedString.length(); ++i) {
		if (!isPowerOf_2(i + 1)) str += correctedString[i];
	}
	return str;
}

char hammingEvenParity(const string &s, int rpos) {
	int n1s = 0;
	for (int pos = 1; pos <= s.length(); ++pos) {
		if ((pos & (1 << rpos)) && s[pos - 1] == '1') ++n1s;
	}
//	cout << (rpos + 1) << " >> " << n1s << " <" << endl;
	return !(n1s % 2) + '0';
}

char hammingOddParity(const string &s, int rpos) {
	return hammingEvenParity(s, rpos) == '1' ? '0' : '1';
}

string computeHammingString(const string &s, int r) {
	string str = s;
	/// setting parity @check_bits
	for (int rpos = 0; rpos < r; ++rpos) {
		str[(1 << rpos) - 1] = hammingOddParity(str, rpos);
	}
	return str;
}

#endif //ERRORDETECTION_HAMMINGUTILS_H
