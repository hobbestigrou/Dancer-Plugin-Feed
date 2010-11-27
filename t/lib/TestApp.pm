package t::lib::TestApp;

use Dancer;
use Dancer::Plugin::Feed;

get '/feed' => sub {
    create_feed(
        title => 'this is a test',
        entries => [
            {title => 'first entry'}
        ],
    );
};

get '/feed/:format' => sub {
    my @entries = map { { title => "entry $_" } } ( 1 .. 10 );

    my $feed = create_feed(
        format  => params->{format},
        title   => 'TestApp',
        entries => \@entries,
    );
    return $feed;
};

1;
