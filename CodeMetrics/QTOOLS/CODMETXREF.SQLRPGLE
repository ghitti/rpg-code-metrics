000100120829
000101120829     h main(CODMETXREF_Main)
000103120829     h actgrp(*NEW)
000104120829     h dftactgrp(*NO)
000105120829     h option(*srcstmt)
000106120829     h bnddir('CEXCEPBNDD':'CMDZBNDDIR')
000107120829
000108120829      /include qtoolstxt,csqlutil
000109120829
000110120829     d CODMETXREF_Main...
000111120829     d                 pr                  extpgm('CODMETXREF')
000112120829     d xrefLib                       10a   const options(*varsize)
000113120829     d outlib                        10a   const options(*varsize)
000114120829
000115120829     d executeCommand  pr                  extpgm('QCMDEXC')
000116120829     d  command                   32768a   const options(*varsize)
000117120829     d  commandSize                  15p 5 const
000118120829
000119120829     d createCursor    pr
000120120829     d xrefName                      10a
000121120829
000122120829     d getNext         pr              n
000123120829     d libToAnalize                  10a
000124120829
000125120829     d dropCursor      pr
000126120829
000127120829
000128120829     p CODMETXREF_Main...
000129120829     p                 b
000130120829     d                 pi
000131120829     d xrefLib                       10a   const options(*varsize)
000132120829     d outlib                        10a   const options(*varsize)
000133120829     d
000134120829     d command         s           5000a
000135120829     d libToProcess    s             10a
000136120829     d
000137120829     d xref            s             10a
000138120829     d outL            s             10a
000139120829
000140120829      /free
000141120829       xref = xrefLib;
000142120829       outL = outLib;
000143120829       createCursor(xref);
000144120829
000145120829       dow getNext(libToProcess);
000146120829         dsply ('Current LIB: ' + libToProcess);
000147120829         command = 'CODMETRICS SOURCE(' + %trim(libToProcess) + '/*ALL) ' +
000148120829                   '           MEMBER(*ALL) OUTLIB('+ %trim(outL)+ ') '   +
000149120829                   '           OPTION(*UPDATE)                 ';
000150120829         executeCommand(%trim(command):%len(%trim(command)));
000151120829       enddo;
000152120829
000153120829       dropCursor();
000154120829       //createCursor('BACXAN');
000155120829
000156120829       //dropCursor();
000157120829       return;
000158120829      /end-free
000159120829     p                 e
000160120829      //_______________________________________________________________________
000161120829
000162120829     p createCursor    b
000163120829     d                 pi
000164120829     d xrefName                      10a
000165120829
000166120829
000167120829      /free
000168120829       EXEC SQL
000169120829         DECLARE LIB_CURSOR CURSOR FOR
000170120829          SELECT LIB
000171120829            FROM XAOBJ/XAALIBL
000172120829           WHERE LIBTYP = 'S'
000173120829             AND XRFLIB = :XREFNAME;
000174120829
000175120829       EXEC SQL
000176120829         OPEN LIB_CURSOR;
000177120829
000178120829       CSQLUTIL_CHECKSQLSTATE(SQLSTT:'OPEN LIB_CURSOR');
000179120829      /end-free
000180120829     p                 e
000181120829      //_______________________________________________________________________
000182120829
000183120829     p getNext         b
000184120829     d                 pi              n
000185120829     d libToAnalize                  10a
000186120829
000187120829      /free
000188120829       EXEC SQL
000189120829         FETCH LIB_CURSOR INTO :LIBTOANALIZE;
000190120829
000191120829       return CSQLUTIL_CHECKSQLSTATE(SQLSTT:'FETCH');
000192120829      /end-free
000193120829     p                 e
000194120829      //_______________________________________________________________________
000195120829
000196120829     p dropCursor      b
000197120829
000198120829      /free
000199120829       EXEC SQL
000200120829         CLOSE LIB_CURSOR;
000201120829      /end-free
000202120829     p                 e
000203120829      //_______________________________________________________________________
