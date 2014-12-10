#!C:\Dwimperl\perl\bin\perl -w
package FileTools;
use strict;

sub giveFilesInDirectory {
	my $dir = shift;
	my $hash = shift || {};
	if(ref($dir) eq "ARRAY") {
		foreach my $crt_path (@$dir) {
			my @list;
			opendir (CRT_DIR, $crt_path)
				or die "Impossible d'ouvrir le répertoire $crt_path $!\n";
			my @files = grep {!/^\.\.?$/} readdir CRT_DIR;
			close CRT_DIR;
			foreach(@files) {
				if (-d "$crt_path\\$_") {
					giveFilesInDirectory("$crt_path\\$_", $hash);
				}
				else {
					push @list, "$crt_path\\$_";
				}
			}
			$hash->{$crt_path} = \@list;
		}
	} else {
		return $dir if(-f $dir);
		my @list;
		opendir(CRT_DIR, $dir)
			or die "Impossible d'ouvrir le répertoire $dir $!\n";
		my @files = grep {!/^\.\.?$/} readdir CRT_DIR;
		close(CRT_DIR);
		foreach (@files) {
			if (-d "$dir\\$_") {
				giveFilesInDirectory("$dir\\$_", $hash);
			} else {
				push @list,  "$dir\\$_";
			}
		}
		$hash->{$dir} = \@list;
	}
}
1;
__END__