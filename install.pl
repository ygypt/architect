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
  label("'create'     > Create disk partitions (cfdisk)");
  label("'format'     > Format disk (mkfs)");
  bar_bot();
  print("Type your command and press enter: ");

  chomp(my $cmd = <>);
  
  if ($cmd == 1) {
    partition_menu();
    next;
  }
  
  if ($cmd == 2) {
    format_menu();
    next;
  }
}


sub partition_menu {
  while(1) {
    clr("Partition Menu");
    label("Create a partition for the bootloader. If there is already a bootloader");
    label("on your machine, you may skip this step unless you expect to run out of");
    label("space in the partition. It is reccomended to allocate at least 1G to");
    label("dual boot systems.");
    label("");
    label("Next, create a partition for btrfs. The root/home split will be handeled");
    label("by btrfs subvolumes. Do not create a seperate home partition!");
    bar_bot();
    print("Type /dev/'device-name' or type 'back': ");
    
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
    clr("Format Menu");
    label("If the ESP was just created, I will need to format it to FAT32. If your");
    label("machine already has a bootloader, don't format it. Regardless, I will");
    label("need to format the main partition to btrfs.");
    label("")
    label("What would you like me to do?");
    label("> esp        select a drive to format to FAT32");
    label("> btrfs      select a drive to format to btrfs");
    label("> back")
    bar_bot();
    print("Type a command and press enter: ");

    chomp(my $cmd = <>);

    if ($dev eq "back") {
      return;
    }

    if ($cmd eq "esp") { format_esp(); }
    if ($cmd eq "btrfs") { format_root(); }
  }
}


sub format_esp {
  while(1) {
    clr("Format Menu - EFI System Partition");
    label("Can I format a partition to FAT32 for you?");
    label("> path/to/device");
    label("> back");
    bar_bot();
    print("Type a command and press enter: ");
    
    chomp(my $dev = <>);
    
    if ($dev eq "back") {
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
    clr("Format Menu - B-Tree Filesystem");
    label("Can I format a partition to btrfs for you?");
    label("> path/to/device");
    label("> back");
    bar_bot();
    print("Type a command and press enter: ");
    
    chomp(my $dev = <>);
    
    if ($dev eq "back") {
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






