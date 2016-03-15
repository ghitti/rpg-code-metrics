In order to successfully install **Code Metrics** in an _IBM i System_, please follow the next steps:

## Step 1 ##
Do an _SVN Checkout_ of the source code with the following command:

```
svn checkout http://rpg-code-metrics.googlecode.com/svn/trunk/ rpg-code-metrics-read-only
```

This step requires that you install an SVN client on your PC, like _tortoiseSVN_ or similar. The _SVN checkout_ will download two folders:

  * CodeMetrics
  * resources

The folder CodeMetrics contains an iProject, which you can open directly on _WDSC_ or _RDi_. When the project is loaded, you can push it to the destination _IBM i_ system.

## Step 2 ##
Compile the installation CL program:

```
CHGCURLIB DESTINATION_LIB
```

```
CRTBNDCL PGM(BUILDMETRI) SRCFILE(QTOOLS) SRCMBR(BUILDMETRI) REPLACE(*YES) OPTION(*EVENTF) DBGVIEW(*SOURCE)
```

## Step 3 ##
Run the installation program specifying the destination library (where you want to create Code Metrics)

```
CALL BUILDMETRI DESTINATION_LIB
```

This command will compile all the required objects and tables.

## Step 4 ##
Create CODMETXMLP data area on the destination library:

```
CRTDTAARA DTAARA(DESTINATION_LIB/CODMETXMLP) TYPE(*CHAR) LEN(2000)
```

## Step 5 ##
Go to the _resources_ folder (which you downloaded on Step 1) and upload the file `codeMetricsConf.xml` to any folder on the IFS for example, `/CodeMetrics/codeMetricsConf.xml`.

Set the path of the XML file on the data area `CODMETXMLP` with the command:

```
CHGDTAARA DTAARA(LIBIRH_BK/CODMETXMLP) VALUE(PATH_OF_XML_FILE)
```