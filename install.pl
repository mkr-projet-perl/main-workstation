#!C:\Dwimperl\perl\bin\perl
use strict;
use Data::Dumper;
use Registre;
use FileTools;
use Store;

my $program = $ARGV[0] or die "Aucun program $!\n";
my $drive = $ARGV[1] or die "Aucun lecteur mis en paramètre$!\n";
my $scanPart = "LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion";
my $forbiddenDir = ["C:/Windows"];

print "Registry's scan before installation...\n";
print "----------------------------------------\n";

my $time = time;
my $scanBeforeInstallation = Registre::scanRegistry($scanPart);
$time = time - $time;
print "Running time $time secondes\n";
print "\n\n";

print "File system's scan before installation...\n";
print "----------------------------------------\n";

$time = time;
my $fileBeforeInstallation = FileTools::giveFilesInDirectory($drive, $forbiddenDir);
$time = time - $time;
print "Running time $time secondes\n";
print "\n\n";

$time = time;
print $program." installation...\n";
print "----------------------------------------\n";
system $program;
$time = time - $time;
print "Running time $time secondes\n";
print "###\n\n";

print "Registry's scan after installation...\n";
print "----------------------------------------\n";

my $scanAfterInstallation = Registre::scanRegistry($scanPart);
$time = time - $time;
print "Running time $time secondes\n";
print "\n\n";

print "File system's scan after installation...\n";
print "----------------------------------------\n";

$time = time;
my $fileAfterInstallation = FileTools::giveFilesInDirectory($drive, $forbiddenDir);
$time = time - $time;
print "Running time $time secondes\n";
print "\n\n";

print "Research registry changes...\n";
print "----------------------------------------\n";
$time = time;
my $diffScan = Registre::diffRegistry($scanBeforeInstallation, $scanAfterInstallation);
$time = time - $time;
print(Dumper($diffScan));
print "Running time $time secondes\n";
print "\n\n";

print "Research file changes...\n";
print "----------------------------------------\n";
$time = time;
my $diffFile = FileTools::diff($fileBeforeInstallation, $fileAfterInstallation);
$time = time - $time;
print(Dumper($diffFile));
print "Running time $time secondes\n";
print "\n\n";

print "Directory created ".keys(%{$diffFile->{'new'}})."\n";
print "Key created ".keys(%{$diffScan->{'news'}})."\n";
print "Key deleted ".keys(%{$diffScan->{'delete'}})."\n";
print "Key updated ".keys(%{$diffScan->{'update'}})."\n";

Store::store_data($diffScan, Store::DIFF_FILE_SYSTEM);
Store::store_data($diffFile, Store::DIFF_REGISTRY);

__END__