#!C:\Dwimperl\perl\bin\perl
use strict;
use Data::Dumper;
use Store;
use MyConfig;

my $refDiffScan = Store::retrieve_data(Store::MAKE_CONFIG_FILE_SYSTEM);
my $refDiffFile = Store::retrieve_data(Store::MAKE_CONFIG_REGISTRY);

if(MyConfig::makeConfig($refDiffScan->{'news'}, Store::DIR) && 
	MyConfig::makeConfig($refDiffFile->{'new'}, Store::DIR)) {
	
	print "Fichier prêt au déploiement\n";
		
}
print "Les fichiers de configuration ne sont pas créés\n";
print "Vérifier les chemins ! \n";

__END__