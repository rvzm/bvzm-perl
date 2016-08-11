use Net::IRC;

$server = 'localhost';
$channel = '#bvzm-project';
$botnick = 'pvzm';
$password = '';
$botadmin = 'rvzm';
$version = "0.1";

$irc = new Net::IRC;

$conn = $irc->newconn(Nick => $botnick,
     Server => $server, Port => 6667);

$conn->add_global_handler('376', \&on_connect);
$conn->add_global_handler('disconnect', \&on_disconnect);
$conn->add_global_handler('kick', \&on_kick);
$conn->add_global_handler('msg', \&on_msg);
$conn->add_global_handler('public', \&on_pub);
$conn->add_global_handler('cversion', \&ctcp_v);

$irc->start;

sub on_connect {
     $self = shift;
     $self->privmsg('nickserv', "identify $password");
     $self->join($channel);
}

sub on_disconnect {
     $self = shift;
     $self->connect();
}

sub on_kick {
     $self = shift;
     $self->join($channel);
     $self->privmsg($channel, "Please don't kick me!");
}

sub on_msg {
     $self = shift;
     $event = shift;

     #if ($event->nick eq $botadmin) {
          foreach $arg ($event->args) {
               if ($arg =~ m/uptime/) {
                    @output = `uptime`;
                    foreach $line (@output) {
                         $self->notice($event->nick, $line);
                    }
               }
          }
     #}
	 
}
sub ctcp_v {
	$self = shift;
	$event = shift;
	foreach $arg ($event->args) {
		print $arg;
		if ($arg = VERSION) {
			$self->notice($event->nick,"bvzm perl bot v$version");
		}
	}
}
sub on_pub {
	$self = shift;
	$event = shift;
	foreach $arg ($event->args) {
		if ($arg =~ m/\@version/) {
			$self->privmsg($channel,"bvzm perl bot v$version");
		}
		if ($arg =~ m/\@sys/) {
			@output = `uptime`;
			foreach $line (@output) {
				$self->privmsg($channel, $line);
			}
		}
		if ($arg =~ m/\@quit/) {
			if ($event->nick eq $botadmin) {
				$self->quit;
				die;
			}
		}
		if ($arg =~ m/\@date/) {
			@output = `date`;
			foreach $line (@output) {
				$self->privmsg($channel, $line);
			}
		}
	}
}
