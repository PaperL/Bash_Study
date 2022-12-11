#!/bin/sh
set -e
prefix='/home/paperlane/toolchain/riscv'
rpath=$prefix/bin/
# clearing test dir
# compiling rom
${rpath}riscv32-unknown-elf-as -o ./sys/rom.o -march=rv32i ./sys/rom.s
# compiling testcase
# mkdir test
for file in ./testcase/fpga/*.c
do
	filename=$(basename $file)
	filename=${filename%.*}
	echo $filename
	cp $file ./test/$filename.c
	${rpath}riscv32-unknown-elf-gcc -o ./test/$filename.o -I ./sys -c ./test/$filename.c -O2 -march=rv32i -mabi=ilp32 -Wall
	# linking
	${rpath}riscv32-unknown-elf-ld -T ./sys/memory.ld ./sys/rom.o ./test/$filename.o -L $prefix/riscv32-unknown-elf/lib/ -L $prefix/lib/gcc/riscv32-unknown-elf/11.1.0/ -lc -lgcc -lm -lnosys -o ./test/$filename.om
	# converting to verilog format
	${rpath}riscv32-unknown-elf-objcopy -O verilog ./test/$filename.om ./test/$filename.data
	# converting to binary format(for ram uploading)
	${rpath}riscv32-unknown-elf-objcopy -O binary ./test/$filename.om ./test/$filename.bin
	# decompile (for debugging)
	${rpath}riscv32-unknown-elf-objdump -D ./test/$filename.om > ./test/$filename.dump
done