module FXlsx
  class CStrArray  < FFI::Struct
    layout :arr, :pointer,
          :s_size, :int
    
    def value
      str = []
      self[:arr].read_array_of_pointer(self[:s_size]).map do |str_ptr| 
        str << str_ptr.read_string
        LibC.free(str_ptr)
      end
      LibC.free(self[:arr])
      str 
    end
  end

  class CStrArray2 < FFI::Struct
    layout :arr, :pointer,
          :s_size, :int
    def value
      rows = []
      self[:arr].read_array_of_pointer(self[:s_size]).each do |p|
        rows << CStrArray.new(p).value
        LibC.free(p)
      end
      LibC.free(self[:arr])
      rows
    end
  end
end