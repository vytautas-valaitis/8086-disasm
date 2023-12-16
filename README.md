# About

2023 metų Kompiuterių Architektūra, MIF, VU.

Studento atsiskaitytas darbas.

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
-p         Output instruction bytes.
-n         Remove NOP that is generated after JMP. Use if JMP is out of range for this reason.
-d         Output numbers in decimal.
```

Tested on linux DosBox 0.74-3 with TASM 3.1 and TLINK 3.0.
