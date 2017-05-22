#
#
#                           Pong game clone
#                     (c) Copyright 2017 Leorize
#
# See the file "LICENSE", included in this distribution, for details about
# copyright.
#

import sdl2/sdl, pongpkg/[texLoader, objects, errors], options, basic2d, times
from os import unixToNativePath

const
  MainWin = (title: "Pong", x: WindowPosCentered, y: WindowPosCentered,
             w: 1280, h: 720, flags: 0'u32)
  AssetsDir = "res"
  PadTexPath = unixToNativePath(AssetsDir & "/pad.png")
  SepTexPath = unixToNativePath(AssetsDir & "/sep.png")
  BallTexPath = unixToNativePath(AssetsDir & "/ball.png")

  # Speeds
  PadMaxSpeed = Vector2d(x: 0, y: 263)
    ## Paddle max speed (distance from center to edge)
  PadRawSpeed = Vector2d(x: 0, y: PadMaxSpeed.y)

type
  Position = enum Left, Right

# Ugly hack to cope with Nim compiler poor not nil analysis
proc proveNotNil(p: Renderer): Renderer not nil
                {.raises: [SdlError], tags: [].} =
  if p.isNil():
    raiseSdlError()
  else:
    result = p

proc collideWall(o: var Object) {.noSideEffect.} =
  if o.x < 0:
    o.x = 0
  elif (o.x.cint() + o.w) > MainWin.w:
    o.x = toFloat(MainWin.w - o.w)

  if o.y < 0:
    o.y = 0
  elif (o.y.cint() + o.h) > MainWin.h:
    o.y = toFloat(MainWin.h - o.h)

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
  pads[Left].y = (MainWin.h - pads[Left].h) / 2

  deepCopy(pads[Right], pads[Left])
  pads[Right].x = toFloat(MainWin.w - pads[Right].w)

  sep.x = (MainWin.w - sep.w) / 2
  sep.y = 0

  # Ball spawn at middle of player side
  ball.x = (MainWin.w - ball.w) / 4
  ball.y = (MainWin.h - ball.h) / 2

  var event: Event

  var timer = epochTime()
  block main:
    while true:
      while event.addr().pollEvent() > 0:
        case event.kind
        of KeyDown:
          case event.key.keysym.sym
          of KDown:
            if not (event.key.repeat > 0):
              pads[Left].speed = PadRawSpeed
          of KUp:
            if not (event.key.repeat > 0):
              pads[Left].speed = -PadRawSpeed
          else: discard
        of KeyUp:
          case event.key.keysym.sym
          of KDown, KUp:
            pads[Left].speed = Vector2d(x: 0, y: 0)
          else: discard
        of Quit: break main
        else: discard

      # Logic path
      # Pads movements
      let
        curTime = epochTime()
        step = curTime - timer
      pads[Left].move(step)
      pads[Left].collideWall()
      timer = curTime

      # Render path
      # Background
      sdlFatalIf: renderer.setRenderDrawColor(0, 0, 0, AlphaOpaque) < 0
      sdlFatalIf: renderer.renderClear() < 0

      # Seperator
      renderer.draw(sep)

      # Pads
      renderer.draw(pads[Left])
      renderer.draw(pads[Right])

      # Ball
      renderer.draw(ball)

      # Show render result
      renderer.renderPresent()
