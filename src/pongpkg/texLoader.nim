#
#
#                         Texture loader for Pong
#                        (c) Copyright 2017 Leorize
#
# See the file "LICENSE", included in this distribution, for details about
# copyright.
#

from sdl2/sdl import Texture, Renderer, createTextureFromSurface
import sdl2/sdl_image as img
import errors
export Texture

const
  SupportedFormat* = InitPng or InitJpg
    ## Supported texture format (PNG and JPG)

proc initTexLoader*(): cint {.inline.} = img.init(SupportedFormat)
  ## Initialize texture loader

proc quitTexLoader*() {.inline.} = img.quit()
  ## De-initialize texture loader

proc loadTexture*(renderer: Renderer not nil, file: string): Texture
                 {.raises: [SdlError], tags: [].} =
  ## Load a texture
  result = nil
  let surface = load(file)
  if surface.isNil(): raiseSdlError()

  result = renderer.createTextureFromSurface(surface)
