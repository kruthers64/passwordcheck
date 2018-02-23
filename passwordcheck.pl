#!/usr/bin/perl

# requires a prepared password hash file based on the Pwned Passwords list from
# https://haveibeenpwned.com
#
# to prepare the file:
#
# 1. download the Pwned Passwords list via torrent:
#    https://downloads.pwnedpasswords.com/passwords/pwned-passwords-2.0.txt.7z.torrent
#
# 2. unzip the file:
#    shell> 7z e -o/var/tmp pwned-passwords-2.0.txt.7z
#
# 3. sort the file; NOTE that the file will be about 30 gigs after unzipping but sorting
#    is still possible (it takes about 20 minutes on my machine with only 8 gigs of ram):
#    shell> sort /var/tmp/pwned-passwords-2.0.txt > /var/tmp/pwned-passwords-2.0-sorted.txt

use strict;
use warnings;

use Digest::SHA qw(sha1_hex);

# globals
my $PASSWORD_FILE   = "/var/tmp/pwned-passwords-2.0-sorted.txt";
my $REGEX           = qr/([0-9A-F]{40}):(\d+)\s/;
my $FOUND           = 0;
my $VARIATIONS      = 0;
my $FILESIZE        = 0;
my $PWFH            = undef;
my $RED             = "\e[01;31m";
my $GREEN           = "\e[01;32m";
my $YELLOW          = "\e[01;33m";
my $HIGHLIGHT       = "\e[01;47;30m";
my $NORMAL          = "\e[00m";

main();
exit();


sub main {
    my @chars = ('a' .. 'z', 'A' .. 'Z', 0 .. 9, '!', '_', '.', '$', '?');

    # checks
    if (not -e $PASSWORD_FILE) {
        die "Password file $PASSWORD_FILE not found\n";
    }
    if (scalar(@ARGV) > 0) {
        die "Do not pass any args.\n";
    }

    # get password file details
    $FILESIZE = (stat($PASSWORD_FILE))[7];
    open($PWFH, "$PASSWORD_FILE") or die "Could not open $PASSWORD_FILE for reading\n";

    # prompt for passwords until hits hits ENTER by itself
    while (1) {
        print("Enter password: ");
        chomp(my $base = <>);
        if ($base eq "") {
            exit();
        }

        # check password w/ various suffixes
        $FOUND = 0;
        $VARIATIONS = 0;
        check($base);
        foreach my $c (@chars) {
            check($base . $c);
        }
        foreach my $c1 (@chars) {
            foreach my $c2 (@chars) {
                check($base . $c1 . $c2);
            }
        }

        # results
        if ($FOUND == 0) {
            print("\n    ${GREEN}Congrats, not found!${NORMAL}\n\n");
        } elsif ($VARIATIONS == 1) {
            if ($FOUND == 1) {
                print("\n    ${YELLOW}At least $FOUND password found.${NORMAL}\n\n");
            } else {
                print("\n    ${YELLOW}At least $FOUND passwords found.${NORMAL}\n\n");
            }
        } elsif ($VARIATIONS > 1) {
            print("\n    ${YELLOW}At least $VARIATIONS variations and $FOUND passwords found.${NORMAL}\n\n");
        }
    }
}

sub sha1sum {
    my ($in) = @_;
    return uc(sha1_hex($in));
}

sub check {
    my ($password) = @_;

    my $count = search(sha1sum($password));
    if ($count > 0) {
        $FOUND += $count;
        $VARIATIONS++;
        printf("    %-20s found %d times\n", $password, $count);
    }
}

# binary search the file for a line w/ the matching sha1sum and return the count
sub search {
    my ($sha1) = @_;

    # we must read in MORE than two lines at a time to ensure we have one complete line
    my $buffer = 150;

    # stop binary search from drilling down to a single byte
    my $minstep = 40;

    my $data;

    my $l = 0;
    my $r = $FILESIZE - 1 - $buffer;

    while ($r > $l) {
        my $m = int(($l + $r) / 2);
        seek($PWFH, $m, 0);
        read($PWFH, $data, $buffer);
        my ($foundsha1, $count) = findsha1($data);
        if (not $foundsha1) {
            die "Failed while searching file at pos = $m\n";
        }
        if ($foundsha1 eq $sha1) {
            return $count;
        }

        if (isHexGreater($sha1, $foundsha1)) {
            $l = $m + $minstep;
        } else {
            $r = $m - $minstep;
        }
    }

    return 0;
}

# find the first full sha1sum:count line from the input blob
sub findsha1 {
    my ($data) = @_;

    if ($data =~ m/$REGEX/s) {
        return ($1, $2);
    }
    return undef;
}

# is arg1 > arg2 as arbitrary hex values?
sub isHexGreater {
    my ($a, $b) = @_;

    my ($ai, $bi);
    for (my $i=0; $i < length($a) ; $i++) {
        $ai = substr($a, $i, 1);
        $bi = substr($b, $i, 1);
        next if $ai eq $bi;
        if (ord($ai) > ord($bi)) {
            return 1;
        }
        return 0;
    }
    return 0;
}
