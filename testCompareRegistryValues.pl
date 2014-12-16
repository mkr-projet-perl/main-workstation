#!C:\Dwimperl\perl\bin\perl
use strict;
use Data::Dumper;
use Registre;

my $registre1 = 
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

my $registre2 =
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

print "Test 1\n";
print "---------------------------\n";
my $isDiff = Registre::_compareRegistryKey($registre1, $registre2);
print "Expected 1 is $isDiff\n";
print "\n\n";

$registre1 = 
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

$registre2 =
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '1111'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

print "Test 1\n";
print "---------------------------\n";
$isDiff = Registre::_compareRegistryKey($registre1, $registre2);
print "Expected 0 is $isDiff\n";
print "\n\n";

$registre1 = 
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

$registre2 =
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

print "Test 1\n";
print "---------------------------\n";
$isDiff = Registre::_compareRegistryKey($registre1, $registre2);
print "Expected 0 is $isDiff\n";
print "\n\n";

$registre1 = 
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

$registre2 =
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

print "Test 1\n";
print "---------------------------\n";
$isDiff = Registre::_compareRegistryKey($registre1, $registre2);
print "Expected 0 is $isDiff\n";
print "\n\n";

$registre1 = 
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '1111'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

$registre2 =
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

print "Test 1\n";
print "---------------------------\n";
$isDiff = Registre::_compareRegistryKey($registre1, $registre2);
print "Expected 0 is $isDiff\n";
print "\n\n";

$registre1 = 
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

$registre2 =
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		},
		'valueName3' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> 'path'
		}
};

print "Test 1\n";
print "---------------------------\n";
$isDiff = Registre::_compareRegistryKey($registre1, $registre2);
print "Expected 0 is $isDiff\n";
print "\n\n";

$registre1 = 
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		},
		'valueName3' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> 'path'
		}
};

$registre2 =
{
		'valueName1' =>
		{
			'type'	=> 'REG_SZ',
			'data'	=> '0000'
		},
		'valueName2' =>
		{
			'type'	=> 'REG_DWORD',
			'data'	=> '0x00000001'
		}
};

print "Test 1\n";
print "---------------------------\n";
$isDiff = Registre::_compareRegistryKey($registre1, $registre2);
print "Expected 0 is $isDiff\n";
print "\n\n";

__END__