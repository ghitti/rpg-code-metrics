000100120626      *------------------------------------------------------------------------
000101120626      *
000102120626      * Copyright (c) 2008-2010 Mihael Schmidt
000103120626      * All rights reserved.
000104120626      *
000105120626      * This file is part of the LMAP service program.
000106120626      *
000107120626      * LMAP is free software: you can redistribute it and/or modify it under
000108120626      * the terms of the GNU Lesser General Public License as published by
000109120626      * the Free Software Foundation, either version 3 of the License, or
000110120626      * any later version.
000111120626      *
000112120626      * LMAP is distributed in the hope that it will be useful,
000113120626      * but WITHOUT ANY WARRANTY; without even the implied warranty of
000114120626      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
000115120626      * GNU Lesser General Public License for more details.
000116120626      *
000117120626      * You should have received a copy of the GNU Lesser General Public
000119120626      * License along with LMAP.  If not, see http://www.gnu.org/licenses/.
000120120626      *
000121120626      *------------------------------------------------------------------------
000122120626
000123120626     H nomain
000124120626     H bnddir('QC2LE')
000125120626     H option(*srcstmt)
000126120626     H copyright('Copyright (c) 2008-2010 Mihael Schmidt. All rights reserved.')
000127120626
000132140310      /copy qtoolstxt,LMAP_H
000133140310      /copy qtoolstxt,LMAP_INT_H
000134140310      /copy qtoolstxt,CEEAPI_H
000135140310      /copy qtoolstxt,LIBC_H
000136120626
000137120626     /**
000138120626      *  \brief Create map
000139120626      *
000140120626      * Creates a map. A header is generated for the map and the pointer to
000141120626      * the map returned.
000142120626      *
000143120626      * <br><br>
000144120626      *
000145120626      * A map must be disposed via the procedure <em>dispose</em> to free all
000146120626      * allocated memory.
000147120626      *
000148120626      * \author Mihael Schmidt
000149120626      * \date   01.06.2008
000150120626      *
000151120626      * \return Map pointer
000152120626      */
000153120626     P lmap_create     B                   export
000154120626     D                 PI              *
000155120626      *
000156120626     D mapPtr          S               *
000157120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000158120626     D heapId          S             10I 0
000159120626      /free
000160120626       cee_createHeap(heapId : *omit : *omit : *omit : *omit);
000161120626
000162120626       // allocate memory for list header
000163120626       cee_getStorage(heapId : %size(tmpl_header) : mapPtr : *omit);
000164120626
000165120626       header.id = LMAP_ID;
000166120626       header.heapId = heapId;
000167120626       header.size = 0;
000168120626       header.firstEntry = *null;
000169120626       header.lastEntry = *null;
000170120626       header.iteration = -1;
000171120626       header.iterNextEntry = *null;
000172120626       header.iterPrevEntry = *null;
000173120626
000174120626       return mapPtr;
000175120626      /end-free
000176120626     P                 E
000177120626
000178120626     /**
000179120626      * \brief Dispose map
000180120626      *
000181120626      * The memory for the whole map is released
000182120626      * (deallocated). The map pointer is set to *null;
000183120626      *
000184120626      * \author Mihael Schmidt
000185120626      * \date   01.06.2008
000186120626      *
000187120626      * \param Map pointer
000188120626      */
000189120626     P lmap_dispose    B                   export
000190120626     D                 PI
000191120626     D   mapPtr                        *
000192120626      *
000193120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000194120626      /free
000195120626       if (mapPtr <> *null);
000196120626        if (isLinkedMapImpl(mapPtr));
000197120626            cee_discardHeap(header.heapId : *omit);
000198120626            mapPtr = *null;
000199120626        endif;
000200120626       endif;
000201120626      /end-free
000202120626     P                 E
000203120626
000204120626     /**
000205120626      * \brief Add map entry
000206120626      *
000207120626      * Adds an entry to the map. If the key already exists in the map
000208120626      * the old value will be replaced by the new one.
000209120626      *
000210120626      * \author Mihael Schmidt
000211120626      * \date   01.06.2008
000212120626      *
000213120626      * \param Map pointer
000214120626      * \param Pointer to the key
000215120626      * \param Key length (in byte)
000216120626      * \param Pointer to the value
000217120626      * \param Value length (in byte)
000218120626      */
000219120626     P lmap_add        B                   export
000220120626     D                 PI
000221120626     D   mapPtr                        *   const
000222120626     D   keyPtr                        *   const
000223120626     D   keyLength                   10U 0 const
000224120626     D   valuePtr                      *   const
000225120626     D   valueLength                 10U 0 const
000226120626      *
000227120626     D header          DS                  likeds(tmpl_header)  based(mapPtr)
000228120626     D prevEntryPtr    S               *
000229120626     D prevEntry       DS                  likeds(tmpl_entry)
000230120626     D                                     based(prevEntryPtr)
000231120626     D newEntryPtr     S               *
000232120626     D newEntry        DS                  likeds(tmpl_entry)
000233120626     D                                     based(newEntryPtr)
000234120626     D tmpPtr          S               *
000235120626     D keyExists       S               N   inz(*off)
000236120626      /free
000237120626       if (isLinkedMapImpl(mapPtr));
000238120626
000239120626         // check if key is in already in the map
000240120626         newEntryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
000241120626         if (newEntryPtr = *null);
000242120626           keyExists = *off;
000243120626         else;
000244120626           keyExists = *on;
000245120626         endif;
000246120626
000247120626         if (not keyExists);    // entry not in map
000248120626           // create new entry
000249120626           cee_getStorage(header.heapId:%size(tmpl_entry):newEntryPtr:*omit);
000250120626           newEntry.keyLength = keyLength + 1;      // +1 for the null byte
000251120626           cee_getStorage(header.heapId:keyLength+1:newEntry.key:*omit);
000252120626           newEntry.valueLength = valueLength + 1;     // +1 for the null byte
000253120626           cee_getStorage(header.heapId : valueLength + 1 :
000254120626                          newEntry.value : *omit);     // +1 for the null byte
000255120626           newEntry.next = *null;
000256120626           newEntry.prev = *null;
000257120626         else;
000258120626           // entry needs to be resized
000259120626           newEntry.keyLength = keyLength + 1;
000260120626           cee_reallocateStorage(newEntry.key : keyLength + 1 : *omit); // +1 for the null byte
000261120626           newEntry.valueLength = valueLength + 1;
000262120626           cee_reallocateStorage(newEntry.value : valueLength + 1 : *omit);
000263120626         endif;
000264120626
000265120626         // copy value to the list entry
000266120626         memcpy(newEntry.key : keyPtr : keyLength);
000267120626         memcpy(newEntry.value : valuePtr : valueLength);
000268120626
000269120626         // set null to the last byte
000270120626         memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
000271120626         memcpy(newEntry.value + valueLength : %addr(hexNull) : 1);
000272120626
000273120626         // update header
000274120626         if (not keyExists);
000275120626           header.size += 1;
000276120626           if (header.firstEntry = *null);
000277120626             header.firstEntry = newEntryPtr;
000278120626           else;
000279120626             prevEntryPtr = header.lastEntry;
000280120626             prevEntry.next = newEntryPtr;
000281120626             newEntry.prev = prevEntryPtr;
000282120626           endif;
000283120626
000284120626           header.lastEntry = newEntryPtr;
000285120626         endif;
000286120626       endif;
000287120626      /end-free
000288120626     P                 E
000289120626
000290120626
000291120626     /**
000292120626      * \brief Add all entries
000293120626      *
000294120626      * Adds all entries from an existing map.
000295120626      *
000296120626      * <br><br>
000297120626      *
000298120626      * \author Mihael Schmidt
000299120626      * \date   01.06.2008
000300120626      *
000301120626      * \param Pointer to destination map
000302120626      * \param Pointer to source map
000303120626      */
000304120626     P lmap_addAll     B                   export
000305120626     D                 PI
000306120626     D   mapPtr                        *   const
000307120626     D   srcMapPtr                     *   const
000308120626      *
000309120626     D header          DS                  likeds(tmpl_header) based(srcMapPtr)
000310120626     D entryPtr        S               *
000311120626     D entry           DS                  likeds(tmpl_entry)
000312120626     D                                     based(entryPtr)
000313120626      /free
000314120626       if (isLinkedMapImpl(mapPtr) and
000315120626           isLinkedMapImpl(srcMapPtr));
000316120626          entryPtr = header.firstEntry;
000317120626         dow (entryPtr <> *null);
000318120626            lmap_add(mapPtr : entry.key : entry.keylength - 1 :
000319120626                              entry.value : entry.valueLength -1);
000320120626
000321120626            entryPtr = entry.next;
000322120626         enddo;
000323120626       endif;
000324120626      /end-free
000325120626     P                 E
000326120626
000327120626
000328120626     /**
000329120626      * \brief Remove entry
000330120626      *
000331120626      * Removes an entry from the map. No action will be taken if the key
000332120626      * does not exist in the map.
000333120626      *
000334120626      * \author Mihael Schmidt
000335120626      * \date   01.06.2008
000336120626      *
000337120626      * \param Map pointer
000338120626      * \param Pointer to the key
000339120626      * \param Key length (in byte)
000340120626      */
000341120626     P lmap_remove     B                   export
000342120626     D                 PI
000343120626     D   mapPtr                        *   const
000344120626     D   keyPtr                        *   const
000345120626     D   keyLength                   10U 0 const
000346120626      *
000347120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000348120626     D ptr             S               *
000349120626     D entry           DS                  likeds(tmpl_entry) based(ptr)
000350120626     D nextEntryPtr    S               *
000351120626     D nextEntry       DS                  likeds(tmpl_entry)
000352120626     D                                     based(nextEntryPtr)
000353120626     D prevEntryPtr    S               *
000354120626     D prevEntry       DS                  likeds(tmpl_entry)
000355120626     D                                     based(prevEntryPtr)
000356120626      /free
000357120626       if (isLinkedMapImpl(mapPtr));
000358120626          ptr = getMapEntry(mapPtr : keyPtr : keyLength);
000359120626
000360120626          // check if map entry is found
000361120626         if (ptr <> *null);
000362120626
000363120626            // update header
000364120626           if (header.firstEntry = ptr);
000365120626              header.firstEntry = entry.next;
000366120626           endif;
000367120626           if (header.lastEntry = ptr);
000368120626              header.lastEntry = entry.prev;
000369120626           endif;
000370120626            header.size -= 1;
000371120626
000372120626            // update neighbours
000373120626           if (entry.prev <> *null);
000374120626              prevEntryPtr = entry.prev;
000375120626              prevEntry.next = entry.next;
000376120626           endif;
000377120626           if (entry.next <> *null);
000378120626              nextEntryPtr = entry.next;
000379120626              nextEntry.prev = entry.prev;
000380120626           endif;
000381120626
000382120626            // release memory
000383120626            cee_freeStorage(entry.key : *omit);
000384120626            cee_freeStorage(entry.value : *omit);
000385120626            cee_freeStorage(ptr : *omit);
000386120626         endif;
000387120626
000388120626       endif;
000389120626      /end-free
000390120626     P                 E
000391120626
000392120626
000393120626     /**
000394120626      * \brief Clear map
000395120626      *
000396120626      * Removes all entries from the map.
000397120626      *
000398120626      * \author Mihael Schmidt
000399120626      * \date   01.06.2008
000400120626      *
000401120626      * \param Map pointer
000402120626      *
000403120626      */
000404120626     P lmap_clear      B                   export
000405120626     D                 PI
000406120626     D   mapPtr                        *   const
000407120626      *
000408120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000409120626     D tmpPtr          S               *
000410120626     D ptr             S               *
000411120626     D entry           DS                  likeds(tmpl_entry) based(ptr)
000412120626      /free
000413120626       if (isLinkedMapImpl(mapPtr));
000414120626
000415120626          ptr = header.lastEntry;
000416120626         dow (ptr <> *null);
000417120626            tmpPtr = entry.prev;
000418120626            cee_freeStorage(entry.key : *omit);
000419120626            cee_freeStorage(entry.value : *omit);
000420120626            cee_freeStorage(ptr : *omit);
000421120626            ptr = tmpPtr;
000422120626         enddo;
000423120626
000424120626          // update header
000425120626          header.size = 0;
000426120626          header.firstEntry = *null;
000427120626          header.lastEntry = *null;
000428120626          header.iteration = -1;
000429120626          header.iterNextEntry = *null;
000430120626          header.iterPrevEntry = *null;
000431120626       endif;
000432120626      /end-free
000433120626     P                 E
000434120626
000435120626
000436120626     /**
000437120626      * \brief Get next entry
000438120626      *
000439120626      * Iterates through the map and returns the key to the next entry. If the
000440120626      * iterator is at the end of the list this method will return <em>null</em>.
000441120626      * The iteration can be aborted early with the procedure <em>lmap_abortIteration</em>.
000442120626      *
000443120626      * \author Mihael Schmidt
000444120626      * \date   01.06.2008
000445120626      *
000446120626      * \param Map pointer
000447120626      *
000448120626      * \return Pointer to the map entry (key) or *null if there are no more entries
000449120626      */
000450120626     P lmap_iterate...
000451120626     P                 B                   export
000452120626     D                 PI              *
000453120626     D   mapPtr                        *   const
000454120626      *
000455120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000456120626     D entryPtr        S               *
000457120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
000458120626     D retVal          S               *
000459120626     D size            S             10I 0
000460120626      /free
000461120626       if (isLinkedMapImpl(mapPtr));
000462120626
000463120626          size = header.size;
000464120626          size -= 1;
000465120626
000466120626         if (header.iteration = size or
000467120626             header.iteration < -1);
000468120626            header.iteration = -1;
000469120626            retVal = *null;
000470120626         else;
000471120626           if (header.iterNextEntry = *null);
000472120626              entryPtr = header.firstEntry;
000473120626           else;
000474120626              entryPtr = header.iterNextEntry;
000475120626           endif;
000476120626
000477120626            header.iteration += 1;
000478120626            header.iterNextEntry = entry.next;
000479120626            retVal = entry.key;
000480120626         endif;
000481120626
000482120626       endif;
000483120626
000484120626       return retVal;
000485120626      /end-free
000486120626     P                 E
000487120626
000488120626
000489120626     /**
000490120626      * \brief Abort iteration
000491120626      *
000492120626      * If the iteration through the list should be aborted early this
000493120626      * procedure should be called.
000494120626      *
000495120626      * \author Mihael Schmidt
000496120626      * \date   01.06.2008
000497120626      *
000498120626      * \param Map pointer
000499120626      */
000500120626     P lmap_abortIteration...
000501120626     P                 B                   export
000502120626     D                 PI
000503120626     D   mapPtr                        *   const
000504120626      *
000505120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000506120626      /free
000507120626       if (isLinkedMapImpl(mapPtr));
000508120626         header.iteration = -1;
000509120626         header.iterNextEntry = *null;
000510120626         header.iterPrevEntry = *null;
000511120626       endif;
000512120626      /end-free
000513120626     P                 E
000514120626
000515120626
000516120626     /**
000517120626      * \brief Contains key
000518120626      *
000519120626      * Checks if the key exists in the map.
000520120626      *
000521120626      * \author Mihael Schmidt
000522120626      * \date   01.06.2008
000523120626      *
000524120626      * \param Map pointer
000525120626      * \param Pointer to the key
000526120626      * \param Key length (in byte)
000527120626      *
000528120626      * \return *on = map contains key <br>
000529120626      *         *off = map does not contain key
000530120626      */
000531120626     P lmap_containsKey...
000532120626     P                 B                   export
000533120626     D                 PI              N
000534120626     D   mapPtr                        *   const
000535120626     D   keyPtr                        *   const
000536120626     D   keyLength                   10U 0 const
000537120626      *
000538120626     D entryPtr        S               *
000539120626     D retVal          S               N   inz(*off)
000540120626      /free
000541120626       if (isLinkedMapImpl(mapPtr));
000542120626
000543120626         entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
000544120626         if (entryPtr = *null);
000545120626           retVal = *off;
000546120626         else;
000547120626           retVal = *on;
000548120626         endif;
000549120626
000550120626       endif;
000551120626
000552120626       return retVal;
000553120626      /end-free
000554120626     P                 E
000555120626
000556120626
000557120626     /**
000558120626      * \brief Contains value
000559120626      *
000560120626      * Checks if the map contains the value.
000561120626      *
000562120626      * \author Mihael Schmidt
000563120626      * \date   01.06.2008
000564120626      *
000565120626      * \param Map pointer
000566120626      * \param Pointer to the value
000567120626      * \param Value length (in byte)
000568120626      *
000569120626      * \return *on = map contains value <br>
000570120626      *         *off = map does not contain value
000571120626      */
000572120626     P lmap_containsValue...
000573120626     P                 B                   export
000574120626     D                 PI              N
000575120626     D   mapPtr                        *   const
000576120626     D   valuePtr                      *   const
000577120626     D   valueLength                 10U 0 const
000578120626      *
000579120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000580120626     D entryPtr        S               *
000581120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
000582120626     D retVal          S               N   inz(*off)
000583120626      /free
000584120626       if (isLinkedMapImpl(mapPtr));
000585120626
000586120626         entryPtr = header.firstEntry;
000587120626         dow (entryPtr <> *null);
000588120626
000589120626           if (valueLength = entry.valueLength - 1 and
000590120626               memcmp(valuePtr : entry.value : valueLength) = 0); // dont include the null
000591120626             retVal = *on;
000592120626             leave;
000593120626           endif;
000594120626
000595120626           entryPtr = entry.next;
000596120626         enddo;
000597120626
000598120626       endif;
000599120626
000600120626       return retVal;
000601120626      /end-free
000602120626     P                 E
000603120626
000604120626
000605120626     /**
000606120626      * \brief Is map empty
000607120626      *
000608120626      * Checks if the map is empty.
000609120626      *
000610120626      * \author Mihael Schmidt
000611120626      * \date   01.06.2008
000612120626      *
000613120626      * \param Map pointer
000614120626      *
000615120626      * \return *on = map is empty <br>
000616120626      *         *off = map is not empty (has at least one entry)
000617120626      */
000618120626     P lmap_isEmpty    B                   export
000619120626     D                 PI              N
000620120626     D   mapPtr                        *   const
000621120626      *
000622120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000623120626     D retVal          S               N
000624120626      /free
000625120626       if (isLinkedMapImpl(mapPtr));
000626120626
000627120626         if (header.size = 0);
000628120626            retVal = *on;
000629120626         else;
000630120626            retVal = *off;
000631120626         endif;
000632120626
000633120626       endif;
000634120626
000635120626       return retVal;
000636120626      /end-free
000637120626     P                 E
000638120626
000639120626
000640120626     /**
000641120626      * \brief Get value
000642120626      *
000643120626      * Returns the value to the passed key.
000644120626      *
000645120626      * \author Mihael Schmidt
000646120626      * \date   01.06.2008
000647120626      *
000648120626      * \param Map pointer
000649120626      * \param Pointer to the key
000650120626      * \param Key length (in Byte)
000651120626      *
000652120626      * \return Pointer to the null-terminated value or
000653120626      *         *null if the key does not exist in the map
000654120626      */
000655120626     P lmap_get        B                   export
000656120626     D                 PI              *
000657120626     D   mapPtr                        *   const
000658120626     D   keyPtr                        *   const
000659120626     D   keyLength                   10U 0 const
000660120626      *
000661120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000662120626     D entryPtr        S               *
000663120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
000664120626     D retVal          S               *   inz(*null)
000665120626      /free
000666120626       if (isLinkedMapImpl(mapPtr));
000667120626         entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
000668120626         if (entryPtr <> *null);
000669120626           retVal = entry.value;
000670120626         endif;
000671120626       endif;
000672120626
000673120626       return retVal;
000674120626      /end-free
000675120626     P                 E
000676120626
000677120626
000678120626     /**
000679120626      * \brief Map size
000680120626      *
000681120626      * Returns the number of entries in the map.
000682120626      *
000683120626      * \author Mihael Schmidt
000684120626      * \date   01.06.2008
000685120626      *
000686120626      * \param Map pointer
000687120626      *
000688120626      * \return Number of entries in the map
000689120626      */
000690120626     P lmap_size       B                   export
000691120626     D                 PI            10I 0
000692120626     D  mapPtr                         *   const
000693120626      *
000694120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000695120626      /free
000696120626       if (isLinkedMapImpl(mapPtr));
000697120626         return header.size;
000698120626       else;
000699120626         return -1;
000700120626       endif;
000701120626      /end-free
000702120626     P                 E
000703120626
000704120626
000705120626     /**
000706120626      * \brief Check for map implementation
000707120626      *
000708120626      * Checks if the pointer points to a map implementation.
000709120626      * The map implementation of this service program has
000710120626      * an id in the first 20 bytes of the map header.
000712120626      *
000713120626      * <br><br>
000714120626      *
000715120626      * If the pointer does not point to a map implementation an
000716120626      * escape message will be sent.
000717120626      *
000718120626      * \author Mihael Schmidt
000719120626      * \date   01.06.2008
000720120626      *
000721120626      * \param Pointer to the map
000722120626      *
000723120626      * \return *on = is map implementation <br>
000724120626      *         *off = is no map implementation (escape message)
000725120626      */
000726120626     P isLinkedMapImpl...
000727120626     P                 B
000728120626     D                 PI              N
000729120626     D   mapPtr                        *   const
000730120626      *
000731120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000732120626     D isMap           S               N
000733120626      /free
000734120626       monitor;
000735120626         if (header.id = LMAP_ID);
000736120626           isMap = *on;
000737120626         else;
000738120626           isMap = *off;
000739120626         endif;
000740120626
000741120626         on-error *all;
000742120626           isMap = *off;
000743120626       endmon;
000744120626
000745120626       if (not isMap);
000746120626         sendEscapeMessage(MSG_NO_LMAP_IMPL);
000747120626       endif;
000748120626
000749120626       return isMap;
000750120626      /end-free
000751120626     P                 E
000752120626
000753120626
000754120626     /**
000755120626      * \brief Send Escape Message
000756120626      *
000757120626      * Sends an escape message with the specified id.
000758120626      *
000759120626      * \author Mihael Schmidt
000760120626      * \date   23.03.2008
000761120626      *
000762120626      * \param Message id
000763120626      */
000767120626     P sendEscapeMessage...
000768120626     P                 B
000769120626     D                 PI
000770120626     D   id                          10I 0 const
000771120626      *
000772120626     D sendProgramMessage...
000773120626     D                 PR                  extpgm('QMHSNDPM')
000774120626     D  szMsgID                       7A   const
000775120626     D  szMsgFile                    20A   const
000776120626     D  szMsgData                  6000A   const  options(*varsize)
000777120626     D  nMsgDataLen                  10I 0 const
000778120626     D  szMsgType                    10A   const
000779120626     D  szCallStkEntry...
000780120626     D                               10A   const
000781120626     D  nRelativeCallStkEntry...
000782120626     D                               10I 0 const
000783120626     D  szRtnMsgKey                   4A
000784120626     D  error                       265A   options(*varsize)
000785120626      *
000786120626     D msgdata         S            512A
000787120626     D msgkey          S              4A
000788120626     D apiError        S            265A
000789120626      /free
000790120626       if (id = MSG_NO_LMAP_IMPL);
000791120626         msgdata = 'The pointer does not point to a map data structure.';
000792120626       elseif (id = MSG_NO_VALID_SORT_ALGORITHM);
000793120626         msgdata = 'A non valid sort algorithm name was passed.';
000794120626       elseif (id = MSG_INVALID_VALUE_TYPE);
000795120626         msgdata = 'The requested type does not correspond to the map ' +
000796120626                   'entry type.';
000797120626       elseif (id = MSG_KEY_NOT_FOUND);
000798120626         msgdata = 'The key was not found in the map.';
000799120626       else;
000800120626         return;
000801120626       endif;
000802120626
000803120626       sendProgramMessage('CPF9898' :
000804120626                          'QCPFMSG   *LIBL     ' :
000805120626                          %trimr(msgdata) :
000806120626                          %len(%trimr(msgdata)) :
000807120626                          '*ESCAPE   ' :
000808120626                          '*PGMBDY' :
000809120626                          0 :
000810120626                          msgkey :
000811120626                          apiError);
000812120626      /end-free
000813120626     P                 E
000814120626
000815120626
000816120626     /**
000817120626      * \brief Get entry by key
000818120626      *
000822120626      * Returns the entry associated with the passed key.
000823120626      *
000824120626      * \param Pointer to the map
000825120626      * \param Pointer to key
000826120626      * \param Length of key
000827120626      *
000828120626      * \return Pointer to the entry or null if the entry is not found
000829120626      */
000830120626     P getMapEntry     B
000831120626     D                 PI              *
000832120626     D  mapPtr                         *   const
000833120626     D  keyPtr                         *   const
000834120626     D  keyLength                    10U 0 const
000835120626      *
000836120626     D header          DS                  likeds(tmpl_header)  based(mapPtr)
000837120626     D entryPtr        S               *
000838120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
000839120626     D retVal          S               *   inz(*null)
000840120626      /free
000841120626       entryPtr = header.firstEntry;
000842120626
000843120626       dow (entryPtr <> *null);
000844120626
000845120626         if (keyLength = entry.keyLength - 1 and
000846120626             memcmp(keyPtr : entry.key : keyLength) = 0); // dont include the null
000847120626           retVal = entryPtr;
000848120626           leave;
000849120626         endif;
000850120626
000851120626         entryPtr = entry.next;
000852120626       enddo;
000853120626
000854120626       return retVal;
000855120626      /end-free
000856120626     P                 E
000857120626
000858120626
000859120626     /**
000860120626      * \brief Swap entries
000861120626      *
000862120626      * Swaps the positions of the passed entries. The entries don't have to lay
000863120626      * next to each other.
000864120626      *
000865120626      * \param Map pointer
000866120626      * \param Pointer to entry
000867120626      * \param Pointer to entry
000868120626      */
000869120626     P internal_swap   B                   export
000870120626     D                 PI
000871120626     D   mapPtr                        *   const
000875120626     D   itemPtr1                      *   const
000876120626     D   itemPtr2                      *   const
000877120626      *
000878120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
000879120626      *
000880120626     D entryPtr1       S               *
000881120626     D entry1          DS                  likeds(tmpl_entry) based(entryPtr1)
000882120626     D entryPtr1P      S               *
000883120626     D entry1P         DS                  likeds(tmpl_entry) based(entryPtr1P)
000884120626     D entryPtr1N      S               *
000885120626     D entry1N         DS                  likeds(tmpl_entry) based(entryPtr1N)
000886120626      *
000887120626     D entryPtr2       S               *
000888120626     D entry2          DS                  likeds(tmpl_entry) based(entryPtr2)
000889120626     D entryPtr2P      S               *
000890120626     D entry2P         DS                  likeds(tmpl_entry) based(entryPtr2P)
000891120626     D entryPtr2N      S               *
000892120626     D entry2N         DS                  likeds(tmpl_entry) based(entryPtr2N)
000893120626      *
000894120626     D tmpPtr          S               *
000895120626      /free
000896120626       // check both items point to the same entry
000897120626       if (itemPtr1 = itemPtr2);
000898120626         return;
000899120626       endif;
000900120626
000901120626       entryPtr1 = itemPtr1;
000902120626       entryPtr2 = itemPtr2;
000903120626
000904120626         // check if the entries are valid
000905120626         if (entryPtr1 <> *null and entryPtr2 <> *null);
000906120626           entryPtr1P = entry1.prev;
000907120626           entryPtr1N = entry1.next;
000908120626           entryPtr2P = entry2.prev;
000909120626           entryPtr2N = entry2.next;
000910120626
000911120626
000912120626           // check if the two nodes are neighbouring nodes
000913120626           if (entry1.next = entryPtr2);
000914120626             entry1.next = entry2.next;
000915120626             entry2.next = entryPtr1;
000916120626
000917120626             entry2.prev = entry1.prev;
000918120626             entry1.prev = entryPtr2;
000919120626
000920120626             if (entryPtr1P <> *null);
000921120626               entry1P.next = entryPtr2;
000922120626             endif;
000923120626
000924120626             if (entryPtr2N <> *null);
000925120626               entry2N.prev = entryPtr1;
000926120626             endif;
000927120626
000928120626           elseif (entry1.prev = entryPtr2); // neighbouring nodes (other way round)
000932120626             entry2.next = entry1.next;
000933120626             entry1.next = entryPtr2;
000934120626
000935120626             entry1.prev = entry2.prev;
000936120626             entry2.prev = entryPtr1;
000937120626
000938120626
000939120626             if (entryPtr1N <> *null);
000940120626               entry1N.prev = entryPtr2;
000941120626             endif;
000942120626
000943120626             if (entryPtr2P <> *null);
000944120626               entry2P.next = entryPtr1;
000945120626             endif;
000946120626
000947120626           else; // no neighbours
000948120626             tmpPtr = entry1.next;
000949120626             entry1.next = entry2.next;
000950120626             entry2.next = tmpPtr;
000951120626
000952120626             tmpPtr = entry1.prev;
000953120626             entry1.prev = entry2.prev;
000954120626             entry2.prev = tmpPtr;
000955120626
000956120626             if (entryPtr1P <> *null);
000957120626               entry1P.next = entryPtr2;
000958120626             endif;
000959120626
000960120626             if (entryPtr1N <> *null);
000961120626               entry1N.prev = entryPtr2;
000962120626             endif;
000963120626
000964120626             if (entryPtr2P <> *null);
000965120626               entry2P.next = entryPtr1;
000966120626             endif;
000967120626
000968120626             if (entryPtr2N <> *null);
000969120626               entry2N.prev = entryPtr1;
000970120626             endif;
000971120626
000972120626           endif;
000973120626
000974120626
000975120626           if (entry1.prev = *null);         // check if it is the first item
000976120626             header.firstEntry = entryPtr1;
000977120626           endif;
000978120626
000979120626           if (entry2.prev = *null);         // check if it is the first item
000980120626             header.firstEntry = entryPtr2;
000981120626           endif;
000982120626
000983120626           if (entry1.next = *null);         // check if it is the last item
000984120626             header.lastEntry = entryPtr1;
000985120626           endif;
000986120626
000987120626           if (entry2.next = *null);         // check if it is the last item
000991120626             header.lastEntry = entryPtr2;
000992120626           endif;
000993120626
000994120626         endif;
000995120626      /end-free
000996120626     P                 E
000997120626
000998120626
000999120626     /**
001000120626      * \brief Add integer
001001120626      *
001002120626      * Adds an entry to the map with an integer value. If the key already
001003120626      * exists the old value will be replaced by the new one.
001004120626      *
001005120626      * \author Mihael Schmidt
001006120626      * \date   01.06.2008
001007120626      *
001008120626      * \param Map pointer
001009120626      * \param Pointer to the key
001010120626      * \param Key length (in byte)
001011120626      * \param Value
001012120626      *
001013120626      */
001014120626     P lmap_addInteger...
001015120626     P                 B                   export
001016120626     D                 PI
001017120626     D   mapPtr                        *   const
001018120626     D   keyPtr                        *   const
001019120626     D   keyLength                   10U 0 const
001020120626     D   value                       10I 0 const
001021120626      *
001022120626     D tmpValue        S             10I 0
001023120626     D valuePtr        S               *
001024120626      /free
001025120626       tmpValue = value;
001026120626       valuePtr = %addr(tmpValue);
001027120626
001028120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : 4);
001029120626      /end-free
001030120626     P                 E
001031120626
001032120626
001033120626     /**
001034120626      * \brief Add string
001035120626      *
001036120626      * Adds an entry to the map with a string value. If the key already
001037120626      * exists the old value will be replaced by the new one.
001038120626      *
001039120626      * \author Mihael Schmidt
001040120626      * \date   26.12.2009
001041120626      *
001042120626      * \param Map pointer
001046120626      * \param Pointer to the key
001047120626      * \param Key length (in byte)
001048120626      * \param Value
001049120626      *
001050120626      */
001051120626     P lmap_addString...
001052120626     P                 B                   export
001053120626     D                 PI
001054120626     D   mapPtr                        *   const
001055120626     D   keyPtr                        *   const
001056120626     D   keyLength                   10U 0 const
001057120626     D   value                    65535A   const varying
001058120626      *
001059120626     D tmpValue        S          65535A
001060120626      /free
001061120626       if (%len(value) = 0);
001062120626         lmap_add(mapPtr : keyPtr : keyLength : %addr(tmpValue) : 0);
001063120626       else;
001064120626         tmpValue = %subst(value : 1 : %len(value));
001065120626         lmap_add(mapPtr : keyPtr : keyLength : %addr(tmpValue) : %len(value));
001066120626       endif;
001067120626      /end-free
001068120626     P                 E
001069120626
001070120626
001071120626     /**
001072120626      * \brief Add long
001073120626      *
001074120626      * Adds an entry to the map with a long value. If the key already
001075120626      * exists the old value will be replaced by the new one.
001076120626      *
001077120626      * \author Mihael Schmidt
001078120626      * \date   23.12.2009
001079120626      *
001080120626      * \param Map pointer
001081120626      * \param Pointer to the key
001082120626      * \param Key length (in byte)
001083120626      * \param Value
001084120626      *
001085120626      */
001086120626     P lmap_addLong...
001087120626     P                 B                   export
001088120626     D                 PI
001089120626     D   mapPtr                        *   const
001090120626     D   keyPtr                        *   const
001091120626     D   keyLength                   10U 0 const
001092120626     D   value                       20I 0 const
001093120626      *
001094120626     D tmpValue        S             20I 0
001095120626     D valuePtr        S               *
001099120626      /free
001100120626       tmpValue = value;
001101120626       valuePtr = %addr(tmpValue);
001102120626
001103120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : 8);
001104120626      /end-free
001105120626     P                 E
001106120626
001107120626
001108120626     /**
001109120626      * \brief Add float
001110120626      *
001111120626      * Adds an entry to the map with a float value. If the key already
001112120626      * exists the old value will be replaced by the new one.
001113120626      *
001114120626      * \author Mihael Schmidt
001115120626      * \date   23.12.2009
001116120626      *
001117120626      * \param Map pointer
001118120626      * \param Pointer to the key
001119120626      * \param Key length (in byte)
001120120626      * \param Value
001121120626      *
001122120626      */
001123120626     P lmap_addFloat...
001124120626     P                 B                   export
001125120626     D                 PI
001126120626     D   mapPtr                        *   const
001127120626     D   keyPtr                        *   const
001128120626     D   keyLength                   10U 0 const
001129120626     D   value                        4F   const
001130120626      *
001131120626     D tmpValue        S              4F
001132120626     D valuePtr        S               *
001133120626      /free
001134120626       tmpValue = value;
001135120626       valuePtr = %addr(tmpValue);
001136120626
001137120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : %size(value));
001138120626      /end-free
001139120626     P                 E
001140120626
001141120626
001142120626     /**
001143120626      * \brief Add double
001144120626      *
001145120626      * Adds an entry to the map with a double value. If the key already
001146120626      * exists the old value will be replaced by the new one.
001147120626      *
001148120626      * \author Mihael Schmidt
001152120626      * \date   23.12.2009
001153120626      *
001154120626      * \param Map pointer
001155120626      * \param Pointer to the key
001156120626      * \param Key length (in byte)
001157120626      * \param Value
001158120626      *
001159120626      */
001160120626     P lmap_addDouble...
001161120626     P                 B                   export
001162120626     D                 PI
001163120626     D   mapPtr                        *   const
001164120626     D   keyPtr                        *   const
001165120626     D   keyLength                   10U 0 const
001166120626     D   value                        8F   const
001167120626      *
001168120626     D tmpValue        S              8F
001169120626     D valuePtr        S               *
001170120626      /free
001171120626       tmpValue = value;
001172120626       valuePtr = %addr(tmpValue);
001173120626
001174120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : %size(value));
001175120626      /end-free
001176120626     P                 E
001177120626
001178120626
001179120626     /**
001180120626      * \brief Add date
001181120626      *
001182120626      * Adds an entry to the map with a date value. If the key already
001183120626      * exists the old value will be replaced by the new one.
001184120626      *
001185120626      * \author Mihael Schmidt
001186120626      * \date   23.12.2009
001187120626      *
001188120626      * \param Map pointer
001189120626      * \param Pointer to the key
001190120626      * \param Key length (in byte)
001191120626      * \param Value
001192120626      *
001193120626      */
001194120626     P lmap_addDate...
001195120626     P                 B                   export
001196120626     D                 PI
001197120626     D   mapPtr                        *   const
001198120626     D   keyPtr                        *   const
001199120626     D   keyLength                   10U 0 const
001200120626     D   value                         D   const
001201120626      *
001205120626     D tmpValue        S               D
001206120626     D valuePtr        S               *
001207120626      /free
001208120626       tmpValue = value;
001209120626       valuePtr = %addr(tmpValue);
001210120626
001211120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : %size(value));
001212120626      /end-free
001213120626     P                 E
001214120626
001215120626
001216120626     /**
001217120626      * \brief Add time
001218120626      *
001219120626      * Adds an entry to the map with a time value. If the key already
001220120626      * exists the old value will be replaced by the new one.
001221120626      *
001222120626      * \author Mihael Schmidt
001223120626      * \date   23.12.2009
001224120626      *
001225120626      * \param Map pointer
001226120626      * \param Pointer to the key
001227120626      * \param Key length (in byte)
001228120626      * \param Value
001229120626      *
001230120626      */
001231120626     P lmap_addTime...
001232120626     P                 B                   export
001233120626     D                 PI
001234120626     D   mapPtr                        *   const
001235120626     D   keyPtr                        *   const
001236120626     D   keyLength                   10U 0 const
001237120626     D   value                         T   const
001238120626      *
001239120626     D tmpValue        S               T
001240120626     D valuePtr        S               *
001241120626      /free
001242120626       tmpValue = value;
001243120626       valuePtr = %addr(tmpValue);
001244120626
001245120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : %size(value));
001246120626      /end-free
001247120626     P                 E
001248120626
001249120626
001250120626     /**
001251120626      * \brief Add timestamp
001252120626      *
001253120626      * Adds an entry to the map with a timestamp value. If the key already
001254120626      * exists the old value will be replaced by the new one.
001258120626      *
001259120626      * \author Mihael Schmidt
001260120626      * \date   23.12.2009
001261120626      *
001262120626      * \param Map pointer
001263120626      * \param Pointer to the key
001264120626      * \param Key length (in byte)
001265120626      * \param Value
001266120626      *
001267120626      */
001268120626     P lmap_addTimestamp...
001269120626     P                 B                   export
001270120626     D                 PI
001271120626     D   mapPtr                        *   const
001272120626     D   keyPtr                        *   const
001273120626     D   keyLength                   10U 0 const
001274120626     D   value                         Z   const
001275120626      *
001276120626     D tmpValue        S               Z
001277120626     D valuePtr        S               *
001278120626      /free
001279120626       tmpValue = value;
001280120626       valuePtr = %addr(tmpValue);
001281120626
001282120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : %size(value));
001283120626      /end-free
001284120626     P                 E
001285120626
001286120626
001287120626     /**
001288120626      * \brief Add decimal
001289120626      *
001290120626      * Adds an entry to the map with a decimal value. If the key already
001291120626      * exists the old value will be replaced by the new one.
001292120626      *
001293120626      * \author Mihael Schmidt
001294120626      * \date   23.12.2009
001295120626      *
001296120626      * \param Map pointer
001297120626      * \param Pointer to the key
001298120626      * \param Key length (in byte)
001299120626      * \param Value
001300120626      *
001301120626      */
001302120626     P lmap_addDecimal...
001303120626     P                 B                   export
001304120626     D                 PI
001305120626     D   mapPtr                        *   const
001306120626     D   keyPtr                        *   const
001307120626     D   keyLength                   10U 0 const
001311120626     D   value                       15P 5   const
001312120626      *
001313120626     D tmpValue        S             15P 5
001314120626     D valuePtr        S               *
001315120626      /free
001316120626       tmpValue = value;
001317120626       valuePtr = %addr(tmpValue);
001318120626
001319120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : %size(value));
001320120626      /end-free
001321120626     P                 E
001322120626
001323120626
001324120626     /**
001325120626      * \brief Add short
001326120626      *
001327120626      * Adds an entry to the map with a short value. If the key already
001328120626      * exists the old value will be replaced by the new one.
001329120626      *
001330120626      * \author Mihael Schmidt
001331120626      * \date   27.12.2009
001332120626      *
001333120626      * \param Map pointer
001334120626      * \param Pointer to the key
001335120626      * \param Key length (in byte)
001336120626      * \param Value
001337120626      *
001338120626      */
001339120626     P lmap_addShort...
001340120626     P                 B                   export
001341120626     D                 PI
001342120626     D   mapPtr                        *   const
001343120626     D   keyPtr                        *   const
001344120626     D   keyLength                   10U 0 const
001345120626     D   value                        5I 0 const
001346120626      *
001347120626     D tmpValue        S              5I 0
001348120626     D valuePtr        S               *
001349120626      /free
001350120626       tmpValue = value;
001351120626       valuePtr = %addr(tmpValue);
001352120626
001353120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : %size(value));
001354120626      /end-free
001355120626     P                 E
001356120626
001357120626
001358120626     /**
001359120626      * \brief Add boolean
001360120626      *
001364120626      * Adds an entry to the map with a boolean value. If the key already
001365120626      * exists the old value will be replaced by the new one.
001366120626      *
001367120626      * \author Mihael Schmidt
001368120626      * \date   23.12.2009
001369120626      *
001370120626      * \param Map pointer
001371120626      * \param Pointer to the key
001372120626      * \param Key length (in byte)
001373120626      * \param Value
001374120626      *
001375120626      */
001376120626     P lmap_addBoolean...
001377120626     P                 B                   export
001378120626     D                 PI
001379120626     D   mapPtr                        *   const
001380120626     D   keyPtr                        *   const
001381120626     D   keyLength                   10U 0 const
001382120626     D   value                         N   const
001383120626      *
001384120626     D tmpValue        S               N
001385120626     D valuePtr        S               *
001386120626      /free
001387120626       tmpValue = value;
001388120626       valuePtr = %addr(tmpValue);
001389120626
001390120626       lmap_add(mapPtr : keyPtr : keyLength : valuePtr : %size(value));
001391120626      /end-free
001392120626     P                 E
001393120626
001394120626
001395120626     /**
001396120626      * \brief Get integer value
001397120626      *
001398120626      * Returns the integer value to the passed key.
001399120626      *
001400120626      * \author Mihael Schmidt
001401120626      * \date   27.12.2009
001402120626      *
001403120626      * \param Map pointer
001404120626      * \param Pointer to the key
001405120626      * \param Key length (in Byte)
001406120626      *
001407120626      * \return Value
001408120626      *
001409120626      * \throws CPF9898 Invalid value type
001410120626      * \throws CPF9898 Key not found
001411120626      */
001412120626     P lmap_getInteger...
001413120626     P                 B                   export
001417120626     D                 PI            10I 0
001418120626     D   mapPtr                        *   const
001419120626     D   keyPtr                        *   const
001420120626     D   keyLength                   10U 0 const
001421120626      *
001422120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001423120626     D entryPtr        S               *
001424120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001425120626     D temp            S             10I 0 based(entry.value)
001426120626     D retVal          S             10I 0
001427120626      /free
001428120626       isLinkedMapImpl(mapPtr);
001429120626
001430120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001431120626       if (entryPtr <> *null);
001432120626
001433120626         if (entry.valueLength -1 <> %size(retVal));
001434120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001435120626         endif;
001436120626
001437120626         monitor;
001438120626           // test if the temp variable is filled with the right data for the type
001439120626           // by moving the data from temp to another var (testVar in this case)
001440120626           retVal = temp;
001441120626           return retVal;
001442120626           on-error *all;
001443120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001444120626             return *loval;
001445120626         endmon;
001446120626
001447120626       else;
001448120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001449120626         return *loval;
001450120626       endif;
001451120626      /end-free
001452120626     P                 E
001453120626
001454120626
001455120626     /**
001456120626      * \brief Get string value
001457120626      *
001458120626      * Returns the string value to the passed key.
001459120626      *
001460120626      * \author Mihael Schmidt
001461120626      * \date   27.12.2009
001462120626      *
001463120626      * \param Map pointer
001464120626      * \param Pointer to the key
001465120626      * \param Key length (in Byte)
001466120626      *
001467120626      * \return Value
001468120626      *
001469120626      * \throws CPF9898 Invalid value type
001470120626      * \throws CPF9898 Key not found
001474120626      */
001475120626     P lmap_getString...
001476120626     P                 B                   export
001477120626     D                 PI         65535A
001478120626     D   mapPtr                        *   const
001479120626     D   keyPtr                        *   const
001480120626     D   keyLength                   10U 0 const
001481120626      *
001482120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001483120626     D entryPtr        S               *
001484120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001485120626     D temp            S          65535A   based(entry.value)
001486120626     D retVal          S          65535A
001487120626      /free
001488120626       isLinkedMapImpl(mapPtr);
001489120626
001490120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001491120626       if (entryPtr <> *null);
001492120626
001493120626         monitor;
001494120626           // test if the temp variable is filled with the right data for the type
001495120626           // by moving the data from temp to another var (testVar in this case)
001496120626           retVal = %subst(temp : 1 : entry.valueLength -1);
001497120626           return retVal;
001498120626           on-error *all;
001499120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001500120626             return *blanks;
001501120626         endmon;
001502120626
001503120626       else;
001504120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001505120626         return *blanks;
001506120626       endif;
001507120626      /end-free
001508120626     P                 E
001509120626
001510120626
001511120626     /**
001512120626      * \brief Get short value
001513120626      *
001514120626      * Returns the short value to the passed key.
001515120626      *
001516120626      * \author Mihael Schmidt
001517120626      * \date   27.12.2009
001518120626      *
001519120626      * \param Map pointer
001520120626      * \param Pointer to the key
001521120626      * \param Key length (in Byte)
001522120626      *
001523120626      * \return Value
001524120626      *
001525120626      * \throws CPF9898 Invalid value type
001529120626      * \throws CPF9898 Key not found
001530120626      */
001531120626     P lmap_getShort...
001532120626     P                 B                   export
001533120626     D                 PI             5I 0
001534120626     D   mapPtr                        *   const
001535120626     D   keyPtr                        *   const
001536120626     D   keyLength                   10U 0 const
001537120626      *
001538120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001539120626     D entryPtr        S               *
001540120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001541120626     D temp            S              5I 0 based(entry.value)
001542120626     D retVal          S              5I 0
001543120626      /free
001544120626       isLinkedMapImpl(mapPtr);
001545120626
001546120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001547120626       if (entryPtr <> *null);
001548120626
001549120626         if (entry.valueLength -1 <> %size(retVal));
001550120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001551120626         endif;
001552120626
001553120626         monitor;
001554120626           // test if the temp variable is filled with the right data for the type
001555120626           // by moving the data from temp to another var (testVar in this case)
001556120626           retVal = temp;
001557120626           return retVal;
001558120626           on-error *all;
001559120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001560120626             return *loval;
001561120626         endmon;
001562120626
001563120626       else;
001564120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001565120626         return *loval;
001566120626       endif;
001567120626      /end-free
001568120626     P                 E
001569120626
001570120626
001571120626     /**
001572120626      * \brief Get long value
001573120626      *
001574120626      * Returns the long value to the passed key.
001575120626      *
001576120626      * \author Mihael Schmidt
001577120626      * \date   27.12.2009
001578120626      *
001579120626      * \param Map pointer
001580120626      * \param Pointer to the key
001584120626      * \param Key length (in Byte)
001585120626      *
001586120626      * \return Value
001587120626      *
001588120626      * \throws CPF9898 Invalid value type
001589120626      * \throws CPF9898 Key not found
001590120626      */
001591120626     P lmap_getLong...
001592120626     P                 B                   export
001593120626     D                 PI            20I 0
001594120626     D   mapPtr                        *   const
001595120626     D   keyPtr                        *   const
001596120626     D   keyLength                   10U 0 const
001597120626      *
001598120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001599120626     D entryPtr        S               *
001600120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001601120626     D temp            S             20I 0 based(entry.value)
001602120626     D retVal          S             20I 0
001603120626      /free
001604120626       isLinkedMapImpl(mapPtr);
001605120626
001606120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001607120626       if (entryPtr <> *null);
001608120626
001609120626         if (entry.valueLength -1 <> %size(retVal));
001610120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001611120626         endif;
001612120626
001613120626         monitor;
001614120626           // test if the temp variable is filled with the right data for the type
001615120626           // by moving the data from temp to another var (testVar in this case)
001616120626           retVal = temp;
001617120626           return retVal;
001618120626           on-error *all;
001619120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001620120626             return *loval;
001621120626         endmon;
001622120626
001623120626       else;
001624120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001625120626         return *loval;
001626120626       endif;
001627120626      /end-free
001628120626     P                 E
001629120626
001630120626
001631120626     /**
001632120626      * \brief Get float value
001633120626      *
001634120626      * Returns the float value to the passed key.
001635120626      *
001639120626      * \author Mihael Schmidt
001640120626      * \date   27.12.2009
001641120626      *
001642120626      * \param Map pointer
001643120626      * \param Pointer to the key
001644120626      * \param Key length (in Byte)
001645120626      *
001646120626      * \return Value
001647120626      *
001648120626      * \throws CPF9898 Invalid value type
001649120626      * \throws CPF9898 Key not found
001650120626      */
001651120626     P lmap_getFloat...
001652120626     P                 B                   export
001653120626     D                 PI             4F
001654120626     D   mapPtr                        *   const
001655120626     D   keyPtr                        *   const
001656120626     D   keyLength                   10U 0 const
001657120626      *
001658120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001659120626     D entryPtr        S               *
001660120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001661120626     D temp            S              4F   based(entry.value)
001662120626     D retVal          S              4F
001663120626      /free
001664120626       isLinkedMapImpl(mapPtr);
001665120626
001666120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001667120626       if (entryPtr <> *null);
001668120626
001669120626         if (entry.valueLength -1 <> %size(retVal));
001670120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001671120626         endif;
001672120626
001673120626         monitor;
001674120626           // test if the temp variable is filled with the right data for the type
001675120626           // by moving the data from temp to another var (testVar in this case)
001676120626           retVal = temp;
001677120626           return retVal;
001678120626           on-error *all;
001679120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001680120626             return *loval;
001681120626         endmon;
001682120626
001683120626       else;
001684120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001685120626         return *loval;
001686120626       endif;
001687120626      /end-free
001688120626     P                 E
001689120626
001694120626     /**
001695120626      * \brief Get double value
001696120626      *
001697120626      * Returns the double value to the passed key.
001698120626      *
001699120626      * \author Mihael Schmidt
001700120626      * \date   27.12.2009
001701120626      *
001702120626      * \param Map pointer
001703120626      * \param Pointer to the key
001704120626      * \param Key length (in Byte)
001705120626      *
001706120626      * \return Value
001707120626      *
001708120626      * \throws CPF9898 Invalid value type
001709120626      * \throws CPF9898 Key not found
001710120626      */
001711120626     P lmap_getDouble...
001712120626     P                 B                   export
001713120626     D                 PI             8F
001714120626     D   mapPtr                        *   const
001715120626     D   keyPtr                        *   const
001716120626     D   keyLength                   10U 0 const
001717120626      *
001718120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001719120626     D entryPtr        S               *
001720120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001721120626     D temp            S              8F   based(entry.value)
001722120626     D retVal          S              8F
001723120626      /free
001724120626       isLinkedMapImpl(mapPtr);
001725120626
001726120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001727120626       if (entryPtr <> *null);
001728120626
001729120626         if (entry.valueLength -1 <> %size(retVal));
001730120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001731120626         endif;
001732120626
001733120626         monitor;
001734120626           // test if the temp variable is filled with the right data for the type
001735120626           // by moving the data from temp to another var (testVar in this case)
001736120626           retVal = temp;
001737120626           return retVal;
001738120626           on-error *all;
001739120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001740120626             return *loval;
001741120626         endmon;
001742120626
001743120626       else;
001744120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001745120626         return *loval;
001749120626       endif;
001750120626      /end-free
001751120626     P                 E
001752120626
001753120626
001754120626     /**
001755120626      * \brief Get boolean value
001756120626      *
001757120626      * Returns the boolean value to the passed key.
001758120626      *
001759120626      * \author Mihael Schmidt
001760120626      * \date   27.12.2009
001761120626      *
001762120626      * \param Map pointer
001763120626      * \param Pointer to the key
001764120626      * \param Key length (in Byte)
001765120626      *
001766120626      * \return Value
001767120626      *
001768120626      * \throws CPF9898 Invalid value type
001769120626      * \throws CPF9898 Key not found
001770120626      */
001771120626     P lmap_getBoolean...
001772120626     P                 B                   export
001773120626     D                 PI              N
001774120626     D   mapPtr                        *   const
001775120626     D   keyPtr                        *   const
001776120626     D   keyLength                   10U 0 const
001777120626      *
001778120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001779120626     D entryPtr        S               *
001780120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001781120626     D temp            S               N   based(entry.value)
001782120626     D retVal          S               N
001783120626      /free
001784120626       isLinkedMapImpl(mapPtr);
001785120626
001786120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001787120626       if (entryPtr <> *null);
001788120626
001789120626         if (entry.valueLength -1 <> %size(retVal));
001790120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001791120626         endif;
001792120626
001793120626         monitor;
001794120626           // test if the temp variable is filled with the right data for the type
001795120626           // by moving the data from temp to another var (testVar in this case)
001796120626           retVal = temp;
001797120626           return retVal;
001798120626           on-error *all;
001799120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001800120626             return *loval;
001804120626         endmon;
001805120626
001806120626       else;
001807120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001808120626         return *loval;
001809120626       endif;
001810120626      /end-free
001811120626     P                 E
001812120626
001813120626     /**
001814120626      * \brief Get time value
001815120626      *
001816120626      * Returns the time value to the passed key.
001817120626      *
001818120626      * \author Mihael Schmidt
001819120626      * \date   27.12.2009
001820120626      *
001821120626      * \param Map pointer
001822120626      * \param Pointer to the key
001823120626      * \param Key length (in Byte)
001824120626      *
001825120626      * \return Value
001826120626      *
001827120626      * \throws CPF9898 Invalid value type
001828120626      * \throws CPF9898 Key not found
001829120626      */
001830120626     P lmap_getTime...
001831120626     P                 B                   export
001832120626     D                 PI              T
001833120626     D   mapPtr                        *   const
001834120626     D   keyPtr                        *   const
001835120626     D   keyLength                   10U 0 const
001836120626      *
001837120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001838120626     D entryPtr        S               *
001839120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001840120626     D temp            S               T   based(entry.value)
001841120626     D retVal          S               T
001842120626      /free
001843120626       isLinkedMapImpl(mapPtr);
001844120626
001845120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001846120626       if (entryPtr <> *null);
001847120626
001848120626         if (entry.valueLength -1 <> %size(retVal));
001849120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001850120626         endif;
001851120626
001852120626         monitor;
001853120626           // test if the temp variable is filled with the right data for the type
001854120626           // by moving the data from temp to another var (testVar in this case)
001855120626           retVal = temp;
001859120626           return retVal;
001860120626           on-error *all;
001861120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001862120626             return *loval;
001863120626         endmon;
001864120626
001865120626       else;
001866120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001867120626         return *loval;
001868120626       endif;
001869120626      /end-free
001870120626     P                 E
001871120626
001872120626
001873120626     /**
001874120626      * \brief Get date value
001875120626      *
001876120626      * Returns the date value to the passed key.
001877120626      *
001878120626      * \author Mihael Schmidt
001879120626      * \date   27.12.2009
001880120626      *
001881120626      * \param Map pointer
001882120626      * \param Pointer to the key
001883120626      * \param Key length (in Byte)
001884120626      *
001885120626      * \return Value
001886120626      *
001887120626      * \throws CPF9898 Invalid value type
001888120626      * \throws CPF9898 Key not found
001889120626      */
001890120626     P lmap_getDate...
001891120626     P                 B                   export
001892120626     D                 PI              D
001893120626     D   mapPtr                        *   const
001894120626     D   keyPtr                        *   const
001895120626     D   keyLength                   10U 0 const
001896120626      *
001897120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001898120626     D entryPtr        S               *
001899120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001900120626     D temp            S               D   based(entry.value)
001901120626     D retVal          S               D
001902120626      /free
001903120626       isLinkedMapImpl(mapPtr);
001904120626
001905120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001906120626       if (entryPtr <> *null);
001907120626
001908120626         if (entry.valueLength -1 <> %size(retVal));
001909120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001910120626         endif;
001914120626
001915120626         monitor;
001916120626           // test if the temp variable is filled with the right data for the type
001917120626           // by moving the data from temp to another var (testVar in this case)
001918120626           retVal = temp;
001919120626           return retVal;
001920120626           on-error *all;
001921120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001922120626             return *loval;
001923120626         endmon;
001924120626
001925120626       else;
001926120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001927120626         return *loval;
001928120626       endif;
001929120626      /end-free
001930120626     P                 E
001931120626
001932120626
001933120626     /**
001934120626      * \brief Get timestamp value
001935120626      *
001936120626      * Returns the timestamp value to the passed key.
001937120626      *
001938120626      * \author Mihael Schmidt
001939120626      * \date   27.12.2009
001940120626      *
001941120626      * \param Map pointer
001942120626      * \param Pointer to the key
001943120626      * \param Key length (in Byte)
001944120626      *
001945120626      * \return Value
001946120626      *
001947120626      * \throws CPF9898 Invalid value type
001948120626      * \throws CPF9898 Key not found
001949120626      */
001950120626     P lmap_getTimestamp...
001951120626     P                 B                   export
001952120626     D                 PI              Z
001953120626     D   mapPtr                        *   const
001954120626     D   keyPtr                        *   const
001955120626     D   keyLength                   10U 0 const
001956120626      *
001957120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
001958120626     D entryPtr        S               *
001959120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
001960120626     D temp            S               Z   based(entry.value)
001961120626     D retVal          S               Z
001962120626      /free
001963120626       isLinkedMapImpl(mapPtr);
001964120626
001965120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
001969120626       if (entryPtr <> *null);
001970120626
001971120626         if (entry.valueLength -1 <> %size(retVal));
001972120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001973120626         endif;
001974120626
001975120626         monitor;
001976120626           // test if the temp variable is filled with the right data for the type
001977120626           // by moving the data from temp to another var (testVar in this case)
001978120626           retVal = temp;
001979120626           return retVal;
001980120626           on-error *all;
001981120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
001982120626             return *loval;
001983120626         endmon;
001984120626
001985120626       else;
001986120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
001987120626         return *loval;
001988120626       endif;
001989120626      /end-free
001990120626     P                 E
001991120626
001992120626
001993120626     /**
001994120626      * \brief Get decimal value
001995120626      *
001996120626      * Returns the decimal value to the passed key.
001997120626      *
001998120626      * \author Mihael Schmidt
001999120626      * \date   27.12.2009
002000120626      *
002001120626      * \param Map pointer
002002120626      * \param Pointer to the key
002003120626      * \param Key length (in Byte)
002004120626      *
002005120626      * \return Value
002006120626      *
002007120626      * \throws CPF9898 Invalid value type
002008120626      * \throws CPF9898 Key not found
002009120626      */
002010120626     P lmap_getDecimal...
002011120626     P                 B                   export
002012120626     D                 PI            15P 5
002013120626     D   mapPtr                        *   const
002014120626     D   keyPtr                        *   const
002015120626     D   keyLength                   10U 0 const
002016120626      *
002017120626     D header          DS                  likeds(tmpl_header) based(mapPtr)
002018120626     D entryPtr        S               *
002019120626     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
002020120626     D temp            S             15P 5 based(entry.value)
002021120626     D retVal          S             15P 5
002022120626      /free
002026120626       isLinkedMapImpl(mapPtr);
002027120626
002028120626       entryPtr = getMapEntry(mapPtr : keyPtr : keyLength);
002029120626       if (entryPtr <> *null);
002030120626
002031120626         if (entry.valueLength -1 <> %size(retVal));
002032120626           sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002033120626         endif;
002034120626
002035120626         monitor;
002036120626           // test if the temp variable is filled with the right data for the type
002037120626           // by moving the data from temp to another var (testVar in this case)
002038120626           retVal = temp;
002039120626           return retVal;
002040120626           on-error *all;
002041120626             sendEscapeMessage(MSG_INVALID_VALUE_TYPE);
002042120626             return *loval;
002043120626         endmon;
002044120626
002045120626       else;
002046120626         sendEscapeMessage(MSG_KEY_NOT_FOUND);
002047120626         return *loval;
002048120626       endif;
002049120626      /end-free
002050120626     P                 E
