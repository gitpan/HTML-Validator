#
# Makefile for HTML::Validator

require 5.004;
use ExtUtils::MakeMaker;

my $args = {
  NSGMLS    => '',
  SGMLCAT   => '#LIB#/sgml-lib/catalog',
  XHTMLCAT  => '#LIB#/xhtml1/DTD/xhtml.soc',
  XMLCAT    => '#LIB#/local/lib/xml/xml.soc',
  LIB       => '/usr/local',
  QUICK     => 'NO',
  XML       => 'ASK',
};

my @a;
my $prefix;

#----------------------------------------------------------------- 
# Go through the argument list
#----------------------------------------------------------------- 

while(my $arg = shift @ARGV) {
    
  if (my ($k,$v) = $arg =~ /^(.*?)=(.*?)$/) {
    if ($k eq "PREFIX") {
      $prefix = $v;
    }
    if (defined($args->{$k})) {
      $args->{$k} = $v;
    }
    else {
      push @a,$arg;
    }
  }
  elsif (my ($a) = $arg =~ /^-(.*?)$/) {
    $args->{QUICK} = 'YES' if $a eq "quick";
    $args->{XML} = 'NO' if $a eq "noxml";
  }
  else {
    push @a,$arg;
  }
}

my $quick = 1 if $args->{QUICK} eq 'YES';

#----------------------------------------------------------------- 
# Search for nsgmls from the path
#----------------------------------------------------------------- 

my $nsgmls;
my $dir;
my $splitchar = ($^O =~ /Win/i) ? ';' : ':';

my @path = split /$splitchar/, $ENV{PATH};

 FIND: foreach $dir (@path) {
   if (-x "$dir/nsgmls") {
     $nsgmls = "$dir/nsgmls";
     last FIND;
   }
 }

#----------------------------------------------------------------- 
# Put the libpath to the defaults
#----------------------------------------------------------------- 

my $k;
foreach $k (keys %$args) {
  if (defined $prefix) {
    $args->{$k} =~ s|#LIB#|$prefix/lib|;
  }
  else {
    $args->{$k} =~ s|#LIB#|$args->{LIB}/lib|;
  }
}

#----------------------------------------------------------------- 
# Check the arguments
#----------------------------------------------------------------- 

if ($quick) {
  $args->{NSGMLS} = $nsgmls;
  $args->{XML} = "NO";
}
else {
  my $a = askfile("nsgmls", $nsgmls);
  $args->{NSGMLS} = $a if defined $a;

  $a = askfile("SGML catalog file", $args->{SGMLCAT});
  $args->{SGMLCAT} = $a if defined $a;

  if ($args->{XML} eq "ASK") {
    if (ask("Do you want XML support ? [y/N]") =~ /^y/i) {
      $args->{XML} = "YES";
    }
    else {
      $args->{XML} = "NO";
    }
  }

  unless ($args->{XML} eq 'NO') {
    $a = askfile("XHTML catalog file", $args->{XHTMLCAT});
    $args->{XHMTLCAT} = $a if defined $a;
    $a = askfile("XML catalog file", $args->{XMLCAT});
    $args->{XMLCAT} = $a if defined $a;
  }
}

#----------------------------------------------------------------- 
#
#----------------------------------------------------------------- 

sub MY::dist_core {
    package MY; # so that "SUPER" works right
    my $inherited = shift->SUPER::dist_core(@_);
    $inherited =~ s/(dist : )/$1 validator_dummy /g; 
    $inherited;
}

sub MY::postamble {
    '
validator_dummy ::
	cp Validator.pm.dummy Validator.pm
';
}

#----------------------------------------------------------------- 
# Generate Validator.pm
#----------------------------------------------------------------- 

my $oldsep = $/;
undef $/;

open(IN,"Validator.pm.in") or die "Cannot open infile";

my $data = <IN>;
$/ = $oldsep;
close IN;

open(OUT,">Validator.pm") or die "Cannot open outfile";

print "Generating Validator.pm from Validator.pm.in\n";

foreach $key (keys %{$args}) {
#	print $key," => ", $args->{$key},"\n";
	$data =~ s/\@$key@/$args->{$key}/sg;
}

print OUT $data;
close OUT;

#----------------------------------------------------------------- 
# Write the Makefile
#----------------------------------------------------------------- 

@ARGV = @a;

WriteMakefile(
	      NAME         => 'HTML::Validator',
	      VERSION_FROM => 'Validator.pm',
	      PM           => { "Validator.pm" => '$(INST_LIBDIR)/Validator.pm'},	
	      EXE_FILES    => [ 'bin/validate' ],
#	      PREREQ_PM    => { LWP => 5.36, },
	      dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	     );

#----------------------------------------------------------------- 
# Ask the path for a file
#----------------------------------------------------------------- 

sub askfile {
    my ($text,$default) = @_;
    return $default if $quick;
    my $ans = ask(join('',"Please insert the path to the $text [", 
                       defined $default ? $default : "","] :"));
    
    $ans = $default if $ans =~ /^\s*$/;
    if (checkfile($ans)) {
        $ans;
    }
    else {
        undef;
    }
}

#----------------------------------------------------------------- 
# Check the existence of a file
#----------------------------------------------------------------- 

sub checkfile {
    my ($file) = @_;
    if (-f $file) {
        1;
    }
    elsif (ask(join('',"File '",$file,"' does not exist, ",
                     "do you want to use it anyway ? [Y/n]")) !~ /^n/i) {
        1;
    }
    else {
        0;
    }
}

#----------------------------------------------------------------- 
# Ask a question
#----------------------------------------------------------------- 

sub ask {
    my ($text) = @_;
    return "n" if $quick;
    print "$text ";
    my $ans = <>;
    chop $ans;
    return $ans;
}


