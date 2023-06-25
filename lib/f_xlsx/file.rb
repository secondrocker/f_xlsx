module FXlsx
  class File
    attr_accessor :id, :closed, :has_file
    
    def self.new_file
      instance = File.new
      instance.id = XlsxExt.newFile()
      instance
    end
  
    def self.open_file(path)
      instance = File.new
      instance.id = XlsxExt.openFile(path)
      instance.has_file = true
      instance
    end
  
    def closed?
      closed
    end
  
    def new_sheet(sheet_name)
      raise "file closed" if self.closed?
  
      XlsxExt.newSheet(self.id, sheet_name)
    end
  
    def set_sheet_name(sheet_name, target_sheet_name)
      raise "file closed" if self.closed?
  
      XlsxExt.setSheetName(self.id, sheet_name, target_sheet_name)
    end

    def set_sheet_visible(sheet_name, visible)
      raise "file closed" if self.closed?

      XlsxExt.setSheetVisible(self.id, sheet_name, visible ? 1 : 0)
    end

    def get_sheet_visible(sheet_name)
      raise "file closed" if self.closed?

      XlsxExt.getSheetVisible(self.id, sheet_name) == 1
    end
  
    def delete_sheet(sheet_name)
      raise "file closed" if self.closed?
  
      XlsxExt.deleteSheet(self.id, sheet_name)
    end
  
    def get_sheet_list
      raise "file closed" if self.closed?
  
      ptr =  XlsxExt.getSheetList(self.id)
      ptr.value
    end
  
    def get_sheet_name(index)
      raise "file closed" if self.closed?
  
      XlsxExt.getSheetName(self.id, index)
    end
  
  
    def set_cell_value(sheet_name, row, col, value)
      raise "file closed" if self.closed?
  
      value = '' if value.nil?
      ptr = nil
      typ = if value.is_a?(Integer)
        ptr = FFI::MemoryPointer.new(:int)
        ptr.write_int(value)
        1
      elsif value.is_a?(Float)
        ptr = FFI::MemoryPointer.new(:float)
        ptr.write_float(value)
        2
      else
        ptr = FFI::MemoryPointer.from_string(value.to_s)
        3
      end
      XlsxExt.setCellValue(self.id, sheet_name, row, col, ptr, typ)
      ptr.free if ptr
    end
  
    def get_cell_value(sheet_name, row, col)
      raise "file closed" if self.closed?
  
      XlsxExt.getCellValue(self.id, sheet_name, row, col)
    end
  
    def get_rows(sheet_name)
      raise "file closed" if self.closed?
  
      XlsxExt.getRows(self.id, sheet_name).value
    end
  
    def put_row(sheet_name, row_index, row)
      raise "file closed" if self.closed?
      
      # 不需要手动释放
      str = CStrArray.new
      str[:s_size] = row.size
      ptr = FFI::MemoryPointer.new(:pointer, row.size)
      pps = row.map{|x| FFI::MemoryPointer.from_string(x.to_s) }
      ptr.write_array_of_pointer(pps)
      str[:arr] = ptr
      XlsxExt.putRow(self.id, sheet_name, row_index,str)
      pps.each(&:free)
      ptr.free
    end
  
    def put_rows(sheet_name, rows)
      raise "file closed" if self.closed?
      #不需要手动释放
      str2 = CStrArray2.new
      str2[:s_size] = rows.size
      ptr2 = FFI::MemoryPointer.new(:pointer, rows.size)
      todoRelease = [ptr2]
      
      ptr2_arr = rows.map do |row|
        # 不需要手动释放
        str = CStrArray.new
        str[:s_size] = row.size
  
        ptr = FFI::MemoryPointer.new(:pointer, row.size)
        todoRelease << ptr
        sptrs = row.map{|s| FFI::MemoryPointer.from_string(s.to_s)}
        todoRelease += sptrs
        ptr.write_array_of_pointer(sptrs)
        str[:arr] = ptr
        str.pointer
      end
      todoRelease += ptr2_arr
      ptr2.write_array_of_pointer(ptr2_arr)
      str2[:arr] = ptr2
      XlsxExt.putRows(self.id, sheet_name, str2)
      todoRelease.each(&:free)
    end
  
    def save
      raise "file closed" if self.closed?
      raise "new file can't save, call save_as" unless has_file
      XlsxExt.save(self.id)
      self.closed = true
    end
  
    def save_as(path)
      raise "file closed" if self.closed?
      XlsxExt.saveAs(self.id,path)
      self.closed = true
    end
  
    def close
      raise "file closed" if self.closed?
      XlsxExt.closeFile(self.id)
      self.closed = true
    end
  end
end