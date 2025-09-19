using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace TilesConverter
{
    class Program
    {
        static void Main(string[] args)
        {
            //byte[] tiles = File.ReadAllBytes("tiles.scr");
            byte[] tiles = File.ReadAllBytes(args[0]);

            List<byte> outBytes = new List<byte>();

            //Пока читаем только 256 тайлов из верхней трети )
            for (int x = 0; x < 256; x++)                
            {
                //8 байтов тайлика                                    
                outBytes.Add(0x36); //ld (hl),n
                outBytes.Add(tiles[x + 0 * 256]); //байт 
                outBytes.Add(0x24); //inc h

                outBytes.Add(0x36); //ld (hl),n
                outBytes.Add(tiles[x + 1 * 256]); //байт 
                outBytes.Add(0x24); //inc h

                outBytes.Add(0x36); //ld (hl),n
                outBytes.Add(tiles[x + 2 * 256]); //байт 
                outBytes.Add(0x24); //inc h

                outBytes.Add(0x36); //ld (hl),n
                outBytes.Add(tiles[x + 3 * 256]); //байт 
                outBytes.Add(0x24); //inc h

                outBytes.Add(0x36); //ld (hl),n
                outBytes.Add(tiles[x + 4 * 256]); //байт 
                outBytes.Add(0x24); //inc h

                outBytes.Add(0x36); //ld (hl),n
                outBytes.Add(tiles[x + 5 * 256]); //байт 
                outBytes.Add(0x24); //inc h

                outBytes.Add(0x36); //ld (hl),n
                outBytes.Add(tiles[x + 6 * 256]); //байт 
                outBytes.Add(0x24); //inc h

                outBytes.Add(0x36); //ld (hl),n
                outBytes.Add(tiles[x + 7 * 256]); //байт 
                outBytes.Add(0x60); //ld h,b

                //1 байт аттрибута
                outBytes.Add(0x36); //ld (hl),n
                outBytes.Add(tiles[6144+x]); //байт 
                outBytes.Add(0x61); //ld h,c

                outBytes.Add(0x2C); //inc l

                outBytes.Add(0xC9); //ret

                //добъём до 32 - потом можно убрать
              //  outBytes.Add(0xFF);
             //   outBytes.Add(0xFF);
              //  outBytes.Add(0xFF);

            }


            File.WriteAllBytes(args[0]+".bin",outBytes.ToArray());

            //Console.ReadLine();

        }
    }
}

/*
 * drawTile0:   
;захардкотить графику тайла
    ld (hl),01111110b ;10 0*3
    inc h     ;4
    ld (hl),10000001b ;10 1*3
    inc h     ;4
    ld (hl),10000001b ;10 2*3
    inc h     ;4
    ld (hl),10000001b ;10 3*3
    inc h     ;4
    ld (hl),10000001b ;10 4*3
    inc h     ;4
    ld (hl),10000001b ;10 5*3
    inc h     ;4
    ld (hl),10000001b ;10 6*3
    inc h     ;4
    ld (hl),01111110b ;10 7*3
    ;color buffer
    ld h,b ;4 - to COLOR BUFFER
    ld (hl),1*8+0 ;10  8*3 
    ;restore h
    ld h,a;4
    inc l ;4 - to next hl
    ret ;10 to next proc
*/