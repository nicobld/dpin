#!/usr/bin/env perl

use strict;
use warnings;
use Cwd qw(getcwd);
use Getopt::Long qw(GetOptions);
use Scalar::Util qw(looks_like_number);

my $BLACK="\033[30m";
my $RED="\033[31m";
my $GREEN="\033[32m";
my $YELLOW="\033[33m";
my $BLUE="\033[34m";
my $PINK="\033[35m";
my $CYAN="\033[36m";
my $WHITE="\033[37m";
my $NORMAL="\033[0;39m";
my $GRAY="\033[90m";

my $VERSION = '1.0.0';

my $prog = "dpin";
my $data_file = "$ENV{HOME}/.config/$prog";
my $data_file_tmp = "$ENV{HOME}/.config/$prog.tmp";
if (not system("test $data_file")) {
	system("touch $data_file");
}

open(FHCACHE, '>', "$ENV{HOME}/.cache/dpin") or die $!;

my $command = '';
my $num = '';
my $alias = '';
my $dir = '';

GetOptions(
	'pin' => sub { $command = 'pin'; },
	'list' => sub { $command = 'list'; },
	'remove' => sub { $command = 'remove'; },
	'clean' => sub { $command = 'clean'; },
	'move' => sub { $command = 'move'; },
	'alias=s' => \$alias,
	'dir=s' => \$dir,
	'num=i' => \$num,
	'version' => sub { print "$prog: version $VERSION\n"; exit; },
	'help' => sub { usage(); exit; },
	);

if (looks_like_number($alias)) {
	print STDERR "$prog: alias cannot be a number.\n";
	exit 1;
}

if (not $command) {
	cdpin();
} elsif ($command eq 'pin') {
	pin($num, $alias, $dir);
} elsif ($command eq 'list') {
	list($num, $alias);
} elsif ($command eq 'remove') {
	remove($num, $alias, $dir);
} elsif ($command eq 'clean') {
	clean();
}

sub cdpin {
	unless (scalar(@ARGV) == 1) { print STDERR "$prog: missing argument\n"; exit 1; }

	open(FH, '<', $data_file) or die $!;

	if (looks_like_number($ARGV[0])) {
		my $line = 0;
		while (<FH>) {
			if ($line == $ARGV[0]) {
				my ($fnum, $falias, $fdir) = split(/:/, $_);
				chomp($fdir);
				if (system("test -e $fdir -a -d $fdir")) {
					print STDERR "$prog: directory '$fdir' missing, unpining it.\n";
					close(FH);
					remove($fnum, '', '');
				} else {
					print FHCACHE "$fdir\n";
				}
				exit;
				close(FHCACHE);
			}
			$line++;
		}
	} else {
		while (<FH>) { 
			my ($fnum, $falias, $fdir) = split(/:/, $_);
			if ($falias =~ /^$ARGV[0]/) {
				chomp($fdir);
				if (system("test -e $fdir -a -d $fdir")) {
					print "$prog: directory '$fdir' missing, unpining it.\n";
					close(FH);
					remove($fnum, '', '');
				} else {
					print FHCACHE "$fdir";
				}
				exit;
			}
		}
	}
	print "dpin: alias or number '$ARGV[0]' not found.\n";
}

sub pin {
	my ($num, $alias, $dir) = @_;
	my $lines = 0;

	if (not $num) {
		open(FH, '<', $data_file) or die $!;
		while (<FH>) { $lines++; }
		close(FH);
	} else {
		print '--pin and --num are not yet supported.\n';
		exit 1;
	}

	if (not $dir) {
		$dir = getcwd();
	} else {
		if (system("test -e $dir -a -d $dir")) {
			print "$prog: directory doesn't exit.\n";
			exit 1;
		}
	}

	open(FH, '>>', $data_file) or die $!;
	
	print FH "$lines:$alias:$dir\n";

	close(FH);
}

