#!/usr/bin/perl

#
#Mobile Detect - Python detection mobile phone and tablet devices
#
#Thanks to:
#    https://github.com/serbanghita/Mobile-Detect/blob/master/Mobile_Detect.php
#

# setup  perl -MCPAN -e 'install JSON'
# cpan
# install JSON
# install JSON::XS
# install WWW::Mechanize
# install IO::Socket::SSL
# install Crypt::SSLeay

use strict;
use Cwd;
use JSON;
use JSON::XS;
use Data::Dumper;

my $pwd 		= cwd();

my $file 		= "$pwd/Mobile_Detect.json";
my $content 	= "";

open my $handle, '<:encoding(UTF-8)', $file or die "Can't open $file for reading: $!";
	local $/ = undef;
	$content = <$handle>;
close $handle;

my $teststring = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0";
my $ts = "Mozilla/5.0 (Linux; Android 4.4.2; GT-I9500 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.166 Mobile Safari/537.36";
eval{
         
    my $json = new JSON;
 
    # these are some nice json options to relax restrictions a bit:
    #my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);
	my $json_text = $json->allow_nonref->utf8->relaxed->decode($content);
	
    my %ep_hash = ();
	my $ep_hash = {};
	
	while (my($k, $v) = each (%{$json_text->{uaMatch}->{tablets}})){
		$ep_hash->{tablets}->{$k} = $v;
		#print "$k => $v\n";
    }
	while (my($k, $v) = each (%{$json_text->{uaMatch}->{phones}})){
		$ep_hash->{phones}->{$k} = $v;
    } 
	while (my($k, $v) = each (%{$json_text->{uaMatch}->{browsers}})){
		$ep_hash->{browsers}->{$k} = $v;
    }
	while (my($k, $v) = each (%{$json_text->{uaMatch}->{os}})){
		$ep_hash->{os}->{$k} = $v;
    } 	
	sub detect_phone(){
		my $str = shift;
		while (my($k, $v) = each (%{$ep_hash->{phones}})){
			if ($str =~ m/$v/ig){
				return $k;
			}
		}
		return 0;
	}
	sub detect_tablet(){
		my $str = shift;
		while (my($k, $v) = each (%{$ep_hash->{tablets}})){
			if ($str =~ m/$v/ig){
				return $k;
			}
		}
		return 0;
	}
	sub detect_mobile_os(){
		my $str = shift;
		while (my($k, $v) = each (%{$ep_hash->{os}})){
			if ($str =~ m/$v/ig){
				return $k;
			}
		}
		return 0;
	}
	sub detect_mobile_ua(){
		my $str = shift;
		while (my($k, $v) = each (%{$ep_hash->{browsers}})){
			if ($str =~ m/$v/ig){
				return $k;
			}
		}
		return 0;
	}
	sub is_phone(){
		my $str = shift;
		if (detect_phone($str) != 0 || detect_mobile_os($str) != 0 || detect_mobile_ua($str) != 0 ){
			return 1;
		}
		return 0;
	}
	sub is_tablet(){
		my $str = shift;
		if (detect_tablet($str) != 0 ){
			return 1;
		}
		return 0;
	}
	sub is_mobile_os(){
		my $str = shift;
		if (detect_mobile_os($str) != 0 ){
			return 1;
		}
		return 0;
	}
	sub is_mobile_ua(){
		my $str = shift;
		if (detect_mobile_ua($str) != 0 ){
			return 1;
		}
		return 0;
	}
	
	#print &detect_phone($ts);
	print &is_phone($ts);
}
