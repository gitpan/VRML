use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => "VRML",
	VERSION_FROM => "VRML.pm",
	DISTNAME => "VRML",
        dist => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
	clean    => { FILES => '*% */*% */*/*%' },
);
