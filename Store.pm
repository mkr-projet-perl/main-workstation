#! C:\Dwimperl\perl\bin\perl -w
package Store;

use strict;
use Storable 'nstore';

use constant DIFF_FILE_SYSTEM 			=> "DiffFileSystem.txt";
use constant DIFF_REGISTRY 				=> "DiffRegistry.txt";
use constant COPY_DIFF_FILE_SYSTEM 		=> "CopyDiffFileSystem.txt";
use constant COPY_DIFF_REGISTRY 		=> "CopyDiffRegistry.txt";
use constant MAKE_CONFIG_FILE_SYSTEM 	=> "ConfigFileSystem.txt";
use constant MAKE_CONFIG_REGISTRY 		=> "ConfigRegistry.txt";
use constant IPS_FILE 					=> "Ips.txt";
use constant DIR 						=> "Saves";
use constant TEMP_DIR 					=> "C:/Temp";

sub store_data {
	my ($ref, $file) = @_;
	Storable::nstore($ref, DIR.'/'.$file);
}

sub retrieve_data {
	my $file = shift;
	my $newRef;
	
	my $path = DIR.'/'.$file;
	$newRef = Storable::retrieve($path);
	
	return $newRef;
}

1;
__END__