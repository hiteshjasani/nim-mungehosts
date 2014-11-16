
import parseopt2, pegs, strutils

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

  Will change this line in /etc/hosts

  127.0.0.1    localhost

  to this line

  127.0.0.1  localhost kafka


Add a host mapping
  % mungehosts -a "192.168.0.1  router"

  Will add the following line to /etc/hosts

  192.168.0.1  router
"""

proc writeVersion*() = echo "0.1.0"

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
  var
    lines = readHosts()
    index = -1
    extra = ""
  for i in 0.. <lines.len:
    if lines[i] =~ peg"'127.0.0.1' \s+ 'localhost' {.*}":
      index = i
      extra = matches[0]
  if index >= 0:
    lines[index] = "127.0.0.1  localhost " & alias & extra
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




