#!C:\Strawberry\perl\bin\perl -w
use strict;
use Data::Dumper;
use Registre;
use FileTools;

=head1
my $path = "C:\\Program Files (x86)\\Steam\\SteamApps\\common\\Saints Row IV";
my %res;
FileTools::giveFilesInDirectory($path, \%res);
foreach my $p (keys(%res)) {
	print "$p\n";
	my $subRes = $res{$p};
	foreach (keys(%$subRes)) {
		print "\t$_\n\t$subRes->{$_}\n";
	}
}
print scalar(keys(%res))."\n";
=cut

my $exe = "C:\\Users\\romain\\Downloads\\npp.6.6.9.Installer.exe";
my $save = Registre::scanRegistry("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/");

my $res = `$exe`;
print $res;

my $save2 = Registre::scanRegistry("LMachine/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/");
my $diff = Registre::diffRegistry($save, $save2);

print "Delete\n".Dumper($diff->{'delete'});
print "Update\n".Dumper($diff->{'updatings'});
print "New\n".Dumper($diff->{'news'});

my $installInforamtions = Registre::installLocation('notepad++');
print Dumper($installInforamtions);
