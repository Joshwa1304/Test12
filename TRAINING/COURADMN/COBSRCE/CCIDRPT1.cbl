       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. CCIDRPT1.                                                    
      *REMARKS.  THIS IS AN EXAMPLE OF AN APPLICATION PROGRAM WHICH             
      *          ACCESSES ENDEVOR INFORMATION USING THE API.                    
      *                                                                         
       ENVIRONMENT DIVISION.                                                    
       CONFIGURATION SECTION.                                                   
       SOURCE-COMPUTER. IBM-OS390.                                              
       OBJECT-COMPUTER. IBM-OS390.                                              
       SPECIAL-NAMES.                                                           
           C01 IS TOP-OF-PAGE.                                                  
       INPUT-OUTPUT SECTION.                                                    
       FILE-CONTROL.                                                            
           SELECT INPUT-FILE ASSIGN TO UR-S-SYSIN                               
              ACCESS IS SEQUENTIAL.                                             
           SELECT OUTPUT-REPORT ASSIGN TO UR-S-CCIDRPT1                         
              ACCESS IS SEQUENTIAL.                                             
           SELECT EXT1-FILE ASSIGN TO UR-S-EXT1ELM                              
              ACCESS IS SEQUENTIAL.                                             
           SELECT EXT2-FILE ASSIGN TO UR-S-EXT2ELM                              
              ACCESS IS SEQUENTIAL.                                             
           SELECT WORK-FILE ASSIGN TO UR-S-WORKELM                              
              ACCESS IS SEQUENTIAL.                                             
           SELECT SORTED-FILE ASSIGN TO UR-S-SORTELM                            
              ACCESS IS SEQUENTIAL.                                             
           SELECT SORT-FILE ASSIGN TO UR-S-SORTFILE.                            
       I-O-CONTROL.                                                             
           APPLY WRITE-ONLY ON EXT1-FILE, EXT2-FILE.                            
      *                                                                         
       DATA DIVISION.                                                           
      *                                                                         
       FILE SECTION.                                                            
       FD  INPUT-FILE                                                           
           RECORDING MODE IS F                                                  
           LABEL RECORDS ARE OMITTED.                                           
       01  INCARD.                                                              
            05  INCARD-FUNC              PIC X(4).                              
            05  INCARD-FUNC-COMM  REDEFINES INCARD-FUNC.                        
                10  INCARD-COMMENT       PIC X.                                 
                10  FILLER               PIC X(3).                              
            05  INCARD-DATA.                                                    
                10  INCARD-PATH          PIC X.                                 
                10  INCARD-SEARCH        PIC X.                                 
                10  INCARD-RETURN        PIC X.                                 
                10  INCARD-ENV           PIC X(8).                              
                10  INCARD-STG-ID        PIC X.                                 
                10  INCARD-SYSTEM        PIC X(8).                              
                10  INCARD-SUBSYS        PIC X(8).                              
                10  INCARD-ELEMENT       PIC X(10).                             
                10  INCARD-TYPE          PIC X(8).                              
                10  INCARD-TOENV         PIC X(8).                              
                10  INCARD-TOSTG-ID      PIC X.                                 
                10  INCARD-TOELEMENT     PIC X(10).                             
                10  INCARD-INCBASE       PIC X(1).                              
                10  FILLER               PIC X(10).                             
      *                                                                         
       FD  EXT1-FILE                                                            
           BLOCK CONTAINS 0 RECORDS                                             
           RECORDING MODE IS V                                                  
           LABEL RECORDS ARE OMITTED.                                           
       01  ALELM-RS-DATA                 PIC X(4092).                           
      *                                                                         
       FD  EXT2-FILE                                                            
           BLOCK CONTAINS 0 RECORDS                                             
           RECORDING MODE IS V                                                  
           LABEL RECORDS ARE OMITTED.                                           
       01  AEELM-RS-DATA                 PIC X(4092).                           
      *                                                                         
       FD  WORK-FILE                                                            
           RECORDING MODE IS F                                                  
           LABEL RECORDS ARE OMITTED.                                           
       01  WORK-DATA                     PIC X(119).                            
      *                                                                         
       FD  SORTED-FILE                                                          
           RECORDING MODE IS F                                                  
           LABEL RECORDS ARE OMITTED.                                           
       01  SORTED-DATA                   PIC X(119).                            
      *                                                                         
       SD  SORT-FILE                                                            
           DATA RECORD IS SORT-DATA.                                            
       01  SORT-DATA.                                                           
           05  SORT-KEY.                                                        
               10  SORT-CCID    PIC X(12).                                      
               10  SORT-ELEMENT PIC X(10).                                      
               10  SORT-TYPE    PIC X(8).                                       
               10  SORT-ENVIRON PIC X(8).                                       
               10  SORT-SID     PIC X.                                          
               10  SORT-SYSTEM  PIC X(8).                                       
               10  SORT-SUBSYS  PIC X(8).                                       
           05  SORT-COMMENT     PIC X(40).                                      
           05  SORT-USER        PIC X(8).                                       
           05  SORT-DATE        PIC X(7).                                       
           05  SORT-TIME        PIC X(5).                                       
           05  SORT-VV          PIC X(2).                                       
           05  SORT-LL          PIC X(2).                                       
      *                                                                         
       FD  OUTPUT-REPORT                                                        
           RECORDING MODE IS F                                                  
           LABEL RECORDS ARE OMITTED.                                           
       01  REPORTLINE                    PIC X(132).                            
      *                                                                         
       WORKING-STORAGE SECTION.                                                 
       77  WS-LINECNT                    PIC S9(3) COMP-3 VALUE +60.            
       77  WS-PAGECNT                    PIC S9(3) COMP-3 VALUE ZERO.           
       77  WS-PRT-CCONTROL               PIC 9 VALUE ZERO.                      
           SKIP1                                                                
       01  INCARD-STATUS                 PIC 9            VALUE ZERO.           
           88  INCARD-ALL-DONE  VALUE 1.                                        
           SKIP1                                                                
       01  EXT1-FILE-STATUS              PIC 9            VALUE ZERO.           
           88  EXT1-CLOSE       VALUE ZERO.                                     
           88  EXT1-OPEN        VALUE 1.                                        
           SKIP1                                                                
       01  WORK-FILE-STATUS              PIC 9            VALUE ZERO.           
           88  WORK-CLOSE       VALUE ZERO.                                     
           88  WORK-OPEN        VALUE 1.                                        
           SKIP1                                                                
       01  API-CALL-TYPE                 PIC 9            VALUE ZERO.           
           88 REQUEST-CALL      VALUE ZERO.                                     
           88 SHUTDOWN-ONLY     VALUE 1.                                        
           SKIP1                                                                
       01  API-CALL-STATUS                PIC 9            VALUE ZERO.          
           88  CALL-OK          VALUE ZERO.                                     
           88  NO-ELEMENTS      VALUE 1.                                        
           88  CALL-ERROR       VALUE 2.                                        
           SKIP1                                                                
       01  API-STATUS                     PIC 9            VALUE ZERO.          
           88  API-ACTIVE       VALUE 1.                                        
           SKIP1                                                                
       01  WS-PRINT-SW                    PIC 9            VALUE ZERO.          
           88  WS-PRINT-SPEC    VALUE 1.                                        
           88  WS-PRINT-DETAIL  VALUE 2.                                        
           SKIP1                                                                
       01  WS-HDRPRT-SW                   PIC 9            VALUE ZERO.          
           88  WS-PRINT-SUBHDR  VALUE 1.                                        
           SKIP1                                                                
       01  WS-CONSTANTS.                                                        
      *                                                                         
      *                FOR  SPL4-SEARCH.                                        
           05  WS-NONE          PIC X(20)  VALUE 'CURRENT LOCATION'.            
           05  WS-BETW          PIC X(20)  VALUE 'BETWEEN LOCATIONS'.           
           05  WS-RANGE         PIC X(20)  VALUE 'LOCATION RANGE'.              
           05  WS-ALL           PIC X(20)  VALUE 'ALL MAPPED LOCATIONS'.        
           05  WS-NEXT          PIC X(20)  VALUE 'NEXT LOCATIONS'.              
           05  WS-NOBASE        PIC X(20)  VALUE 'DO NOT INCLUDE BASE'.         
           05  WS-INBASE        PIC X(20)  VALUE 'INCLUDE BASE LEVEL'.          
           05  SAVE-SW          PIC X VALUE '0'.                                
           05  WS-SAVE-VV       PIC XX.                                         
           05  WS-SAVE-LL       PIC XX.                                         
           05  WS-SAVE-CCID     PIC X(12).                                      
      *                                                                         
      *                FOR  SPL5-PATH.                                          
           05  WS-PHYSICAL      PIC X(8)   VALUE 'PHYSICAL'.                    
           05  WS-LOGICAL       PIC X(8)   VALUE 'LOGICAL'.                     
      *                                                                         
      *                FOR  SPL6-RETURN.                                        
           05  WS-RTNALL        PIC X(50)  VALUE 'ALL OCCURRENCES OF ELE        
      -    'MENT AND TYPE'.                                                     
           05  WS-RTNFIRST      PIC X(50)  VALUE 'FIRST OCCURRENCES OF E        
      -    'LEMENT AND TYPE'.                                                   
           SKIP2                                                                
       01  HEADING-1.                                                           
           05  HDR1-CCONTROL    PIC X      VALUE '1'.                           
           05  HDR1-LINE.                                                       
           10  FILLER           PIC X(37)  VALUE SPACES.                        
           10  FILLER           PIC X(32)  VALUE 'ENDEVOR INVENTORY REPO        
      -    'RT BY CCID'.                                                        
           10  FILLER           PIC X(42)  VALUE SPACES.                        
           10  FILLER           PIC X(5)   VALUE 'PAGE '.                       
           10  HDR1-PAGENO      PIC ZZ9.                                        
           10  FILLER           PIC X(3)   VALUE SPACES.                        
           SKIP1                                                                
       01  HEADING-2.                                                           
           05  HDR2-CCONTROL    PIC X      VALUE '0'.                           
           05  HDR2-LINE.                                                       
           10  FILLER           PIC X(8)   VALUE '  CCID: '.                    
           10  FILLER           PIC X      VALUE SPACE.                         
           10  HDR2-CCID        PIC X(12).                                      
           10  FILLER           PIC X(111) VALUE SPACES.                        
           SKIP1                                                                
       01  HEADING-3.                                                           
           05  HDR3-CCONTROL    PIC X      VALUE '0'.                           
           05  HDR3-LINE.                                                       
           10  FILLER           PIC X(12)  VALUE '  ELEMENT'.                   
           10  FILLER           PIC X(9)   VALUE ' TYPE'.                       
           10  FILLER           PIC X(6)   VALUE ' VV.LL'.                      
           10  FILLER           PIC X(8)   VALUE ' DATE'.                       
           10  FILLER           PIC X(6)   VALUE ' TIME'.                       
           10  FILLER           PIC X(9)   VALUE ' USER'.                       
           10  FILLER           PIC X(9)   VALUE ' ENVIRON'.                    
           10  FILLER           PIC X(4)   VALUE ' SID'.                        
           10  FILLER           PIC X(9)   VALUE ' SYSTEM'.                     
           10  FILLER           PIC X(9)   VALUE ' SUBSYS'.                     
           10  FILLER           PIC X(41)  VALUE ' COMMENT'.                    
           10  FILLER           PIC X(10)  VALUE SPACES.                        
           SKIP1                                                                
       01  PRINTAREA.                                                           
           05  PRT-CCONTROL     PIC X.                                          
           05  PRT-DATA         PIC X(132).                                     
           SKIP1                                                                
       01  SPECLINE1.                                                           
           05  SPL1-CCONTROL    PIC X      VALUE '-'.                           
           05  FILLER           PIC X(2)   VALUE SPACES.                        
           05  FILLER           PIC X(25)  VALUE ' USER SPECIFICATIONS:         
      -    '  '.                                                                
           05  FILLER           PIC X(105) VALUE SPACES.                        
           SKIP1                                                                
       01  SPECLINE2.                                                           
           05  SPL2-CCONTROL    PIC X      VALUE ' '.                           
           05  FILLER           PIC X(9)   VALUE SPACES.                        
           05  FILLER           PIC X(14)  VALUE 'FROM  ENVIRON:'.              
           05  SPL2-ENVIRON     PIC X(8).                                       
           05  FILLER           PIC X(8)   VALUE '  STGID:'.                    
           05  SPL2-SID         PIC X.                                          
           05  FILLER           PIC X(9)   VALUE '  SYSTEM:'.                   
           05  SPL2-SYSTEM      PIC X(8).                                       
           05  FILLER           PIC X(9)   VALUE '  SUBSYS:'.                   
           05  SPL2-SUBSYS      PIC X(8).                                       
           05  FILLER           PIC X(10)  VALUE '  ELEMENT:'.                  
           05  SPL2-ELEMENT     PIC X(10).                                      
           05  FILLER           PIC X(7)   VALUE '  TYPE:'.                     
           05  SPL2-TYPE        PIC X(8).                                       
           05  FILLER           PIC X(23)  VALUE SPACES.                        
           SKIP1                                                                
       01  SPECLINE3.                                                           
           05  SPL3-CCONTROL    PIC X      VALUE ' '.                           
           05  FILLER           PIC X(9)   VALUE SPACES.                        
           05  FILLER           PIC X(14)  VALUE 'TO    ENVIRON:'.              
           05  SPL3-ENVIRON     PIC X(8).                                       
           05  FILLER           PIC X(8)   VALUE '  STGID:'.                    
           05  SPL3-SID         PIC X.                                          
           05  FILLER           PIC X(92)  VALUE SPACES.                        
           SKIP1                                                                
       01  SPECLINE4.                                                           
           05  SPL4-CCONTROL    PIC X      VALUE ' '.                           
           05  FILLER           PIC X(9)   VALUE SPACES.                        
           05  FILLER           PIC X(17)  VALUE 'SEARCH SETTING - '.           
           05  SPL4-SEARCH      PIC X(20).                                      
           05  FILLER           PIC X(86)   VALUE SPACES.                       
           SKIP1                                                                
       01  SPECLINE5.                                                           
           05  SPL5-CCONTROL    PIC X      VALUE ' '.                           
           05  FILLER           PIC X(9)   VALUE SPACES.                        
           05  FILLER           PIC X(15)  VALUE 'PATH SETTING - '.             
           05  SPL5-PATH        PIC X(8).                                       
           05  FILLER           PIC X(100)  VALUE SPACES.                       
           SKIP1                                                                
       01  SPECLINE6.                                                           
           05  SPL6-CCONTROL    PIC X      VALUE ' '.                           
           05  FILLER           PIC X(9)   VALUE SPACES.                        
           05  FILLER           PIC X(8)   VALUE 'PROCESS '.                    
           05  SPL6-RETURN      PIC X(50).                                      
           05  FILLER           PIC X(65)   VALUE SPACES.                       
           SKIP1                                                                
       01  SPECLINE7.                                                           
           05  SPL7-CCONTROL    PIC X      VALUE ' '.                           
           05  FILLER           PIC X(9)   VALUE SPACES.                        
           05  SPL7-BASE        PIC X(20).                                      
           05  FILLER           PIC X(103)   VALUE SPACES.                      
           SKIP1                                                                
       01  SPECLINE8.                                                           
           05  SPL8-CCONTROL    PIC X      VALUE ' '.                           
           05  FILLER           PIC X(25)  VALUE SPACES.                        
           05  SPL8-COMMENT     PIC X(80).                                      
           05  FILLER           PIC X(27)   VALUE SPACES.                       
           SKIP1                                                                
       01  DETAIL-1.                                                            
           05  DET1-CCONTROL    PIC X      VALUE ' '.                           
           05  FILLER           PIC XX     VALUE SPACES.                        
           05  DET1-ELEMENT     PIC X(10).                                      
           05  FILLER           PIC X      VALUE SPACE.                         
           05  DET1-TYPE        PIC X(8).                                       
           05  FILLER           PIC X      VALUE SPACE.                         
           05  DET1-VV          PIC XX.                                         
           05  FILLER           PIC X      VALUE '.'.                           
           05  DET1-LL          PIC XX.                                         
           05  FILLER           PIC X      VALUE SPACE.                         
           05  DET1-DATE        PIC X(7).                                       
           05  FILLER           PIC X      VALUE SPACE.                         
           05  DET1-TIME        PIC X(5).                                       
           05  FILLER           PIC X      VALUE SPACE.                         
           05  DET1-USER        PIC X(8).                                       
           05  FILLER           PIC X      VALUE SPACE.                         
           05  DET1-ENVIRON     PIC X(8).                                       
           05  FILLER           PIC X(2)   VALUE SPACE.                         
           05  DET1-SID         PIC X.                                          
           05  FILLER           PIC X(2)   VALUE SPACES.                        
           05  DET1-SYSTEM      PIC X(8).                                       
           05  FILLER           PIC X      VALUE SPACE.                         
           05  DET1-SUBSYS      PIC X(8).                                       
           05  FILLER           PIC X      VALUE SPACE.                         
           05  DET1-COMMENT     PIC X(40).                                      
           05  FILLER           PIC X(10)  VALUE SPACES.                        
           SKIP1                                                                
       01  DETAIL-RECORD.                                                       
           05  DETR-KEY.                                                        
               10  DETR-CCID    PIC X(12).                                      
               10  DETR-ELEMENT PIC X(10).                                      
               10  DETR-TYPE    PIC X(8).                                       
               10  DETR-ENVIRON PIC X(8).                                       
               10  DETR-SID     PIC X.                                          
               10  DETR-SYSTEM  PIC X(8).                                       
               10  DETR-SUBSYS  PIC X(8).                                       
           05  DETR-COMMENT     PIC X(40).                                      
           05  DETR-USER        PIC X(8).                                       
           05  DETR-DATE        PIC X(7).                                       
           05  DETR-TIME        PIC X(5).                                       
           05  DETR-VV          PIC X(2).                                       
           05  DETR-LL          PIC X(2).                                       
       01  SAVE-DETAIL-RECORD   PIC X(132).                                     
           SKIP1                                                                
       01  WS-REQUEST                    PIC X(4092).                           
           SKIP2                                                                
       01  WS-RESPONSE                   PIC X(4092).                           
           SKIP2                                                                
       COPY ECCCNST.                                                            
           SKIP2                                                                
       COPY ECHAACTL.                                                           
           SKIP2                                                                
       COPY ECHAEELM.                                                           
               10  AEELM-RS-RECDAREA     PIC X(4092).                           
               10  AEELM-RS-EC-LVL-REC REDEFINES AEELM-RS-RECDAREA.             
                   15  EC-LVL-PP.                                               
                       20  EC-LVL-P1     PIC X.                                 
                       20  EC-LVL-P2     PIC X.                                 
                   15  EC-LVL-VV.                                               
                       20 EC-LVL-V1      PIC X.                                 
                       20 EC-LVL-V2      PIC X.                                 
                   15  EC-LVL-LL.                                               
                       20 EC-LVL-L1      PIC X.                                 
                       20 EC-LVL-L2      PIC X.                                 
                   15  FILLER            PIC X(6).                              
                   15  EC-LVL-USER       PIC X(8).                              
                   15  FILLER            PIC X(1).                              
                   15  EC-LVL-DATE       PIC X(7).                              
                   15  FILLER            PIC X.                                 
                   15  EC-LVL-TIME       PIC X(5).                              
                   15  FILLER            PIC X.                                 
                   15  EC-LVL-STMT       PIC X(8).                              
                   15  FILLER            PIC X.                                 
                   15  EC-LVL-CCID       PIC X(12).                             
                   15  FILLER            PIC X.                                 
                   15  EC-LVL-COMMENT    PIC X(40).                             
                   15  FILLER            PIC X(927).                            
           SKIP2                                                                
       COPY ECHALELM.                                                           
           SKIP2                                                                
      *                                                                         
       PROCEDURE DIVISION.                                                      
       MAIN-LINE.                                                               
           OPEN INPUT  INPUT-FILE.                                              
           OPEN OUTPUT OUTPUT-REPORT.                                           
       MAIN-LOOP.                                                               
           PERFORM A1000-PROCESS-INPUT THRU                                     
                   A1009-EXIT.                                                  
           IF INCARD-ALL-DONE                                                   
               GO TO MAIN-EXIT.                                                 
           PERFORM A1010-GET-ELEMENT-LIST THRU                                  
                   A1019-EXIT.                                                  
           IF NO-ELEMENTS OR CALL-ERROR                                         
               GO TO MAIN-EXIT.                                                 
           PERFORM A1020-PROCESS-ELEMENT-LIST THRU                              
                   A1029-EXIT.                                                  
           IF CALL-ERROR                                                        
               GO TO MAIN-EXIT.                                                 
           GO TO MAIN-LOOP.                                                     
       MAIN-EXIT.                                                               
           PERFORM A1030-TERMINATION THRU                                       
                   A1039-EXIT.                                                  
           STOP RUN.                                                            
       EJECT                                                                    
       A1000-PROCESS-INPUT.                                                     
           READ INPUT-FILE AT END GO TO A1000-EOF.                              
           PERFORM B1000-WRITE-SPECIFICATION THRU                               
                   B1009-EXIT.                                                  
           IF INCARD-COMMENT = '*'                                              
              GO TO A1000-PROCESS-INPUT.                                        
           MOVE +60 TO WS-LINECNT.                                              
           GO TO A1009-EXIT.                                                    
       A1000-EOF.                                                               
            MOVE 1 TO INCARD-STATUS.                                            
       A1009-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       A1010-GET-ELEMENT-LIST.                                                  
            PERFORM B1010-LIST-AACTL-BLOCK THRU                                 
                    B1019-EXIT.                                                 
            PERFORM B1020-ALELM-BLOCK THRU                                      
                    B1029-EXIT.                                                 
            MOVE 1 TO API-STATUS.                                               
            PERFORM C1000-ENDEVOR-CALL THRU                                     
                    C1009-EXIT.                                                 
       A1019-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       A1020-PROCESS-ELEMENT-LIST.                                              
            OPEN INPUT  EXT1-FILE.                                              
            MOVE 1 TO EXT1-FILE-STATUS.                                         
            OPEN OUTPUT WORK-FILE.                                              
            MOVE 1 TO WORK-FILE-STATUS.                                         
      *                                                                         
       A1020-LOOP.                                                              
            READ EXT1-FILE INTO ALELM-RS                                        
                  AT END GO TO A1020-EOF.                                       
      *     DISPLAY ALELM-RS(15:52).                                            
            PERFORM B1030-EXTRACT-AACTL-BLOCK THRU                              
                    B1039-EXIT.                                                 
            PERFORM B1040-AEELM-BLOCK THRU                                      
                    B1049-EXIT.                                                 
            PERFORM C1000-ENDEVOR-CALL THRU                                     
                    C1009-EXIT.                                                 
            IF CALL-ERROR                                                       
               GO TO A1029-EXIT.                                                
            PERFORM B1050-PROCESS-ELEMENT THRU                                  
                    B1059-EXIT.                                                 
            GO TO A1020-LOOP.                                                   
      *                                                                         
       A1020-EOF.                                                               
            MOVE 0 TO WORK-FILE-STATUS.                                         
            CLOSE WORK-FILE.                                                    
            CLOSE EXT1-FILE.                                                    
            MOVE 0 TO EXT1-FILE-STATUS.                                         
      *                                                                         
            SORT SORT-FILE                                                      
                ASCENDING KEY SORT-KEY                                          
                WITH DUPLICATES IN ORDER                                        
                USING WORK-FILE                                                 
                GIVING SORTED-FILE.                                             
      *                                                                         
            PERFORM B1060-DETAIL-REPORT THRU                                    
                    B1069-EXIT.                                                 
       A1029-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       A1030-TERMINATION.                                                       
            IF API-ACTIVE                                                       
               PERFORM B1070-AACTL-SHUTDOWN-BLOCK THRU                          
                       B1079-EXIT                                               
               MOVE 1 TO API-CALL-TYPE                                          
               PERFORM C1000-ENDEVOR-CALL THRU                                  
                       C1009-EXIT.                                              
            CLOSE INPUT-FILE.                                                   
            CLOSE OUTPUT-REPORT.                                                
            IF EXT1-OPEN                                                        
               CLOSE EXT1-FILE.                                                 
            IF WORK-OPEN                                                        
               CLOSE WORK-FILE.                                                 
       A1039-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       B1000-WRITE-SPECIFICATION.                                               
            MOVE 1 TO WS-PRINT-SW.                                              
            IF INCARD-COMMENT = '*'                                             
               MOVE INCARD TO SPL8-COMMENT                                      
               MOVE SPECLINE8 TO PRINTAREA                                      
               PERFORM W1000-WRITE THRU                                         
                       W1009-EXIT                                               
               GO TO B1009-EXIT.                                                
            MOVE SPECLINE1 TO PRINTAREA.                                        
            PERFORM W1000-WRITE THRU                                            
                    W1009-EXIT.                                                 
            MOVE INCARD-ENV     TO SPL2-ENVIRON.                                
            MOVE INCARD-STG-ID  TO SPL2-SID.                                    
            MOVE INCARD-SYSTEM  TO SPL2-SYSTEM.                                 
            MOVE INCARD-SUBSYS  TO SPL2-SUBSYS.                                 
            MOVE INCARD-ELEMENT TO SPL2-ELEMENT.                                
            MOVE INCARD-TYPE    TO SPL2-TYPE.                                   
            MOVE SPECLINE2 TO PRINTAREA.                                        
            PERFORM W1000-WRITE THRU                                            
                    W1009-EXIT.                                                 
            MOVE INCARD-TOENV    TO SPL3-ENVIRON.                               
            MOVE INCARD-TOSTG-ID TO SPL3-SID.                                   
            MOVE SPECLINE3 TO PRINTAREA.                                        
            PERFORM W1000-WRITE THRU                                            
                    W1009-EXIT.                                                 
            IF INCARD-SEARCH = 'N'                                              
               MOVE WS-NONE TO SPL4-SEARCH.                                     
            IF INCARD-SEARCH = 'B'                                              
               MOVE WS-BETW TO SPL4-SEARCH.                                     
            IF INCARD-SEARCH = 'R'                                              
               MOVE WS-RANGE TO SPL4-SEARCH.                                    
            IF INCARD-SEARCH = 'A'                                              
               MOVE WS-ALL   TO SPL4-SEARCH.                                    
            IF INCARD-SEARCH = 'E'                                              
               MOVE WS-NEXT  TO SPL4-SEARCH.                                    
            MOVE SPECLINE4 TO PRINTAREA.                                        
            PERFORM W1000-WRITE THRU                                            
                    W1009-EXIT.                                                 
            IF INCARD-PATH = 'P'                                                
               MOVE WS-PHYSICAL TO SPL5-PATH.                                   
            IF INCARD-PATH = 'L'                                                
               MOVE WS-LOGICAL  TO SPL5-PATH.                                   
            MOVE SPECLINE5 TO PRINTAREA.                                        
            PERFORM W1000-WRITE THRU                                            
                    W1009-EXIT.                                                 
            IF INCARD-RETURN = 'A'                                              
               MOVE WS-RTNALL   TO SPL6-RETURN.                                 
            IF INCARD-RETURN = 'F'                                              
               MOVE WS-RTNFIRST TO SPL6-RETURN.                                 
            MOVE SPECLINE6 TO PRINTAREA.                                        
            PERFORM W1000-WRITE THRU                                            
                    W1009-EXIT.                                                 
            IF INCARD-INCBASE = 'N'                                             
               MOVE WS-NOBASE    TO SPL7-BASE                                   
            ELSE                                                                
               MOVE WS-INBASE    TO SPL7-BASE.                                  
            MOVE SPECLINE7 TO PRINTAREA.                                        
            PERFORM W1000-WRITE THRU                                            
                    W1009-EXIT.                                                 
       B1009-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       B1010-LIST-AACTL-BLOCK.                                                  
            MOVE ZEROS      TO AACTL-RTNCODE.                                   
            MOVE ZEROS      TO AACTL-REASON.                                    
            MOVE ZEROS      TO AACTL-SELECTED.                                  
            MOVE ZEROS      TO AACTL-RETURNED.                                  
            MOVE 'N'        TO AACTL-SHUTDOWN.                                  
            MOVE 'MSG3FILE' TO AACTL-MSG-DDN.                                   
            MOVE 'EXT1ELM ' TO AACTL-LIST-DDN.                                  
            MOVE SPACES     TO AACTL-HI-MSGID.                                  
       B1019-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       B1020-ALELM-BLOCK.                                                       
            MOVE INCARD-PATH       TO ALELM-RQ-PATH.                            
            MOVE INCARD-RETURN     TO ALELM-RQ-RETURN.                          
            MOVE INCARD-SEARCH     TO ALELM-RQ-SEARCH.                          
            MOVE INCARD-ENV        TO ALELM-RQ-ENV.                             
            MOVE INCARD-STG-ID     TO ALELM-RQ-STG-ID.                          
            MOVE INCARD-SYSTEM     TO ALELM-RQ-SYSTEM.                          
            MOVE INCARD-SUBSYS     TO ALELM-RQ-SUBSYS.                          
            MOVE INCARD-ELEMENT    TO ALELM-RQ-ELM.                             
            MOVE INCARD-TYPE       TO ALELM-RQ-TYPE.                            
            MOVE INCARD-TOENV      TO ALELM-RQ-TOENV.                           
            MOVE INCARD-TOSTG-ID   TO ALELM-RQ-TOSTG-ID.                        
            MOVE INCARD-TOELEMENT  TO ALELM-RQ-TOELM.                           
      *                                                                         
            MOVE SPACES            TO ALELM-RS-DATAAREA.                        
      *                                                                         
            MOVE ALELM-RQ          TO WS-REQUEST.                               
            MOVE ALELM-RS          TO WS-RESPONSE.                              
       B1029-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       B1030-EXTRACT-AACTL-BLOCK.                                               
            MOVE ZEROS      TO AACTL-RTNCODE.                                   
            MOVE ZEROS      TO AACTL-REASON.                                    
            MOVE ZEROS      TO AACTL-SELECTED.                                  
            MOVE ZEROS      TO AACTL-RETURNED.                                  
            MOVE 'N'        TO AACTL-SHUTDOWN.                                  
            MOVE 'MSG3FILE' TO AACTL-MSG-DDN.                                   
            MOVE 'EXT2ELM ' TO AACTL-LIST-DDN.                                  
            MOVE SPACES     TO AACTL-HI-MSGID.                                  
       B1039-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       B1040-AEELM-BLOCK.                                                       
            MOVE 'B'               TO AEELM-RQ-FORMAT.                          
      *     MOVE 'C'               TO AEELM-RQ-FORMAT.                          
            MOVE 'E'               TO AEELM-RQ-RTYPE.                           
            MOVE ALELM-RS-ENV      TO AEELM-RQ-ENV.                             
            MOVE ALELM-RS-STG-ID   TO AEELM-RQ-STG-ID.                          
            MOVE ALELM-RS-SYSTEM   TO AEELM-RQ-SYSTEM.                          
            MOVE ALELM-RS-SUBSYS   TO AEELM-RQ-SUBSYS.                          
            MOVE ALELM-RS-ELEMENT  TO AEELM-RQ-ELM.                             
            MOVE ALELM-RS-TYPE     TO AEELM-RQ-TYPE.                            
      *                                                                         
            MOVE SPACES            TO AEELM-RS-DATAAREA.                        
      *                                                                         
            MOVE AEELM-RQ          TO WS-REQUEST.                               
            MOVE AEELM-RS          TO WS-RESPONSE.                              
       B1049-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
      *                                                                         
      *     THIS ROUTINE READS THE BROWSE DISPLAY FILE LOOKING FOR              
      *     THE FIRST LINE OF VERSION AND LEVEL INFORMATION. IF THE             
      *     FOUND ELEMENT HAS SIGNOUT INFORMATION, THE VV.LL INFO               
      *     WILL NOT BE FOUND ON LINE 16, BUT ON LINE 18.                       
      *                                                                         
       B1050-PROCESS-ELEMENT.                                                   
            OPEN INPUT  EXT2-FILE.                                              
            MOVE '0'    TO SAVE-SW.                                             
            MOVE SPACES TO WS-SAVE-CCID.                                        
       B1050-PRIME.                                                             
            READ EXT2-FILE INTO AEELM-RS                                        
                  AT END GO TO B1050-EOF.                                       
      *     DISPLAY '1 ' AEELM-RS-EC-LVL-REC(1:80).                             
            IF EC-LVL-P1 IS NOT = ' ' OR                                        
            EC-LVL-P1 IS = '*' OR                                               
            EC-LVL-P1 IS = '-'                                                  
               GO TO B1050-PRIME.                                               
            IF EC-LVL-P2 IS = '+'                                               
               GO TO B1050-PRIME.                                               
            IF EC-LVL-V1 = '0' OR '1' OR '2' OR '3' OR '4'                      
                        OR '5' OR '6' OR '7' OR '8' OR '9'                      
              NEXT SENTENCE                                                     
            ELSE                                                                
              GO TO B1050-PRIME.                                                
      *                                                                         
      *     WE SHOULD BE AT THE BASE LEVEL FOR THE ELEMENT WHEN                 
      *     WE FALL INTO THE LOOP..                                             
      *                                                                         
       B1050-LOOP.                                                              
            MOVE EC-LVL-CCID         TO DETR-CCID.                              
            MOVE EC-LVL-CCID         TO WS-SAVE-CCID.                           
            MOVE AEELM-RS-ELM        TO DETR-ELEMENT.                           
            MOVE AEELM-RS-TYPE       TO DETR-TYPE.                              
            MOVE AEELM-RS-ENV        TO DETR-ENVIRON.                           
            MOVE AEELM-RS-STG-ID     TO DETR-SID.                               
            MOVE AEELM-RS-SYSTEM     TO DETR-SYSTEM.                            
            MOVE AEELM-RS-SUBSYS     TO DETR-SUBSYS.                            
            MOVE EC-LVL-COMMENT      TO DETR-COMMENT.                           
            MOVE EC-LVL-USER         TO DETR-USER.                              
            MOVE EC-LVL-DATE         TO DETR-DATE.                              
            MOVE EC-LVL-TIME         TO DETR-TIME.                              
            MOVE EC-LVL-VV           TO DETR-VV.                                
            MOVE EC-LVL-LL           TO DETR-LL.                                
            MOVE EC-LVL-VV           TO WS-SAVE-VV.                             
            MOVE EC-LVL-LL           TO WS-SAVE-LL.                             
      *     DISPLAY 'B1050-LOOP WRITE'.                                         
            IF INCARD-INCBASE = 'N' AND                                         
                  SAVE-SW     = '0'                                             
                  MOVE '1'   TO SAVE-SW                                         
                  MOVE DETAIL-RECORD TO SAVE-DETAIL-RECORD                      
            ELSE                                                                
                  MOVE '2'   TO SAVE-SW                                         
                  WRITE WORK-DATA FROM DETAIL-RECORD.                           
                                                                                
            READ EXT2-FILE INTO AEELM-RS                                        
                  AT END GO TO B1050-EOF.                                       
      *     DISPLAY '2 ' AEELM-RS-EC-LVL-REC(1:80).                             
      *                                                                         
      *     REPORT GENERATE CCID IF IT'S NOT EQUAL TO CURRENT CCID              
      *                                                                         
            IF  EC-LVL-CCID NOT = WS-SAVE-CCID                                  
               IF AEELM-RS-EC-LVL-REC (1:9) = 'GENERATE'                        
                  MOVE WS-SAVE-VV TO EC-LVL-VV                                  
                  MOVE WS-SAVE-LL TO EC-LVL-LL                                  
                  GO TO B1050-EOF.                                              
            IF EC-LVL-P1 IS NOT = ' ' OR                                        
            EC-LVL-P1 IS = '*' OR                                               
            EC-LVL-P1 IS = '-'                                                  
               GO TO B1050-EOF.                                                 
            IF EC-LVL-P2 IS = '+'                                               
               GO TO B1050-EOF.                                                 
            IF EC-LVL-V1 = '0' OR '1' OR '2' OR '3' OR '4'                      
                        OR '5' OR '6' OR '7' OR '8' OR '9'                      
              GO TO B1050-LOOP.                                                 
       B1050-EOF.                                                               
      *     DISPLAY 'B1050-EOF'.                                                
            IF SAVE-SW     = '1'                                                
               WRITE WORK-DATA FROM SAVE-DETAIL-RECORD.                         
            CLOSE EXT2-FILE.                                                    
       B1059-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       B1060-DETAIL-REPORT.                                                     
            OPEN INPUT  SORTED-FILE.                                            
            MOVE 2 TO WS-PRINT-SW.                                              
       B1060-LOOP.                                                              
            READ SORTED-FILE INTO DETAIL-RECORD                                 
                  AT END GO TO B1060-EOF.                                       
            MOVE 0 TO WS-HDRPRT-SW.                                             
            IF DETR-CCID IS NOT = HDR2-CCID                                     
               MOVE DETR-CCID    TO HDR2-CCID                                   
               MOVE 1            TO WS-HDRPRT-SW.                               
            MOVE DETR-ELEMENT    TO DET1-ELEMENT.                               
            MOVE DETR-TYPE       TO DET1-TYPE.                                  
            MOVE DETR-ENVIRON    TO DET1-ENVIRON.                               
            MOVE DETR-SID        TO DET1-SID.                                   
            MOVE DETR-SYSTEM     TO DET1-SYSTEM.                                
            MOVE DETR-SUBSYS     TO DET1-SUBSYS.                                
            MOVE DETR-COMMENT    TO DET1-COMMENT.                               
            MOVE DETR-USER       TO DET1-USER.                                  
            MOVE DETR-DATE       TO DET1-DATE.                                  
            MOVE DETR-TIME       TO DET1-TIME.                                  
            MOVE DETR-VV         TO DET1-VV.                                    
            MOVE DETR-LL         TO DET1-LL.                                    
            MOVE DETAIL-1        TO PRINTAREA.                                  
            PERFORM W1000-WRITE THRU                                            
                    W1009-EXIT.                                                 
            GO TO B1060-LOOP.                                                   
       B1060-EOF.                                                               
            CLOSE SORTED-FILE.                                                  
       B1069-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       B1070-AACTL-SHUTDOWN-BLOCK.                                              
            MOVE ZEROS      TO AACTL-RTNCODE.                                   
            MOVE ZEROS      TO AACTL-REASON.                                    
            MOVE ZEROS      TO AACTL-SELECTED.                                  
            MOVE ZEROS      TO AACTL-RETURNED.                                  
            MOVE 'Y'        TO AACTL-SHUTDOWN.                                  
            MOVE 'MSG3FILE' TO AACTL-MSG-DDN.                                   
            MOVE SPACES     TO AACTL-LIST-DDN.                                  
            MOVE SPACES     TO AACTL-HI-MSGID.                                  
       B1079-EXIT.                                                              
            EXIT.                                                               
       C1000-ENDEVOR-CALL.                                                      
            MOVE 0 TO API-CALL-STATUS.                                          
            IF SHUTDOWN-ONLY                                                    
               CALL EAC-ENDEVOR-APINAME USING AACTL                             
               IF AACTL-RTNCODE = 0                                             
                  NEXT SENTENCE                                                 
               ELSE                                                             
                  MOVE 2 TO API-CALL-STATUS                                     
            ELSE                                                                
               CALL EAC-ENDEVOR-APINAME USING AACTL                             
                        WS-REQUEST WS-RESPONSE                                  
               IF AACTL-RTNCODE = 0                                             
                   NEXT SENTENCE                                                
               ELSE                                                             
                   IF AACTL-RTNCODE = 4 AND AACTL-REASON = 6                    
                      MOVE 1 TO API-CALL-STATUS                                 
                   ELSE                                                         
                      IF AACTL-RTNCODE > 12                                     
                         MOVE 2 TO API-CALL-STATUS.                             
       C1009-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       W1000-WRITE.                                                             
      *     DISPLAY 'LINECNT=' WS-LINECNT.                                      
            IF WS-LINECNT > 59                                                  
               PERFORM W1010-PRINT-HDR1 THRU                                    
                 W1019-EXIT.                                                    
            IF WS-PRINT-DETAIL AND WS-PRINT-SUBHDR                              
               COMPUTE WS-LINECNT = WS-LINECNT + 3                              
               IF WS-LINECNT > 59                                               
                  PERFORM W1010-PRINT-HDR1 THRU                                 
                    W1019-EXIT                                                  
                  COMPUTE WS-LINECNT = 4.                                       
            IF WS-PRINT-DETAIL AND WS-PRINT-SUBHDR                              
               WRITE REPORTLINE FROM HDR2-LINE AFTER ADVANCING                  
                     2 LINES                                                    
               WRITE REPORTLINE FROM HDR3-LINE AFTER ADVANCING                  
                     1 LINE.                                                    
            IF WS-PRT-CCONTROL = 3                                              
               ADD 3 TO WS-LINECNT                                              
            ELSE                                                                
               IF WS-PRT-CCONTROL = 2                                           
                  ADD 2 TO WS-LINECNT                                           
               ELSE                                                             
                  ADD 1 TO WS-LINECNT.                                          
            WRITE REPORTLINE FROM PRT-DATA AFTER ADVANCING                      
                  WS-PRT-CCONTROL LINES.                                        
       W1009-EXIT.                                                              
            EXIT.                                                               
            SKIP2                                                               
       W1010-PRINT-HDR1.                                                        
            MOVE 3 TO WS-PRT-CCONTROL.                                          
            COMPUTE WS-LINECNT = 1.                                             
            COMPUTE WS-PAGECNT = WS-PAGECNT + 1.                                
            MOVE WS-PAGECNT TO HDR1-PAGENO.                                     
            WRITE REPORTLINE FROM HDR1-LINE AFTER ADVANCING                     
                  TOP-OF-PAGE.                                                  
            IF WS-PRINT-DETAIL                                                  
               MOVE 1 TO WS-HDRPRT-SW                                           
               MOVE 1 TO WS-PRT-CCONTROL.                                       
       W1019-EXIT.                                                              
            EXIT.                                                               
