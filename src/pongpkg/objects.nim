#
#
#       Structures and functions to render and manage objects for Pong
#                       (c) Copyright 2017 Leorize
#
# See the file "LICENSE", included in this distribution, for details about
# copyright.
#

import sdl2/sdl, texLoader, options

type
  Object* = object
    ## 2D object with texture
    tex: Texture
    rect: Rect

proc w*(o: Object): cint {.noSideEffect.} = o.rect.w

proc h*(o: Object): cint {.noSideEffect.} = o.rect.h

proc x*(o: Object): cint {.noSideEffect.} = o.rect.x

proc y*(o: Object): cint {.noSideEffect.} = o.rect.y

proc `w=`*(o: var Object, w: cint) {.noSideEffect.} =
  o.rect.w = w

proc `h=`*(o: var Object, h: cint) {.noSideEffect.} =
  o.rect.h = h

proc `x=`*(o: var Object, x: cint) {.noSideEffect.} =
  o.rect.x = x

proc `y=`*(o: var Object, y: cint) {.noSideEffect.} =
  o.rect.y = y

proc getTexture*(o: Object): Texture {.noSideEffect.} = o.tex

proc initObject*(renderer: Renderer not nil, path: string): Option[Object]
                {.raises: [], tags: [IOEffect].} =
  var o: Object

  o.tex = renderer.loadTexture(path)

  if o.tex.isNil(): return
  if o.tex.queryTexture(nil, nil, o.rect.w.addr(), o.rect.h.addr()) < 0: return

  result = some(o)

proc draw*(renderer: Renderer not nil, o: var Object): cint
          {.noSideEffect.} =
  renderer.renderCopy(o.tex, nil, o.rect.addr())
