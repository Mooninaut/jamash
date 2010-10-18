#include "StormLib/src/StormLib.h"
#include <iostream>
#include <string>
#include <vector>
#include <sys/stat.h>

// mpq.cpp - Uses StormLib to extract UI code / art from
// World of Warcraft versions 4.0+

// StormLib is available as source code from http://www.zezula.net/en/mpq/stormlib.html

// The version of StormLib used is slightly patched, see stormlib.diff

// Copyright (C) 2010 Clement Cherlin ("Jamash" on Kil'jaeden-US)
// Email: ccherlin@gmail.com
// WowInterface: http://www.wowinterface.com/forums/member.php?action=getinfo&userid=25961
// Curse Gaming: http://wow.curse.com/members/Jamash.aspx

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// VERSION 1.0 2010-OCT-03 Clement Cherlin
/*
const char * const suffixes[] = { ".toc", ".lua", ".xml", ".xsd" };
const int suffixCount = 4;
const char * const prefixes[] = { "Interface\\FrameXML\\", "Interface\\AddOns\\" };
const int prefixCount = 2;

const char art[] = "Interface\\*.blp";
*/
using namespace std;

const string Locale("locale=");
const string Command("command=");
const string Mpq("mpq=");
const string Prefix("prefix=");
const string Suffix("suffix=");
const string Base("base=");
const string Debug("debug=");
const string Verbose("verbose=");

