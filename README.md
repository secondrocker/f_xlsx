# FXlsx
## 说明
项目包含ext目录，目录下为go项目
使用go excelize库并编译为c链接库    
gem 使用ffi调用链接库提供的方法，进而提供编辑xlsx文件的功能。
## 使用

1. 打开文件
    - 读取已有文件
      ```ruby
        f = FXlsx.open_file('文件路径')
      ```
    - 新文件
      ```ruby
        f = FXlsx.new_file
      ```
2. 操作方法调用

    | 方法名 | 说明 | 参数说明 |
    | ---- | ---- | ---- |
    | f.new_sheet(sheet_name) | 创建指定名称sheet | sheet_name为指定名 |
    | f.set_sheet_name(source_sheet_name, target_sheet_name) | 修改sheet名 | source_sheet_name：要修改的sheet名<br/>target_sheet_name：要修改为sheet名 |
    | f.set_sheet_visible(sheet_name, visible) | 设置sheet可见 | sheet_name：要操作的sheet名<br/>visible： true可见，false不可见 |
    | visible = f.get_sheet_visible(sheet_name) | 获取sheet是否可见 | sheet_name：要操作的sheet名<br/> visible: 返回值 true则为可见，false不可见 |
    | f.delete_sheet(sheet_name) | 删除sheet | sheet_name：要操作的sheet名 |
    | names = f.get_sheet_list(sheet_name) | 获取全部sheet名 | sheet_name：要操作的sheet名<br/>names: 返回值为sheet名数组 |
    | name = f.get_sheet_name(index) | 获取指定索引sheet名 | index：sheet索引值(0开始)<br/>name: 返回值为sheet名 |
    | f.set_cell_value(sheet_name, row, col, value) | 设置单元格值 | sheet_name：要操作的sheet名<br/>row：行序号(0开始) <br/>col：列序号(0开始) <br/> value：值，可为int,float,string,nil |
    | val = f.get_cell_value(sheet_name, row, col) | 获取单元格内容 |sheet_name：要操作的sheet名<br/>row：行序号(0开始) <br/>col：列序号(0开始) <br/> val：返回值，单元格内容(string) |
    | rows = f.get_rows(sheet_name) | 获取指定sheet内全部内容 | sheet_name：要操作的sheet名<br/>rows：返回值，二维字符串数组 |
    | f.put_row(sheet_name, row_index, row) | 设置指定行内容 | sheet_name：要操作的sheet名<br/>row_index：行索引<br/> row：要设置的行内容，字符串数组 |
    | f.put_rows(sheet_name, rows) | 设置sheet内容 |  sheet_name：要操作的sheet名<br/>rows: 要设置的内容，二位字符串数组 |
    | f.merge_cell(sheet_name, start_row, start_col, end_row, end_col) | 合并单元格 | sheet_name：要操作的sheet名<br/>start_row：左上角行索引<br/>start_col：左上角列索引<br/>end_row：右下角行索引<br/>end_col：右下角列索引 |
    | f.unmerge_cell(sheet_name, start_row, start_col, end_row, end_col) | 拆分单元格 | sheet_name：要操作的sheet名<br/>start_row：左上角行索引<br/>start_col：左上角列索引<br/>end_row：右下角行索引<br/>end_col：右下角列索引 |
    | cells = f.get_merge_cells(sheet_name) | 获取全部合并单元格 | sheet_name：要操作的sheet名<br/> cells: 返回值，已合并的单元格信息，数组,{ start_row：左上角行索引, start_col：左上角列索引, end_row：右下角行索引, end_col：右下角列索引, value: 单元格值(字符串) } |
    


3. 保存
    - 打开已有文件时保存：f.save  
    - 新文件保存： f.save_as(file_path)

4. **注意事项**

    仅能调用 FXlsx::File(含FXlsx代理出的两个方法open_file，new_file) 下的类/实例方法(即readme里说明的方法)，不要调用FXlsx::XlsxExt/FXlsx::LibC 下的任何方法；因为 FXlsx::File 下的方法调用后释放内存，而其他地方的未做内存释放。
## 跨平台编译
    前提条件：安装 go
1. cd ext 路径
2. 执行go mod tidy
3. ./build.sh 打包c链接库(需修改链接库名为当前操作系统链接库后缀)
4. 返回主目录,gem build f_xlsx.gemspec打包gem