# 8051
This is an 8051 processer soft core.
I made this project to learn knowledge about processer and 8051 instruction.
This project is not finished yet. It lacks some features such as interrupt and timer.

When I made this project, I referred this project and the book mentioned in its README.
https://github.com/risclite/R8051

---
这是一个8051软核，是我在学习处理器时制作的。  
在制作这个软核时我参考了这个项目：https://github.com/risclite/R8051，
和该项目README中提到的书《8051软核处理器设计实战》。  

这个项目还没有完成，主要是缺少中断功能和一些SFR，后续更新中可能会补全功能。  

在my8051文件夹中是一个quartus工程，该工程使用的FPGA型号为EP4CE22F17C6，开发板为terasIC的DE0-Nano。  
my8051为该项目的顶层文件，my8051、core、ram、sfr为可综合的verilog代码，rom、data、xdata为quartus提供的IPcore。  

在testbench_of_core中的是对core的tb，该tb读取code.bin中的程序作为激励，并模拟了ram的行为。上传的code.bin中并没有测试用的程序代码，但我已经测试过每条指令均可单独正常运行。

根目录下的8051_instruction.xlsx为8051指令集的指令表，供参考。