#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use Registre;

my $time = time;
my $test = 
{
	'LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/key1' => 
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
	'LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/key1/sKey1' =>
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
	},
	'LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/key1/sKey2' =>
	{
		'valueName5' =>
			{
				'type' => 'REG_SZ',
				'data' => 'data content5'
			},
		'valueName6' =>
			{
				'type' => 'REG_SZ',
				'data' => 'data content6'
			},
	},
	'LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/key1/sKey2/ssKey1' =>
	{
		'valueName7' =>
			{
				'type' => 'REG_SZ',
				'data' => 'data content7'
			},
		'valueName8' =>
			{
				'type' => 'REG_SZ',
				'data' => 'data content8'
			},
	},
	'LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/key2/sKey54564/ssKey486464a446' =>
	{
		'valueName9' =>
			{
				'type' => 'REG_SZ',
				'data' => 'data content9'
			},
		'valueName10' =>
			{
				'type' => 'REG_SZ',
				'data' => 'data content10'
			},
	},
};
print "Load config...\n";
Registre::loadConfig($test);
$time = time - $time;
print "Config loaded\n";
print "Running time $time secondes\n";

__END__