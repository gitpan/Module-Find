package Module::Find;
use strict;
# $Id: Find.pm,v 1.3 2004/06/17 00:10:48 comdog Exp $

=head1 NAME

Module::Find - Search @INC for libraries without loading them

=head1 SYNOPSIS

	use Module::Find qw(find_module);

	# find the first CGI.pm
	my $location  = find_module( "CGI" );

	# find all of them
	my @loactions = find_module( "CGI" );

	# find module directories
	my @directories = find_module_dirs( "Test" );

	# find modules under a namespace
	my @modules = find_modules_under( "Test" );

=head1 DESCRIPTION

Module::Find goes through the directories in @INC and finds the
occurances of the named module or library.  It can return the
first location it finds or all the location it finds.  It does
not attempt to load the modules.

=head2 Functions

=over 4

=item find_module( MODULE [, ARRAY] )

Given MODULE, return a list of all of its installed locations under
the directories in ARRAY (or @INC by default).  In scalar context it
returns the first installed location, which should be the same one
that perl finds first.

=item find_module_dirs( NAMESPACE [, ARRAY] )

Given NAMESPACE (not necessarily a complete module name), find all
directories under those in ARRAY (or @INC by default ) that contain
that namespace. It returns a list of directory names.

=item find_modules_under( NAMESPACE [, ARRAY] )

Like find_module_dirs, but returns all of the modules under
the same directories. It returns a list of module names (i.e.
Foo::Bar).

For instance, if I wanted to find all the modules under the
Module::Release namespace (so I could load them all), I could:

	foreach my $module ( find_modules_under( "Module::Release" ) )
		{
		require $module;
		}

=back

=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	http://sourceforge.net/projects/brian-d-foy/

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHORS

brian d foy, E<lt>bdfoy@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2004 brian d foy.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use base qw(Exporter);
use vars qw($VERSION @EXPORT_OK);

use File::Spec::Functions qw(catfile splitdir);

$VERSION = "0.1_1";

sub _module_find
	{
	my $module = shift;

	my $dirs = @_ ? \@_ : \@INC;

	my @paths = ();

	foreach my $dir ( @$dirs )
		{
		my $path = catfile( $dir, $module );

		push @paths, $path if -e $path;
		}

	return unless( @paths );
	if( wantarray ) { @paths } else { $paths[0] }
	}

sub find_modules
	{
	_module_find( _module2path( $_[0] ) )
	}

sub find_module_dirs
	{
	_module_find( _module2dir( $_[0] ) )
	}

sub find_modules_under
	{
	require File::Find;
	my @dirs = _module_find( _module2dir( $_[0] ) );

	my( @files, @modules ) = ();
	my $wanted = sub { no warnings; push @files, $File::Find::name if /\.pm/ };

	foreach my $dir ( @dirs )
		{
		@files = ();
		File::Find::find( $wanted, $dir );

		push @modules, map { s/^$dir/./; catfile( $_[0], $_ ) } @files;
		}

	@modules = map { my @p = splitdir( $_ ); $p[-1] =~ s/\.pm$//; join "::", @p }
		@modules;
	}

sub _module2path
	{
	my @parts = split /::/, $_[0];

	$parts[-1] .= ".pm";

	catfile( @parts );
	}

sub _module2dir
	{
	catfile( split /::/, $_[0] );
	}

1;
