#!/usr/bin/perl

use XML::Parser;
use DBI;

use utf8;
use open ':encoding(UTF-8)';
use open ':std';

binmode(STDOUT, ":utf8");

# This fixes a bug with the russian NPC.xml (2013-03-24) where rare mobs are
# shown as Elite, not LootDropper in Cape Jule.

%yesthisisarare=(
	UFB1926AA4AB396F0=>1,		# Keelsnapper
	UFB1926A57EE2FFAE=>1,		# Dendorath
	UFB1926AB5BE859C1=>1,		# Riktor
	UFB1926A60FD8A2BF=>1,		# Son of Auram
	UFB1926AC64C61CD6=>1,		# The Ghost of Malluma
	UFB1926A71831658C=>1,		# Iron Dragon Mark VII
	UFB1926A8296F289D=>1,		# Pyronite Monstrosity
	UFB1926A93A45D3E2=>1,		# Avatar of Krynathal
);

my $dbh=DBI->connect("dbi:mysql:riftrares", "root", "dbadmin", { mysql_enable_utf8 => 1});
$dbh->do("set names utf8");
my $sth_del=$dbh->prepare(qq(
	delete from mob where id=? and lang=?
));
my $sth_ins=$dbh->prepare(qq(
	insert into mob (id, lang, name, zone, scene)
	values(?, ?, ?, ?, ?);
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

my $inprimaryname=0;
my $inzone=0;
my $inscene=0;
my $collectedtext;
my $mobid;

sub handle_start {
	my ($expat, $element)=@_;
	if ($element eq "NPC") {
		%pname=();
		%zone=();
		%scene=();
		$portrait="";
		$mobid="";
	}
	$inprimaryname=1 if $element eq "PrimaryName";
	$inzone=1 if $element eq "Zone";
	$inscene=1 if $element eq "Scene";
	$collectedtext="";
}

sub handle_char {
	my ($expat, $string)=@_;
	$string=~s/'/&apos;/g;
	$collectedtext.=$string;
}

sub handle_end {
	my ($expat, $element)=@_;
	$inprimaryname=0 if $element eq "PrimaryName";
	$inzone=0 if $element eq "Zone";
	$inscene=0 if $element eq "Scene";

	if ($inprimaryname) {
		$pname{$element}=$collectedtext;
	} elsif ($inzone) {
		$zone{$element}=$collectedtext;
	} elsif ($inscene) {
		$scene{$element}=$collectedtext;
	} elsif ($element eq "Portrait") {
		$portrait=$collectedtext;
	} elsif ($element eq "AddonType") {
		$mobid=$collectedtext;
	}
	$collectedtext="";

	if ($element eq "NPC"
	&&  ( $portrait eq "LootDropper"
	   || $yesthisisarare{$mobid}==1 )) {
		foreach $lang (keys %pname) {
			$sth_del->execute($mobid, $lang);
			$sth_ins->execute($mobid, $lang, $pname{$lang}, $zone{$lang}, $scene{$lang});
		}
	}
}
