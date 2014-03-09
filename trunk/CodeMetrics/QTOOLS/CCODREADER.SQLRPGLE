000100120517     /**
000101120518      * \brief CCODREADER: source file reading utilities
000102120517      *
000103120517      * <p>
000104120517      *  This class contains procedures to read a source
000105120517      *  file using sql functions
000107120517      * </p>
000108120517      *
000109120517      * \author Isaaac Ramirez Herrera
000110120517      * \date   May, 2012
000111120517      * \rev    17-05-2012 Isaac Ramirez
000112120517      */
000113120517
000114120517     h nomain
000115120521     h bnddir('CMDZBNDDIR':'CEXCEPBNDD')
000116120517
000118120517      /include csystsrc/qsrctxt,cexception
000119120517      /include qtoolstxt,csqlutil
000120120521      /include qtoolstxt,cmdznconst
000121120628      /include qtoolstxt,ccodreader
000122120809      /include qtoolstxt,crpgparutl
000160120517
000161120628      ////////////////////////////////////////////////////////////
000162120628      // Procedure definition
000163120628      ////////////////////////////////////////////////////////////
000164120628
000165120628     d currentLine     s             10i 0
000166120628     d lastHigherLine  s             10i 0
000167120628
000169120517      ////////////////////////////////////////////////////////////
000170120517      // Procedure definition
000171120517      ////////////////////////////////////////////////////////////
000172120517
000175120517     /**
000176120518      * \brief CCODREADER_beginReading: begins the source code reading
000177120517      *
000178120517      * <p>
000179120517      *  Declares and opens a cursor for the source code in
000180120517      *  QTEMP/QINPUTSRC
000181120517      * </p>
000182120517      */
000183120518     p CCODREADER_beginReading...
000184120518     p                 b                   export
000185120517     d                 pi
000186120517
000187120517      /free
000188120628       clear currentLine;
000189120628       clear lastHigherLine;
000190120628
000191120517       EXEC SQL
000192120517         DECLARE CODECURSOR SCROLL CURSOR FOR
000193120517         SELECT SRCSEQ,
000194120517                SRCDTA
000195120517           FROM QINPUTSRC;
000196120517
000197120522         EXEC SQL OPEN CODECURSOR;
000198120522
000199120522       if not CSQLUTIL_checkSQLState(sqlstt:'OPEN CODECURSOR');
000205120517         CEXCEPTION_throwNewException(COULD_NOT_READ_CODE_FILE
000206120517                                     :MDZN_MESSAGE_FILE);
000207120517       endif;
000208120517      /end-free
000209120517
000210120517     p                 e
000211120517      //_______________________________________________________________________
000212120517
000214120517     /**
000215120518      * \brief CCODREADER_readNextLine: reads the next line in the source code
000216120517      *
000217120517      * <p>
000218120517      *  This procedure reads the next line in the source code
000219120517      * </p>
000220120517      *
000221120517      * \param line readed (output)
000222120517      * \return  *on: read successful
000223120517      *         *off: read failed
000224120517      */
000225120518     p CCODREADER_readNextLine...
000226120517     p                 b                   export
000227120517     d                 pi              n
000228120517     d line                         255a
000229120517     d lineNumber      s             10i 0
000230120517
000231120517      /free
000232120517       EXEC SQL
000233120517         FETCH NEXT FROM CODECURSOR
000234120517         INTO :LINENUMBER,:LINE;
000235120517
000236120517       if CSQLUTIL_checkSQLState(sqlstt:'FETCH CODECURSOR');
000237120517         currentLine = lineNumber;
000238120517
000239120517         if currentLine > lastHigherLine;
000241120517           lastHigherLine = currentLine;
000242120517         endif;
000243120517
000244120809         line = CRPGPARUTL_toUpper(line);
000245120517         return *on;
000246120517       else;
000247120517         return *off;
000248120517       endif;
000249120517
000250120517      /end-free
000251120517     p                 e
000252120517      //_______________________________________________________________________
000253120517
000254120517     /**
000255120518      * \brief CCODREADER_readPreviousLine: reads the previous line in the source
000256120517      *
000257120517      * <p>
000258120517      *  This procedure read the previous line in the source code
000259120517      * </p>
000260120517      *
000261120517      * \param line readed (output)
000262120517      * \return  *on: read successful
000263120517      *         *off: read failed
000264120517      */
000265120518     p CCODREADER_readPreviousLine...
000266120517     p                 b                   export
000267120517     d                 pi              n
000268120517     d line                         255a
000269120517     d lineNumber      s             10i 0
000270120517
000271120517      /free
000272120517       EXEC SQL
000273120517         FETCH PRIOR FROM CODECURSOR
000274120517         INTO :LINENUMBER, :LINE;
000275120517
000276120517       if CSQLUTIL_checkSQLState(sqlstt:'FETCH CODECURSOR');
000277120517         currentLine = lineNumber;
000278120809         line        = CRPGPARUTL_toUpper(line);
000279120517         return *on;
000280120517       else;
000281120517         return *off;
000282120517       endif;
000283120517      /end-free
000284120517
000285120517     p                 e
000286120517      //_______________________________________________________________________
000287120518
000288120518     /**
000289120518      * \brief CCODREADER_endReading: closes the code reading cursor
000290120518      *
000291120518      * <p>
000292120518      *  This procedure closes the CODECURSOR cursor
000293120518      * </p>
000294120518      */
000295120518     p CCODREADER_endReading...
000296120518     p                 b                   export
000297120518
000298120518      /free
000299120518       EXEC SQL
000300120518         CLOSE CODECURSOR;
000301120518
000302120518       CSQLUTIL_checkSQLState(sqlstt:'CLOSE CODECURSOR');
000303120518      /end-free
000304120518     p                 e
000305120518      //_______________________________________________________________________
000306120518
