# frozen_string_literal: true; encoding: ASCII-8BIT

#
# See COPYRIGHT for license details.

require 'ffi'
require 'rbconfig'
require 'gd2/version'

module GD2
  class LibraryError < StandardError; end

  module GD2FFI

    ##
    # Search for the path to LibGD and return it.
    #
    # If global variable $GD2_LIBRARY_FULL_PATH is set and not nil, it
    # will be used as the path to the shared library.
    #
    # Otherwise, if environment variable GD2_LIBRARY_FULL_PATH is set
    # and not empty, it will be used as the path to the shared library.
    #
    # If neither of these are set to a valid path, search for the lib
    # based on the current platform.  On *nix platforms (including
    # macOS), a set of likely directories will be searched unless the
    # environment variable GD2_LIBRARY_PATH is set; in that case, its
    # value will be used as the *DIRECTORY* to search for the lib.
    #
    # The path to the found library is cached internally and returned by
    # subsequent calls, so filesystem changes will have no effect on
    # the result.
    #
    # If no library path is found, raises a LibraryError exception.
    def self.gd_library_name
      return @gd_library_name if defined?(@gd_library_name)

      # Check for the global
      @gd_library_name = $GD2_LIBRARY_FULL_PATH
      return @gd_library_name if @gd_library_name

      # Check for the environment variable
      @gd_library_name = ENV['GD2_LIBRARY_FULL_PATH']
      return @gd_library_name if @gd_library_name && @gd_library_name != ''

      # Otherwise, we look for the lib:

      # Is it cygwin?
      case RbConfig::CONFIG['host_os']
        when 'cygwin'
          @gd_library_name = 'cyggd-2.dll'

        # Or Windows with MinGW?
        when /mingw/
          ffi_convention(:stdcall)
          @gd_library_name = 'bgd.dll'

        # Otherwise, we assume something *nix-like
        else
          looks_like_mac_os = [
            RbConfig::CONFIG['arch'],
            RbConfig::CONFIG['host_os']
          ].detect { |c| c =~ /darwin/ }

          lib = looks_like_mac_os ? 'libgd.dylib' : 'libgd.so'

          # Let the user set a lib dir if they want to; otherwise, we
          # check the usual suspects.
          paths = [
            '/usr/local/{lib64,lib}',
            '/opt/local/{lib64,lib}',
            '/usr/{lib64,lib}',
            '/usr/lib/{x86_64,i386}-linux-gnu',
            '/usr/lib/arm-linux*'
          ]

          envpath = ENV['GD2_LIBRARY_PATH']

          paths = [envpath] if envpath && envpath != ''

          @gd_library_name = Dir.glob(paths.collect { |path| "#{path}/#{lib}{.*,}"}).first
      end

      raise LibraryError, 'Unable to find the LibGD dynamic library' unless @gd_library_name

      @gd_library_name
    end

    extend FFI::Library

    # rubocop:disable Layout/HashAlignment
    # rubocop:disable Style/HashSyntax
    # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets
    FFI_LAYOUT = {
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
      :gdImagePaletteCopy                 => [ :void,     :pointer, :pointer ],
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
      :gdImageColorAllocate               => [ :int,      :pointer, :int, :int, :int ],
      :gdImageColorAllocateAlpha          => [ :int,      :pointer, :int, :int, :int, :int ],
      :gdImageColorDeallocate             => [ :void,     :pointer, :int ],
      :gdImagePaletteToTrueColor          => [ :pointer,  :pointer],
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
      :gdImageGifAnimBeginPtr             => [ :pointer,  :pointer, :pointer, :int, :int ],
      :gdImageGifAnimBegin                => [ :void,     :pointer, :pointer, :int, :int ],
      :gdImageGifAnimAddPtr               => [ :pointer,  :pointer, :pointer, :int, :int, :int, :int, :int, :pointer ],
      :gdImageGifAnimAdd                  => [ :void,     :pointer, :pointer, :int, :int, :int, :int, :int, :pointer ],
      :gdImageGifAnimEnd                  => [ :void,     :pointer ],
      :gdImageGifAnimEndPtr               => [ :pointer,  :pointer ],
      :gdFontGetSmall                     => [ :pointer ],
      :gdFontGetLarge                     => [ :pointer ],
      :gdFontGetMediumBold                => [ :pointer ],
      :gdFontGetGiant                     => [ :pointer ],
      :gdFontGetTiny                      => [ :pointer ],
      :gdFontCacheSetup                   => [ :int ],
      :gdFontCacheShutdown                => [ :void ],
      :gdFTUseFontConfig                  => [ :int,      :int ],
      :gdFree                             => [ :void,     :pointer ]
    }.freeze
    # rubocop:enable Layout/SpaceInsideArrayLiteralBrackets
    # rubocop:enable Style/HashSyntax
    # rubocop:enable Layout/HashAlignment

    begin
      ffi_lib(gd_library_name)

      FFI_LAYOUT.each do |fun, ary|
        ret = ary.shift
        begin
          class_eval do
            attach_function(fun, ary, ret)
          end
        rescue FFI::NotFoundError
          # that's okay
        end
      end
    rescue LoadError, NoMethodError
      raise LoadError, "Couldn't load the gd2 library."
    end
  end

  # rubocop:disable Layout/SpaceAroundOperators
  # rubocop:disable Layout/ExtraSpacing

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
  # rubocop:enable Layout/ExtraSpacing
  # rubocop:enable Layout/SpaceAroundOperators

  GD2_BASE = File.join(File.dirname(__FILE__), 'gd2')

  autoload :Image, File.join(GD2_BASE, 'image')
  autoload :Color, File.join(GD2_BASE, 'color')
  autoload :Palette, File.join(GD2_BASE, 'palette')
  autoload :Canvas, File.join(GD2_BASE, 'canvas')
  autoload :Font, File.join(GD2_BASE, 'font')
  autoload :FFIStruct, File.join(GD2_BASE, 'ffi_struct')
  autoload :AnimatedGif, File.join(GD2_BASE, 'animated_gif')
end

class Numeric
  unless instance_methods.include? 'degrees'
    # Express an angle in degrees, e.g. 90.degrees. Angles are converted to
    # radians.
    def degrees
      self * 2 * Math::PI / 360
    end
    alias degree degrees
  end

  unless instance_methods.include? 'to_degrees'
    # Convert an angle (in radians) to degrees.
    def to_degrees
      self * 360 / Math::PI / 2
    end
  end

  unless instance_methods.include? 'percent'
    # Express a percentage, e.g. 50.percent. Percentages are floating point
    # values, e.g. 0.5.
    def percent
      self / 100.0
    end
  end

  unless instance_methods.include? 'to_percent'
    # Convert a number to a percentage value, e.g. 0.5 to 50.0.
    def to_percent
      self * 100
    end
  end
end
