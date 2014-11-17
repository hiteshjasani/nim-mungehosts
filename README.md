mungehosts
==========
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

## Usage with Docker

### 1. Add the tool to your image in your Dockerfile

```
ADD https://github.com/hiteshjasani/nim-mungehosts/releases/download/v0.1.0/mungehosts /usr/local/bin/mungehosts
RUN chmod 755 /usr/local/bin/mungehosts
```

### 2. When you run your container, run a startup script that invokes
mungehosts and updates your hosts file before running your server process.
See the section below on command line usage for examples.

#### Why can't I update /etc/hosts using the RUN command in a Dockerfile?

Unfortunately, Docker does not persist the `/etc/hosts` file between
`RUN` commands in Dockerfiles.  They only persist changes you make in
a running container.  Therefore, the recommended way to use this tool
is to have a startup script that runs when starting your Docker
container.  Inside this script, add lines running this tool before
starting your server process.

#### Why can't I simply use `sed` to modify `/etc/hosts`?

`sed` and similar tools actually write their changes to another temp
file and then attempt to move it over to `/etc/hosts`.  The problem with
this is that some process already has the file open and the move command
fails with a message similar to

```bash
sed: cannot rename /etc/sedl8ySxL: Device or resource busy
```

Mungehosts was written to bypass this problem.

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

### Add host mapping

To add a mapping for host `foo` at `192.168.0.1`

```bash
% sudo mungehosts -a "192.168.0.1  foo"
% cat /etc/hosts
127.0.0.1  localhost
192.168.0.1  foo
```

### Help

```bash
% mungehosts --help
```

## Dependencies

### Runtime
There are no runtime dependencies other than standard C.

```bash
% ldd ./mungehosts
        linux-vdso.so.1 =>  (0x00007fffbc9fd000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f7991f40000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f7991b7a000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f7992149000)
```

### Platforms

* Linux -- Full support, binary available in releases
* Other Unix -- Possibly works, you'll need to build the tool from source
* Windows -- no support

Basically the tool will work on any Unix platform with a `/etc/hosts` file.
There is a Linux binary in the releases, which I recommend using.

Building the tool from source is not recommended unless you have a high
pain tolerance and capacity for delayed gratification.  For those who still
want to do it, step 1 is installing a Nim compiler.

Sorry, there is no support for Windows.


