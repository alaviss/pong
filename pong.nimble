# Package
version = "0.1.0"
author = "Leorize"
description = "Pong game clone in Nim."
license = "MIT"

# Dependencies
requires "nim >= 0.16.1", "sdl2_nim >= 0.96"

srcDir = "src"
skipDirs = @["res"]
bin = @["pong"]
