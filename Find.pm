package Module::Find;

use 5.006001;
use strict;
use warnings;

use File::Find;

our $VERSION = '0.02';

our $basedir = undef;
our @results = ();
our $prune = 0;

our @ISA = qw(Exporter);

our @EXPORT = qw(findsubmod findallmod usesub useall);

=head1 NAME

Module::Find - Find and use installed modules in a (sub)category

=head1 SYNOPSIS

  use Module::Find;

  # use all modules in the Plugins/ directory
  @found = usesub Mysoft::Plugins;

  # use modules in all subdirectories
  @found = useall Mysoft::Plugins;

  # find all DBI::... modules
  @found = findsubmod DBI;

  # find anything in the CGI/ directory
  @found = findallmod CGI;

=head1 DESCRIPTION

Module::Find lets you find and use modules in categories. This can be very 
useful for auto-detecting driver or plugin modules. You can differentiate
between looking in the category itself or in all subcategories.

If you want Module::Find to search in a certain directory on your 
harddisk (such as the plugins directory of your software installation),
make sure you modify C<@INC> before you call the Module::Find functions.

=head1 FUNCTIONS

=over

=item C<@found = findsubmod Module::Category>

Returns modules found in the Module/Category subdirectories of your perl 
installation. E.g. C<findsubmod CGI> will return C<CGI::Session>, but 
not C<CGI::Session::File> .

=cut

sub findsubmod(*) {
	$prune = 1;
		
	return _find($_[0]);
}

=item C<@found = findallmod Module::Category>

Returns modules found in the Module/Category subdirectories of your perl 
installation. E.g. C<findallmod CGI> will return C<CGI::Session> and also 
C<CGI::Session::File> .

=cut

sub findallmod(*) {
	$prune = 0;
	
	return _find($_[0]);
}

=item C<@found = usesub Module::Category>

Uses and returns modules found in the Module/Category subdirectories of your perl 
installation. E.g. C<usesub CGI> will return C<CGI::Session>, but 
not C<CGI::Session::File> .

=cut

sub usesub(*) {
	$prune = 1;
	
	my @r = _find($_[0]);
	
	foreach (@r) {
		eval " require $_; import $_ ; ";
		die $@ if $@;
	}
	
	return @r;
}

=item C<@found = useall Module::Category>

Uses and returns modules found in the Module/Category subdirectories of your perl 
installation. E.g. C<useall CGI> will return C<CGI::Session> and also 
C<CGI::Session::File> .

=cut

sub useall(*) {
	$prune = 0;
	
	my @r = _find($_[0]);
	
	foreach (@r) {
		eval " require $_; import $_; ";
		die $@ if $@;
	}
	
	return @r;
}

# 'wanted' functions for find()
# you know, this would be a nice application for currying...
sub _wanted {
    (my $name = $_) =~ s|^$basedir/?||;
    return unless $name;

    if (-d && $prune) {
        $File::Find::prune = 1;
        return;
    }

    return unless /\.pm$/ && -r;

    $name =~ s|/|::|g;
    $name =~ s|\.pm$||;

    push @results, $name;
}


# helper functions for finding files

sub _find(*) {
    my ($category) = @_;
    return undef unless defined $category;

    (my $dir = $category) =~ s|::|/|g;

    my @dirs = map "$_/$dir", @INC;
    @results = ();

    foreach $basedir (@dirs) {
    	next unless -d $basedir;
    	
        find({wanted   => \&_wanted,
              no_chdir => 1}, $basedir);
    }

    @results = map "$category\::$_", @results;
    return @results;
}

=back

=head1 HISTORY

=over 8

=item 0.01, 2004-04-22

Original version; created by h2xs 1.22

=item 0.02, 2004-05-25

Added test modules that were left out in the first version. Thanks to
Stuart Johnston for alerting me to this.

=back

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Christian Renz, E<lt>crenz@web42.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Christian Renz <crenz@web42.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
