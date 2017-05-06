from sdl2/sdl import getError

type
  SdlError* = object of Exception

proc raiseSdlError*() {.inline, raises: [SdlError], tags: [].} =
  raise newException(SdlError, $getError())

template sdlFatalIf*(cond: bool) =
  if cond: raiseSdlError()
