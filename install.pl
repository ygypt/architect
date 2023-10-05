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
  label("What would you like me to do?");
  label(" 'create'    Create disk partitions (cfdisk)");
  label(" 'format'    Format disk partitions (mkfs)");
  label(" 'exit'");
  bar_bot();
  print("Type your command and press enter: ");

  chomp(my $cmd = <>);
 
  if ($cmd eq "create") { partition_menu(); }
  if ($cmd eq "format") { format_menu(); }
  if ($cmd eq "exit") {
    system("clear");
    last;
  }
}


sub partition_menu {
  while(1) {
    clr("Create Partitions");
    label("I can create a partition for your bootloader if you don't have one already. I can");
    label("also partition btrfs to your drive so that you can keep your files safe with snapshots");
    label("snapshots. Make sure not to partition home seperately! That's what subvolumes are for!");
    label("");
    label("May I create partitions on one of your devices?");
    label(" 'path/to/device'");
    label(" 'back'");
    bar_bot();
    print("Type /dev/'device-name' or type 'back': ");
    
    chomp(my $cmd = <>);
    
    if ($cmd eq "back") {
      return;
    }
    
    if (system("cfdisk $cmd")) {
      print("Press enter to continue...");
      <>;
    }
  }
}


sub format_menu {
  while(1) {
    clr("Format Partitions");
    label("If the ESP was just created, I will need to format it to FAT32. If your");
    label("machine already has a bootloader, don't format it. Regardless, I will");
    label("need to format the main partition to btrfs.");
    label("");
    label("What would you like me to do?");
    label(" 'esp'     Select a drive to format to FAT32");
    label(" 'btrfs'   Select a drive to format to btrfs");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");

    chomp(my $cmd = <>);

    if ($cmd eq "esp")    { format_esp(); }
    if ($cmd eq "btrfs")  { format_root(); }
    if ($cmd eq "back") {
      return;
    }
  }
}


sub format_esp {
  while(1) {
    clr("Format Menu - EFI System Partition");
    label("May I format a partition to FAT32 for you?");
    label(" 'path/to/device'");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");
    
    chomp(my $cmd = <>);
    
    if ($cmd eq "back") {
      return;
    }

    if (system("mkfs.fat -F32 $cmd")) {
      print("Press enter to continue...");
      <>;
      next;
    }

    return;
  }
}


sub format_root {
  while(1) {
    clr("Format Menu - B-Tree Filesystem");
    label("May I format a partition to btrfs for you?");
    label(" 'path/to/device'");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");
    
    chomp(my $cmd = <>);
    
    if ($cmd eq "back") {
      return;
    }

    if (system("mkfs.btrfs $cmd")) {
      print("Press enter to continue...");
      <>;
      next;
    }

    return;
  }
}






