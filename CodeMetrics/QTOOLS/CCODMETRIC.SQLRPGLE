000100120616     /**
000101120522      * \brief CCODMETRIC: obtain metrics from source code
000102120522      *
000103120522      * <p>
000104120522      *  This program obtains metrics from existiing source
000105120628      *  code to determine the modernization level of an
000106120628      *  existing program
000107120522      * </p>
000108120522      *
000109120522      * \author Isaaac Ramirez Herrera
000110120522      * \date   May, 2012
000111120522      * \rev    22-05-2012 Isaac Ramirez
000112120522      */
000113120514     h dftactgrp(*NO)
000114120514     h actgrp('QILE')
000115120514     h option(*srcstmt)
000116140310     h bnddir('CMDZBNDDIR')
000117120514
000118120625      /include qtoolstxt,ccodparms
000119120521      /include qtoolstxt,cwrkfilgen
000120120518      /include qtoolstxt,ccodreader
000121120623      /include qtoolstxt,ccodstats
000122120521      /include qtoolstxt,ccodanlyzr
000123120614      /include qtoolstxt,cmdznconst
000124120614      /include qtoolstxt,cqsyswrk
000125120625      /include qtoolstxt,cwrklist
000126120614      /include qtoolstxt,llist_h
000127140310      /include qtoolstxt,cexception
000129140310      /include qtoolstxt,cExcpTypes
000130140310      /include qtoolstxt,cExcpError
000131120514
000136120521      /////////////////////////////////////////////////////////////////
000137120521      // Prototype declaration
000138120521      /////////////////////////////////////////////////////////////////
000139120521
000140120518     d CCodMetric_main...
000141120518     d                 pr                  extpgm('CCODMETRIC')
000142120808     d  library                      10a   const options(*varsize)
000143120808     d  file                         10a   const options(*varsize)
000144120808     d  member                       10a   const options(*varsize)
000147120808     d  option                       20a   const options(*varsize)
000148120514
000149120614     d checkParameters...
000150120614     d                 pr
000151120614     d  library                      10a   const options(*varsize)
000152120614     d  file                         10a   const options(*varsize)
000153120614     d  member                       10a   const options(*varsize)
000156120614     d  option                       20a   const options(*varsize)
000157120614
000183120808     d processMember...
000185120625     d                 pr
000186120625     d memberInfo                          likeds(QSYSMember_Type)
000187120625
000188120623     d regenerateMetric...
000189120623     d                 pr              n
000190120623     d memberInfo                          likeds(QSYSMember_Type)
000191120623
000192120808     d displayProgramMessage...
000194120808     d                 pr
000195120808     d message                      150a   const
000196120808
000197120521      /////////////////////////////////////////////////////////////////
000198120521      // Procedure definition
000199120521      /////////////////////////////////////////////////////////////////
000200120521
000201120521     /**
000202120521      * \brief CCodMetric_main: process a source file to obtain metrics
000203120521      *
000204120521      * <p>
000205120521      *  This procedure processes a source file to obtain metrics
000206120521      *  indicating the level of modernization of the source
000207120521      * </p>
000208120521      *
000209120521      * \param name of the library of the physical source file
000210120521      * \param name of the physical file with the source member
000211120521      * \param name of the member with the source code
000212120808      * \param library of the output file with the statistics
000213120808      * \param name of the output file with the statistics
000214120614      * \param *UPDATE  = updates the statistic checking for missing elements
000215120614      *        *REPLACE = replaces the previuos statistics
000216120521      */
000217120518     d CCodMetric_main...
000218120514     d                 pi
000219120514     d  library                      10a   const options(*varsize)
000220120514     d  file                         10a   const options(*varsize)
000221120514     d  member                       10a   const options(*varsize)
000222120614     d  option                       20a   const options(*varsize)
000223120614     d
000224120625     d memberNode      ds                  likeds(QSYSMember_Type)
000225120627     d workListCount   s             10i 0
000226120627
000227120514      /free
000228120614       monitor;
000229120814         //Set SQL Options
000230120814         EXEC SQL
000231120814           SET OPTION COMMIT = *NONE;
000232120814         EXEC SQL
000233120814           SET OPTION CLOSQLCSR = *ENDMOD;
000234120814
000235120625         //Check parameter and save them in the environment
000236120808         checkParameters(library:file:member:option);
000237120625
000238120808         //Retrieve the list of member to process
000254120627         workListCount = CWRKLIST_prepareWorkList(library:file:member);
000255120808
000258120627         if workListCount > 0;
000265120627           if option = OPTION_UPDATE;
000266120627             //Find any inconsistence in the previously calculated metrics
000267120628             CWRKLIST_checkResultsConsistency(library:file:member);
000268120627           else;
000269120627             //Delete all previosly calculated metrics
000270120814             CCODSTATS_deleteAllStatistics();
000271120627           endif;
000272120627
000273120627           monitor;
000274120627             //Iterate through the list of elements to process
000275120627             dow CWRKLIST_getNextListElement(memberNode);
000276120808               processMember(memberNode);
000277120627               clear memberNode;
000278120627             enddo;
000279120627           on-error;
000280120627             CEXCEPTION_catchException();
000281120627             CEXCEPTION_printStackTrace();
000282120627           endmon;
000283120627         endif;
000284120625
000285120627         //Release associated resources
000286120627         CWRKLIST_dropWorkList();
000287120614       on-error;
000288120614         CEXCEPTION_catchException();
000289120614         CEXCEPTION_printStackTrace();
000290120829
000291120829         //Release associated resources
000292120829         CWRKLIST_dropWorkList();
000293120614       endmon;
000294120614
000295120809       displayProgramMessage('Code metrics calculation ended. +
000296120809          Check joblog for more info');
000297120809
000298120809       *inLr = *on;
000299120514       return;
000300120514      /end-free
000301120601      //______________________________________________________________________
000302120601
000303120622     /**
000304120622      * \brief checkParameters: checks the input parameters
000305120622      *
000306120622      * <p>
000307120622      *   This procedures checks the input parameters in order to validate
000308120622      *   them. If the parameters are invalid, raises a new exception
000309120622      * </p>
000310120622      *
000311120622      * \param library name
000312120622      * \param file name
000313120622      * \param member name
000314120622      * \param option of the code metric analyzer
000315120622      */
000316120614     p checkParameters...
000317120614     p                 b
000318120614     d                 pi
000319120614     d  library                      10a   const options(*varsize)
000320120614     d  file                         10a   const options(*varsize)
000321120614     d  member                       10a   const options(*varsize)
000322120614     d  option                       20a   const options(*varsize)
000323120614
000324120614      /free
000325120614       if %trim(library) = *blanks or %trim(file) = *blanks or
000326120808          %trim(member) = *blanks  or %trim(option) = *blanks;
000327120614         CEXCEPTION_throwNewException(INVALID_PARAMETERS:MDZN_MESSAGE_FILE);
000328120614       else;
000329120614         if option <> OPTION_REPLACE and option <> OPTION_UPDATE;
000330120614           CEXCEPTION_throwNewException(UNSUPPORTED_OPTION:MDZN_MESSAGE_FILE);
000331120625         else;
000332120625           //All parameters are ok, save them
000333120625           CCODPARMS_setLibrary(library);
000334120625           CCODPARMS_setFile(file);
000335120625           CCODPARMS_setMember(member);
000336120625           CCODPARMS_setOption(option);
000337120625         endif;
000338120614       endif;
000339120614      /end-free
000340120614     p                 e
000341120614      //______________________________________________________________________
000342120614
000434120628     /**
000435120628      * \brief: processMember executes the metrics process for a member
000436120628      *
000437120628      * <p>
000438120628      *  This procedure executes the metrics calculation process of a member.
000439120628      *  Assumes that the relevant data of the member was previously
000440120628      *  retrieved
000441120628      * </p>
000442120628      *
000443120628      * \param QSYSMember_type structure cotaining the member data
000445120628      */
000446120808     p processMember...
000447120625     p                 b
000448120625     d                 pi
000449120625     d memberInfo                          likeds(QSYSMember_Type)
000450120628     d
000451120628     d lineReaded      s            255a
000452120628
000453120625      /free
000454120628       //Check if the metrics exists and are valid
000455120625       if regenerateMetric(memberInfo);
000456120628         monitor;
000457120628           //Prepare the configuration required
000459120628           CCODANLYZR_config(memberNode.memberType);
000460120628
000461120829           //Save the last modification datetime of the member
000462120829           CCODSTATS_setLastModificationDate(memberInfo.changeDateTime);
000463120829           CCODSTATS_setMemberCreationDate(memberInfo.creationDate);
000464120829
000465120628           //Creates a temporary file from the member to analyze
000466120628           CWRKFILGEN_createWorkFile(memberNode.library:memberNode.fileName
000467120628              :memberNode.memberName);
000468120628
000469120628           CCODREADER_beginReading();
000470120628
000471120628           monitor;
000472120628             dow CCODREADER_readNextLine(lineReaded);
000473120628               CCODANLYZR_parseLine(lineReaded);
000474120628             enddo;
000475120628           on-error;
000476120808             CEXCEPTION_catchException();
000477120628             CEXCEPTION_printStackTrace();
000478120628           endmon;
000479120628
000480120628           CCODREADER_endReading();
000481120628
000482120628           //Clean up the temporary files
000483120813           CWRKFILGEN_deleteWorkFile(WORK_LIB:WORK_FILE);
000484120628
000485120628           //Write the generated statistics
000486120628           CCODSTATS_writeStatistics(memberInfo.memberName
000487120628              :memberInfo.fileName:memberInfo.library:memberInfo.memberType);
000488120628
000489120813           //Dispose resources
000490120813           CCODANLYZR_clearAnalysis();
000491120628         on-error;
000492120628           CEXCEPTION_catchException();
000493120628           CEXCEPTION_printStackTrace();
000494120628         endmon;
000495120625       else;
000496120625         CEXCEPTION_jobPrintf('WARNING: Previous Metrics for Member %s/%s,%s ' +
000497120628             'mantained':%trim(library):%trim(file):%trim(member));
000498120625       endif;
000499120625      /end-free
000500120625     p                 e
000501120625      //______________________________________________________________________
000502120625
000503120628     /**
000504120628      * \brief regenerateMetric determines if the metrics must be re-generated
000505120628      *
000506120628      * <p>
000507120628      *  This procedure determines if a metrics must be re-gerenerated for
000508120628      *  a member. The metric will always be regenerated if the option *REPLACE
000509120628      *  was specified. If the option *UPDATE was specified, the metric will
000510120628      *  be regenerated if the date and time of the last change on the member
000511120628      *  if higher than the date and time of the previosly generated metric
000512120628      *  for that member
000513120628      * </p>
000514120628      *
000515120628      * \param Structute of type QSYSMember_Type with the member data
000516120628      */
000517120623     p regenerateMetric...
000518120623     p                 b
000519120623     d                 pi              n
000520120623     d memberInfo                          likeds(QSYSMember_Type)
000521120623     d
000522120623     d generationDateTime...
000523120623     d                 s               z
000524120623
000525120623      /free
000526120623       //If replace, always re-calculate the metrics
000527120625       if CCODPARMS_getOption() = OPTION_REPLACE;
000528120623         return *on;
000529120623       else;
000530120623         if CCODSTATS_getMetricGenerationDateTime(memberInfo.library
000531120623            :memberInfo.fileName:memberInfo.memberName:generationDateTime);
000532120623
000533120623           //If member was change after the last metric calculation
000534120623           if memberInfo.changeDateTime > generationDateTime;
000535120623             return *on;
000536120623           else;
000537120623             return *off;
000538120623           endif;
000539120623         else;
000540120623           //Previously calculated metric not found
000541120623           return *on;
000542120623         endif;
000543120623       endif;
000544120623
000545120623      /end-free
000546120623     p                 e
000547120623      //______________________________________________________________________
000548120808
000549120809     /**
000550120809      * \brief displayProgramMessage send a message to the user
000551120809      *
000552120809      * <p>
000553120809      *  This procedure sends a message to the bottom of the user main screen
000554120809      *  (console/session)
000555120809      * </p>
000556120809      *
000557120809      * \param message to display
000558120809      */
000559120808     p displayProgramMessage...
000560120808     p                 b
000561120808     d                 pi
000562120808     d message                      150a   const
000563120808     d
000564120808     d errorApi        ds                  likeds(errorDS_Type)
000565120808     d msgKey          s              4a
000566120808
000567120808      /free
000568120809       monitor;
000569120809         errorApi.bytesProv = 0;
000570120809
000571120809         SendProgramMessage('CPF9898':'QCPFMSG   *LIBL     '
000572120809            :message:%len(%trimr(message)):'*COMP':'*PGMBDY'
000573120809            :3:MsgKey:errorApi);
000574120809       on-error;
000575120809         CEXCEPTION_catchException();
000576120809         CEXCEPTION_printException();
000577120809       endmon;
000578120808      /end-free
000579120808     p                 e
000580120808      //_______________________________________________________________________
000581120808
000582120623
