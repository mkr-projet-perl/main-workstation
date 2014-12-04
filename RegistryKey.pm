#!C:\Strawberry\perl\bin\perl -w
package RegistryKey;
use strict;

sub new {
	my ($classe, $ref_args) = @_;
	$classe = ref($classe) || $classe;
	
	my $self = {};
	bless($self, $classe);
	
	$self->{_name}				= $ref_args->{name};
	$self->{_fullName}			= $ref_args->{fullName};
	$self->{_values}			= $ref_args->{registryValues};
	$self->{_isALeaf}			= $ref_args->{isALeaf};
	
	return $self;
}

=pod

=encoding utf8

=head1 REGISTRYKEY

Package<RegistryKey> - module de représentation d'une clé de registre

=head1 SYNOPSIS

use::strict;

=head1 DESCRIPTION

L'objet RegistryKey représente l'état d'une clé de registre.
Il possède :

=head1 ATTRIBUTS

=head2 _name
Cet attribut correspond au nom de la clé de registre.

=head2 _fullName
Cet attribut correspond au nom complet de la clé. Cela s'en va de la racine HKEY_*
jusqu'au nom de la clé.

=head2 _values
Cet attribut représente toutes les valeurs d'une clé. C'est une table de hachage où
chaque clé est le nom de la valeur. La valeur associé est aussi est une table de hachage
contenant le type de la valeur et son contenue.
	_values => {
		'.bmp' => {
			'type' 		=> REG_SZ,
			'Content'	=> 'PBrush'
		},
		'.dib' => {
			'type'		=> REG_SZ,
			'Content'	=> 'PBrush'
		},
		...
	}

=head2 _isALeaf
Cet attribut indique si la clé est une feuille ou non. C'est-à-dire si elle ne possèdent aucune sous clés.

=head1 ATUTEUR

romain huret

=cut

1;
__END__