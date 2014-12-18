#! C:\Dwimperl\perl\bin\perl -w
package Store;

use strict;
use Storable;

use constant DIFF_FILE_SYSTEM => "DiffFileSystem";
use constant DIFF_REGISTRY => "DiffRegistry";
use constant READY_DIFF_FILE_SYSTEM => "FileSysBefore";
use constant READY_DIFF_REGISTRY => "FileSysAfter";
use constant MAKE_CONFIG_FILE_SYSTEM => "FileSysBefore";
use constant MAKE_CONFIG_REGISTRY => "FileSysAfter";
use constant IPS_FILE => "Ips";
use constant DIR => "Saves/";
use constant TEMP_DIR => "C:/Temp";

sub store_data {
	my ($ref, $file) = @_;
	store($ref, DIR.$file);
}

sub retrieve_data {
	my $file = shift;
	my $newRef;
	
	$newRef = retrieve($file);
	
	return $newRef;
}

1;