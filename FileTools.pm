#!C:\Dwimperl\perl\bin\perl -w
package FileTools;
use strict;
use Data::Dumper;
use File::Path;
use File::Copy;
use Store;
use EnvTools;
use JSON;

my $mForbiddenDir = ["C:/Windows", "C:/Users", "C:/Recovery"];

sub _containsInForbidden {
	my $dir = shift;
	my $forbiddenDir = shift;
	my $isIn = 0;
	$isIn = 1 if(grep{ $_ eq $dir } @$forbiddenDir);
	return $isIn;
}

sub _giveFiles {
	my $dir = shift;
	my $hash = shift;
	my $forbiddenDir = shift;
	my @list;
	print "$dir\n";
	if(-d $dir) {
			if(opendir(CRT_DIR, $dir)) {
				my @files = grep {!/^\.\.?$/} readdir CRT_DIR;
				close(CRT_DIR); 
				foreach (@files) {
					$dir =~ s/\/+$//g;
					my $path = $dir.'/'.$_;
					chomp $path;
					if (-d $path){
						if($path !~ /^C:\/.*?\..*|^C:\/.*?\$.*|^C:\/Users/) {
							if(!defined $forbiddenDir || !_containsInForbidden($path, $forbiddenDir)) {
								_giveFiles($path, $hash);
							}
						}
					} elsif(-f $path) {
						EnvTools::transformVarToEnv(\$path);
						push @list, $path;			
					}
				}
			} else {
				# print "Impossible d'ouvrir le répertoire $dir $!\n";
			}
	} elsif(-f $dir) {
		push @list, $dir;
		EnvTools::transformVarToEnv(\$dir);
	}
	EnvTools::transformVarToEnv(\$dir);
	$hash->{$dir} = \@list;
}

sub giveFilesInDirectory {
	my $dir = shift;
	my $forbiddenDir = shift;
	
	push @$forbiddenDir, @$mForbiddenDir if(defined $forbiddenDir);
	$forbiddenDir = $mForbiddenDir if(!defined $forbiddenDir);
	
	my $hash = {};
	if(ref($dir) eq "ARRAY") {
		foreach my $crt_path (@$dir) {
			_giveFiles($crt_path, $hash, $forbiddenDir);
		}
	} else {
		_giveFiles($dir, $hash, $forbiddenDir);
	}
	return $hash;
}

sub diff {
	my ($oldFiles, $newFiles) = @_;
	my (%hash, %new, %delete);
	foreach (keys(%$oldFiles)) {
		if(!exists $newFiles->{$_}) {
			$delete{$_} = $oldFiles->{$_};
		} else {
			my %tmpOld = map { $_ => 1} @{$oldFiles->{$_}};
			my %tmpNew = map { $_ => 1} @{$newFiles->{$_}};
			my (@listOld, @listNew);
			foreach (keys(%tmpOld)) {
				if(!exists $tmpNew{$_}) {
					push @listOld, $_;
				} else {
					#Comparer les date de création de fichiers
					
				}
			}
			if(@listOld > 0) {
				$delete{$_} = \@listOld;
			}
			foreach (keys(%tmpNew)) {
				if(!exists $tmpOld{$_}) {
					push @listNew, $_;
				}
			}
			if(@listNew > 0) {
				$new{$_} = \@listNew;
			}
		}
	}
	foreach (keys(%$newFiles)) {
		if(!exists $oldFiles->{$_}) {
			$new{$_} = $newFiles->{$_};
		}
	}
	$hash{'new'} = \%new;
	$hash{'delete'} = \%delete;
	return \%hash;
}

1;
__END__