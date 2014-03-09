000100120628     h nomain
000101080827
000102120628      /include qtoolstxt,cstringutl
000103080827
000115120628     p CSTRINGUTL_parse...
000116120628     p                 b                   export
000117120628     d                 pi         32767a   varying
000118120628     d  string@                        *   const options(*string)
000119120628     d  parm1@                         *   const options(*string:*nopass)
000120120628     d  parm2@                         *   const options(*string:*nopass)
000121120628     d  parm3@                         *   const options(*string:*nopass)
000122120628     d  parm4@                         *   const options(*string:*nopass)
000123120628     d  parm5@                         *   const options(*string:*nopass)
000124120628     d  parm6@                         *   const options(*string:*nopass)
000125120628     d  parm7@                         *   const options(*string:*nopass)
000126120628     d  parm8@                         *   const options(*string:*nopass)
000127120628     d  parm9@                         *   const options(*string:*nopass)
000128120628     d
000129120628     d Parm@           s               *   dim(9)
000130120628     d ParmStr         s          32767a   inz varying
000131120628     d String          s          32767a   inz varying
000132120628     d Pos             s             10i 0 inz
000133120628     d ParmNbrC        ds
000134120628     d   ParmNbr                      1s 0 inz
000135120628
000136080827      /free
000137080827        if %parms > 1;
000138080827         Parm@( 1 ) = parm1@;
000139080827         if %parms > 2;
000140080827          Parm@( 2 ) = parm2@;
000141080827          if %parms > 3;
000142080827           Parm@( 3 ) = parm3@;
000143080827           if %parms > 4;
000144080827            Parm@( 4 ) = parm4@;
000145080827            if %parms > 5;
000146080827             Parm@( 5 ) = parm5@;
000147080827             if %parms > 6;
000148080827              Parm@( 6 ) = parm6@;
000149080827              if %parms > 7;
000150080827               Parm@( 7 ) = parm7@;
000151080827                if %parms > 8;
000152080827                 Parm@( 8 ) = parm8@;
000153080827                 if %parms > 9;
000154080827                  Parm@( 9 ) = parm9@;
000155080827                 endif;
000156080827                endif;
000157080827               endif;
000158080827              endif;
000159080827             endif;
000160080827            endif;
000161080827           endif;
000162080827          endif;
000163080827         endif;
000164080827
000165080827        String = %str( String@ );
000166080827        if %len( String ) = 0;
000167080827          return String;
000168080827        endif;
000169080827
000170080827        Pos = %scan( '&' : String );
000171080827        dow Pos > 0;
000172080827          ParmNbrC = %subst( String : Pos + 1 : 1 );
000173080827          if ParmNbrC >= '1' and ParmNbrC <= '9';
000174080827            if Parm@( ParmNbr ) <> *null;
000175080827              ParmStr = %str( Parm@( ParmNbr ) );
000176080827              String = %replace( ParmStr : String : Pos : 2 );
000177080827              Pos = Pos + %len( ParmStr );
000178080827            endif;
000179080827          endif;
000180080827          if Pos < %len( String );
000181080827            Pos = %scan( '&' : String : Pos + 1 );
000182080827          else;
000183080827            leave;
000184080827          endif;
000185080827        enddo;
000186080827
000187080827        return String;
000188080827
000189080827        begsr *pssr;
000190080827          return String;
000191080827        endsr;
000192080827
000193080827      /end-free
000194120628     p                 e
000195120628