sub list {
	my ($num, $alias) = @_;
	open(FH, '<', $data_file) or die $!;

	if ($alias) {
		while (<FH>) {
			my ($fnum, $falias, $fdir) = split(/:/, $_);
			if ($falias =~ /^$alias/) {
				print $fdir;
			}
		}
	} elsif ($num) {
		while (<FH>) {
			my ($fnum, $falias, $fdir) = split(/:/, $_);
			if ($fnum == $num) {
				print $fdir;
			}
		}
	} else {
		print "${BLUE}n ${NORMAL}alias ${GRAY}directory\n\n";
		while (<FH>) {
			my ($fnum, $falias, $fdir) = split(/:/, $_);
			if ($falias eq '') {
				$falias = "\t";
			}
			print "$BLUE$fnum $NORMAL$falias $GRAY$fdir";
		}
	}

	close(FH);
} 


sub remove {
	my ($num, $alias, $dir) = @_;
	if ((!$alias && !$dir && !$num or $alias && $dir or $alias && $num or $dir && $num) and ($num == 0 and $alias || $dir)) {
		print STDERR 'dpin: use exactly one of --alias, --dir, --num\n';
		exit 1;
	}

	my $line;
	my $count = 0;
	
	open(FH, '<', $data_file) or die $!;
	open(FHTMP, '>', $data_file_tmp) or die $!;

	if ($alias) {
		while (<FH>) {
			my ($fnum, $falias, $fdir) = split(/:/, $_);
			if (not $falias eq $alias){
				print FHTMP "$count:$falias:$fdir";
				$count++;
			}
		}
	}

	if ($dir) {
		while (<FH>) {
			my ($fnum, $falias, $fdir) = split(/:/, $_);
			if (not $fdir eq $dir){
				print FHTMP "$count:$falias:$fdir";
				$count++;
			}
		}
	}

	if ($num) {
		while (<FH>) {
			my ($fnum, $falias, $fdir) = split(/:/, $_);
			if (not $fnum == $num){
				print FHTMP "$count:$falias:$fdir";
				$count++;
			}
		}
	}

	close FH;
	close FHTMP;
	system("cp $data_file_tmp $data_file");
	system("rm $data_file_tmp");
}

sub clean {
	print '$prog: are you sure you want to remove all pins ? [yes/no] > ';
	my $confirm = <>;
	chomp($confirm);
	if ($confirm eq 'yes') {
		print '$prog: Removing all pins...\n';
		system("rm -f $data_file");
	}
}

sub move {
	unless (scalar(@ARGV) == 2) { print STDERR "$prog: missing arguments\n"; exit 1; }

	open(FH, '<', "$data_file") or die $!;

	# if (looks_like_number(

	while (<FH>) {
		my ($fnum, $falias, $fdir) = split(/:/, $_);
	}
}


sub usage {
	printf
"$prog : Usage

$prog index|alias : cd to the pin with the right index or alias.
$prog --pin [--alias STRING] [--dir STRING]
$prog --list [--alias STRING] [--num INT]
$prog --remove --alias STRING | --num INT
$prog --clean

Commands:
-p, --pin
	adds a pin to to the list

-l, --list
	prints the list of pins

-r, --remove
	remove pin

-c, --clean
	remove all pins

Options:
-a, --alias = STRING
	use STRING as alias

-d, --dir = STRING
	use STRING as directory

-n, --num = INT
	use INT as index


Examples:

Pin current directory at the end of the list.
> $prog -p

Pin a specified directory with -d, give it an alias with -a.
> $prog -p -a myalias -d \$HOME/mydir

Cd to pin index 0 (no options needed).
> $prog 0

Cd to pin with alias 'myalias' (no options needed).
> $prog myalias
> $prog myal
> $prog m

List all pins.
> $prog -l

Remove pin index 0.
> $prog -r -n 0

Remove pin with alias 'myalias'.
> $prog -r -a myalias

Remove all pins.
> $prog -c
"
}
