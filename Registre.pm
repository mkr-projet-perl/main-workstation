#!C:\Dwimperl\perl\bin\perl -w
package Registre;
use strict;
use Win32API::Registry 0.24;
use Data::Dumper;

sub KEY_READ () { 131097 }
sub KEY_WOW64_64KEY () { 131353 }
sub KEY_WOW64_64KEY_W () { 131334 }
sub KEY_READ_ALL () { Win32API::Registry::KEY_READ|KEY_WOW64_64KEY}
sub KEY_WRITE_ALL () { Win32API::Registry::KEY_WRITE|KEY_WOW64_64KEY_W }

sub _openKey {
	my ($root, $key, $key_rights) = @_;
	my $registry_key;
	Win32API::Registry::RegOpenKeyEx($root, $key, 0, $key_rights, $registry_key);
		# or die "RegOpenKeyEx $root\\$key\n".Win32API::Registry::regLastError()."\n";
	return $registry_key;
}

sub _closeKey {
	 my $key = shift;
	 Win32API::Registry::RegCloseKey($key)
	 	or die "RegCloseKey $key\n".Win32API::Registry::regLastError()."\n";
 	return 1;
}

my $_rootRegistryKey = {
	"LMachine"	=> Win32API::Registry::HKEY_LOCAL_MACHINE,
	"Classes"	=> Win32API::Registry::HKEY_CLASSES_ROOT,
	"CUser"		=> Win32API::Registry::HKEY_CURRENT_USER,
	"Users"		=> Win32API::Registry::HKEY_USERS,
	"CConfig"	=> Win32API::Registry::HKEY_CURRENT_CONFIG,
	"PerfData"	=> Win32API::Registry::HKEY_PERFORMANCE_DATA,
	"DynDat"	=> Win32API::Registry::HKEY_DYN_DATA
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
			print "$str n'est pas une cl�\n";
		}
	}
	return ($root, $key);
}

sub _transformRegistryValue {
	my ($type,$value) = @_;
	return "" if(!defined $value);
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
	Win32API::Registry::RegQueryInfoKey($opened_key, [], [], [], $nbSubKeys, [], [], [], [], [], [], [])
		or die "RegQueryInfoKey impossible de compter le nombre sous-clefs".Win32API::Registry::regLastError()."\n";
	return $nbSubKeys;
}

sub _valueCounter {
	my $opened_key = shift;
	my $nbValues;
	Win32API::Registry::RegQueryInfoKey($opened_key, [], [], [], [], [], [], $nbValues, [], [], [], [])
		or die "RegQueryInfoKey impossible de compter le nombre de valeurs".Win32API::Registry::regLastError()."\n";
	return $nbValues;
}

sub _enumSubKeyName {
	my ($opened_key, $index) = @_;
	my $subKeyName;
	Win32API::Registry::RegEnumKeyEx($opened_key, $index, $subKeyName, [], [], [], [], []);
	return $subKeyName;
}

sub _enumValue {
	my ($opened_key, $index) = @_;
	my ($name, $type, $data);
	Win32API::Registry::RegEnumValue($opened_key, $index, $name, [], [], $type, $data, 0)
		or die "RegEnumValue impossible de r�cup�rer le nom, le type et le contenue de la valeur\n".Win32API::Registry::regLastError()."\n";
	return ($name, $type, $data);
}

sub _getRegistryKeyValue {
	my ($opened_key, $value) = @_;
	my ($type, $data);
	Win32API::Registry::RegQueryValueEx($opened_key, $value, [], $type, $data, []);
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
				if($subKeyName) {
					_scanRegistry($opened_key, $subKeyName, $res, $fullPath."/".$subKeyName);
				}
			}
		}
		my $values = _getAllRegistryKeyValues($opened_key);
		$fullPath =~ s/\\\\/\//g;
		$res->{$fullPath} = $values;
		_closeKey($opened_key);
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
	$appName =~ tr/A-Z/a-z/;
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

