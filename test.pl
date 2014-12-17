#!C:\Dwimperl\perl\bin\perl -w
use strict;
use Data::Dumper;
use Registre;
use FileTools;


# my $exe = "C:\\Users\\romain\\Downloads\\npp.6.6.9.Installer.exe";
# my $save = Registre::scanRegistry("LMachine/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall/");
# print "Nombre de clefs avant installation ".scalar(keys(%$save))."\n";

# open(EXE, "$exe|");

# close(EXE);

# my $save2 = Registre::scanRegistry("LMachine/SOFTWARE/Wow6432Node/Microsoft/Windows/CurrentVersion/Uninstall/");
# print "Nombre de clefs après installation ".scalar(keys(%$save2))."\n";
# my $diff = Registre::diffRegistry($save, $save2);

# print "Delete\n".Dumper($diff->{'delete'});
# print "Update\n".Dumper($diff->{'updatings'});
# print "New\n".Dumper($diff->{'news'});

# my $createdKey = Registre::createOrReplaceKey("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/test1");
# print "Created result $createdKey\n";
system ('perl ./testFullInstall.pl C:\\Users\\zen\\Downloads\\npp.6.7.Installer.exe');

__END__