#!C:\Strawberry\perl\bin\perl -w
package FileTools;
use strict;

sub giveFilesInDirectory {
	my $dir = shift;
	my $hash = shift || {};
	if(ref($dir) eq "ARRAY") {
		foreach my $crt_path (@$dir) {
			my %hashDir;
			opendir (CRT_DIR, $crt_path)
				or die "Impossible d'ouvrir le répertoire $crt_path $!\n";
			my @files = grep {!/^\.\.?$/} readdir CRT_DIR;
			close CRT_DIR;
			foreach(@files) {
				if (-d "$crt_path\\$_") {
					$hashDir{"$crt_path\\$_"} = "d";
					giveFilesInDirectory("$crt_path\\$_", $hash);
				}
				else {
					$hashDir{"$crt_path\\$_"} = "f";
				}
			}
			$hash->{$crt_path} = \%hashDir;
		}
	} else {
		my %hashDir;
		opendir(CRT_DIR, $dir)
			or die "Impossible d'ouvrir le répertoire $dir $!\n";
		my @files = grep {!/^\.\.?$/} readdir CRT_DIR;
		close(CRT_DIR);
		foreach (@files) {
			if (-d "$dir\\$_") {
				$hashDir{"$dir\\$_"} = "d";
				giveFilesInDirectory("$dir\\$_", $hash);
			} else {
				$hashDir{"$dir\\$_"} = "f";
			}
		}
		$hash->{$dir} = \%hashDir;
	}
}
1;
__END__