#!/bin/perl
use strict;
use 5.010;
use utf8;
use open qw(:std :utf8);

sub clr {
  my ($menu_title) = @_;

  system("clear");
  
  bar_top();
  label("Architect Installer by Ygypt");
  bar_mid();

  foreach (split(/\n/, `lsblk`)) {
    chomp($_);
    label($_);
  }
  
  bar_mid();
  label("$menu_title");
  bar_mid("-");
}

sub bar {
  my $symbol = "─";
  if (@_) { $symbol = @_[0]; }
  my $cols = `tput cols`;
  my $bar = "$symbol" x ($cols - 2);
  return $bar;
}

sub bar_flat  { say("━",bar(@_),"━"); }
sub bar_bot   { say("└",bar(@_),"┘"); }
sub bar_mid   { say("├",bar(@_),"┤"); }
sub bar_top   { say("┌",bar(@_),"┐"); }

sub label {
  my ($text) = @_;
  my $cols = `tput cols`;
  my $text_len = length($text);
  my $blank_len = $cols - $text_len - 3; # symbols on l/r and space on left
  my $blank_bar = " " x $blank_len;
  say("│ $text$blank_bar│");
}
sub label_full {
  my ($text) = @_;
  mkbar_top();
  label($text);
  mkbar_bot();
}


# main loop
while(1){
  clr("Main Menu");
  label("Create a partition for '/'. Do not create home, it will be a btrfs subvolume");
  label("Create a partition for '/efi' if it does not already exist");
  label("");
  label("What would you like to do?");
  label("1: Create disk partitions (cfdisk)");
  label("2: Format disk (mkfs)");
  bar_bot();
  print("Type number and press enter: ");

  chomp(my $menu = <>);
  
  if ($menu == 1) {
    partition_menu();
    next;
  }
  
  if ($menu == 2) {
    format_menu();
    next;
  }
}


sub partition_menu {
  while(1) {
    clr("Partition Menu");
    print("Type /dev/\'device name\' or type 'back': ");
    
    chomp(my $dev = <>);
    
    if ($dev eq "back") {
      return;
    }
    
    if (system("cfdisk $dev")) {
      print("Press enter to continue...");
      <>;
    }
  }
}


sub format_menu {
  while(1) {
    format_esp();
    format_root();
  }
}


sub format_esp {
  while(1) {
    clr("Format Menu - FAT32");
    label("First we will format the ESP to FAT32");
    bar_bot();
    
    say("(you may type 'skip' to skip this step)");
    print("Enter the /dev/device_name for ESP: ");
    
    chomp(my $dev = <>);
    
    if ($dev eq "skip") {
      return;
    }

    if (system("mkfs.fat -F32 $dev")) {
      print("Press enter to continue...");
      <>;
      next;
    }

    return;
  }
}


sub format_root {
  while(1) {
    clr("Format Menu - btrfs");
    label("Next we will format the btrfs partition");
    bar_bot();

    say("(you may type 'skip' to skip this step)");
    print("Enter the /dev/device_name for btrfs: ");
    
    chomp(my $dev = <>);
    
    if ($dev eq "skip") {
      return;
    }

    if (system("mkfs.btrfs $dev")) {
      print("Press enter to continue...");
      <>;
      next;
    }

    return;
  }
}






