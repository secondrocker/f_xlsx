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

  class CCell < FFI::Struct
    layout :start_row, :int,
           :start_col, :int,
           :end_row, :int,
           :end_col, :int,
           :val, :string
  end

  class CCellArray < FFI::Struct
    layout :cells, :pointer,
           :s_size, :int

    def values
      _cells = []
      self[:cells].read_array_of_pointer(self[:s_size]).each do |cell_ptr|
        c = CCell.new(cell_ptr)
        _cells << {
          start_row: c[:start_row],
          start_col: c[:start_col],
          end_row: c[:end_row],
          end_col: c[:end_col],
          value: c[:val]
        }
        LibC.free(cell_ptr)
      end
      LibC.free(self[:cells])
      LibC.free(self)
      _cells
    end
  end
end