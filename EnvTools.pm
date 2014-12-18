#!C:\Dwimperl\perl\bin\perl -w
package EnvTools;
use strict;
use Data::Dumper;

my $_env =
{
	$ENV{'USERPROFILE'} 		=> '%USERPROFILE%',
	$ENV{'WINDIR'}				=> '%WINDIR%',
	$ENV{'ProgramData'}			=> '%PROGRAMDATA%',
	$ENV{'ProgramFiles'}		=> '%PROGRAMFILE%',
	$ENV{'ProgramFiles(x86)'}	=> '%PROGRAMFILE86%',
	$ENV{'TEMP'}				=> '%TEMP%',
	$ENV{'USERNAME'}			=> '%USERNAME%'
};

foreach (keys(%$_env)) {
	delete $_env->{$_} if('' eq $_);
}

sub _getEnv {
	my $var = shift;
	return $_env->{$var};
}

sub transformVarToEnv {
	my $var = shift;
	my $tmp_var = $$var;
	$tmp_var =~ s/\//\\/g;
	foreach (keys(%$_env)) {
		if(index($tmp_var,$_)==0) {
			my $n_var = _getEnv(substr($tmp_var, 0, length($_)));
			substr($$var, 0, length($_)) = $n_var;
			last;
		}
	}
}

sub transformEnvToVar {
	my $var = shift;
	my $tmp_var = $$var;
	$tmp_var =~ s/\//\\/g;
	foreach (keys(%$_env)) {
		if(index($tmp_var,$_env->{$_})==0) {
			my $n_var = $_;
			$n_var =~ s/\\/\//g;
			substr($$var, 0, length($_env->{$_})) = $n_var;
			last;
		}
	}
}

1;
__END__