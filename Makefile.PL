# $Id: Makefile.PL,v 1.2 2004/06/17 00:11:51 comdog Exp $
use ExtUtils::MakeMaker;

eval "use Test::Manifest";
unless( $@ )
   {
   * ExtUtils::MM_Any::test_via_harness = sub
	   {
	   my($self, $perl, $tests) = @_;

	   return qq|\t$perl "-MTest::Manifest" | .
			qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			qq|'\$(INST_ARCHLIB)')"\n|;
	   }
   }
	   
WriteMakefile(
	'NAME'	       => 'Module::Find',
	'VERSION_FROM' => "lib/Find.pm",
		    	
	'PM' => {
        'lib/Find.pm'  => '$(INST_LIBDIR)/Find.pm',
    	},

	'MAN3PODS' => {
		'lib/Find.pm'    => '$(INST_MAN3DIR)/Module::Find.3',
		},

	clean => { FILES => '*.bak Module-Find-*' },
	);
