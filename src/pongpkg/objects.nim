#
#
#       Structures and functions to render and manage objects for Pong
#                       (c) Copyright 2017 Leorize
#
# See the file "LICENSE", included in this distribution, for details about
# copyright.
#

import sdl2/sdl, texLoader, errors, basic2d
export Vector2d

type
  Object* = object
    ## 2D object with texture
    tex: Texture
    x*, y*: float
    w*, h*: cint
    speed*: Vector2d

proc move*(o: var Object, timeStep: float) {.inline, noSideEffect.} =
  o.x += o.speed.x * timeStep
  o.y += o.speed.y * timeStep

proc initObject*(renderer: Renderer not nil, path: string): Object
                {.raises: [SdlError], tags: [ReadIOEffect].} =
  result.tex = renderer.loadTexture(path)

  if result.tex.queryTexture(nil, nil, result.w.addr(),
                             result.h.addr()) < 0:
    result.tex.destroyTexture()
    raiseSdlError()

proc draw*(renderer: Renderer not nil, o: Object)
          {.inline, raises: [SdlError], tags: [WriteIOEffect].} =
  var r = Rect(x: o.x.cint(), y: o.y.cint(), w: o.w, h: o.h)
  sdlFatalIf: renderer.renderCopy(o.tex, nil, r.addr()) < 0
