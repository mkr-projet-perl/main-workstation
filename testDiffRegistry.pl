#!C:\Dwimperl\perl\bin\perl
use strict;
use Data::Dumper;
use Registre;

my $program = $ARGV[0] || "C:\\Users\\romain\\Downloads\\npp.6.6.9.Installer.exe";
my $scanningPart = "LMachine/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall";

print "Scan of registry before installation...\n";
print "----------------------------------------\n";

my $time = time;
my $scanBeforeInstallation = Registre::scanRegistry($scanningPart);
$time = time - $time;
print "Running time $time secondes\n";
print "\n\n";

$time = time;
print $program." installation...\n";
print "----------------------------------------\n";
system $program;
$time = time - $time;
print "Running time $time secondes\n";
print "\n\n";

print "Scan of registry after installation...\n";
print "----------------------------------------\n";

$time = time;
my $scanAfterInstallation = Registre::scanRegistry($scanningPart);
$time = time - $time;
print "Running time $time secondes\n";
print "\n\n";

print "Research registry changes...\n";
print "----------------------------------------\n";
$time = time;
my $diff = Registre::diffRegistry($scanBeforeInstallation, $scanAfterInstallation);
$time = time - $time;
print(Dumper($diff));
print "Running time $time secondes\n";
print "\n\n";

__END__