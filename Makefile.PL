use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => "VRML",
	VERSION_FROM => "VRML.pm",
	OBJ_EXT => "% */*% */*/*%",	# not fine, but needed for 'clean'
	DISTNAME => "VRML",
        dist => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
);