##############################################################################
##############################################################################
#	Gestion des cl�s de registre (cr�ation, suppression et modification)
##############################################################################
##############################################################################

sub _createKey {
	my ($opened_key, $newSubKey) = @_;
	my $newKey;
	#Mettre les bons droits � la place de $uAccess
	Win32API::Registry::RegCreateKeyEx($opened_key, $newSubKey, 0, "", [], $uAccess, [], $newKey, Win32API::Registry::REG_CREATED_NEW_KEY)
		or die "Impossible de cr�er une cl� $newSubKey\n".Win32API::Registry::regLastError()."\n";
	return $newKey;
}

sub _setKeyValue {
	my ($opened_key, $value, $type, $data) = @_;
	Win32API::Registry::RegSetValueEx( $opened_key, $value, 0, $type, $data, 0)
		or die "Impossible de cr�er la valeur $value pour la cl� $opened_key\n".Win32API::Registry::regLastError()."\n";
	return 1;
}

sub _deleteKey {
	my ($opened_key, $subKey) = @_;
	Win32API::Registry::RegDeleteKey($opened_key, $subKey)
		or die "Impossible de supprimer la cl� $subKey\n".Win32API::Registry::regLastError()."\n";
	return 1;
}

sub _deleteValues {
	my ($opened_key, $value) = @_;
	Win32API::Registry::RegDeleteValue($opened_key, $value)
		or die "Impossible de supprimer la valeur $value de la cl� $opened_key\n".Win32API::Registry::regLastError()."\n";
	return 1;
}

#return 1: si cl� cr��
#return 0: si cl� modifi�e car existante
#return -1: si impossible de cr�er ou modifier
sub createOrReplaceKey {
	my ($root, $key) = _transformRegistryString(shift);
	my $values = shift || {};
	my $opened_key = _openKey($root, $key, KEY_WRITE_ALL);
	if(!$opened_key) {
		$opened_key = _openKey($root, "", KEY_WRITE_ALL);
		if($opened_key) {
			my $newKey = _createKey($opened_key, $key);
			foreach (keys(%$values)) {
				_setKeyValue($newKey, $values->{'name'}, $values->{'type'}, $values->{'data'});
			}
			Win32API::Registry::RegFlushKey($newKey);
			_closeKey($newKey);
		} else {
			die "Impossible d'ouvrir la cl� $root en �criture\n".Win32API::Registry::regLastError()."\n";
		}
		_closeKey($opened_key);
		return 1;
	} else {
		#Il faut �um�rer toutes les cl�s de $opened_key et les comparer aux nouvelles valeurs
		#pour pross�der au changements (cr�ation de valeur, suppression ou mise � jour)
		#Voir ci n�cessaire
		foreach (keys(%$values)) {
			_setKeyValue($opened_key, $values->{'name'}, $values->{'type'}, $values->{'data'});
		}
		Win32API::Registry::RegFlushKey($newKey);
		_closeKey($opened_key);
		return 0;
	}
	return -1;
}

sub deleteKey {
	my ($root, $key) = _transformRegistryString(shift);
	my $opened_key = _openKey($root, $key, KEY_WRITE_ALL);
	if($opened_key) {
		_closeKey($opened_key);
		$opened_key = _openKey($root, "", KEY_WRITE_ALL);
		if($opened_key) {
			_deleteKey($opened_key, $key);
		} else {
			die "Impossible d'ouvrir $root en �criture\n".Win32API::Registry::regLastError()."\n";
		}
		_closeKey($opened_key);
		return 1;
	} else {
		die "La cl� $root\\$key n'existe pas\n".Win32API::Registry::regLastError()."\n";
	}
	return 0;
}

##############################################################################
##############################################################################
#	Sauvegarde des cl�s de registre
##############################################################################
##############################################################################





##############################################################################
##############################################################################
1;
__END__