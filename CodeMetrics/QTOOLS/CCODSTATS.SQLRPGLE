000101120611     /**
000102120626      * \brief CCODSTATS mantains the code analysis statistics
000103120611      *
000104120611      * <p>
000105120626      *  This module keeps the analysis statistics for each analyzed
000106120626      *  source code member
000107120611      * </p>
000108120611      *
000109120611      * \author Isaac Ramirez Herrera
000110120611      * \date   June, 2012
000111120611      * \rev    11-06-2012 Isaac Ramirez
000112120611      */
000113120528     h nomain
000114120529     h bnddir('CMDZBNDDIR':'CEXCEPBNDD')
000115120809     h option(*srcstmt)
000116120528
000117120528      /include qtoolstxt,ccodstats
000118120528      /include qtoolstxt,cmdznconst
000119140310      /include qtoolstxt,lmap_h
000120140310      /include qtoolstxt,cexception
000121120611      /include qtoolstxt,csqlutil
000122120529
000123120611      ////////////////////////////////////////////////////////////////////////
000124120611      // Global Variable declaration
000125120611      ////////////////////////////////////////////////////////////////////////
000126120611
000127120809     /**
000128120809      * totalLines          : number of total lines of the source member
000129120809      * commentsCount       : number of commented lines found in th source
000130120809      * blanklineCount      : number of blank lines
000131120809      * columnarLineCount   : number of columnar lines in the source
000132120809      * columnarLinesByType : map composed of {Column, count} entries
000133120809      * freeLineCount       : number of total free format lines
000134120809      * unknownLineCount    : number of unclassified lines
000135120809      * deprecatedOperators : map composed of {Operator, count} entries
000136120809      * validOperators      : number of operators compatible with free-form
000137120809      * inlineVariables     : number of total variables declarated inline
000138120809      * conditionalIndicat. : number of total conditional indicators
000139120809      * resultingIndicators : number of total resulting indicators
000140120809      * indicatorsAsVariable: number of total indicators used as variables
000141120829      * lastModificationDate: datetime of the last modification on the member
000142120829      * memberCreationDate  : member creation date
000143120809      */
000144120528     d sourceCodeStatistics...
000145120626     d                 ds                  qualified
000146120626     d totalLines                    10i 0 inz
000147120626     d commentsCount                 10i 0 inz
000148120626     d blankLineCount                10i 0 inz
000149120809     d columnarLineCount...
000150120809     d                               10i 0 inz
000151120809      //Map structure indexed by spec type {'C', Count}, {'D', Count}
000152120809     d columnarLinesByType...
000153120809     d                                 *   inz(*NULL)
000154120626     d freeLineCount                 10i 0 inz
000155120626     d unknownLineCount...
000156120626     d                               10i 0 inz
000157120809      //Map structure indexed by operator {'MOVE', Count}
000158120626     d deprecatedOperators...
000159120626     d                                 *   inz(*NULL)
000160120626     d validOperators                10i 0 inz
000161120626     d inlineVariables...
000162120626     d                               10i 0 inz
000163120626     d conditionalIndicators...
000164120626     d                               10i 0 inz
000165120626     d resultingIndicators...
000166120626     d                               10i 0 inz
000167120626     d indicatorsAsVariables...
000168120626     d                               10i 0 inz
000169120829     d lastModificationDate...
000170120829     d                                 z   inz
000171120829     d memberCreationDate...
000172120829     d                                 d   inz
000173120528
000174120611      ////////////////////////////////////////////////////////////////////////
000175120611      // Prototype declaration
000176120611      ////////////////////////////////////////////////////////////////////////
000177120611
000178120626     d saveDeprecatedOperators...
000179120611     d                 pr
000180120626     d memberName                    10a   const varying
000181120626     d fileName                      10a   const varying
000182120626     d libraryName                   10a   const varying
000183120611
000184120809     d saveLinesBySpec...
000185120809     d                 pr
000186120809     d memberName                    10a   const varying
000187120809     d fileName                      10a   const varying
000188120809     d libraryName                   10a   const varying
000189120809
000190120830     d getColumnarLineCountByType...
000192120830     d                 pr            10i 0
000193120830     d key                            5a   const
000194120830
000195120528      ////////////////////////////////////////////////////////////////////////
000196120528      // Procedure definition
000197120528      ////////////////////////////////////////////////////////////////////////
000198120528
000199120626     /**
000200120626      * \brief CCODSTATS_clear clear the current statistic
000201120626      *
000202120626      * <p>
000203120626      *  This procedure clears the current statistics
000204120626      * </p>
000205120626      */
000206120528     p CCODSTATS_clear...
000207120528     p                 b                   export
000208120528
000209120528      /free
000210120529       if sourceCodeStatistics.deprecatedOperators <> *NULL;
000211120529         monitor;
000212120529           lmap_dispose(sourceCodeStatistics.deprecatedOperators);
000213120529         on-error;
000214120529           CEXCEPTION_catchException();
000215120529           CEXCEPTION_printStackTrace();
000216120529         endmon;
000217120529       endif;
000218120813
000219120813       if sourceCodeStatistics.columnarLinesByType <> *NULL;
000220120813         monitor;
000221120813           lmap_dispose(sourceCodeStatistics.columnarLinesByType);
000222120813         on-error;
000223120813           CEXCEPTION_catchException();
000224120813           CEXCEPTION_printStackTrace();
000225120813         endmon;
000226120813       endif;
000227120529
000228120528       clear sourceCodeStatistics;
000229120529       sourceCodeStatistics.deprecatedOperators = *NULL;
000230120813       sourceCodeStatistics.columnarLinesByType = *NULL;
000231120528      /end-free
000232120528     p                 e
000233120528      //_______________________________________________________________________
000234120528
000235120814     /**
000236120814      * \brief CCODSTATS_deleteAllStatistics deletes all calculated statistics
000237120814      *
000238120814      * <p>
000239120814      *  This procedure deletes all the previously calculated statistics
000240120814      * </p>
000241120814      */
000242120814     p CCODSTATS_deleteAllStatistics...
000243120814     p                 b                   export
000244120814
000245120814      /free
000247120814       monitor;
000248120814         EXEC SQL
000249120829           DELETE
000250120829             FROM MDZAOPEDEP;
000251120814
000252120814         CSQLUTIL_checkSQLState(SQLSTT:'DELETE MDZA_OPERADORES_DEPRECADOS');
000253120814       on-error;
000254120814         CEXCEPTION_catchException();
000255120814       endmon;
000256120814
000257120814       monitor;
000258120814         EXEC SQL
000259120829           DELETE
000260120829             FROM MDZALINHOJ ;
000261120814
000262120814         CSQLUTIL_checkSQLState(SQLSTT:'DELETE MDZA_LINEAS_HOJA');
000263120814       on-error;
000264120814         CEXCEPTION_catchException();
000265120814       endmon;
000266120814
000267120814       monitor;
000268120814         EXEC SQL
000269120829           DELETE
000270120829             FROM MDZAESTCOD;
000271120814
000272120814         CSQLUTIL_checkSQLState(SQLSTT:'DELETE MDZA_ESTADISTICAS_CODIGO');
000273120814       on-error;
000274120814         CEXCEPTION_catchException();
000275120814       endmon;
000276120814      /end-free
000277120814     p                 e
000278120814      //_______________________________________________________________________
000279120814
000280120814     /**
000281120814      * \brief CCODSTATS_deleteStatistics: delete statistics for a item
000282120814      *
000283120814      * <p>
000284120814      *  This procedure deletes all the statistics related to an specific
000285120814      *  item which the metrics were previousy calculated
000286120814      * </p>
000287120814      *
000288120814      * \param name of the library of the item
000289120814      * \param name of the file of the item
000290120814      * \param name of the member of the item
000291120814      */
000292120814     p CCODSTATS_deleteStatistics...
000293120814     p                 b                   export
000294120814     d                 pi
000295120814     d libraryName                   10a   const varying
000296120814     d fileName                      10a   const varying
000297120814     d memberName                    10a   const varying
000298120814
000299120814      /free
000300120814       monitor;
000301120814         EXEC SQL
000302120829           DELETE
000303120829            FROM MDZAOPEDEP
000304120829           WHERE OPENOMMBR = :MEMBERNAME
000305120829             AND OPEARCSRC = :FILENAME
000306120829             AND OPEBIBSRC = :LIBRARYNAME;
000307120814
000308120814         CSQLUTIL_checkSQLState(SQLSTT:'DELETE MDZA_OPERADORES_DEPRECADOS');
000309120814
000310120814         EXEC SQL
000311120829           DELETE
000312120829            FROM MDZALINHOJ
000313120829           WHERE LINNOMMBR = :MEMBERNAME
000314120829             AND LINARCSRC = :FILENAME
000315120829             AND LINBIBSRC = :LIBRARYNAME;
000316120814
000317120814         CSQLUTIL_checkSQLState(SQLSTT:'DELETE MDZA_LINEAS_HOJA');
000318120814
000319120814         EXEC SQL
000320120829           DELETE
000321120829            FROM MDZAESTCOD
000322120829           WHERE ESTNOMMBR = :MEMBERNAME
000323120829             AND ESTARCSRC = :FILENAME
000324120829             AND ESTBIBSRC = :LIBRARYNAME;
000325120814
000326120814         CSQLUTIL_checkSQLState(SQLSTT:'DELETE MDZA_ESTADISTICAS_CODIGO');
000327120814       on-error;
000328120814         CEXCEPTION_catchException();
000329120814         CEXCEPTION_printStackTrace();
000330120814       endmon;
000331120814      /end-free
000332120814     p                 e
000333120814      //_______________________________________________________________________
000334120814
000335120809     /**
000336120809      * \brief CCODSTATS_writeStatistics write calculated statistics to a file
000337120809      *
000338120809      * <p>
000339120809      *  This procedure writes the calculated statistics to a output file
000340120809      * </p>
000341120809      *
000342120809      * \param name of the member to which the metrics were calculated
000343120809      * \param name of the file to which the metrics were calculated
000344120809      * \param name of the library to which the metrics were calculated
000345120809      * \param type of the member to which the metrics were calculated
000346120809      */
000347120626     p CCODSTATS_writeStatistics...
000348120626     p                 b                   export
000349120626     d                 pi
000350120626     d memberName                    10a   const varying
000351120626     d fileName                      10a   const varying
000352120626     d libraryName                   10a   const varying
000353120626     d memberType                    10a   const varying
000354120626     d
000355120626     d blankLines      s              5i 0
000356120626     d commentsCount   s             10i 0
000357120626     d totalLines      s             10i 0
000358120626     d unknownLines    s             10i 0
000359120626     d deprecatedOps   s             10i 0
000360120626     d compatibleOps   s             10i 0
000361120626     d inlineVar       s             10i 0
000362120626     d conditionalIndicators...
000363120626     d                 s             10i 0
000364120626     d resultingIndicators...
000365120626     d                 s             10i 0
000366120626     d indicatorVariables...
000367120626     d                 s             10i 0
000368120626     d columnarLines   s             10i 0
000369120626     d freeLines       s             10i 0
000370120829     d lastModificationDate...
000371120829     d                 s               z
000372120829     d creationDate    s               d
000373120809     d sqlStmt         s           5000a
000374120809
000375120626      /free
000376120630       totalLines            = sourceCodeStatistics.totalLines;
000377120630       commentsCount         = sourceCodeStatistics.commentsCount;
000378120630       blankLines            = sourceCodeStatistics.blankLineCount;
000379120630       unknownLines          = sourceCodeStatistics.unknownLineCount;
000380120626       deprecatedOps         = CCODSTATS_countDeprecatedOperators();
000381120630       compatibleOps         = sourceCodeStatistics.validOperators;
000382120630       inlineVar             = sourceCodeStatistics.inlineVariables;
000383120630       conditionalIndicators = sourceCodeStatistics.conditionalIndicators;
000384120630       resultingIndicators   = sourceCodeStatistics.resultingIndicators;
000385120630       indicatorVariables    = sourceCodeStatistics.indicatorsAsVariables;
000386120830       columnarLines         = getColumnarLineCountByType(CSPEC);
000387120630       freeLines             = sourceCodeStatistics.freeLineCount;
000388120829       lastModificationDate  = sourceCodeStatistics.lastModificationDate;
000389120829       creationDate          = sourceCodeStatistics.memberCreationDate;
000390120626
000391120626       //Delete previous record
000392120814       CCODSTATS_deleteStatistics(libraryName:fileName:memberName);
000393120626
000394120626       //Save the main statistics on the MDZAESTCOD table
000395120626       EXEC SQL
000396120829         INSERT INTO MDZAESTCOD (
000397120829                     ESTNOMMBR, ESTARCSRC, ESTBIBSRC,
000398120829                     ESTTIPSRC, ESTLINBLA, ESTLINCOM,
000399120829                     ESTLINDIR, ESTLINCOL, ESTLINFRE,
000400120829                     ESTLINTOT, ESTOPEOBS, ESTOPECMP,
000401120829                     ESTVARLIN, ESTINDCON, ESTINDRES,
000402120829                     ESTINDVAR, ESTFECMOD, ESTFECCRT)
000403120829              VALUES (:MEMBERNAME,   :FILENAME,      :LIBRARYNAME,
000404120829                      :MEMBERTYPE,   :BLANKLINES,    :COMMENTSCOUNT,
000405120829                      :UNKNOWNLINES, :COLUMNARLINES, :FREELINES,
000406120829                      :TOTALLINES,   :DEPRECATEDOPS, :COMPATIBLEOPS,
000407120829                      :INLINEVAR,    :CONDITIONALINDICATORS,
000408120829                      :RESULTINGINDICATORS, :INDICATORVARIABLES,
000409120829                      :LASTMODIFICATIONDATE, :CREATIONDATE);
000410120626
000411120829       CSQLUTIL_CHECKSQLSTATE(SQLSTT:'INSERT CODE STATS');
000412120626
000413120626       //Save the data related with deprecated operators
000414120626       saveDeprecatedOperators(memberName:fileName:libraryName);
000415120720
000416120809       //Save lines by specification type
000417120809       saveLinesBySpec(memberName:fileName:libraryName);
000418120809
000419120626      /end-free
000420120626     p                 e
000421120626      //_______________________________________________________________________
000422120626
000423120626     p CCODSTATS_getMetricGenerationDateTime...
000424120626     p                 b                   export
000425120626     d                 pi              n
000426120626     d libraryName                   10a   const varying
000427120626     d fileName                      10a   const varying
000428120626     d memberName                    10a   const varying
000429120626     d generationDateTime...
000430120626     d                                 z
000431120626
000432120626      /free
000433140311       EXEC SQL
000434140311         SELECT ESTFECANA
000435140311           INTO :GENERATIONDATETIME
000436140311           FROM MDZAESTCOD
000437140311          WHERE ESTNOMMBR = :MEMBERNAME
000438140311            AND ESTARCSRC = :FILENAME
000439140311            AND ESTBIBSRC = :LIBRARYNAME;
000440120626
000441120626       return CSQLUTIL_checkSQLState(SQLSTT:'SELECT GENERATIONDATETIME');
000442120626      /end-free
000443120626     p                 e
000444120626      //_______________________________________________________________________
000445120626
000446120626     /**
000447120626      * \brief saveDeprecatedOperators writes the list of deprecated operators
000448120626      *
000449120626      * <p>
000450120626      *  This procedure writes the list of deprecated operators to the
000451120626      *  corresponding database table
000452120626      * </p>
000453120626      *
000454120626      * \param name of the source member
000455120626      * \param name of the source file
000456120626      * \param library containing the source file
000457120626      */
000458120626     p saveDeprecatedOperators...
000459120626     p                 b                   export
000460120626     d                 pi
000461120626     d memberName                    10a   const varying
000462120626     d fileName                      10a   const varying
000463120626     d libraryName                   10a   const varying
000464120626     d
000465120626     d keyPtr          s               *   inz(*null)
000466120626     d key             s            255a   varying based(keyPtr)
000467120626     d valuePtr        s               *   inz(*null)
000468120626     d value           s             10i 0 based(valuePtr)
000469120626
000470120626      /free
000471120626       monitor;
000472120814         if sourceCodeStatistics.deprecatedOperators <> *NULL;
000473120814           keyPtr = lmap_iterate(sourceCodeStatistics.deprecatedOperators);
000474120626
000475120814           dow (keyPtr <> *NULL);
000476120814             valuePtr = lmap_get(sourceCodeStatistics.deprecatedOperators
000477120814                                :keyPtr
000478120814                                :%size(key));
000479120814             EXEC SQL
000480120829               INSERT INTO MDZAOPEDEP
000481120829                    VALUES (:MEMBERNAME, :FILENAME, :LIBRARYNAME, :KEY, :VALUE);
000482120626
000483120814             CSQLUTIL_CHECKSQLSTATE(SQLSTT:'INSERT DEPRECATED OPS');
000484120626
000485120814             keyPtr = lmap_iterate(sourceCodeStatistics.deprecatedOperators);
000486120814           enddo;
000487120814         endif;
000488120626       on-error;
000489120626         CEXCEPTION_catchException();
000490120626         CEXCEPTION_printStackTrace();
000491120626       endmon;
000492120626      /end-free
000493120626     p                 e
000494120626      //_______________________________________________________________________
000495120626
000496120809     /**
000497120809      * \brief saveLinesBySpec writes the list of line count by type
000498120809      *
000499120809      * <p>
000500120809      *  This procedure writes count of columnar lines by type to the
000501120809      *  corresponding database table
000502120809      * </p>
000503120809      *
000504120809      * \param name of the source member
000505120809      * \param name of the source file
000506120809      * \param library containing the source file
000507120809      */
000508120809     p saveLinesBySpec...
000509120809     p                 b                   export
000510120809     d                 pi
000511120809     d memberName                    10a   const varying
000512120809     d fileName                      10a   const varying
000513120809     d libraryName                   10a   const varying
000514120809     d
000515120809     d keyPtr          s               *   inz(*null)
000516120830     d key             s              1a   based(keyPtr)
000517120809     d valuePtr        s               *   inz(*null)
000518120809     d value           s             10i 0 based(valuePtr)
000519120809
000520120809      /free
000521120814       monitor;
000522120814         if (sourceCodeStatistics.columnarLinesByType <> *NULL);
000523120814           keyPtr = lmap_iterate(sourceCodeStatistics.columnarLinesByType);
000524120809
000525120814           dow (keyPtr <> *NULL);
000526120814             valuePtr = lmap_get(sourceCodeStatistics.columnarLinesByType
000527120814                                :keyPtr
000528120814                                :%size(key));
000529120814             EXEC SQL
000530120829               INSERT INTO MDZALINHOJ
000531120829                    VALUES (:MEMBERNAME, :FILENAME, :LIBRARYNAME, :KEY, :VALUE);
000532120809
000533120814             CSQLUTIL_CHECKSQLSTATE(SQLSTT:'INSERT SPEC COUNT');
000534120809
000535120814             keyPtr = lmap_iterate(sourceCodeStatistics.columnarLinesByType);
000536120814           enddo;
000537120814         endif;
000538120809       on-error;
000539120809         CEXCEPTION_catchException();
000540120809         CEXCEPTION_printStackTrace();
000541120809       endmon;
000542120809      /end-free
000543120809     p                 e
000544120809      //_______________________________________________________________________
000545120809
000546120626     /**
000547120626      * \brief CCODSTATS_addDeprecatedOperator adds a deprecated operator
000548120626      *
000549120626      * <p>
000550120626      *  This procedure add a deprecated operator to the list. If the operator
000551120626      *  was already registered add it to the count, otherwise, register it
000552120626      *
000553120626      * \param operator to add
000554120626      * </p>
000555120626      */
000556120529     p CCODSTATS_addDeprecatedOperator...
000557120529     p                 b                   export
000558120529     d                 pi
000559120529     d operator                     255a   const varying
000560120626     d
000561120529     d count           s             10i 0
000562120529     d ptrEntry        s               *   inz(*NULL)
000563120529     d entry           s             10i 0 based(ptrEntry)
000564120529     d tempOperator    s                   like(operator)
000565120529
000566120529      /free
000567120529       monitor;
000568120813         //Allocate a new map
000569120813         if sourceCodeStatistics.deprecatedOperators = *NULL;
000570120813           sourceCodeStatistics.deprecatedOperators = lmap_create();
000571120813         endif;
000572120813
000573120529         tempOperator = operator;
000574120529
000575120529         ptrEntry = lmap_get(sourceCodeStatistics.deprecatedOperators
000576120529                            :%addr(tempOperator):%size(tempOperator));
000577120529
000578120529         if (ptrEntry = *NULL);
000579120529           //Add a new deprecated operator
000580120529           count = 1;
000581120529           lmap_add(sourceCodeStatistics.deprecatedOperators
000582120529                   :%addr(tempOperator)
000583120529                   :%size(tempOperator)
000584120529                   :%addr(count)
000585120529                   :%size(count));
000586120529         else;
000587120529           //Update the count of the operator
000588120529           entry += 1;
000589120529         endif;
000590120529       on-error;
000591120529         CEXCEPTION_catchException();
000592120529         CEXCEPTION_printStackTrace();
000593120529         CEXCEPTION_throwNewException(ERROR_REGISTERING_DEPRECATED
000594120529                                     :MDZN_MESSAGE_FILE);
000595120529       endmon;
000596120529      /end-free
000597120529     p                 e
000598120529      //_______________________________________________________________________
000599120529
000600120830     /**
000601120830      * \brief getColumnarLineCountByType: returns columnar lines count by type
000602120830      *
000603120830      * <p>
000604120830      *  Returns the count of an specific columnar line type
000605120830      * </p>
000606120830      *
000607120830      * \return line count for the indicated type
000608120830      */
000609120830     p getColumnarLineCountByType...
000610120830     p                 b
000611120830     d                 pi            10i 0
000612120830     d type                           5a   const
000613120830     d key             s              5a
000614120830     d keyPtr          s               *   inz(*null)
000615120830     d valuePtr        s               *   inz(*null)
000616120830     d value           s             10i 0 based(valuePtr)
000617120830
000618120830      /free
000619120830       monitor;
000620120830         if (sourceCodeStatistics.columnarLinesByType <> *NULL);
000621120830           key    = type;
000622120830           keyPtr = %addr(key);
000624120830           valuePtr = lmap_get(sourceCodeStatistics.columnarLinesByType
000625120830                              :keyPtr
000626120830                              :%len(%trim(key)));
000627120830
000628120830           if (valuePtr <> *NULL);
000629120830             return value;
000630120830           else;
000631120830             return 0;
000632120830           endif;
000634120830         else;
000635120830           return 0;
000636120830         endif;
000637120830       on-error;
000638120830         CEXCEPTION_catchException();
000639120830         CEXCEPTION_printException();
000640120830         return -1;
000641120830       endmon;
000642120830      /end-free
000643120830     p                 e
000644120830      //_______________________________________________________________________
000645120830
000646120626     /**
000647120626      * \brief CCODSTATS_addTotalLines adds to the total lines counter
000648120626      *
000649120626      * <p>
000650120626      *  This procedure adds a new line to the totalLines counter
000651120626      * </p>
000652120626      */
000653120528     p CCODSTATS_addTotalLines...
000654120528     p                 b                   export
000655120528
000656120528      /free
000657120528       sourceCodeStatistics.totalLines += 1;
000658120528      /end-free
000659120528     p                 e
000660120528      //_______________________________________________________________________
000661120528
000662120626     /**
000663120626      * \brief CCODSTATS_addCommentsCount adds to the coment countes
000664120626      *
000665120626      * <p>
000666120626      *  This procedures adds to the comments counter
000667120626      * </p>
000668120626      */
000669120528     p CCODSTATS_addCommentsCount...
000670120528     p                 b                   export
000671120528
000672120528      /free
000673120528       sourceCodeStatistics.commentsCount += 1;
000674120528      /end-free
000675120528     p                 e
000676120528      //_______________________________________________________________________
000677120528
000678120809     /**
000679120809      * \brief CCODSTATS_addBlankLines adds to the blank lines count
000680120809      *
000681120809      * <p>
000682120809      *  This procedure adds one ocurrence to the blank lines counter
000683120809      * </p>
000684120809      */
000685120528     p CCODSTATS_addBlankLines...
000686120528     p                 b                   export
000687120528      /free
000688120626       sourceCodeStatistics.blankLineCount += 1;
000689120528      /end-free
000690120528     p                 e
000691120528      //_______________________________________________________________________
000692120528
000693120809     /**
000694120809      * \brief CCODSTATS_countDeprecatedOperators add to the related count
000695120809      *
000696120809      * <p>
000697120809      *  This procedure counts the deprecated operators. Using a map (key-pair
000698120809      *  list) keeps the counter for every deprecated operator detected in
000699120809      *  the code
000700120809      * </p>
000701120809      *
000702120809      * \return total quantity of deprecated oeprators
000703120809      */
000704120528     p CCODSTATS_addLineCount...
000705120528     p                 b                   export
000706120528     d                 pi
000707120528     d lineType                       5a   const
000708120809     d
000709120809     d key             s                   like(lineType)
000710120809     d value           s             10i 0 based(currentCountPtr)
000711120809     d valuePtr        s               *   inz(*null)
000712120809     d newValue        s             10i 0
000713120809     d newKey          s              5a
000714120809
000715120528      /free
000716120809       monitor;
000717120809         if lineType = FREE_LINE;
000718120809           sourceCodeStatistics.freeLineCount += 1;
000719120809           return;
000720120809         else;
000721120809           sourceCodeStatistics.columnarLineCount += 1;
000722120809         endif;
000723120809
000724120809         if sourceCodeStatistics.columnarLinesByType = *NULL;
000725120809           sourceCodeStatistics.columnarLinesByType = lmap_create();
000726120809         endif;
000727120809
000728120809         key = lineType;
000729120809
000730120809         currentCountPtr = lmap_get(sourceCodeStatistics.columnarLinesByType
000731120809             :%addr(key):%len(%trim(key)));
000732120809
000733120809         if (currentCountPtr = *NULL);
000734120809           newValue = 1;
000735120809           newKey   = lineType;
000736120809
000737120809           lmap_add(sourceCodeStatistics.columnarLinesByType:%addr(newKey)
000738120809              :%len(%trim(newKey)):%addr(newValue):%size(newValue));
000739120809         else;
000740120809           value += 1;
000741120809         endif;
000742120809       on-error;
000743120809         CEXCEPTION_catchException();
000744120809         CEXCEPTION_printStackTrace();
000745120809       endmon;
000746120528      /end-free
000747120528     p                 e
000748120528      //_______________________________________________________________________
000749120528
000750120809     /**
000751120809      * \brief CCODSTATS_addUnknownLines add to the related count
000752120809      *
000753120809      * <p>
000754120809      *  This procedure adds one occurrence to the unknown lines counter
000755120809      * </p>
000756120809      */
000757120528     p CCODSTATS_addUnknownLines...
000758120528     p                 b                   export
000759120528
000760120528      /free
000761120528       sourceCodeStatistics.unknownLineCount += 1;
000762120528      /end-free
000763120528     p                 e
000764120528      //_______________________________________________________________________
000765120528
000766120809     /**
000767120809      * \brief CCODSTATS_countDeprecatedOperators add to the related count
000768120809      *
000769120809      * <p>
000770120809      *  This procedure counts the deprecated operators. Using a map (key-pair
000771120809      *  list) keeps the counter for every deprecated operator detected in
000772120809      *  the code
000773120809      * </p>
000774120809      *
000775120809      * \return total quantity of deprecated oeprators
000776120809      */
000777120530     p CCODSTATS_countDeprecatedOperators...
000778120530     p                 b                   export
000779120530     d                 pi            10i 0
000780120530     d keyPtr          s               *   inz(*null)
000781120530     d key             s            255a   varying based(keyPtr)
000782120530     d valuePtr        s               *   inz(*null)
000783120530     d value           s             10i 0 based(valuePtr)
000784120530     d count           s             10i 0 inz(0)
000785120530
000786120530      /free
000787120530       monitor;
000788120814         if (sourceCodeStatistics.deprecatedOperators <> *NULL);
000789120814           keyPtr = lmap_iterate(sourceCodeStatistics.deprecatedOperators);
000790120530
000791120814           dow (keyPtr <> *null);
000792120814             valuePtr = lmap_get(sourceCodeStatistics.deprecatedOperators
000793120814                                :keyPtr
000794120814                                :%size(key));
000795120814             count += value;
000796120814             keyPtr = lmap_iterate(sourceCodeStatistics.deprecatedOperators);
000797120814           enddo;
000798120814         endif;
000799120530       on-error;
000800120530         CEXCEPTION_catchException();
000801120530         CEXCEPTION_printStackTrace();
000802120530       endmon;
000803120814
000804120814       return count;
000805120530      /end-free
000806120530     p                 e
000807120530      //_______________________________________________________________________
000808120530
000809120809     /**
000810120809      * \brief CCODSTATS_addValidOperator add to the related count
000811120809      *
000812120809      * <p>
000813120809      *  This procedure adds one ocurrence to the valid operator counter
000814120809      * </p>
000815120809      */
000816120530     p CCODSTATS_addValidOperator...
000817120530     p                 b                   export
000818120530
000819120530      /free
000820120531       sourceCodeStatistics.validOperators += 1;
000821120530      /end-free
000822120530     p                 e
000823120530      //_______________________________________________________________________
000824120530
000825120809     /**
000826120809      * \brief CCODSTATS_addInLineDeclaration add to the related count
000827120809      *
000828120809      * <p>
000829120809      *  This procedure adds one occurrence to the inline declaration counter
000830120809      * </p>
000831120809      */
000832120531     p CCODSTATS_addInLineDeclaration...
000833120531     p                 b                   export
000834120531
000835120531      /free
000836120531       sourceCodeStatistics.inlineVariables += 1;
000837120531      /end-free
000838120531     p                 e
000839120531      //_______________________________________________________________________
000840120531
000841120809     /**
000842120809      * \brief CCODSTATS_addConditionalIndicator add to the related count
000843120809      *
000844120809      * <p>
000845120809      *  This procedure adds one ocurrence to the conditional indicator
000846120809      *  counter
000847120809      * </p>
000848120809      *
000849120809      */
000850120531     p CCODSTATS_addConditionalIndicator...
000851120531     p                 b                   export
000852120531
000853120531      /free
000854120531       sourceCodeStatistics.conditionalIndicators += 1;
000855120531      /end-free
000856120531     p                 e
000857120531      //_______________________________________________________________________
000858120531
000859120809     /**
000860120809      * \brief CCODSTATS_addResultingIndicator adds to the related count
000861120809      *
000862120809      * <p>
000863120809      *  This procedure adds one occurrence to the resulting indicators
000864120809      *  counter
000865120809      * </p>
000866120809      *
000867120809      */
000868120531     p CCODSTATS_addResultingIndicator...
000869120531     p                 b                   export
000870120531
000871120531      /free
000872120531       sourceCodeStatistics.resultingIndicators += 1;
000873120531      /end-free
000874120531     p                 e
000875120601      //_______________________________________________________________________
000876120601
000877120809     /**
000878120809      * \brief CCODSTATS_addIndicatorAsVariable adds to the related count
000879120809      *
000880120809      * <p>
000881120809      *  This procedure adds one occurrence to the indicators used as
000882120809      *  variables counter
000883120809      * </p>
000884120809      */
000885120601     p CCODSTATS_addIndicatorAsVariable...
000886120601     p                 b                   export
000887120601
000888120601      /free
000889120601       sourceCodeStatistics.indicatorsAsVariables += 1;
000890120601      /end-free
000891120601     p                 e
000892120611      //_______________________________________________________________________
000893120611
000894120530      /////////////////////////////////////////////////////////////////////
000895120530      // Getters / Setters
000896120530      /////////////////////////////////////////////////////////////////////
000897120530
000898120528     p CCODSTATS_getTotalLines...
000899120528     p                 b                   export
000900120528     d                 pi            10i 0
000901120528
000902120528      /free
000903120528       return sourceCodeStatistics.totalLines;
000904120528      /end-free
000905120528     p                 e
000906120528      //_______________________________________________________________________
000907120528
000908120528     p CCODSTATS_getCommentsCount...
000909120528     p                 b                   export
000910120528     d                 pi            10i 0
000911120528
000912120528      /free
000913120528       return sourceCodeStatistics.commentsCount;
000914120528      /end-free
000915120528     p                 e
000916120528      //_______________________________________________________________________
000917120528
000918120528     p CCODSTATS_getBlankLinesCount...
000919120528     p                 b                   export
000920120528     d                 pi            10i 0
000921120528
000922120528      /free
000923120626       return sourceCodeStatistics.blankLineCount;
000924120528      /end-free
000925120528     p                 e
000926120528      //_______________________________________________________________________
000927120528
000928120528     p CCODSTATS_getFreeLineCount...
000929120528     p                 b                   export
000930120528     d                 pi            10i 0
000931120528
000932120528      /free
000933120528       return sourceCodeStatistics.freeLineCount;
000934120528      /end-free
000935120528     p                 e
000936120528      //_______________________________________________________________________
000937120528
000938120528     p CCODSTATS_getUnknownLineCount...
000939120528     p                 b                   export
000940120528     d                 pi            10i 0
000941120528
000942120528      /free
000943120528       return sourceCodeStatistics.unknownLineCount;
000944120528      /end-free
000945120528     p                 e
000946120528      //_______________________________________________________________________
000947120529
000948120809     /**
000949120809      * \brief CCODSTATS_getDeprecatedOperators retrieves the related count
000950120809      *
000951120809      * <p>
000952120809      *  This procedure returns the count of deprecated operators
000953120809      * </p>
000954120809      *
000955120809      * \return count of deprecated operators
000956120809      */
000957120529     p CCODSTATS_getDeprecatedOperators...
000958120529     p                 b                   export
000959120529     d                 pi              *
000960120529
000961120529      /free
000962120529       return sourceCodeStatistics.deprecatedOperators;
000963120529      /end-free
000964120529     p                 e
000965120531      //_______________________________________________________________________
000966120531
000967120809     /**
000968120809      * \brief CCODSTATS_getValidOperators retrieves the related count
000969120809      *
000970120809      * <p>
000971120809      *  This procedure returns the count of valid operators
000972120809      * </p>
000973120809      *
000974120809      * \return count of operators compatible with free format
000975120809      */
000976120531     p CCODSTATS_getValidOperators...
000977120531     p                 b                   export
000978120531     d                 pi            10i 0
000979120531
000980120531      /free
000981120531       return sourceCodeStatistics.validOperators;
000982120531      /end-free
000983120531     p                 e
000984120531      //_______________________________________________________________________
000985120531
000986120809     /**
000987120809      * \brief CCODSTATS_getInlineDeclarations retrieves the related count
000988120809      *
000989120809      * <p>
000990120809      *  This procedure returns the count of variables declared inline
000991120809      * </p>
000992120809      *
000993120809      * \return count of variables declared inline
000994120809      */
000995120531     p CCODSTATS_getInlineDeclarations...
000996120531     p                 b                   export
000997120531     d                 pi            10i 0
000998120531
000999120531      /free
001000120531       return sourceCodeStatistics.inlineVariables;
001001120531      /end-free
001002120531     p                 e
001003120531      //_______________________________________________________________________
001004120531
001005120809     /**
001006120809      * \brief CCODSTATS_getConditionalIndicators retrieves the related count
001007120809      *
001008120809      * <p>
001009120809      *  This procedure retrieves the count of conditional indicators used
001010120809      * </p>
001011120809      *
001012120809      * \return count of conditional indicators
001013120809      */
001014120531     p CCODSTATS_getConditionalIndicators...
001015120531     p                 b                   export
001016120531     d                 pi            10i 0
001017120531
001018120531      /free
001019120531       return sourceCodeStatistics.conditionalIndicators;
001020120531      /end-free
001021120531     p                 e
001022120531      //_______________________________________________________________________
001023120531
001024120809     /**
001025120809      * \brief CCODSTATS_getResultingIndicators retrieves the related count
001026120809      *
001027120809      * <p>
001028120809      *  This procedure retrieves the count of resulting indicators used
001029120809      *  in the source code
001030120809      * </p>
001031120809      *
001032120809      * \return count of resulting indicators used
001033120809      */
001034120531     p CCODSTATS_getResultingIndicators...
001035120531     p                 b                   export
001036120531     d                 pi            10i 0
001037120531
001038120531      /free
001039120531       return sourceCodeStatistics.resultingIndicators;
001040120531      /end-free
001041120531     p                 e
001042120601      //_______________________________________________________________________
001043120601
001044120809     /**
001045120809      * \brief CCODSTATS_getIndicatorsAsVariables retrieves the related count
001046120809      *
001047120809      * <p>
001048120809      *  This procedure retrieves the count of indicators used as variables
001049120809      * </p>
001050120809      *
001051120809      * \return count of indicators used as variables
001052120809      */
001053120601     p CCODSTATS_getIndicatorsAsVariables...
001054120601     p                 b                   export
001055120601     d                 pi            10i 0
001056120601
001057120601      /free
001058120601       return sourceCodeStatistics.indicatorsAsVariables;
001059120601      /end-free
001060120601     p                 e
001061120809      //_______________________________________________________________________
001062120829
001063120829     /**
001064120829      * \brief CCODSTATS_getLastModificationDate: retrieve the related value
001065120829      *
001066120829      * <p>
001067120829      *  Retrieve the last modification date and time of an specific member
001068120829      * </p>
001069120829      *
001070120829      * \return timestamp containing the last modification date and time
001071120829      */
001072120829     p CCODSTATS_getLastModificationDate...
001073120829     p                 b                   export
001074120829     d                 pi              z
001075120829
001076120829      /free
001077120829       return sourceCodeStatistics.lastModificationDate;
001078120829      /end-free
001079120829     p                 e
001080120829      //_______________________________________________________________________
001081120829
001082120829     /**
001083120829      * \brief CCODSTATS_setLastModificationDate: sets the related value
001084120829      *
001085120829      * <p>
001086120829      *  This procedure sets the last modification date of the member
001087120829      * </p>
001088120829      *
001089120829      * \param timestamp of the last modification of the member
001090120829      */
001091120829     p CCODSTATS_setLastModificationDate...
001092120829     p                 b                   export
001093120829     d                 pi
001094120829     d modificationDateTime...
001095120829     d                                 z   const
001096120829
001097120829      /free
001098120829       sourceCodeStatistics.lastModificationDate = modificationDateTime;
001099120829      /end-free
001100120829     p                 e
001101120829      //_______________________________________________________________________
001102120829
001103120829     p CCODSTATS_setMemberCreationDate...
001104120829     p                 b                   export
001105120829     d                 pi
001106120829     d creationDate                    d   const
001107120829
001108120829      /free
001109120829       sourceCodeStatistics.memberCreationDate = creationDate;
001110120829      /end-free
001111120829     p                 e
