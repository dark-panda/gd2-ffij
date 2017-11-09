# frozen_string_literal: true; encoding: ASCII-8BIT
#
# See COPYRIGHT for license details.

module GD2::FFIStruct
  class FTStringExtraPtr < FFI::Struct
    layout(
      :flags,       :int,
      :linespacing, :double,
      :charmap,     :int,
      :hdpi,        :int,
      :vdpi,        :int,
      :xshow,       :pointer, # char*
      :fontpath,    :pointer  # char*
    )
  end

  class ImagePtr < FFI::ManagedStruct
    layout(
      :pixels,            :pointer, # unsigned char**
      :sx,                :int,
      :sy,                :int,
      :colorsTotal,       :int,
      :red,               [ :int, 256 ],
      :green,             [ :int, 256 ],
      :blue,              [ :int, 256 ],
      :open,              [ :int, 256 ],
      :transparent,       :int,
      :polyInts,          :pointer, # int*
      :polyAllocated,     :int,
      :brush,             :pointer, # gdImageStruct*
      :tile,              :pointer, # gdImageStruct*
      :brushColorMap,     [ :int, 256 ],
      :tileColorMap,      [ :int, 256 ],
      :styleLength,       :int,
      :stylePos,          :int,
      :style,             :pointer, # int*,
      :interlace,         :int,
      :thick,             :int,
      :alpha,             [ :int, 256 ],
      :trueColor,         :int,
      :tpixels,           :pointer, # int**
      :alphaBlendingFlag, :int,
      :saveAlphaFlag,     :int,
      :aa,                :int,
      :aa_color,          :int,
      :aa_dont_blend,     :int,
      :cx1,               :int,
      :cy1,               :int,
      :cx2,               :int,
      :cy2,               :int
    )

    def self.release(ptr)
      ::GD2::GD2FFI.gdImageDestroy(ptr) unless ptr.null?
    end
  end
end
