#
#
#       Structures and functions to render and manage objects for Pong
#                       (c) Copyright 2017 Leorize
#
# See the file "LICENSE", included in this distribution, for details about
# copyright.
#

import sdl2/sdl, texLoader, errors

type
  Object* = object
    ## 2D object with texture
    tex: Texture
    rect*: Rect

proc w*(o: Object): cint {.inline, noSideEffect.} = o.rect.w

proc h*(o: Object): cint {.inline, noSideEffect.} = o.rect.h

proc x*(o: Object): cint {.inline, noSideEffect.} = o.rect.x

proc y*(o: Object): cint {.inline, noSideEffect.} = o.rect.y

proc `x=`*(o: var Object, x: cint) {.inline, noSideEffect.} = o.rect.x = x

proc `y=`*(o: var Object, y: cint) {.inline, noSideEffect.} = o.rect.y = y

proc initObject*(renderer: Renderer not nil, path: string): Object
                {.raises: [SdlError], tags: [ReadIOEffect].} =
  result.tex = renderer.loadTexture(path)

  if result.tex.queryTexture(nil, nil, result.rect.w.addr(),
                             result.rect.h.addr()) < 0:
    result.tex.destroyTexture()
    raiseSdlError()

proc draw*(renderer: Renderer not nil, o: var Object)
          {.inline, raises: [SdlError], tags: [WriteIOEffect].} =
  sdlFatalIf: renderer.renderCopy(o.tex, nil, o.rect.addr()) < 0
