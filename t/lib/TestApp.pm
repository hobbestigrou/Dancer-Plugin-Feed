package t::lib::TestApp;

use Dancer;
use Dancer::Plugin::Feed;

get '/feed' => sub {
    create_feed(
        title   => 'this is a test',
        entries => [ { title => 'first entry' } ],
    );
};

get '/feed/:format' => sub {
    create_feed(
        format  => params->{format},
        title   => 'TestApp with ' . params->{format},
        entries => _get_entries(),
    );
};

get '/other/feed/rss' => sub {
    create_rss_feed(
        title   => 'TestApp with rss',
        entries => _get_entries(),
    );
};

get '/other/feed/atom' => sub {
    create_atom_feed(
        title   => 'TestApp with atom',
        entries => _get_entries(),
    );
};

sub _get_entries {
    [map { { title => "entry $_" } } ( 1 .. 10 )];
}

1;
