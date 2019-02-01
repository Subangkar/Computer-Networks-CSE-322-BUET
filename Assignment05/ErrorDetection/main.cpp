#include <iostream>
#include <windows.h>
#include <bitset>
#include <ctime>
#include <vector>
#include <algorithm>

#include "HammingUtils.h"
#include "CRCUtils.h"

using namespace std;

bool debug = true;
#define M 1
#define S "a"//"Hamming Code"
#define P 0.1
#define POLYNOMIAL "10101"

enum console_color_t {
	WHITE = 15, GREEN = 10, RED = 4, CYAN = 11
};

void setConsoleColor(int color = WHITE) {
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), static_cast<WORD>(color));
}

void printDataBlock(const string &s, int m);

void printHammingCodedColoredString(const string &s);

void printChecksumAddedDataBits(const string &s, const string &polynomial);

string convertToBinaryString(const string &s);

string convertFromBinaryString(const string &s);

string serializeColmWise(const string &s, int nChars_per_row);

string deserializeColmWise(const string &s, int nChars_per_row, vector<int> &corruptIdx);

string corruptDataFrame(const string &s, double corruptionFactor, vector<int> &corruptIdx);

void printCorrupted(const string &s, const string &actual, int newLineSep = 0, bool seperate_ascii = false);

void printCorruptedFrame(const string &s, const vector<int> &corruptIdx);

void printCorruptedFrame(const string &s, const string &actual);

void printCorruptedDataBlock(const string &s, int m, const vector<int> &corruptIdx);

/// returns a random value between [0,1]
double randomFactor();

int main() {
	int m = M;
	string s = S;
	string polynomial = POLYNOMIAL;
	double p = P;
	cout << "Enter #data_bytes in a row (m): ";
	if (!debug)cin >> m;
	else cout << m << endl;
	fflush(stdin);
	cout << "Enter data string: ";
	if (!debug)getline(cin, s);
	else cout << s << endl;
	cout << "Enter generator: ";
	if (!debug)getline(cin, polynomial);
	else cout << polynomial << endl;
	cout << "Enter corruption probability: ";
	if (!debug)cin >> p;
	else cout << p << endl;
	while (s.length() % m != 0) s.append("~");
	m *= 8;

	vector<int> corruptIdx;
	int r = nhamming_redundant_bits(m);// from HammingUtils.h
	string binaryDataBlock = convertToBinaryString(s);
	string hammingDataBlock = convertToHammingPaddedDataBlock(binaryDataBlock, m);
	string serializedFrame = serializeColmWise(hammingDataBlock, m + r);
	string checksumAddedFrame = appendChecksumCRC(serializedFrame, polynomial);

	string corruptedFrame = corruptDataFrame(checksumAddedFrame, p, corruptIdx);

	string checkSumRemovedFrame = removeChecksumCRC(corruptedFrame, polynomial);
	string corruptHammingDataBlock = deserializeColmWise(checkSumRemovedFrame, m + r, corruptIdx);
	string correctedDataBlock = convertFromHammingPaddedDataBlock(corruptHammingDataBlock, m);
	string correctedDataString = convertFromBinaryString(correctedDataBlock);

	cout << "Data string after padding: \"" << s << "\" (" << s.length() << ")" << endl;
	cout << endl;

	cout << "Data block:" << " (" << binaryDataBlock.length() << ")" << endl;
	printDataBlock(binaryDataBlock, m);
	cout << endl;

	cout << "Data block after adding check bits:" << " (" << hammingDataBlock.length() << ")" << endl;
	printHammingCodedDataBlock(hammingDataBlock, m);
	cout << endl;

	cout << "Data bits after column-wise serialization:" << " (" << serializedFrame.length() << ")" << endl;
	cout << serializedFrame << endl;
	cout << endl;

	cout << "Data bits after adding CRC check-sum:" << " (" << checksumAddedFrame.length() << ")" << endl;
	printChecksumAddedDataBits(checksumAddedFrame, polynomial);
	cout << endl;

	cout << "Data bits after corruption:" << endl;
	printCorrupted(corruptedFrame, checksumAddedFrame);
	cout << endl;


	if (!checkChecksumOkay(corruptedFrame, polynomial)) cout << "Checksum: error detected" << endl;
	else cout << "Checksum: no error detected" << endl;
	cout << endl;

	cout << "Data bits after removing CRC check-sum:" << " (" << checkSumRemovedFrame.length() << ")" << endl;
//	printCorruptedFrame(checkSumRemovedFrame, corruptIdx);
	printCorrupted(checkSumRemovedFrame, serializedFrame);
	cout << endl;
//	cout << checkSumRemovedFrame << endl;


	cout << "Data bits after deserialization:" << " (" << corruptHammingDataBlock.length() << ")" << endl;
//	printCorruptedDataBlock(corruptHammingDataBlock, m + r, corruptIdx);
	printCorrupted(corruptHammingDataBlock, hammingDataBlock, m + r);
	cout << endl;

	cout << "Data block after removing check bits:" << " (" << correctedDataBlock.length() << ")" << endl;
//	printDataBlock(correctedDataBlock, m);
	printCorrupted(correctedDataBlock, binaryDataBlock, m, true);
	cout << endl;

	cout << "Recovered data string: " << correctedDataString << endl;
	cout << endl;
	return 0;
}

