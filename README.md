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

+ root
+ user
+ pkg
+ boot
+ custom
+ full-install

##### ex:
```
root zen
```
runs `root` script with `rootconf/zen` as its argument

```
full-install --root zen --user kairo --pkg awesome --boot grub --custom dotfiles
```
runs all 5 scripts in the order specified, passing each respective conf
