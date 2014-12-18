#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use MyConfig;

my $time = time;
my $test = 
{
	'a/b/c/d' => {},
	'a/b/c' => {},
	'a' => {},
	'e/f' => {},
	'e/f/g' => {},
	'h/i/j/k' => {},
};
my $filename = $ARGV[0] || "C:\\Users\\zen\\Desktop\\test.txt";
print "Create registry config file...\n";
MyConfig::makeDeleteConfigRegistry($test, $filename);
$time = time - $time;
print "Config file created\n";
print "Running time $time secondes\n";

print "Read registry config file...\n";
$time = time;
my $new = MyConfig::readConfig($filename);
print Dumper($new);
$time = time - $time;
print "Config file read\n";
print "Running time $time secondes\n";

__END__