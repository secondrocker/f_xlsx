require 'f_xlsx'
stop = false
fork do
  File.open("test.pid","w"){ |f| f.puts(Process.pid)}
  trap('INT') do
    puts 'will stop'
    stop = true
  end
  while true do
    # path2 = "/Users/wangdong/Desktop/3620230626131231产品录入模板.xlsx"
    path2 = "/Users/wangdong/Desktop/批量搜索产品清单.xlsx"
    f2 = FXlsx.open_file(path2)
    # f2.put_row('Sheet1',5,[5,'b','c'])
    # f2.put_rows('Sheet1',[[2,nil],[1,'b','c']])
    pp f2.get_merge_cells('使用说明')

    f2.unmerge_cell('使用说明', 0,0, 48, 44)
    f2.close
    # f2.save_as(path2)
    break if stop
  end
end