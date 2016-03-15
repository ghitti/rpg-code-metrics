Code metrics can be executed with the command `CODMETRICS`

# Command definition #

<pre>
Source file  . . . . . . . . . .                 Name, *ALL<br>
Library  . . . . . . . . . . .                 Nombre, *CURLIB<br>
Source file member . . . . . . .                 Name, *ALL<br>
Output files library . . . . . .   *CURLIB       *CURLIB, Name<br>
Update or replace outfile  . . .   *UPDATE<br>
Outfile preffix  . . . . . . . .   *DFT          *DFT, Preffix<br>
</pre>

  * **Source file**: name of the source file to be processed by _Code Metrics_. If the option **`*`ALL** is specified, _Code Metrics_ process all the source files available.
  * **Library**: name of the library where the source file is located
  * **Source file member**: indicates the name of the member to be processed by _Code Metrics_. If the option **`*`ALL** is specified, _Code Metrics_ process all the source member of the _Source File_ specified.
  * **Output files library**: specifies the name of the library where the output files are generated
  * **Update or replace outfile**: specifies the action to be taken with the existing data in the _Output files library_
    * `*`REPLACE: all the existing data will be deleted and replace with the last execution
    * `*`UPDATE: all the existing data will be syncronized, meaning that any missing file will be remove from the output file and only changed member since the last execution will be re-calculated.
  * **Outfile preffix**: four letter preffix for the output files

# How to use #
In order to use _Code Metrics_ follow the next steps

## Step 1 ##
Make sure to have the library where you installed _Code Metrics_ in your library list

```
ADDLIBLE DESTINATION_LIB
```

or

```
CHGCURLIB DESTINATION_LIB
```

## Step 2 ##
Execute `CODMETRICS` command specifying the parameters accordingly. For example:

```
CODMETRICS SOURCE(TEST/*ALL) MEMBER(*ALL) OPTION(*REPLACE) PREFFIX(*DFT)
```

## Step 3 ##
Check the generated files:

  * MDZAESTCOD: keeps the primary statistics
  * MDZAOPEDEP: list and count of deprecated operators
  * MDZALINHOJ: count of lines per spec