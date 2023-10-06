#!/bin/perl
use strict;
use 5.010;
use utf8;
use open qw(:std :utf8);

our $packages = "
base
base-devel
linux
linux-headers
linux-firmware
amd-ucode
mesa
pipewire
networkmanager
bluez
bluez-utils
ntfs-3g
grub
os-prober
efibootmgr
zsh
git
ranger
docker
timeshift
neovim
wayland
kitty
hyprland
";
#this is the only delimiter that doesnt fuck up my lsp
$packages =~ s#\n# #g; 


#################
### --------- ###
### main loop ###
### --------- ###
#################
while(1){
  clr("Main Menu");
  label("Create a partition for '/'. Do not create home, it will be a btrfs subvolume");
  label("Create a partition for '/efi' if it does not already exist");
  label("");
  label("What would you like me to do?");
  label(" 'partition'     Create disk partitions (cfdisk)");
  label(" 'format'        Format disk partitions (mkfs)");
  label(" 'mount'         Mount paritions to the current filesystem");
  label(" 'install'       Install that shit boi");
  label(" 'exit'");
  bar_bot();
  print("Type your command and press enter: ");

  chomp(my $cmd = <>);
 
  if ($cmd eq "partition") { partition_menu(); }
  if ($cmd eq "format") { format_menu(); }
  if ($cmd eq "mount") { mount_menu(); }
  if ($cmd eq "install") { install(); }
  if ($cmd eq "exit") {
    system("clear");
    last;
  }
}


sub install {
  clr("Install");
  
  if ( `mount | grep /mnt` eq ""
    or `mount | grep /mnt/efi` eq "") {
    label("You must mount /mnt, /mnt/efi, and /mnt/home");
    bar_bot();
    failure_dialog();
    return;
  }

  if (`mount | grep /mnt/home` eq "") {
    while(1) {
      label("You don't have a dedicated /home, is that okay?");
      bar_bot();
      print("y/n: ");

      chomp(my $cmd = <>);

      if ($cmd eq "y") { last; }
      if ($cmd eq "n") { return; }
    }
  }



  system("pacstrap -K /mnt $packages");
  system("genfstab -U /mnt >> /mnt/etc/fstab");
  # run my chroot script bc doing this in perl would be a headache
  system("zsh /root/architect/chroot.zsh");
  
  bar_top();
  label("Run 'arch-chroot /mnt'");
  label("Run 'passwd'");
  label("Run 'passwd kairo'");
  label("Run 'reboot'");
  bar_bot();

  exit();
}


################
### -------- ###
### graphics ###
### -------- ###
################
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


sub success_dialog {
  my $title = "Success!";
  if (@_) { $title = @_[0]; }
  clr($title);
  label("Success!");
  bar_bot();
  print("Press enter to continue...");
  <>;
}
sub failure_dialog {
  if (@_) {
    say(@_[0]);
  }
  print("Press enter to continue...");
  <>;
}




################
### -------- ###
### submenus ###
### -------- ###
################
sub partition_menu {
  while(1) {
    clr("Create Partitions");
    label("I can create a partition for your bootloader if you don't have one already. I can");
    label("recommend partitioning the remaining space as 'Linux Filesystem'");
    label("");
    label("May I create partitions on one of your devices?");
    label(" 'path/to/device'");
    label(" 'back'");
    bar_bot();
    print("Type your command and press enter: ");
    
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
    label("machine already has bootloader or home partitions, don't format them!");
    label("Anyways, I will need to format the remaining partitions to ext4.");
    label("");
    label("What would you like me to do?");
    label(" 'esp'     Select a partition to format to FAT32");
    label(" 'ext4'    Select a partition to format to ext4");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");

    chomp(my $cmd = <>);

    if ($cmd eq "esp")  { format_esp(); }
    if ($cmd eq "ext4") { format_ext4(); }
    if ($cmd eq "back") { return; }
  }
}


sub format_esp {
  my $title = "Format Partitions - EFI System Partition";
  while(1) {
    clr($title);
    label("May I format a partition to FAT32 for you?");
    label(" 'path/to/partition'");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");
    
    chomp(my $cmd = <>);
    
    if ($cmd eq "back") { return; }

    unless (system("mkfs.fat -F32 $cmd")) {
      success_dialog($title);
      next;
    }
     
    print("Something went wrong. Press enter to continue...");
    <>;
  }
}


sub format_ext4 {
  my $title = "Format Partitions - Ext4 Filesystem";
  while(1) {
    clr($title);
    label("May I format a partition to ext4 for you?");
    label(" 'path/to/partition'");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");
    
    chomp(my $cmd = <>);
    
    if ($cmd eq "back") { return; }
    unless (system("mkfs.ext4 $cmd")) { success_dialog($title); next; }

    failure_dialog();
  }
}




sub mount_menu {
  while(1) {
    clr("Mount Partitions");
    label("I will mount your partitions. Do these in order from top");
    label("to bottom. Shall I begin mounting?");
    label(" 'root'    Mount root partition first");
    label(" 'esp'     Mount bootloader to /efi");
    label(" 'home'    Mount home partition (optional)");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");

    chomp(my $cmd = <>);
    
    if ($cmd eq "root") { mount_root(); }
    if ($cmd eq "esp")  { mount_esp(); }
    if ($cmd eq "home") { mount_home(); }
    if ($cmd eq "back") { return; }
  }
}


sub mount_root {
  my $title = "Mount Partitions - Root";
  while(1) {
    clr($title);
    label("I need the partition path for your desired root");
    label(" '/path/to/partition'");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");

    chomp(my $cmd = <>);
    
    if ($cmd eq "back") { return; }
    unless (system("mount $cmd /mnt")) { success_dialog($title); return; }

    failure_dialog();
  }
}


sub mount_esp {
  my $title = "Mount Partitions - EFI System Partition";
  while(1) {
    clr($title);
    if (`mount | grep /mnt` eq "") {
      label("There is nothing mounted to /mnt");
      label("Because of this, the ESP cannot yet be mounted, as it");
      label("must be mounted to /mnt/efi");
      label("Please mount 'root' first.");
      bar_bot();
      failure_dialog();
      return;
    }
    label("I need the partition path for your desired esp");
    label(" '/path/to/partition'");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");

    chomp(my $cmd = <>);
    
    if ($cmd eq "back") { return; }

    unless (-d "/mnt/efi") { system("mkdir /mnt/efi"); }
    unless (system("mount $cmd /mnt/efi")) { success_dialog($title); return; }

    failure_dialog();
  }
}


sub mount_home {
  my $title = "Mount Partitions - Home Partition";
  while(1) {
    clr($title);
    if (`mount | grep /mnt` eq "") {
      label("There is nothing mounted to /mnt");
      label("Because of this, the home cannot yet be mounted, as it");
      label("must be mounted to /mnt/home");
      label("Please mount 'root' first.");
      bar_bot();
      failure_dialog();
      return;
    }
    label("I need the partition path for your desired home");
    label(" '/path/to/partition'");
    label(" 'back'");
    bar_bot();
    print("Type a command and press enter: ");

    chomp(my $cmd = <>);
    
    if ($cmd eq "back") { return; }
    unless (-d "/mnt/home") { system("mkdir /mnt/home"); }
    unless (system("mount $cmd /mnt/home")) { success_dialog($title); return; }

    failure_dialog();
  }
}







