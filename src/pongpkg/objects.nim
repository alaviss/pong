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
    # 2D object with texture
    tex: Texture
    rect: ref Rect

proc w*(o: Object): cint {.noSideEffect.} = o.rect.w

proc h*(o: Object): cint {.noSideEffect.} = o.rect.h

proc x*(o: Object): cint {.noSideEffect.} = o.rect.x

proc y*(o: Object): cint {.noSideEffect.} = o.rect.y

proc `w=`*(o: Object, w: cint) {.noSideEffect.} =
  o.rect.w = w

proc `h=`*(o: Object, h: cint) {.noSideEffect.} =
  o.rect.h = h

proc `x=`*(o: Object, x: cint) {.noSideEffect.} =
  o.rect.x = x

proc `y=`*(o: Object, y: cint) {.noSideEffect.} =
  o.rect.y = y

proc getTexture*(o: Object): Texture {.noSideEffect.} = o.tex

proc initObject*(renderer: Renderer not nil, path: string): Option[Object]
                {.raises: [], tags: [IOEffect].} =
  var o: Object

  o.tex = renderer.loadTexture(path)

  o.rect = new(Rect)
  if o.tex.isNil(): return
  if o.tex.queryTexture(nil, nil, o.rect.w.addr(), o.rect.h.addr()) < 0: return

  result = some(o)

proc initObject*(tex: Texture not nil): Option[Object] {.noSideEffect.} =
  var o: Object

  o.tex = tex

  o.rect = new(Rect)
  if o.tex.isNil(): return
  if o.tex.queryTexture(nil, nil, o.rect.w.addr(), o.rect.h.addr()) < 0: return

  result = some(o)

proc initObject*(tex: Texture not nil,
                 x, y, w, h: Option[cint]): Option[Object] {.noSideEffect.} =
  var o: Object

  o.tex = tex

  o.rect = new(Rect)
  if isSome(w):
    o.rect.w = w.unsafeGet()
  elif o.tex.queryTexture(nil, nil, o.rect.w.addr(), nil) < 0:
    return
  if isSome(h):
    o.rect.h = h.unsafeGet()
  elif o.tex.queryTexture(nil, nil, nil, o.rect.h.addr()) < 0:
    return

  if isSome(x):
    o.rect.x = x.unsafeGet()
  if isSome(y):
    o.rect.y = y.unsafeGet()

  result = some(o)

proc draw*(renderer: Renderer not nil, o: Object): cint
          {.noSideEffect.} =
  renderer.renderCopy(o.tex, nil, o.rect[].addr())
