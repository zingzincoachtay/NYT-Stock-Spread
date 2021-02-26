#!/usr/bin/perl -w
use strict;
use warnings;
use Text::CSV;
#my ($sep,$quo) = ('|','');
my ($sep,$quo) = (',','"');
my $csv = Text::CSV->new({sep_char=>$sep,quote_char=>$quo});

my $csvfilename = $ARGV[0] or die "Need a file to parse.\n";
my ($fullname,$filename) = ('','');
if( $csvfilename=~/^.+\/(([^\/]+?)\-\d{4}\d{2}\d{2})\.csv$/ ){
  ($fullname,$filename) = ($1,$2);
} else { print "CSV filename could not be parsed: $!\n"; exit;}
my $tablename = "_$filename";
my $sqlofname = "./sql-importable/$fullname.csv.sql";

my ($cols,$entries) = CSVwHeader($csvfilename);
my @cols_data = ParseCSV(0,$cols);
$_=~s/\s+//g foreach @cols_data;
print "@cols_data\n";
# 
# Initialize Flags
# 
my $k = 0; my $columnflags = {};
use lib './pmods';
use Declare;
my $flagobj = {};
foreach my $n (0 .. $#cols_data){
  $flagobj->{$n} = new Declare('',0,1,1,1,0,0);
  # (1) always count charlen
  # (2) col is char(isnum==0) if there is one occurrence of text
  # (3) col is decimal(isint==0) if there is one occurrence of non-int
  # (4) col is signed(isunsigned==0) if there is one occurrence of signed num
  # (5)(6) count numlen if isnum; count denlen if isnum
  #while( my($key,$val)=each(%{$flagobj->{$n}}) ){ print "($n)[$key -- $val]\n";}
}
while(my $entry = ${$entries}[$k]){
  my @eval_data = ParseCSV($k,$entry);
  foreach my $j (0 .. $#eval_data){
    my ($charlen,$isnum,$isint,$isunsigned,$numlen,$denlen) = (0,0,0,0,0,0);
    my $data = $eval_data[$j];
      #   /[a-df-zA-DF-Z]{2,}/
      #   /[\-\+\d,\.eE]+$/
      # for now, treat 1.11e10 as text
    if($data eq ''){
      # do nothing skip
    } elsif( $data=~/^[\-\+\d,\.]+$/ ){
      # is a number column
      ($charlen,$isnum) = (length($data),1);
      ($isint,$isunsigned,$numlen,$denlen) = cell_is_numeral($k,$j,$data);
    } else {#elsif( $data=~/[a-zA-Z]{2,}/ ){
      # is a text column
      #print "$data\n" if $j==2;
      ($charlen,$isnum) = (length($data),0);
      ($isint,$isunsigned,$numlen,$denlen) = (0,0,0,0);
    }
    set_flags($j,$flagobj->{$j},[$charlen,$isnum,$isint,$isunsigned,$numlen,$denlen]);
  }
  $k++;
}

my @column_definitions = ();
foreach my $k0 (sort {$a<=>$b} keys %$flagobj){
  my $v0 = $flagobj->{$k0};
  if( $v0->get_isnum() && $v0->get_isint() ){
    $v0->{_cellc}  = $cols_data[$k0].' int';
    $v0->{_cellc} .= ' unsigned';
  }
  if( $v0->get_isnum() && !($v0->get_isint()) ){
    my $full_len = $v0->{_numlen} + $v0->{_denlen};
    $v0->{_cellc} = $cols_data[$k0].' decimal($full_len,'.$v0->{_denlen};
  }
  if( !($v0->get_isnum()) ){
    $v0->{_cellc} = $cols_data[$k0].' char('.$v0->{_charlen}.')'
      if $v0->{_charlen}>0 && $v0->{_charlen}<256;
    $v0->{_cellc} = $cols_data[$k0].' text)'
      if $v0->{_charlen}>255;
  }
  print "$k0 -- ".$v0->{_cellc}."\n";
  push @column_definitions, $v0->{_cellc};
}
my $sql_prefix = "
CREATE DATABASE IF NOT EXISTS track_stock_prices;
USE track_stock_prices;
DROP TABLE IF EXISTS _$filename;
CREATE TABLE IF NOT EXISTS _$filename (".join(',',@column_definitions).");

