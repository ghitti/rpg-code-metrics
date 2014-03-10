000100120120     h nomain
000104140310     h bnddir('QC2LE':'CMDZBNDDIR')
000105120119
000109140310      /include qtoolstxt,cexception
000110140310      /include qtoolstxt,cregexp
000177120119
000178120626     p CREGEXP_create  b                   export
000179120119     d                 pi                  likeds(regex_T)
000180120120     d pattern                    32768a   value
000181120119     d
000182120119     d
000183120119     d reasonCode      s             10i 0
000184120119     d regularExpression...
000185120119     d                 ds                  likeds(regex_T)
000186120119     d convertedPattern...
000187120119     d                 s                   like(pattern)
000188120119     d patternAddr     s               *
000189120119     d convertedPatternAddr...
000190120119     d                 s               *   inz(%addr(convertedPattern))
000191120119     d tempBuffer      s            100a
000193120119
000194120119      /free
000195120119       monitor;
000196120119         patternAddr = %addr(pattern);
000197120121         convertedPattern =    pattern;
000198120121
000205120119         //Prepare the regular expression and check for errors
000206120121         reasonCode = regcomp(regularExpression
000207120121                    : %subst(convertedPattern : 1
000208120121                            : %len(%trimr(convertedPattern)))
000209120121                    : REG_EXTENDED);
000210120119
000211120119         if (reasonCode <> 0);
000212120119           regerror(reasonCode : regularExpression : %addr(tempBuffer)
000213120119                               : %size(tempBuffer));
000214120119
000215120119           //The expression had an error
000216120119           CEXCEPTION_throwNewException('CPF9898' : 'QCPFMSG' : 'Error while ' +
000217120120               'compiling the regular expression. RC: ' + %char(reasonCode) +
000218120120               ':' + tempBuffer);
000219120119         else;
000220120119           return regularExpression;
000221120119         endif;
000222120119
000223120119       on-error;
000224120119         CEXCEPTION_catchException();
000225120119         CEXCEPTION_printStackTrace();
000226120119         CEXCEPTION_throwNewException('CPF9898' : 'QCPFMSG' : 'Error while ' +
000227120119               'compiling the regular expression');
000228120119       endmon;
000229120119      /end-free
000230120119
000231120119     p                 e
000232120119      //_______________________________________________________________________
000233120119
000234120626     p CREGEXP_isMatch...
000235120626     p                 b                   export
000236120119     d                 pi              n
000237120119     d
000238120119     d dataToCompare              32768a   varying const
000239120119     d regularExp                          likeds(regex_T) value
000240120119     d matchInfo       ds                  likeds(regMatch_T) Dim(2)
000241120119     d reasonCode      s             10i 0
000242120119     d tempBuffer      s            100a
000243120119
000244120119      /free
000245120119       monitor;
000246120121         reasonCode = regexec(regularExp : %trimr(dataToCompare)
000247120121                             : 1 : matchInfo : 0);
000248120119
000249120121         if (reasonCode = 0);
000250120119           return *on;
000251120119         else;
000252120119           if (reasonCode = REG_NOMATCH);
000253120119             return *off;
000254120119           else;
000255120119             //An error ocurred
000256120119             regerror(reasonCode : regularExp : %addr(tempBuffer)
000257120119                     : %size(tempBuffer));
000258120119
000259120119             CEXCEPTION_throwNewException('CPF9898' : 'QCPFMSG' :
000260120119                'Error while compiling the regular expression. RC: ' +
000261120120                %char(reasonCode) + ':' + tempBuffer);
000262120119           endif;
000263120119         endif;
000264120119       on-error;
000265120119         CEXCEPTION_catchException();
000266120119         CEXCEPTION_printStackTrace();
000267120119         CEXCEPTION_throwNewException('CPF9898' : 'QCPFMSG' : 'Error while ' +
000268120119               'comparing the regular expression');
000269120119       endmon;
000270120119      /end-free
000271120119
000272120119     p                 e
000273120119      //_______________________________________________________________________
000274120119
000275120626     p CREGEXP_destroy...
000276120626     p                 b                   export
000277120119     d                 pi
000278120119     d regularExp                          likeds(regex_T) value
000279120119
000280120119      /free
000281120119       monitor;
000282120119         regfree(regularExp);
000283120119
000284120119       on-error;
000285120119         CEXCEPTION_catchException();
000286120119         CEXCEPTION_printStackTrace();
000287120119       endmon;
000288120119      /end-free
000289120119     p                 e
000290120628      //_______________________________________________________________________
000291120628
000292120628     p CREGEXP_convertCCSID...
000293120628     p                 b                   export
000294120628     d                 pi
000301120628     d   inputBuffer                   *   const
000302120628     d   outputBuffer                  *   const
000303120628     d   fromCcsid                   10i 0 value
000304120628     d   toCcsid                     10i 0 value
000305120628     d   buffersLen                  10u 0 value
000306120628
000307120628     d iconv_t         ds                  based(prototype_only)
000308120628     d   return_value                10i 0
000309120628     d   cd                          10i 0 dim(12)
000310120628      *
000311120628     d from            ds                  qualified
000312120628     d  CCSID                        10i 0 inz(0)
000313120628     d  ConvAlt                      10i 0 inz(0)
000314120628     d  SubsAlt                      10i 0 inz(0)
000315120628     d  ShiftAlt                     10i 0 inz(1)
000316120628     d  InpLenOp                     10i 0 inz(0)
000317120628     d  ErrorOpt                     10i 0 inz(1)
000318120628     d  Reserved                      8a   inz(*ALLx'00')
000319120628      *
000320120628     d to              ds                  qualified
000321120628     d  CCSID                        10i 0 inz(0)
000322120628     d  ConvAlt                      10i 0 inz(0)
000323120628     d  SubsAlt                      10i 0 inz(0)
000324120628     d  ShiftAlt                     10i 0 inz(1)
000325120628     d  InpLenOp                     10i 0 inz(0)
000326120628     d  ErrorOpt                     10i 0 inz(1)
000327120628     d  Reserved                      8a   inz(*ALLx'00')
000328120628      *
000329120628     d QtqIconvOpen    pr                  extproc('QtqIconvOpen')
000330120628     d                                     like(iconv_t)
000331120628     d    tocode                           like(to) const
000332120628     d    fromcode                         like(from) const
000333120628      *
000334120628     d iconv           pr            10i 0 extproc('iconv')
000335120628     d   cd                                like(iconv_t) value
000336120628     d   inbuf                         *   const
000337120628     d   inbytesleft                 10u 0
000338120628     d   outbuf                        *   const
000339120628     d   outbytesleft                10u 0
000340120628      *
000341120628     d iconv_close     pr            10i 0 extproc('iconv_close')
000342120628     d   cd                                like(iconv_t) value
000343120628      *
000344120628     d hInconv         ds                  likeds(iconv_t)
000345120628     d pInBuf          s               *   inz
000346120628     d pOutBuf         s               *   inz
000347120628      *
000348120628     d DIGITS          c                   const(%len(to.ccsid))
000349120628     d DECPOS          c                   const(%decpos(to.ccsid))
000350120628
000351120628      /free
000352120628
000353120628         from.ccsid = fromCcsid;
000354120628         to.ccsid = toCcsid;
000355120628
000356120628         hInconv = QtqIconvOpen(to:from);
000357120628
000358120628         iconv(hInconv:inputBuffer:buffersLen:outputBuffer:buffersLen);
000359120628
000360120628         iconv_close(hInconv);
000361120628
000362120628      /end-free
000363120628
000366120628     p                 e
000367120628
