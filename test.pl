#!C:\Strawberry\perl\bin\perl -w
use strict;
use Win32API::Registry 0.21 qw( :ALL );
use Data::Dumper;

use constant KEY_WOW64_64KEY => 0x0100;
use constant KEY_WOW64_32KEY => 0x0200;

sub _openKey {
	my ($root, $key, $key_rights) = @_;
	my $registry_key;
	RegOpenKeyEx($root, $key, 0, $key_rights, $registry_key)
		or die "RegOpenKeyEx impossible d'ouvrir $root\\$key\n".regLastError()."\n";
	return $registry_key;
}

sub _closeKey {
	 my $key = shift;
	 RegCloseKey($key)
	 	or die "RegCloseKey $key\n".regLastError()."\n";
 	return 1;
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
					$key =~ s/\//\\\\/g;
				} else {
					$key = "";
				}
			} else {
				$root = undef;
			}
		} else {
			print "$str n'est pas une cl�\n";
		}
	}
	return ($root, $key);
}

sub _subKeyCounter {
	my $opened_key = shift;
	my $nbSubKeys;
	RegQueryInfoKey($opened_key, [], [], [], $nbSubKeys, [], [], [], [], [], [], []) 
		or die "RegQueryInfoKey impossible de compter le nombre sous-clefs".regLastError()."\n";
	return $nbSubKeys;
}

sub _valueCounter {
	my $opened_key = shift;
	my $nbValues;
	RegQueryInfoKey($opened_key, [], [], [], [], [], [], $nbValues, [], [], [], []) 
		or die "RegQueryInfoKey impossible de compter le nombre de valeurs".regLastError()."\n";
	return $nbValues;
}

sub _enumSubKeyName {
	my ($opened_key, $index) = @_;
	my $subKeyName;
	RegEnumKeyEx($opened_key, $_, $subKeyName, [], [], [], [], []) 
		or die "RegEnumKeyEx impossible d'it�rer sur les sous-clefs".regLastError()."\n";
	return $subKeyName;
}

sub _enumValue {
	my ($opened_key, $index) = @_;
	my ($name, $type, $data);
	RegEnumValue($opened_key, $index, $name, [], [], $type, $data, [])
		or die "RegEnumValue impossible d'it�rer sur les valeurs".regLastError()."\n";
	return ($name, $type, $data);
}

sub _getRegistryKeyValue {
	my ($opened_key, $value) = @_;
	my ($type, $data);
	RegQueryValueEx($opened_key, $value, [], $type, $data, []);
	return ($type, $data);
}

sub _getAllRegistryKeyValues {
	my $opened_key = shift;
	my %hash;
	my $nbValues = _valueCounter($opened_key);
	foreach (0..$nbValues-1) {
		my ($name, $type, $data) = _enumValue($opened_key, $_);
		$hash{$name} = {'type' => $type, 'data' => $data};
	}
	return \%hash;
}

sub _scanRegistry {
	my ($root, $key, $res) = @_;
	my ($opened_key, $nbSubKeys);
	$opened_key = _openKey($root, $key, KEY_READ|0x0200);
	$nbSubKeys = _subKeyCounter($opened_key);
	if($nbSubKeys) {
		foreach (0..$nbSubKeys-1) {
			my $subKeyName = _enumSubKeyName($opened_key, $_);
			_scanRegistry($opened_key, $subKeyName, $res);
		}
	} else {
		my $values = _getAllRegistryKeyValues($opened_key);
		$res->{$key} = $values;
	}
	_closeKey($opened_key);
}

sub _compareValue {
	my ($keyValuesA, $keyValuesB) = @_;
	my $isSame = 1;
	$isSame = 0 if($keyValuesA->{'name'} ne $keyValuesB->{'name'});
	$isSame = 0 if($keyValuesA->{'type'} != $keyValuesB->{'type'});
	$isSame = 0 if($keyValuesA->{'data'} ne $keyValuesB->{'data'});
	return $isSame;
}

sub _compareRegistryKey {
	my ($valuesA, $valuesB) = @_;
	my $isSame = 0;
	foreach (@$valuesA) {
		
	}
	return $isSame;
}

sub scanRegistry {
	my ($path) = @_;
	my ($root, $key) = _transformRegistryString($path);
	my %res;
	print "$root\t$key\n";
	if(defined $root) {
		_scanRegistry($root, $key, \%res);
	} else {
		print "$path n'est pas une cl� valide\n";
	}
	return \%res;
}

sub diffRegistry {
	my ($oldRegistry, $newRegistry) = @_;
	my (%deleted, %updatings, %news); 
	my %res;
	foreach (keys(%$oldRegistry)) {
		if(!exists($newRegistry->{$_})) {
			$deleted{$_} = $oldRegistry->{$_};
		} else {
			#On regarde si elle a �t� modifi�e (valeur, type, contenue)
			my $values = $oldRegistry->{$_};
			foreach (keys(%$values)) {
				if(!_compareRegistryKey($oldRegistry->{$_}, $newRegistry->{$_})) {
					$updatings{$_} = $oldRegistry->{$_};
				}
			}
		}
	}
	foreach (keys(%$newRegistry)) {
		if(!exists($oldRegistry->{$_})) {
			$news{$_} = $newRegistry->{$_};
		}
	}
	$res{'delete'} = \%deleted;
	$res{'update'} = \%updatings;
	$res{'news'} = \%news;
	return \%res;
}
my $res = scanRegistry("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Applets");
my $res2 = scanRegistry("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication");
print Dumper($res2);
#my $hash = diffRegistry($res, $res2);
#print Dumper($hash);

#$res = scanRegistry("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/");
#print scalar(@$res)."\n";

#$res = scanRegistry("LMachine/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall/");
#print scalar(@$res)."\n";

#print Dumper(_transformRegistryString(""));
#print Dumper(_transformRegistryString("LMachine"));
#print Dumper(_transformRegistryString("LMachine/SOFTWARE"));
#print Dumper(_transformRegistryString("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"));