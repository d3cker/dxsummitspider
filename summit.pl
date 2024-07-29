#
# DXSummit.fi for DXSpider
# by Bart SP6XD
# Developed for DXSpider node: telnet://dxcluster.sp6pws.pl:7300
# No rights reserved, I don't care.
# Use on your own risk.
#
# usage: 
#      summit [noat|addcomment] - show DXSummit spots
#      summit noat - removes `-@` suffix from callsigns
#      summit addcomment - adds "[DXSummit]" to the info 
#      It's possible to use "noat" and "addcomment" at the same time
#

use strict;
use warnings;
use LWP::UserAgent;
use JSON;

use Time::Piece;
use Time::Seconds;
use DXChannel;
use DXCommandmode;

my ($self, $line) = @_;

# Some security check upfront. Only crontab and sysop in the console may call that one
if ($self->priv < 9) {
    LogDbg('DXCommand', $self->call . " attempted to call DXSpider");
    return (1, $self->msg('e5'));
}

# Since DXSummit grabs spots from the cluster... 
# .. I think it's ok to import spots from DXsummit
my $url = 'http://www.dxsummit.fi/api/v1/spots';

# Create a user agent object
my $ua = LWP::UserAgent->new(
    ssl_opts => {
	verify_hostname => 1,
	SSL_verify_mode => 0x00
    }
);

# Send a GET request to the endpoint
my $response = $ua->get($url);

# Check the response
if ($response->is_success) {
    # Parse the JSON response
    my $json = JSON->new->utf8->decode($response->content);

    # Process each entry in the JSON array
    foreach my $entry (@$json) {
        # Extract the required fields
        my $de_call = $entry->{de_call};
	# Process web spots only "-@"
	if ($de_call =~ /-\@$/) {
            my $frequency = $entry->{frequency} // 0;
            my $dx_call = $entry->{dx_call} // '';
            my $info = $entry->{info} // '';
            my $time = $entry->{time} // '';

	    #Check for parameters
	    if(length($line) != 0) {
		foreach my $element (split ' ', $line) {
		    if ($element eq "noat") {
			$de_call = substr($de_call, 0, -2);

		    }
		    if ($element eq "addcomment") {
			$info = "$info [DXSummit]";
		    }

		}
	    }
            # Format date for condition check
	    my $temp_date = Time::Piece->strptime($time, '%Y-%m-%dT%H:%M:%S');
	    my $current_epoch = time();

	    # Let's make it 61 seconds 
	    # I'd rather duplicate a spot than loose it
	    if(($current_epoch - $temp_date->epoch) < 61) {
		# Send DXSummit.fi spots message to all users 
                # I'm not familiar with DXSpider code enough to assess 
                # whether it's a dirty hack or not. I think it's a dirty hack. 
		foreach my $dxchan (DXChannel->get_all()) {
		    if ($dxchan->is_user) {
			DXCommandmode::dx_spot($dxchan ,"", "" , $frequency , $dx_call, $temp_date->epoch, $info, $de_call);
		    }
		}
	    } 
	}
    }
} else {
    # Print an error message if the request failed
    die "HTTP request failed: " . $response->status_line;
}

