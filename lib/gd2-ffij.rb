# encoding: ASCII-8BIT
#
# Ruby/GD2 -- Ruby binding for gd 2 graphics library
#
# Copyright 2005-2006 Robert Leslie, 2010 J Smith
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
require 'gd2/version'

module GD2
  module GD2FFI
    def self.gd_library_name
      return @gd_library_name if defined?(@gd_library_name)

      @gd_library_name = if RbConfig::CONFIG['host_os'] == 'cygwin'
        'cyggd-2.dll'
      elsif RbConfig::CONFIG['host_os'] =~ /mingw/
        'bgd.dll'
      else
        paths = if ENV['GD2_LIBRARY_PATH']
          [ ENV['GD2_LIBRARY_PATH'] ]
        else
          [ '/usr/local/{lib64,lib}', '/opt/local/{lib64,lib}', '/usr/{lib64,lib}', '/usr/lib/{x86_64,i386}-linux-gnu' ]
        end

        lib = if [
          RbConfig::CONFIG['arch'],
          RbConfig::CONFIG['host_os']
        ].detect { |c| c =~ /darwin/ }
          'libgd.dylib'
        else
          'libgd.so'
        end

        Dir.glob(paths.collect { |path|
          "#{path}/#{lib}"
        }).first
      end
    end

    extend FFI::Library

    begin
      ffi_lib(*gd_library_name)
    rescue LoadError, NoMethodError
      raise LoadError.new("Couldn't load the gd2 library.")
    end

    {
      'gdImageCreate@8'                       => [ :pointer,  :int, :int ],
      'gdImageCreateTrueColor@8'              => [ :pointer,  :int, :int ],
      'gdImageCreatePaletteFromTrueColor@12'  => [ :pointer,  :pointer, :int, :int ],
      'gdImageCreateFromJpeg@4'               => [ :pointer,  :pointer ],
      'gdImageCreateFromJpegPtr@8'            => [ :pointer,  :int, :pointer ],
      'gdImageCreateFromPng@4'                => [ :pointer,  :pointer ],
      'gdImageCreateFromPngPtr@8'             => [ :pointer,  :int, :pointer ],
      'gdImageCreateFromGif@4'                => [ :pointer,  :pointer ],
      'gdImageCreateFromGifPtr@8'             => [ :pointer,  :int, :pointer ],
      'gdImageCreateFromWBMP@4'               => [ :pointer,  :pointer ],
      'gdImageCreateFromWBMPPtr@8'            => [ :pointer,  :int, :pointer ],
      'gdImageCreateFromGd@4'                 => [ :pointer,  :pointer ],
      'gdImageCreateFromGdPtr@8'              => [ :pointer,  :int, :pointer ],
      'gdImageCreateFromGd2@4'                => [ :pointer,  :pointer ],
      'gdImageCreateFromGd2Ptr@8'             => [ :pointer,  :int, :pointer ],
      'gdImageCreateFromGd2Part@20'           => [ :pointer,  :pointer, :int, :int, :int, :int ],
      'gdImageCreateFromXbm@4'                => [ :pointer,  :pointer ],
      'gdImageCreateFromXpm@4'                => [ :pointer,  :pointer ],
      'gdImageCompare@8'                      => [ :int,      :pointer, :pointer ],
      'gdImageJpeg@12'                        => [ :void,     :pointer, :pointer, :int ],
      'gdImageJpegPtr@12'                     => [ :pointer,  :pointer, :pointer, :int ],
      'gdImagePngEx@12'                       => [ :void,     :pointer, :pointer, :int ],
      'gdImagePngPtrEx@12'                    => [ :pointer,  :pointer, :pointer, :int ],
      'gdImageGif@8'                          => [ :void,     :pointer, :pointer ],
      'gdImageGifPtr@8'                       => [ :pointer,  :pointer, :pointer ],
      'gdImageWBMP@12'                        => [ :void,     :pointer, :int, :pointer ],
      'gdImageWBMPPtr@12'                     => [ :pointer,  :pointer, :pointer, :int ],
      'gdImageGd@8'                           => [ :void,     :pointer, :pointer ],
      'gdImageGdPtr@8'                        => [ :pointer,  :pointer, :pointer ],
      'gdImageGd2@16'                         => [ :void,     :pointer, :pointer, :int, :int ],
      'gdImageGd2Ptr@16'                      => [ :pointer,  :pointer, :int, :int, :pointer ],
      'gdImageDestroy@4'                      => [ :void,     :pointer ],
      'gdImageSetPixel@16'                    => [ :void,     :pointer, :int, :int, :int ],
      'gdImageGetPixel@12'                    => [ :int,      :pointer, :int, :int ],
      'gdImageGetTrueColorPixel@12'           => [ :int,      :pointer, :int, :int ],
      'gdImageLine@24'                        => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      'gdImageRectangle@24'                   => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      'gdImageFilledRectangle@24'             => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      'gdImagePolygon@16'                     => [ :void,     :pointer, :pointer, :int, :int ],
      'gdImageOpenPolygon@16'                 => [ :void,     :pointer, :pointer, :int, :int ],
      'gdImageFilledPolygon@16'               => [ :void,     :pointer, :pointer, :int, :int ],
      'gdImageArc@32'                         => [ :void,     :pointer, :int, :int, :int, :int, :int, :int, :int ],
      'gdImageFilledArc@36'                   => [ :void,     :pointer, :int, :int, :int, :int, :int, :int, :int, :int ],
  #   'gdImageEllipse@??'                     => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      'gdImageFilledEllipse@24'               => [ :void,     :pointer, :int, :int, :int, :int, :int ],
      'gdImageFill@16'                        => [ :void,     :pointer, :int, :int, :int ],
      'gdImageFillToBorder@20'                => [ :void,     :pointer, :int, :int, :int, :int ],
      'gdImageSetClip@20'                     => [ :void,     :pointer, :int, :int, :int, :int ],
      'gdImageGetClip@20'                     => [ :void,     :pointer, :pointer, :pointer, :pointer, :pointer ],
      'gdImageBoundsSafe@12'                  => [ :int,      :pointer, :int, :int ],
      'gdImageSetBrush@8'                     => [ :void,     :pointer, :pointer ],
      'gdImageSetTile@8'                      => [ :void,     :pointer, :pointer ],
      'gdImageSetAntiAliased@8'               => [ :void,     :pointer, :int ],
      'gdImageSetAntiAliasedDontBlend@12'     => [ :void,     :pointer, :int, :int ],
      'gdImageSetStyle@12'                    => [ :void,     :pointer, :pointer, :int ],
      'gdImageSetThickness@8'                 => [ :void,     :pointer, :int ],
      'gdImageInterlace@8'                    => [ :void,     :pointer, :int ],
      'gdImageAlphaBlending@8'                => [ :void,     :pointer, :int ],
      'gdImageSaveAlpha@8'                    => [ :void,     :pointer, :int ],
      'gdImageColorTransparent@8'             => [ :void,     :pointer, :int ],
      'gdImageColorResolveAlpha@20'           => [ :int,      :pointer, :int, :int, :int, :int ],
      'gdImageColorExactAlpha@20'             => [ :int,      :pointer, :int, :int, :int, :int ],
      'gdImageColorClosestAlpha@20'           => [ :int,      :pointer, :int, :int, :int, :int ],
      'gdImageColorClosestHWB@16'             => [ :int,      :pointer, :int, :int, :int ],
      'gdImageColorAllocateAlpha@20'          => [ :int,      :pointer, :int, :int, :int, :int ],
      'gdImageColorDeallocate@8'              => [ :void,     :pointer, :int ],
      'gdAlphaBlend@8'                        => [ :int,      :int, :int ],
      'gdImageCopy@32'                        => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int ],
      'gdImageCopyResized@40'                 => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int, :int, :int ],
      'gdImageCopyResampled@40'               => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int, :int, :int ],
      'gdImageCopyRotated@44'                 => [ :void,     :pointer, :pointer, :double, :double, :int, :int, :int, :int, :int ],
      'gdImageCopyMerge@36'                   => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int, :int ],
      'gdImageCopyMergeGray@36'               => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :int, :int ],
      'gdImageSquareToCircle@8'               => [ :pointer,  :pointer, :int ],
      'gdImageSharpen@8'                      => [ :void,     :pointer, :int ],
      'gdImageChar@24'                        => [ :void,     :pointer, :pointer, :int, :int, :int, :int ],
      'gdImageCharUp@24'                      => [ :void,     :pointer, :pointer, :int, :int, :int, :int ],
      'gdImageString@24'                      => [ :void,     :pointer, :pointer, :int, :int, :pointer, :int ],
      'gdImageStringUp@24'                    => [ :void,     :pointer, :pointer, :int, :int, :pointer, :int ],
      'gdImageStringFTEx@48'                  => [ :pointer,  :pointer, :pointer, :int, :pointer, :double, :double, :int, :int, :pointer, :pointer ],
      'gdImageStringFTCircle@60'              => [ :pointer,  :pointer, :int, :int, :double, :double, :double, :pointer, :double, :pointer, :pointer, :int ],
      'gdFontGetSmall@0'                      => [ :pointer ],
      'gdFontGetLarge@0'                      => [ :pointer ],
      'gdFontGetMediumBold@0'                 => [ :pointer ],
      'gdFontGetGiant@0'                      => [ :pointer ],
      'gdFontGetTiny@0'                       => [ :pointer ],
      'gdFontCacheSetup@0'                    => [ :int ],
      'gdFontCacheShutdown@0'                 => [ :void ],
      'gdFTUseFontConfig@4'                    => [ :int,      :int ],
      'gdFree@4'                              => [ :void,     :pointer ]
    }.each do |fun, ary|
	  rfun = fun.split('@')[0]
	  fun = rfun unless RbConfig::CONFIG['host_os'] =~ /mingw/
      ret = ary.shift
      attach_function(rfun, fun, ary, ret)
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
