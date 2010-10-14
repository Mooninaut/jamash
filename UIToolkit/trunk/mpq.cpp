#include "StormLib/src/StormLib.h"
#include <iostream>
#include <string>

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

const char * const suffixes[] = { ".toc", ".lua", ".xml", ".xsd" };
const int suffixCount = 4;
const char * const prefixes[] = { "Interface\\FrameXML\\", "Interface\\AddOns\\" };
const int prefixCount = 2;
const int bufferSize = 1024;

const int commandIndex = 1;
const int localeIndex = 2;
const int baseIndex = 3;
const int patchIndex = 4;

const char art[] = "Interface\\*.blp";

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
    std::cout << found.cFileName << std::endl;
  result = SListFileFindNextFile(listHandle, &found);
  }
  SListFileFindClose(listHandle);
  return count;
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
  std::cerr << "Opening base MPQ " << argv[baseIndex] << " for reading." << std::endl;

  result = SFileOpenArchive(argv[baseIndex], 0, MPQ_OPEN_READ_ONLY, &mpqHandle);

  for (int arg = patchIndex; arg < argc && result; arg++) {
    std::cerr << "Applying patch MPQ " << argv[arg] << "." << std::endl;
    result = SFileOpenPatchArchive(mpqHandle, argv[arg], argv[localeIndex], MPQ_OPEN_READ_ONLY);
  }

  std::cerr << "File open result: " << (result ? "Success" : "Failure");

  if (!result) {
    std::cerr << " Error #" << GetLastError() << std::endl;
    exit(1);
  }

  std::cerr << std::endl;

  if (strcmp(argv[commandIndex], "code") == 0) {
    long count = 0;

    for (int i = 0; i < prefixCount; i++) {
      for (int j = 0; j < suffixCount; j++) {
        strcpy(buffer, prefixes[i]);
        strcat(buffer, "*");
        strcat(buffer, suffixes[j]);
        count += printMPQMatches(mpqHandle, buffer);
      }
    }

    std::cerr << "Found " << count << " files." << std::endl;

  }
  else if (strcmp(argv[commandIndex], "art") == 0) {
    long count = 0;
    count += printMPQMatches(mpqHandle, art);
    std::cerr << "Found " << count << " files." << std::endl;
  }
  else if (strcmp(argv[commandIndex], "extract") == 0) {
    char buffer2[bufferSize];
    long extracted = 0;
    while (1) {
      std::cin.getline(buffer, bufferSize, '\t');
      std::cin.getline(buffer2, bufferSize);
      if (std::cin.eof()) {
        break;
      }
      std::cerr << "Extracting file '" << buffer << "' to location '" << buffer2 << "'" << std::endl;
      if (SFileExtractFile(mpqHandle, buffer, buffer2)) {
        extracted++;
      }
      else {
        std::cerr << "Could not extract file, error #" << GetLastError() << std::endl;
        exit(2);
      }
    }
    std::cerr << "Extracted " << extracted << " files." << std::endl;
  }
  SFileCloseArchive(mpqHandle);
  return(0);
}
