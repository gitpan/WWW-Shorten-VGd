use strict;
use warnings;
use 5.006;

package WWW::Shorten::VGd;
BEGIN {
  $WWW::Shorten::VGd::VERSION = '0.001';
}
# ABSTRACT: shorten (or lengthen) URLs with http://v.gd


use base qw( WWW::Shorten::generic Exporter );
our @EXPORT = qw( makeashorterlink makealongerlink );
use Carp;
use HTML::Entities;


sub makeashorterlink {
    my $url = shift or croak 'No URL passed to makeashorterlink';
    my $ua = __PACKAGE__->ua();
    my $response = $ua->post('http://v.gd/create.php', [
        url => $url,
        source => 'PerlAPI-' . (defined __PACKAGE__->VERSION ? __PACKAGE__->VERSION : 'dev'),
        format => 'simple',
    ]);
    return unless $response->is_success;
    my $shorturl = $response->{_content};
    return if $shorturl =~ m/Error/;
    if ($response->content =~ m{(\Qhttp://v.gd/\E[\w_]+)}) {
        return $1;
    }
    return;
}


sub makealongerlink {
    my $url = shift or croak 'No v.gd key/URL passed to makealongerlink';
    my $ua = __PACKAGE__->ua();
    
    $url =~ s{\Qhttp://v.gd/\E}{}i;
    my $response = $ua->post('http://v.gd/forward.php', [
        shorturl => $url,
        source => 'PerlAPI-' . (defined __PACKAGE__->VERSION ? __PACKAGE__->VERSION : 'dev'),
        format   => 'simple',
    ]);
    # use Data::Dumper;
    # print STDERR Dumper $response;
    return unless $response->is_success;

    my $longurl = $response->{_content};
    return decode_entities($longurl);
}

1;



=pod

=encoding utf-8

=head1 NAME

WWW::Shorten::VGd - shorten (or lengthen) URLs with http://v.gd

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    use WWW::Shorten::VGd;
    use WWW::Shorten 'VGd';

    my $url = q{http://averylong.link/wow?thats=really&really=long};
    my $short_url = makeashorterlink($url);
    my $long_url  = makealongerlink($short_url); # eq $url

=head1 DESCRIPTION

A Perl interface to the web site L<http://v.gd>. v.gd simply maintains
a database of long URLs, each of which has a unique identifier. By default,
this URL shortening service will show you a preview page before redirecting
you. This can be turned off by setting a cookie at L<http://v.gd/previews.php>.

=head1 Functions

=head2 makeashorterlink

The function C<makeashorterlink> will call the v.gd web site passing
it your long URL and will return the shortened link.

=head2 makealongerlink

The function C<makealongerlink> does the reverse. C<makealongerlink>
will accept as an argument either the full TinyURL URL or just the
TinyURL identifier.

If anything goes wrong, then either function will return C<undef>.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<http://search.cpan.org/dist/WWW-Shorten-VGd/>.

The development version lives at L<http://github.com/doherty/WWW-Shorten-VGd>
and may be cloned from L<git://github.com/doherty/WWW-Shorten-VGd.git>.
Instead of sending patches, please fork this project using the standard
git and github infrastructure.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://github.com/doherty/WWW-Shorten-VGd/issues>.

=head1 AUTHOR

Mike Doherty <doherty@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Mike Doherty.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
