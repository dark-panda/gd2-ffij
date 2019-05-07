# frozen_string_literal: true; encoding: ASCII-8BIT
#
# See COPYRIGHT for license details.

class GD2::AnimatedGif
  class Frame < Struct.new(:ptr, :size)
    def read
      ptr.get_bytes(0, size.get_int(0))
    end
  end

  def add(ptr, options = {})
    size = FFI::MemoryPointer.new(:int)

    frame_ptr = if frames.empty?
      ::GD2::GD2FFI.send(:gdImageGifAnimBeginPtr, ptr.image_ptr, size, -1, 0)
    else
      previous_frame_ptr = if options[:previous_frame]
        options[:previous_frame].image_ptr
      else
        FFI::Pointer::NULL
      end

      ::GD2::GD2FFI.send(:gdImageGifAnimAddPtr, ptr.image_ptr, size, 0, 0, 0, options[:delay].to_i, 1, previous_frame_ptr)
    end

    raise LibraryError if frame_ptr.null?

    frames << Frame.new(frame_ptr, size)
  end

  def end
    size = FFI::MemoryPointer.new(:int)

    frame_ptr = ::GD2::GD2FFI.send(:gdImageGifAnimEndPtr, size)

    raise LibraryError if frame_ptr.null?

    frames << Frame.new(frame_ptr, size)
  end

  def export(filename_or_io)
    output = case filename_or_io
      when String
        File.open(filename_or_io, 'wb')
      else
        filename_or_io
    end

    frames.each do |frame|
      output.write(frame.read)
    end

    output.flush
    output.rewind

    output
  end

  private

    def frames
      return @frames if defined?(@frames)

      @frames = []

      ObjectSpace.define_finalizer(@frames, frames_finalizer)

      @frames
    end

    def frames_finalizer
      proc do
        each do |frame|
          ::GD2::GD2FFI.send(:gdFree, frame[:frame_ptr])
        end
      end
    end
end
