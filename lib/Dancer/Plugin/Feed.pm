package Dancer::Plugin::Feed;

use strict;
use warnings;
use Dancer ':syntax';
use Dancer::Plugin;

=head1 NAME

Dancer::Plugin::Feed - easy to generate feed rss or atom 
for Dancer applications.

=cut

our $VERSION = '0.1';

my $settings = plugin_setting;

register generate_rss => sub {
    my ( $item_detail ) = @_;

    my $feed_rss = Dancer::Plugin::Feed::RSS->new($item_detail);

    if ( $settings->{version} eq '0.9' ) {
        if ( length($settings->{title}) > 40 ) {
            die 'The title cannot be more the 40 characters';
        }
        if ( length($settings->{link}) > 500 ) {
            die 'the link cannot be more the 500 characters';
        }
        if ( length($settings->{description}) > 500 ) {
            die 'the description cannot be more the 500 characters';
        }
    }
    
    if ( $settings->{version} eq '1.0' ) {
        if ( ! $settings->{title} || ! $settings->{link} 
             || ! $settings->{description} ) {
            die 'The title, link, and description, are required for RSS 1.0.';
        }
    }
    
    my $file_name = $settings->{appdir} . $item_detail->{file_name};
    
    if ( -e $file_name ) {
        $feed_rss->update_rss();
    }
    else {
        $feed_rss->write();
    }
};

register_plugin;

=head1 SYNOPSIS

    use Dancer;
    use Dancer::Plugin::Feed;

    get '/feed' => sub {
        my $add_item = {
            title        => "feed title",
            link         => "http://your_web_site.com/0101.html",
            description  => "the one-stop-shop for all your Linux software needs",
            dc => {
                subject  => "X11/Utilities",
                creator  => "Your name",
            },
            file_name => 'all.rdf'
        };

        my $error = generate_rss( $add_item );
    };
    
   get '/feed/:tag' => sub {
        my $add_item = {
            title        => "feed title",
            link         => "http://your_web_site.com/news/0101.html",
            description  => "the one-stop-shop for all your Linux software needs",
            dc => {
                subject  => "X11/Utilities",
                creator  => "Your Name",
            },
            file_name => "$tag.rdf"
        };

        my $error = generate_rss( $add_item );
    };

    
    dance;


=head1 DESCRIPTION

Provides an easy generate feed rss or atom 
keyword within your L<Dancer> application.

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
