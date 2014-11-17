
import parseopt2, pegs, strutils

proc writeVersion*() = echo "0.1.1"

proc writeHelp() = echo """
Alter /etc/hosts file with a new localhost alias or host mapping.

Usage:  mungehosts [ -l host_alias | -a host_mapping | -v | -h | -p ]

-l, --add-alias host_alias
    Add an alias that maps to localhost.

-a, --add-host host_mapping
    Add an IP to host mapping.

-v, --version
    Print software version.

-h, --help
    Print this information.

-p, --print
    Print /etc/hosts to stdout.


Sample Usage:

Add host alias for localhost
  % mungehosts -l kafka

  Will change these lines in /etc/hosts

  127.0.0.1    localhost
  ::1          localhost ip6-localhost ip6-loopback

  to this

  127.0.0.1    localhost kafka
  ::1          localhost ip6-localhost ip6-loopback kafka


Add a host mapping
  % mungehosts -a "192.168.0.1  router"

  Will add the following line to /etc/hosts

  192.168.0.1  router
"""

proc writeHosts*() = echo(readFile("/etc/hosts"))

proc updateFile(lines: openArray[string], addedLines: bool) =
  let
    extra = if addedLines: "\n" else: ""
    str = join(lines, "\n") & extra
  writeFile("/etc/hosts", str)

proc readHosts(): seq[string] =
  let raw = readFile("/etc/hosts")
  result = split(raw, '\L')

proc doAddAlias(alias: string) =
  let
    ip4 = peg"{'127.0.0.1' \s+ 'localhost'} {.*}"
    ip6 = peg"{'::1' \s+ 'localhost'} {.*}"
  var lines = readHosts()
  for i in 0.. <lines.len:
    if lines[i] =~ ip4:
      lines[i] = matches[0] & matches[1] & " " & alias
    if lines[i] =~ ip6:
      lines[i] = matches[0] & matches[1] & " " & alias
  updateFile(lines, false)

proc doAddHost(hostmap: string) =
  var lines = readHosts()
  lines.add(hostmap)
  updateFile(lines, true)



type TAction = enum undefined, addAlias, addHost

when isMainModule:
  var
    action: TAction = undefined
    arg: string

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      arg = key
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h": writeHelp(); quit()
      of "version", "v": writeVersion(); quit()
      of "add-alias", "l": action = addAlias
      of "add-host", "a": action = addHost
      of "print", "p": writeHosts(); quit()
      else: writeHelp(); quit()
    of cmdEnd: assert(false) # cannot happen

  case action:
  of undefined: writeHelp(); quit()
  of addAlias:
    if arg != nil:
      doAddAlias(arg)
    else:
      echo "Error:  Must provide an alias!"
      writeHelp()
      quit()
  of addHost:
    if arg != nil:
      doAddHost(arg)
    else:
      echo "Error:  Must provide a host mapping!"
      writeHelp()
      quit()




