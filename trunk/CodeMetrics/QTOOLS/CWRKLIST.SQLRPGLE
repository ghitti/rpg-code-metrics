000100120813     /**
000101120813      * \brief CWRKLIST: list of members to process
000102120813      *
000103120813      * <p>
000104120813      *  This module contains the functionality required to
000105120813      *  generate a list of member in order to apply them
000106120813      *  aditional processing
000107120813      * </p>
000108120813      *
000109120813      * \author Isaaac Ramirez Herrera
000110120813      * \date   May, 2012
000111120813      * \rev    22-05-2012 Isaac Ramirez
000112120813      */
000113120813
000114120813     h nomain
000115120625     h bnddir('CEXCEPBNDD':'CMDZBNDDIR')
000116120623
000117120623      /include csystsrc/qsrctxt,cexception
000118120623      /include qtoolstxt,csqlutil
000119120625      /include qtoolstxt,cmdznconst
000120120625      /include qtoolstxt,cwrklist
000121120625      /include qtoolstxt,cqsyswrk
000122120625      /include qtoolstxt,cwrkfilgen
000123120628      /include qtoolstxt,cstringutl
000124120623
000125120623      ///////////////////////////////////////////////////////////////////////
000126120623      // Constant declaration
000127120623      ///////////////////////////////////////////////////////////////////////
000128120623
000129120623     d Quote           s              1a   inz(X'7D')
000130120623     d OUTLIBRARY      c                   const('QTEMP')
000131120623     d FILES           c                   const('FILESLIST')
000132120623     d MEMBERS         c                   const('MEMBERLIST')
000133120623     d GENERATE_FILES_DESC...
000134120623     d                 c                   const('DSPFD FILE(&1/&2) +
000135120623     d                                     TYPE(*BASATR) OUTPUT(*OUTFILE)  +
000136120623     d                                     OUTFILE(&3/&4)')
000137120623     d GENERATE_MEMBERS_LIST...
000138120623     d                 c                   const('DSPFD FILE(&1/&2) +
000139120623     d                                     TYPE(*MBRLIST) OUTPUT(*OUTFILE) +
000140120623     d                                     OUTFILE(&3/&4)')
000141120623
000142120623      ///////////////////////////////////////////////////////////////////////
000143120623      // Prototype declaration
000144120623      ///////////////////////////////////////////////////////////////////////
000147120623
000148120623     d executeCommand  pr                  extpgm('QCMDEXC')
000149120623     d  command                   32768a   const options(*varsize)
000150120623     d  commandSize                  15p 5 const
000151120623
000152120623     d generateFileDescription...
000153120623     d                 pr
000154120625     d library                       10a   const
000155120625     d file                          10a   const
000157120623
000158120627     d createTemporaryWorkList...
000159120627     d                 pr
000160120627     d library                       10a   const
000161120627     d file                          10a   const
000162120627     d member                        10a   const
000163120627
000164120815     d removeMainInconsistency...
000165120815     d                 pr
000166120815     d library                       10a   const
000167120815     d file                          10a   const
000168120815     d member                        10a   const
000169120815
000170120815     d removeOperatorsInconsistency...
000171120815     d                 pr
000172120815     d library                       10a   const
000173120815     d file                          10a   const
000174120815     d member                        10a   const
000175120815
000176120815     d removeLinesInconsistency...
000177120815     d                 pr
000178120815     d library                       10a   const
000179120815     d file                          10a   const
000180120815     d member                        10a   const
000181120815
000182120623      ///////////////////////////////////////////////////////////////////////
000183120623      // Procedure definition
000184120623      ///////////////////////////////////////////////////////////////////////
000185120623
000186120628     /**
000187120628      * \brief CWRKLIST_prepareWorkList: prepares the work list
000188120628      *
000189120628      * <p>
000190120628      *  this procedures creates the list of member to analyze. Generates
000191120628      *  the files QTEMP/FILES (containing the list of source files) and
000192120628      *  QTEMP/MEMBERLIST (containing the list of members). In both cases it
000193120628      *  uses the command DSPFD. With these files it creates a temporal table
000194120628      *  named QTEMP/WORKLIST.
000195120628      * </p>
000196120628      *
000197120628      * \param library to analyze
000198120628      * \param file to analyze. It can be a name or *ALL
000199120628      * \param member to analyze. It can be a name or *ALL.
000200120628      *
000201120628      * \return worklist count
000202120628      */
000203120623     p CWRKLIST_prepareWorkList...
000204120623     p                 b                   export
000205120627     d                 pi            10i 0
000206120623     d library                       10a   const
000207120623     d file                          10a   const
000208120623     d member                        10a   const
000209120625     d outFileName     s             10a   inz(FILES)
000210120625     d outLibName      s             10a   inz(MEMBERS)
000211120627     d elementCount    s             10i 0 inz(0)
000212120627
000213120623      /free
000214120625       monitor;
000215120626         generateFileDescription(library:file);
000216120627         createTemporaryWorkList(library:file:member);
000225120625
000229120625         CSQLUTIL_CHECKSQLSTATE(SQLSTT:'PREPARE SQLSTATEMENT');
000230120623
000231120628         EXEC SQL
000232120628           SELECT COUNT(1)
000233120628             INTO :ELEMENTCOUNT
000234120628             FROM QTEMP/WORKLIST;
000235120627
000236120813         CSQLUTIL_CHECKSQLSTATE(SQLSTT:'SELECT COUNT');
000237120627
000238120628         EXEC SQL
000239120628           DECLARE WORKCURSOR SCROLL CURSOR FOR
000240120628            SELECT *
000241120628              FROM QTEMP/WORKLIST
000242120628              FOR READ ONLY;
000243120627
000244120627         CSQLUTIL_CHECKSQLSTATE(SQLSTT:'DECLARE WORKCURSOR');
000245120626
000246120628         EXEC SQL
000247120628           OPEN WORKCURSOR;
000248120627
000252120625         CSQLUTIL_CHECKSQLSTATE(SQLSTT:'OPEN WOKRCURSOR');
000253120627
000254120627         return elementCount;
000255120627       on-error;
000256120625         CEXCEPTION_catchException();
000257120625         CEXCEPTION_printStackTrace();
000258120625         CEXCEPTION_throwNewException(ERROR_GENERATING_WRKLIST
000259120625            :MDZN_MESSAGE_FILE);
000260120625       endmon;
000261120623      /end-free
000262120623     p                 e
000263120623      //______________________________________________________________________
000264120623
000265120813     /**
000266120813      * \brief CWRKLIST_getNextListElement: iterates to the next work item
000267120813      *
000268120813      * <p>
000269120813      *  This procedures iterates to the next element in the work list of
000270120813      *  members created during the execution of the CWRKLIST_prepareWorkList
000271120813      *  procedure.
000272120813      * </p>
000273120813      *
000274120813      * \param output element containing the next element
000275120813      * \return *ON = operation successful
000276120813      *        *OFF = operation failed
000277120813      */
000278120625     p CWRKLIST_getNextListElement...
000279120623     p                 b                   export
000280120625     d                 pi              n
000281120625     d element                             likeds(QSYSMember_Type)
000282120625     d
000283120625     d tempLibrary     s             10a
000284120625     d tempFile        s             10a
000285120625     d tempMember      s             10a
000286120625     d tempType        s             10a
000287120625     d tempDateTime    s             13a
000288120829     d tempCreationDate...
000289120829     d                 s              7a
000290120625
000291120623      /free
000292120628       EXEC SQL
000293120829         FETCH WORKCURSOR INTO :TEMPLIBRARY, :TEMPFILE, :TEMPMEMBER,
000294120829                               :TEMPTYPE, :TEMPDATETIME, :TEMPCREATIONDATE;
000295120625
000296120625       if (CSQLUTIL_checkSqlState(SQLSTT:'FETCH WORKCURSOR'));
000297120623
000298120625         //Fill the element to return
000299120625         element.library        = tempLibrary;
000300120625         element.fileName       = tempFile;
000301120625         element.memberName     = tempMember;
000302120625         element.memberType     = tempType;
000304120829         element.creationDate   = %date(tempCreationDate:*CYMD0);
000306120625         element.changeDateTime = CQSYSWRK_convertDate(tempDateTime);
000307120625         return *on;
000308120625       else;
000309120625         return *off;
000310120625       endif;
000311120623      /end-free
000312120623     p                 e
000313120623      //______________________________________________________________________
000314120623
000315120628     /**
000316120628      * \brief CWRKLIST_dropWorkList: deletes the temp file QTEMP/WORKLIST
000317120628      *
000318120628      * <p>
000319120628      *  This procedure deletes the file QTEMP/WORKLIST and releases
000320120628      *  the associated resources
000321120628      * </p>
000322120628      */
000323120623     p CWRKLIST_dropWorkList...
000324120623     p                 b                   export
000325120623
000326120623      /free
000327120625       monitor;
000328120628         EXEC SQL
000329120628           CLOSE WORKCURSOR;
000330120623
000331120625         CSQLUTIL_checksqlstate(SQLSTT:'CLOSE WORKCURSOR');
000332120627
000333120829         EXEC SQL
000334120829           DROP TABLE QTEMP/WORKLIST;
000335120813
000336120813         //Delete any temp file if exists
000337120813         CWRKFILGEN_deleteWorkFile(OUTLIBRARY:FILES);
000338120813         CWRKFILGEN_deleteWorkFile(OUTLIBRARY:MEMBERS);
000339120813       ON-ERROR;
000340120625         CEXCEPTION_catchException();
000341120625         CEXCEPTION_printStackTrace();
000342120625       endmon;
000343120623      /end-free
000344120623     p                 e
000345120623      //______________________________________________________________________
000346120623
000347120628     /**
000348120628      * \brief CWRKLIST_checkResultsConsistency: check for orphan members
000349120628      *
000350120628      * <p>
000351120628      *  This procedure checks the MDZAESTCOD table for orphan member (members
000352120628      *  with metrics previosly generated but currently inexistent or without
000353120628      *  a parent source file) and deletes it
000354120628      * </p>
000355120628      *
000356120628      * \param name of the library
000357120628      * \param name of the file or *ALL
000358120628      * \param name of the member or *ALL
000359120628      *
000360120628      */
000361120627     p CWRKLIST_checkResultsConsistency...
000362120627     p                 b                   export
000363120627     d                 pi
000364120627     d library                       10a   const
000365120627     d file                          10a   const
000366120627     d member                        10a   const
000367120627
000368120627      /free
000369120815       removeLinesInconsistency(library:file:member);
000370120815       removeOperatorsInconsistency(library:file:member);
000371120815       removeMainInconsistency(library:file:member);
000410120627      /end-free
000411120627     p                 e
000412120627      //______________________________________________________________________
000413120815
000414120815     p removeMainInconsistency...
000415120815     p                 b
000416120815     d                 pi
000417120815     d library                       10a   const
000418120815     d file                          10a   const
000419120815     d member                        10a   const
000420120815     d
000421120815     d topStatement    s           5000a
000422120815
000423120815      /free
000424120815       monitor;
000425120815         if file <> ALL and member <> ALL;
000426120815           //If the file and member are specified
000427120815           return;
000428120815         else;
000429120815           topStatement =
000430120815            ' DELETE                                                       ' +
000431120815            '  FROM MDZAESTCOD ORIGIN                                      ' +
000432120815            ' WHERE EXISTS(                                                ' +
000433120815            '       SELECT *                                               ' +
000434120815            '         FROM QTEMP/WORKLIST LIST RIGHT JOIN MDZAESTCOD STATS ' +
000435120815            '           ON LIST.LIBNAME = STATS.ESTBIBSRC                  ' +
000436120815            '          AND LIST.FILENAME = STATS.ESTARCSRC                 ' +
000437120815            '          AND LIST.MEMBERNAME = STATS.ESTNOMMBR               ' +
000438120815            '        WHERE LIST.LIBNAME IS NULL                            ' +
000439120815            '          AND LIST.FILENAME IS NULL                           ' +
000440120815            '          AND LIST.MEMBERNAME IS NULL                         ' +
000441120815            '          AND ORIGIN.ESTBIBSRC = STATS.ESTBIBSRC              ' +
000442120815            '          AND ORIGIN.ESTARCSRC = STATS.ESTARCSRC              ' +
000443120815            '          AND ORIGIN.ESTNOMMBR = STATS.ESTNOMMBR              ' +
000444120815            '          AND STATS.ESTBIBSRC = ' + Quote + %trim(library) + Quote;
000445120815
000446120815           if file <> ALL;
000447120815             topStatement = %trim(topStatement) +
000448120815                '      AND STATS.ESTARCSRC = ' + Quote + %trim(file) + Quote;
000449120815           endif;
000450120815
000451120815           topStatement = %trim(topStatement) + ')';
000452120815
000453120815           EXEC SQL
000454120815             PREPARE STMT_CONSISTENCY FROM :TOPSTATEMENT;
000455120815
000456120815           CSQLUTIL_checksqlstate(SQLSTT:'PREPARE STMT_CONSISTENCY');
000457120815
000458120815           EXEC SQL
000459120815             EXECUTE STMT_CONSISTENCY;
000460120815
000461120815           CSQLUTIL_checksqlstate(SQLSTT:'EXECUTE STMT_CONSISTENCY');
000462120815         endif;
000463120815       on-error;
000464120815         CEXCEPTION_catchException();
000465120815         CEXCEPTION_printStackTrace();
000466120815       endmon;
000467120815      /end-free
000468120815     p                 e
000469120815      //______________________________________________________________________
000470120815
000471120814     p removeOperatorsInconsistency...
000472120814     p                 b
000473120814     d                 pi
000474120814     d library                       10a   const
000475120814     d file                          10a   const
000476120814     d member                        10a   const
000477120815     d
000478120815     d topStatement    s           5000a
000479120815
000480120815      /free
000481120815       monitor;
000482120815         if file <> ALL and member <> ALL;
000483120815           //If the file and member are specified
000484120815           return;
000485120815         else;
000486120815           topStatement =
000487120815            ' DELETE                                                       ' +
000488120815            '  FROM MDZAOPEDEP ORIGIN                                      ' +
000489120815            ' WHERE EXISTS(                                                ' +
000490120815            '       SELECT *                                               ' +
000491120815            '         FROM QTEMP/WORKLIST LIST RIGHT JOIN MDZAOPEDEP STATS ' +
000492120815            '           ON LIST.LIBNAME = STATS.OPEBIBSRC                  ' +
000493120815            '          AND LIST.FILENAME = STATS.OPEARCSRC                 ' +
000494120815            '          AND LIST.MEMBERNAME = STATS.OPENOMMBR               ' +
000495120815            '        WHERE LIST.LIBNAME IS NULL                            ' +
000496120815            '          AND LIST.FILENAME IS NULL                           ' +
000497120815            '          AND LIST.MEMBERNAME IS NULL                         ' +
000498120815            '          AND ORIGIN.OPEBIBSRC = STATS.OPEBIBSRC              ' +
000499120815            '          AND ORIGIN.OPEARCSRC = STATS.OPEARCSRC              ' +
000500120815            '          AND ORIGIN.OPENOMMBR = STATS.OPENOMMBR              ' +
000501120815            '          AND STATS.OPEBIBSRC = ' + Quote + %trim(library) + Quote;
000502120815
000503120815           if file <> ALL;
000504120815             topStatement = %trim(topStatement) +
000505120815                '      AND STATS.OPEARCSRC = ' + Quote + %trim(file) + Quote;
000506120815           endif;
000507120815
000508120815           topStatement = %trim(topStatement) + ')';
000509120815
000510120815           EXEC SQL
000511120815             PREPARE STMT_CONSISTENCY FROM :TOPSTATEMENT;
000512120815
000513120815           CSQLUTIL_checksqlstate(SQLSTT:'PREPARE STMT_CONSISTENCY');
000514120815
000515120815           EXEC SQL
000516120815             EXECUTE STMT_CONSISTENCY;
000517120815
000518120815           CSQLUTIL_checksqlstate(SQLSTT:'EXECUTE STMT_CONSISTENCY');
000519120815         endif;
000520120815       on-error;
000521120815         CEXCEPTION_catchException();
000522120815         CEXCEPTION_printStackTrace();
000523120815       endmon;
000524120815      /end-free
000525120814     p                 e
000526120814      //______________________________________________________________________
000527120814
000528120815     p removeLinesInconsistency...
000529120815     p                 b
000530120815     d                 pi
000531120815     d library                       10a   const
000532120815     d file                          10a   const
000533120815     d member                        10a   const
000534120815     d
000535120815     d topStatement    s           5000a
000536120815
000537120815      /free
000538120815       monitor;
000539120815         if file <> ALL and member <> ALL;
000540120815           //If the file and member are specified
000541120815           return;
000542120815         else;
000543120815           topStatement =
000544120815            ' DELETE                                                       ' +
000545120815            '  FROM MDZALINHOJ ORIGIN                                      ' +
000546120815            ' WHERE EXISTS(                                                ' +
000547120815            '       SELECT *                                               ' +
000548120815            '         FROM QTEMP/WORKLIST LIST RIGHT JOIN MDZALINHOJ STATS ' +
000549120815            '           ON LIST.LIBNAME = STATS.LINBIBSRC                  ' +
000550120815            '          AND LIST.FILENAME = STATS.LINARCSRC                 ' +
000551120815            '          AND LIST.MEMBERNAME = STATS.LINNOMMBR               ' +
000552120815            '        WHERE LIST.LIBNAME IS NULL                            ' +
000553120815            '          AND LIST.FILENAME IS NULL                           ' +
000554120815            '          AND LIST.MEMBERNAME IS NULL                         ' +
000555120815            '          AND ORIGIN.LINBIBSRC = STATS.LINBIBSRC              ' +
000556120815            '          AND ORIGIN.LINARCSRC = STATS.LINARCSRC              ' +
000557120815            '          AND ORIGIN.LINNOMMBR = STATS.LINNOMMBR              ' +
000558120815            '          AND STATS.LINBIBSRC = ' + Quote + %trim(library) + Quote;
000559120815
000560120815           if file <> ALL;
000561120815             topStatement = %trim(topStatement) +
000562120815                '      AND STATS.LINARCSRC = ' + Quote + %trim(file) + Quote;
000563120815           endif;
000564120815
000565120815           topStatement = %trim(topStatement) + ')';
000566120815
000567120815           EXEC SQL
000568120815             PREPARE STMT_CONSISTENCY FROM :TOPSTATEMENT;
000569120815
000570120815           CSQLUTIL_checksqlstate(SQLSTT:'PREPARE STMT_CONSISTENCY');
000571120815
000572120815           EXEC SQL
000573120815             EXECUTE STMT_CONSISTENCY;
000574120815
000575120815           CSQLUTIL_checksqlstate(SQLSTT:'EXECUTE STMT_CONSISTENCY');
000576120815         endif;
000577120815       on-error;
000578120815         CEXCEPTION_catchException();
000579120815         CEXCEPTION_printStackTrace();
000580120815       endmon;
000581120815      /end-free
000582120815     p                 e
000583120815      //______________________________________________________________________
000584120815
000585120628     /**
000586120628      * \brief createTemporaryWorkList: creates the file WORKLIST
000587120628      *
000588120628      * <p>
000589120628      *  This procedure creates a temporary file called WORKLIST with the
000590120628      *  data of the file QTEMP/FILES and QTEMP/MEMBERLIST
000591120628      * </p>
000592120628      *
000593120628      * \param name of the library
000594120628      * \param name of the file or *ALL
000595120628      * \param name of the member or *ALL
000596120628      */
000597120627     p createTemporaryWorkList...
000598120627     p                 b
000599120627     d                 pi
000600120627     d library                       10a   const
000601120627     d file                          10a   const
000602120627     d member                        10a   const
000603120627     d statement       s          10000a   varying
000604120627
000605120627      /free
000606120627       statement =
000607120627           'CREATE TABLE QTEMP/WORKLIST AS ( ' +
000608120627           'SELECT FILES.ATLIB    AS LIBNAME,                   ' +
000609120627           '       FILES.ATFILE   AS FILENAME,                  ' +
000610120627           '       MEMBERS.MLNAME AS MEMBERNAME,                ' +
000611120627           '       MEMBERS.MLSEU2 AS SOURCETYPE,                ' +
000612120829           '       MEMBERS.MLCHGC || MEMBERS.MLCHGD ||          ' +
000613120829           '         MEMBERS.MLCHGT AS CHANGEDATETIME,          ' +
000614120829           '       MEMBERS.MLCCEN || MEMBERS.MLCDAT AS CREATIONDATE ' +
000616120627           '  FROM &1/&2 AS FILES INNER JOIN &1/&3 AS MEMBERS   ' +
000617120627           '    ON FILES.ATFILE = MEMBERS.MLFILE                ' +
000618120627           '   AND FILES.ATLIB = MEMBERS.MLLIB                  ' +
000619120627           ' WHERE FILES.ATDTAT = ' + Quote + 'S' + Quote;
000620120627
000621120627       if file <> ALL;
000622120627         statement = %trim(statement) +
000623120627             ' AND FILES.ATFILE = ' + Quote +  %trim(file) + Quote + ' ';
000624120627
000625120627         if member <> ALL;
000626120627           statement = %trim(statement) +
000627120627             ' AND MEMBERS.MLNAME = ' + Quote + %trim(member) + Quote + ' ';
000628120627         else;
000629120627           statement = %trim(statement) +
000630120627             '   AND MEMBERS.MLNOMB > 0 ' +
000631120627             '   AND MEMBERS.MLNRCD > 0 ';
000632120627         endif;
000633120627       else;
000634120627         statement = %trim(statement) +
000635120627             ' AND MEMBERS.MLNOMB > 0    ' +
000636120627             ' AND MEMBERS.MLNRCD > 0    ' +
000637120627             ' AND FILES.ATFILE NOT LIKE ' +
000638120627                     Quote + 'EVFTEMP%' + Quote;
000639120627       endif;
000640120627
000641120627       //Close the temporal table definition
000642120627       statement = %trim(statement) +
000643120627         ' ) WITH DATA ';
000644120627
000645120628       statement = CSTRINGUTL_parse(statement:OUTLIBRARY:FILES:MEMBERS);
000646120627
000647120628       //Drop in case it exists
000648120628       EXEC SQL
000649120628         DROP TABLE QTEMP/WORKLIST;
000650120628
000651120628       EXEC SQL
000652120628         PREPARE SQLSTATEMENT FROM :STATEMENT;
000653120627
000654120627       CSQLUTIL_checksqlstate(SQLSTT:'PREPARE CREATE WORKLIST');
000655120627
000656120628       EXEC SQL
000657120628         EXECUTE SQLSTATEMENT;
000658120627
000659120627       CSQLUTIL_checksqlstate(SQLSTT:'EXECUTE CREATE WORKLIST');
000660120627      /end-free
000661120627     p                 e
000662120627      //______________________________________________________________________
000663120627
000664120628     /**
000665120628      * \brief generateFileDescription: generates the file list and member list
000666120628      *
000667120628      * <p>
000668120628      *  This procedure generates a list of files (QTEMP/FILES) and a list of
000669120628      *  members (QTEMP/MEMBERLIST) using the command DSPFD
000670120628      * </p>
000671120628      *
000672120628      * \param name of the  library
000673120628      * \param name of the source file or *ALL
000674120628      *
000675120628      */
000676120623     p generateFileDescription...
000677120623     p                 b
000678120625     d                 pi
000679120625     d library                       10a   const
000680120625     d file                          10a   const
000681120623     d command         s           1024a
000682120623
000683120623      /free
000684120625       //Delete any temp file if exists
000685120625       CWRKFILGEN_deleteWorkFile(OUTLIBRARY:FILES);
000686120625       CWRKFILGEN_deleteWorkFile(OUTLIBRARY:MEMBERS);
000687120625
000688120625       //Generate files descriptions
000689120628       command = CSTRINGUTL_parse(GENERATE_FILES_DESC:%trim(library)
000690120628         :%trim(file):OUTLIBRARY:FILES);
000691120625
000692120625       executeCommand(%trim(command):%len(%trim(command)));
000693120623
000694120625       //Generate member list
000695120628       command = CSTRINGUTL_parse(GENERATE_MEMBERS_LIST:%trim(library)
000696120628         :%trim(file):OUTLIBRARY:MEMBERS);
000697120625
000698120625       executeCommand(%trim(command):%len(%trim(command)));
000699120623      /end-free
000700120623     p                 e
000701120623      //______________________________________________________________________
000702120623
