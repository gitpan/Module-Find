# $Id: load.t,v 1.1.1.1 2004/06/16 23:24:33 comdog Exp $

BEGIN {
	our @modules = qw(
		Module::Find
		);
	}
	
use Test::More tests => scalar @modules;

foreach my $module ( @modules )
	{	
	print "bail out! [$module] has problems\n" 
		unless use_ok( $module );
	}
