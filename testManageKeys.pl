#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use Registre;
use Win32API::Registry 0.24;


my $not_existing_path = "LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/test";
my $existing_path = $not_existing_path;
my $values = 
{
	'value1' =>
	{
		'type' => 'REG_SZ',
		'data' => 'data1'	
	},
	'value2' =>
	{
		'type' => 'REG_BINARY',
		'data' => 0111001001010
	},
	'value3' =>
	{
		'type' => 'REG_DWORD',
		'data' => 0xAF
	}
};

print "Create not existing registry key\n";
print "--------------------------------\n";

print "Create registry key running...\n";
my $time = time;
my $createdKey = Registre::createOrReplaceKey($not_existing_path);
$time = time - $time;
print "Does the registry key is created ?\tYes\n" if($createdKey);
print "Does the registry key is updated ?\tYes\n" if(!$createdKey);
print Dumper(Registre::scanRegistry($not_existing_path));

print "Running time $time secondes\n";

print "###\n\n";
print "Create existing registry key \n";
print "-------------------------------\n";

print "Create registry key running...\n";
$time = time;
$createdKey = Registre::createOrReplaceKey($existing_path, $values);
$time = time - $time;
print "Does the registry key is created ?\tYes\n" if($createdKey);
print "Does the registry key is updated ?\tYes\n" if(!$createdKey);
print Dumper(Registre::scanRegistry($existing_path));

print "Running time $time secondes\n";

print "###\n\n";

__END__