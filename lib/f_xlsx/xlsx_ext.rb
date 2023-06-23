LIB_PATH = File.expand_path("ext/excel.#{FFI::Platform::LIBSUFFIX}")
module FXlsx
  module XlsxExt
    extend FFI::Library
    ffi_lib LIB_PATH
    attach_function :printStr, [:string], :void
    
    attach_function :newFile, [], :uint32
    attach_function :openFile, [:string], :uint32
    
    attach_function :newSheet, [:uint32, :string], :int
    attach_function :deleteSheet, [:uint32, :string], :void
    attach_function :setSheetName, [:uint32, :string, :string], :void
    attach_function :setSheetVisible, [:uint32, :string, :int], :void
    attach_function :getSheetVisible, [:uint32, :string], :int

    attach_function :getSheetList, [:uint32], CStrArray.ptr
    attach_function :getSheetName, [:uint32, :int], :string

    attach_function :setCellValue, [:uint32, :string, :int, :int, :pointer, :int], :void
    attach_function :getCellValue, [:uint32, :string, :int, :int], :string

    attach_function :getRows, [:uint32, :string], CStrArray2.ptr
    
    attach_function :putRow, [:uint32, :string, :int, CStrArray.ptr], :void
    attach_function :putRows, [:uint32, :string, CStrArray2.ptr], :void

    attach_function :save, [:uint32], :void
    attach_function :saveAs, [:uint32, :string], :void

    attach_function :closeFile, [:uint32], :void
  
  end
end