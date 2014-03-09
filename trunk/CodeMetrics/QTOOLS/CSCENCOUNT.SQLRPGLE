000100130627     h dftactgrp(*no)
000101130627     h actgrp(*new)
000102130627     h main(CSCENCOUNT_main)
000103130627
000106130627      /////////////////////////////////////////////////////////////////////////
000107130627      // Class attributes
000108130627      /////////////////////////////////////////////////////////////////////////
000109130627
000110130627     d this            ds                  qualified
000111130627     d  joesd                      5000a   inz(*blanks)
000112130627
000113130627      /////////////////////////////////////////////////////////////////////////
000114130627      // Constant declaration
000115130627      /////////////////////////////////////////////////////////////////////////
000116130627
000117130627     d SQL_OK          c                   const('00000')
000118130627     d SCENARIO_KEYWORD...
000119130627     d                 c                   const('ESCENARIO')
000120130627
000121130627      /////////////////////////////////////////////////////////////////////////
000122130627      // Prototype declaration
000123130627      /////////////////////////////////////////////////////////////////////////
000124130627
000125130627     d CSCENCOUNT_main...
000126130627     d                 pr                  extpgm('CSCENCOUNT')
000127130627     d library                       10a   const
000128130627     d file                          10a   const
000129130627
000130130627     d getNext         pr              n
000131130627
000132130627      /////////////////////////////////////////////////////////////////////////
000133130627      // Procedures definition
000134130627      /////////////////////////////////////////////////////////////////////////
000135130627
000136130627     p CSCENCOUNT_main...
000137130627     p                 b
000138130627     d                 pi
000139130627     d library                       10a   const
000140130627     d file                          10a   const
000141130627     d
000142130627     d sqlStament      s            500a   inz(*blanks)
000143130627     d currentScen     s             20a   inz(*blanks)
000144130627     d preScen         s             20a   inz(*blanks)
000145130627     d count           s             10i 0 inz(*zero)
000146130627     d sentenciaSQL    s            800a
000147130627
000148130627      /free
000149130627       sentenciaSQL = 'SELECT JOESD'
000150130627                    + '  FROM ' + %trim(library) + '/' + %trim(file);
000151130627
000152130627       EXEC SQL
000153130627         PREPARE STATEMNT FROM :sentenciaSQL;
000154130627
000155130627       EXEC SQL
000156130627         DECLARE CURSOR_SCEN CURSOR FOR STATEMNT;
000157130627
000158130627       EXEC SQL
000159130627         OPEN CURSOR_SCEN;
000160130627
000161130627       EXEC SQL
000162130627         DELETE FROM OUTFILE;
000163130627
000164130627       dow getNext();
000165130627
000166130627         if (%subst(this.joesd:11:9) = SCENARIO_KEYWORD);
000167130627
000168130627           currentScen = %subst(this.joesd:11);
000169130627
000174130627           if (preScen <> *blanks);
000175130627             if preScen <> currentScen;
000177130627               EXEC SQL
000178130627                 INSERT INTO OUTFILE VALUES(:PRESCEN,:COUNT);
000179130627
000180130627               reset count;
000181130627               preScen = currentScen;
000182130627             else;
000183130627               iter;
000184130627             endif;
000185130627           else;
000186130627             preScen = currentScen;
000187130627           endif;
000188130627
000189130627         else;
000190130627           if currentScen <> *blanks;
000191130627             count += 1;
000192130627           endif;
000193130627
000194130627         endif;
000195130627
000196130627       enddo;
000197130627
000198130627       if (currentScen <> *blanks);
000200130627         EXEC SQL
000201130627            INSERT INTO CSCENCOUNT VALUES(:CURRENTSCEN,:COUNT);
000202130627
000203130627         if sqlStt = SQL_OK;
000204130627           dsply 'No se pudo registrar en archivo de salida';
000205130627           dsply ('Error: ' + sqlStt);
000206130627         endif;
000207130627       else;
000208130627         dsply 'Ningun registro procesado. Verifique parámetros';
000209130627       endif;
000210130627
000211130627       EXEC SQL
000212130627         CLOSE CURSOR_SCEN;
000213130627
000214130627      /end-free
000215130627     p                 e
000216130627      //__________________________________________________________
000217130627
000218130627     p getNext         b
000219130627     d                 pi              n
000220130627      /free
000221130627       EXEC SQL
000222130627         FETCH NEXT FROM CURSOR_SCEN INTO :this.joesd;
000223130627
000224130627       return sqlstt = SQL_OK;
000225130627      /end-free
000226130627     p                 e
