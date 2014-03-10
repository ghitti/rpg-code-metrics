000001100913      //-----------------------------------------------------------------------//
000002100913      //                                                                       //
000003100913      // Modulo:      CException                                               //
000004100913      // Descripcion: Contiene los procedimientos requeridos para el manejo    //
000005100913      //              de excepciones                                           //
000006100913      //_______________________________________________________________________//
000007100913      //                                                                       //
000008100913      // Autor:  Ing. Isaac Ramirez Herrera                                    //
000009100913      // Fecha:  03 de noviembre 2009                                          //
000010100913      // Ultima modificación: 11 de septiembre de 2010                         //
000011100913      //                                                                       //
000012100913      //-----------------------------------------------------------------------//
000013100913
000014100913     h copyright('BAC Credomatic Network GE')
000015100913     h nomain
000016100913     h bnddir('QC2LE')
000017100913     h option(*srcstmt)
000018100913
000019140310      /include qtoolstxt,cException
000020140310      /include qtoolstxt,cExcpTypes
000021140310      /include qtoolstxt,cExcpError
000022100913
000023100913      //-----------------------------------------------------------------------
000024100913      // Constantes
000025100913      //-----------------------------------------------------------------------
000026100913
000027100913     d FORMAT_NAME     c                   const('RCVM0300')
000028100913     d RECEIVE_ACTION  c                   const('*OLD')
000029100913     d WAIT_TIME       c                   const(0)
000030100913     d MESSAGE_TYPE    c                   const('*PRV')
000031100913     d MESSAGE_TYPE_ESCAPE...
000032100913     d                 c                   const('*ESCAPE')
000033100913     d CALL_STACK_COUNTER_THROW...
000034100913     d                 c                   const(2)
000035100913     d CALL_STACK_COUNTER...
000036100913     d                 c                   const(1)
000037100913     d CALL_STACK_ENTRY...
000038100913     d                 c                   const('*')
000039100913     d DEFAULT_MESSAGE_ID...
000040100913     d                 c                   const('CPF9898')
000041100913     d DEFAULT_MESSAGE_FILE...
000042100913     d                 c                   const('QCPFMSG   ')
000043100913     d CALL_STACK_INFO_FORMAT...
000044100913     d                 c                   const('CSTK0100')
000045100913     d JOB_INFO_FORMAT...
000046100913     d                 c                   const('JIDF0100')
000047100913     d NOT_FOUND       c                   const('NOT_AVAIL')
000048100913     d IGNORE_ENTRIES...
000049100913     d                 c                   const(2)
000050100913     d IGNORE_ENTRIES_NOT_THROWN...
000051100913     d                 c                   const(3)
000052100913     d THROW_PROCEDURE_NAME...
000053100913     d                 c                   const('CEXCEPTION_THROWNEWEXCEPTION')
000054100913
000055100913      //-----------------------------------------------------------------------
000056100913      // Variables Globales
000057100913      //-----------------------------------------------------------------------
000058100913
000059100913      //@@field:
000060100913      //@name: psDs
000061100913      //@objective: Program Status Data Structure
000062100913      //@@
000063100913     d psds           sds                  qualified
000064100913     d  job_name             244    253
000065100913     d  job_user             254    263
000066100913     d  job_num              264    269s 0
000067100913
000068100913      //@@field:
000069100913      //@name: exception
000070100913      //@objective: estructura en la que se almacenan las excepciones generadas
000071100913      //@@
000072100913     d exception       ds                  likeds(exception_type) inz
000073100913
000074100913      //@@field:
000075100913      //@name: stackEntryArray
000076100913      //@objective: arreglo de entradas de la pila de llamadas
000077100913      //@@
000078100913     d stackEntryArray...
000079100913     d                 ds                  dim(ENTRY_ARRAY_SIZE)
000080100913     d                                     likeds(callStackEntry_type)
000081100913     d stackEntryArrayCount...
000082100913     d                 s             10i 0 inz(0)
000083100913
000084100913      //-----------------------------------------------------------------------
000085100913      // Prototipos de procedimientos no exportados
000086100913      //-----------------------------------------------------------------------
000087100913
000088100913      //@@method:
000089100913      //@name: CEXCEPTION_saveCallStack
000090100913      //@description: salva la pila de llamadas en un arreglo
000091100913      //@paramin: skipEntries indica cuantas entradas de la pila deben
000092100913      //                      ignorarse al inicio
000093100913      //@return: retorna *OFF en caso de error
000094100913      //@@
000095100913     d CEXCEPTION_saveCallStack...
000096100913     d                 pr              n
000097100913     d skipEntries                   10i 0 options(*nopass) value
000098100913
000099100913      //@@method:
000100100913      //@name: CEXCEPTION_saveThrowInfo
000101100913      //@description: salva informacion de la excepcion, disponible en el
000102100913      //              momento en el que se realiza el throw de la excepcion
000103100913      //@@
000104100913     d CEXCEPTION_saveThrowInfo...
000105100913     d                 pr
000106100913
000107100913      //@@method:
000108100913      //@name: CEXCEPTION_printStackHeader
000109100913      //@description: escribe el en joblog, el encabezado de la impresion
000110100913      //              de la pila de llamadas
000111100913      //@paramin: messageId     identificador de la excepcion producida
000112100913      //@paramin: messageText   descripcion de la excepcion producida
000113100913      //@paramin: callStackSize profundidad de la pila de llamadas
000114100913      //@@
000115100913     d CEXCEPTION_printStackHeader...
000116100913     d                 pr
000117100913     d messageId                           like(exception_type.messageId)
000118100913     d                                     const
000119100913     d messageText                         like(exception_type.messageText)
000120100913     d                                     const
000121100913     d callStackSize                 10i 0 const
000122100913
000123100913      //@@method:
000124100913      //@name: CEXCEPTION_printStackEntry
000125100913      //@description: despliega una entrada de la pila de llamadas
000126100913      //@@
000127100913     d CEXCEPTION_printStackEntry...
000128100913     d                 pr
000129100913     d  programName                  21a   varying const
000130100913     d  moduleName                   21a   varying const
000131100913     d  procedureName               255a   varying const
000132100913     d  line                         30a   varying const
000133100913
000134100913      //@@method:
000135100913      //@name: CEXCEPTION_saveSenderInfo
000136100913      //@description: salva informacion de la excepcion, obtenida al
000137100913      //              recuperar el program message. Este procedimiento
000138100913      //              se utiliza cuando se envia una excepcion  sin utilizar
000139100913      //              el metodo CEXCEPTION_throwNewException
000140100913      //@paramin: senderInfo  estructura con informacion del envio de la
000141100913      //                      excepcion.
000142100913      //@@
000143100913     d CEXCEPTION_saveSenderInfo...
000144100913     d                 pr
000145100913     d senderInfo                          likeds(RCVM0300SndRcvInfo) const
000146100913
000147100913      //@@method:
000148100913      //@name: CEXCEPTION_printExceptionJoblog
000149100913      //@description: imprime la excepcion en el joblog
000150100913      //@@
000151100913     d CEXCEPTION_printExceptionJoblog...
000152100913     d                 pr
000153100913     d messageId                      7a   const varying
000154100913     d messageFile                   20a   const varying
000155100913     d messageText                  132a   const varying
000156100913     d messageSev                    10a   const varying
000157100913     d program                       10a   const varying
000158100913     d module                        10a   const varying
000159100913     d procedure                    255a   const varying
000160100913     d statement                     30a   const varying
000161100913     d jobName                       10a   const varying
000162100913     d jobNumber                      6a   const varying
000163100913     d userProfile                   10a   const varying
000164100913     d date                          10a   const varying
000165100913     d time                          15a   const varying
000166100913
000167100913      //-----------------------------------------------------------------------
000168100913      // Definicion de procedimientos
000169100913      //-----------------------------------------------------------------------
000170100913
000171100913      //@@method:
000172100913      //@name: CEXCEPTION_throwNewException
000173100913      //@description: Genera un nuevo program message de tipo *ESCAPE,
000174100913      //              que cancela la entrada actual de la pila de llamadas
000175100913      //              y puede ser capturado en un bloque monitor.
000176100913      //
000177100913      //@param: msgID      Identificador del mensaje
000178100913      //@param: msgFile    Archivo de mensajes (sin calificar)
000179100913      //@param: replaceVar Reemplazo para la variable de sustitucion
000180100913      //                   incluida en la definicion del mensaje
000181100913      //                   en el messageFile indicado
000182100913      //@return: indica si se pudo genera la excepcion o no
000183100913      //@@
000184100913     p CEXCEPTION_throwNewException...
000185100913     p                 b                   export
000186100913     d                 pi              n
000187100913     d msgID                         10a   const varying
000188100913     d msgFile                       10a   const varying
000189100913     d replaceVar                  3000a   const varying options(*nopass)
000190100913     d
000191100913     d errorApi        ds                  likeds(errorDS_Type)
000192100913     d qualifiedMsgFileName...
000193100913     d                 s             20a
000194100913     d msgKey          s              4a
000195100913     d replaceVarTemp  s           3000a
000196100913
000197100913      /free
000198100913       //Limpia la estructura
000199100913       clear exception;
000200100913
000201100913       monitor;
000202100913         if %parms() > 2;
000203100913           //En caso de que la variable de reemplazo fue provista,
000204100913           //no se emplea el valor por defecto
000205100913           replaceVarTemp = replaceVar;
000206100913         endif;
000207100913
000208100913         //Crea el nombre calificado del archivo de mensajes
000209100913         qualifiedMsgFileName            = msgFile;
000210100913         %subst(qualifiedMsgFileName:11) = '*LIBL';
000211100913
000212100913         //Salva la pila de llamadas
000213100913         if CEXCEPTION_saveCallStack() and stackEntryArrayCount > 0;
000214100913
000215100913           //Salva informacion de la excepcion
000216100913           CEXCEPTION_saveThrowInfo();
000217100913         endif;
000218100913
000219100913         //Invoca el envio del program message
000220100913         SendProgramMessage(msgId:
000221100913                    qualifiedMsgFileName:
000222100913                    replaceVarTemp:
000223100913                    %len(%trimr(replaceVarTemp)):
000224100913                    MESSAGE_TYPE_ESCAPE:
000225100913                    CALL_STACK_ENTRY:
000226100913                    CALL_STACK_COUNTER_THROW:
000227100913                    MsgKey:
000228100913                    errorApi);
000229100913
000230100913         //--------------------------------------------------------------------
000231100913         //Esta seccion de codigo solo se ejecuta en caso de que no se
000232100913         //pudo enviar el mensaje
000233100913         //--------------------------------------------------------------------
000234100913
000235100913         if errorApi.exceptionId <> *blanks;
000236100913           //En caso de que no encuentre el messageFile indicado
000237100913           //se lanza una excepcion generica
000238100913           %subst(qualifiedMsgFileName:1:10) = DEFAULT_MESSAGE_FILE;
000239100913           replaceVarTemp = 'The application tried to throw exception ' +
000240100913                             msgID + ', but the message file ' +
000241100913                             msgFile + ' is not valid';
000242100913
000243100913           SendProgramMessage(DEFAULT_MESSAGE_ID:
000244100913                    qualifiedMsgFileName:
000245100913                    replaceVarTemp:
000246100913                    %len(%trim(replaceVarTemp)):
000247100913                    MESSAGE_TYPE_ESCAPE:
000248100913                    CALL_STACK_ENTRY:
000249100913                    CALL_STACK_COUNTER_THROW:
000250100913                    MsgKey:
000251100913                    errorApi);
000252100913
000253100913           return *on;
000254100913         else;
000255100913           CEXCEPTION_jobPrintf('CEXCEPTION_throwNewException: +
000256100913             Error throwing exception!');
000257100913           return *off;
000258100913         endif;
000259100913       on-error;
000260100913         CEXCEPTION_jobPrintf('CEXCEPTION_throwNewException: +
000261100913             Error throwing exception!');
000262100913         return *off;
000263100913       endmon;
000264100913      /end-free
000265100913
000266100913     p CEXCEPTION_throwNewException...
000267100913     p                 e
000268100913      //_______________________________________________________________________
000269100913
000270100913      //@@method:
000271100913      //@name: CEXCEPTION_saveCallStack
000272100913      //@description: salva la pila de llamadas en un arreglo
000273100913      //
000274100913      //@paramin: skipEntries indica cuantas entradas de la pila deben
000275100913      //                      ignorarse al inicio
000276100913      //@return: retorna *OFF en caso de error
000277100913      //@@
000278100913     p CEXCEPTION_saveCallStack...
000279100913     p                 b
000280100913     d                 pi              n
000281100913     d skipEntries                   10i 0 options(*nopass) value
000282100913
000283100913      /free
000284100913       //El arreglo en el que se salva la pila es global
000285100913       return CEXCEPTION_getCurrentCallStack(%addr(stackEntryArray)
000286100913                                            :stackEntryArrayCount);
000287100913      /end-free
000288100913
000289100913     p CEXCEPTION_saveCallStack...
000290100913     p                 e
000291100913      //_______________________________________________________________________
000292100913
000293100913      //@@method:
000294100913      //@name: CEXCEPTION_getCurrentCallStack
000295100913      //@description: obtiene la pila de llamadas en el momento en que se
000296100913      //              invoca este procedimiento
000297100913      //
000298100913      //@paramin:  ptrEntryArray apuntador al arreglo en el que se almacenará
000299100913      //                         la informacion de la pila de llamadas
000300100913      //                         Debe ser de 100 entradas
000301100913      //@paramout: arraySize     cantidad de entradas de arreglo
000302100913      //@paramin:  skipEntries   cantidad de entradas que se ignorarán al inicio
000303100913      //                         de la pila de llamadas. Por defecto 2.
000304100913      //@return: indicador del estado de la operacion
000305100913      //@@
000306100913     p CEXCEPTION_getCurrentCallStack...
000307100913     p                 b                   export
000308100913     d                 pi              n
000309100913     d ptrEntryArray                   *   const
000310100913     d arraySize                     10i 0
000311100913     d skipEntries                   10i 0 options(*nopass) value
000312100913     d
000313100913     d entryArray      ds                  dim(ENTRY_ARRAY_SIZE)
000314100913     d                                     likeds(callStackEntry_type)
000315100913     d                                     based(ptrEntryArray)
000316100913     d sizeCSTK0100    s             10i 0 inz(0)
000317100913     d index           s             10i 0
000318100913     d ptrCSTK0100     s               *   inz(*null)
000319100913     d
000320100913      //Estructura de informacion de la pila de llamadas
000321100913     d CSTK0100        ds                  qualified based(ptrCSTK0100)
000322100913     d  BytesRtn                     10i 0
000323100913     d  BytesAvail                   10i 0
000324100913     d  Total                        10i 0
000325100913     d  Offset                       10i 0
000326100913     d  Count                        10i 0
000327100913     d  ThreadId                      8a
000328100913     d  Status                        1a
000329100913     d
000330100913      //Estructura de informacion del job
000331100913     d JIDF0100        ds                  qualified
000332100913     d  JobName                      10a   inz('*')
000333100913     d  JobUser                      10a
000334100913     d  JobNo                         6a
000335100913     d  IntId                        16a
000336100913     d                                2a   inz(x'0000')
000337100913     d  ThreadInd                    10i 0 inz(1)
000338100913     d  ThreadId                      8a   inz(x'0000000000000000')
000339100913     d
000340100913     d
000341100913     d pStatement      s               *
000342100913
000343100913      //Estructura de informacion de numero de statements
000344100913     d statements      ds          1000    qualified based(pStatement)
000345100913     d  identifier                   10a
000346100913
000347100913      //Almacena el nombre del procedimiento invocado
000348100913     d procedureName   s           4096a   based(ptrName)
000349100913     d
000350100913     d errorApi        ds                  likeds(errorDS_Type)
000351100913     d newArrayEntry   ds                  likeds(callStackEntry_type)
000352100913     d skipEntriesUsed...
000353100913     d                 s                   like(skipEntries)
000354100913     d                                     inz(IGNORE_ENTRIES)
000355100913     d ptrEntry        s               *   inz(*null)
000356100913     d stackEntry      ds                  likeds(stackEntry_type)
000357100913     d                                     based(ptrEntry)
000358100913
000359100913      /free
000360100913       //Limpia el arreglo de entradas de la pila
000361100913       clear entryArray;
000362100913       arraySize = 0;
000363100913
000364100913       //Se reserva inicialmente el tamaño de la estructura CSTK0100.
000365100913       //En caso de que sea insuficiente se reasigna
000366100913       sizeCSTK0100 = %size(CSTK0100);
000367100913       ptrCSTK0100  = %alloc(sizeCSTK0100);
000368100913
000369100913       monitor;
000370100913         //Trata de obtener la informacion de la pila de llamadas
000371100913         //En caso de que la memoria reservada sea insuficiente,
000372100913         //ejecuta un realloc
000373100913         dou (CSTK0100.BytesRtn >= CSTK0100.BytesAvail);
000374100913           GetCallStack(CSTK0100:
000375100913                        sizeCSTK0100:
000376100913                        CALL_STACK_INFO_FORMAT:
000377100913                        JIDF0100:
000378100913                        JOB_INFO_FORMAT:
000379100913                        errorApi);
000380100913
000381100913           if (sizeCSTK0100 < CSTK0100.BytesAvail);
000382100913             sizeCSTK0100 = CSTK0100.BytesAvail;
000383100913             ptrCSTK0100 = %realloc(ptrCSTK0100:sizeCSTK0100);
000384100913           endif;
000385100913         enddo;
000386100913
000387100913         //Establece el apuntador a la entrada correspondiente
000388100913         //de la pila de llamadas obtenida por el API
000389100913         ptrEntry = ptrCSTK0100 + CSTK0100.Offset;
000390100913
000391100913         if %parms > 2;
000392100913           skipEntriesUsed = skipEntries;
000393100913         endif;
000394100913
000395100913         //Se salta las primeras N entradas de la pila de llamadas
000396100913         for index = 1 to skipEntriesUsed;
000397100913           ptrEntry += stackEntry.Len;
000398100913         endfor;
000399100913
000400100913         if CSTK0100.Count > skipEntriesUsed;
000401100913
000402100913           //Recorre cada una de las entradas de la pila de llamadas
000403100913           //a partir de la tercer entrada,
000404100913           for index = skipEntriesUsed + 1 to CSTK0100.Count;
000405100913             clear newArrayEntry;
000406100913
000407100913             //Establece el valor de stackEntry
000408100913             newArrayEntry.stackEntryInfo = stackEntry;
000409100913
000410100913             //Si esta disponible, se obtiene el numero de linea de la
000411100913             //invocacion
000412100913             if stackEntry.StmtCnt > 0 and stackEntry.StmtDisp > 0;
000413100913               pStatement = ptrEntry + stackEntry.StmtDisp;
000414100913               newArrayEntry.statement = %triml(statements.identifier:'0');
000415100913             endif;
000416100913
000417100913             //Si esta disponible, se obtiene el nombre del procedimiento
000418100913             if (stackEntry.ProcDisp > 0 and stackEntry.ProcLen > 0);
000419100913               ptrName = ptrEntry + stackEntry.ProcDisp;
000420100913               newArrayEntry.procedureName = %subst(procedureName:1:
000421100913                                                     stackEntry.ProcLen);
000422100913             endif;
000423100913
000424100913             //Agrega la nueva entrada al arreglo
000425100913             arraySize += 1;
000426100913             entryArray(arraySize) = newArrayEntry;
000427100913
000428100913             //Establece el apuntador a la entrada siguiente
000429100913             //de la pila de llamadas obtenida por el API
000430100913             ptrEntry = ptrEntry + stackEntry.Len;
000431100913
000432100913             //Si el arreglo de entradas alcanzó el maximo, sale del for
000433100913             if arraySize > ENTRY_ARRAY_SIZE;
000434100913               leave;
000435100913             endif;
000436100913           endfor;
000437100913         endif;
000438100913       on-error;
000439100913         CEXCEPTION_jobPrintf('CEXCEPTION_saveCallStack: +
000440100913             Error saving stack!');
000441100913         return *off;
000442100913       endmon;
000443100913
000444100913       if ptrCSTK0100 <> *null;
000445100913         dealloc ptrCSTK0100;
000446100913         ptrCSTK0100 = *null;
000447100913       endif;
000448100913
000449100913       return *on;
000450100913      /end-free
000451100913
000452100913     p CEXCEPTION_getCurrentCallStack...
000453100913     p                 e
000454100913      //_______________________________________________________________________
000455100913
000456100913      //@@method:
000457100913      //@name: CEXCEPTION_saveThrowInfo
000458100913      //@description: salva informacion de la excepcion, disponible en el
000459100913      //              momento en el que se realiza el throw de la excepcion
000460100913      //@@
000461100913     p CEXCEPTION_saveThrowInfo...
000462100913     p                 b
000463100913     d arrayEntry      ds                  likeds(callStackEntry_type)
000464100913
000465100913      /free
000466100913       monitor;
000467100913         if (stackEntryArrayCount > 0);
000468100913           arrayEntry = stackEntryArray(1);
000469100913
000470100913           //Establece los datos de la excepcion, obtenidos del primer
000471100913           //elemento del arreglo de entradas de la pila de llamadas
000472100913           exception.program         = arrayEntry.stackEntryInfo.PgmName;
000473100913           exception.module          = arrayEntry.stackEntryInfo.Module;
000474100913           exception.procedure       = arrayEntry.procedureName;
000475100913           exception.statementNumber = %triml(arrayEntry.statement:'0');
000476100913         endif;
000477100913       on-error;
000478100913         CEXCEPTION_jobPrintf('CEXCEPTION_saveThrowInfo: +
000479100913             Error saving information!');
000480100913       endmon;
000481100913      /end-free
000482100913
000483100913     p CEXCEPTION_saveThrowInfo...
000484100913     p                 e
000485100913      //_______________________________________________________________________
000486100913
000487100913      //@@method:
000488100913      //@name: CEXCEPTION_catchException
000489100913      //@description: obtiene datos de una excepcion producida
000490100913      //@return: en caso de error devuelve *OFF
000491100913      //@@
000492100913     p CEXCEPTION_catchException...
000493100913     p                 b                   export
000494100913     d                 pi              n
000495100913     d
000496100913     d recoveredMessage...
000497100913     d                 ds                  likeds(RCVM0300)
000498100913     d messageKey      s              4    inz(*ALLx'00')
000499100913     d apiError        ds                  likeds(errorDS_Type)
000500100913     d
000501100913     d ptrSenderInfo   s               *   inz(*null)
000502100913     d senderInfo      ds                  likeds(RCVM0300SndRcvInfo)
000503100913     d                                     based(ptrSenderInfo)
000504100913
000505100913      /free
000506100913       monitor;
000507100913         ReceiveProgramMessage(recoveredMessage:
000508100913                               %size(recoveredMessage):
000509100913                               FORMAT_NAME:
000510100913                               CALL_STACK_ENTRY:
000511100913                               CALL_STACK_COUNTER:
000512100913                               MESSAGE_TYPE:
000513100913                               messageKey:
000514100913                               WAIT_TIME:
000515100913                               RECEIVE_ACTION:
000516100913                               apiError);
000517100913
000518100913         if recoveredMessage.ByteAvail > 0;
000519100913           ptrSenderInfo = %addr(recoveredMessage.MsgData)
000520100913                         + recoveredMessage.LenReplace1
000521100913                         + recoveredMessage.LenMsgReturn
000522100913                         + recoveredMessage.LenHelpReturn;
000523100913
000524100913           //Si la excepcion no fue lanzada utilizando el metodo
000525100913           //CEXCEPTION_throwNewException, entonces debe salvar la pila
000526100913           //de llamadas
000527100913           if %trimr(senderInfo.SendingProcedure) <> THROW_PROCEDURE_NAME;
000528100913             clear exception;
000529100913             CEXCEPTION_saveCallStack();
000530100913             CEXCEPTION_saveSenderInfo(senderInfo);
000531100913           endif;
000532100913
000533100913           exception.messageId          = recoveredMessage.MsgId;
000534100913           exception.messageFileName    = recoveredMessage.MsgFileName;
000535100913           exception.messageSeverity    = recoveredMessage.MsgSeverity;
000536100913           exception.messageFileLibrary = recoveredMessage.MsgLibUsed;
000537100913
000538100913           exception.messageText = %subst(recoveredMessage.MsgData:
000539100913                                          recoveredMessage.LenReplace1 + 1:
000540100913                                          recoveredMessage.LenMsgReturn);
000541100913           exception.date        = %date(%dec(senderInfo.DateSent:7:0):*cymd);
000542100913           exception.time        = %time(senderInfo.TimeSent:*hms0);
000543100913           exception.jobName     = psds.job_name;
000544100913           exception.userProfile = psds.job_user;
000545100913           exception.jobNumber   = %char(psds.job_num);
000546100913
000547100913           if (recoveredMessage.LenReplace1 > 0);
000548100913             exception.messageData = %subst(recoveredMessage.MsgData:1:
000549100913                                            recoveredMessage.LenReplace1);
000550100913           endif;
000551100913
000552100913           //Limpia el indicador de que se lanzo la excepcion
000553100913           return *on;
000554100913         else;
000555100913            CEXCEPTION_jobPrintf('CEXCEPTION_catchException: +
000556100913                Nothing to catch!');
000557100913           return *off;
000558100913         endif;
000559100913       on-error;
000560100913         CEXCEPTION_jobPrintf('CEXCEPTION_catchException: +
000561100913                Error catching exception!');
000562100913         return *off;
000563100913       endmon;
000564100913      /end-free
000565100913
000566100913     p CEXCEPTION_catchException...
000567100913     p                 e
000568100913      //_______________________________________________________________________
000569100913
000570100913      //@@method:
000571100913      //@name: CEXCEPTION_saveSenderInfo
000572100913      //@description: salva informacion de la excepcion, obtenida al
000573100913      //              recuperar el program message. Este procedimiento
000574100913      //              se utiliza cuando se envia una excepcion  sin utilizar
000575100913      //              el metodo CEXCEPTION_throwNewException
000576100913      //@paramin: senderInfo  estructura con informacion del envio de la
000577100913      //                      excepcion.
000578100913      //@@
000579100913     p CEXCEPTION_saveSenderInfo...
000580100913     p                 b
000581100913     d                 pi
000582100913     d senderInfo                          likeds(RCVM0300SndRcvInfo) const
000583100913
000584100913      /free
000585100913       exception.program         = %trimr(senderInfo.SendingPgm);
000586100913       exception.module          = %trimr(senderInfo.SendingModule);
000587100913       exception.procedure       = %trimr(senderInfo.SendingProcedure);
000588100913       exception.statementNumber = senderInfo.StateNosSending;
000589100913      /end-free
000590100913
000591100913     p CEXCEPTION_saveSenderInfo...
000592100913     p                 e
000593100913      //_______________________________________________________________________
000594100913
000595100913      //@@method:
000596100913      //@name: CEXCEPTION_printStackTrace
000597100913      //@description: escribe la pila de llamadas al momento en el que se
000598100913      //              produjo la ultima excepcion
000599100913      //
000600100913      //@paramin: ptrHeaderPrinter apuntador al procedimiento que despliega
000601100913      //                           el encabezado de la impresion de la pila.
000602100913      //                           Debe cumplir con el siguiente prototipo:
000603100913      //
000604100913      //  d headerPrinter   pr
000605100913      //  d  messageId                          like(exception_type.messageId)
000606100913      //  d                                     const
000607100913      //  d  messageText                        like(exception_type.messageText)
000608100913      //  d                                     const
000609100913      //  d  callStackSize                10i 0 const
000610100913      //
000611100913      //@paramin: ptrEntryPrinter  apuntador al procedimiento que despliega
000612100913      //                           cada una de las entradas de la pila de
000613100913      //                           llamadas. Debe cumplir el siguiente prototipo
000614100913      //
000615100913      //  d entryPrinter    pr
000616100913      //  d  programName                  21a   varying const
000617100913      //  d  moduleName                   21a   varying const
000618100913      //  d  procedureName               255a   varying const
000619100913      //  d  line                         30a   varying const
000620100913      //
000621100913      // @paramin: ptrFooterPrinter apuntador al procedimiento que finaliza la
000622100913      //                            impresion de las entradas de la pila. Debe
000623100913      //                            cumplir el siguiente prototipo:
000624100913      //
000625100913      //  d footerPrinter   pr
000626100913      //@@
000627100913     p CEXCEPTION_printStackTrace...
000628100913     p                 b                   export
000629100913     d                 pi
000630100913     d ptrHeaderPrinter...
000631100913     d                                 *   procptr const options(*nopass)
000632100913     d ptrEntryPrinter...
000633100913     d                                 *   procptr const options(*nopass)
000634100913     d ptrFooterPrinter...
000635100913     d                                 *   procptr const options(*nopass)
000636100913     d
000637100913     d ptrHeaderPrinterUsed...
000638100913     d                 s                   like(ptrHeaderPrinter)
000639100913     d ptrEntryPrinterUsed...
000640100913     d                 s                   like(ptrEntryPrinter)
000641100913     d ptrFooterPrinterUsed...
000642100913     d                 s                   like(ptrFooterPrinter)
000643100913     d
000644100913      //Prototipo del procedimiento que despliega el header de la pila
000645100913     d headerPrinter   pr                  extproc(ptrHeaderPrinterUsed)
000646100913     d  messageId                          like(exception_type.messageId)
000647100913     d                                     const
000648100913     d  messageText                        like(exception_type.messageText)
000649100913     d                                     const
000650100913     d  callStackSize                10i 0 const
000651100913     d
000652100913      //Prototipo del procedimiento especifico que despliega cada una de las
000653100913      //entradas de la pila de llamadas
000654100913     d entryPrinter    pr                  extproc(ptrEntryPrinterUsed)
000655100913     d  programName                  21a   varying const
000656100913     d  moduleName                   21a   varying const
000657100913     d  procedureName               255a   varying const
000658100913     d  line                         30a   varying const
000659100913     d
000660100913      //Prototipo del procedimiento especifico que despliega el final de la
000661100913      //impresion de la pila de llamadas
000662100913     d footerPrinter   pr                  extproc(ptrFooterPrinterUsed)
000663100913     d
000664100913     d programName     s             21a   varying
000665100913     d moduleName      s             21a   varying
000666100913     d
000667100913     d index           s             10i 0
000668100913     d arrayEntryTemp...
000669100913     d                 ds                  likeds(callStackEntry_type) inz
000670100913
000671100913      /free
000672100913       monitor;
000673100913         if stackEntryArrayCount <= 0;
000674100913           CEXCEPTION_jobPrintf('CEXCEPTION_printStackTrace: +
000675100913                Stack trace not available');
000676100913           return;
000677100913         endif;
000678100913
000679100913         //Validacion de los parametros especificados para este procedimiento
000680100913         if %parms = 0;
000681100913           ptrHeaderPrinterUsed = %paddr(CEXCEPTION_printStackHeader);
000682100913           ptrEntryPrinterUsed  = %paddr(CEXCEPTION_printStackEntry);
000683100913           ptrFooterPrinterUsed = *null;
000684100913         else;
000685100913           ptrHeaderPrinterUsed = ptrHeaderPrinter;
000686100913           if ptrHeaderPrinterUsed = *null;
000687100913             CEXCEPTION_jobPrintf('WARNING at CEXCEPTION_printStackTrace: +
000688100913                                   Header printer pointer not especified.');
000689100913           endif;
000690100913
000691100913           if %parms > 1;
000692100913             ptrEntryPrinterUsed = ptrEntryPrinter;
000693100913             if ptrEntryPrinterUsed = *null;
000694100913               CEXCEPTION_jobPrintf('WARNING at CEXCEPTION_printStackTrace: +
000695100913                                     Entry printer pointer not especified.');
000696100913             endif;
000697100913
000698100913             if %parms > 2;
000699100913               ptrFooterPrinterUsed = ptrFooterPrinter;
000700100913               if ptrFooterPrinterUsed = *null;
000701100913                 CEXCEPTION_jobPrintf('WARNING at CEXCEPTION_printStackTrace: +
000702100913                                     Footer printer pointer not especified.');
000703100913               endif;
000704100913             endif;
000705100913           endif;
000706100913         endif;
000707100913
000708100913         if ptrHeaderPrinterUsed <> *null;
000709100913           //Invoca el metodo especifico para desplegar el inicio de la
000710100913           //impresion de la pila de llamadas
000711100913           headerPrinter(exception.messageId:
000712100913                         exception.messageText:
000713100913                         stackEntryArrayCount);
000714100913         endif;
000715100913
000716100913         if ptrEntryPrinterUsed <> *null;
000717100913           //En caso de que la excepcion sea diferente a la primera entrada
000718100913           //de la pila de llamadas salvada, se despliega la informacion
000719100913           if (stackEntryArray(1).procedureName <> exception.procedure);
000720100913             entryPrinter(exception.program:
000721100913                          exception.module:
000722100913                          %trimr(exception.procedure):
000723100913                          %trimr(exception.statementNumber));
000724100913           endif;
000725100913
000726100913           for index = 1 to stackEntryArrayCount;
000727100913             arrayEntryTemp = stackEntryArray(index);
000728100913
000729100913             programName = %trimr(arrayEntryTemp.stackEntryInfo.PgmName);
000730100913
000731100913             if arrayEntryTemp.stackEntryInfo.Module <> *blanks;
000732100913               moduleName = %trimr(arrayEntryTemp.stackEntryInfo.Module);
000733100913             endif;
000734100913
000735100913             //Invoca el metodo especifico para desplegar cada una de las
000736100913             //entradas de la pila de llamadas
000737100913             entryPrinter(programName:
000738100913                          moduleName:
000739100913                          %trimr(arrayEntryTemp.procedureName):
000740100913                          %trimr(arrayEntryTemp.statement));
000741100913
000742100913           endfor;
000743100913         endif;
000744100913
000745100913         if ptrFooterPrinterUsed <> *null;
000746100913           //Invoca el metodo especifico para desplegar el final de la
000747100913           //impresion de la pila de llamadas
000748100913           footerPrinter();
000749100913         endif;
000750100913
000751100913       on-error;
000752100913         CEXCEPTION_jobPrintf('CEXCEPTION_printStackTrace: +
000753100913                Error printing stack!');
000754100913       endmon;
000755100913      /end-free
000756100913
000757100913     p CEXCEPTION_printStackTrace...
000758100913     p                 e
000759100913      //_______________________________________________________________________
000760100913
000761100913      //@@method:
000762100913      //@name: CEXCEPTION_printStackHeader
000763100913      //@description: escribe el en joblog, el encabezado de la impresion
000764100913      //              de la pila de llamadas
000765100913      //@paramin: messageId     identificador de la excepcion producida
000766100913      //@paramin: messageText   descripcion de la excepcion producida
000767100913      //@paramin: callStackSize profundidad de la pila de llamadas
000768100913      //@@
000769100913     p CEXCEPTION_printStackHeader...
000770100913     p                 b
000771100913     d                 pi
000772100913     d messageId                           like(exception_type.messageId)
000773100913     d                                     const
000774100913     d messageText                         like(exception_type.messageText)
000775100913     d                                     const
000776100913     d callStackSize                 10i 0 const
000777100913
000778100913      /free
000779100913       if callStackSize > 0;
000780100913         CEXCEPTION_jobPrintf('Exception %s: %s':messageId:messageText);
000781100913       endif;
000782100913
000783100913       return;
000784100913      /end-free
000785100913
000786100913     p CEXCEPTION_printStackHeader...
000787100913     p                 e
000788100913      //_______________________________________________________________________
000789100913
000790100913      //@@method:
000791100913      //@name: CEXCEPTION_printStackEntry
000792100913      //@description: despliega una entrada de la pila de llamadas
000793100913      //@@
000794100913     p CEXCEPTION_printStackEntry...
000795100913     p                 b
000796100913     d                 pi
000797100913     d  programName                  21a   varying const
000798100913     d  moduleName                   21a   varying const
000799100913     d  procedureName               255a   varying const
000800100913     d  line                         30a   varying const
000801100913     d  tab            c                   const('   ')
000802100913
000803100913      /free
000804100913       if moduleName <> *blanks;
000805100913         CEXCEPTION_jobPrintf(tab + 'at program %s::module %s':
000806100913             programName:moduleName);
000807100913       else;
000808100913         CEXCEPTION_jobPrintf(tab + 'at program %s':programName);
000809100913       endif;
000810100913
000811100913       if procedureName <> *blanks;
000812100913         CEXCEPTION_jobPrintf(tab + tab + 'at procedure: %s':procedureName);
000813100913       endif;
000814100913
000815100913       if line <> *blanks;
000816100913         CEXCEPTION_jobPrintf(tab + tab + 'at line: %s':line);
000817100913       endif;
000818100913
000819100913       return;
000820100913      /end-free
000821100913
000822100913     p CEXCEPTION_printStackEntry...
000823100913     p                 e
000824100913      //_______________________________________________________________________
000825100913
000826100913      //@@method:
000827100913      //@name: CEXCEPTION_printException
000828100913      //@description: despliega la ultima excepcion capturada
000829100913      //@paramin: ptrExceptionPrinter apuntador al procedimiento que imprime
000830100913      //                              la excepcion. Debe cumplir el prototipo:
000831100913      //
000832100913      // d exceptionPrinter...
000833100913      // d                 pr                  extproc(ptrExceptionPrinterUsed)
000834100913      // d messageId                      7a   const varying
000835100913      // d messageFile                   20a   const varying
000836100913      // d messageText                  132a   const varying
000837100913      // d messageSev                    10a   const varying
000838100913      // d program                       10a   const varying
000839100913      // d module                        10a   const varying
000840100913      // d procedure                    255a   const varying
000841100913      // d statement                     30a   const varying
000842100913      // d jobName                       10a   const varying
000843100913      // d jobNumber                      6a   const varying
000844100913      // d userProfile                   10a   const varying
000845100913      // d date                          10a   const varying
000846100913      // d time                          15a   const varying
000847100913      //@@
000848100913     p CEXCEPTION_printException...
000849100913     p                 b                   export
000850100913     d                 pi
000851100913     d ptrExceptionPrinter...
000852100913     d                                 *   procptr const options(*omit:*nopass)
000853100913     d ptrExceptionPrinterUsed...
000854100913     d                 s                   like(ptrExceptionPrinter)
000855100913     d                                     inz(*null)
000856100913      //Prototipo para el procedimiento apuntado por ptrExceptionPrinter
000857100913     d exceptionPrinter...
000858100913     d                 pr                  extproc(ptrExceptionPrinterUsed)
000859100913     d messageId                      7a   const varying
000860100913     d messageFile                   20a   const varying
000861100913     d messageText                  132a   const varying
000862100913     d messageSev                    10a   const varying
000863100913     d program                       10a   const varying
000864100913     d module                        10a   const varying
000865100913     d procedure                    255a   const varying
000866100913     d statement                     30a   const varying
000867100913     d jobName                       10a   const varying
000868100913     d jobNumber                      6a   const varying
000869100913     d userProfile                   10a   const varying
000870100913     d date                          10a   const varying
000871100913     d time                          15a   const varying
000872100913
000873100913      /free
000874100913       monitor;
000875100913          if %parms > 0;
000876100913            ptrExceptionPrinterUsed = ptrExceptionPrinter;
000877100913          else;
000878100913            ptrExceptionPrinterUsed = %paddr(CEXCEPTION_printExceptionJoblog);
000879100913          endif;
000880100913
000881100913          if exception.messageId <> *blanks;
000882100913            if ptrExceptionPrinterUsed <> *null;
000883100913              exceptionPrinter(%trimr(CEXCEPTION_getMessageId())
000884100913                              :%trimr(CEXCEPTION_getMessageFile())
000885100913                              :%trimr(CEXCEPTION_getMessageText())
000886100913                              :%trimr(%char(CEXCEPTION_getMessageSeverity()))
000887100913                              :%trimr(CEXCEPTION_getProgram())
000888100913                              :%trimr(CEXCEPTION_getModule())
000889100913                              :%trimr(CEXCEPTION_getProcedure())
000890100913                              :%trimr(CEXCEPTION_getStatementNumber())
000891100913                              :%trimr(CEXCEPTION_getJobName())
000892100913                              :%trimr(CEXCEPTION_getJobNumber())
000893100913                              :CEXCEPTION_getUserProfile()
000894100913                              :%trimr(%char(CEXCEPTION_getDate()))
000895100913                              :%trimr(%char(CEXCEPTION_getTime())));
000896100913            else;
000897100913              CEXCEPTION_jobPrintf('CEXCEPTION_printException: +
000898100913                              WARNING: ExceptionPrinter is null');
000899100913            endif;
000900100913          else;
000901100913            CEXCEPTION_jobPrintf('CEXCEPTION_printException: +
000902100913                              No exception to print');
000903100913          endif;
000904100913       on-error;
000905100913         CEXCEPTION_jobPrintf('CEXCEPTION_printException: +
000906100913                              error printing exception');
000907100913       endmon;
000908100913      /end-free
000909100913
000910100913     p CEXCEPTION_printException...
000911100913     p                 e
000912100913      //_______________________________________________________________________
000913100913
000914100913      //@@method:
000915100913      //@name: CEXCEPTION_printExceptionJoblog
000916100913      //@description: imprime la excepcion en el joblog
000917100913      //@@
000918100913     p CEXCEPTION_printExceptionJoblog...
000919100913     p                 b
000920100913     d                 pi
000921100913     d messageId                      7a   const varying
000922100913     d messageFile                   20a   const varying
000923100913     d messageText                  132a   const varying
000924100913     d messageSev                    10a   const varying
000925100913     d program                       10a   const varying
000926100913     d module                        10a   const varying
000927100913     d procedure                    255a   const varying
000928100913     d statement                     30a   const varying
000929100913     d jobName                       10a   const varying
000930100913     d jobNumber                      6a   const varying
000931100913     d userProfile                   10a   const varying
000932100913     d date                          10a   const varying
000933100913     d time                          15a   const varying
000934100913
000935100913
000936100913      /free
000937100913       CEXCEPTION_jobPrintf('Message Id: %s': messageId);
000938100913       CEXCEPTION_jobPrintf('Message File: %s': messageFile);
000939100913       CEXCEPTION_jobPrintf('Message Severity: %s': messageSev);
000940100913       CEXCEPTION_jobPrintf('Message Text: %s': messageText);
000941100913       CEXCEPTION_jobPrintf('Program: %s': program);
000942100913       CEXCEPTION_jobPrintf('Module: %s': module);
000943100913       CEXCEPTION_jobPrintf('Procedure: %s': procedure);
000944100913       CEXCEPTION_jobPrintf('Line: %s': statement);
000945100913       CEXCEPTION_jobPrintf('Job Name: %s': jobName);
000946100913       CEXCEPTION_jobPrintf('Job Number: %s': jobNumber);
000947100913       CEXCEPTION_jobPrintf('User profile: %s': userProfile);
000948100913       CEXCEPTION_jobPrintf('Date: %s': date);
000949100913       CEXCEPTION_jobPrintf('Time: %s': time);
000950100913      /end-free
000951100913
000952100913     p CEXCEPTION_printExceptionJoblog...
000953100913     p                 e
000954100913      //_______________________________________________________________________
000955100913
000956100913      //@@method:
000957100913      //@name: CEXCEPTION_jobPrintf
000958100913      //@description: escribe una cadena de caracteres en el joblog
000959100913      //@return: cantidad de bytes escritos en el joblog
000960100913      //@@
000961100913     p CEXCEPTION_jobPrintf...
000962100913     p                 b                   export
000963100913     d                 pi            10i 0
000964100913     d  pMsg                           *   value options(*string)
000965100913     d  pS1                            *   value options(*string : *nopass)
000966100913     d  pS2                            *   value options(*string : *nopass)
000967100913     d  pS3                            *   value options(*string : *nopass)
000968100913     d  pS4                            *   value options(*string : *nopass)
000969100913     d  pS5                            *   value options(*string : *nopass)
000970100913     d  pS6                            *   value options(*string : *nopass)
000971100913     d  pS7                            *   value options(*string : *nopass)
000972100913     d  pS8                            *   value options(*string : *nopass)
000973100913
000974100913      //Prototipo del procedimiento de C para escribir en el JobLog
000975100913     d Qp0zLprintf     pr            10I 0 ExtProc('Qp0zLprintf')
000976100913     d  outputString                   *   value options(*string)
000977100913     d                                 *   value options(*string:*nopass)
000978100913     d                                 *   value options(*string:*nopass)
000979100913     d                                 *   value options(*string:*nopass)
000980100913     d                                 *   value options(*string:*nopass)
000981100913     d                                 *   value options(*string:*nopass)
000982100913     d                                 *   value options(*string:*nopass)
000983100913     d                                 *   value options(*string:*nopass)
000984100913     d                                 *   value options(*string:*nopass)
000985100913     d                                 *   value options(*string:*nopass)
000986100913     d                                 *   value options(*string:*nopass)
000987100913
000988100913     d writtenBytes    s             10i 0
000989100913
000990100913      /free
000991100913       writtenBytes  = Qp0zLprintf(pMsg:pS1:pS2:pS3:pS4:pS5:pS6:pS7:ps8);
000992100913       writtenBytes += Qp0zLprintf(X'25');
000993100913       return writtenBytes;
000994100913      /end-free
000995100913
000996100913     p CEXCEPTION_jobPrintf...
000997100913     p                 e
000998100913
000999100913      //-----------------------------------------------------------------------
001000100913      // Metodos get
001001100913      //-----------------------------------------------------------------------
001002100913
001003100913      //@@method:
001004100913      //@name: CEXCEPTION_getMessageId
001005100913      //@description: obtiene el messageId de la excepcion
001006100913      //@return: messageId de la excepcion
001007100913      //@@
001008100913     p CEXCEPTION_getMessageId...
001009100913     p                 b                   export
001010100913     d                 pi                  like(exception_type.messageId)
001011100913
001012100913      /free
001013100913       return exception.messageId;
001014100913      /end-free
001015100913
001016100913     p CEXCEPTION_getMessageId...
001017100913     p                 e
001018100913      //_______________________________________________________________________
001019100913
001020100913      //@@method:
001021100913      //@name: CEXCEPTION_getMessageFile
001022100913      //@description: obtiene el messageFile de la excepcion
001023100913      //@return: messageFile de la excepcion
001024100913      //@@
001025100913     p CEXCEPTION_getMessageFile...
001026100913     p                 b                   export
001027100913     d                 pi                  like(exception_type.messageFile)
001028100913
001029100913      /free
001030100913       return exception.messageFile;
001031100913      /end-free
001032100913
001033100913     p CEXCEPTION_getMessageFile...
001034100913     p                 e
001035100913      //_______________________________________________________________________
001036100913
001037100913      //@@method:
001038100913      //@name: CEXCEPTION_getMessageFileName
001039100913      //@description: obtiene el valor de messageFileName de la excepcion
001040100913      //@return: messageFileName de la excepcion
001041100913      //@@
001042100913     p CEXCEPTION_getMessageFileName...
001043100913     p                 b                   export
001044100913     d                 pi                  like(exception_type.messageFileName)
001045100913
001046100913      /free
001047100913       return exception.messageFileName;
001048100913      /end-free
001049100913
001050100913     p CEXCEPTION_getMessageFileName...
001051100913     p                 e
001052100913      //_______________________________________________________________________
001053100913
001054100913      //@@method:
001055100913      //@name: CEXCEPTION_getMessageFileLibrary
001056100913      //@description: obtiene el valor de messageFileLibrary de la excepcion
001057100913      //@return: messageFileLibrary de la excepcion
001058100913      //@@
001059100913     p CEXCEPTION_getMessageFileLibrary...
001060100913     p                 b                   export
001061100913     d                 pi                  like(exception_type.
001062100913     d                                         messageFileLibrary)
001063100913
001064100913      /free
001065100913       return exception.messageFileLibrary;
001066100913      /end-free
001067100913
001068100913     p CEXCEPTION_getMessageFileLibrary...
001069100913     p                 e
001070100913      //_______________________________________________________________________
001071100913
001072100913      //@@method:
001073100913      //@name: CEXCEPTION_getMessageText
001074100913      //@description: obtiene el valor de messageText de la excepcion
001075100913      //@return: messageText de la excepcion
001076100913      //@@
001077100913     p CEXCEPTION_getMessageText...
001078100913     p                 b                   export
001079100913     d                 pi                  like(exception_type.messageText)
001080100913
001081100913      /free
001082100913       return exception.messageText;
001083100913      /end-free
001084100913
001085100913     p CEXCEPTION_getMessageText...
001086100913     p                 e
001087100913      //_______________________________________________________________________
001088100913
001089100913      //@@method:
001090100913      //@name: CEXCEPTION_getMessageText
001091100913      //@description: obtiene el valor de messageText de la excepcion
001092100913      //@return: messageText de la excepcion
001093100913      //@@
001094100913     p CEXCEPTION_getMessageData...
001095100913     p                 b                   export
001096100913     d                 pi                  like(exception_type.messageData)
001097100913
001098100913      /free
001099100913       return exception.messageData;
001100100913      /end-free
001101100913
001102100913     p CEXCEPTION_getMessageData...
001103100913     p                 e
001104100913      //_______________________________________________________________________
001105100913
001106100913      //@@method:
001107100913      //@name: CEXCEPTION_getJobName
001108100913      //@description: obtiene el valor de jobName de la excepcion
001109100913      //@return: jobName de la excepcion
001110100913      //@@
001111100913     p CEXCEPTION_getJobName...
001112100913     p                 b                   export
001113100913     d                 pi                  like(exception_type.jobName)
001114100913
001115100913      /free
001116100913       return exception.jobName;
001117100913      /end-free
001118100913
001119100913     p CEXCEPTION_getJobName...
001120100913     p                 e
001121100913      //_______________________________________________________________________
001122100913
001123100913      //@@method:
001124100913      //@name: CEXCEPTION_getJobName
001125100913      //@description: obtiene el valor de jobName de la excepcion
001126100913      //@return: jobName de la excepcion
001127100913      //@@
001128100913     p CEXCEPTION_getJobNumber...
001129100913     p                 b                   export
001130100913     d                 pi                  like(exception_type.jobNumber)
001131100913
001132100913      /free
001133100913       return exception.jobNumber;
001134100913      /end-free
001135100913
001136100913     p CEXCEPTION_getJobNumber...
001137100913     p                 e
001138100913      //_______________________________________________________________________
001139100913
001140100913      //@@method:
001141100913      //@name: CEXCEPTION_getUserProfile
001142100913      //@description: obtiene el valor de userProfile de la excepcion
001143100913      //@return: userProfile de la excepcion
001144100913      //@@
001145100913     p CEXCEPTION_getUserProfile...
001146100913     p                 b                   export
001147100913     d                 pi                  like(exception_type.userProfile)
001148100913
001149100913      /free
001150100913       return exception.userProfile;
001151100913      /end-free
001152100913
001153100913     p CEXCEPTION_getUserProfile...
001154100913     p                 e
001155100913      //_______________________________________________________________________
001156100913
001157100913      //@@method:
001158100913      //@name: CEXCEPTION_getDate
001159100913      //@description: obtiene el valor de date de la excepcion
001160100913      //@return: date de la excepcion
001161100913      //@@
001162100913     p CEXCEPTION_getDate...
001163100913     p                 b                   export
001164100913     d                 pi                  like(exception_type.date)
001165100913
001166100913      /free
001167100913       return exception.date;
001168100913      /end-free
001169100913
001170100913     p CEXCEPTION_getDate...
001171100913     p                 e
001172100913      //_______________________________________________________________________
001173100913
001174100913      //@@method:
001175100913      //@name: CEXCEPTION_getTime
001176100913      //@description: obtiene el valor de time de la excepcion
001177100913      //@return: time de la excepcion
001178100913      //@@
001179100913     p CEXCEPTION_getTime...
001180100913     p                 b                   export
001181100913     d                 pi                  like(exception_type.time)
001182100913
001183100913      /free
001184100913       return exception.time;
001185100913      /end-free
001186100913
001187100913     p CEXCEPTION_getTime...
001188100913     p                 e
001189100913      //_______________________________________________________________________
001190100913
001191100913      //@@method:
001192100913      //@name: CEXCEPTION_getProgram
001193100913      //@description: obtiene el valor de program de la excepcion
001194100913      //@return: program de la excepcion
001195100913      //@@
001196100913     p CEXCEPTION_getProgram...
001197100913     p                 b                   export
001198100913     d                 pi                  like(exception_type.program)
001199100913
001200100913      /free
001201100913       return exception.program;
001202100913      /end-free
001203100913
001204100913     p CEXCEPTION_getProgram...
001205100913     p                 e
001206100913      //_______________________________________________________________________
001207100913
001208100913      //@@method:
001209100913      //@name: CEXCEPTION_getModule
001210100913      //@description: obtiene el valor del module de la excepcion
001211100913      //@return: module de la excepcion
001212100913      //@@
001213100913     p CEXCEPTION_getModule...
001214100913     p                 b                   export
001215100913     d                 pi                  like(exception_type.module)
001216100913
001217100913      /free
001218100913       return exception.module;
001219100913      /end-free
001220100913
001221100913     p CEXCEPTION_getModule...
001222100913     p                 e
001223100913      //_______________________________________________________________________
001224100913
001225100913      //@@method:
001226100913      //@name: CEXCEPTION_getProcedure
001227100913      //@description: obtiene el valor de procedure de la excepcion
001228100913      //@return: procedure de la excepcion
001229100913      //@@
001230100913     p CEXCEPTION_getProcedure...
001231100913     p                 b                   export
001232100913     d                 pi                  like(exception_type.procedure)
001233100913
001234100913      /free
001235100913       return exception.procedure;
001236100913      /end-free
001237100913
001238100913     p CEXCEPTION_getProcedure...
001239100913     p                 e
001240100913      //_______________________________________________________________________
001241100913
001242100913      //@@method:
001243100913      //@name: CEXCEPTION_getMessageSeverity...
001244100913      //@description: obtiene el valor de messageSeverity de la excepcion
001245100913      //@return: messageSeverity de la excepcion
001246100913      //@@
001247100913     p CEXCEPTION_getMessageSeverity...
001248100913     p                 b                   export
001249100913     d                 pi                  like(exception_type.messageSeverity)
001250100913
001251100913      /free
001252100913       return exception.messageSeverity;
001253100913      /end-free
001254100913
001255100913     p CEXCEPTION_getMessageSeverity...
001256100913     p                 e
001257100913      //_______________________________________________________________________
001258100913
001259100913      //@@method:
001260100913      //@name: CEXCEPTION_getStatementNumber
001261100913      //@description: obtiene el valor de messageSeverity de la excepcion
001262100913      //@return: StatementNumber de la excepcion
001263100913      //@@
001264100913     p CEXCEPTION_getStatementNumber...
001265100913     p                 b                   export
001266100913     d                 pi                  like(exception_type.statementNumber)
001267100913
001268100913      /free
001269100913       return exception.statementNumber;
001270100913      /end-free
001271100913
001272100913     p CEXCEPTION_getStatementNumber...
001273100913     p                 e
