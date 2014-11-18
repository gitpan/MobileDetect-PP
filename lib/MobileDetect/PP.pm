# Copyleft 2014 Sebastian Enger 
# sebastian.enger at gmail - com
# All rights released.
package MobileDetect::PP;
#
#MobileDetect::PP - Perl detection mobile phone and tablet devices
#
#Thanks to:
#   https://github.com/serbanghita/Mobile-Detect/blob/master/Mobile_Detect.php
#	https://github.com/serbanghita/Mobile-Detect/blob/master/Mobile_Detect.json

use 5.006;
use strict;
use warnings FATAL => 'all';
use JSON;
use Data::Dumper;
use LWP::Protocol::https;
use LWP::UserAgent;

=head1 NAME

MobileDetect::PP - The great new MobileDetect::PP is finally available!

Perl Module for the PHP Toolchain Mobile Detect from https://github.com/serbanghita/Mobile-Detect

=head1 VERSION

Version 1.01

=cut

our $VERSION 					= '1.12';
use constant JSON_REMOTE_FILE 	=> 'https://raw.githubusercontent.com/serbanghita/Mobile-Detect/master/Mobile_Detect.json';
use constant JSON_LOCAL_FILE 	=> '/var/tmp/Mobile_Detect.json';

our @EXPORT = qw(is_phone is_tablet is_mobile_os is_mobile_ua detect_phone detect_tablet detect_mobile_os detect_mobile_ua);

=head1 SYNOPSIS

Check a given string against the Mobile Detect Library that can be found here: https://github.com/serbanghita/Mobile-Detect
I have prepared a Perl Version, because there is no such thing in perl and i also want to show my support for Mr. Șerban Ghiță
and his fine piece of PHP Software.

This is the Perl Version. You need to setup LWP with HTTPS Support before (needed to regulary update the Mobile_Detect.json file
from github).

Install needed modules example:
From the bash call :"cpan"
cpan [1] Promt: call "install JSON"
cpan [2] Promt: call "install JSON::XS"
cpan [3] Promt: call "install LWP::Protocol"
cpan [4] Promt: call "install LWP::Protocol::https"

Usage Example:

    #!/usr/bin/perl

	use MobileDetect::PP;

	my $obj 	= MobileDetect::PP->new(); 
	my $check 	= "Mozilla/5.0 (Linux; U; Android 4.1.2; nl-nl; SAMSUNG GT-I8190/I8190XXAME1 Build/JZO54K) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"; # Samsung Galaxy S3 Mini

	print "is_phone: 			".$obj->is_phone($check); print "\n";
	print "detect_phone: 		".$obj->detect_phone($check); print "\n";
	print "is_tablet: 			".$obj->is_tablet($check);print "\n";
	print "detect_tablet: 		".$obj->detect_tablet($check);print "\n";

	print "is_mobile_os: 		".$obj->is_mobile_os($check);print "\n";
	print "detect_mobile_os:	".$obj->detect_mobile_os($check);print "\n";
	print "is_mobile_ua: 		".$obj->is_mobile_ua($check);print "\n";
	print "detect_mobile_ua:	".$obj->detect_mobile_ua($check)."\n";

	exit;
=cut

sub new {
	my($class, %args) = @_;
	my $self 		= bless({}, $class);
	my $json 		= JSON->new();
	my $content 	= "";
	my $filestamp 	= -M JSON_LOCAL_FILE; 
	
	if ( (defined($filestamp) && $filestamp > 31) || !-e JSON_LOCAL_FILE ){
		unlink JSON_LOCAL_FILE;
	
		my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
		my $res = $ua->get(JSON_REMOTE_FILE);

		open my $handle, '>:encoding(UTF-8)', JSON_LOCAL_FILE or die "Can't open ".JSON_LOCAL_FILE." for reading: $!";
			print $handle $res->content;
		close $handle;
		$content = $res->content;
	} else {
		open my $handle, '<:encoding(UTF-8)', JSON_LOCAL_FILE or die "Can't open ".JSON_LOCAL_FILE." for reading: $!";
			local $/ = undef;
			$content = <$handle>;
		close $handle;
	}
	my $json_text = $json->allow_nonref->utf8->relaxed->decode($content);
	
	while (my($k, $v) = each (%{$json_text->{uaMatch}->{tablets}})){
		$self->{tablets}->{$k} = $v;
    }
	while (my($k, $v) = each (%{$json_text->{uaMatch}->{phones}})){
		$self->{phones}->{$k} = $v;
    } 
	while (my($k, $v) = each (%{$json_text->{uaMatch}->{browsers}})){
		$self->{browsers}->{$k} = $v;
    }
	while (my($k, $v) = each (%{$json_text->{uaMatch}->{os}})){
		$self->{os}->{$k} = $v;
    }
	return $self;
}