LOAD DATA LOCAL INFILE '$csvfilename' 
INTO TABLE _$filename
FIELDS TERMINATED BY '$sep' 
ENCLOSED BY '$quo'
LINES TERMINATED BY '\\n'
IGNORE 1 ROWS;
";
open(my $json_file,'>',$sqlofname) or die "Could not open '$sqlofname' $!\n";
if( eval(print $json_file $sql_prefix) ){
  print "SQL file was created: $sqlofname\n";
}
close $json_file;


sub set_flags {
  my ($r,$obj,$flags) = @_;
  my ($this,$that) = ('','');
  ### if isnum(1)=0 then isint(2)=0 [AND] isunsigned(3)=0
  # if not number, neither is it numeral nor unsigned
  #print "isnum-${$flags}[1](1),isint-${$flags}[2](2),isun-${$flags}[3](3)\n" 
  #   if ${$flags}[1]==0 && !(${$flags}[2]==0 && ${$flags}[3]==0);
  if( ${$flags}[1]==0 && !(${$flags}[2]==0 && ${$flags}[3]==0) ){
    ${$flags}[3]=0;
    ${$flags}[2]=0;
  }
  ### /* Deprecate: numeral can be unsigned(3) non-integer(2) */ 
  ### /* if isunsigned(3)=1 then isint(2)=1
  ### if isint(2)=0 then isunsigned(3)=0
  # if not integer, neither should the SQL (decimal) query be unsigned
  #print "isnum-${$flags}[1](1),isint-${$flags}[2](2),isun-${$flags}[3](3)\n" 
  #   if ${$flags}[2]==0 && !(${$flags}[3]==0);
  if( ${$flags}[2]==0 && !(${$flags}[3]==0) ){
    ${$flags}[3]=0;
  }
  ### if isint(2)=1 then isnum(1)=1
  # if integer, should it be numeral
  #print "isnum-${$flags}[1](1),isint-${$flags}[2](2)\n" 
  #   if ${$flags}[2]==1 && !(${$flags}[1]==1);
  if( ${$flags}[2]==1 && !(${$flags}[1]==1) ){
    ${$flags}[1]=1;
  }
  
  $this = ${$flags}[0]; $that = $obj->get_charlen();
  $obj->set_charlen($this) if $that<$this;
  #
  #     Only do when the new char lengths exceeds current upper limit.
  $this = ${$flags}[1]; $that = $obj->get_isnum();
  $obj->set_isnum($this) if !($that==$this || $that==0);
  #
  #     Strict - isnum(1)
  #     Lenient - istext(0)
  #     Once a text is found, treat all as text.
  #     ... once set to isnum=0, do not change.
  $this = ${$flags}[2]; $that = $obj->get_isint();
  $obj->set_isint($this) if !($that==$this || $that==0 || ${$flags}[1]==0);
  #
  #     Strict - isint(1)
  #     Lenient - isnum(0)
  #     Once a decimal is found, treat all as decimal (non-integer numeral).
  #     ... once set to isint=0, do not change.
  #     ... all int is num, but not all num are int.
  #     ... only when isnum=1
  $this = ${$flags}[3]; $that = $obj->get_isunsigned();
  $obj->set_isunsigned($this) if !($that==$this || $that==0 || ${$flags}[2]==0);
  #
  #	 Strict - isunsigned(1)
  #	 Lenient - issigned(0)
  #	 Once a signed int is foound, treat all as signed.
  #	 ... once set to isunsigned=0, do not change.
  #	 ... only when isint=1
  $this = ${$flags}[4]; $that = $obj->get_numlen();
  $obj->set_numlen($this) if $that<$this && ${$flags}[2]==0 && ${$flags}[3]==0;
  #
  #	 Only do when new numlen > current numlen upper limit.
  #	 ... only when isnum=1 AND isint=0
  $this = ${$flags}[5]; $that = $obj->get_denlen();
  $obj->set_denlen($this) if $that<$this && ${$flags}[2]==1 && ${$flags}[3]==0;
  #
  #	 Only do when new denlen > current denlen upper limit.
  #	 ... only when isnum=1 AND isint=0
  return 1;
}

