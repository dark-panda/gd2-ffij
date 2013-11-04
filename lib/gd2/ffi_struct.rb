# encoding: ASCII-8BIT
#
# Ruby/GD2 -- Ruby binding for gd 2 graphics library
#
# Copyright 2010-2013 J Smith
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