sub detect_phone(){
	my $self 	= shift;
	my $str 	= shift;
	#print "check string: $str\n";
	my $retVal  = 0;
	while (my($k1, $v1) = each (%{$self->{phones}})){
		if ($str =~ m/$v1/igs){
		#	print "have match: $k1\n";
			$retVal = $k1;
		} else {
		#	print "no match: $k1\n";
		}
	}
	return $retVal;
}
sub detect_tablet(){
	my $self 	= shift;
	my $str 	= shift;
	
	my $retVal  = 0;
	while (my($k2, $v2) = each (%{$self->{tablets}})){
		if ($str =~ m/$v2/igs){
		#	print "have match: $k2\n";
			$retVal = $k2;
		} else {
		#	print "no match: $k2\n";
		}
	}
	return $retVal;
}
sub detect_mobile_os(){
	my $self 	= shift;
	my $str 	= shift;
	
	my $retVal  = 0;
	while (my($k3, $v3) = each (%{$self->{os}})){
		if ($str =~ m/$v3/igs){
		#	print "have match: $k2\n";
			$retVal = $k3;
		} else {
		#	print "no match: $k2\n";
		}
	}
	return $retVal;
}
sub detect_mobile_ua(){
	my $self 	= shift;
	my $str 	= shift;

	my $retVal  = 0;
	while (my($k4, $v4) = each (%{$self->{browsers}})){
		if ($str =~ m/$v4/igs){
		#	print "have match: $k2\n";
			$retVal = $k4;
		} else {
		#	print "no match: $k2\n";
		}
	}
	return $retVal;
}

sub is_phone(){
	my $self 	= shift;
	my $str 	= shift;
	
	my $val1 	= $self->detect_phone($str);
	my $val2 	= $self->detect_mobile_os($str);
	my $val3 	= $self->detect_mobile_ua($str);
	#print "DEBUG: $val1 -$val2-$val3\n";
	if ( $val1 =~ /[a-zA-Z]/igs || $val2 =~ /[a-zA-Z]/igs || $val3 =~ /[a-zA-Z]/igs ){
		return 1;
	}
	return 0;
}
sub is_tablet(){
	my $self 	= shift;
	my $str 	= shift;
	my $val 	= $self->detect_tablet($str);
	
	if ($val =~ /[a-zA-Z]/igs){
		return 1;
	}
	return 0;
}
sub is_mobile_os(){
	my $self 	= shift;
	my $str 	= shift;
	my $val 	= $self->detect_mobile_os($str);
	
	if ($val =~ /[a-zA-Z]/igs){
		return 1;
	}
	return 0;
}
sub is_mobile_ua(){
	my $self 	= shift;
	my $str 	= shift;
	my $val 	= $self->detect_mobile_ua($str);
	
	if ($val =~ /[a-zA-Z]/igs){
		return 1;
	}
}


=head1 AUTHOR

Sebastian Enger, C<< <sebastian.enger at gmail.com> >>
Web News auf Deutsch L<http://www.buzzerstar.com/>.
Trending News auf Deutsch L<http://www.buzzerstar.com/trending/>.
Newsticker auf Deutsch L<http://www.buzzerstar.com/newsticker/>.
=head1 BUGS

Please report any bugs or feature requests to C<bug-mobiledetect-pp at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MobileDetect-PP>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MobileDetect::PP


You can also look for information at:

L<https://code.google.com/p/mobiledetect/>

Or write the author an bug request email: 
Sebastian Enger, C<< <sebastian.enger at gmail.com> >>

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MobileDetect-PP>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MobileDetect-PP>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MobileDetect-PP>

=item * Search CPAN

L<http://search.cpan.org/dist/MobileDetect-PP/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Sebastian Enger.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of MobileDetect::PP
