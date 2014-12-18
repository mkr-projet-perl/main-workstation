#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use MyConfig;

my $file_config = ARGV[0] or die "Couldn't find config file: $@\n";

if(my $config = MyConfig::readFile($file_config)) {
	MyConfig::loadCreateConfigFileSystem($config);
} else {
	die "Can't read $file_config: $@\n";
}

__END__