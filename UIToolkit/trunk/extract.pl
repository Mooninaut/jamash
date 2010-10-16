#!/usr/bin/perl -w

# extract.pl - Helper script to automate extracting UI code from
# World of Warcraft versions 4.0+

# Copyright (C) 2010 Clement Cherlin ("Jamash" on Kil'jaeden-US)
# Email: ccherlin@gmail.com
# WowInterface: http://www.wowinterface.com/forums/member.php?action=getinfo&userid=25961
# Curse Gaming: http://wow.curse.com/members/Jamash.aspx

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# VERSION 1.0 2010-OCT-03 Clement Cherlin

use strict;
use Getopt::Long;
use File::Spec;
use IO::Dir;
use IO::File;
use IO::Pipe;

sub buildDirs {
  my $href = shift;
  map {
    my $key = $_;
    my $val = $href->{$_};
    %$val
      ? ($key, map { File::Spec->catdir($key, $_) } buildDirs($val))
      : $_;
    } sort { $a cmp $b } keys %$href;
}

my $dataDir = "Data";
my $outDir = "User-Interface-Data";
my $mpqProgram = "mpq.exe";
my $locale = "enUS";
my $extract; #= "code";
my $logFileName = "extract.log";

my $result = GetOptions(
  "datadir=s"   => \$dataDir,
  "outdir=s"    => \$outDir,
  "mpqprogram=s" => \$mpqProgram,
  "locale=s"    => \$locale,
  "extract=s" => \$extract,
  "logfile=s" => \$logFileName);
my $artPrefix = "prefix=Interface";
my $artSuffix = "suffix=.blp";
my @codePrefixes = map { "prefix=$_" } ("Interface\\FrameXML", "Interface\\AddOns");
my @codeSuffixes = map { "suffix=$_" } (".toc", ".lua", ".xml", ".xsd");
my $logFileHandle;
if ($logFileName) {
  $logFileHandle = IO::File->new(">$logFileName") or die;
}
sub logPrint {
  if ($logFileHandle) {
    $logFileHandle->print(@_);
  }
}
logPrint("data $dataDir, out $outDir, mpq.exe $mpqProgram, locale $locale, extract $extract, log $logFileName\n");
my $dataHandle = IO::Dir->new($dataDir) or die "Could not open directory '$dataDir' for reading: $!.\n";
my $fileName;
my @MPQNames;
while (defined($fileName = $dataHandle->read())) {
  push(@MPQNames, File::Spec->catfile($dataDir, $fileName)) if $fileName =~ m/\.mpq$/i;
}
undef $dataHandle;
$dataHandle = IO::Dir->new(File::Spec->catdir($dataDir, $locale)) or die;
while (defined($fileName = $dataHandle->read())) {
  push(@MPQNames, File::Spec->catfile($dataDir, $locale, $fileName)) if $fileName =~ m/\.mpq$/i;
}

undef $dataHandle;
@MPQNames = sort {lc($a) cmp lc($b)} @MPQNames;
logPrint("Found MPQs: @MPQNames\n");
# print "@MPQNames\n"; # debug
my @updates = grep { m/wow-update-\d+\.mpq$/i } @MPQNames;
logPrint("Found update MPQs: @updates\n");
my ($version) = $updates[-1] =~ m/wow-update-(\d+)\.mpq$/i;
my @updatesOldWorld = grep { m/wow-update-oldworld-\d+\.mpq/i } @MPQNames;
logPrint("Found Old World update MPQs: @updatesOldWorld\n");
my $localeMPQ = File::Spec->catfile($dataDir, $locale, "locale-$locale.MPQ");
my @mpqs = ($localeMPQ, @updates);
my $first = 1;
while (@mpqs) {
  my $mpqs = q("mpq=).join(q(" "mpq=), @mpqs).q(");
  my @paths;
  my $base = $first ? "" : $locale;
  my $commandLine;
  if ($extract eq "code") {
    $commandLine = "$mpqProgram command=list locale=$locale $mpqs base=$base @codePrefixes @codeSuffixes";
  }
  elsif ($extract eq "art") {
    $commandLine = "$mpqProgram command=list locale=$locale $mpqs base=$base $artPrefix $artSuffix";
  }
  else {
    die "invalid command\n";
  }
  logPrint("Executing $commandLine\n");
  @paths = `$commandLine`;
  logPrint("Found paths:\n".join('',@paths));
  my %newDirs;
  my @newFiles;
  chomp @paths;
  foreach my $path (@paths) {
    my @pieces = split(/\\/, $path);
    shift @pieces if not $first;
    push @newFiles, [@pieces];
    my $file = pop(@pieces);
    my $href = \%newDirs;
    foreach my $piece (@pieces) {
      if (exists($href->{$piece})) {
        
      }
      else {
        $href->{$piece} = {};
      }      
      $href = $href->{$piece};
    }
  }
  my @newDirs = grep { not -d $_ } (
    $outDir,
    File::Spec->catdir($outDir, $version),
    map { File::Spec->catdir($outDir, $version, $_) } buildDirs(\%newDirs)
  );
  logPrint("Creating directories:\n".join($/,@newDirs)."\n");
  #print join($/, @newDirs), $/; # debug
  foreach my $newDir (@newDirs) {
    mkdir ($newDir);
  }
  my $commandString = q(").join(q(" "), $mpqProgram, 'command=extract', "locale=$locale", "base=$base", map{ "mpq=$_" }@mpqs).q(");
  logPrint("Executing command: $commandString\n");
  my $pipe = IO::File->new('|' . $commandString) or die;
  for (my $i = 0; $i < @paths; $i++) {
    my $inFile = $paths[$i];
    my $outFile = File::Spec->catfile($outDir, $version, @{$newFiles[$i]});
    $pipe->print($inFile, "\t", $outFile, $/);
  }
  undef $pipe;
  shift @mpqs; # oh so tricksy -- try each successive mpq for new files
  $first = 0;
}
undef $logFileHandle;