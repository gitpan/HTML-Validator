require 5.004;
use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME         => 'HTML::Validator',
	      VERSION_FROM => 'Validator.pm',
	      PM           => { "Validator.pm" => '$(INST_LIBDIR)/Validator.pm'},	
	      EXE_FILES    => [ 'bin/validate' ],
	      PREREQ_PM    => { LWP => 5.36, },
	      dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	     );
