#!/usr/bin/perl

use HTML::Validator;

print "1..4\n";

my $doc = new HTML::Validator("t/xhtml.html");

$doc->{subst_URL} = 1;

# testing doctype

print "not " if $doc->doctype ne 'PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"';

print "ok 1\n";

print "not" if $doc->{dtdfile} ne 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd';

print "ok 2\n";

# test URL working

$doc->validate;

print "not " if $doc->is_valid;

print "ok 3\n";

# test generated errors

if ($doc->{usexml} eq "NO") {
  print "ok 4 # skipped because no XML support\n";
}
else {
  print "not " unless $doc->errors =~ 
    /document type does not allow element "br" here/;
  print "ok 4\n";
}
