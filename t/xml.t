#!/usr/bin/perl

use HTML::Validator;

print "1..5\n";

my $doc = new HTML::Validator("t/valid.xml");

# testing that we got the doctype right
print "not " unless $doc->doctype =~ /^\[.*?\]$/s;

print "ok 1\n";


# testing that it really is an XML document

print "not " unless defined $doc->{XML};
print "ok 2\n";

$doc->validate;

# it should be valid as well - or otherwise we don't have XML support

if ($doc->{usexml} eq "NO") {
  print "ok 3 # skipped because no XML support\n";
}
else {
  print "not " unless $doc->is_valid;
  print "ok 3\n";
}
# the next document should be invalid

$doc->reset;
$doc->open("t/invalid.xml");
$doc->validate;

print "not " if $doc->is_valid;
print "ok 4\n";

if ($doc->{usexml} eq "NO") {
  print "ok 5 # skipped because no XML support\n";
}
else {
  print "not " unless $doc->errors =~ 
    /document type does not allow element "break" here/;

  print "ok 5\n";
}
