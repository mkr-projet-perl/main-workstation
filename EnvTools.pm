#!C:\Dwimperl\perl\bin\perl -w
package EnvTools;
use strict;

sub _transformVarToEnv {
	my $var = shift;
	my @tabs;
	foreach (keys(%ENV)) {
		my $e = $ENV{$_};
		$e =~ s/\\/\//g;
		if(index($$var, $e) == 0) {
			push @tabs, $e;
		}
	}
	my $value = (sort({ !(($a =~ tr/\//\//) <=> ($b =~ tr/\//\//)) } @tabs))[0];
	print "$value\n";
	
}

sub _transformEnvToVar {
	my $var = shift;
	foreach (keys(%ENV)) {
		if(index($var, $_) == 0) {
			substr($var, 0, length($_) -1) = $_;
		}
	}
}


sub encodeEnv {
	my $ref = shift;
	map { _transformVarToEnv(\$_) } keys(%$ref);
}

sub decodeEnv {
	my $ref = shift;
	map { _transformEnvToKeyVar($_) } keys(%$ref);
}

1;
__END__