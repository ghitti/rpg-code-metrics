000100120808/* CODMETRICS command source                                   */
000101120808/*                                                             */
000102120808/* Description: CodMetrics command definition. This command is */
000103120808/*              processed by the CODMETRCLD.pgm program which  */
000104120808/*              calculates metrics for a source file           */
000105120808/*                                                             */
000106120808/* Author     : Isaac Ramirez Herrera                          */
000107120808/* Created on : August 8, 2012                                 */
000108120808
000110120808             CMD        PROMPT('Code Modernization Metrics')
000111120514
000112120808             PARM       KWD(SOURCE) TYPE(FILE) MIN(1) PROMPT('Source file')
000113120808
000114120809             PARM       KWD(MEMBER) TYPE(*NAME) LEN(10) SPCVAL((*ALL '*ALL')) MIN(1) +
000115120809                          CHOICE('Name, *ALL') PROMPT('Source file member')
000116120808
000117120809             PARM       KWD(OUTLIB) TYPE(*NAME) LEN(10) DFT(*CURLIB) SPCVAL((*CURLIB *CURLIB)) +
000118120809                          PROMPT('Output files library') CHOICE('*CURLIB, Name')
000119120808
000120120808             PARM       KWD(OPTION) TYPE(*CHAR) LEN(20) RSTD(*YES) DFT(*UPDATE) VALUES(*UPDATE +
000121120808                          *REPLACE) CHOICE('*UPDATE, *REPLACE')  PROMPT('Update or replace +
000122120808                          outfile')
000123120914
000124120914             PARM       KWD(PREFFIX) TYPE(*CHAR) LEN(4) RSTD(*NO) DFT(*DFT) SPCVAL((*DFT +
000125120914                          'DFT')) CHOICE('*DFT, Preffix') PROMPT('Outfile preffix')
000127120808
000128120809             DEP        CTL(&SOURCE *EQ *ALL) PARM((&MEMBER *EQ *ALL))
000129120808
000130120809 FILE:       QUAL       TYPE(*NAME) LEN(10) VARY(*NO) EXPR(*YES) SPCVAL((*ALL '*ALL')) +
000131120809                          CHOICE('Name, *ALL')
000132120808             QUAL       TYPE(*NAME) LEN(10) VARY(*NO) EXPR(*YES) SPCVAL((*CURLIB *CURLIB)) +
000133120808                          PROMPT('Library')