const int bufferSize = 1024;
/*
const int commandIndex = 1;
const int localeIndex = 2;
const int baseIndex = 3;
const int patchIndex = 4;
*/
DWORD getFileFlags(HANDLE mpq, const char *fileName) {
  HANDLE file;
  //cerr << "Checking to see if " << fileName << " is patched." << endl;
  //bool result = SFileOpenFileEx(mpq, fileName, SFILE_OPEN_PATCHED_FILE, &file);
  bool result = SFileOpenFileEx(mpq, fileName, SFILE_OPEN_FROM_MPQ, &file);
  assert(result == true); // FIXME BLAH BLAH
  DWORD info;
  result = SFileGetFileInfo(file, SFILE_INFO_FLAGS, &info, sizeof(info));
  SFileCloseFile(file);
  return(info);
}
bool isPatch(DWORD info) {
  return(info & MPQ_FILE_PATCH_FILE ? true : false);
}
bool isDeleted(DWORD info) {
  return(info & MPQ_FILE_DELETE_MARKER ? true : false);
}
long printMPQMatches(HANDLE mpq, const char *glob) {
  SFILE_FIND_DATA found;
  bool result = false;
  long count = 0;
  HANDLE listHandle = SListFileFindFirstFile(mpq, NULL, glob, &found);
  if (listHandle != NULL) {
    result = true;
  }
  while (result) {
    count++;
    DWORD flags = getFileFlags(mpq, found.cFileName);
    if (isPatch(flags)) {
      cout << "*"; // patched
    }
    else if (isDeleted(flags)) {
      cout << "-"; // deleted
    }
    else {
      cout << "+"; // new
    }
    cout << " " << found.cFileName << endl;
    result = SListFileFindNextFile(listHandle, &found);
  }
  SListFileFindClose(listHandle);
  return count;
}
/*
bool FileExists(const char * fileName) {
  struct stat stFileInfo;
  bool exists;
  int intStat;

  // Attempt to get the file attributes
  intStat = stat(fileName,&stFileInfo);
  if(intStat == 0) {
    // We were able to get the file attributes
    // so the file obviously exists.
    exists = true;
  } else {
    // We were not able to get the file attributes.
    // This may mean that we don't have permission to
    // access the folder which contains this file. If you
    // need to do that level of checking, lookup the
    // return values of stat which will give you
    // more details on why stat failed.
    exists = false;
  }
  
  return(exists);
}
*/
// is str1 a prefix of str2?
bool isPrefix(const string str1, const string str2) {
  return(str2.compare(0, str1.length(), str1) ? false : true);
}
int main(int argc, const char *argv[]) {
  // SFileOpenArchive(const char * szMpqName, DWORD dwPriority, DWORD dwFlags, HANDLE * phMpq);
  // argv[0] executable name
  // argv[1] command
  // argv[2] locale string
  // argv[3] base MPQ
  // argv[4]...argv[argc - 1] patch MPQs (must be in order)
  HANDLE mpqHandle;
  bool result;
  char buffer[bufferSize];
  vector<string> mpqStr;
  vector<string> prefixStr;
  vector<string> suffixStr;
  string localeStr("enUS");
  string commandStr("list");
  string baseStr("");
  string debugStr("false");
  string verboseStr("true");
  //bool debug;
  bool verbose;
  vector<string>::iterator it1;
  vector<string>::iterator it2;
  for (int arg = 1; arg < argc; arg++) {
    string s(argv[arg]);
#define GETIT(str, var) \
    if (isPrefix(str, s)) { \
      var = s; \
      var.erase(0, str.length()); \
    } else
    GETIT(Command, commandStr)
    GETIT(Locale, localeStr)
    GETIT(Base, baseStr)
    //GETIT(Debug, debugStr)
    GETIT(Verbose, verboseStr)
#undef GETIT
#define GETIT(str,vec) \
    if (isPrefix(str, s)) { \
      s.erase(0, str.length()); \
      vec.push_back(s); \
    } else
    GETIT(Mpq, mpqStr)
    GETIT(Prefix, prefixStr)
    GETIT(Suffix, suffixStr)
    {}
#undef GETIT
  }
  //debug = debugStr != "false";
  verbose = verboseStr != "false";
  if (verbose) {
    cerr << "command " << commandStr << endl;
    cerr << "locale " << localeStr << endl;
    cerr << "base " << baseStr << endl;
#define PRINTIT(vec, str) \
  for (it1 = vec.begin(); it1 < vec.end(); it1++) { \
    cerr << str << *it1 << endl; \
  }
    PRINTIT(mpqStr, "MPQ ")
    PRINTIT(prefixStr, "prefix ")
    PRINTIT(suffixStr, "suffix ")
  }
#undef PRINTIT
  if (baseStr.length() > 0) {
    baseStr += "\\";
  }
  if (verbose) {
    cerr << "Opening base MPQ " << mpqStr[0] << " for reading." << endl;
  }
  result = SFileOpenArchive(mpqStr[0].c_str(), 0, MPQ_OPEN_READ_ONLY, &mpqHandle);
//  result = SFileOpenArchive(argv[baseIndex], 0, MPQ_OPEN_READ_ONLY, &mpqHandle);

  for (it1 = ++mpqStr.begin(); it1 < mpqStr.end() && result; it1++) {
    if (verbose) {
      cerr << "Applying patch MPQ " << *it1 << "." << endl;
    }
    result = SFileOpenPatchArchive(mpqHandle, it1->c_str(), localeStr.c_str(), MPQ_OPEN_READ_ONLY);
  }
  if (verbose) {
    cerr << "File open result: " << (result ? "Success" : "Failure");
  }

  if (!result) {
    cerr << " Error #" << GetLastError() << endl;
    exit(1);
  }

  cerr << endl;

  if (commandStr == "list") {
    long count = 0;
    
    for (it1 = prefixStr.begin(); it1 < prefixStr.end(); it1++) {
      for (it2 = suffixStr.begin(); it2 < suffixStr.end(); it2++) {
        string s = baseStr + *it1 + "\\*" + *it2;
        if (verbose) {
          cerr << "Searching for " << s << endl;
        }
        count += printMPQMatches(mpqHandle, s.c_str()); // , debug, mpqStr[0].c_str());
      }
    }
    if (verbose) {
      cerr << "Found " << count << " files." << endl;
    }

  }
/*
  else if (strcmp(argv[commandIndex], "art") == 0) {
    long count = 0;
    count += printMPQMatches(mpqHandle, art);
    cerr << "Found " << count << " files." << endl;
  }
*/
  else if (commandStr == "extract") {
    char buffer2[bufferSize];
    long extracted = 0;
    long errors = 0;
    //long exists = 0;
    while (1) {
      cin.getline(buffer, bufferSize, '\t');
      cin.getline(buffer2, bufferSize);
      if (cin.eof()) {
        break;
      }
      /*
      if (FileExists(buffer2)) {
        //cerr << "File '" << buffer2 << "' already exists." << endl;
        exists++;
      }
      else {
      */
        //cerr << "Extracting file '" << buffer << "' to location '" << buffer2 << "'" << endl;
        if (SFileExtractFile(mpqHandle, buffer, buffer2)) {
          extracted++;
        }
        else {
          cerr << "Could not extract file '" << buffer << "', error #" << GetLastError() << endl;
          errors++;
          //exit(2);
        }
      /*
      }
      */
    }
    //cerr << "Extracted " << extracted << " files, skipping " << exists << " existing files, with " << errors << " errors." << endl;
    if (verbose) {
      cerr << "Extracted " << extracted << " files, with " << errors << " errors." << endl;
    }
  }
  SFileCloseArchive(mpqHandle);
  return(0);
}
