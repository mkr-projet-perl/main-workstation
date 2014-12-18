#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use Registre;
use FileTools;
use EnvTools;
use File::Path;

my $files = FileTools::giveFilesInDirectory('C:/Program Files (x86)/SFR/Mediacenter Evolution');
print Dumper($files);

FileTools::makeCreateConfig($files, 'C:/Users/romain/Desktop/test.txt');

if(my $config = Registre::readConfig('C:/Users/romain/Desktop/test.txt')) {
	print Dumper($config);
	FileTools::loadCreateConfig($config);
}

__END__