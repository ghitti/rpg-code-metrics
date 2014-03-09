000100120628     /**
000101120628      * \brief CPARSEFACT: line parser factory
000102120628      *
000103120628      * <p>
000104120628      *  This module creates a new line parser corresponding
000105120628      *  to the souce type of the member to analyze
000107120628      * </p>
000108120628      *
000109120628      * \author Isaaac Ramirez Herrera
000110120628      * \date   May, 2012
000111120628      * \rev    22-05-2012 Isaac Ramirez
000112120628      */
000113120525     h nomain
000114120529     h bnddir('CMDZBNDDIR':'CEXCEPBNDD')
000115120525
000116120525      /include csystsrc/qsrctxt,cexception
000117120525      /include qtoolstxt,crpg3parsr
000118120525      /include qtoolstxt,crpg4parsr
000119120528      /include qtoolstxt,cparsefact
000120120528      /include qtoolstxt,cmdznconst
000121120525
000122120628     /**
000123120628      * \brief CPARSEFACT_getParser: creates a parser for the source type
000124120628      *
000125120628      * <p>
000126120628      *  This procedure creates a line parser for the specific source type.
000127120628      * </p>
000128120628      *
000129120628      * \param type of the file to parse
000130120628      * \return pointer to the parser function
000131120628      */
000132120525     p CPARSEFACT_getParser...
000133120528     p                 b                   export
000134120525     d                 pi              *   procptr
000135120525     d fileType                      10a   const varying
000136120525
000137120525      /free
000138120525       select;
000139120525         when fileType = RPT_MEMBER_TYPE;
000140120525           CRPG3PARSR_createParser();
000141120529           return %paddr(CRPG3PARSR_parseLine);
000142120525
000143120630         when fileType = RPG_MEMBER_TYPE;
000144120630           CRPG3PARSR_createParser();
000145120630           return %paddr(CRPG3PARSR_parseLine);
000146120630
000147120525         when fileType = RPGILE_MEMBER_TYPE;
000148120525           CRPG4PARSR_createParser();
000149120529           return %paddr(CRPG4PARSR_parseLine);
000150120525
000151120808         when fileType = SQLRPGILE_MEMBER_TYPE;
000152120808           CRPG4PARSR_createParser();
000153120808           return %paddr(CRPG4PARSR_parseLine);
000154120808
000155120525         other;
000156120525           CEXCEPTION_throwNewException(UNSUPPORTED_MEMBER_TYPE
000157120525                                       :MDZN_MESSAGE_FILE);
000158120525       endsl;
000159120525      /end-free
000160120525     p                 e
000161120525
