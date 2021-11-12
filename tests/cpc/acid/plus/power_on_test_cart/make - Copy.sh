pasmo --bin page1.s page1.bin
pasmo --bin page2.s page2.bin
pasmo --bin page3.s page3.bin
pasmo --bin page4.s page4.bin
pasmo --bin page5.s page5.bin
pasmo --bin page6.s page6.bin
pasmo --bin page7.s page7.bin
pasmo --bin page8.s page8.bin
pasmo --bin page9.s page9.bin
pasmo --bin page10.s page10.bin
pasmo --bin page11.s page11.bin
pasmo --bin page12.s page12.bin
pasmo --bin page13.s page13.bin
pasmo --bin page14.s page14.bin
pasmo --bin page15.s page15.bin
pasmo --bin page16.s page16.bin
pasmo --bin page17.s page17.bin
pasmo --bin page18.s page18.bin
pasmo --bin page19.s page19.bin
pasmo --bin page20.s page20.bin
pasmo --bin page21.s page21.bin
pasmo --bin page22.s page22.bin
pasmo --bin page23.s page23.bin
pasmo --bin page24.s page24.bin
pasmo --bin page25.s page25.bin
pasmo --bin page26.s page26.bin
pasmo --bin page27.s page27.bin
pasmo --bin page28.s page28.bin
pasmo --bin page29.s page29.bin
pasmo --bin page30.s page30.bin
pasmo --bin page31.s page31.bin

pasmo --bin test_ram.s test_ram.bin test_ram.lst
pasmo --bin cart_test.s cart_test.bin cart_test.lst

cat cart_test.bin page1.bin page2.bin page3.bin page4.bin page5.bin page6.bin page7.bin page8.bin page9.bin page10.bin page11.bin page12.bin page13.bin page14.bin page15.bin page16.bin page17.bin page18.bin page19.bin page20.bin page21.bin page22.bin page23.bin page24.bin page25.bin page26.bin page27.bin page28.bin page29.bin page30.bin page31.bin >cart.bin

buildcpr cart.bin cart.cpr
