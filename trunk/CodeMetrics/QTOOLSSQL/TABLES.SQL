-- Tables used by Code Metrics
-- Author: Isaac Ramirez Herrera
DROP TABLE QTEMP/WORKLIST;
 
CREATE TABLE QTEMP/WORKLIST AS (                
	SELECT FILES.ATLIB    AS LIBNAME,            
           FILES.ATFILE   AS FILENAME,                      
           MEMBERS.MLNAME AS MEMBERNAME,                  
           MEMBERS.MLSEU2 AS SOURCETYPE,                  
           MEMBERS.MLCHGC || MEMBERS.MLCHGD ||            
           MEMBERS.MLCHGC || MEMBERS.MLCHGD ||            
           MEMBERS.MLCHGT AS CHANGEDATETIME               
      FROM QTEMP/FILES INNER JOIN QTEMP/MEMBERS  
        ON FILES.ATFILE = MEMBERS.MLFILE       
       AND FILES.ATLIB = MEMBERS.MLLIB                 
) WITH NO DATA;
-------------------------------------------------------------------------

drop table MDZAESTCOD; 

create table MDZAESTCOD (
	NOMBRE_MIEMBRO    for column ESTNOMMBR char(10) not null,
	ARCHIVO_FUENTE    for column ESTARCSRC char(10) not null,
	BIBLIOTECA_FUENTE for column ESTBIBSRC char(10) not null,
	TIPO_FUENTE       for column ESTTIPSRC char(10) not null,
	FECHA_ANALISIS    for column ESTFECANA timestamp not null default 
	                             current timestamp,
	LINEAS_BLANCO     for column ESTLINBLA integer not null default 0,
	LINEAS_COMENTARIO for column ESTLINCOM integer not null default 0,
	LINEAS_DIRECTIVAS for column ESTLINDIR integer not null default 0,
	LINEAS_COLUMNARES for column ESTLINCOL integer not null default 0,
	LINEAS_FREE       for column ESTLINFRE integer not null default 0,
	LINEAS_TOTALES    for column ESTLINTOT integer not null default 0,
	OPERADORES_OBSOLE for column ESTOPEOBS integer not null default 0,
	OPERADORES_COMPAT for column ESTOPECMP integer not null default 0,
	VARIABLES_LINEA   for column ESTVARLIN integer not null default 0,
	INDICADORES_CONDI for column ESTINDCON integer not null default 0,
	INDICADORES_RESUL for column ESTINDRES integer not null default 0,
	INDICADORES_VARIA for column ESTINDVAR integer not null default 0,
	FECHA_ULT_MOD_MBR for column ESTFECMOD timestamp not null,
	FECHA_CREACIO_MBR for column ESTFECCRT date not null,
	constraint MDZAESTCOD_PK primary key(ESTNOMMBR, ESTARCSRC, ESTBIBSRC)
);

-------------------------------------------------------------------------

drop table MDZALINHOJ;

create table MDZALINHOJ (
	NOMBRE_MIEMBRO    for column LINNOMMBR char(10) not null,
	ARCHIVO_FUENTE    for column LINARCSRC char(10) not null,
	BIBLIOTECA_FUENTE for column LINBIBSRC char(10) not null,
	TIPO_HOJA         for column LINTIPHOJ char(1)  not null,
	CANTIDAD_LINEAS   for column LINCANLIN integer  not null,
	constraint MDZALINHOJ_PK 
	primary key(LINNOMMBR, LINARCSRC, LINBIBSRC,  LINTIPHOJ)
);

-------------------------------------------------------------------------

create table MDZAOPEDEP (
	NOMBRE_MIEMBRO    for column OPENOMMBR char(10) not null,
	ARCHIVO_FUENTE    for column OPEARCSRC char(10) not null,
	BIBLIOTECA_FUENTE for column OPEBIBSRC char(10) not null,
	NOMBRE_OPERADOR   for column OPENOMOPE varchar(30) not null,
	CONTEO_OPERADOR   for column OPECONOPE integer     not null,
	constraint MDZAOPEDEP_PK 
	primary key(OPENOMMBR, OPEARCSRC, OPEBIBSRC, OPENOMOPE)
);

