#!C:\Dwimperl\perl\bin\perl
use strict;
use Data::Dumper;
use Store;
use MyConfig;

my $refDiffScan = Store::retrieve_data(Store::COPY_DIFF_REGISTRY);
my $refDiffFile = Store::retrieve_data(Store::COPY_DIFF_FILE_SYSTEM);

if(MyConfig::makeConfig($refDiffScan->{'news'}, Store::DIR.'/'.Store::MAKE_CONFIG_REGISTRY) && 
	MyConfig::makeConfig($refDiffFile->{'new'}, Store::DIR.'/'.Store::MAKE_CONFIG_FILE_SYSTEM)) {
	
	print "Fichier prêt au déploiement\n";
		
}
print "Les fichiers de configuration ne sont pas créés\n";
print "Vérifier les chemins ! \n";

__END__