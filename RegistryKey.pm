#!C:\Strawberry\perl\bin\perl -w
package RegistryKey;
use strict;

sub new {
	my ($classe, $ref_args) = @_;
	$classe = ref($classe) || $classe;
	
	my $self = {};
	bless($self, $classe);
	
	$self->{_root}				= $ref_args->{root};
	$self->{_registryKeyName}	= $ref_args->{registryKeyName};
	$self->{_registryKeyValues}	= $ref_args->{registryValues};
	
	return $self;
}

sub getName {
	my $self = shift;
	return $self->{_registryKeyName};
}

sub getRoot {
	my $self = shift;
	return $self->{_root};
}

sub setType {
	my ($self, $type) = @_;
	$self->{type} = $type;
	return;
}

sub getInstallLocation {
	my $self = shift;
	if(defined $self->{_registryKeyValues}) {
		return $self->{_registryKeyValues}->{_installLocation};
	}
	return undef;
}

sub getUninstallString {
	my $self = shift;
	if(defined $self->{_registryKeyValues}) {
		return $self->{_registryKeyValues}->{_uninstallString};
	}
	return undef;
}

sub getDisplayIcon {
	my $self = shift;
	if(defined $self->{_registryKeyValues}) {
		return $self->{_registryKeyValues}->{_displayIcon};
	}
	return undef;
}

1;
__END__