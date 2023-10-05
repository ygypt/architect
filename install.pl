#!/bin/perl
use strict;
use 5.010;

sub clr() {
  my $cols = `tput cols`;
  my $bar = "─" x $cols;
  system("clear");
  say($bar);
  say("Architect Installer by Ygypt");
  say($bar);
  system("lsblk");
  say($bar);
}

# main loop
while(1){
  clr();
  say("Create a partition for '/'. Do not create home, it will be a btrfs subvolume");
  say("Create a partition for '/efi' if it does not already exist");
  say("");
  say("What would you like to do?");
  say("1: Edit disk \(cfdisk\)");
  say("2: Format disk");
  say("");
  print("Type number and press enter: ");

  chomp(my $menu = <>);
  if ($menu == 1) {
    cfdisk_menu();
  }
}

sub cfdisk_menu() {
  while(1) {
    clr();
    print("Type /dev/\'device name\' or type 'back': ");
    
    chomp(my $dev = <>);
    if ($dev eq "back") {
      return;
    }
    
    if (system("cfdisk $dev")) {
      print("Press enter to continue: ");
      <>;
    }
  }
}
