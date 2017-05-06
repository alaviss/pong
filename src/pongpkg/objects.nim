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
    rect: Rect

proc w*(o: Object): cint {.inline, noSideEffect.} = o.rect.w

proc h*(o: Object): cint {.inline, noSideEffect.} = o.rect.h

proc x*(o: Object): cint {.inline, noSideEffect.} = o.rect.x

proc y*(o: Object): cint {.inline, noSideEffect.} = o.rect.y

proc `w=`*(o: var Object, w: cint) {.inline, noSideEffect.} =
  o.rect.w = w

proc `h=`*(o: var Object, h: cint) {.inline, noSideEffect.} =
  o.rect.h = h

proc `x=`*(o: var Object, x: cint) {.inline, noSideEffect.} =
  o.rect.x = x

proc `y=`*(o: var Object, y: cint) {.inline, noSideEffect.} =
  o.rect.y = y

proc getTexture*(o: Object): Texture {.inline, noSideEffect.} = o.tex

proc initObject*(renderer: Renderer not nil, path: string): Object
                {.raises: [SdlError], tags: [IOEffect].} =
  result.tex = renderer.loadTexture(path)

  sdlFatalIf:
    result.tex.queryTexture(nil, nil, result.rect.w.addr(),
                            result.rect.h.addr()) < 0

proc draw*(renderer: Renderer not nil, o: var Object): cint
          {.inline, noSideEffect.} =
  renderer.renderCopy(o.tex, nil, o.rect.addr())
