#!C:\Dwimperl\perl\bin\perl -w
use strict;
use FileTools;
use Data::Dumper;

print "Scanning of system files running...\n";
my $before = FileTools::giveFilesInDirectory("C:\\");
print "Scannnig of system files terminated\n"; 
print "Running time $time secondes\n";

my $exe = "C:\\Users\\romain\\Downloads\\npp.6.6.9.Installer.exe";
system($exe);
$time = time;
my $after = FileTools::giveFilesInDirectory("C:\\");
print "Scannnig of system files terminated\n"; 
$time = time - $time;
print "Running time $time secondes\n";


print Dumper($diff);
print "Directory ".scalar(keys(%$diff))."\n";
__END__