#!/usr/bin/perl

use DBI;
use Encode;

use utf8;
binmode(STDOUT, ":utf8");

my $dbh=DBI->connect("dbi:mysql:riftrares", "root", "dbadmin", {mysql_enable_utf8 => 1 } );
$dbh->do("set names utf8");

my $sth_zones=$dbh->prepare(qq(
	select distinct zone from mob where lang='English' order by zone;
));
my $sth_allzonenames=$dbh->prepare(qq(
	select distinct lang, zone from mob
	where id in (
		select id from mob where lang='English' and zone=?
	)
	order by lang
));

my $sth_mobsbyzone=$dbh->prepare(qq(
	select distinct id, name from mob
	where zone=? and lang='English'
	order by name
));

my $sth_allmobnames=$dbh->prepare(qq(
	select distinct lang, name from mob
	where id = ?
	order by lang
));

my $sth_allachvmobnames=$dbh->prepare(qq(
	select distinct lang, name from achv, mamatch
	where achv.id=mamatch.achvid and achv.no=mamatch.achvno
	and mamatch.mobid=?
	order by lang
));

my $sth_positions=$dbh->prepare(qq(
	select x, z from loc where mobid=?
));

print qq(
-- This file is autogenerated. Please review the autogen subdirectory
-- instead of submitting changes to this file.

RareDar.data=
{
);

$sth_zones->execute();
while (($zone)=$sth_zones->fetchrow_array()) {
	print nt(qq(
		{
		zone = {
	));
	$sth_allzonenames->execute($zone);
	while (($lang, $langzone)=$sth_allzonenames->fetchrow_array()) {
		$langzone=Encode::decode("utf-8", $langzone);
# if ($zone eq "Ardent Domain") {
		# print "\nutf8: ", ( utf8::is_utf8(langzone) ? "Y" : "N" ), "  ", $lang, " ", $langzone, "\n";
# }
		$langzone=~s/&apos;/'/g;
		print qq( $lang = "$langzone",);
	}
	print "},";

	print nt(qq(
		mobs = {
	));

	$sth_mobsbyzone->execute($zone);
	while (($id)=$sth_mobsbyzone->fetchrow_array()) {
		print nt(qq(
			{	id = "$id",
				targ = { 
		));

		$sth_allmobnames->execute($id);
		while (($lang, $langname)=$sth_allmobnames->fetchrow_array()) {
			$langname=Encode::decode("utf-8", $langname);
			$langname=~s/&apos;/'/g;
			print qq( $lang = "$langname",);
		}
		print "},";

		print nt(qq(
				achv = { 
		));
		$sth_allachvmobnames->execute($id);
		while (($lang, $langname)=$sth_allachvmobnames->fetchrow_array()) {
			$langname=Encode::decode("utf-8", $langname);
			$langname=~s/&apos;/'/g;
			print qq( $lang = "$langname",);
		}
		print "},";

		print nt(qq(
				pos = { 
		));
		$sth_positions->execute($id);
		while (($x, $z)=$sth_positions->fetchrow_array()) {
			print qq( { $x, $z, }, );
		}
		print "},";



		print nt(qq(
			},
		));
	}
	print nt(qq(
			},
		},
	));

}

print qq(
}
);


sub nt {
	my $x=shift;
	$x=~s/\s*\n\s*$//;
	return $x;
}