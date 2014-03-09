000100120628     /**
000101120628      * \brief CRPG3PARSR: parser an RPG III line of code
000102120628      *
000103120628      * <p>
000104120628      *  This module contains all the necesary logic to parse
000105120628      *  a line of RPG III source code
000107120628      * </p>
000108120628      *
000109120628      * \author Isaaac Ramirez Herrera
000110120628      * \date   May, 2012
000111120628      * \rev    28-06-2012 Isaac Ramirez
000112120628      */
000113120525     h nomain
000114120529     h bnddir('CMDZBNDDIR':'CEXCEPBNDD')
000115120630     h option(*srcstmt)
000116120525
000117120525      /include qtoolstxt,cmdzntypes
000118120529      /include qtoolstxt,cmdznconst
000119120629      /include qtoolstxt,crpg3parsr
000120120629      /include qtoolstxt,crpgparutl
000121120529      /include qtoolstxt,ccodstats
000122120630      /include qtoolstxt,cstringutl
000123120529      /include csystsrc/qsrctxt,cexception
000125120525
000126120529      ///////////////////////////////////////////////
000127120529      // Constant declaration
000128120529      ///////////////////////////////////////////////
000129120529
000130120529     d MAX_COLUMN      c                   const(80)
000131120525
000132120529      ///////////////////////////////////////////////
000133120529      // Variable and structures declaration
000134120529      ///////////////////////////////////////////////
000135120629
000136120629     d fSpecLayout     ds                  qualified
000137120629     d  comment                            likeds(columnPositions)
000138120629
000139120629     d eSpecLayout     ds                  qualified
000140120629     d  comment                            likeds(columnPositions)
000141120629
000142120629     d lSpecLayout     ds                  qualified
000143120629     d  comment                            likeds(columnPositions)
000144120629
000145120629     d iSpecLayout     ds                  qualified
000146120629     d  comment                            likeds(columnPositions)
000147120629
000148120629     d oSpecLayout     ds                  qualified
000149120629     d  comment                            likeds(columnPositions)
000150120629
000175120628      //CSPEC line layout
000176120525     d cSpecLayout     ds                  qualified
000177120525     d  sequenceNumber...
000178120525     d                                     likeds(columnPositions)
000179120525     d  format                             likeds(columnPositions)
000180120525     d  controlLevel                       likeds(columnPositions)
000181120531     d  conditionalIndicators...
000182120531     d                                     likeds(columnPositions)
000183120525     d  factor1                            likeds(columnPositions)
000184120525     d  operationCode                      likeds(columnPositions)
000185120525     d  factor2                            likeds(columnPositions)
000186120525     d  resultField                        likeds(columnPositions)
000187120525     d  resultFieldLength...
000188120525     d                                     likeds(columnPositions)
000189120525     d  resultFieldDecimal...
000190120525     d                                     likeds(columnPositions)
000191120525     d  resultingIndicator...
000192120525     d                                     likeds(columnPositions)
000193120525     d  comment                            likeds(columnPositions)
000194120525
000199120529      ///////////////////////////////////////////////
000200120529      // Prototype declaration
000201120529      ///////////////////////////////////////////////
000202120529
000218120529     d parseCSPEC      pr
000219120529     d  codeLine                    255a   const varying
000220120529
000240120630     d checkDeprecatedOperator...
000241120529     d                 pr
000242120529     d  codeLine                    255a   const varying
000243120529
000256120601     d checkVariableIndicators...
000257120601     d                 pr
000258120601     d codeLine                     255a   const varying
000259120601     d isFree                          n   const
000260120601
000261120525      ///////////////////////////////////////////////
000262120525      // Procedure definition
000263120525      ///////////////////////////////////////////////
000264120525
000265120525     /**
000266120525      * \brief CRPG4PARSR_createParser: create a specific parser
000267120525      *
000268120629      * <p>
000269120629      *  Creates the parser for RPG III source code lines. Reads
000270120629      *  reads the configuration from the config XML
000271120629      * </p>
000272120629      *
000273120629      * \TODO: Remove read from config file
000274120525      */
000275120525     p CRPG3PARSR_createParser...
000276120525     p                 b                   export
000297120630     d options         s           1000a
000298120630     d configFile      s           2000a   varying
000299120630     d xmlPath         s           1000a
000300120630
000301120630      /free
000302120630       monitor;
000303120630         //Read the base configuration
000304120630         CRPGPARUTL_config();
000305120630
000306120630         //Read aditional configuration
000307120630         configFile = CRPGPARUTL_getConfigFile();
000308120630         xmlPath    = 'codeMetricsConfig/rpg/rpgIII/lineLayout/cSpecLayout';
000309120630         options    = 'doc=file path=&1 &2';
000310120630         options    = CSTRINGUTL_parse(options:%trim(xmlPath):XML_INTO_CONFIG);
000311120630
000313120630         xml-into cSpecLayout %xml(configFile : options);
000315120630       on-error;
000316120630         CEXCEPTION_catchException();
000317120630         CEXCEPTION_printStackTrace();
000318120630         CEXCEPTION_throwNewException(ERROR_CREATING_PARSER:MDZN_MESSAGE_FILE);
000319120630       endmon;
000320120525      /end-free
000321120525     p                 e
000322120525      //_______________________________________________________________________
000323120525
000324120628     /**
000325120628      * \brief CRPG3PARSR_parseLine: parse an RPG III source line
000326120628      *
000327120628      * <p>
000328120628      *  This procedure parses a line of RPG III code and updates the
000329120628      *  corresponding statistics
000330120628      * </p>
000331120628      *
000332120628      * \param line of code to parse
000333120628      *
000334120628      */
000335120529     p CRPG3PARSR_parseLine...
000336120529     p                 b                   export
000337120525     d                 pi
000338120525     d codeLine                     255a   varying
000339120529     d spec            s              1a
000340120628
000341120529      /free
000342120529       CCODSTATS_addTotalLines();
000343120529
000344120629       if (CRPGPARUTL_isBlankLine(codeLine));
000345120529         CCODSTATS_addBlankLines();
000346120529       else;
000347120629         if (CRPGPARUTL_isFullCommentLine(codeLine));
000348120529           CCODSTATS_addCommentsCount();
000349120529         else;
000350120529           spec = %subst(codeLine:SPEC_COLUMN:1);
000351120529
000352120529           if spec <> *blanks;
000355120529             select;
000356120529               when spec = CSPEC;
000357120529                 parseCSPEC(codeLine);
000358120529               when spec = ESPEC;
000359120629                 CCODSTATS_addLineCount(ESPEC);
000360120529               when spec = FSPEC;
000361120629                 CCODSTATS_addLineCount(FSPEC);
000362120529               when spec = HSPEC;
000363120629                 CCODSTATS_addLineCount(HSPEC);
000364120529               when spec = ISPEC;
000365120629                 CCODSTATS_addLineCount(ISPEC);
000366120529               when spec = OSPEC;
000367120629                 CCODSTATS_addLineCount(OSPEC);
000368120529               when spec = LSPEC;
000369120629                 CCODSTATS_addLineCount(LSPEC);
000370120529               other;
000371120529                 CCODSTATS_addUnknownLines();
000372120529             endsl;
000373120529           else;
000374120629             //Unknown line type. It can be a compile time
000375120629             //array or a preprocessor directive (COPY, INCLUDE, etc)
000376120529             CCODSTATS_addUnknownLines();
000377120529           endif;
000378120529         endif;
000379120529       endif;
000380120525      /end-free
000381120525     p                 e
000382120525      //_______________________________________________________________________
000383120529
000440120529     p parseCSPEC      b
000441120529     d                 pi
000442120529     d  codeLine                    255a   const varying
000445120529
000446120529      /free
000447120629       if CRPGPARUTL_isEndLineComment(codeLine:cSpecLayout.comment.from
000448120629           :cSpecLayout.comment.to:MAX_COLUMN);
000449120629
000451120529         CCODSTATS_addCommentsCount();
000452120529       else;
000453120529         //Count the current line
000454120529         CCODSTATS_addLineCount(CSPEC);
000455120529
000459120529         //Check if the operator is deprecated
000460120630         checkDeprecatedOperator(codeLine);
000463120629
000464120531         //Check if there is any inline declaration
000465120630         CRPGPARUTL_checkInLineDeclaration(codeLine
000466120630           :cSpecLayout.resultField.from
000467120630           :cSpecLayout.resultField.to
000468120630           :cSpecLayout.resultFieldLength.from
000469120630           :cSpecLayout.resultFieldDecimal.to
000470120630           :MAX_COLUMN);
000471120630
000472120531         //Find conditional indicators
000473120630         CRPGPARUTL_checkConditionalIndicators(codeLine
000474120630           :cSpecLayout.conditionalIndicators.from
000475120630           :cSpecLayout.conditionalIndicators.to
000476120630           :MAX_COLUMN);
000477120531
000478120531         //Find resulting indicators
000479120630         CRPGPARUTL_checkResultingIndicators(codeLine
000480120630           :cSpecLayout.resultingIndicator.from
000481120630           :cSpecLayout.resultingIndicator.to
000482120630           :MAX_COLUMN);
000483120601
000484120630         //Find indicators as variables
000485120630         CRPGPARUTL_checkVariableIndicators(codeLine
000486120630            :cSpecLayout.factor1.from
000487120630            :cSpecLayout.resultField.to
000489120630            :MAX_COLUMN);
000490120630       endif;
000491120529      /end-free
000492120529     p                 e
000493120529      //_______________________________________________________________________
000494120529
000495120630     p checkDeprecatedOperator...
000496120630     p                 b
000497120630     d                 pi
000498120630     d codeLine                     255a   const varying
000499120630     d
000500120630     d operator        s           4096a
000501120630
000502120630      /free
000503120630       operator = CRPGPARUTL_lineSubst(codeLine:cSpecLayout.operationCode.from
000504120630          :cSpecLayout.operationCode.to:MAX_COLUMN);
000505120630
000506120630       if (CRPGPARUTL_CheckDeprecated(operator));
000507120630         CCODSTATS_addDeprecatedOperator(operator);
000508120630       else;
000509120630         CCODSTATS_addValidOperator();
000510120630       endif;
000511120630      /end-free
000512120630     p                 e
000513120630      //_______________________________________________________________________
000514120630
000570120630
000641120601
