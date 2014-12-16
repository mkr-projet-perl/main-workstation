#!C:\Dwimperl\perl\bin\perl
use strict;
use Data::Dumper;
use Registre;

print "Test 1\n";
print "----------------------------------------\n";

my $time = time;
my $scan = Registre::scanRegistry("LMachine/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall");
$time = time - $time;
print "Nb keys scanned ".scalar(keys(%$scan))."\n";
print "Running time $time secondes\n";
print "\n\n";

print "Test 2\n";
print "----------------------------------------\n";

$time = time;
$scan = Registre::scanRegistry("LMachine/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion");
$time = time - $time;
print "Nb keys scanned ".scalar(keys(%$scan))."\n";
print "Running time $time secondes\n";
print "\n\n";

print "Test 3\n";
print "----------------------------------------\n";

$time = time;
$scan = Registre::scanRegistry("CUser");
$time = time - $time;
print "Nb keys scanned ".scalar(keys(%$scan))."\n";
print "Running time $time secondes\n";
print "\n\n";

print "Test 4\n";
print "----------------------------------------\n";

$time = time;
$scan = Registre::scanRegistry();
$time = time - $time;
print "Nb keys scanned ".scalar(keys(%$scan))."\n";
print "Running time $time secondes\n";
print "\n\n";

__END__