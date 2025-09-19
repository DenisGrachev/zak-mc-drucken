del *.zx0
del *.exo
del *.upk

TilesConverter.exe tiles.scr
TilesConverter.exe tilesMenu.scr
exomizer raw -P15 -T1 tiles.scr.bin -o tiles.exo
rem exomizer raw -P15 -T1 tilesMenu.bin -o tiles.exo

tmxParser.exe map.tmx

tmxParser.exe map01.tmx
tmxParser.exe map02.tmx
tmxParser.exe map03.tmx
tmxParser.exe map04.tmx
tmxParser.exe map05.tmx
tmxParser.exe map06.tmx
tmxParser.exe map07.tmx
tmxParser.exe map08.tmx
tmxParser.exe map09.tmx
tmxParser.exe map10.tmx
tmxParser.exe map11.tmx
tmxParser.exe map12.tmx
tmxParser.exe map13.tmx
tmxParser.exe map14.tmx
tmxParser.exe map15.tmx
tmxParser.exe map16.tmx
tmxParser.exe map17.tmx
tmxParser.exe map18.tmx
tmxParser.exe map19.tmx
tmxParser.exe map20.tmx

rem zx0.exe map01.tmx.mapa
rem zx0.exe map02.tmx.mapa
rem zx0.exe map03.tmx.mapa
rem zx0.exe map04.tmx.mapa
rem zx0.exe map05.tmx.mapa
rem zx0.exe map06.tmx.mapa
rem zx0.exe map07.tmx.mapa
rem zx0.exe map08.tmx.mapa

exomizer.exe raw -P15 -T1 map01.tmx.mapa -o map01.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map02.tmx.mapa -o map02.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map03.tmx.mapa -o map03.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map04.tmx.mapa -o map04.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map05.tmx.mapa -o map05.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map06.tmx.mapa -o map06.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map07.tmx.mapa -o map07.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map08.tmx.mapa -o map08.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map09.tmx.mapa -o map09.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map10.tmx.mapa -o map10.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map11.tmx.mapa -o map11.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map12.tmx.mapa -o map12.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map13.tmx.mapa -o map13.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map14.tmx.mapa -o map14.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map15.tmx.mapa -o map15.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map16.tmx.mapa -o map16.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map17.tmx.mapa -o map17.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map18.tmx.mapa -o map18.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map19.tmx.mapa -o map19.tmx.mapa.exo
exomizer.exe raw -P15 -T1 map20.tmx.mapa -o map20.tmx.mapa.exo

rem upkr.exe --z80 map01.tmx.mapa
rem upkr.exe --z80 map02.tmx.mapa
rem upkr.exe --z80 map03.tmx.mapa
rem upkr.exe --z80 map04.tmx.mapa
rem upkr.exe --z80 map05.tmx.mapa
rem upkr.exe --z80 map06.tmx.mapa
rem upkr.exe --z80 map07.tmx.mapa
rem upkr.exe --z80 map08.tmx.mapa