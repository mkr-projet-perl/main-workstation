#!C:\Dwimperl\perl\bin\perl
package MyConfig;
use strict;
use Data::Dumper;
use File::Path qw(mkpath);
use File::Copy qw(copy);
use Registre;
use FileTools;
use EnvTools;
use Store;
use JSON;

##############################################################################
##############################################################################
#	Gestion du fichier de config
# Ce fichier sert à la création de clé de registre sur le poste client.
# Il est envoyé par la machine maître au client.
##############################################################################
##############################################################################

use constant TMP_DIR 		=> Store::TEMP_DIR;

sub _createConfigFile {
	my $filename = shift;
	my $content = shift;
	
	if(open(FILE, '>:encoding(UTF-8)', $filename)) {
		print FILE $content;
		close(FILE);
		return 1;
	} else {
		print "erreur $!\n";
	}
	return 0;
}

sub makeConfig {
	my $ref = shift;
	my $filename = shift;
	my $json = to_json($ref, {pretty => 1, utf8 => 1});
	
	return _createConfigFile($filename, $json);
}

sub makeDeleteConfigRegistry {
	my $ref = shift;
	my $filename = shift;
	
	my @tab = sort({ ($a =~ tr/\//\//) <=> ($b =~ tr/\//\//) or $a cmp $b } keys(%$ref));
	foreach my $hKey (@tab) {
		@tab = grep { $_ eq $hKey || index($_, $hKey) != 0 } @tab;
	}
	
	my $json = to_json(\@tab, {pretty => 1, utf8 => 1});
	return _createConfigFile($filename, $json);
}

#Cette fonction lit un fichier config et retourne le json décodé associé
sub readConfig {
	my $configPath = shift;
	
	if(open(FILE, '<:encoding(UTF-8)', $configPath)) {
		my $doc;
		$doc .= $_ while(<FILE>);
		return from_json($doc, {utf8 => 1});
	}
	return 0;
}

sub loadCreateConfigRegistry {
	my $hash = shift;
	my $sizeMax = 0;
	my $sizeMin = ((keys(%$hash))[0] =~ tr/\//\//);
	foreach (keys(%$hash)) {
		my $tmpSize = ($_ =~ tr/\//\// );
		$sizeMax = $tmpSize if($tmpSize >= $sizeMax);
		$sizeMin = $tmpSize if($tmpSize <= $sizeMin);
	}
	# print "MAX\t$sizeMax\nMIN\t$sizeMin\n";
	while($sizeMax >= $sizeMin) {
		my @sTab = grep { ($_ =~ tr/\//\//) == $sizeMax } keys(%$hash);
		foreach (@sTab) {
			print "$_\n";
			Registre::createOrReplaceKey($_, $hash->{$_});
		}
		--$sizeMax;
	}
}

sub loadDeleteConfigRegistry {
	my $tab = shift;
	my @deleteKey;
	foreach (@$tab) {Registre::selectDeletedKey($_, \@deleteKey);}
	my $sizeMax = 0;
	my $sizeMin = ($deleteKey[0] =~ tr/\//\//);
	foreach (@deleteKey) {
		my $tmpSize = ($_ =~ tr/\//\// );
		$sizeMax = $tmpSize if($tmpSize >= $sizeMax);
		$sizeMin = $tmpSize if($tmpSize <= $sizeMin);
	}
	# print "MAX\t$sizeMax\nMIN\t$sizeMin\n";
	while($sizeMax >= $sizeMin) {
		my @sTab = grep { ($_ =~ tr/\//\//) == $sizeMax } @deleteKey;
		Registre::deleteKey(\@sTab);
		--$sizeMax;
	}
}

sub _copyFile {
	my $src = shift;
	my $dst = shift;
	print "Copy from $src to $dst\n";
	eval{copy($src, $dst)};
	if($@) {
		print "Coudn't copy $src to $dst: $@\n";
		return 0;
	}
	return 1;
}

sub _createPathOrFile {
	my $path = shift;
	my $files = shift;
	EnvTools::transformEnvToVar(\$path);
	print "$path\n";
	
	eval{mkpath $path};
	if($@) {
		print "Coudn't create $path: $@\n";
		return 0;
	}
	
	foreach my $f (@$files) {
		EnvTools::transformEnvToVar(\$f);
		my $filename = ($f =~ /(.+)\/(.*)/)[1];
		_copyFile(TMP_DIR."/$filename", $path);
	}
	return 1;
	
}

sub loadCreateConfigFileSystem {
	my $hash = shift;
	foreach (keys(%$hash)) {
		_createPathOrFile($_, $hash->{$_});
	}
}

##############################################################################
##############################################################################

1;
__END__