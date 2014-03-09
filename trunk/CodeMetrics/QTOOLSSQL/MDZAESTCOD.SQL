000100120607<%DB2%>
000101120607<%DEFINICION%>
000102120607
000104120831create table MDZAESTCOD (
000107120607  NOMBRE_MIEMBRO    for column ESTNOMMBR char(10) not null,
000108120607  ARCHIVO_FUENTE    for column ESTARCSRC char(10) not null,
000109120607  BIBLIOTECA_FUENTE for column ESTBIBSRC char(10) not null,
000110120607  TIPO_FUENTE       for column ESTTIPSRC char(10) not null,
000111120607  FECHA_ANALISIS    for column ESTFECANA timestamp not null default current timestamp,
000112120607  LINEAS_BLANCO     for column ESTLINBLA integer not null default 0,
000113120607  LINEAS_COMENTARIO for column ESTLINCOM integer not null default 0,
000114120813  LINEAS_DIRECTIVAS for column ESTLINDIR integer not null default 0,
000115120607  LINEAS_COLUMNARES for column ESTLINCOL integer not null default 0,
000116120607  LINEAS_FREE       for column ESTLINFRE integer not null default 0,
000117120607  LINEAS_TOTALES    for column ESTLINTOT integer not null default 0,
000118120607  OPERADORES_OBSOLE for column ESTOPEOBS integer not null default 0,
000119120607  OPERADORES_COMPAT for column ESTOPECMP integer not null default 0,
000120120607  VARIABLES_LINEA   for column ESTVARLIN integer not null default 0,
000121120607  INDICADORES_CONDI for column ESTINDCON integer not null default 0,
000122120607  INDICADORES_RESUL for column ESTINDRES integer not null default 0,
000123120607  INDICADORES_VARIA for column ESTINDVAR integer not null default 0,
000124120829  FECHA_ULT_MOD_MBR for column ESTFECMOD timestamp not null,
000125120829  FECHA_CREACIO_MBR for column ESTFECCRT date not null,
000126120623  constraint MDZAESTCOD_PK primary key(ESTNOMMBR, ESTARCSRC, ESTBIBSRC)
000127120607);
000128120607
000133120607<%ESTEPASE%>
000134120607
000135120607<%/ESTEPASE%>
000136120607<%/DB2%>
