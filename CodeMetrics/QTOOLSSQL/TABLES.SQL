-- Tables used by Code Metrics
-- Author: Isaac Ramirez Herrera
DROP TABLE QTEMP/WORKLIST;
 
CREATE TABLE QTEMP/WORKLIST AS (                
	SELECT FILES.ATLIB    AS LIBNAME,            
           FILES.ATFILE   AS FILENAME,                      
           MEMBERS.MLNAME AS MEMBERNAME,                  
           MEMBERS.MLSEU2 AS SOURCETYPE,                  
           MEMBERS.MLCHGC || MEMBERS.MLCHGD ||          
               MEMBERS.MLCHGT AS CHANGEDATETIME,          
           MEMBERS.MLCCEN || MEMBERS.MLCDAT AS CREATIONDATE                          
      FROM QTEMP/FILES INNER JOIN QTEMP/MEMBERS  
        ON FILES.ATFILE = MEMBERS.MLFILE       
       AND FILES.ATLIB = MEMBERS.MLLIB                 
) WITH NO DATA;
-------------------------------------------------------------------------

drop table MDZAESTCOD; 

create table MDZAESTCOD (
	MEMBER_NAME       		 for column ESTNOMMBR 
							 char(10) not null,
	SOURCE_FILE       		 for column ESTARCSRC 
							 char(10) not null,
	SOURCE_LIBRARY    		 for column ESTBIBSRC 
							 char(10) not null,
	SOURCE_TYPE       		 for column ESTTIPSRC 
							 char(10) not null,
	EXECUTION_DATE    		 for column ESTFECANA  
	                         timestamp not null default current timestamp,
	BLANK_LINES       		 for column ESTLINBLA 
							 integer not null default 0,
	COMMENT_LINES     		 for column ESTLINCOM 
						 	 integer not null default 0,
	PREPROCESSOR_LINES		 for column ESTLINDIR 
							 integer not null default 0,
	FIXED_LINES              for column ESTLINCOL 
	    					 integer not null default 0,
	FREE_LINES               for column ESTLINFRE  
	                         integer not null default 0,
	TOTAL_LINES       		 for column ESTLINTOT 
							 integer not null default 0,
	OBSOLETE_OPERATORS       for column ESTOPEOBS 
						     integer not null default 0,
	COMPATIBLE_OPERATORS     for column ESTOPECMP 
	                         integer not null default 0,
	VARIABLES_LINEA          for column ESTVARLIN 
	                         integer not null default 0,
	CONDITIONAL_INDICATORS   for column ESTINDCON 
	                         integer not null default 0,
	RESULTING_INDICATORS     for column ESTINDRES 
						     integer not null default 0,
	VARIABLE_INDICATORS      for column ESTINDVAR 
							 integer not null default 0,
	MEMBER_LAST_MODIFICATION for column ESTFECMOD 
							 timestamp not null,
	MEMBER_CREATION          for column ESTFECCRT 
							 date not null,
	constraint MDZAESTCOD_PK primary key(ESTNOMMBR, ESTARCSRC, ESTBIBSRC)
);

-------------------------------------------------------------------------

drop table MDZALINHOJ;

create table MDZALINHOJ (
	MEMBER_NAME       for column LINNOMMBR char(10) not null,
	SOURCE_FILE       for column LINARCSRC char(10) not null,
	SOURCE_LIBRARY    for column LINBIBSRC char(10) not null,
	SPEC_TYPE         for column LINTIPHOJ char(1)  not null,
	LINE_COUNT        for column LINCANLIN integer  not null,
	constraint MDZALINHOJ_PK 
	primary key(LINNOMMBR, LINARCSRC, LINBIBSRC,  LINTIPHOJ)
);

-------------------------------------------------------------------------

drop table MDZAOPEDEP;

create table MDZAOPEDEP (
	MEMBER_NAME       for column OPENOMMBR char(10) not null,
	SOURCE_FILE       for column OPEARCSRC char(10) not null,
	SOURCE_LIBRARY    for column OPEBIBSRC char(10) not null,
	OPERATOR_NAME     for column OPENOMOPE varchar(30) not null,
	OPERATOR_COUNT    for column OPECONOPE integer     not null,
	constraint MDZAOPEDEP_PK 
	primary key(OPENOMMBR, OPEARCSRC, OPEBIBSRC, OPENOMOPE)
);

