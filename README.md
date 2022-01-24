# architect

*simple install scripts for arch*

### contents
##### configs:
rootconf
userconf
pkgconf
bootconf

##### scripts:
help

root
user
pkg
boot
full-install
  $rootconf $userconf $pkgconf $bootconf

##### ex:
```
root zen
```
runs `root` script with the `zen` config within
`rootconf` directory as its argument

full-install zen kairo awesome grub
