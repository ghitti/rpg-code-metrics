000100120521     /**
000101120521      * \brief CCODANLYZR: source code analizer
000102120521      *
000103120521      * <p>
000104120521      *  This class contains procedures to analyze source code
000106120521      * </p>
000107120521      *
000108120521      * \author Isaaac Ramirez Herrera
000109120521      * \date   May, 2012
000110120521      * \rev    21-05-2012 Isaac Ramirez
000111120521      */
000113120518     h nomain
000114140310     h bnddir('CMDZBNDDIR')
000115120607     h option(*srcstmt)
000116120521
000117140310      /include qtoolstxt,cexception
000118120521      /include qtoolstxt,cmdznconst
000119120521      /include qtoolstxt,ccodanlyzr
000120120528      /include qtoolstxt,ccodstats
000121120528      /include qtoolstxt,cparsefact
000124120518
000215120521      /////////////////////////////////////////////////////
000216120521      // Prototype declaration
000217120521      /////////////////////////////////////////////////////
000218120521
000256120528     d lineParserPtr   s               *   procptr
000259120528     d lineParser      pr                  extProc(lineParserPtr)
000260120528     d  codeLine                    255a   const varying
000261120525
000270120521      /////////////////////////////////////////////////////
000271120521      // Procedure definition
000272120521      /////////////////////////////////////////////////////
000273120521
000274120522     /**
000275120522      * \brief: CCODANLYZR_clearAnalysis clears the source statistics
000276120522      *
000277120522      * <p>
000278120522      *  This procedure clears all the souce code analysis statistics
000279120522      * </p>
000280120522      */
000281120522     p CCODANLYZR_clearAnalysis...
000282120523     p                 b                   export
000283120522
000284120522      /free
000285120528       CCODSTATS_clear();
000286120522      /end-free
000287120522     p                 e
000288120522      //_______________________________________________________________________
000289120523
000290120523     /**
000291120628      * \brief CCODANLYZR_config: configure the code analyzer
000292120523      *
000293120523      * <p>
000294120628      *  This procedure configures the code analyzer. Sets the
000295120628      *  line parser according to the source type
000296120523      * </p>
000297120523      *
000299120628      * \param type of the member to analyze
000300120523      */
000301120523     p CCODANLYZR_config...
000302120524     p                 b                   export
000303120523     d                 pi
000304120523     d memberType                    10a   varying const
000305120525     d
000306120523      /free
000307120523       monitor;
000308120628         //Create the corresponding parser
000309120525         lineParserPtr = CPARSEFACT_getParser(memberType);
000313120525       on-error;
000314120523         CEXCEPTION_catchException();
000315120523         CEXCEPTION_printStackTrace();
000316120523         CEXCEPTION_throwNewException(COULD_NOT_CONFIG_ANALIZER
000317120523                                     :MDZN_MESSAGE_FILE);
000318120523       endmon;
000319120523      /end-free
000320120523     p                 e
000321120523      //_______________________________________________________________________
000322120523
000323120522     /**
000324120522      * \brief: CCODANLYZR_parseLine: parse a line of source code
000325120522      *
000326120522      * <p>
000327120522      *  This procedure parses a line of code for further analysis
000328120522      * </p>
000329120522      *
000330120522      * \param string containing a line of source code
000331120522      */
000332120521     p CCODANLYZR_parseLine...
000333120521     p                 b                   export
000334120521     d                 pi
000335120521     d codeLine                     255a   const varying
000336120521
000339120521      /free
000340120528       if lineParserPtr <> *null;
000341120528         lineParser(codeLine);
000342120528       else;
000343120528         CEXCEPTION_throwNewException(ANALIZER_NOT_SET:MDZN_MESSAGE_FILE);
000345120528       endif;
000384120521      /end-free
000386120521     p                 e
000387120521      //_______________________________________________________________________
000388120521
