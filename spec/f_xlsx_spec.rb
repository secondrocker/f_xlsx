RSpec.describe FXlsx do
  it "has a version number" do
    expect(FXlsx::VERSION).not_to be nil
  end

  # todo utf-8
  # todo set_visible
  it "write_and_read" do
    path = File.expand_path("test.xlsx")
    f = FXlsx.new_file
    f.set_sheet_name("Sheet1","张真人")
    f.set_cell_value("张真人",0,0,"武当山")
    f.put_row("张真人", 1, ["宋远桥", 999, "李克用", nil, 1223.45, "俞莲舟"])
    expect(f.get_cell_value("张真人", 1, 1)).to eq('999')
    expect(f.get_cell_value("张真人", 1, 5).force_encoding("utf-8")).to eq('俞莲舟')
    expect(f.get_rows('张真人')[1][1]).to eq(999.to_s)
    
    f.new_sheet("666")
    expect(f.get_sheet_list[1]).to eq("666")
    expect(f.get_sheet_name(0).force_encoding("utf-8")).to eq("张真人")
    f.delete_sheet("666")
    sheet_names = f.get_sheet_list
    expect(sheet_names.size).to eq(1)
    expect(sheet_names[0].force_encoding("utf-8")).to eq('张真人')


    f.new_sheet('mm')
    f.put_rows('mm',[['a1'],['b2',22],['c3',333,nil,333.33]])
    expect(f.get_cell_value('mm',2,3)).to eq('333.33')

    expect(f.get_sheet_visible('mm')).to be_truthy

    f.new_sheet('vv')
    f.set_sheet_visible('vv', false)
    expect(f.get_sheet_visible('vv')).to be_falsy
    f.save_as(path)
    expect(File.exists?(path)).to be_truthy
    File.delete(path)
  end
end
