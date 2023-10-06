#!/bin/perl
use strict;
use 5.010;

my $str = "echo -e 'doing some \\nshit n127\.0\.0\.1\\'";

system("zsh \"echo -e 'doing some\\n shit 127\.0.0.1'\"");
