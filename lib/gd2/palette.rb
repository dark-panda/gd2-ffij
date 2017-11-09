# frozen_string_literal: true; encoding: ASCII-8BIT
#
# See COPYRIGHT for license details.

module GD2
  # = Description
  #
  # Palette objects are associated with an Image and hold the selection of
  # pixel colors available to the Image. This is primarily a concern for
  # Image::IndexedColor images, but their use with Image::TrueColor images is
  # supported for consistency.
  #
  # == Obtaining
  #
  # Obtain a Palette object from the associated Image:
  #
  #   palette = image.palette
  #
  class Palette
    class PaletteFullError < StandardError; end
    class ColorNotFoundError < StandardError; end

    # The Image associated with this Palette
    attr_reader :image

    def initialize(image)   #:nodoc:
      @image = image
    end

    # Return the maximum number of colors this palette can hold.
    def size
      MAX_COLORS
    end
    alias length size

    def allocated?(index)   #:nodoc:
      @image.image_ptr[:open][index].zero?
    end
    protected :allocated?

    # Return the number of colors presently allocated in this palette.
    def used
      (0...size).inject(0) do |sum, i|
        sum + (allocated?(i) ? 1 : 0)
      end
    end

    # Return the number of palette entries available to be allocated for new
    # colors.
    def available
      size - used
    end

    # Return the color allocated to the specified +index+, or *nil* if the
    # entry is unallocated.
    def [](index)
      index = size + index if index < 0
      raise RangeError unless (0...size).include? index
      return nil unless allocated?(index)
      get_color(index)
    end

    # Assign (allocate) the given +color+ to the palette entry identified by
    # +index+. If the entry was previously allocated to a different color,
    # every pixel in the image having the given color +index+ will effectively
    # be changed to the new color. This method cannot be used with
    # Image::TrueColor palettes.
    def []=(index, color)
      raise RangeError unless (0...MAX_COLORS).include? index
      if color.nil?
        deallocate(self[index] ||
          Color.new_from_palette(0, 0, 0, 0, index, self))
      else
        ptr = @image.image_ptr
        ptr[:red][index] = color.red
        ptr[:green][index] = color.green
        ptr[:blue][index] = color.blue
        ptr[:alpha][index] = color.alpha
        ptr[:open][index] = 0
      end
    end

    # Locate the given +color+ in this palette and return it if found;
    # otherwise try to allocate the +color+, or if the palette is full, return
    # a color from the palette that is closest to it.
    def resolve(color)
      raise TypeError unless color.kind_of? Color
      c = ::GD2::GD2FFI.send(:gdImageColorResolveAlpha, @image.image_ptr,
        color.red.to_i, color.green.to_i, color.blue.to_i, color.alpha.to_i)
      c == -1 ? nil : get_color(c)
    end

    # Locate the given +color+ in this palette and return it. Returns *nil*
    # if the color is not presently in the palette.
    def exact(color)
      raise TypeError unless color.kind_of? Color
      c = ::GD2::GD2FFI.send(:gdImageColorExactAlpha, @image.image_ptr,
        color.red.to_i, color.green.to_i, color.blue.to_i, color.alpha.to_i)
      c == -1 ? nil : get_color(c)
    end

    # Like Palette#exact except an error is raised if the color is not
    # presently in the palette.
    def exact!(color)
      exact(color) or raise Palette::ColorNotFoundError,
        "Color #{color} is not in the palette"
    end

    # Return the color in this palette that is closest to the given +color+
    # according to Euclidian distance.
    def closest(color)
      raise TypeError unless color.kind_of? Color
      c = ::GD2::GD2FFI.send(:gdImageColorClosestAlpha, @image.image_ptr,
        color.red.to_i, color.green.to_i, color.blue.to_i, color.alpha.to_i)
      c == -1 ? nil : get_color(c)
    end

    # Return the color in this palette that is closest to the given +color+
    # according to hue, whiteness, and blackness.
    def closest_hwb(color)
      raise TypeError unless color.kind_of? Color
      c = ::GD2::GD2FFI.send(:gdImageColorClosestHWB, @image.image_ptr,
        color.red.to_i, color.green.to_i, color.blue.to_i)
      c == -1 ? nil : get_color(c)
    end

    # Assign the given +color+ to an unoccupied entry in this palette and
    # return it. Does not check whether the color is already allocated, and
    # raises an error for Image::IndexedColor palettes if the palette is full.
    def allocate(color)
      raise TypeError unless color.kind_of? Color
      c = ::GD2::GD2FFI.send(:gdImageColorAllocateAlpha, @image.image_ptr,
        color.red.to_i, color.green.to_i, color.blue.to_i, color.alpha.to_i)
      c == -1 ? raise(Palette::PaletteFullError, 'Palette is full') :
        get_color(c)
    end

    # Ensure the given +color+ is present in this palette, allocating it if
    # necessary. Returns the palette so calls may be stacked.
    def <<(color)
      exact(color) or allocate(color)
      self
    end

    # Remove the given +color+ from this palette.
    def deallocate(color)
      color = exact(color) unless color.index
      return nil if color.nil? || color.index.nil?
      ::GD2::GD2FFI.send(:gdImageColorDeallocate, @image.image_ptr, color.index.to_i)
      nil
    end

    # Remove all colors from this palette that are not currently in use by the
    # associated Image. This is an expensive operation. Returns the number of
    # palette entries deallocated.
    def deallocate_unused
      # implemented by subclass
    end
  end

  class Palette::IndexedColor < Palette
    include Enumerable

    def inspect   #:nodoc:
      "#<#{self.class} [#{used}]>"
    end

    def get_color(index)  #:nodoc:
      ptr = @image.image_ptr
      Color.new_from_palette(
        ptr[:red][index],
        ptr[:green][index],
        ptr[:blue][index],
        ptr[:alpha][index],
        index, self)
    end
    protected :get_color

    # Iterate through every color allocated in this palette.
    def each  #:yields: color
      (0...MAX_COLORS).each do |i|
        color = self[i]
        yield color unless color.nil?
      end
      self
    end

    def deallocate_unused   #:nodoc:
      used = @image.collect.flatten.uniq.inject(Array.new(MAX_COLORS)) do
          |ary, c|
        ary[c] = true
        ary
      end
      count = 0
      each do |color|
        unless used.at(color.index)
          self[color.index] = nil
          count += 1
        end
      end
      count.zero? ? nil : count
    end
  end

  class Palette::TrueColor < Palette
    def inspect   #:nodoc:
      "#<#{self.class}>"
    end

    def size  #:nodoc:
      ((1 + RGB_MAX) ** 3) * (1 + ALPHA_MAX)
    end
    alias length size
    alias used size

    def allocated?(index)   #:nodoc:
      true
    end
    protected :allocated?

    # Return *true*.
    def include?(color)
      true
    end

    def get_color(index)  #:nodoc:
      Color.new_from_rgba(index)
    end
    protected :get_color

    def []=(index, color)   #:nodoc:
      raise "Palette assignment not supported for #{self.class}"
    end
  end
end
