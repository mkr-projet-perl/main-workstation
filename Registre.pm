#!C:\Strawberry\perl\bin\perl -w
package Registre;
use strict;
use Win32API::Registry 0.21 qw( :ALL );
use RegistryKey;

#Compte le nom de clé registre ouverte.
my $registryKeyCounter = 0;

sub new {
	my ($classe, $ref_args) = @_;
	$classe = ref($classe) || $classe;
	my $self = {};
	bless($self, $classe);
	
	#Indique si il y a une connexion sur une machine distante
	$self->{_isConnectedToRemote} = 0;
	
	return $self;
}

#################################
#Méthode privée au package
#################################

sub _setRegistryKey {
	my ($self, $key) = @_;
	if (defined $key) {
		$self->{_crtRegistryKey} = $key;
	}
	return;
}

sub _getRegistryKey {
	my $self = shift;
	return $self->{_crtRegistryKey};
}

sub _error {
	my $key = shift;
	die $key."\n".regLastError()."\n";
}


#Correspondance de la tête de la clé
#Ceci correspond au HKEY_*
my $_rootRegistryKey = {
	"LMachine"	=> HKEY_LOCAL_MACHINE,
	"Classes"	=> HKEY_CLASSES_ROOT,
	"CUser"		=> HKEY_CURRENT_USER,
	"Users"		=> HKEY_USERS,
	"CConfig"	=> HKEY_CURRENT_CONFIG,
	"PerfData"	=> HKEY_PERFORMANCE_DATA,
	"DynDat"	=> HKEY_DYN_DATA
};

sub _headCorrectRegistryKey {
	my $key = shift;
	
}

use constant KEY_READ32 => 0x0100;
use constant KEY_READ64 => 0x0200;

sub _openKey {
	my ($self,$key,$key_way) = @_;
	my $registry_key;
	if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, $key, 0, $key_way, $registry_key)) {
		return $registry_key;
	} else {
		$self->_error('Lecture impossible de la clé'.$key);
	}
}

sub _closeKey {
	 my ($self, $key) = @_;
	 if(RegCloseKey($key)) {
	 	return 1;
	 } else {
	 	$self->_error("Fermeture impossible de la clé ".$key);
	 }
}

sub _getValue {
	my ($self, $registry_key, $value) = @_;
	my ($type, $data);
	if(RegQueryValueEx( $registry_key, $value, [], $type, $data, [] )) { 
		return ($type, $data);
	} else {
		$self->_error("Récupération des valeurs impossible pour la clé ".$registry_key."\n");
	}
	return undef;
}

#####################################
# Méthodes publiques
#####################################

sub scanRegistry {
	my ($self, $refPathList, $savedRegistry) = @_;
	foreach my $crt_path (@$refPathList) {
		if((my $crt_key = $self->_open($crt_path, KEY_READ|KEY_READ64))) {
			if(ref($crt_key) eq "SCALAR") {
				
			} elsif(ref($crt_key) eq "HASH") {
				
			}
			$self->_close($crt_key);
		} else {
			$self->_error();
		}
	}
}

sub readRegistryKey {
	my ($self, $key) = @_;
}

sub writeRegistry {
	my ($self, $key) = @_;
}

sub deleteRegistry {
	my ($self, $key) = @_;
}

sub deleteRegistryKeyValues {
	my ($self, $key, $values) = @_;
}

sub updateRegistryKey {
	my ($self, $key, $values) = @_;
}

1;
__END__