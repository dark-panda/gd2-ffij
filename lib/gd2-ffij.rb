#
# Ruby/GD2 -- Ruby binding for gd 2 graphics library
#
# Copyright © 2005-2006 Robert Leslie, 2010 J Smith
#
# This file is part of Ruby/GD2.
#
# Ruby/GD2 is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ffi'
require 'rbconfig'

module GD2
  VERSION = '0.0.1'.freeze

  module GD2FFI
    def self.gd_library_name
      case Config::CONFIG['arch']
      when /darwin/
        'libgd.2.dylib'
      when /mswin32/, /cygwin/
        'bgd.dll'
      else
        'libgd.so.2'
      end
    end

    extend FFI::Library
    ffi_lib(*gd_library_name)

    {
      :gdImageCreate                      => [ :pointer,  :int, :int ],
      :gdImageCreateTrueColor             => [ :pointer,  :int, :int ],
      :gdImageCreatePaletteFromTrueColor  => [ :pointer,  :pointer, :int, :int ],
      :gdImageCreateFromJpeg              => [ :pointer,  :pointer ],
      :gdImageCreateFromJpegPtr           => [ :pointer,  :int, :pointer ],
      :gdImageCreateFromPng               => [ :pointer,  :pointer ],
      :gdImageCreateFromPngPtr            => [ :pointer,  :int, :pointer ],
      :gdImageCreateFromGif               => [ :pointer,  :pointer ],
      :gdImageCreateFromGifPtr            => [ :pointer,  :int, :pointer ],
      :gdImageCreateFromWBMP              => [ :pointer,  :pointer ],
      :gdImageCreateFromWBMPPtr           => [ :pointer,  :int, :pointer ],
      :gdImageCreateFromGd                => [ :pointer,  :pointer ],
      :gdImageCreateFromGdPtr             => [ :pointer,  :int, :pointer ],
      :gdImageCreateFromGd2               => [ :pointer,  :pointer ],
      :gdImageCreateFromGd2Ptr            => [ :pointer,  :int, :pointer ],
      :gdImageCreateFromGd2Part           => [ :pointer,  :pointer, :int, :int, :int, :int ],
      :gdImageCreateFromXbm               => [ :pointer,  :pointer ],
      :gdImageCreateFromXpm               => [ :pointer,  :pointer ],
      :gdImageCompare                     => [ :int,      :pointer, :pointer ],
      :gdImageJpeg                        => [ :void,     :pointer, :pointer, :int ],
      :gdImageJpegPtr                     => [ :pointer,  :pointer, :pointer, :int ],
      :gdImagePngEx                       => [ :void,     :pointer, :pointer, :int ],
      :gdImagePngPtrEx                    => [ :pointer,  :pointer, :pointer, :int ],
      :gdImageGif                         => [ :void,     :pointer, :pointer ],
      :gdImageGifPtr                      => [ :pointer,  :pointer, :pointer ],
      :gdImageWBMP                        => [ :void,     :pointer, :int, :pointer ],
      :gdImageWBMPPtr                     => [ :pointer,  :pointer, :pointer, :int ],
      :gdImageGd                          => [ :void,     :pointer, :pointer ],
      :gdImageGdPtr                       => [ :pointer,  :pointer, :pointer ],
      :gdImageGd2                         => [ :void,     :pointer, :pointer, :int, :int ],
      :gdImageGd2Ptr                      => [ :pointer,  :pointer, :int, :int, :pointer ],
      :gdImageDestroy                     => [ :void,     :pointer ],
      :gdImageSetPixel                    => [ :void,     :pointer, :int, :int, :int ],
      :gdImageGetPixel                    => [ :int,      :pointer, :int, :int ],
      :gdImageGetTrueColorPixel           => [ :int,      :pointer, :int, :int ],
      :gdImageLine                        => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      :gdImageRectangle                   => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      :gdImageFilledRectangle             => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      :gdImagePolygon                     => [ :void,     :pointer, :pointer, :int, :int ],
      :gdImageOpenPolygon                 => [ :void,     :pointer, :pointer, :int, :int ],
      :gdImageFilledPolygon               => [ :void,     :pointer, :pointer, :int, :int ],
      :gdImageArc                         => [ :void,     :pointer, :int, :int, :int, :int, :int, :int, :int ],
      :gdImageFilledArc                   => [ :void,     :pointer, :int, :int, :int, :int, :int, :int, :int, :int ],
  #   :gdImageEllipse                     => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      :gdImageFilledEllipse               => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      :gdImageFill                        => [ :void,     :pointer, :int, :int, :int ],
      :gdImageFillToBorder                => [ :void,     :pointer, :int, :int, :int, :int ],
      :gdImageSetClip                     => [ :void,     :pointer, :int, :int, :int, :int ],
      :gdImageGetClip                     => [ :void,     :pointer, :pointer, :pointer, :pointer, :pointer ],
      :gdImageBoundsSafe                  => [ :int,      :pointer, :int, :int ],
      :gdImageSetBrush                    => [ :void,     :pointer, :pointer ],
      :gdImageSetTile                     => [ :void,     :pointer, :pointer ],
      :gdImageSetAntiAliased              => [ :void,     :pointer, :int ],
      :gdImageSetAntiAliasedDontBlend     => [ :void,     :pointer, :int, :int ],
      :gdImageSetStyle                    => [ :void,     :pointer, :pointer, :int ],
      :gdImageSetThickness                => [ :void,     :pointer, :int ],
      :gdImageInterlace                   => [ :void,     :pointer, :int ],
      :gdImageAlphaBlending               => [ :void,     :pointer, :int ],
      :gdImageSaveAlpha                   => [ :void,     :pointer, :int ],
      :gdImageColorTransparent            => [ :void,     :pointer, :int ],
      :gdImageColorResolveAlpha           => [ :int,      :pointer, :int, :int, :int, :int ],
      :gdImageColorExactAlpha             => [ :int,      :pointer, :int, :int, :int, :int ],
      :gdImageColorClosestAlpha           => [ :int,      :pointer, :int, :int, :int, :int ],
      :gdImageColorClosestHWB             => [ :int,      :pointer, :int, :int, :int ],
      :gdImageColorAllocateAlpha          => [ :int,      :pointer, :int, :int, :int, :int ],
      :gdImageColorDeallocate             => [ :void,     :pointer, :int ],
      :gdAlphaBlend                       => [ :int,      :int, :int ],
      :gdImageCopy                        => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int ],
      :gdImageCopyResized                 => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int, :int, :int ],
      :gdImageCopyResampled               => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int, :int, :int ],
      :gdImageCopyRotated                 => [ :void,     :pointer, :pointer, :double, :double, :int, :int, :int, :int, :int ],
      :gdImageCopyMerge                   => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int, :int ],
      :gdImageCopyMergeGray               => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int, :int ],
      :gdImageSquareToCircle              => [ :pointer,  :pointer, :int ],
      :gdImageSharpen                     => [ :void,     :pointer, :int ],
      :gdImageChar                        => [ :void,     :pointer, :pointer, :int, :int, :int, :int ],
      :gdImageCharUp                      => [ :void,     :pointer, :pointer, :int, :int, :int, :int ],
      :gdImageString                      => [ :void,     :pointer, :pointer, :int, :int, :pointer, :int ],
      :gdImageStringUp                    => [ :void,     :pointer, :pointer, :int, :int, :pointer, :int ],
      :gdImageStringFTEx                  => [ :pointer,  :pointer, :pointer, :int, :pointer, :double, :double, :int, :int, :pointer, :pointer ],
      :gdImageStringFTCircle              => [ :pointer,  :pointer, :int, :int, :double, :double, :double, :pointer, :double, :pointer, :pointer, :int ],
      :gdFontGetSmall                     => [ :pointer ],
      :gdFontGetLarge                     => [ :pointer ],
      :gdFontGetMediumBold                => [ :pointer ],
      :gdFontGetGiant                     => [ :pointer ],
      :gdFontGetTiny                      => [ :pointer ],
      :gdFontCacheSetup                   => [ :int ],
      :gdFontCacheShutdown                => [ :void ],
      :gdFTUseFontConfig                  => [ :int,      :int ],
      :gdFree                             => [ :void,     :pointer ]
    }.each do |fun, ary|
      ret = ary.shift
      attach_function(fun, ary, ret)
    end
  end

  # Bit flags for Image#compare

  CMP_IMAGE         =   1  # Actual image IS different
  CMP_NUM_COLORS    =   2  # Number of Colours in pallette differ
  CMP_COLOR         =   4  # Image colours differ
  CMP_SIZE_X        =   8  # Image width differs
  CMP_SIZE_Y        =  16  # Image heights differ
  CMP_TRANSPARENT   =  32  # Transparent colour
  CMP_BACKGROUND    =  64  # Background colour
  CMP_INTERLACE     = 128  # Interlaced setting
  CMP_TRUECOLOR     = 256  # Truecolor vs palette differs

  # Format flags for Image#gd2

  FMT_RAW           =   1
  FMT_COMPRESSED    =   2

  # Color constants

  MAX_COLORS        = 256

  RGB_MAX           = 255

  ALPHA_MAX         = 127
  ALPHA_OPAQUE      =   0
  ALPHA_TRANSPARENT = 127

  class LibraryError < StandardError; end
end

require 'gd2/image'
require 'gd2/color'
require 'gd2/palette'
require 'gd2/canvas'
require 'gd2/font'
require 'gd2/ffi_struct'

class Numeric
  if not self.instance_methods.include? 'degrees'
    # Express an angle in degrees, e.g. 90.degrees. Angles are converted to
    # radians.
    def degrees
      self * 2 * Math::PI / 360
    end
    alias degree degrees
  end

  if not self.instance_methods.include? 'to_degrees'
    # Convert an angle (in radians) to degrees.
    def to_degrees
      self * 360 / Math::PI / 2
    end
  end

  if not self.instance_methods.include? 'percent'
    # Express a percentage, e.g. 50.percent. Percentages are floating point
    # values, e.g. 0.5.
    def percent
      self / 100.0
    end
  end

  if not self.instance_methods.include? 'to_percent'
    # Convert a number to a percentage value, e.g. 0.5 to 50.0.
    def to_percent
      self * 100
    end
  end
end
