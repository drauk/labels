#! /usr/bin/perl
# tex/labels/makelabel.pl   2017-10-3   Alan U. Kennington.
# $Id: tex/labels/makelabel.pl 05bb3a8c7d 2017-10-03 10:23:31Z Alan U. Kennington $

# This is a Perl script for making a label.
# Usage: ./makelabel.pl <filename.txt>

my $deft_n_columns = 22;
my $darkness = 30;          # Default darkness is 30%.
my $deft_mpfont = "phvr8r"; # Default MetaPost font is Helvetica.

my $n_args = $#ARGV + 1;
if ($n_args != 1) {
    print STDERR "Usage:   $0 <filename.txt>\n";
    print STDERR "Example: $0 label1.txt\n";
    exit(1);
    }

# The file to be filtered.
my $f = $ARGV[0];
print "Reading file \"$f\"\n";
if (! -e $f) {
    print STDERR "ERROR: file \"$f\" does not exist\n";
    print STDERR "Usage: $0 <filename.txt>\n";
    exit(1);
    }
if (! -f $f) {
    print STDERR "ERROR: file \"$f\" is not a plain file\n";
    print STDERR "Usage: $0 <filename.txt>\n";
    exit(1);
    }
if (-z $f) {
    print STDERR "ERROR: file \"$f\" is an empty file\n";
    print STDERR "Usage: $0 <filename.txt>\n";
    exit(1);
    }

# Check that the filename tail is ".txt".
my @names = split /\./, $f;
my $n_names = $#names;
my $t = $names[$n_names];
# print "t = \"$t\"\n";
if (lc($t) ne "txt") {
    print STDERR "ERROR: file \"$f\" is not a .txt file\n";
    print STDERR "Usage: $0 <filename.txt>\n";
    exit(1);
    }

# Determine the filename head.
my $head = $f;
$head =~ s/(.*)\.[^\.]+/$1/;
# print "head = \"$head\"\n";

# Return empty string unless the given string is a valid decimal integer.
#-----------------------#
#      nonneg_dec       #
#-----------------------#
sub nonneg_dec {
    my ($str) = @_;
    my $str_out = $str;
    if ($str !~ m/^[0-9]+$/) {
        # Not all characters are decimal digits.
        $str_out = "";
        }
    elsif (length($str) >= 2 && $str =~ m/^0/) {
        # The first digit is "0", and there are more digits. Implies octal!
        $str_out = "";
        }
    return $str_out;
    } # End of subroutine nonneg_dec.

#------------------------------------------------------------------------------
# Read the file.
open(my $fhand, '<', $f)
    or die "ERROR: Could not open file \"$f\" for reading\n";

my $n_lines = 0;
my $n_columns = 0;
my @lines_txt;
while (my $line = readline($fhand)) {
    chomp($line);
#    print "line = \"$line\"\n";
    # Trim the left and then the right.
    $line =~ s/^\s*//;
    $line =~ s/\s*$//;
    # Reduce inter-word spaces to a single space.
    $line =~ s/\s+/ /g;
    $n_lines += 1;
#    print "line = \"$line\"\n";

    # Interpret comments and commands.
    if ($line =~ m/^%%% /) {
#        print "Comment line: \"$line\"\n";
        my @comment = split / /, $line;
        my $n_comment = $#comment;  # Number of fields after "%%%".
        if ($n_comment >= 1) {
            my $command = lc($comment[1]);
            # There is no "switch" in standard old-style Perl.
            if ($command eq "dark" || $command eq "darkness") {
                if ($n_comment >= 2) {
                    my $param = $comment[2];
                    print "Found darkness parameter \"$param\"\n";
                    my $param_dec = nonneg_dec($param);
                    if ($param_dec eq "") {
                        print "ERROR: DARKNESS = \"$param\". IGNORED.\n";
                        }
                    elsif ($param_dec > 100) {
                        print "ERROR: DARKNESS too large: $param. IGNORED.\n";
                        }
                    else {
                        print "Darkness set to \"$param_dec\"\n";
                        $darkness = $param_dec;
                        }
                    }
                }
            elsif ($command eq "font") {
                if ($n_comment >= 2) {
                    my $param = $comment[2];
                    print "Found font parameter \"$param\"\n";
                    if ($param =~ m/\s/) {
                        print "ERROR: FONT = \"$param\". IGNORED.\n";
                        }
                    else {
                        print "Font set to \"$param\"\n";
                        $deft_mpfont = $param;
                        }
                    }
                }
            }
        }
    else {
        # A non-comment line.
        $n_columns += 1;
        $lines_txt[$n_columns] = $line;
        }
    } # End of per-line while-loop.

