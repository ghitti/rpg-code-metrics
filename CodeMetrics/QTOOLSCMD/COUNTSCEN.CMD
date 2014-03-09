000100130627
000101130627             CMD        PROMPT('Contar eventos por scenario')
000103130627
000104130627             PARM       KWD(INLIB) TYPE(*NAME) LEN(10) DFT(*CURLIB) SPCVAL((*CURLIB *CURLIB)) +
000105130627                          PROMPT('Input file library') CHOICE('*CURLIB, Name')
000106130627
000107130627             PARM       KWD(INFILE) TYPE(*NAME) LEN(10) MIN(1) PROMPT('Input file Name') +
000108130627                          CHOICE('Name')
000109130627
000110130627             PARM       KWD(OUTLIB) TYPE(*NAME) LEN(10) DFT(*CURLIB) SPCVAL((*CURLIB *CURLIB)) +
000111130627                          PROMPT('Output file library') CHOICE('*CURLIB, Name')
000112130627
000113130627             PARM       KWD(OUTFILE) TYPE(*NAME) LEN(10) MIN(1) PROMPT('Output file Name') +
000114130627                          CHOICE('Name')
000115130627
