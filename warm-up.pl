#!C:\Dwimperl\perl\bin\perl
use strict;
use Data::Dumper;
use Store;

my $refDiffScan = Store::retrieve_data(Store::DIFF_REGISTRY);
my $refDiffFile = Store::retrieve_data(Store::DIFF_FILE_SYSTEM);

Store::store_data($refDiffScan, Store::COPY_DIFF_REGISTRY);
Store::store_data($refDiffFile, Store::COPY_DIFF_FILE_SYSTEM);

print "ok\n";

__END__