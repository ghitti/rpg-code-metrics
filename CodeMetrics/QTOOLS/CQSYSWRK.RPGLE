000101120613     /**
000102120614      *  \brief CQSYSWRK contains utility methods related with QSYS file system
000103120612      *
000104120614      * <p>
000105120614      *  This module contains generic procedures related with the QSYS file
000106140310      *  system.
000108120614      * </p>
000109120614      *
000110120614      * \author Ing Isaac Ramírez Herrera
000111120614      * \date June 14, 2012
000112120614      * \rev 14-06-2012 Isaac Ramírez
000113120612      */
000114120614     h nomain
000116140310     h bnddir('CMDZBNDDIR')
000117120611
000120120612      /include qtoolstxt,cqsyswrk
000246120612
000261120614      //////////////////////////////////////////////////////////////////
000262120614      // Procedure definition
000263120614      //////////////////////////////////////////////////////////////////
000264120614
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
