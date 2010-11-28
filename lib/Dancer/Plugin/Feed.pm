package Dancer::Plugin::Feed;

use Dancer ':syntax';
use Dancer::Plugin;
use XML::Feed;

our $VERSION = '0.1';



my $ct = {
    atom => 'application/atom+xml',
    rss  => 'application/rss+xml',
};

my @feed_properties =
  qw/format title base link tagline description author language copyright self_link modified/;

my @entries_properties = qw/
  title base link content summary category tags author id issued modified
  /;

register create_feed => sub {
    my (%params) = @_;

    my $format = _validate_format(\%params);
    
    if ($format =~ /^atom$/i) {
        _create_atom_feed(\%params);
    }elsif($format =~/^rss$/i) {
        _create_rss_feed(\%params);
    }else{
        die "unknown format";
    }
};

register create_atom_feed => sub {
    my (%params) = @_;
    _create_atom_feed(\%params);
};

register create_rss_feed => sub {
    my (%params) = @_;
    _create_rss_feed(\%params);
};

sub _validate_format {
    my $params = shift;
    my $format = delete $params->{format};

    if (!$format) {
        my $settings = plugin_setting;
        $format = $settings->{format} or die "format is missing";
    }

    if ($format !~ /^(?:atom|rss)$/i) {
        die "unknown format";
    }
    return $format;
}

sub _create_feed {
    my ($format, $params) = @_;
    my $entries = delete $params->{entries};
    
    my $feed = XML::Feed->new($format);
    my $settings = plugin_setting;

    map {
        my $val = $params->{$_} || $settings->{$_};
        $feed->$_($val) if ($val);
    } @feed_properties;

    foreach my $entry (@$entries) {
        my $e = XML::Feed::Entry->new($format);

        map {
            my $val = $entry->{$_};
            $e->$_($val) if $val
        } @entries_properties;
        
        $feed->add_entry($e);
    }

    return $feed->as_xml;
}

sub _create_atom_feed {
    my $params = shift;
    content_type($ct->{atom});
    _create_feed('Atom', $params);
}

sub _create_rss_feed {
    my $params = shift;
    content_type($ct->{rss});
    _create_feed('RSS', $params);
}

register_plugin;

=head1 NAME

Dancer::Plugin::Feed - easy to generate feed rss or atom for Dancer applications.

=head1 SYNOPSIS

    use Dancer;
    use Dancer::Plugin::Feed;

    get '/feed/:format' => sub {
      my @entries = map { { title => "entry $_" } } ( 1 .. 10 );

      my $feed = create_feed(
        format  => params->{format},
        title   => 'TestApp',
        entries => \@entries,
      );
      return $feed;
    };

    dance;

=head1 DESCRIPTION

Provides an easy generate feed rss or atom keyword within your L<Dancer> application. This module relies on L<XML::Feed>. Please, consult the documentation of L<XML::Feed> and L<XML::Feed::Entry>.

=head1 CONFIGURATION

     plugins:
         Feed:
             version: '1.0'
             channel:
                 title: 'Feed title'
                 link: 'http://your_web_site.com'
                 description: 'the one-stop-shop for all your Linux software needs'
                 dc:
                     date: '2000-08-23T07:00+00:00'
                     subject: 'Linux Software'
                     creator: 'scoop@freshmeat.net'
                     publisher:'scoop@freshmeat.net'
                     rights: 'Copyright 1999, Freshmeat.net'
                     language: 'en-us'
                   syn:
                     updatePeriod: "hourly",
                     updateFrequency: "1",
                     updateBase: "1901-01-01T00:00+00:00",

             #The title, link, and description, are required for RSS 1.0. language is required for RSS 0.91. Version are required for all version. The other parameters are optional for RSS 0.91 and 1.0. 

=head1 FUNCTIONS

=head2 create_feed

This function returns a XML feed. Accepted parameters are :

=over 4

=item format (required)

The B<Content-Type> header will be set to the appropriate value

=item title

=item base

=item link

=item tagline

=item description

=item author

=item language

=item copyright

=item self_link

=item modified

=back

=head1 AUTHOR

Natal Ngétal, C<< <hobbestigrou@erakis.im> >>

=head1 CONTRIBUTING

This module is developed on Github at:

L<http://github.com/hobbestigrou/Dancer-Plugin-Feed>

Feel free to fork the repo and submit pull requests

=head1 ACKNOWLEDGEMENTS

Alexis Sukrieh and Franck Cuny

=head1 BUGS

Please report any bugs or feature requests in github.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::Feed

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Natal Ngétal.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 SEE ALSO

L<Dancer>
L<XML::RSS>
l<XML::ATOM>

=cut 

1;
