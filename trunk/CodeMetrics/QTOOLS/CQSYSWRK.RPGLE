000101120613     /**
000102120614      *  \brief CQSYSWRK contains utility methods related with QSYS file system
000103120612      *
000104120614      * <p>
000105120614      *  This module contains generic procedures related with the QSYS file
000106120614      *  system. Includes common tasks such as getting lists of objects or
000107120614      *  getting the memberlist of a file.
000108120614      * </p>
000109120614      *
000110120614      * \author Ing Isaac Ramírez Herrera
000111120614      * \date June 14, 2012
000112120614      * \rev 14-06-2012 Isaac Ramírez
000113120612      */
000114120614     h nomain
000116120612     h bnddir('CMQBNDDIR':'CEXCEPBNDD')
000117120611
000118120611      /include cmqasrc/qsrctxt,cuspaceutl
000119120612      /include csystsrc/qsrctxt,cexception
000120120612      /include qtoolstxt,cqsyswrk
000121120616      /include qtoolstxt,cmdznconst
000122120612      /include qtoolstxt,cqsyswrtyp
000123120612      /include qtoolstxt,llist_h
000124120611
000243120612      //////////////////////////////////////////////////////////////////
000244120614      // Prototype declaration
000245120612      //////////////////////////////////////////////////////////////////
000246120612
000247120613     d isSourceFile    pr              n
000249120613     d fileStruct                          likeds(QSYSFile_Type)
000250120613
000261120614      //////////////////////////////////////////////////////////////////
000262120614      // Procedure definition
000263120614      //////////////////////////////////////////////////////////////////
000264120614
000320120612     /**
000321120612      * \brief CQSYSWRK_getAllObjects similar to the command WRKOBJ
000322120612      *
000323120612      * <p>
000324120612      *  this procedure retrieves a list of objects in the same way as
000325120612      *  the WRKOBJ object does;
000326120612      * </p>
000327120612      *
000328120612      * \param name of the object to retrieve data
000329120612      * \param library where the object is located
000330120612      * \param type of the object searched
000331120612      *
000332120612      * \return pointer to a list of objects (llist)
000333120612      */
000334120612     p CQSYSWRK_getAllObjects...
000335120611     p                 b                   export
000336120612     d                 pi              *
000337120611     d   ObjectName                  10a   Const
000338120611     d   LibraryName                 10a   Const
000339120611     d   ObjectType                  10a   Const
000340120611     d
000341120611     d uSpaceName      s             10a   inz('OBJECTLIST')
000342120611     d uSpaceLib       s             10a   inz('QTEMP')
000343120612     d
000344120614     d headerStruc     ds                  likeds(ObjectListHeaderDS)
000345120612     d                                     based(headerStrucPtr)
000346120612     d headerStrucPtr  s               *   inz(*null)
000347120612     d entryStruc      ds                  likeds(OBJL0300)
000348120612     d                                     based(ptrEntryStruc)
000349120611     d ptrEntryStruc   s               *   inz(*null)
000350120612     d
000351120612     d count           s             10i 0
000352120612     d listPtr         s               *   inz(*null)
000353120612     d listNode        ds                  likeds(QSYSObject_Type)
000354120612
000355120611      /free
000356120611       monitor;
000357120612         //This causes that any call to API throws an exception
000358120612         //instead of using the ApiError structure
000359120612         ApiError.BytesAvailable = 0;
000360120612
000361120612         //Create the object list
000362120612         listPtr = list_create();
000363120612
000364120612         //Create the temporal user space
000365120612         CUSPACEUTL_createUserSpace(uSpaceName:uSpaceLib:*blanks
000366120612           :4096:*blanks:'*CHANGE':'*YES');
000367120611
000368120611         //Retrieve the object list with the indicating parameters
000369120612         API_ListObjects(uSpaceName + uSpaceLib:'OBJL0300'
000370120611           :ObjectName + LibraryName:ObjectType:ApiError);
000371120611
000372120611         //Retrieve header information
000373120612         headerStrucPtr = CUSPACEUTL_retrieveUserSpace(uSpaceName:uSpaceLib);
000374120611
000375120612         //Point to the first entry
000376120612         ptrEntryStruc = %addr(headerStruc) + headerStruc.ListOffset;
000377120611
000378120611         for count = 1 to headerStruc.ListCount;
000379120613
000380120613           //Ignore elements with information status A (No info returned) or
000381120613           //L (No info returned, object locked)
000382120613           if entryStruc.InformationStatus <> 'A' and
000383120613              entryStruc.InformationStatus <> 'L';
000384120613
000385120613             clear listNode;
000386120613             listNode.name    = entryStruc.ObjectNameUsed;
000387120613             listNode.library = entryStruc.LibraryUsed;
000388120613             listNode.type    = entryStruc.TypeUsed;
000389120613             list_add(listPtr:%addr(listNode):%size(listNode));
000390120613           endif;
000391120612
000392120612           //Move to the next entry
000393120612           ptrEntryStruc += headerStruc.EntrySize;
000394120611         endfor;
000395120612
000396120612         return listPtr;
000397120611       on-error;
000398120612         CEXCEPTION_catchException();
000399120612         CEXCEPTION_printStackTrace();
000400120611       endmon;
000401120611      /end-free
000402120611
000403120611     p                 e
000404120611      //_______________________________________________________________________
000405120611
000406120614     /**
000407120614      * \brief CQSYSWRK_getAllSourceFiles gets all the source files in library
000408120614      *
000409120614      * <p>
000410120614      *  This procedures retrieves a list of all the source files in a
000411120614      *  given library.
000412120614      * </p>
000413120614      *
000414120614      * \param Name of the library
000415120614      * \return pointer to a llist structure
000416120614      */
000417120613     p CQSYSWRK_getAllSourceFiles...
000418120613     p                 b                   export
000419120613     d                 pi              *
000420120613     d LibraryName                   10a   Const
000421120613     d
000422120613     d uSpaceName      s             10a   inz('OBJECTLIST')
000423120613     d uSpaceLib       s             10a   inz('QTEMP')
000425120614     d headerStruc     ds                  likeds(ObjectListHeaderDS)
000426120613     d                                     based(headerStrucPtr)
000427120613     d headerStrucPtr  s               *   inz(*null)
000428120613     d entryStruc      ds                  likeds(OBJL0300)
000429120613     d                                     based(ptrEntryStruc)
000430120613     d ptrEntryStruc   s               *   inz(*null)
000431120613     d
000432120613     d count           s             10i 0
000433120613     d listPtr         s               *   inz(*null)
000434120613     d listNode        ds                  likeds(QSYSFile_Type)
000435120613     d ObjectName      s             10a   inz('*ALL')
000436120613     d ObjectType      s             10a   inz('*FILE')
000437120613
000438120613      /free
000439120613       monitor;
000440120613         //This causes that any call to API throws an exception
000441120613         //instead of using the ApiError structure
000442120613         ApiError.BytesAvailable = 0;
000443120613
000444120613         //Create the object list
000445120613         listPtr = list_create();
000446120613
000447120613         //Create the temporal user space
000448120613         CUSPACEUTL_createUserSpace(uSpaceName:uSpaceLib:*blanks
000449120613           :4096:*blanks:'*CHANGE':'*YES');
000450120613
000451120613         //Retrieve the object list with the indicating parameters
000452120613         API_ListObjects(uSpaceName + uSpaceLib:'OBJL0300'
000453120613           :ObjectName + LibraryName:ObjectType:ApiError);
000454120613
000455120613         //Retrieve header information
000456120613         headerStrucPtr = CUSPACEUTL_retrieveUserSpace(uSpaceName:uSpaceLib);
000457120613
000458120613         //Point to the first entry
000459120613         ptrEntryStruc = %addr(headerStruc) + headerStruc.ListOffset;
000460120613
000461120613         for count = 1 to headerStruc.ListCount;
000462120613           //Ignore elements with information status A (No info returned) or
000463120613           //L (No info returned, object locked)
000464120613           if entryStruc.InformationStatus <> 'A' and
000465120613              entryStruc.InformationStatus <> 'L';
000466120613             clear listNode;
000467120613             listNode.name    = entryStruc.ObjectNameUsed;
000468120613             listNode.library = entryStruc.LibraryUsed;
000469120613             listNode.type    = entryStruc.TypeUsed;
000470120613
000471120613             if (isSourceFile(listNode));
000472120613               list_add(listPtr:%addr(listNode):%size(listNode));
000473120613             endif;
000474120613           endif;
000475120613
000476120613           //Move to the next entry
000477120613           ptrEntryStruc += headerStruc.EntrySize;
000478120613         endfor;
000479120613
000480120614         //Delete the user space
000481120614         CUSPACEUTL_deleteUserSpace(uSpaceName:uSpaceLib);
000482120614
000483120613         return listPtr;
000484120613       on-error;
000485120613         CEXCEPTION_catchException();
000486120613         CEXCEPTION_printStackTrace();
000487120613       endmon;
000488120613      /end-free
000489120613     p                 e
000490120613      //_______________________________________________________________________
000491120613
000492120614     /**
000493120614      * \brief CQSYSWRK_getAllMembers: retrieve the list of members of a file
000494120614      *
000495120614      * <p>
000496120628      *  This procedures creates a list of all the members of a specific file
000497120628      *  and returns a pointer to the list (llist)
000498120614      * </p>
000499120614      *
000500120614      * \param name of the file
000501120614      * \param library of the file
000502120614      * \return list of members
000503120614      */
000504120614     p CQSYSWRK_getAllMembers...
000505120616     p                 b                   export
000506120614     d                 pi              *
000507120614     d file                          10a   const
000508120614     d library                       10a   const
000509120614     d
000510120614     d memberList      s               *   inz(*NULL)
000511120614     d uSpaceName      s             10a   inz('OBJECTLIST')
000512120614     d uSpaceLib       s             10a   inz('QTEMP')
000513120614     d error           ds                  likeds(ApiError)
000514120614     d headerPtr       s               *   inz(*NULL)
000515120614     d headerDs        ds                  likeds(MemberListHeaderDS)
000516120614     d                                     based(headerPtr)
000517120614     d entryPtr        s               *   inz(*NULL)
000518120614     d entryDs         ds                  likeds(MBRL0200)
000519120614     d                                     based(entryPtr)
000520120614     d memberNode      ds                  likeds(QSYSMember_Type)
000521120616     d count           s             10i 0 inz(0)
000522120616
000523120614      /free
000524120614       monitor;
000525120614         error.BytesAvailable = 0;
000526120614
000527120614         //Create the empty member list
000528120614         memberList = list_create();
000529120614
000530120614         //Create the temporal user space
000531120614         CUSPACEUTL_createUserSpace(uSpaceName:uSpaceLib:*blanks
000532120614           :4096:*blanks:'*CHANGE':'*YES');
000533120614
000534120614         //Fill user space with the list
000535120614         API_ListMembers(uSpacename + uSpaceLib:'MBRL0200':file + library
000536120616            :'*ALL':'0':error);
000537120614
000538120614         //Retrieve header information
000539120614         headerPtr = CUSPACEUTL_retrieveUserSpace(uSpacename:uSpaceLib);
000540120614
000541120614         //Point to the first entry
000542120614         entryPtr = headerPtr + %size(headerDs);
000543120614
000544120614         for count = 1 to headerDS.MemberCount;
000545120614           clear memberNode;
000546120614
000547120614           memberNode.memberName     = entryDs.memberName;
000548120614           memberNode.memberType     = entryDs.sourceType;
000549120625           memberNode.changeDateTime = CQSYSWRK_convertDate(entryDs.changeDate);
000550120614
000551120616           list_add(memberList:%addr(memberNode):%size(memberNode));
000552120614           entryPtr += %size(entryDs);
000553120614         endfor;
000554120614
000555120614         CUSPACEUTL_deleteUserSpace(uSpaceName:uSpaceLib);
000556120614
000557120614         return memberList;
000558120614       on-error;
000559120614         CEXCEPTION_catchException();
000560120614         CEXCEPTION_printStackTrace();
000561120614         return *NULL;
000562120614       endmon;
000563120614
000564120614      /end-free
000565120614     p                 e
000566120614      //_______________________________________________________________________
000567120614
000616120614     /**
000617120614      * \brief isSourceFile indicates if a physical file is a source file
000618120614      *
000619120614      * <p>
000620120614      *  This procedures determines if a physical file is a source physical
000621120614      *  file with members. Any file with no member will no be considered as
000622120614      *  a source file
000623120614      * </p>
000624120614      *
000625120614      * \param structure with the minumun data related to the file to validate
000626120614      * \return  *ON = the indicated file is a source physical file
000627120614      *         *OFF = the indicated file isn't a source file or doesn't
000628120614      *                contains any members
000629120614      */
000630120613     p isSourceFile    b
000631120613     d                 pi              n
000632120613     d fileStruct                          likeds(QSYSFile_Type)
000634120616     d memberInfo      ds                  likeds(QSYSMember_Type)
000635120613
000636120613      /free
000638120616       memberInfo = CQSYSWRK_getMemberInfo(fileStruct.Library
000639120616           :fileStruct.name:'*FIRST');
000645120613
000646120616       return memberInfo.isSourceFile;
000657120613      /end-free
000658120613     p                 e
000659120614      //_______________________________________________________________________
000660120614
000661120628     /**
000662120628      * \brief CQSYSWRK_getMemberInfo retrieves a member information
000663120628      *
000664120628      * <p>
000665120628      *  This procedures retrieves all the relevant data of a member.
000666120628      *  Returns the data in a QSYSMember_Type data structure type
000667120628      * </p>
000668120628      *
000669120628      * \param library of the member
000670120628      * \param file of the member
000671120628      * \param name of the member
000672120628      *
000673120628      * \return QSYSMember_Type structure with the data
000674120628      */
000676120616     p CQSYSWRK_getMemberInfo...
000677120616     p                 b                   export
000678120616     d                 pi                  likeds(QSYSMember_Type)
000679120616     d library                       10a   const
000680120616     d file                          10a   const
000681120616     d member                        10a   const
000682120616     d errorDS         ds                  likeds(ApiError) inz(*likeds)
000683120616     d memberDesc      ds                  likeds(MBRD0100)
000684120616     d memberInfo      ds                  likeds(QSYSMember_Type)
000685120616
000686120616      /free
000687120616       monitor;
000688120616         clear errorDS;
000689120616         clear memberDesc;
000690120616         clear memberInfo;
000691120616
000692120616         //This causes an exception if the API ends with error;
000693120616         errorDS.BytesAvailable = 0;
000694120616
000695120616         API_RetrieveMemberDescription(memberDesc:%size(memberDesc):'MBRD0100'
000696120616            :file + library:member:'0':errorDS);
000697120616
000698120616         memberInfo.library        = memberDesc.libraryName;
000699120616         memberInfo.fileName       = memberDesc.fileName;
000700120616         memberInfo.memberName     = memberDesc.memberName;
000701120616         memberInfo.memberType     = memberDesc.sourceType;
000702120625         memberInfo.changeDateTime = CQSYSWRK_convertDate(
000703120625           memberDesc.lastChange);
000704120616
000705120625         if memberDesc.sourceFile = '1';
000706120616           memberInfo.isSourceFile = *on;
000707120616         else;
000708120616           memberInfo.isSourceFile = *off;
000709120616         endif;
000710120616
000711120616         return memberInfo;
000712120616       on-error;
000713120616         CEXCEPTION_catchException();
000714120616         CEXCEPTION_printStackTrace();
000715120616         CEXCEPTION_throwNewException(ERROR_RETRIEVING_MEMBERINFO
000716120616           :MDZN_MESSAGE_FILE);
000717120616       endmon;
000718120616      /end-free
000719120616     p                 e
000720120616      //_______________________________________________________________________
000721120616
000722120614     /**
000723120625      * \brief CQSYSWRK_convertDate converts a 13-character date in a timestamp
000724120614      *
000725120614      * <p>
000726120614      *  This procedure converts a 13-character date in format system date time
000727120614      *  into a rpg timestamp
000728120614      * </p>
000729120614      *
000730120614      * \param system datetime value to convert
000731120614      * \return converted timestamp
000732120614      */
000733120625     p CQSYSWRK_convertDate...
000734120625     p                 b                   export
000735120614     d                 pi              z
000736120614     d inputDate                     13a   const
000737120614     d
000738120614     d changeTime      s               t
000739120614     d changeDate      s               d
000740120614
000741120614      /free
000742120614       changeDate = %date(%subst(inputDate:1:7):*CYMD0 );
000743120614       changeTime = %time(%subst(inputDate:8:6):*HMS0 );
000744120614
000745120614       return changeDate + changeTime;
000746120614      /end-free
000747120614
000748120614     p                 e
000749120614      //_______________________________________________________________________
