nim-mungehosts
==============
Mungehosts is a tool to enable programmatically altering the `/etc/hosts` file
from the Linux command line.  Run with arguments, the tool can add aliases
for localhost and add new IP-to-host mappings.  This means you can embed
hosts file changes into your scripts -- altering the hosts file on machine
startup is a good example.

The reason this was created was due to Docker not providing any way to do this
using the Dockerfile syntax.  I was building a Dockerfile that had a multi-process
server inside of it.  One process expected to be able to communicate to
another process, whose hostname it received from Zookeeper.  However, the hosts
file did not have a mapping for that other hostname.  To make it work,
required aliasing localhost to this other hostname.

## Command line usage

Grab the Linux binary from releases.  It's an executable with no additional
dependencies than the normal C runtime so it'll work on any Linux platform.

### Aliasing localhost

To alias the hostname `foo` to `localhost`.

```bash
% sudo mungehosts -l foo
```

Will result in

```bash
127.0.0.1  localhost foo
```

Any existing aliases will be preserved, so running the command again
with trying to alias `bar` will result in

```bash
% sudo mungehosts -l bar
% cat /etc/hosts
127.0.0.1  localhost bar foo
```

### Help

```bash
% mungehosts --help
```

### Dependencies

There are no runtime dependencies other than standard C.

```bash
# ldd ./mungehosts
        linux-vdso.so.1 =>  (0x00007fffbc9fd000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f7991f40000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f7991b7a000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f7992149000)
```

## Platforms

Basically the tool will work on any Unix platform with a `/etc/hosts` file.
There is a Linux binary in the releases, which I recommend using.

Building the tool from source is not recommended unless you have a high
pain tolerance and capacity for delayed gratification.  For those who still
want to do it, step 1 is installing a Nim compiler.

Sorry, there is no support for Windows.


