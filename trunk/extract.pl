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

my $dataDir = "Data";
my $outDir = "User-Interface-Data";
my $mpqProgram = "mpq.exe";
my $locale = "enUS";
my $extract = "code";

my $result = GetOptions(
  "datadir=s"   => \$dataDir,
  "outdir=s"    => \$outDir,
  "mpqprogram=s" => \$mpqProgram,
  "locale=s"    => \$locale,
  "extract=s" => \$extract);

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
# print "@MPQNames\n"; # debug
my @updates = grep { m/wow-update-\d+\.mpq$/i } @MPQNames;
my ($version) = $updates[-1] =~ m/wow-update-(\d+)\.mpq$/i;
my @updatesOldWorld = grep { m/wow-update-oldworld-\d+\.mpq/i } @MPQNames;
my $localeMPQ = File::Spec->catfile($dataDir, $locale, "locale-$locale.MPQ");

my $updates = q(").join(q(" "), @updates).q(");
my @paths = `$mpqProgram $extract $locale "$localeMPQ" $updates`;
my %newDirs;
my @newFiles;
chomp @paths;
foreach my $path (@paths) {
  my @pieces = split(/\\/, $path);
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
my @newDirs = (
  $outDir,
  File::Spec->catdir($outDir, $version),
  map { File::Spec->catdir($outDir, $version, $_) } buildDirs(\%newDirs)
);
#print join($/, @newDirs), $/; # debug
foreach my $newDir (@newDirs) {
  mkdir ($newDir) if not -d $newDir;
}
my $commandString = q(").join(q(" "),$mpqProgram, 'extract', $locale, $localeMPQ, @updates).q(");
my $pipe = IO::File->new('|' . $commandString) or die;
for (my $i = 0; $i < @paths; $i++) {
  my $inFile = $paths[$i];
  my $outFile = File::Spec->catfile($outDir, $version, @{$newFiles[$i]});
  $pipe->print($inFile, "\t", $outFile, $/);
}
undef $pipe;
