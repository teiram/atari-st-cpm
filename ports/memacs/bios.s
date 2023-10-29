* BIOS.S


        globl   _bios

_bios:  move.w  4(a7),d0        * ucitava broj funkcije
        move.w  6(a7),d1        * ucitava argument funkcije
        trap    #3              * poziva bios
        rts

        end
