#!/usr/bin/perl

use XML::Parser;
use DBI;

use utf8;
binmode(STDOUT, ":utf8");

%achv=(
	c5C766AF68015CB70=>1,		# ultimate hunter
	c5057BAEBDEA774CE=>1,		# great beasts fear my name
	c128FB25EE807902B=>1,		# ultimate camper
	c7443CBB86FC99D5E=>1,		# Brine Buster
	c67C744D530A8EC9B=>1,		# The Hidden Forest
	c35BB4DD687461439=>1,		# Take Only Lives, Leave Only Corpses
	c14A33E10DAD5EC40=>1,		# Foci on the Big Picture
	c5C49C11CB05C8F3E=>1,		# I'll See You in Ashenfell
);

my $dbh=DBI->connect("dbi:mysql:riftrares", "root", "dbadmin", { mysql_enable_utf8 => 1});
$dbh->do("set names utf8");
my $sth_del=$dbh->prepare(qq(
	delete from achv where id=? and lang=? and no=?
));
my $sth_ins=$dbh->prepare(qq(
	insert into achv (id, lang, no, name)
	values(?, ?, ?, ?);
));

while (my $arg=shift @ARGV) {
	my $parser=new XML::Parser(
		Handlers => {
			Start => \&handle_start,
			End   => \&handle_end,
			Char  => \&handle_char,
		},
	);
	$parser->parsefile($arg);
}

my $inARO=0;
my %pname;
my $collectedtext;
my $achvid="";
my $arindex;

sub handle_start {
	my ($expat, $element)=@_;
	if ($element eq "AchievementRequirementOther") {
		$inARO=1;
		%pname=();
	}
	$collectedtext="";
}

sub handle_char {
	my ($expat, $string)=@_;
	$string=~s/'/&apos;/g;
	$collectedtext.=$string;
}

sub handle_end {
	my ($expat, $element)=@_;

	if ($element eq "AddonId" && $achv{$collectedtext}) {
		$achvid=$collectedtext;
		$arindex=0;
	}
	if ($element eq "Achievement") {
		$achvid="";
	}

	if ($achvid && $element eq "AchievementRequirementOther") {
		$arindex++;
		foreach $lang (keys %pname) {
			$sth_del->execute($achvid, $lang, $arindex);
			$sth_ins->execute($achvid, $lang, $arindex, $pname{$lang});
			# print "delete from achv where id='$achvid' and lang='$lang' and no=$arindex;\n";
			# print "insert into achv (id, lang, no, name) ".
			# "values ('$achvid', '$lang', $arindex, '$pname{$lang}');\n";
		}
		$inARO=0;
	}

	if ($inARO && $element ne "Name" && $element ne "Count") {
		$pname{$element}=$collectedtext;
	}

	$collectedtext="";
}
