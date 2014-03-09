000101120629     /**
000102120629      * \brief CRPG4PARSR: parser an RPG IV line of code
000103120629      *
000104120629      * <p>
000105120629      *  This module contains all the necesary logic to parse
000106120629      *  a line of RPG IV source code
000107120629      * </p>
000108120629      *
000109120629      * \author Isaaac Ramirez Herrera
000110120629      * \date   June, 2012
000111120629      * \rev    29-06-2012 Isaac Ramirez
000112120629      */
000113120528     h nomain
000114120529     h bnddir('CEXCEPBNDD':'CMDZBNDDIR')
000115120630     h option(*srcstmt)
000116120525
000117120525      /include qtoolstxt,cmdzntypes
000118120525      /include qtoolstxt,crpg4parsr
000119120629      /include qtoolstxt,crpgparutl
000120120528      /include qtoolstxt,ccodstats
000121120528      /include qtoolstxt,cmdznconst
000122120630      /include qtoolstxt,cstringutl
000123120630      /include csystsrc/qsrctxt,cexception
000124120630      /include qhashtxt,lmap_h
000125120525
000126120629      ///////////////////////////////////////////////
000127120629      // Constant declaration
000128120629      ///////////////////////////////////////////////
000129120629
000130120629     d MAX_COLUMN      c                   const(80)
000140120630     d FREE_BEGIN      c                   const(7)
000141120629
000142120629      ///////////////////////////////////////////////
000143120629      // Variable and structures declaration
000144120629      ///////////////////////////////////////////////
000145120629
000146120630     d extendedFactor2Operators...
000147120630     d                 s               *   inz(*NULL)
000148120630
000151120630     d insideFree      s               n   inz(*OFF)
000152120630
000164120629      //CSPEC layout in RPG IV
000165120629     d cSpecLayout     ds                  qualified
000166120629     d  sequenceNumber...
000167120629     d                                     likeds(columnPositions)
000168120629     d  format                             likeds(columnPositions)
000169120629     d  controlLevel                       likeds(columnPositions)
000170120629     d  conditionalIndicators...
000171120629     d                                     likeds(columnPositions)
000172120629     d  factor1                            likeds(columnPositions)
000173120629     d  operationCode                      likeds(columnPositions)
000174120629     d  factor2                            likeds(columnPositions)
000175120629     d  extendedFactor2...
000176120629     d                                     likeds(columnPositions)
000177120629     d  resultField                        likeds(columnPositions)
000178120629     d  resultFieldLength...
000179120629     d                                     likeds(columnPositions)
000180120629     d  resultFieldDecimal...
000181120629     d                                     likeds(columnPositions)
000182120629     d  resultingIndicator...
000183120629     d                                     likeds(columnPositions)
000184120630     d  comment                            likeds(columnPositions)
000185120629
000186120629      //////////////////////////////////////////////
000187120629      // Prototype declaration
000188120629      //////////////////////////////////////////////
000189120629
000190120630     d parseColumnar   pr
000192120630     d spec                           1a   value
000193120630     d codeLine                     255a   const varying
000194120630
000195120630     d parseFREE       pr
000197120630     d codeLine                     255a   const varying
000198120630
000199120528     d parseCSPEC      pr
000200120528     d  codeLine                    255a   const varying
000201120528
000202120630     d checkDeprecatedOperator...
000203120630     d                 pr
000204120630     d  codeLine                    255a   const varying
000205120630
000206120630     d isExtendedFactor2...
000207120630     d                 pr              n
000208120630     d codeLine                     255a   const varying
000209120630
000210120630     d populateExtendedFactor2...
000211120630     d                 pr            10i 0
000212120630     d communication                 10a
000213120630     d element                       50a   dim(1) const
000214120630     d elementCount                  10i 0 value
000215120630
000216120525      ///////////////////////////////////////////////
000217120525      // Procedure definition
000218120525      ///////////////////////////////////////////////
000219120525
000220120525     /**
000221120525      * \brief CRPG4PARSR_createParser: create a specific parser
000222120525      *
000223120525      * <p>
000224120629      *  Creates the parser for RPG IV source code lines. Reads
000225120629      *  reads the configuration from the config XML
000226120525      * </p>
000227120629      *
000228120629      * \TODO: Remove read from config file
000229120525      */
000230120525     p CRPG4PARSR_createParser...
000231120525     p                 b                   export
000232120630     d
000233120630     d options         s           1000a
000234120630     d configFile      s           2000a   varying
000235120630     d xmlPath         s           1000a
000236120630     d communication   s             10a
000237120630
000238120525      /free
000239120630       monitor;
000240120630         //Read the base configuration
000241120630         CRPGPARUTL_config();
000242120630
000243120630         //Read aditional configuration
000244120630         configFile = CRPGPARUTL_getConfigFile();
000245120630         xmlPath    = 'codeMetricsConfig/rpg/rpgIV/lineLayout/cSpecLayout';
000246120630         options    = 'doc=file path=&1 &2';
000247120630         options    = CSTRINGUTL_parse(options:%trim(xmlPath):XML_INTO_CONFIG);
000248120630
000249120630         xml-into cSpecLayout %xml(configFile : options);
000250120630
000251120630         //Create the extendedfactor2 operators index
000252120630         extendedFactor2Operators = lmap_create();
000253120630
000254120630         options    = 'doc=file path=&1 &2';
000255120630         xmlPath    = 'codeMetricsConfig/rpg/rpgIV/extendedFactor2Operators/'
000256120630                    + 'operator';
000257120630         options    = CSTRINGUTL_parse(options:%trim(xmlPath):XML_INTO_CONFIG);
000258120630         xml-into %handler(populateExtendedFactor2 : communication)
000259120630                  %xml(configFile:options);
000260120630       on-error;
000261120630         CEXCEPTION_catchException();
000262120630         CEXCEPTION_printStackTrace();
000263120630         CEXCEPTION_throwNewException(ERROR_CREATING_PARSER:MDZN_MESSAGE_FILE);
000264120630       endmon;
000265120525      /end-free
000266120525     p                 e
000267120525      //_______________________________________________________________________
000268120525
000269120630     p populateExtendedFactor2...
000270120630     p                 b
000271120630     d                 pi            10i 0
000272120630     d communication                 10a
000273120630     d element                       50a   dim(1) const
000274120630     d elementCount                  10i 0 value
000275120630     d key             s            255a   varying
000276120630     d value           s             50a
000277120630
000278120630      /free
000279120630       key   = CRPGPARUTL_toUpper(%trim(element(1)));
000280120630       value = element(1);
000281120630
000284120809       lmap_add(extendedFactor2Operators:%addr(key):%len(%trim(key))
000285120809               :%addr(value):%len(%trim(value)));
000286120630
000287120630       return 0;
000288120630      /end-free
000289120630     p                 e
000290120630      //_______________________________________________________________________
000291120630
000292120525     p CRPG4PARSR_parseLine...
000293120525     p                 b                   export
000294120525     d                 pi
000295120525     d codeLine                     255a   varying
000296120528     d spec            s              1a
000297120630     d tempString      s            255a   varying
000298120630     d firstToken      s            255a   varying
000299120630
000300120525      /free
000301120528       CCODSTATS_addTotalLines();
000302120528
000303120629       if (CRPGPARUTL_isBlankLine(codeLine));
000304120528         CCODSTATS_addBlankLines();
000305120528       else;
000306120629         if (CRPGPARUTL_isFullCommentLine(codeLine));
000307120528           CCODSTATS_addCommentsCount();
000308120528         else;
000309120528           spec = %subst(codeLine:SPEC_COLUMN:1);
000310120630
000311120630           if spec <> *blanks;
000312120630             parseColumnar(spec:codeLine);
000313120630             insideFree = *OFF;
000314120630           else;
000315120630             tempString = %subst(codeLine:FREE_BEGIN);
000316120630             tempString = %triml(tempString);
000317120630             tempString = CRPGPARUTL_toUpper(tempString);
000318120630             firstToken = %subst(tempString:1:%scan(' ':tempString));
000319120630             firstToken = %trim(firstToken);
000320120630
000321120630             select;
000322120630               when firstToken = '/FREE';
000323120630                 CCODSTATS_addLineCount(FREE_LINE);
000324120630                 insideFree = *ON;
000325120630
000326120630               when firstToken = '/END-FREE';
000327120630                 CCODSTATS_addLineCount(FREE_LINE);
000328120630                 insideFree = *OFF;
000329120630               other;
000330120630                 if insideFree;
000331120630                   parseFREE(codeLine);
000332120630                 else;
000333120630                   CCODSTATS_addUnknownLines();
000335120630                 endif;
000336120630             endsl;
000337120630           endif;
000370120528         endif;
000371120528       endif;
000372120525      /end-free
000373120525     p                 e
000374120525      //_______________________________________________________________________
000375120528
000376120630     p parseColumnar   b
000377120630     d                 pi
000378120630     d spec                           1a   value
000379120630     d codeLine                     255a   const varying
000381120630
000382120630      /free
000385120630       select;
000386120809         when spec = HSPEC;
000387120630           CCODSTATS_addLineCount(HSPEC);
000388120630         when spec = FSPEC;
000389120630           CCODSTATS_addLineCount(FSPEC);
000390120630         when spec = DSPEC;
000391120630           CCODSTATS_addLineCount(DSPEC);
000392120630         when spec = ISPEC;
000393120630           CCODSTATS_addLineCount(ISPEC);
000394120630         when spec = CSPEC;
000395120630           parseCSPEC(codeLine);
000396120630         when spec = OSPEC;
000397120630           CCODSTATS_addLineCount(OSPEC);
000398120630         when spec = PSPEC;
000399120630           CCODSTATS_addLineCount(PSPEC);
000400120630         other;
000401120814           CCODSTATS_addUnknownLines();
000403120630       endsl;
000404120630      /end-free
000405120630     p                 e
000406120630      //_______________________________________________________________________
000407120630
000408120630     p parseFREE       b
000409120630     d                 pi
000410120630     d codeLine                     255a   const varying
000411120630
000412120630      /free
000413120630       //Counts the current line
000414120630       CCODSTATS_addLineCount(FREE_LINE);
000415120630
000416120630       //Check indicator as variable
000417120630       CRPGPARUTL_checkVariableIndicators(codeLine
000418120630          :FREE_BEGIN:MAX_COLUMN:MAX_COLUMN);
000419120630      /end-free
000420120630     p                 e
000421120630      //_______________________________________________________________________
000422120630
000423120630     /**
000424120630      * \brief parseCSPEC: parses a CSPEC line
000425120630      *
000426120630      * <p>
000427120630      *  This procedure parses a CSPEC line of code
000428120630      * </p>
000429120630      *
000430120630      * \param line of code to parse
000431120630      */
000432120528     p parseCSPEC      b
000433120528     d                 pi
000434120528     d  codeLine                    255a   const varying
000435120528
000436120528      /free
000437120629       //Counts the current line
000438120528       CCODSTATS_addLineCount(CSPEC);
000439120629
000440120629       //Check if the operator is deprecated
000441120630       checkDeprecatedOperator(codeLine);
000442120630
000443120630       //Check if theres a conditional indicator set
000444120630       CRPGPARUTL_checkConditionalIndicators(codeLine
000445120630           :cSpecLayout.conditionalIndicators.from
000446120630           :cSpecLayout.conditionalIndicators.to
000447120630           :MAX_COLUMN);
000448120630
000449120630       if (isExtendedFactor2(codeLine));
000450120630         //Check indicator as variable
000451120630         CRPGPARUTL_checkVariableIndicators(codeLine
000452120630            :cSpecLayout.extendedFactor2.from
000453120630            :cSpecLayout.extendedFactor2.to
000454120630            :MAX_COLUMN);
000456120630       else;
000457120630         //Check resulting indicator
000458120630         CRPGPARUTL_checkResultingIndicators(codeLine
000459120630           :cSpecLayout.resultingIndicator.from
000460120630           :cSpecLayout.resultingIndicator.to
000461120630           :MAX_COLUMN);
000462120630
000463120630         //Check indicator as variable
000464120630         CRPGPARUTL_checkVariableIndicators(codeLine
000465120630            :cSpecLayout.factor1.from
000466120630            :cSpecLayout.resultField.to
000467120630            :MAX_COLUMN);
000468120630
000469120630         //Check if there is any inline declaration
000470120630         CRPGPARUTL_checkInLineDeclaration(codeLine
000471120630           :cSpecLayout.resultField.from
000472120630           :cSpecLayout.resultField.to
000473120630           :cSpecLayout.resultFieldLength.from
000474120630           :cSpecLayout.resultFieldDecimal.to
000475120630           :MAX_COLUMN);
000476120630       endif;
000477120528      /end-free
000478120528
000479120528     p                 e
000480120528      //_______________________________________________________________________
000481120528
000482120630     p checkDeprecatedOperator...
000483120630     p                 b
000484120630     d                 pi
000485120630     d codeLine                     255a   const varying
000486120630     d
000487120630     d operator        s           4096a
000488120630
000489120630      /free
000490120630       operator = CRPGPARUTL_lineSubst(codeLine:cSpecLayout.operationCode.from
000491120630          :cSpecLayout.operationCode.to:MAX_COLUMN);
000492120630
000493120630       if (CRPGPARUTL_CheckDeprecated(operator));
000494120630         CCODSTATS_addDeprecatedOperator(operator);
000495120630       else;
000496120630         CCODSTATS_addValidOperator();
000497120630       endif;
000498120630      /end-free
000499120630     p                 e
000500120630      //_______________________________________________________________________
000501120630
000502120630     p isExtendedFactor2...
000503120630     p                 b
000504120630     d                 pi              n
000505120630     d codeLine                     255a   const varying
000506120630     d
000507120630     d index           s             10i 0
000508120809     d tempOperator    s            255a   varying
000511120809
000512120809      /free
000516120630       tempOperator = CRPGPARUTL_lineSubst(codeLine
000517120630          :cSpecLayout.operationCode.from
000518120630          :cSpecLayout.operationCode.to
000519120630          :MAX_COLUMN);
000520120630
000521120630       tempOperator = CRPGPARUTL_toUpper(%trim(tempOperator));
000522120809
000523120809       //if the operator in a CSpec code line is blank, its a
000524120809       //extended factor 2 continuation line.
000526120809       if %trim(tempOperator) = *blanks;
000527120809         return *on;
000528120809       else;
000529120809         //Check if the operator is in the extendedfactor2 list
000532120809         if lmap_containsKey(extendedFactor2Operators:%addr(tempOperator)
000533120809                :%len(%trim(tempOperator)));
000534120809           return *on;
000535120809         else;
000536120809           return *off;
000537120809         endif;
000538120809       endif;
000539120630
000540120630       return *off;
000541120630      /end-free
000542120630     p                 e
000543120630      //_______________________________________________________________________
