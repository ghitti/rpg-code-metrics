000100120514     /**
000101120521      * \brief CWRKFILGEN: Work file generator
000102120514      *
000103120514      * <p>
000104120514      *  This class contains all the funcionality needed to
000105120514      *  generate work files in the QTEMP library in order to
000106120514      *  apply aditional code analysis
000107120514      * </p>
000108120514      *
000109120514      * \author Isaaac Ramirez Herrera
000110120514      * \date   May, 2012
000112120514      * \rev    14-05-2012 Isaac Ramirez
000113120514      */
000114120514
000115120510     h nomain
000116140310     h bnddir('CMDZBNDDIR')
000117120510
000118120628      /include qtoolstxt,cstringutl
000119120521      /include qtoolstxt,cwrkfilgen
000120120521      /include qtoolstxt,cmdznconst
000121140310      /include qtoolstxt,cexception
000122120510
000123120514      /////////////////////////////////////////////////////////////////////////
000124120514      // Prototype definition
000125120514      /////////////////////////////////////////////////////////////////////////
000126120514
000127120510     d executeCommand...
000128120510     d                 pr              n
000129120510     d command                      500a   const varying
000130120510
000144120514      /////////////////////////////////////////////////////////////////////////
000145120514      // Procedure definition
000146120514      /////////////////////////////////////////////////////////////////////////
000147120514
000148120510     /**
000149120521      * \brief CWRKFILGEN_createWorkFile: creates a work file in QTEMP
000151120510      *
000152120510      * <p>
000153120510      *  This procedures creates a file in QTEMP based on an specific member.
000154120511      *  The created work file is named with the indicated destination and
000155120511      *  with a member of the same name. This allows to access a source member
000156120510      *  trough SQL without needing to create an alias
000157120510      * </p>
000158120510      *
000159120510      * \param name of the library containing the file and member
000160120510      * \param name of the source file
000161120510      * \param name of the member to copy to the work file
000165120510      */
000166120521     p CWRKFILGEN_createWorkFile...
000167120514     p                 b                   export
000168120514     d                 pi
000169120510     d sourceLibrary                 10a   const varying
000170120510     d sourceFile                    10a   const varying
000171120511     d sourceMember                  10a   const varying
000174120511     d
000175120511     d command         s           4096a   varying
000176120625     d workLib         s             10a   varying
000177120625     d workFile        s             10a   varying
000178120625     d workMember      s             10a   varying
000179120625
000180120510      /free
000181120510       monitor;
000182120813         workLib    = WORK_LIB;
000183120813         workFile   = WORK_FILE;
000184120813         workMember = WORK_FILE;
000185120625
000186120510         //Check parameters
000187120510         if %trim(sourceLibrary) = *blanks or
000188120510            %trim(sourceFile)    = *blanks or
000189120510            %trim(sourceMember)  = *blanks;
000190120514           CEXCEPTION_throwNewException(INVALID_PARAMETERS:MDZN_MESSAGE_FILE);
000191120510         endif;
000192120510
000193120514         //Try to remove the work file to ensure is clear
000194120626         CWRKFILGEN_deleteWorkFile(workLib:workFile);
000195120514
000196120514         //Create work file
000197120628         if executeCommand(CSTRINGUTL_parse('CRTSRCPF FILE(&1/&2)'
000198120628             :%trim(workLib):%trim(workFile)));
000199120625           //Create the member
000200120628           if not executeCommand(CSTRINGUTL_parse('ADDPFM FILE(&1/&2) MBR(&2)'
000201120625               :%trim(workLib):%trim(workFile)));
000202120625             CEXCEPTION_throwNewException(COULD_NOT_CREATE_MEMBER
000203120514                                         :MDZN_MESSAGE_FILE);
000204120514           endif;
000205120514
000206120514           //Copy the original member to the workFile
000207120719           if not executeCommand(CSTRINGUTL_parse('CPYSRCF FROMFILE(&1/&2) '+
000208120719                                'TOFILE(&3/&4) ' +
000209120719                                'FROMMBR(&5) ' +
000210120514                                'TOMBR(QINPUTSRC)'
000211120719                               : %trim(sourceLibrary)
000212120625                               : %trim(sourceFile)
000213120625                               : %trim(workLib)
000214120625                               : %trim(workFile)
000215120625                               : %trim(sourceMember)));
000216120514             CEXCEPTION_throwNewException(COULD_NOT_COPY_TO_WORKFILE
000217120514                                         :MDZN_MESSAGE_FILE);
000218120514           endif;
000219120514         else;
000220120514           CEXCEPTION_throwNewException(COULD_NOT_CREATE_WORK_FILE
000221120514                                       :MDZN_MESSAGE_FILE);
000222120514         endif;
000223120510       on-error;
000224120510         CEXCEPTION_catchException();
000225120510         CEXCEPTION_printStackTrace();
000226120510       endmon;
000227120510      /end-free
000228120510     p                 e
000229120510      //_______________________________________________________________________
000230120510
000231120521     /**
000232120521      * \brief CWRKFILGEN_deleteWorkFile: delete the work file in QTEMP
000233120521      *
000234120521      * <p>
000235120521      *  This procedures deletes the work file previously created in QTEMP
000236120521      * </p>
000237120628      *
000238120628      * \param library of the work file
000239120628      * \param name of the work file
000240120521      */
000241120521     p CWRKFILGEN_deleteWorkFile...
000242120521     p                 b                   export
000243120625     d                 pi
000244120625     d library                       10a   const varying
000245120625     d file                          10a   const varying
000246120625     d tempQualifiedName...
000247120625     d                 s             21a   varying
000248120625
000249120521      /free
000250120625       tempQualifiedName = %trim(library) + '/' + %trim(file);
000251120625
000252120625       if not executeCommand('DLTF FILE(' + tempQualifiedName + ')');
000253120625         CEXCEPTION_jobPrintf('Leve - No se pudo eliminar el archivo ' +
000254120625          tempQualifiedName);
000255120521       endif;
000256120521      /end-free
000257120521
000258120521     p                 e
000259120521      //_______________________________________________________________________
000260120521
000333120510     p executeCommand...
000334120510     p                 b
000335120510     d                 pi              n
000336120510     d command                      500a   const varying
000337120510     d
000338120510     d QCMDEXC         pr                  extpgm('QCMDEXC')
000339120510     d  command                     500a   const
000340120510     d  length                       15p 5 const
000341120510
000342120510
000343120510      /free
000344120510       monitor;
000345120510         QCMDEXC(%trim(command):%len(%trim(command)));
000346120510         return *on;
000347120510
000348120510       on-error;
000349120510         CEXCEPTION_catchException();
000350120510         CEXCEPTION_printStackTrace();
000351120510         return *off;
000352120510       endmon;
000353120510      /end-free
000354120510     p                 e
000355120510      //________________________________________________________________________
000356120511
