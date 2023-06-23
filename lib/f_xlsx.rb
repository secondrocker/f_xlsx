require "./f_xlsx/version"
require "./f_xlsx/xlsx"

module FXlsx
  class Error < StandardError; end
  # Your code goes here...

  def self.new_file
    Xlsx.new_file
  end

  def self.open_file(path)
    Xlsx.open_file(path)
  end
  
end
