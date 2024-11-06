//
// Project:65 C library
// Christopher Just
//
// Partial implementation of conio library, using ANSI escape codes on 
// stdin/stdout.
//

#include <stdio.h>
#include <conio.h>
#include <p65.h>

unsigned char conio_cursor = 1;
unsigned char conio_revers = 0;
unsigned char conio_fgcolor = 7;
unsigned char conio_bgcolor = 0;


void clrscr (void)
{
    fputs ("\x1b[2J\x1b[;H", stdout);
    conio_cursor = 1;
    conio_revers = 0;
    conio_fgcolor = 7;
    conio_bgcolor = 0;
}



char cgetc ()
{
    return fgetc(stdin);
}



void __fastcall__ cputcxy (unsigned char x, unsigned char y, char c)
{
    fprintf (stdout, "\x1b[%d;%dH%c", y, x, c);
}



void __fastcall__ gotoxy (unsigned char x, unsigned char y)
{
    fprintf (stdout, "\x1b[%d;%dH", y, x);
}



unsigned char __fastcall__ kbhit (void)
{
    int result = ioctl (0, IO_AVAILABLE);
    //printf ("avail: %d", result);
    if (result > 0)
        return 0xff; // true
    else
        return 0;
}



unsigned char __fastcall__ cursor (unsigned char onoff)
{
    unsigned char result = conio_cursor;
    conio_cursor = onoff;
    if (onoff == 0)
        fputs ("\x1b[?25l", stdout);
    else
        fputs ("\x1b[?25h", stdout);
    return result;
}



// This sequence doesn't seem to be doing what I wanted.
unsigned char __fastcall__ revers (unsigned char onoff)
{
    unsigned char result = conio_revers;
    conio_revers = onoff;
    if (onoff == 0)
        fputs ("\x1b[27m", stdout);
    else
        fputs ("\x1b[7m", stdout);
    return result;
}


// colors:
// 0-7          8-15
// black        
// red
// green
// yellow
// blue 
// magenta
// cyan
// white
unsigned char __fastcall__ textcolor (unsigned char color)
{
    unsigned char result = conio_fgcolor;
    if (color <= 7)
    {
        conio_fgcolor = color;
        fprintf (stdout, "\x1b[0;%dm", 30 + color);
    }
    if (color >= 8 && color <= 15)
    {
        conio_fgcolor = color;
        fprintf (stdout, "\x1b[1;%dm", 22 + color);
    }
    return result;
}



unsigned char __fastcall__ bgcolor (unsigned char color)
{
    unsigned char result = conio_bgcolor;
    if (color <= 7)
    {
        conio_bgcolor = color;
        fprintf (stdout, "\x1b[%dm", 40 + color);
    }
    else if (color <= 15)
    {
        conio_bgcolor = color;
        fprintf (stdout, "\x1b[%dm", 100 + color);
    }

    return result;
}

