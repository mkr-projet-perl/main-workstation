#!C:\Strawberry\perl\bin\perl -w
package Registre;
use strict;
use Win32API::Registry 0.21 qw( :ALL );
use Data::Dumper;

use constant KEY_READ_ALL => KEY_READ|0x0100;

sub _openKey {
	my ($root, $key, $key_rights) = @_;
	my $registry_key;
	RegOpenKeyEx($root, $key, 0, $key_rights, $registry_key);
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

my $_valueType = {
	1	=> 'REG_SZ',
	2	=> 'REG_EXPAND_SZ',
	3	=> 'REG_BINARY',
	4	=> 'REG_DWORD',
	7	=> 'REG_MULTI_SZ',
	9	=> 'REG_FULL_RESOURCE_DESCRIPTOR'
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
			print "$str n'est pas une clé\n";
		}
	}
	return ($root, $key);
}

sub _transformRegistryValue {
	my ($type,$value) = @_;
	my $newValue = $value;
	if($type == 3) {
		$newValue = unpack("B*", $value);
	}elsif($type == 4 || $type == 9) {
		$newValue = unpack("H*", $value);
	}
	return $newValue;
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
		or die "RegEnumKeyEx impossible d'itérer sur les sous-clefs".regLastError()."\n";
	return $subKeyName;
}

sub _enumValue {
	my ($opened_key, $index) = @_;
	my ($name, $type, $data);
	RegEnumValue($opened_key, $index, $name, [], [], $type, $data, [])
		or die "RegEnumValue impossible d'itérer sur les valeurs".regLastError()."\n";
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
		my %values;
		my ($name, $type, $data) = _enumValue($opened_key, $_);
		$values{'type'} = $_valueType->{$type};
		$values{'data'} = _transformRegistryValue($type, $data);
		$hash{$name} = \%values;
	}
	return \%hash;
}

sub _scanRegistry {
	my ($root, $key, $res, $fullPath) = @_;
	my ($opened_key, $nbSubKeys);
	$opened_key = _openKey($root, $key, KEY_READ_ALL);
	if($opened_key) {
		$nbSubKeys = _subKeyCounter($opened_key);
		if($nbSubKeys) {
			foreach (0..$nbSubKeys-1) {
				my $subKeyName = _enumSubKeyName($opened_key, $_);
				_scanRegistry($opened_key, $subKeyName, $res, $fullPath."/".$subKeyName);
			}
		}
		my $values = _getAllRegistryKeyValues($opened_key);
		$fullPath =~ s/\\\\/\//g;
		$res->{$fullPath} = $values;
		_closeKey($opened_key);
	} else {
		print "RegOpenKeyEx impossible d'ouvrir $root\\$key\n".regLastError()."\n";
	}
}

sub _compareRegistryKey {
	my ($valuesA, $valuesB) = @_;
	my $isSame = 1;
	foreach (keys(%$valuesA)) {
		if(exists $valuesB->{$_}) {
			if(!$valuesA->{$_}{'type'} eq $valuesB->{$_}{'type'}) {
				$isSame = 0;
			}
			if(!$valuesA->{$_}{'data'} == $valuesB->{$_}{'data'} ||
				!$valuesA->{$_}{'data'} eq $valuesB->{$_}{'data'}) {
				$isSame = 0;		
			}
		} else {
			$isSame = 0;
		} 
	}
	$isSame = 0 if(scalar(grep { !exists $valuesA->{$_} } keys(%$valuesB)));
	return $isSame;
}

sub _installInformation {
	my ($registryPath, $appName, $values) = @_;
	my %installLocation;
	$appName =~ tr/A-Z/a-z/;
	my ($root, $key) = _transformRegistryString($registryPath);
	my $opened_key = _openKey($root, $key, KEY_READ_ALL);
	my $nbSubKeys = _subKeyCounter($opened_key);
	foreach (0..$nbSubKeys-1) {
		my $subKeyName = _enumSubKeyName($opened_key, $_);
		my $subOpenedKey = _openKey($opened_key, $subKeyName, KEY_READ_ALL);
		my $name = _getRegistryKeyValue($subOpenedKey, "DisplayName");
		$name =~ tr/A-Z/a-z/;
		if($appName eq $name) {
			if(defined $values) {
				foreach (@$values) {
					my ($type, $data) = _getRegistryKeyValue($subOpenedKey, $_);
					if(defined $data && $data ne '') {
						$installLocation{$_} = $data;
					}
				}
			} else {
				my ($type, $data) = _getRegistryKeyValue($subOpenedKey, "InstallLocation");
				$installLocation{'InstallLocation'} = $data if(defined $data);
			}
		}
		_closeKey($subOpenedKey);
	}
	_closeKey($opened_key);
	return \%installLocation;
}

sub installLocation {
	my $appName = shift;
	my $registryKeyPath32Bits = 'LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/';
	my $registryKeyPath64Bits = 'LMachine/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall/';
	my @values = qw(InstallLocation UninstallString DisplayIcon);
	my $installLocation = _installInformation($registryKeyPath32Bits, $appName, \@values);
	if(!defined $installLocation || $installLocation eq '') {
		$installLocation = _installInformation($registryKeyPath64Bits, $appName, \@values);
	}
	return $installLocation;
}

sub scanRegistry {
	my ($path) = @_;
	my ($root, $key) = _transformRegistryString($path);
	my %res;
	print "$root\t$key\n";
	if(defined $root) {
		_scanRegistry($root, $key, \%res, $key);
	} else {
		print "$path n'est pas une clé valide\n";
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
			#On regarde si elle a été modifiée (valeur, type, contenue)
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

sub _createKey {
	my ($keyPath, $values) = @_;	
}

sub _replaceKey {
	my ($keyPath, $values) = @_;
}

sub _deleteKey {
	my ($keyPath) = @_;
}

sub _deleteValues {
	my ($keyPath, $values) = @_;
}

#my $install = installLocation('rogue legacy');
#print Dumper($install);

# my $res = scanRegistry("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Applets");
# my $res2 = scanRegistry("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Authentication");

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
1;
__END__