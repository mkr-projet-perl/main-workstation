#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use Registre;
use FileTools;
use EnvTools;

my $ref = 
{
	'bite' 				=> {},
	'C:/Windows'			=> {},
	'C:/Users/zen/eded/eded/e'	=> {},
	'C:/Windows/ded/fefef/ded'	=> {}
};



EnvTools::encodeEnv($ref);
# print Dumper($ref);

__END__