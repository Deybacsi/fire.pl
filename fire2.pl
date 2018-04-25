#!/usr/bin/perl -w

use strict;
use lib "./modules";
use Term::ANSIScreen qw/:color :cursor :screen :keyboard/;
use Term::ReadKey;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval nanosleep
                      clock_gettime clock_getres clock_nanosleep clock
                      stat lstat utime);
use utf8;
binmode STDOUT, ":encoding(UTF-8)";
 
our ($width, $height) = GetTerminalSize ();

our @buf1; our @buf2;
our @chars; our @cols;
our $maxchars=8;
our $maxdots=20;

my $key; # pressed key

# buffer&color init
sub clearbufs { 
  my $x; my $y;
  for ($y=0; $y<$height+1; $y++) {
    for ($x=0; $x<$width+1; $x++) {
      $buf1[$x][$y]=1;
      $buf2[$x][$y]=1;
    }
  }
=pod
  $chars[0]=" "; $cols[0]="black";
  $chars[1]=" "; $cols[1]="black";
  $chars[2]=" "; $cols[2]="black";
  $chars[3]=" "; $cols[3]="black";
  $chars[4]="+"; $cols[4]="bold yellow";
  $chars[5]="#"; $cols[5]="yellow";
  $chars[6]="#"; $cols[6]="red";
  $chars[7]="#"; $cols[7]="blue";
  $chars[8]="#"; $cols[8]="bold blue";
  
  $chars[0]=" "; $cols[0]="black";
  $chars[1]=" "; $cols[1]="black";
  $chars[2]="."; $cols[2]="red";
  $chars[3]="."; $cols[3]="bold yellow";
  $chars[4]="+"; $cols[4]="bold yellow";
  $chars[5]="#"; $cols[5]="bold white";
  $chars[6]="#"; $cols[6]="bold yellow";
  $chars[7]="#"; $cols[7]="yellow";
  $chars[8]="@"; $cols[8]="red";  
=cut
  $chars[0]=" "; $cols[0]="black";
  $chars[1]=" "; $cols[1]="black";
  $chars[2]="."; $cols[2]="red";
  $chars[3]="."; $cols[3]="bold yellow";
  $chars[4]="+"; $cols[4]="bold yellow";
  $chars[5]="#"; $cols[5]="bold white";
  $chars[6]="#"; $cols[6]="bold yellow";
  $chars[7]="#"; $cols[7]="bold blue";
  $chars[8]="#"; $cols[8]="blue"; 
}

sub copybuf2to1 { @buf1=@buf2; }

# calc buf1 -> buf2
sub calctobuf2 {
  my $y; my $x;
  for ($y=1; $y<$height; $y++) {
    for ($x=1; $x<$width-1; $x++) {
      $buf2[$x][$y-1]=int(($buf1[$x][$y]+$buf1[$x+1][$y]+$buf1[$x-1][$y]+$buf1[$x][$y+1]+$buf1[$x][$y-1])/5.1 )  ;
    }
  }   
}

# put the whole shit to screen
sub buf2toscr {
  my $y; my $x; my$i;
  for ($y=1; $y<$height; $y++) {
    for ($x=1; $x<$width; $x++) {
      $i=$buf2[$x][$y];
      if ($i > $maxchars ) { $i=$maxchars; }
      locate $y,$x; 
      print color ($cols[$i]), $chars[$i], color("reset");
    }
  }
}

# bottom random pixel line
sub putbottom {
  my $x;
  for ($x=0; $x<$width; $x++) {
    $buf1[$x][$height-1]=int(rand($maxchars+15));
  }
}

# random bright flying dots
sub putrnddots {
  my $i;
  for ($i=1; $i<$maxdots; $i++) {
    $buf1[int(rand($width))][$height-2-int(rand(5))]=$maxchars+15;
  }
}

# main loop

&clearbufs;
ReadMode 4; cls;

while (not defined ($key = ReadKey(-1))) {
  &putbottom;
  &putrnddots;
  &calctobuf2;
  &copybuf2to1;
  &buf2toscr;
  usleep(20000);
}
resetkey; setmode 3; cls;
ReadMode 0; # Reset tty mode before exiting
# perec!
