#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use Registre;

my $time = time;
my $test = 
{
	'key1/sKey1' => 
	{
		'valueName1' => 
			{
				'type' => 'REG_SZ',
				'data' => 'data content'
			},
		'valueName2' =>
			{
				'type' => 'REG_SZ',
				'data' => 'data content2'
			}
	},
	'key1/sKey2' =>
	{
		'valueName3' =>
			{
				'type' => 'REG_SZ',
				'data' => 'data content3'
			},
		'valueName4' =>
			{
				'type' => 'REG_SZ',
				'data' => 'data content4'
			},
	}
};
my $filename = "C:\\Users\\romain\\Desktop\\test.txt";
print "Create registry config file...\n";
Registre::makeConfig($test, $filename);
$time = time - $time;
print "Config file created\n";
print "Running time $time secondes\n";

print "Read registry config file...\n";
$time = time;
my $new = Registre::readConfig($filename);
print Dumper($new);
$time = time - $time;
print "Config file read\n";
print "Running time $time secondes\n";

__END__