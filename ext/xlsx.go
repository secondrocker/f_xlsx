package main

import (
	"fmt"
	"sync"
	"unsafe"

	"github.com/google/uuid"
	"github.com/xuri/excelize/v2"
)

/*
#include <stdlib.h>
typedef struct str_arr{
	char **arr;
	int s_size;
} str_arr;

typedef struct str_arr2 {
	str_arr **arr;
	int s_size;
} str_arr2;
*/
import "C"

var files map[uint32]*excelize.File
var once sync.Once

func getFile(uid uint32) *excelize.File {
	return files[uid]
}

func setFile(uid uint32, file *excelize.File) {
	once.Do(func() {
		files = make(map[uint32]*excelize.File)
	})
	files[uid] = file
}

//export printStr
func printStr(str *C.char) {
	ss := C.GoString(str)
	fmt.Println(ss)
}

//export newFile
func newFile() uint32 {
	file := excelize.NewFile()
	uid := fuuid()
	setFile(uid, file)
	return uid
}

//export openFile
func openFile(filePath *C.char) uint32 {
	path := C.GoString(filePath)
	fmt.Println(path)
	file, err := excelize.OpenFile(path)
	if err != nil {
		fmt.Println(err)
		return 0
	}
	uid := fuuid()
	setFile(uid, file)
	return uid
}

//export newSheet
func newSheet(fileId uint32, sheetNamcC *C.char) C.int {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNamcC)
	num, _ := f.NewSheet(sheetName)
	return C.int(num)
}

//export setSheetName
func setSheetName(fileId uint32, sheetNameC *C.char, targetSheetNameC *C.char) {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNameC)
	targetSheetName := C.GoString(targetSheetNameC)
	f.SetSheetName(sheetName, targetSheetName)
}

//export getSheetList
func getSheetList(fileId uint32) *C.struct_str_arr {
	f := getFile(fileId)
	names := f.GetSheetList()
	return fromGo2Arrs(names)
}

//export getSheetName
func getSheetName(fileId uint32, index int) *C.char {
	f := getFile(fileId)
	name := f.GetSheetName(index)
	rtn := C.CString(name)
	// defer C.free(unsafe.Pointer(rtn))
	return rtn
}

//export closeFile
func closeFile(fileId uint32) {
	f := getFile(fileId)
	f.Close()
	delete(files, fileId)
}

//export setSheetVisible
func setSheetVisible(fileId uint32, sheetNameC *C.char, visible C.int) {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNameC)
	f.SetSheetVisible(sheetName, int(visible) == 1)
}

//export getSheetVisible
func getSheetVisible(fileId uint32, sheetNameC *C.char) C.int {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNameC)
	vis, _ := f.GetSheetVisible(sheetName)
	if vis {
		return C.int(1)
	}
	return C.int(0)
}

//export deleteSheet
func deleteSheet(fileId uint32, sheetNameC *C.char) {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNameC)
	f.DeleteSheet(sheetName)
}

//export setCellValue
func setCellValue(fileId uint32, sheetNameC *C.char, row C.int, col C.int, value unsafe.Pointer, typ int) {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNameC)
	cell, _ := excelize.CoordinatesToCellName(int(col)+1, int(row)+1)
	switch int(typ) {
	case 1: //int
		ptr := (*C.int)(value)
		f.SetCellInt(sheetName, cell, int(*ptr))
	case 2: //float
		ptr := (*C.float)(value)
		f.SetCellFloat(sheetName, cell, float64(*ptr), 4, 32)
	case 3: //string
		val := (*C.char)(value)
		f.SetCellStr(sheetName, cell, C.GoString(val))
	}
}

//export getCellValue
func getCellValue(fileId uint32, sheetNameC *C.char, row C.int, col C.int) *C.char {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNameC)
	cell, _ := excelize.CoordinatesToCellName(int(col)+1, int(row)+1)
	val, _ := f.GetCellValue(sheetName, cell)

	str := C.CString(val)
	// defer C.free(unsafe.Pointer(str))
	return str
}

//export getRows
func getRows(fileId uint32, sheetNameC *C.char) *C.struct_str_arr2 {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNameC)
	rows, _ := f.GetRows(sheetName)
	return fromGo2Arrs2(rows)
}

//export putRows
func putRows(fileId uint32, sheetNameC *C.char, rowsC *C.struct_str_arr2) {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNameC)
	vRows := (*[2 << 32]*C.struct_str_arr)(unsafe.Pointer(rowsC.arr))
	for i := 0; i < int(rowsC.s_size); i++ {
		row := fromArr2Go(vRows[i])
		innerPutRow(f, sheetName, i, row)
	}

}

//export putRow
func putRow(fileId uint32, sheetNameC *C.char, rowIndex int, rowC *C.struct_str_arr) {
	f := getFile(fileId)
	sheetName := C.GoString(sheetNameC)
	row := fromArr2Go(rowC)
	fmt.Printf("%v\n", len(row))
	innerPutRow(f, sheetName, rowIndex, row)
}

func innerPutRow(f *excelize.File, sheetName string, rowIndex int, row []string) {
	for i := 0; i < len(row); i++ {
		cell, _ := excelize.CoordinatesToCellName(i+1, rowIndex+1)
		f.SetCellStr(sheetName, cell, row[i])
	}
}

//export save
func save(fileId uint32) {
	f := getFile(fileId)
	f.Save()
	f.Close()
	delete(files, fileId)
}

//export saveAs
func saveAs(fileId uint32, path *C.char) {
	f := getFile(fileId)
	strPath := C.GoString(path)
	f.SaveAs(strPath)
	f.Close()
	delete(files, fileId)
}

func fromGo2Arrs(strs []string) *C.struct_str_arr {
	var arr = (*C.struct_str_arr)(C.malloc(C.size_t(unsafe.Sizeof(C.struct_str_arr{}))))
	arr.s_size = C.int(len(strs))

	var ss = C.malloc(C.size_t(arr.s_size) * C.size_t(unsafe.Sizeof(uintptr(0))))

	var arrSs = (*[2 << 32]*C.char)(unsafe.Pointer(ss))
	for i, s := range strs {
		arrSs[i] = C.CString(s)
	}
	arr.arr = (**C.char)(ss)
	return arr
}

func fromGo2Arrs2(strs [][]string) *C.struct_str_arr2 {
	var arr2 = (*C.struct_str_arr2)(C.malloc(C.size_t(unsafe.Sizeof(C.struct_str_arr2{}))))
	arr2.s_size = C.int(len(strs))
	var ss = C.malloc(C.size_t(arr2.s_size) * C.size_t(unsafe.Sizeof(uintptr(0))))
	var arrSs = (*[2 << 32]*C.struct_str_arr)(unsafe.Pointer(ss))

	for i, _strs := range strs {
		arrSs[i] = fromGo2Arrs(_strs)
	}
	arr2.arr = (**C.struct_str_arr)(ss)
	return arr2
}

func fromArr2Go(rowC *C.struct_str_arr) []string {
	vRow := (*[2 << 32]*C.char)(unsafe.Pointer(rowC.arr))
	row := make([]string, 0, int(rowC.s_size))
	for ii := 0; ii < int(rowC.s_size); ii++ {
		row = append(row, C.GoString(vRow[ii]))
	}
	return row
}

func fuuid() uint32 {
	return uuid.New().ID()
}

func main() {
}
