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
      LibC.free(self)
      str 
    end
  end

  class CStrArray2 < FFI::Struct
    layout :arr, :pointer,
           :s_size, :int
    def value
      rows = []
      self[:arr].read_array_of_pointer(self[:s_size]).each do |p|
        # CStrArray value方法自动释放指针，本处不需释放
        rows << CStrArray.new(p).value
      end
      LibC.free(self[:arr])
      LibC.free(self)
      rows
    end
  end
end