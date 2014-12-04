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

Package<RegistryKey> - module de repr�sentation d'une cl� de registre

=head1 SYNOPSIS

use::strict;

=head1 DESCRIPTION

L'objet RegistryKey repr�sente l'�tat d'une cl� de registre.
Il poss�de :

=head1 ATTRIBUTS

=head2 _name
Cet attribut correspond au nom de la cl� de registre.

=head2 _fullName
Cet attribut correspond au nom complet de la cl�. Cela s'en va de la racine HKEY_*
jusqu'au nom de la cl�.

=head2 _values
Cet attribut repr�sente toutes les valeurs d'une cl�. C'est une table de hachage o�
chaque cl� est le nom de la valeur. La valeur associ� est aussi est une table de hachage
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
Cet attribut indique si la cl� est une feuille ou non. C'est-�-dire si elle ne poss�dent aucune sous cl�s.

=head1 ATUTEUR

romain huret

=cut

1;
__END__