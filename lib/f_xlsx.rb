require "f_xlsx/version"
require "f_xlsx/lib_c"
require "f_xlsx/base_types"
require "f_xlsx/xlsx_ext"
require "f_xlsx/file"

module FXlsx

  def self.new_file
    File.new_file
  end

  def self.open_file(path)
    File.open_file(path)
  end
  
end
