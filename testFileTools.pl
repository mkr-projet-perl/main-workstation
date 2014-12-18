#!C:\Dwimperl\perl\bin\perl -w
use strict;
use FileTools;
use Data::Dumper;

my $program = $ARGV[0] || "C:\\Users\\romain\\Downloads\\npp.6.6.9.Installer.exe";my $forbidden = [""];my $time = time;
print "System files' scan running...\n";
my $before = FileTools::giveFilesInDirectory("C:/", $forbidden);
print "Scan of system files terminated\n"; $time = time - $time;
print "Running time $time secondes\n";

system($program);
$time = time;print "System files' scan' running...\n";
my $after = FileTools::giveFilesInDirectory("C:/", $forbidden);
print "Scan of system files terminated\n"; 
$time = time - $time;
print "Running time $time secondes\n";

my $diff = FileTools::diff($before, $after);
print Dumper($diff);
print "Directory created ".keys(%{$diff->{'new'}})."\n";
__END__