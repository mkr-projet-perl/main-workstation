#!C:\Dwimperl\perl\bin\perl
use strict;
use Data::Dumper;
use Store;
use Registre;
use FileTools;

my $refDiffScan = Store::retrieve_data(Store::MAKE_CONFIG_FILE_SYSTEM);
my $refDiffFile = Store::retrieve_data(Store::MAKE_CONFIG_REGISTRY);

if(Registre::makeCreateConfig($refDiffScan->{'news'}) && 
	FileTools::makeCreateConfig($refDiffFile->{'new'})) {
	
	print "Fichier prêt au déploiement\n";
		
}
print "Les fichiers de configuration ne sont pas créés\n";
print "Vérifier les chemins ! \n";

__END__