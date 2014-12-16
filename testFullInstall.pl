#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use Registre;
use FileTools;

my $program = $ARGV[0] || "C:\\Users\\romain\\Downloads\\npp.6.6.9.Installer.exe";
my $scanningPart = "LMachine";

print "Scan of Registry before installation...\n";
print "----------------------------------------\n";

my $time = time;
my $scanBeforeInstallation = Registre::scanRegistry($scanningPart);
$time = time - $time;
print "Running time $time secondes\n";
print "###\n\n";

print "Scan of File system before installation...\n";
print "----------------------------------------\n";

my $time = time;
my $fileBeforeInstallation = FileTools::giveFilesInDirectory("C:\\");
$time = time - $time;
print "Running time $time secondes\n";
print "###\n\n";

$time = time;
print $program." installation...\n";
print "----------------------------------------\n";
system $program;
$time = time - $time;
print "Running time $time secondes\n";
print "###\n\n";

print "Scan of registry after installation...\n";
print "----------------------------------------\n";

my $scanAfterInstallation = Registre::scanRegistry($scanningPart);
$time = time - $time;
print "Running time $time secondes\n";
print "###\n\n";

print "Scan of File system after installation...\n";
print "----------------------------------------\n";

my $time = time;
my $fileAfterInstallation = FileTools::giveFilesInDirectory("C:\\");
$time = time - $time;
print "Running time $time secondes\n";
print "###\n\n";

print "Research registry changes...\n";
print "----------------------------------------\n";
$time = time;
my $diffScan = Registre::diffRegistry($scanBeforeInstallation, $scanAfterInstallation);
$time = time - $time;
print(Dumper($diffScan));
print "Running time $time secondes\n";
print "###\n\n";

print "Research file changes...\n";
print "----------------------------------------\n";
$time = time;
my $diffFile = FileTools::diff($fileBeforeInstallation, $fileAfterInstallation);
$time = time - $time;
print(Dumper($diffFile));
print "Running time $time secondes\n";
print "###\n\n";

__END__