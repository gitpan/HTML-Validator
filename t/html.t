#!/usr/bin/perl

use HTML::Validator;

print "1..3\n";

my $doc = new HTML::Validator("t/valid.html");

$doc->validate;

# the document should be invalid in the first run

print "not " if $doc->is_valid;
print "ok 1\n";

# replacing the document type, it should be valid now

$doc = new HTML::Validator("t/valid.html");

$doc->doctype('html4');
$doc->validate;

print "not " unless $doc->is_valid;
print "ok 2\n";

# object reuse

$doc->reset;
$doc->open("t/invalid.html");
$doc->validate;

#print $doc->message,"\n";
print "not " if $doc->is_valid;
print "ok 3\n";

