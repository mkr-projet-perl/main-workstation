#!C:\Strawberry\perl\bin\perl -w
use strict;
use Win32API::Registry 0.21 qw( :ALL );
use Data::Dumper;

sub _openKey {
	my ($root, $key,$key_way) = @_;
	my $registry_key;
	if (RegOpenKeyEx($root, $key, 0, $key_way, $registry_key)) {
		return $registry_key;
	} else {
		die $key."\n".regLastError()."\n";
	}
}

sub _closeKey {
	 my $key = shift;
	 if(RegCloseKey($key)) {
	 	return 1;
	 } else {
	 	die $key."\n".regLastError()."\n";
	 }
}

my $_rootRegistryKey = {
	"LMachine"	=> HKEY_LOCAL_MACHINE,
	"Classes"	=> HKEY_CLASSES_ROOT,
	"CUser"		=> HKEY_CURRENT_USER,
	"Users"		=> HKEY_USERS,
	"CConfig"	=> HKEY_CURRENT_CONFIG,
	"PerfData"	=> HKEY_PERFORMANCE_DATA,
	"DynDat"	=> HKEY_DYN_DATA
};

sub _transformRegistryString {
	my $str = shift;
	my ($root, $key);
	if($str =~ m/^(\w+)(\/(.+)$)?/) {
		if(defined $1) {
			$root = $1;
			if(exists $_rootRegistryKey->{$root}) {
				$root = $_rootRegistryKey->{$root};
				if(defined $3) {
					$key = $3;
					$key =~ s/\//\\/g;
				} else {
					$key = "";
				}
			} else {
				$root = undef;
			}
		} else {
			print "$str n'est pas une clé\n";
		}
	}
	return ($root, $key);
}

use constant KEY_READ64 => 0x0200;

sub _scanRegistry {
	my ($root, $key, $res) = @_;
	my ($opened_key, $nbSubKeys, $subKeyName);
	$opened_key = _openKey($root, $key, KEY_READ|KEY_READ64);
	RegQueryInfoKey($opened_key, [], [], [], $nbSubKeys, [], [], [], [], [], [], []) or die regLastError()."\n";
	if($nbSubKeys) {
		foreach (0..$nbSubKeys-1) {
			RegEnumKeyEx($opened_key, $_, $subKeyName, [], [], [], [], []) or die regLastError()."\n";
			_scanRegistry($opened_key, $subKeyName, $res);
		}
	} else {
		push @$res, $key;
	}
	_closeKey($opened_key);
}

sub scanRegistry {
	my ($path) = @_;
	my ($root, $key) = _transformRegistryString($path);
	my @res;
	if(defined $root) {
		_scanRegistry($root, $key, \@res);
	} else {
		print "$path n'est pas une clé valide\n";
	}
	return \@res;
}

print Dumper(scanRegistry("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/"));

#print Dumper(_transformRegistryString(""));
#print Dumper(_transformRegistryString("LMachine"));
#print Dumper(_transformRegistryString("LMachine/SOFTWARE"));
#print Dumper(_transformRegistryString("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"));