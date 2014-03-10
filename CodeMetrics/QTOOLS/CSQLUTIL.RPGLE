000100120628     /**
000101120628      * \brief CSQLUTIL: Utility procedures for sql
000102120628      *
000103120628      * <p>
000104120628      *  This module contains utility methods for embedded sql
000105120628      *  handling
000107120628      * </p>
000108120628      *
000109120628      * \author Isaaac Ramirez Herrera
000110120628      * \date   May, 2012
000111120628      * \rev    28-06-2012 Isaac Ramirez
000112120628      */
000113120518     h nomain
000114140310     h bnddir('CMDZBNDDIR')
000116120518
000117140310      /include qtoolstxt,cexception
000118120518      /include qtoolstxt,csqlutil
000119120518
000120120518     /**
000121120518      * \brief CSQLUTIL_checkSQLState: Checks the status of a sql statement
000122120518      *
000123120518      * <p>
000124120518      *  This procedure checks the sql state after the execution of an sql
000125120518      *  statement
000126120518      * </p>
000127120518      */
000128120518     p CSQLUTIL_checkSQLState...
000129120518     p                 b                   export
000130120518     d                 pi              n
000131120518     d StateCode                      5a   const
000132120518     d Area                          50a   const
000133120518     d exceptionMsg    s            255a   varying
000134120518
000135120518      /free
000136120518       if StateCode = *blanks;
000137120518         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'
000138120518                                     :'StateCode cannot be blank');
000139120518       endif;
000140120518
000141120518       select;
000142120518         when %subst(StateCode:1:2) = '00' or %subst(StateCode:1:2) = '01';
000143120518           return *on;
000144120518         when %subst(StateCode:1:2) = '02';
000145120518           return *off;
000146120518         other;
000147120518           exceptionMsg = 'SQL Statement at area ' +  %trim(Area)
000148120518                        + ' failed with SQLSTT=' +  StateCode;
000149120518
000150120518           CEXCEPTION_throwNewException('CPF9898':'QCPFMSG':exceptionMsg);
000151120518       endsl;
000152120518
000153120518      /end-free
000154120518
000155120518     p                 e
000156120518      //_______________________________________________________________________
000157120518