string convertToBinaryString(const string &s) {
	string binStr;
	for (const auto &c:s) {
		binStr += (bitset<8>(static_cast<unsigned long long int>(c))).to_string();
	}
	return binStr;
}

string convertFromBinaryString(const string &s) {
	string asciiStr;
	for (int i = 0; i * 8 < s.length(); ++i) {
		asciiStr += (char) bitset<8>(string(s, i * 8, 8)).to_ullong();
	}
	return asciiStr;
}

void printHammingCodedColoredString(const string &s) {
	for (int pos = 1; pos <= s.length(); ++pos) {
		if (isPowerOf_2(pos)) {
			setConsoleColor(GREEN);
		}
		cout << s[pos - 1];
		setConsoleColor(WHITE);
	}
	setConsoleColor(WHITE);
	cout << endl;
}

void printDataBlock(const string &s, int m) {
	for (int i = 0; i < s.length();) {
		if (i % (8) == 0) cout << " ";
		cout << s[i];
		if (++i % (m) == 0) cout << endl;
	}
}

void printCorruptedDataBlock(const string &s, int m, const vector<int> &corruptIdx) {
	for (int i = 0; i < s.length();) {
		if (find(corruptIdx.begin(), corruptIdx.end(), i) != corruptIdx.end()) {
			setConsoleColor(RED);
		}
		cout << s[i];
		if (++i % (m) == 0) cout << endl;
		setConsoleColor(WHITE);
	}
}

double randomFactor() {
	static bool isSeeded = false;
	if (!isSeeded) isSeeded = true, srand(time(nullptr));
	double fact = rand();
	return fact / RAND_MAX;
}

string serializeColmWise(const string &s, int nChars_per_row) {
	string serialStr;
	auto nChars_per_colm = s.length() / nChars_per_row;
	for (int c = 0; c < nChars_per_row; ++c) {
		for (int r = 0; r < nChars_per_colm; ++r) {
			serialStr += s[r * nChars_per_row + c];
		}
	}
	return serialStr;
}

string deserializeColmWise(const string &s, int nChars_per_row, vector<int> &corruptIdx) {
	vector<int> newCorruptIdx;
	string origStr;
	auto nChars_per_colm = s.length() / nChars_per_row;
	for (int r = 0; r < nChars_per_colm; ++r) {
		for (int c = 0; c < nChars_per_row; ++c) {
			auto i = c * nChars_per_colm + r;
			origStr += s[i];
			if (find(corruptIdx.begin(), corruptIdx.end(), i) != corruptIdx.end()) {
				newCorruptIdx.push_back(r * nChars_per_row + c);
			}
		}
	}
	corruptIdx = newCorruptIdx;
	return origStr;
}

string corruptDataFrame(const string &s, double corruptionFactor, vector<int> &corruptIdx) {
	string corrupted = s;
	int i = 0;
	for (auto &c:corrupted) {
		if (randomFactor() < corruptionFactor) {
//		if (i == 12 || i == 0) {
			c = !(c - '0') + '0';
			corruptIdx.push_back(i);
		}
		++i;
	}
	return corrupted;
}

void printCorruptedFrame(const string &s, const vector<int> &corruptIdx) {
	int i = 0;
	for (const auto &c:s) {
		if (find(corruptIdx.begin(), corruptIdx.end(), i) != corruptIdx.end()) {
			setConsoleColor(RED);
		}
		cout << c;
		setConsoleColor(WHITE);
		++i;
	}
	cout << endl;
}

void printChecksumAddedDataBits(const string &s, const string &polynomial) {
	auto crc_len = polynomial.length() - 1;
	int i;
	setConsoleColor(WHITE);
	for (i = 0; i < s.length() - crc_len; ++i) {
		cout << s[i];
	}
	setConsoleColor(CYAN);
	while (i < s.length()) cout << s[i++];
	cout << endl;
	setConsoleColor();
}

void printCorrupted(const string &s, const string &actual, int newLineSep, bool seperate_ascii) {
	for (int i = 0; i < s.length();) {
		if (seperate_ascii && i % 8 == 0)cout << " ";
		if (s[i] != actual[i]) setConsoleColor(RED);
		cout << s[i];
		setConsoleColor(WHITE);
		++i;
		if (newLineSep && (i % newLineSep == 0))cout << endl;
	}
	cout << endl;
}