print "Found $n_columns columns in $n_lines lines in file \"$f\".\n";
my $n_columns_blank = 0;
my $n_columns_ignore = 0;
if ($n_columns < $deft_n_columns) {
    $n_columns_blank = $deft_n_columns - $n_columns;
    print "Will print $n_columns_blank blank lines on the right.\n";
    }
if ($n_columns > $deft_n_columns) {
    $n_columns_ignore = $n_columns - $deft_n_columns;
    print "Will ignore the last $n_columns_ignore lines.\n";
    }

#==============================================================================
# Name of MetaPost output file.
my $f_mp = "$head.mp";

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
my $text_mp_top =
"% $f_mp
% MetaPost file \"$f_mp\" generated by \"makelabel.pl\" from \"$f\".

% prologues := 1;

beginfig(1);
pair zz[];
color col[];
string label[];

% The light colour is always pure white.
col1 := white;

% Percentage darkness for the dark columns.
darkness := $darkness;
col2 := (1-darkness/100)*white; % The dark colour.

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% All of the labels from 1 to 22 must be defined once and only once.
% Blank labels should be given as the empty string, which is \"\".
";

#-----------------------#
#      quotequote       #
#-----------------------#
sub quotequote {
    my ($str) = @_;
    my $str_out = "";
    if ($str =~ m/\"/) {
        # Use negative max number of fields to not delete trailing null string.
        my @parts = split /\"/, $str, -1;
        for ($i = 0; $i <= $#parts; $i += 1) {
            if ($i > 0) {
                $str_out .= " & (char 34) & ";
                }
            $str_out .= "\"$parts[$i]\"";
            }
        }
    else {
        $str_out = "\"$str\"";
        }
    return $str_out;
    } # End of subroutine quotequote.

#------------------------------------------------------------------------------
my $text_mp_mid = "";
for (my $i = 1; $i <= $deft_n_columns; $i += 1) {
    # NOTE: Should escape '"' as '\"' here to prevent MetaPost bugs.
    if (defined($lines_txt[$i])) {
        if ($lines_txt[$i] !~ m/<<</) {
            # Single-row case.
            my $rowA = quotequote($lines_txt[$i]);
            $text_mp_mid .= "label[$i] := " . $rowA . ";\n";
            $text_mp_mid .= "label[100 + $i] := \"\";\n";
            }
        else {
            # Double-row case.
            my ($text_l, $text_r) = split(/ *<<< */, $lines_txt[$i], 2);
            my $rowA = quotequote($text_l);
            my $rowB = quotequote($text_r);
            $text_mp_mid .= "label[$i] := " . $rowA . ";\n";
            $text_mp_mid .= "label[100 + $i] := " . $rowB . ";\n";
            }
        }
    else {
        # Zero-row case.
        $text_mp_mid .= "label[$i] := \"\";\n";
        $text_mp_mid .= "label[100 + $i] := \"\";\n";
        }
    }

#------------------------------------------------------------------------------
my $text_mp_bot =
"% Number of labels. Must always be 22.
n_labels := 22;

% The choice of font.
defaultfont := \"$deft_mpfont\";
% defaultfont := \"cmr9\";

% Dot and line widths.
penDOT := 2.5bp;
penBDY := 0.5bp;
penBOX := 0.5bp;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Width of all 22 columns, ignoring the extension on the right.
wsquares := 19.4 cm;