sub keep_flags {
  my ($istext,$charlen,$isnum,$isint,$isunsigned,$numlen,$denlen) = @_;
# 
# both istext and isnum cannot be true
# neither (charlen>0 and istext=0) nor (charlen=0 and istext=1) cannot be true
# 
# 
  print <<WARN if $istext==$isnum || $charlen*$istext==0;
Warning: columns did not seem right at the line $k; values were:
istext = $istext
charlen = $charlen
isnum = $isnum
isint = $isint
isunsigned = $isunsigned
numlen = $numlen
denlen = $denlen
WARN
}

sub CSVwHeader {
  my ($csvfilename) = @_;
  open(my $csv_data,'<',$csvfilename) or die "Could not open '$csvfilename' $!\n";
    my @entries = <$csv_data>;
  close($csv_data);
  my $cols = shift @entries;
  return ($cols,\@entries);
}
sub ParseCSV {
  my ($n,$en) = @_;
  chomp $en;
  if( $csv->parse($en) ){
    return $csv->fields();
  } elsif( $n==0 && $! eq '' ){
    print <<WARN;
Could not parse.
Possibly resolve by running 'dos2unix' on the input csv file...
Possibly resolve by checking the sep_char and quote_char in $0...
WARN
    exit;
  } else {
    $n++;
    print "Line($n) could not be parsed: $n -- $en. $!\n"; exit;
  }
}
sub cell_is_numeral {
  my ($m,$n,$d) = @_;
# 
# order of importance
#   is predominantly numeral - int (unsigned), decimal(N,D)
#   globally delete ',' and '+' (why would they be there?)
#     num AND '-' AND ('.' OR '.00') -> int
#     num AND '-' -> int
#     num only AND '-' AND NO('.') -> int
#   num only AND ('-' or ',')
# 
  $d =~ s/[\+,]//g;
  my ($isint,$isunsigned,$numlen,$denlen) = (0,1,0,0);
  if( $d=~/^\-/ ){
    # even one negative number found, should 
    # be (signed) int
    $isunsigned = 0;
  }
  if( $d=~/^(?:\-)?(\d+)(\.?0*)$/ ){
    # is an int
    $isint = 1;
    # also when 0s are on the RHS of a '.'
    #$isunsigned = 0 if defined $1;
    $numlen = length($1);
    $denlen = length($2)-1;
  } elsif( $d=~/^(?:\-)?(\d+)\.(\d+)$/ ){
    #print "$d -- $1-$2\n";
    # is NOT an integer because of a period.
    $numlen = length($1);
    $denlen = length($2);
  } else {
    print "Cell(m=$m,n=$n) seems an oddball... ($d)?\n"; exit;
  }
  #print "$isint,$isunsigned,$numlen,$denlen\n";
  return ($isint,$isunsigned,$numlen,$denlen);
}
sub cell_is_text {
  my ($m,$n,$s) = @_;
# 
# order of importance
#   is predominantly text - varchar, text, blob
#         char length<255   - varchar
#     255<char length<65535 - text
# 
# return ( istext,charlen );
  my $slen = length($s);
  if($slen>0){
    return length($s);
  } else {
    print "Cell(m=$m,n=$n) seems an oddball... ($s)?\n"; exit;
  }
}

