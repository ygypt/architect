#!/bin/zsh
NOC='\033[0m'       # Reset
BLA='\033[0;30m'    # Black
RED='\033[0;31m'    # Red
GRE='\033[0;32m'    # Green
YEL='\033[0;33m'    # Yellow
BLU='\033[0;34m'    # Blue
PUR='\033[0;35m'    # Purple
CYA='\033[0;36m'    # Cyan
WHI='\033[0;37m'    # White

cat << EOF | arch-chroot /mnt
  ln -sf /usr/share/zoneinfo/UTC /etc/localtime
  hwclock --systohc
  echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
  locale-gen
  touch /etc/locale.conf
  echo LANG=en_US.UTF-8 >> /etc/locale.conf
  echo KEYMAP=us >> /etc/vconsole.conf
  touch /etc/hostname
  echo -e "GameCuboid" >> /etc/hostname
  touch /etc/hosts
  echo -e "127.0.0.1\tlocalhost\n::\t\tlocalhost\n127.0.0.1\tGameCuboid" | tee /etc/hosts
  useradd -m kairo -s /bin/zsh
  echo "%kairo ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo
  touch /etc/systemd/system/getty@tty1.service.d/autologin.conf
  echo -e "Environment=XDG_SESSION_TYPE=x11\n[Service]\nExecStart=\nExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin kairo %I $TERM" | tee /etc/systemd/system/getty@tty1.service.d/autologin.conf
  systemctl enable NetworkManager.service
  grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Grub --removable
  echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
  grub-mkconfig -o /boot/grub/grub.cfg
  grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Grub --removable
  chsh -s /bin/zsh
EOF
