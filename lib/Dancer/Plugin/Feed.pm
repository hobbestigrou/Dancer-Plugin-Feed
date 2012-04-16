package Dancer::Plugin::Feed;

use Dancer ':syntax';
use Dancer::Plugin;
use Dancer::Exception qw(:all);
use XML::Feed;

our $VERSION = '0.6';

my $ct = {
    atom => 'application/atom+xml',
    rss  => 'application/rss+xml',
};

#Register exception
register_exception('FeedInvalidFormat',
    message_pattern => "Unknown format use rss or atom: %s"
);
register_exception('FeedNoFormat',
    message_pattern => "Format is missing"
);

my @feed_properties =
  qw/format title base link tagline description author id language copyright self_link modified/;

my @entries_properties =
  qw/title base link content summary category tags author id issued modified enclosure/;

register create_feed => sub {
    my (%params) = @_;

    my $format = _validate_format(\%params);

    if ($format =~ /^atom$/i) {
        _create_atom_feed(\%params);
    }elsif($format =~/^rss$/i) {
        _create_rss_feed(\%params);
    }else{
        raise FeedInvalidFormat => $format;
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
        $format = $settings->{format} or raise 'FeedNoFormat';
    }

    if ($format !~ /^(?:atom|rss)$/i) {
        raise FeedInvalidFormat => $format;
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

1;

=encoding UTF-8

=head1 NAME

Dancer::Plugin::Feed - easy to generate feed rss or atom for Dancer applications.

=head1 SYNOPSIS

    use Dancer;
    use Dancer::Plugin::Feed;
    use Try::Tiny;

    get '/feed/:format' => sub {
        my $feed;
        try {
            $feed = create_feed(
                format  => params->{format},
                title   => 'my great feed',
                entries => [ map { title => "entry $_" }, 1 .. 10 ],
            );
        }
        catch {
            my ( $exception ) = @_;

            if ( $exception->does('FeedInvalidFormat') ) {
                return $exception->message;
            }
            elsif ( $exception->does('FeedNoFormat') ) {
                return $exception->message;
            }
            else {
                $exception->rethrow;
            }
        };

        return $feed;
    };

    dance;

=head1 DESCRIPTION

Provides an easy way to generate RSS or Atom feed. This module relies on L<XML::Feed>. Please, consult the documentation of L<XML::Feed> and L<XML::Feed::Entry>.

=head1 CONFIGURATION

 plugins:
   Feed:
     title: my great feed
     format: Atom

=head1 FUNCTIONS

=head2 create_feed

This function returns a XML feed. All parameters can be define in the configuration

AcceptEd parameters are:

=over 4

=item format (required)

The B<Content-Type> header will be set to the appropriate value

=item entries

An arrayref containing a list of entries. Each item will be transformed to an L<XML::Feed::Entry> object. Each entry is an hashref. Some common attributes for these hashrefs are C<title>, C<link>, C<summary>, C<content>, C<author>, C<issued> and C<modified>. Check L<XML::Feed::Entry> for more details.

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

=head2 create_atom_feed

This method call B<create_feed> by setting the format to Atom.

=head2 create_rss_feed

This method call B<create_feed> by setting the format to RSS.

=head1 Exception

=over

=item FeedNoFormat

=item FeedInvalidFormat

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

Copyright 2010-2011 Natal Ngétal.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 SEE ALSO

L<Dancer>
L<XML::Feed>
L<XML::Feed::Entry>
