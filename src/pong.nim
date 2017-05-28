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

  BallSpeed = Vector2d(x: 136, y: 0) # Distance from ball spawn to pad

type
  Position = enum Left, Right
  Axis {.pure.} = enum X, Y

# Ugly hack to cope with Nim compiler poor not nil analysis
proc proveNotNil(p: Renderer): Renderer not nil
                {.raises: [SdlError], tags: [].} =
  if p.isNil():
    raiseSdlError()
  else:
    result = p

proc collideWall(o: Object): set[Axis]
                {.noSideEffect.} =
  ## Returns the wall axises that the object has collided with
  result = {}

  if (o.x < 0) or (o.x.cint() + o.w) > MainWin.w:
    result.incl(Axis.X)

  if (o.y < 0) or (o.y.cint() + o.h) > MainWin.h:
    result.incl(Axis.Y)

proc wallCollideFix(o: var Object, axises: set[Axis]) {.noSideEffect.} =
  ## Move an object to it's collision point with the wall given the axises
  if Axis.X in axises:
    if o.x < 0:
      o.x = 0
    else:
      o.x = toFloat(MainWin.w - o.w)

  if Axis.Y in axises:
    if o.y < 0:
      o.y = 0
    else:
      o.y = toFloat(MainWin.h - o.h)

proc consumeBall(o: var Object) {.noSideEffect.} =
  ## Respawn ball to center of consumed side with velocity toward wall
  o.y = (MainWin.h - o.h) / 2

  if (o.x + o.w.toFloat() - MainWin.w.toFloat()) > 0:
    o.x = MainWin.w.toFloat() * 0.75 - o.w.toFloat() * 0.5
  else:
    o.x = toFloat(MainWin.w - o.w) * 0.25

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

  ball.speed = -BallSpeed # Ball falls to player paddle

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
      pads[Left].wallCollideFix(pads[Left].collideWall())

      ball.move(step)
      let ballCollideWall = ball.collideWall()
      if Axis.X in ballCollideWall:
        ball.consumeBall()
      elif Axis.Y in ballCollideWall:
        ball.speed.rotate(degToRad(45))

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
