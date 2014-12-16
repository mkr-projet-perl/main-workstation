#!C:\Dwimperl\perl\bin\perl -w
use strict;
use FileTools;
use Data::Dumper;
my $time = time;
print "Scanning of system files running...\n";
my $before = FileTools::giveFilesInDirectory("C:/");
print "Scannnig of system files terminated\n"; $time = time - $time;
print "Running time $time secondes\n";

my $exe = "C:\\Users\\romain\\Downloads\\npp.6.6.9.Installer.exe";
system($exe);
$time = time;print "Scan of system files running...\n";
my $after = FileTools::giveFilesInDirectory("C:/");
print "Scan of system files terminated\n"; 
$time = time - $time;
print "Running time $time secondes\n";

my $diff = FileTools::diff($before, $after);
print Dumper($diff);
print "Directory created ".scalar(keys(%{$diff->{'new'}}))."\n";
__END__