#
#
#                           Pong game clone
#                     (c) Copyright 2017 Leorize
#
# See the file "LICENSE", included in this distribution, for details about
# copyright.
#

import sdl2/sdl
from os import unixToNativePath

const
  MainWin = (title: "Pong", x: WindowPosCentered, y: WindowPosCentered,
             w: 1280, h: 720, flags: 0'u32)

type
  SdlError = object of Exception

template sdlFatalIf*(cond: bool) =
  if cond:
    raise newException(SdlError, $sdl.getError())
  else: discard

when isMainModule:
  sdlFatalIf: sdl.init(InitVideo) < 0
  defer: sdl.quit()

  let window = createWindow(MainWin.title, MainWin.x, MainWin.y, MainWin.w,
                            MainWin.h, MainWin.flags);
  sdlFatalIf: window.isNil()
  defer: window.destroyWindow()

  let renderer = window.createRenderer(-1, 0)
  sdlFatalIf: renderer.isNil()
  defer: renderer.destroyRenderer()

  sdlFatalIf: renderer.renderSetLogicalSize(MainWin.w, MainWin.h) < 0

  let event = new(Event)

  block main:
    while true:
      while event[].addr().pollEvent() > 0:
        case event.kind
        of Quit: break main
        else: discard

      # Background
      sdlFatalIf: renderer.setRenderDrawColor(0, 0, 0, AlphaOpaque) < 0
      sdlFatalIf: renderer.renderClear() < 0

      # Show render result
      renderer.renderPresent()
