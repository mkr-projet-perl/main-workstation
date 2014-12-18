#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use Registre;
use Win32API::Registry 0.24;

my $sPath = Registre::PATH_32_CURRENT_VERSION."/Uninstall/test"
my @tPath = qw($sPath);
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

print "Create registry key\n";
print "--------------------------------\n";

print "Create registry key running...\n";
my $time = time;
my $createdKey = Registre::createOrReplaceKey($sPath);
$time = time - $time;
print "Does the registry key is created ?\tYes\n" if($createdKey);
print "Does the registry key is updated ?\tYes\n" if(!$createdKey);
print Dumper(Registre::scanRegistry(\@tPath));

print "Running time $time secondes\n";

print "###\n\n";

__END__