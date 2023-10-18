# 8086-disasm  

Dissasembles MS-DOS EXE files.  

## Usage
```bash
Syntax: disasm [options] input_file_name
Options:
-h,-?      Display this help screen.
-o [name]  Output file name. Defaults to 'ASMOUT.ASM'.
-a         Output addresses.
-c         Output code segment only.
-l         Output generated labels.
-d         Output numbers in decimal.
```

Tested on linux DosBox 0.74-3 with TASM 3.1 and TLINK 3.0.