% Width of one square.
wsquare := wsquares / n_labels;

% X and Y coordinates of the sloping lines.
Xslope := 3.1cm;
Yslope := 3.4cm;

% The angle (in degrees anticlockwise) to tilt the text.
% Not really 45 degrees. Need arctan(y/x).
% angle_label := 45;
zz20 := (Xslope, Yslope);
zz21 := zz20 rotated -90;
angle_label := angle(zz20);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
d1 := 12pt;
d1h := d1 * sqrt(2);
dx1 := 0.1mm;               % Offset of text from base of label.
zz0 := (50, 50);
dsplit := 6bp;              % Offsets for a double-row column.

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
for i=1 upto n_labels:
    % Add the colour.
    zz30 := zz0 + (0, -wsquare * (i - 1));
    zz31 := zz0 + (0, -wsquare * i);
    zz32 := zz31 + zz21;
    zz33 := zz30 + zz21;
    if (i mod 2) = 1:
        col3 := col1;
    else:
        col3 := col2;
        fi
    pickup pencircle scaled penBOX;
    fill zz30--zz31--zz32--zz33--cycle withcolor col3;
    draw zz30--zz31--zz32--zz33--cycle;
    % Do the text.
    zz1 := zz0 + (0, -wsquare * (i - 0.5));
    if label[100 + i] =  \"\":
        % Single-row case.
        draw thelabel.rt(label[i] infont defaultfont, (0,0))
            rotated (angle_label - 90) shifted (zz1+(0, dx1));
    else:
        % Double-row case.
        draw thelabel.rt(label[i] infont defaultfont, (0,0))
            rotated (angle_label - 90) shifted (zz1+(0, dx1+dsplit));
        draw thelabel.rt(label[100 + i] infont defaultfont, (0,0))
            rotated (angle_label - 90) shifted (zz1+(0, dx1-dsplit));
        fi
    endfor

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Draw a bounding box.
zz10 := zz0;
zz11 := zz10 + (0, -wsquares);
zz12 := zz11 + zz21;
zz13 := zz10 + zz21;

pickup pencircle scaled penBDY;
draw zz10--zz11--zz12--zz13--cycle;

endfig;
end
";

#------------------------------------------------------------------------------
# Write MetaPost text to mp file.
# print "MetaPost top-text:\n$text_mp_top";
# print "MetaPost mid-text:\n$text_mp_mid";
# print "MetaPost bottom-text:\n$text_mp_bot";

#------------------------------------------------------------------------------
print "Writing MetaPost file \"$f_mp\"...\n";
open($fhand_mp, '>', $f_mp)
    or die "ERROR: Could not open file \"$f_mp\" for writing\n";

print $fhand_mp $text_mp_top, $text_mp_mid, $text_mp_bot;
# print $fhand_mp $text_mp_mid;

#==============================================================================
# Name of TeX output file.
my $f_tex = "$head.tex";
my $f_1 = "$head.1";

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
my $text_tex =
"% $f_tex
% Labels generated from file \"$f\".

\\input epsf

\\nopagenumbers
\\parindent0pt
\\def\\lgap{\\hskip10pt\\relax}

% Adjust the printing area for A4 paper.
\\hoffset=-2.838mm
\\vsize=29.73017788cm
\\advance\\vsize by-2.54cm            % Top margin
\\advance\\vsize by-2.54cm            % Bottom margin
\\advance\\vsize by-0.9cm             % Allowance for page number in footer.

\\centerline{\\epsfbox{$f_1}\\lgap%
\\epsfbox{$f_1}\\lgap%
\\epsfbox{$f_1}\\lgap%
\\epsfbox{$f_1}\\lgap%
\\epsfbox{$f_1}}

\\bye
";

#------------------------------------------------------------------------------
print "Writing TeX file \"$f_tex\"...\n";
open($fhand_tex, '>', $f_tex)
    or die "ERROR: Could not open file \"$f_tex\" for writing\n";

print $fhand_tex $text_tex;

__END__
