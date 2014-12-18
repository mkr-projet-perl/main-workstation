#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use Config;

my $file_config = ARGV[0] or die "Couldn't find config file: $@\n";

if(my $config = Config::readFile($file_config)) {
	Config::loadCreateConfigFileSystem($config);
} else {
	die "Can't read $file_config: $@\n";
}

__END__