#
#
#                           Pong game clone
#                     (c) Copyright 2017 Leorize
#
# See the file "LICENSE", included in this distribution, for details about
# copyright.
#

import sdl2/sdl, pongpkg/[texLoader, objects], options
from os import unixToNativePath

const
  MainWin = (title: "Pong", x: WindowPosCentered, y: WindowPosCentered,
             w: 1280, h: 720, flags: 0'u32)
  AssetsDir = "res"
  PadTexPath = unixToNativePath(AssetsDir & "/pad.png")
  SepTexPath = unixToNativePath(AssetsDir & "/sep.png")
  BallTexPath = unixToNativePath(AssetsDir & "/ball.png")

type
  SdlError* = object of Exception

  Position = enum Left, Right

template sdlFatalIf*(cond: bool) =
  if cond:
    raise newException(SdlError, $sdl.getError())
  else: discard

proc fatalOnNone[T](opt: Option[T]): T {.raises: [SdlError], tags: [].} =
  if opt.isNone:
    raise newException(SdlError, $sdl.getError())
  else: result = opt.unsafeGet()

# Ugly hack to cope with Nim compiler poor not nil analysis
proc proveNotNil(p: Renderer): Renderer not nil
                {.raises: [SdlError], tags: [].} =
  if p.isNil():
    raise newException(SdlError, $sdl.getError())
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

  let
    sep = initObject(renderer, SepTexPath).fatalOnNone()
    ball = initObject(renderer, BallTexPath).fatalOnNone()

  pads[Left] = initObject(renderer, PadTexPath).fatalOnNone()
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
