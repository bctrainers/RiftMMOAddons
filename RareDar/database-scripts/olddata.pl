#!/usr/bin/perl

use XML::Parser;
use DBI;

use utf8;
binmode(STDOUT, ":utf8");

my $dbh=DBI->connect("dbi:mysql:riftrares", "root", "dbadmin", { mysql_enable_utf8 => 1});
$dbh->do("set names utf8");

my $sth_findmob=$dbh->prepare(qq(
	select id from mob where name=?
));

foreach $arg (@ARGV) {
	open(F, "<$arg");
	binmode(F, ":utf8");
	while (<F>) {
		if (/\["(.*)"\]\s*=\s*{\s*(\d+),\s*(\d+)/) {
			$name=$1;
			$x=$2;
			$y=$3;
			next if ($x==0 || $y==0);

			$sth_findmob->execute($name);
			if (($id)=$sth_findmob->fetchrow_array()) {
				unless ($have{"$id, $x, $y"}) {
					push(@f, "('$id', $x, $y), -- $name");
					# print "($id, $x, $y), -- $name\n";
				}
				$have{"$id, $x, $y"}=1;
			}
		}
	}
	close F;
}

print qq(
insert into loc (mobid, x, z) values
);
print join("\n", sort @f);
print qq(
(null, null, null);
delete from loc where id is null;
);
