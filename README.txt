This is a dead simple perl script to check a password (plus variations) against the Pwned
Passwords 2.0 list from https://haveibeenpwned.com

It will not work out of the box; you will need to get and prepare the password list first.
To do that, follow the procedure below...

                                        *** WARNING ***

DOING THE FOLLOWING WILL REQUIRE AROUND 100 GIGS OF HARD DRIVE SPACE!
However, when finished it will use about 30 gigs.

The procedure:

1.  Download the Pwned Passwords list via torrent:
    https://downloads.pwnedpasswords.com/passwords/pwned-passwords-2.0.txt.7z.torrent

2.  Go to the directory containing the downloaded file.

3.  Use the following shell code to prepare the file (ie. unzip and sort it):

    NOTE: The unzipped file will be about 30 gigs but the GNU sort program distributed with
    linux should have no trouble sorting it.  For example, my machine with only 8 gigs of ram
    sorted it in about 20 minutes.  However, sort will probably need about 30 gigs of space
    in /tmp for temporary files; if you need it to use a different tmpdir, add the -T <dir>
    arg to the sort command.

    NOTE2: Choose a better OUTDIR if /var/tmp doesn't work for you, but remember to update the
    path in the script as well.


# paste the following into a shell
export OUTDIR=/var/tmp
echo unzipping && 7z e -o$OUTDIR pwned-passwords-2.0.txt.7z && \
echo sorting && sort $OUTDIR/pwned-passwords-2.0.txt > $OUTDIR/pwned-passwords-2.0-sorted.txt && \
echo cleaning && rm -v pwned-passwords-2.0.txt.7z $OUTDIR/pwned-passwords-2.0.txt

  ------------------------------------------------------------------------------------------------

Once that's complete, simply run the script with no args:

shell> cd /wherever/you/put/the/script
shell> ./passwordcheck.pl

It will prompt you for a password in a loop until you hit ENTER by itself to quit.

                                    *** ANOTHER WARNING ***

THE PASSWORD WILL BE ECHOED TO THE SCREEN!
It's not hidden because variations of the password will also be echoed to the screen if found in
the list.  If you try something popular, your screen will be filled with versions of the password.
You probably don't want to do this in public with your actual passwords.  But testing random
things with some friends can be pretty fun...

Anyway, usage will look something like this:

shell> ./passwordcheck.pl 
Enter password: fredsdead
    fredsdead            found 97 times
    fredsdead0           found 2 times
    fredsdead1           found 27 times
    fredsdead2           found 10 times
    fredsdead3           found 2 times
    fredsdead4           found 2 times
    fredsdead5           found 3 times
    fredsdead6           found 2 times
    fredsdead7           found 7 times
    fredsdead22          found 3 times
    fredsdead46          found 3 times
    fredsdead55          found 1 times
    fredsdead69          found 3 times
    fredsdead75          found 1 times

    At least 14 variations and 163 passwords found.

Enter password: barneytoo
    barneytoo            found 2 times

    At least 2 passwords found.

Enter password: barneywho?

    Congrats, not found!

Enter password: 

  ------------------------------------------------------------------------------------------------

Some notes about the code:
- This was a quick hack and there may be bugs.
- I didn't exhaustively test the searching to make it as efficient as possible.  It's pretty fast
  for perl searching a 30 gig file, though.
- The password variations are pretty lame (1 or 2 characters added to the end).  Feel free to make
  that better, but the more variations added the longer each will take.

