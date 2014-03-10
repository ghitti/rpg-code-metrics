000100120628     /**
000101120630      * \brief CRPGPARUTL: utility parsing procedures
000102120628      *
000103120628      * <p>
000104120628      *  This module contains utility parsing procedures
000107120628      * </p>
000108120628      *
000109120628      * \author Isaaac Ramirez Herrera
000110120628      * \date   May, 2012
000111120628      * \rev    22-05-2012 Isaac Ramirez
000112120628      */
000113120528     h nomain
000114140310     h bnddir('CMDZBNDDIR')
000115120630     h option(*srcstmt)
000116120528
000117120630      /include qtoolstxt,crpgparutl
000118120528      /include qtoolstxt,cmdznconst
000119140310      /include qtoolstxt,lmap_h
000120120630      /include qtoolstxt,cstringutl
000121140310      /include qtoolstxt,cexception
000122120630      /include qtoolstxt,ccodstats
000123140310      /include qtoolstxt,cregexp
000124120528
000125120628      /////////////////////////////////////////////////////////////////////
000126120628      // Constants declarations
000127120628      /////////////////////////////////////////////////////////////////////
000128120628
000129120528     d LOWER           c                   'abcdefghijklmnopqrstuvwxyz'
000130120528     d UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
000131120630
000132120630      //Configuration XML paths
000133120630     d INDICATOR_PATH  c                   const('codeMetricsConfig/rpg/+
000134120630     d                                     generalConfiguration+
000135120630     d                                     /indicatorsPattern')
000136120630     d DEPRECATED_OPS_PATH...
000137120630     d                 c                   const('codeMetricsConfig/rpg/+
000138120630     d                                     generalConfiguration/+
000139120630     d                                     deprecatedOperators/operator' )
000140120630
000141120628      /////////////////////////////////////////////////////////////////////
000142120628      // Global variable definition
000143120628      /////////////////////////////////////////////////////////////////////
000144120628
000145120630      //Contains the path and name of the configuration xml
000146120630     d ConfXMLPath     s           2000a   dtaara(CODMETXMLP)
000147120630
000148120630      //Contains the base configuration
000149120630     d RPGParserConfig...
000150120630     d                 ds                  qualified
000151120630     d
000152120628     d  indicatorsPattern...
000153120628     d                              100a   inz(*blanks)
000154120628     d  deprecatedOperators...
000155120630     d                                 *   inz(*null)
000156120628
000157120630      //Structure of the deprecated operators in the XML
000158120630     d operator        ds                  qualified based(@dummy)
000159120529     d  name                         10a   varying
000160120529     d  alternativeName...
000161120529     d                               10a   varying
000162120628
000163120628      /////////////////////////////////////////////////////////////////////
000164120628      // Prototype declaration
000165120628      /////////////////////////////////////////////////////////////////////
000166120628
000167120531     d populateDeprecatedOpList...
000168120531     d                 pr            10i 0
000169120531     d communication                 10a
000170120531     d element                             dim(1) likeds(operator) const
000171120531     d elementCount                  10i 0 value
000172120531
000173120630     d searchForIndicatorVariable...
000175120630     d                 pr              n
000176120630     d textBlock                    255a   const varying
000177120630
000178120529      /////////////////////////////////////////////////////////////////////
000179120529      // Procedure definition
000180120529      /////////////////////////////////////////////////////////////////////
000181120529
000182120630     /**
000183120630      * \brief CRPGPARUTL_config: reads the xml configuration file
000184120630      *
000185120630      * <p>
000186120630      *  This procedure reads the xml configuration file containing the
000187120630      *  particular configuration for the parsers.
000188120630      * </p>
000189120630      *
000190120630      */
000191120630     p CRPGPARUTL_config...
000192120630     p                 b                   export
000193120630     p
000194120630     d communication   s             10a
000195120630     d options         s           1000a
000196120630
000197120630      /free
000198120630       monitor;
000199120630         //Read configuration file full path and name from dtaara
000200120630         in ConfXMLPath;
000201120630
000202120630         //Load indicators pattern
000203120630         options = 'doc=file path=&1 &2';
000204120630         options = CSTRINGUTL_parse(options:INDICATOR_PATH:XML_INTO_CONFIG);
000205120630         xml-into RPGParserConfig.indicatorsPattern
000206120630                  %xml(%trim(ConfXMLPath):options);
000207120630
000208120630         //Load all deprecated operators
000209120630         if RPGParserConfig.deprecatedOperators <> *NULL;
000210120630           lmap_dispose(RPGParserConfig.deprecatedOperators);
000211120630         endif;
000212120630
000213120630         RPGParserConfig.deprecatedOperators = lmap_create();
000214120630
000215120630         options = 'doc=file path=&1 &2';
000216120630         options = CSTRINGUTL_parse(options:DEPRECATED_OPS_PATH
000217120630                                   :XML_INTO_CONFIG);
000218120630         xml-into %handler(populateDeprecatedOpList : communication)
000219120630                  %xml(%trim(ConfXMLPath):options);
000220120630       on-error;
000221120630         CEXCEPTION_catchException();
000222120630         CEXCEPTION_printStackTrace();
000223120630         CEXCEPTION_throwNewException(ERROR_CREATING_PARSER:MDZN_MESSAGE_FILE);
000224120630       endmon;
000225120630      /end-free
000226120630     p                 e
000227120630      //_______________________________________________________________________
000228120630
000229120630     /**
000230120630      * \brief populateDeprecatedOpList: inserts a operator in the list
000231120630      *
000232120630      * <p>
000233120630      *  This procedure inserts into the deprecated operators list a single
000234120630      *  operator readed from the configuration xml. This procedure
000235120630      *  is the handler of an XML-INTO operation
000236120630      * </p>
000237120630      *
000238120630      * \param communication area
000239120630      * \param element to be added
000240120630      * \param total count of elements
000241120630      *
000242120630      * \return always return 0
000243120630      */
000244120630     p populateDeprecatedOpList...
000245120630     p                 b
000246120630     d                 pi            10i 0
000247120630     d communication                 10a
000248120630     d element                             dim(1) likeds(operator) const
000249120630     d elementCount                  10i 0 value
000250120630     d key             s            255a   varying
000251120630     d value           ds                  likeds(operator)
000252120630
000253120630      /free
000254120630       key = CRPGPARUTL_toUpper(%trim(element(1).name));
000255120630       eval-corr value = element(1);
000257120630
000259120630       lmap_add(RPGParserConfig.deprecatedOperators:%addr(key):%size(key)
000260120630               :%addr(value):%size(value));
000261120630
000262120630       return 0;
000263120630      /end-free
000264120630     p                 e
000265120630      //_______________________________________________________________________
000266120630
000267120628     /**
000268120630      * \brief CRPGPARUTL_lineSubst: gets the string between the columns
000269120628      *
000270120628      * <p>
000271120628      *  This procedures returns the string contained between two columns
000272120628      *  number
000273120628      * </p>
000274120628      *
000275120628      * \param line to substring
000276120628      * \param initial column
000277120628      * \param ending column
000278120628      * \param max column
000279120628      *
000280120628      * \return substring
000281120628      */
000282120630     p CRPGPARUTL_lineSubst...
000283120528     p                 b                   export
000284120528     d                 pi           255a   varying
000285120528     d codeLine                     255a   const varying
000286120528     d beginColumn                   10i 0 const
000287120528     d endColumn                     10i 0 const
000288120528     d maxColumn                     10i 0 const
000289120528     d size            s             10i 0
000290120528
000291120528      /free
000292120528       //Check parameters
000293120528       if (beginColumn > 0          and endColumn > 0)    and
000294120528          (beginColumn <= maxColumn and endColumn <= maxColumn) and
000295120528          (beginColumn <= endColumn);
000296120528
000297120528         size = (endColumn - beginColumn) + 1;
000298120528         return %subst(codeLine:beginColumn:size);
000299120528       else;
000300120528         CEXCEPTION_throwNewException(INVALID_PARAMETERS:MDZN_MESSAGE_FILE);
000301120528       endif;
000302120528      /end-free
000303120528     p                 e
000304120528      //_______________________________________________________________________
000305120528
000306120628     /**
000307120630      * \brief CRPGPARUTL_toUpper: converts a string to uppercase
000308120628      *
000309120628      * <p>
000310120628      *  This procedure converts a string in uppercase
000311120628      * </p>
000312120628      *
000313120628      * \param string to convert
000314120628      * \return converted string
000315120628      */
000316120630     p CRPGPARUTL_toUpper...
000317120528     p                 b                   export
000318120528     d                 pi         65535a   varying
000319120528     d string                     65535a   const varying
000320120528
000321120528      /free
000322120528       return %xlate(LOWER:UPPER:string);
000323120528      /end-free
000324120528     p                 e
000325120528      //_______________________________________________________________________
000326120528
000327120628     /**
000328120630      * \brief CRPGPARUTL_toLower: convert character to lower
000329120628      *
000330120628      * <p>
000331120628      *  This procedure converts a string to lower case string
000332120628      * </p>
000333120628      *
000334120628      * \param string to convert
000335120628      * \return converted string
000336120628      */
000337120630     p CRPGPARUTL_toLower...
000338120528     p                 b                   export
000339120528     d                 pi         65535a   varying
000340120528     d string                     65535a   const varying
000341120528
000342120528      /free
000343120528       return %xlate(UPPER:LOWER:string);
000344120528      /end-free
000345120528     p                 e
000346120528      //_______________________________________________________________________
000347120528
000348120630     /**
000349120630      * \brief CRPGPARUTL_checkDeprecated: checks if a operator is in the list
000350120630      *
000351120630      * <p>
000352120630      *  Checks the deprecated operator hashmap to determine if a given operator
000353120630      *  is considered as deprecated
000354120630      * </p>
000355120630      *
000356120630      * \param operator to check
000357120630      * \return  *ON  = the operator is deprecated
000358120630      *          *OFF = the operator is not deprecated
000359120630      */
000360120630     p CRPGPARUTL_checkDeprecated...
000361120529     p                 b                   export
000362120529     d                 pi              n
000363120529     d operator                     255a   const varying
000364120529     d index           s             10i 0
000365120529     d tempOperator    s                   like(operator)
000366120531
000367120529      /free
000368120630       tempOperator = CRPGPARUTL_toUpper(%trim(operator));
000369120531
000370120630       if lmap_containsKey(RPGParserConfig.deprecatedOperators
000371120630              :%addr(tempOperator):%size(tempOperator));
000372120531         return *on;
000373120531       else;
000374120531         return *off;
000375120531       endif;
000376120531
000377120529       return *off;
000378120529      /end-free
000379120529     p                 e
000380120529      //_______________________________________________________________________
000381120529
000434120630     /**
000435120630      * \brief CRPGPARUTL_isFullCommentLine Determines if a line is a comment
000436120630      *
000437120630      * <p>
000438120630      *  This procedure determines if a line of source code is a comment.
000439120630      *  Considers free-format comments and columnar comments.
000440120630      * </p>
000441120630      *
000442120630      * \param string containing a line of source code
000443120630      *
000444120813      * \return  *ON: line is a comment                          -
000445120630      *         *OFF: line is not a comment
000446120630      */
000447120630     p CRPGPARUTL_isFullCommentLine...
000448120630     p                 b                   export
000449120630     d                 pi              n
000450120630     d codeLine                     255a   const varying
000451120813     d firstTwoChars   s              2a
000452120630
000453120630      /free
000454120630       //Check if the line is commented with a '*'
000455120630       if %subst(codeLine:SPEC_COLUMN + 1:1) = OLD_COMMENT_SYMBOL;
000456120630         return *on;
000457120630       else;
000458120814         firstTwoChars = %subst(%triml(%subst(codeLine:SPEC_COLUMN + 1)):1:2);
000459120813
000460120813         //Check if the line is commented with '//'
000461120813         if firstTwoChars = FREE_COMMENT_SYMBOL;
000462120813           return *on;
000463120813         else;
000466120813           return *off;
000467120813         endif;
000468120630       endif;
000469120630      /end-free
000470120630     p                 e
000471120630      //_______________________________________________________________________
000472120630
000473120809     /**
000474120809      * \brief CRPGPARUTL_isBlankLine determines if the current line is blank
000475120809      *
000476120809      * <p>
000477120809      *  This procedure checks the indicated line to determine if is blank
000478120809      * </p>
000479120809      *
000480120809      * \param code line to analyze
000481120809      * \return  *ON = line is a blank line
000482120809      *         *OFF = line is not a blank line
000483120809      */
000484120630     p CRPGPARUTL_isBlankLine...
000485120630     p                 b                   export
000486120630     d                 pi              n
000487120630     d codeLine                     255a   const varying
000488120630
000489120630      /free
000490120630       //Check if the line is blank after the format column
000491120630       if %trim(%subst(codeLine:SPEC_COLUMN + 1)) = *Blanks;
000492120630         return *on;
000493120630       else;
000494120630         return *off;
000495120630       endif;
000496120630      /end-free
000497120630     p                 e
000498120630      //_______________________________________________________________________
000499120630
000500120630     p CRPGPARUTL_isEndLineComment...
000501120630     p                 b                   export
000502120630     d                 pi              n
000503120630     d codeLine                     255a   const varying
000504120630     d commentStart                  10i 0 const
000505120630     d commentEnd                    10i 0 const
000506120630     d maxColumn                     10i 0 const
000507120630
000508120630      /free
000509120630       if %trim(CRPGPARUTL_lineSubst(codeLine:SPEC_COLUMN + 1
000510120630               :commentStart - 1:maxColumn)) = *blanks and
000511120630          %trim(CRPGPARUTL_lineSubst(codeLine:commentStart
000512120630               :commentEnd:maxColumn)) <> *blanks;
000513120630         return *on;
000514120630       else;
000515120630         return *off;
000516120630       endif;
000517120630      /end-free
000518120630     p                 e
000519120630      //_______________________________________________________________________
000520120630
000521120630     p CRPGPARUTL_checkConditionalIndicators...
000522120630     p                 b                   export
000523120630     d                 pi
000524120630     d codeLine                     255a   const varying
000525120630     d columnFrom                    10i 0 const
000526120630     d columnTo                      10i 0 const
000527120630     d maxColumn                     10i 0 const
000528120630     d
000529120630     d conditionalIndicators...
000530120630     d                 s              9a   varying
000531120630
000532120630      /free
000533120630       conditionalIndicators = CRPGPARUTL_lineSubst(codeLine:columnFrom:
000534120630                                  columnTo:maxColumn);
000535120630
000536120630       if %trim(conditionalIndicators) <> *blanks;
000537120630         CCODSTATS_addConditionalIndicator();
000538120630       endif;
000539120630      /end-free
000540120630     p                 e
000541120630      //_______________________________________________________________________
000542120630
000543120630     p CRPGPARUTL_checkInLineDeclaration...
000544120630     p                 b                   export
000545120630     d                 pi
000546120630     d codeLine                     255a   const varying
000547120630     d resultFrom                    10i 0 const
000548120630     d resultTo                      10i 0 const
000549120630     d lengthFrom                    10i 0 const
000550120630     d decimalTo                     10i 0 const
000551120630     d maxColumn                     10i 0 const
000552120630     d
000553120630     d resultField     s             50a   varying
000554120630     d resultFieldLen  s              4a   varying
000555120630
000556120630      /free
000557120630       resultField  = CRPGPARUTL_lineSubst(codeLine:resultFrom
000558120630          :resultTo:maxColumn);
000559120630
000560120630       resultFieldLen = CRPGPARUTL_lineSubst(codeLine:lengthFrom
000561120630          :decimalTo:maxColumn);
000562120630
000563120630       if (%trim(resultField)    <> *blanks) and
000564120630          (%trim(resultFieldLen) <> *blanks);
000565120630         CCODSTATS_addInLineDeclaration();
000566120630       endif;
000567120630      /end-free
000568120630     p                 e
000569120630      //_______________________________________________________________________
000570120630
000571120630     p CRPGPARUTL_checkResultingIndicators...
000572120630     p                 b                   export
000573120630     d                 pi
000574120630     d codeLine                     255a   const varying
000575120630     d columnFrom                    10i 0 const
000576120630     d columnTo                      10i 0 const
000577120630     d maxColumns                    10i 0 const
000578120630     d resultingIndicators...
000579120630     d                 s              6a   varying
000580120630
000581120630      /free
000582120630       resultingIndicators = CRPGPARUTL_lineSubst(codeLine:columnFrom
000583120630           :columnTo:maxColumns);
000584120630
000585120630       if %trim(resultingIndicators) <> *blanks;
000586120630         CCODSTATS_addResultingIndicator();
000587120630       endif;
000588120630      /end-free
000589120630     p                 e
000590120630      //_______________________________________________________________________
000591120630
000592120630     p CRPGPARUTL_checkVariableIndicators...
000593120630     p                 b                   export
000594120630     d                 pi
000595120630     d codeLine                     255a   const varying
000596120630     d columnFrom                    10i 0 const
000597120630     d columnTo                      10i 0 const
000598120630     d maxColumn                     10i 0 const
000599120630     d
000600120630     d tempString      s             50a
000601120630
000602120630      /free
000603120630       monitor;
000607120630         tempString = CRPGPARUTL_lineSubst(codeLine
000608120630            :columnFrom:columnTo:maxColumn);
000609120630
000612120630         if searchForIndicatorVariable(tempString);
000617120630           CCODSTATS_addIndicatorAsVariable();
000618120630         endif;
000650120630       on-error;
000651120630         CEXCEPTION_catchException();
000652120630         CEXCEPTION_printStackTrace();
000653120630       endmon;
000654120630      /end-free
000655120630     p                 e
000656120630      //_______________________________________________________________________
000657120630
000658120630     p searchForIndicatorVariable...
000659120630     p                 b
000660120630     d                 pi              n
000661120630     d textBlock                    255a   const varying
000662120630     d
000663120630     d regex           ds                  likeds(regex_T)
000664120630     d pattern         s            100a   inz(*blanks)
000665120630     d patternCVT      s                   like(pattern)
000666120630     d status          s               n
000667120630
000668120630      /free
000669120630       pattern = CRPGPARUTL_getIndicatorsPattern();
000670120630
000671120630       CREGEXP_convertCCSID(%addr(pattern):%addr(patternCVT)
000672120630             :0:37:%len(%trim(pattern)));
000673120630
000674120630       regex = CREGEXP_create(%trim(patternCVT));
000675120630
000676120630       if %trim(textBlock) <> *blanks and
000677120630          CREGEXP_isMatch(%trim(textBlock):regex);
000678120630         status = *on;
000679120630       else;
000680120630         status = *off;
000681120630       endif;
000682120630
000683120630       CREGEXP_destroy(regex);
000684120630
000685120630       return status;
000686120630      /end-free
000687120630     p                 e
000688120630      //_______________________________________________________________________
000689120630
000690120630     p CRPGPARUTL_getIndicatorsPattern...
000691120630     p                 b                   export
000692120630     d                 pi           100a
000693120630
000694120630      /free
000695120630       return RPGParserConfig.indicatorsPattern;
000696120630      /end-free
000697120630     p                 e
000698120630      //_______________________________________________________________________
000699120630
000700120630     p CRPGPARUTL_getConfigFile...
000701120630     p                 b                   export
000702120630     d                 pi          2000a   varying
000703120630
000704120630      /free
000705120630       return %trim(ConfXMLPath);
000706120630      /end-free
000707120630     p                 e
000708120630      //_______________________________________________________________________
