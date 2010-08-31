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

module GD2
  #
  # = Introduction
  #
  # Image is the abstract base class for Image::IndexedColor and
  # Image::TrueColor.
  #
  # == Creating and Importing
  #
  # Image objects are created either as a blank array of pixels:
  #
  #   image = Image::IndexedColor.new(width, height)
  #   image = Image::TrueColor.new(width, height)
  #
  # or by loading image data from a file or a string containing one of the
  # supported image formats:
  #
  #   image = Image.load(file)
  #   image = Image.load(string)
  #
  # or by importing image data from a file given by its pathname:
  #
  #    image = Image.import(filename)
  #
  # == Exporting
  #
  # After manipulating an image, it can be exported to a string in one of the
  # supported image formats:
  #
  #   image.jpeg(quality = nil)
  #   image.png(level = nil)
  #   image.gif
  #   image.wbmp(fgcolor)
  #   image.gd
  #   image.gd2(fmt = FMT_COMPRESSED)
  #
  # or to a file in a format determined by the filename extension:
  #
  #   image.export(filename, options = {})
  #
  class Image
    class UnrecognizedImageTypeError < StandardError; end

    attr_reader :image_ptr  #:nodoc:

    # The Palette object for this image
    attr_reader :palette

    include Enumerable

    # Create a new image of the specified dimensions. The default image class
    # is Image::TrueColor; call this method on Image::IndexedColor instead if
    # a palette image is desired.
    def self.new(w, h)
      image = (self == Image) ?
        TrueColor.new(w, h) : allocate.init_with_size(w, h)

      block_given? ? yield(image) : image
    end

    class << self
      alias [] new
    end

    # Load an image from a file or a string. The image type is detected
    # automatically (JPEG, PNG, GIF, WBMP, or GD2). The resulting image will be
    # either of class Image::TrueColor or Image::IndexedColor.
    def self.load(src)
      src = src.force_encoding("BINARY") if src.respond_to? :force_encoding
      case src
      when File
        pos = src.pos
        magic = src.read(4)
        src.pos = pos
        data = src.read
        data = data.force_encoding("BINARY") if data.respond_to? :force_encoding
        args = [ data.length, data ]
      when String
        magic = src
        args = [ src.length, src ]
      else
        raise TypeError, 'Unexpected argument type'
      end

      create = {
        :jpeg => :gdImageCreateFromJpegPtr,
        :png  => :gdImageCreateFromPngPtr,
        :gif  => :gdImageCreateFromGifPtr,
        :wbmp => :gdImageCreateFromWBMPPtr,
        :gd2  => :gdImageCreateFromGd2Ptr
      }

      type = data_type(magic) or
        raise UnrecognizedImageTypeError, 'Image data format is not recognized'
      ptr = GD2FFI.send(create[type], *args)
      raise LibraryError unless ptr

      ptr = FFIStruct::ImagePtr.new(ptr)

      image = (image_true_color?(ptr) ?
        TrueColor : IndexedColor).allocate.init_with_image(ptr)

      block_given? ? yield(image) : image
    end

    def self.data_type(str)
      ct = 0
      mgc = ""
      str.each_byte do |byte|
        break if ct == 4
        mgc << byte.to_s
        ct += 1
      end
      case mgc
      when "255216255224"
        :jpeg
      when "137807871"
        :png
      when "71737056"
        :gif
      when "001300"
        :wbmp
      when "103100500"
        :gd2
      end
    end
    private_class_method :data_type

    # Import an image from a file with the given +filename+. The :format option
    # or the file extension is used to determine the image type (jpeg, png,
    # gif, wbmp, gd, gd2, xbm, or xpm). The resulting image will be either of
    # class Image::TrueColor or Image::IndexedColor.
    #
    # If the file format is gd2, it is optionally possible to extract only a
    # part of the image. Use options :x, :y, :width, and :height to specify the
    # part of the image to import.
    def self.import(filename, options = {})
      raise Errno::ENOENT.new(filename) unless File.exists?(filename)

      unless format = options.delete(:format)
        md = filename.match(/\.([^.]+)\z/)
        format = md ? md[1].downcase : nil
      end
      format = format.to_sym if format

      ptr = # TODO: implement xpm and xbm imports
      #if format == :xpm
        #raise ArgumentError, "Unexpected options #{options.inspect}" unless options.empty?
        #GD2FFI.send(:gdImageCreateFromXpm, filename)
      #elsif format == :xbm
        #GD2FFI.send(:gdImageCreateFromXbm, filename)
      if format == :gd2 && !options.empty?
        x, y, width, height =
          options.delete(:x) || 0, options.delete(:y) || 0,
          options.delete(:width)  || options.delete(:w),
          options.delete(:height) || options.delete(:h)
        raise ArgumentError, "Unexpected options #{options.inspect}" unless
          options.empty?
        raise ArgumentError, 'Missing required option :width' if width.nil?
        raise ArgumentError, 'Missing required option :height' if height.nil?
        # TODO:
        ptr = File.open(filename, 'rb') do |file|
          GD2FFI.send(:gdImageCreateFromGd2Part, file, x.to_i, y.to_i, width.to_i, height.to_i)
        end
      else
        raise ArgumentError, "Unexpected options #{options.inspect}" unless
          options.empty?
        create_sym = {
          :jpeg => :gdImageCreateFromJpegPtr,
          :jpg  => :gdImageCreateFromJpegPtr,
          :png  => :gdImageCreateFromPngPtr,
          :gif  => :gdImageCreateFromGifPtr,
          :wbmp => :gdImageCreateFromWBMPPtr,
          :gd   => :gdImageCreateFromGdPtr,
          :gd2  => :gdImageCreateFromGd2Ptr
        }[format]
        raise UnrecognizedImageTypeError,
          'Format (or file extension) is not recognized' unless create_sym

        file = File.read(filename)
        file = file.force_encoding("BINARY") if file.respond_to? :force_encoding
        file_ptr = FFI::MemoryPointer.new(file.size, 1, false)
        file_ptr.put_bytes(0, file)

        GD2FFI.send(create_sym, file.size, file_ptr)
      end
      raise LibraryError unless ptr

      ptr = FFIStruct::ImagePtr.new(ptr)

      image = (image_true_color?(ptr) ?
        TrueColor : IndexedColor).allocate.init_with_image(ptr)

      block_given? ? yield(image) : image
    end

    def self.image_true_color?(ptr)
      not ptr[:trueColor].zero?
    end
    private_class_method :image_true_color?

    def self.create_image_ptr(sx, sy, alpha_blending = true)  #:nodoc:
      ptr = FFIStruct::ImagePtr.new(GD2FFI.send(create_image_sym, sx.to_i, sy.to_i))
      GD2FFI.send(:gdImageAlphaBlending, ptr, alpha_blending ? 1 : 0)
      ptr
    end

    def init_with_size(sx, sy)  #:nodoc:
      init_with_image self.class.create_image_ptr(sx, sy)
    end

    def init_with_image(ptr)  #:nodoc:
      @image_ptr = if ptr.is_a?(FFIStruct::ImagePtr)
        ptr
      else
        FFIStruct::ImagePtr.new(ptr)
      end

      @palette = self.class.palette_class.new(self) unless
        @palette && @palette.image == self
      self
    end

    def inspect   #:nodoc:
      "#<#{self.class} #{size.inspect}>"
    end

    # Duplicate this image, copying all pixels to a new image. Contrast with
    # Image#clone which produces a shallow copy and shares internal pixel data.
    def dup
      self.class.superclass.load(gd2(FMT_RAW))
    end

    # Compare this image with another image. Returns 0 if the images are
    # identical, otherwise a bit field indicating the differences. See the
    # GD2::CMP_* constants for individual bit flags.
    def compare(other)
      GD2FFI.send(:gdImageCompare, image_ptr, other.image_ptr)
    end

    # Compare this image with another image. Returns *false* if the images are
    # not identical.
    def ==(other)
      (compare(other) & CMP_IMAGE).zero?
    end

    # Return true if this image is a TrueColor image.
    def true_color?
      kind_of?(TrueColor)
      # self.class.image_true_color?(image_ptr)
    end

    # Return the width of this image, in pixels.
    def width
      image_ptr[:sx]
    end
    alias w width

    # Return the height of this image, in pixels.
    def height
      image_ptr[:sy]
    end
    alias h height

    # Return the size of this image as an array [_width_, _height_], in pixels.
    def size
      [width, height]
    end

    # Return the aspect ratio of this image, as a floating point ratio of the
    # width to the height.
    def aspect
      width.to_f / height
    end

    # Return the pixel value at image location (+x+, +y+).
    def get_pixel(x, y)
      GD2FFI.send(:gdImageGetPixel, @image_ptr, x.to_i, y.to_i)
    end
    alias pixel get_pixel

    # Set the pixel value at image location (+x+, +y+).
    def set_pixel(x, y, value)
      GD2FFI.send(:gdImageSetPixel, @image_ptr, x.to_i, y.to_i, value.to_i)
      nil
    end

    # Return the color of the pixel at image location (+x+, +y+).
    def [](x, y)
      pixel2color(get_pixel(x, y))
    end

    # Set the color of the pixel at image location (+x+, +y+).
    def []=(x, y, color)
      set_pixel(x, y, color2pixel(color))
    end

    # Iterate over each row of pixels in the image, returning an array of
    # pixel values.
    def each
      ptr = image_ptr
      (0...height).each do |y|
        row = (0...width).inject(Array.new(width)) do |row, x|
          row[x] = get_pixel(x, y)
          row
        end
        yield row
      end
    end

    # Return a Color object for the given +pixel+ value.
    def pixel2color(pixel)
      Color.new_from_rgba(pixel)
    end

    # Return a pixel value for the given +color+ object.
    def color2pixel(color)
      color.rgba
    end

    # Return *true* if this image will be stored in interlaced form when output
    # as PNG or JPEG.
    def interlaced?
      not image_ptr[:interlace].zero?
    end

    # Set whether this image will be stored in interlaced form when output as
    # PNG or JPEG.
    def interlaced=(bool)
      GD2FFI.send(:gdImageInterlace, image_ptr, bool ? 1 : 0)
    end

    # Return *true* if colors will be alpha blended into the image when pixels
    # are modified. Returns *false* if colors will be copied verbatim into the
    # image without alpha blending when pixels are modified.
    def alpha_blending?
      not image_ptr[:alphaBlendingFlag].zero?
    end

    # Set whether colors should be alpha blended with existing colors when
    # pixels are modified. Alpha blending is not available for IndexedColor
    # images.
    def alpha_blending=(bool)
      GD2FFI.send(:gdImageAlphaBlending, image_ptr, bool ? 1 : 0)
    end

    # Return *true* if this image will be stored with full alpha channel
    # information when output as PNG.
    def save_alpha?
      not image_ptr[:saveAlphaFlag].zero?
    end

    # Set whether this image will be stored with full alpha channel information
    # when output as PNG.
    def save_alpha=(bool)
      GD2FFI.send(:gdImageSaveAlpha, image_ptr, bool ? 1 : 0)
    end

    # Return the transparent color for this image, or *nil* if none has been
    # set.
    def transparent
      pixel = image_ptr[:transparent]
      pixel == -1 ? nil : pixel2color(pixel)
    end

    # Set or unset the transparent color for this image.
    def transparent=(color)
      GD2FFI.send(:gdImageColorTransparent, image_ptr,
        color.nil? ? -1 : color2pixel(color))
    end

    # Return the current clipping rectangle. Use Image#with_clipping to
    # temporarily modify the clipping rectangle.
    def clipping
      x1 = FFI::MemoryPointer.new(:pointer)
      y1 = FFI::MemoryPointer.new(:pointer)
      x2 = FFI::MemoryPointer.new(:pointer)
      y2 = FFI::MemoryPointer.new(:pointer)

      GD2FFI.send(:gdImageGetClip, image_ptr, x1, y1, x2, y2)
      [ x1.read_int, y1.read_int, x2.read_int, y2.read_int ]
    end

    # Temporarily set the clipping rectangle during the execution of a block.
    # Pixels outside this rectangle will not be modified by drawing or copying
    # operations.
    def with_clipping(x1, y1, x2, y2)   #:yields: image
      clip = clipping
      begin
        p clipping
        GD2FFI.send(:gdImageSetClip, image_ptr, x1.to_i, y1.to_i, x2.to_i, y2.to_i)
        p clipping
        yield self
        self
      ensure
        GD2FFI.send(:gdImageSetClip, image_ptr, *clip)
      end
    end

    # Return *true* if the current clipping rectangle excludes the given point.
    def clips?(x, y)
      GD2FFI.send(:gdImageBoundsSafe, image_ptr, x.to_i, y.to_i).zero?
    end

    # Provide a drawing environment for a block. See GD2::Canvas.
    def draw  #:yields: canvas
      yield Canvas.new(self)
      self
    end

    # Consolidate duplicate colors in this image, and eliminate all unused
    # palette entries. This only has an effect on IndexedColor images, and
    # is rather expensive. Returns the number of palette entries deallocated.
    def optimize_palette
      # implemented by subclass
    end

    # Export this image to a file with the given +filename+. The image format
    # is determined by the :format option, or by the file extension (jpeg, png,
    # gif, wbmp, gd, or gd2). Returns the size of the written image data.
    # Additional +options+ are as arguments for the Image#jpeg, Image#png,
    # Image#wbmp, or Image#gd2 methods.
    def export(filename, options = {})
      unless format = options.delete(:format)
        md = filename.match(/\.([^.]+)\z/)
        format = md ? md[1].downcase : nil
      end
      format = format.to_sym if format

      size = FFI::MemoryPointer.new(:pointer)

      case format
      when :jpeg, :jpg
        write_sym = :gdImageJpegPtr
        args = [ size, options.delete(:quality) || -1 ]
      when :png
        write_sym = :gdImagePngPtrEx
        args = [ size, options.delete(:level) || -1 ]
      when :gif
        write_sym = :gdImageGifPtr
        args = [ size ]
      when :wbmp
        write_sym = :gdImageWBMPPtr
        fgcolor = options.delete(:fgcolor)
        raise ArgumentError, 'Missing required option :fgcolor' if fgcolor.nil?
        args = [size, color2pixel(fgcolor)]
      when :gd
        write_sym = :gdImageGdPtr
        args = [ size ]
      when :gd2
        write_sym = :gdImageGd2Ptr
        args = [ options.delete(:chunk_size) || 0, options.delete(:fmt) || FMT_COMPRESSED, size ]
      else
        raise UnrecognizedImageTypeError,
          'Format (or file extension) is not recognized'
      end

      raise ArgumentError, "Unrecognized options #{options.inspect}" unless
        options.empty?

      File.open(filename, 'wb') do |file|
        begin
          img = GD2FFI.send(write_sym, image_ptr, *args)
          file.write(img.get_bytes(0, size.get_int(0)))
        ensure
          GD2FFI.gdFree(img)
        end
      end
    end

    # Encode and return data for this image in JPEG format. The +quality+
    # argument should be in the range 0–95, with higher quality values usually
    # implying both higher quality and larger sizes.
    def jpeg(quality = nil)
      size = FFI::MemoryPointer.new(:pointer)
      ptr = GD2FFI.send(:gdImageJpegPtr, image_ptr, size, quality || -1)
      ptr.get_bytes(0, size.get_int(0))
    ensure
      GD2FFI.send(:gdFree, ptr)
    end

    # Encode and return data for this image in PNG format. The +level+
    # argument should be in the range 0–9 indicating the level of lossless
    # compression (0 = none, 1 = minimal but fast, 9 = best but slow).
    def png(level = nil)
      size = FFI::MemoryPointer.new(:pointer)
      ptr = GD2FFI.send(:gdImagePngPtrEx, image_ptr, size, level.to_i || -1)
      ptr.get_bytes(0, size.get_int(0))
    ensure
      GD2FFI.send(:gdFree, ptr)
    end

    # Encode and return data for this image in GIF format. Note that GIF only
    # supports palette images; TrueColor images will be automatically converted
    # to IndexedColor internally in order to create the GIF. Use
    # Image#to_indexed_color to control this conversion more precisely.
    def gif
      size = FFI::MemoryPointer.new(:pointer)
      ptr = GD2FFI.send(:gdImageGifPtr, image_ptr, size)
      ptr.get_bytes(0, size.get_int(0))
    ensure
      GD2FFI.send(:gdFree, ptr)
    end

    # Encode and return data for this image in WBMP format. WBMP currently
    # supports only black and white images; the specified +fgcolor+ will be
    # used as the foreground color (black), and all other colors will be
    # considered “background” (white).
    def wbmp(fgcolor)
      size = FFI::MemoryPointer.new(:pointer)
      ptr = GD2FFI.send(:gdImageWBMPPtr, image_ptr, size, color2pixel(fgcolor))
      ptr.get_bytes(0, size.get_int(0))
    ensure
      GD2FFI.send(:gdFree, ptr)
    end

    # Encode and return data for this image in “.gd” format. This is an
    # internal format used by the gd library to quickly read and write images.
    def gd
      size = FFI::MemoryPointer.new(:pointer)
      ptr = GD2FFI.send(:gdImageGdPtr, image_ptr, size)
      ptr.get_bytes(0, size.get_int(0))
    ensure
      GD2FFI.send(:gdFree, ptr)
    end

    # Encode and return data for this image in “.gd2” format. This is an
    # internal format used by the gd library to quickly read and write images.
    # The specified +fmt+ may be either GD2::FMT_RAW or GD2::FMT_COMPRESSED.
    def gd2(fmt = FMT_COMPRESSED, chunk_size = 0)
      size = FFI::MemoryPointer.new(:pointer)
      ptr = GD2FFI.send(:gdImageGd2Ptr, image_ptr, chunk_size.to_i, fmt.to_i, size)
      ptr.get_bytes(0, size.get_int(0))
    ensure
      GD2FFI.send(:gdFree, ptr)
    end

    # Copy a portion of another image to this image. If +src_w+ and +src_h+ are
    # specified, the indicated portion of the source image will be resized
    # (and resampled) to fit the indicated dimensions of the destination.
    def copy_from(other, dst_x, dst_y, src_x, src_y,
        dst_w, dst_h, src_w = nil, src_h = nil)
      raise ArgumentError unless src_w.nil? == src_h.nil?
      if src_w
        GD2FFI.send(:gdImageCopyResampled, image_ptr, other.image_ptr,
          dst_x.to_i, dst_y.to_i, src_x.to_i, src_y.to_i, dst_w.to_i, dst_h.to_i, src_w.to_i, src_h.to_i)
      else
        GD2FFI.send(:gdImageCopy, image_ptr, other.image_ptr,
          dst_x.to_i, dst_y.to_i, src_x.to_i, src_y.to_i, dst_w.to_i, dst_h.to_i)
      end
      self
    end

    # Copy a portion of another image to this image, rotating the source
    # portion first by the indicated +angle+ (in radians). The +dst_x+ and
    # +dst_y+ arguments indicate the _center_ of the desired destination, and
    # may be floating point.
    def copy_from_rotated(other, dst_x, dst_y, src_x, src_y, w, h, angle)
      GD2FFI.send(:gdImageCopyRotated, image_ptr, other.image_ptr,
        dst_x.to_f, dst_y.to_f, src_x.to_i, src_y.to_i, w.to_i, h.to_i, angle.to_degrees.round.to_i)
      self
    end

    # Merge a portion of another image into this one by the amount specified
    # as +pct+ (a percentage). A percentage of 1.0 is identical to
    # Image#copy_from; a percentage of 0.0 is a no-op. Note that alpha
    # channel information from the source image is ignored.
    def merge_from(other, dst_x, dst_y, src_x, src_y, w, h, pct)
      GD2FFI.send(:gdImageCopyMerge, image_ptr, other.image_ptr,
        dst_x.to_i, dst_y.to_i, src_x.to_i, src_y.to_i, w.to_i, h.to_i, pct.to_percent.round.to_i)
      self
    end

    # Rotate this image by the given +angle+ (in radians) about the given axis
    # coordinates. Note that some of the edges of the image may be lost.
    def rotate!(angle, axis_x = width / 2.0, axis_y = height / 2.0)
      ptr = self.class.create_image_ptr(width, height, alpha_blending?)
      GD2FFI.send(:gdImageCopyRotated, ptr, image_ptr,
        axis_x.to_f, axis_y.to_f, 0, 0, width.to_i, height.to_i, angle.to_degrees.round.to_i)
      init_with_image(ptr)
    end

    # Like Image#rotate! except a new image is returned.
    def rotate(angle, axis_x = width / 2.0, axis_y = height / 2.0)
      clone.rotate!(angle, axis_x, axis_y)
    end

    # Crop this image to the specified dimensions, such that (+x+, +y+) becomes
    # (0, 0).
    def crop!(x, y, w, h)
      ptr = self.class.create_image_ptr(w, h, alpha_blending?)
      GD2FFI.send(:gdImageCopy, ptr, image_ptr, 0, 0, x.to_i, y.to_i, w.to_i, h.to_i)
      init_with_image(ptr)
    end

    # Like Image#crop! except a new image is returned.
    def crop(x, y, w, h)
      clone.crop!(x, y, w, h)
    end

    # Expand the left, top, right, and bottom borders of this image by the
    # given number of pixels.
    def uncrop!(x1, y1 = x1, x2 = x1, y2 = y1)
      ptr = self.class.create_image_ptr(x1 + width + x2, y1 + height + y2,
        alpha_blending?)
      GD2FFI.send(:gdImageCopy, ptr, image_ptr, x1.to_i, y1.to_i, 0, 0, width.to_i, height.to_i)
      init_with_image(ptr)
    end

    # Like Image#uncrop! except a new image is returned.
    def uncrop(x1, y1 = x1, x2 = x1, y2 = y1)
      clone.uncrop!(x1, y1, x2, y2)
    end

    # Resize this image to the given dimensions. If +resample+ is *true*,
    # the image pixels will be resampled; otherwise they will be stretched or
    # shrunk as necessary without resampling.
    def resize!(w, h, resample = true)
      ptr = self.class.create_image_ptr(w, h, false)
      GD2FFI.send(resample ? :gdImageCopyResampled : :gdImageCopyResized,
        ptr, image_ptr, 0, 0, 0, 0, w.to_i, h.to_i, width.to_i, height.to_i)
      alpha_blending = alpha_blending?
      init_with_image(ptr)
      self.alpha_blending = alpha_blending
      self
    end

    # Like Image#resize! except a new image is returned.
    def resize(w, h, resample = true)
      clone.resize!(w, h, resample)
    end

    # Transform this image into a new image of width and height +radius+ × 2,
    # in which the X axis of the original has been remapped to θ (angle) and
    # the Y axis of the original has been remapped to ρ (distance from center).
    # Note that the original image must be square.
    def polar_transform!(radius)
      raise 'Image must be square' unless width == height
      ptr = GD2FFI.send(:gdImageSquareToCircle, image_ptr, radius.to_i)
      raise LibraryError unless ptr
      init_with_image(ptr)
    end

    # Like Image#polar_transform! except a new image is returned.
    def polar_transform(radius)
      clone.polar_transform!(radius)
    end

    # Sharpen this image by +pct+ (a percentage) which can be greater than 1.0.
    # Transparency/alpha channel are not altered. This has no effect on
    # IndexedColor images.
    def sharpen(pct)
      self
    end

    # Return this image as a TrueColor image, creating a copy if necessary.
    def to_true_color
      self
    end

    # Return this image as an IndexedColor image, creating a copy if necessary.
    # +colors+ indicates the maximum number of palette colors to use, and
    # +dither+ controls whether dithering is used.
    def to_indexed_color(colors = MAX_COLORS, dither = true)
      ptr = GD2FFI.send(:gdImageCreatePaletteFromTrueColor,
        to_true_color.image_ptr, dither ? 1 : 0, colors.to_i)
      raise LibraryError unless ptr

      obj = IndexedColor.allocate.init_with_image(ptr)

      # fix for gd bug where image->open[] is not properly initialized
      (0...obj.image_ptr[:colorsTotal]).each do |i|
        obj.image_ptr[:open][i] = 0
      end

      obj
    end
  end

  #
  # = Description
  #
  # IndexedColor images select pixel colors indirectly through a palette of
  # up to 256 colors. Use Image#palette to access the associated Palette
  # object.
  #
  class Image::IndexedColor < Image
    def self.create_image_sym   #:nodoc:
      :gdImageCreate
    end

    def self.palette_class  #:nodoc:
      Palette::IndexedColor
    end

    def pixel2color(pixel)  #:nodoc:
      palette[pixel]
    end

    def color2pixel(color)  #:nodoc:
      color.from_palette?(palette) ? color.index : palette.exact!(color).index
    end

    def alpha_blending?   #:nodoc:
      false
    end

    def alpha_blending=(bool)   #:nodoc:
      raise 'Alpha blending mode not available for indexed color images' if bool
    end

    def optimize_palette  #:nodoc:
      # first map duplicate colors to a single palette index
      map, cache = palette.inject([{}, Array.new(MAX_COLORS)]) do |ary, color|
        ary.at(0)[color.rgba] = color.index
        ary.at(1)[color.index] = color.rgba
        ary
      end
      each_with_index do |row, y|
        row.each_with_index do |pixel, x|
          set_pixel(x, y, map[cache.at(pixel)])
        end
      end

      # now clean up the palette
      palette.deallocate_unused
    end

    def to_true_color   #:nodoc:
      sz = size
      obj = TrueColor.new(*sz)
      obj.alpha_blending = false
      obj.copy_from(self, 0, 0, 0, 0, *sz)
      obj.alpha_blending = true
      obj
    end

    def to_indexed_color(colors = MAX_COLORS, dither = true)  #:nodoc:
      palette.used <= colors ? self : super
    end

    # Like Image#merge_from except an optional final argument can be specified
    # to preserve the hue of the source by converting the destination pixels to
    # grey scale before the merge.
    def merge_from(other, dst_x, dst_y, src_x, src_y, w, h, pct, gray = false)
      return super(other, dst_x, dst_y, src_x, src_y, w, h, pct) unless gray
      GD2FFI.send(:gdImageCopyMergeGray, image_ptr, other.image_ptr,
        dst_x.to_i, dst_y.to_i, src_x.to_i, src_y.to_i, w.to_i, h.to_i, pct.to_percent.round.to_i)
      self
    end
  end

  #
  # = Description
  #
  # TrueColor images represent pixel colors directly and have no palette
  # limitations.
  #
  class Image::TrueColor < Image
    def self.create_image_sym   #:nodoc:
      :gdImageCreateTrueColor
    end

    def self.palette_class  #:nodoc:
      Palette::TrueColor
    end

    def sharpen(pct)  #:nodoc:
      GD2FFI.send(:gdImageSharpen, image_ptr, pct.to_percent.round.to_i)
      self
    end
  end
end
