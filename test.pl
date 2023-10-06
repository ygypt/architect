#!/bin/perl
use strict;
use 5.010;

unless (system("mount | grep /poop")) {
  say("mount says that poop exist");
}
