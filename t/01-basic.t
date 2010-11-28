use strict;
use warnings;

use Test::More import => ['!pass'];

use Dancer;
use Dancer::Test;

use t::lib::TestApp;
use XML::Feed;

plan tests => 32;

my ($res, $feed);

eval { $res = dancer_response(GET => '/feed'); };
like $@, qr/format is missing/;

for my $format (qw/atom rss/) {
    for my $route ("/feed/$format", "/other/feed/$format") {
        ok ($res = dancer_response(GET => $route));
        is ($res->{status}, 200);
        is ($res->header('Content-Type'), "application/$format+xml");
        ok ( $feed = XML::Feed->parse( \$res->{content} ) );
        is ( $feed->title, 'TestApp with ' . $format );
        my @entries = $feed->entries;
        is (scalar @entries, 10);
        is ($entries[0]->title, 'entry 1');
    }
}

eval { $res = dancer_response(GET => '/feed/foo')};
like $@, qr/unknown format/;

setting plugins => { Feed => { format => 'atom' } };
ok ($res = dancer_response(GET => '/feed'));
is ($res->header('Content-Type'), 'application/atom+xml');
