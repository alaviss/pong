#
#
#                           Pong game clone
#                     (c) Copyright 2017 Leorize
#
# See the file "LICENSE", included in this distribution, for details about
# copyright.
#

import sdl2/sdl, pongpkg/[texLoader, objects, errors], options
from os import unixToNativePath

const
  MainWin = (title: "Pong", x: WindowPosCentered, y: WindowPosCentered,
             w: 1280, h: 720, flags: 0'u32)
  AssetsDir = "res"
  PadTexPath = unixToNativePath(AssetsDir & "/pad.png")
  SepTexPath = unixToNativePath(AssetsDir & "/sep.png")
  BallTexPath = unixToNativePath(AssetsDir & "/ball.png")

type
  Position = enum Left, Right

# Ugly hack to cope with Nim compiler poor not nil analysis
proc proveNotNil(p: Renderer): Renderer not nil
                {.raises: [SdlError], tags: [].} =
  if p.isNil():
    raiseSdlError()
  else:
    result = p

when isMainModule:
  sdlFatalIf: sdl.init(InitVideo) < 0
  defer: sdl.quit()
  sdlFatalIf: initTexLoader() < 0
  defer: quitTexLoader()

  let window = createWindow(MainWin.title, MainWin.x, MainWin.y, MainWin.w,
                            MainWin.h, MainWin.flags);
  sdlFatalIf: window.isNil()
  defer: window.destroyWindow()

  let renderer = window.createRenderer(-1, 0).proveNotNil()
  defer: renderer.destroyRenderer()

  sdlFatalIf: renderer.renderSetLogicalSize(MainWin.w, MainWin.h) < 0

  var
    pads: array[Position, Object]
    sep = initObject(renderer, SepTexPath)
    ball = initObject(renderer, BallTexPath)

  pads[Left] = initObject(renderer, PadTexPath)
  pads[Left].x = 0
  pads[Left].y = MainWin.h div 2 - pads[Left].h div 2

  deepCopy(pads[Right], pads[Left])
  pads[Right].x = MainWin.w - pads[Right].w

  sep.x = MainWin.w div 2 - sep.w div 2
  sep.y = 0

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

      # Seperator
      sdlFatalIf: renderer.draw(sep) < 0

      # Pads
      sdlFatalIf: renderer.draw(pads[Left]) < 0
      sdlFatalIf: renderer.draw(pads[Right]) < 0

      # Show render result
      renderer.renderPresent()
