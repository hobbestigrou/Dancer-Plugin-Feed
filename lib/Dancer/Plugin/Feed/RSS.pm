package Dancer::Plugin::Feed::RSS

use strict;
use warnings;
use Dancer::Plugin::Feed;
use XML::RSS;
use DateTime;

my $settings = plugin_setting;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub write_rss {
    my $self = shift;
    
    my $rss = new XML::RSS (version => $settings->{version});

    my $file_name = $settings->{appdir} . $self->{file_name};
    delete $self->{file_name};

    $rss->channel($settings->{channel});

    if ( $settings->{image} ) {
        $rss->image($settings->{image});
    }

    $rss->add_item($self);

    $rss->save($file_name);
}

sub update_rss {
    my $self = shift;

    my $rss = new XML::RSS;
    $rss->parsefile($file_name);

    $rss->add_item($self);
    
    my $time = DateTime->from_epoch( epoch => time() );

    if ( $settings->{version} eq '1.0' ) {
        $rss->channel(dc => { 
            date      => DateTime->now();
            publisher => $self->{dc}->{creator};
            },
       );
    }
    $rss->save($file_name);
}

1;
