#!C:\Dwimperl\perl\bin\perl -w
package Registre;
use strict;
use Win32API::Registry 0.24;
use Win32::TieRegistry;
use Data::Dumper;
use JSON;

########################################################################
#		Constante d'accès aux clés de registre 32 bits et 64 bits      #
########################################################################
use constant KEY_WOW64_64KEY => 0x0100;
use constant KEY_READ_ALL => Win32API::Registry::KEY_READ|KEY_WOW64_64KEY;
use constant KEY_WRITE_ALL => Win32API::Registry::KEY_WRITE|KEY_WOW64_64KEY;

########################################################################
#		Constante représentant les chemins de registre à explorer      #
########################################################################
use constant PATH_32_CURRENT_VERSION => "LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion";
use constant PATH_64_CURRENT_VERSION => "LMachine/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion";
use constant PATH_EXTENSION => "LMachine/SOFTWARE/Classes";

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
	0	=> 'REG_NONE',
	1	=> 'REG_SZ',
	2	=> 'REG_EXPAND_SZ',
	3	=> 'REG_BINARY',
	4	=> 'REG_DWORD',
	6	=> 'REG_LINK',
	7	=> 'REG_MULTI_SZ',
	9	=> 'REG_FULL_RESOURCE_DESCRIPTOR'
};

sub _transformRegistryString {
	my $str = shift;
	if($str =~ /(.+?)\/(.*)/) {
		if(defined $1 && defined $2) {
			my ($root, $sKey);
			$root = $_rootRegistryKey->{$1};
			$sKey = $2 if(defined $2);
			$sKey =~ s/\//\\\\/g;
			return ($root, $sKey);
		}
		return 0;
	}elsif($str =~ /(.+)(\/)?/) {
		if(defined $1) {
			my $root = $_rootRegistryKey->{$1} if(defined $1);
			return $root;
		}
		return 0;
	}
	return 0;
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
	Win32API::Registry::RegEnumValue($opened_key, $index, $name, [], [], $type, $data, 0);
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
				if(my $subKeyName = _enumSubKeyName($opened_key, $_)) {
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
			if($valuesA->{$_}->{'type'} ne $valuesB->{$_}->{'type'}) {
				$isSame = 0;
			}
			if($valuesA->{$_}->{'data'} != $valuesB->{$_}->{'data'} ||
				$valuesA->{$_}->{'data'} ne $valuesB->{$_}->{'data'}) {
				$isSame = 0;		
			}
		} else {
			$isSame = 0;
		} 
	}
	$isSame = 0 if(scalar(grep { !exists $valuesA->{$_} } keys(%$valuesB)));
	return $isSame;
}

sub scanRegistry {
	my $listPath = shift;
	my %res;
	if(!defined $listPath) {
		my ($root, $key) = _transformRegistryString(PATH_32_CURRENT_VERSION);
		print "$root\t$key\n";
		_scanRegistry($root, $key, \%res, PATH_32_CURRENT_VERSION);
	} else {
		foreach my $path (@$listPath) {
				my ($root, $key) = _transformRegistryString($path);
				print "$root\t$key\n";
				if(defined $root) {
					_scanRegistry($root, $key, \%res, $path);
				} else {
					print "$path n'est pas une clé valide\n";
				}
			}
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
			if(!_compareRegistryKey($oldRegistry->{$_}, $newRegistry->{$_})) {
				$updatings{$_} = $oldRegistry->{$_};
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
#	Gestion des clés de registre (création, suppression et modification)
##############################################################################
##############################################################################

sub _createKey {
	my ($opened_key, $newSubKey) = @_;
	my $newKey;
	Win32API::Registry::RegCreateKeyEx($opened_key, $newSubKey, 0, "", Win32API::Registry::REG_OPTION_NON_VOLATILE, Win32API::Registry::KEY_ALL_ACCESS, [], $newKey, [])
		or die "Impossible de créer une clé $newSubKey\n".Win32API::Registry::regLastError()."\n";
	return $newKey;
}

sub _setKeyValue {
	my ($opened_key, $value, $type, $data) = @_;
	Win32API::Registry::RegSetValueEx( $opened_key, $value, 0, $type, $data, 0)
		or die "Impossible de créer la valeur $value pour la clé $opened_key\n".Win32API::Registry::regLastError()."\n";
	return 1;
}

sub _deleteKey {
	my ($opened_key, $subKey) = @_;
	Win32API::Registry::RegDeleteKey($opened_key, $subKey)
		or die "Impossible de supprimer la clé $subKey\n".Win32API::Registry::regLastError()."\n";
	return 1;
}

sub _deleteValues {
	my ($opened_key, $value) = @_;
	Win32API::Registry::RegDeleteValue($opened_key, $value)
		or die "Impossible de supprimer la valeur $value de la clé $opened_key\n".Win32API::Registry::regLastError()."\n";
	return 1;
}

sub _transformRegistryToCreatingKey {
	return shift =~ m/(.+)\/(.*)/;
}

sub createOrReplaceKey {
	my $path = shift;
	my $values = shift || {};
	my ($s_root, $s_key) = _transformRegistryString($path);
	my %_valueTypeReverse = reverse %$_valueType;
	print "$path\n";
	print "------------\n";
	if(my $opened_key = _openKey($s_root, $s_key, KEY_WRITE_ALL)) {
		# print "Key existing -- insert values running...\n";
		foreach (keys(%$values)) {
			print "Create $_ with $values->{$_}->{'type'}, $values->{$_}->{'data'}\n";
			my $type = $_valueTypeReverse{$values->{$_}->{'type'}};
			_setKeyValue($opened_key, $_, $type, $values->{$_}->{'data'});
		}
		_closeKey($opened_key);
		return 0;
	} else {
		# print "Key not existing -- create key running...\n";
		my $opened_key = _openKey($s_root, "", KEY_WRITE_ALL);
		my $newKey = _createKey($s_root, $s_key);
		foreach (keys(%$values)) {
			print "Create $_ with $values->{$_}->{'type'}, $values->{$_}->{'data'}\n";
			my $type = $_valueTypeReverse{$values->{$_}->{'type'}};
			_setKeyValue($newKey, $_, $type, $values->{$_}->{'data'});
		}
		_closeKey($newKey);
		_closeKey($opened_key);
		return 1;
	}
}

sub selectDeletedKey {
	my $path = shift;
	my $deleteKey = shift;
	$path =~ s/\/+$//;
	my ($root, $key) = _transformRegistryString($path);
	if(my $opened_key = _openKey($root, $key, Win32API::Registry::KEY_ALL_ACCESS|KEY_WOW64_64KEY)) {
		if(my $nbSubKey = _subKeyCounter($opened_key)) {
			foreach (0..$nbSubKey-1) {
				my $subName = _enumSubKeyName($opened_key, $_);
				selectDeletedKey("$path/$subName", $deleteKey);
			}
		}
		_closeKey($opened_key);
		push @$deleteKey, $path;
	}
}

sub deleteKey {
	my $refTab = shift;
	foreach (@$refTab) {
		my ($root, $key) = _transformRegistryString($_);
		print "Delete $_\n";
		_deleteKey($root, $key);
	}
}

1;
__END__