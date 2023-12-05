LIB = excel

ifeq ($(OS),Windows_NT)
	# Windows
	LIB := $(LIB).dll
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		# Linux
		LIB := $(LIB).so
	else
		ifeq ($(UNAME_S),Darwin)
			# Mac
			LIB := $(LIB).dylib
		endif
	endif
endif

build: ext/$(LIB)
	gem build f_xlsx.gemspec -o pkg/f_xlsx-0.2.9.gem

ext/$(LIB): ext/types.h ext/excel.h ext/xlsx.go
	cd ext && go mod tidy && go build -buildmode=c-shared -o $(LIB) xlsx.go

clean:
	rm -f ext/$(LIB) f_xlsx-*.gem
test:
	ruby test.rb
stop: test.pid
	kill -2 $$(cat test.pid)
	rm test.pid
	
