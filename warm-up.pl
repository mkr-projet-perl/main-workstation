#!C:\Dwimperl\perl\bin\perl
use strict;
use Data::Dumper;
use Store;

my $refDiffScan = Store::retrieve_data(Store::DIFF_FILE_SYSTEM);
my $refDiffFile = Store::retrieve_data(Store::DIFF_REGISTRY);

Store::store_data($refDiffScan, Store::MAKE_CONFIG_FILE_SYSTEM);
Store::store_data($refDiffFile, Store::MAKE_CONFIG_REGISTRY);

__END__