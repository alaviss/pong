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
export Texture

const
  SupportedFormat* = InitPng or InitJpg
    ## Supported texture format (PNG or JPG)

template initTexLoader*(): cint = img.init(SupportedFormat)
  ## Initialize texture loader

template quitTexLoader*() = img.quit()
  ## De-initialize texture loader

proc loadTexture*(renderer: Renderer not nil, file: string): Texture
                 {.raises: [], tags: [].} =
  ## Load a texture
  result = nil
  let surface = load(file)
  if surface.isNil(): return

  result = renderer.createTextureFromSurface(surface)
