      SUBROUTINE LODAPP        
C        
C     THIS MODULE APPENDS NEW LOAD VECTORS (PAPP AND POAP) TO THE       
C     SUBSTRUCTURE  -NAME-.  THE NEW VECTORS ARE MERGED WITH ALREADY    
C     EXISTING (PVEC AND POVE) MATRICES OR ARE SIMPLY RECOPIED AS       
C     THE NEW PVEC AND POVE ITEMS. LOAP DATA IS ALSO MERGED WITH THE    
C     LODS DATA OR IS SIMPLY COPIED AS THE NEW LODS ITEM.        
C        
C     SOF ITEMS -        
C        
C     LOAP - APPENDED LOAD SET IDENTIFICATION TABLE        
C     PAPP - APPENDED LOAD MATRICES (G-SET)        
C     POAP - APPENDED LOAD MATRICES (O-SET)        
C     LODS - LOAD SET IDENTIFICATION TABLE **BECOMES THE NEW LODS**     
C     PVEC - LOAD MATRICES (G-SET)         **BECOMES THE NEW PVEC**     
C     POVE - LOAD MATRICES (O-SET)         **BECOMES THE NEW POVE**     
C        
      EXTERNAL        RSHIFT     ,ANDF        
      LOGICAL         LPAPP      ,LPVEC      ,LPOAP      ,LPOVE      ,  
     1                LMERG      ,LLSUB      ,MDIUP      ,DITUP        
      INTEGER         RSHIFT     ,ANDF       ,BUF        
      DIMENSION       IZ(1)      ,NN(2)      ,MCBLOC(7)  ,ADUMP(4000),  
     1                NPROG(2)   ,NAME(2)    ,NAMELL(2)  ,ICORX(1)      
      CHARACTER       UFM*23     ,UWM*25     ,UIM*29     ,SFM*25        
      COMMON /XMSSG / UFM        ,UWM        ,UIM        ,SFM        
      COMMON /BLANK / BUF(3)        
      COMMON /SYSTEM/ ISBUFF     ,LP        
      COMMON /PACKX / ITYPIN     ,ITYPOT     ,IFIRST     ,ILAST      ,  
     1                INCR        
      COMMON /PARMEG/ MCBK(7)    ,MCBK11(7)  ,MCBK21(7)  ,MCBK12(7)  ,  
     1                MCBK22(7)  ,LCORE      ,IRULE        
CZZ   COMMON /ZZLODA/ RZ(1)        
      COMMON /ZZZZZZ/ RZ(1)        
      COMMON /NAMES / IRD        ,IRDREW     ,IWRT       ,IWRTRW     ,  
     1                IREW       ,INOREW     ,IEFNRW     ,IRSP       ,  
     2                IRDP       ,ICSP       ,ICDP       ,ISQURE     ,  
     3                IRECT      ,IDIAG      ,IUPPER     ,ILOWER     ,  
     4                ISYM        
      COMMON /SOF   / DITDUM(6)  ,IODUM(8)   ,MDIDUM(4)  ,NXTDUM(15) ,  
     1                DITUP      ,MDIUP        
CZZ   COMMON /SOFPTR/ ICORX        
      EQUIVALENCE     (ICORX(1)  ,RZ(1))        
      EQUIVALENCE     (RZ(1)     ,IZ(1))        
      DATA    IPAPP , IPOAP      /101        ,102        /        
      DATA    ISCR1 , ISCR2      ,ISCR3      ,ISCR4      ,ISCR5      ,  
     1        ISCR6 , ISCR7      ,ISCR8      /        
     2        301   , 302        ,303        ,304        ,305        ,  
     3        306   , 307        ,308        /        
      DATA    NPAPP , NPOAP      ,NPVEC      ,NPOVE      ,        
     1        NLOAP , NLODS      /        
     2        4HPAPP, 4HPOAP     ,4HPVEC     ,4HPOVE     ,        
     3        4HLOAP, 4HLODS     /        
      DATA    NPROG              /4HLODA     ,4HPP       /        
      DATA    BLNK  / 4H         /        
C        
C     INITIALIZE PARAMETERS        
C        
      CALL TMTOGO (ITIME1)        
      NAME(1) = BUF(1)        
      NAME(2) = BUF(2)        
      IDRY    = BUF(3)        
      NCORE = KORSZ(IZ(1))        
C        
C     INITIALIZE OPEN CORE - THERE ARE NIZ WORDS AVAILABLE        
C        
      IB1  = NCORE - (ISBUFF+1)        
      IB2  = IB1 - ISBUFF - 1        
      IB3  = IB2 - ISBUFF        
      IBUF1= IB3 - ISBUFF        
      NIZ  = IBUF1 - 1        
      NSTART = 1        
C        
C     TEST CORE        
C        
      NCHAVE = NIZ        
      IF (NCHAVE .LE. 0) GO TO 7001        
      CALL SOFOPN (IZ(IB1),IZ(IB2),IZ(IB3))        
C        
C     CHECK STATUS OF SUBSTRUCTURE BEING REFERENCED - NAME        
C        
      CALL SFETCH (NAME,NLODS,3,IGO)        
      IF (IGO  .EQ. 4) GO TO 7002        
      IF (IDRY .LT. 0) GO TO 1001        
C        
C     CHECK LOCATION OF THE PAPP VECTOR - EITHER ON FILE IPAPP OR SOF   
C        
      IZ(1) = IPAPP        
      CALL RDTRL (IZ(1))        
      IF (IZ(1) .GT. 0) GO TO 10        
      LPAPP = .FALSE.        
      IUAPP = ISCR1        
      NITEM = NPAPP        
      CALL MTRXI (IUAPP,NAME,NITEM,0,ITEST)        
      IF (ITEST .NE. 1) GO TO 7003        
      LPAPP = .TRUE.        
      GO TO 20        
   10 LPAPP = .TRUE.        
      IUAPP = IPAPP        
   20 CONTINUE        
C        
C     CHECK STATUS OF THE POAP VECTOR        
C     FIRST GET THE NAME OF THE LOWER LEVEL SUBSTRUCTURE WHERE        
C     THE POAP ITEM TO BE USED IS LOCATED        
C        
      LPOAP = .FALSE.        
      LLSUB = .FALSE.        
      CALL FNDLVL (NAME,NAMELL)        
      IF (NAMELL(1) .EQ. BLNK) GO TO 7002        
      IF (NAME(1).NE.NAMELL(1) .OR. NAME(2).NE.NAMELL(2)) LLSUB = .TRUE.
      IF (.NOT.LLSUB) GO TO 40        
      IZ(1) = IPOAP        
      CALL RDTRL (IZ(1))        
      IF (IZ(1) .GT. 0) GO TO 30        
      IUOAP = ISCR2        
      NITEM = NPOAP        
      CALL MTRXI (IUOAP,NAMELL,NITEM,0,ITEST)        
      IF (ITEST .NE. 1) GO TO 40        
      LPOAP = .TRUE.        
      GO TO 40        
   30 LPOAP = .TRUE.        
      IUOAP = IPOAP        
   40 CONTINUE        
C        
C     ESTABLISH TYPE OF CASE BEING RUN, I.E. THE CASE NO. BEING DEFINED 
C     BY  NN(1) AND NN(2).        
C        
      NN(1) = 0        
      NN(2) = 0        
C        
C     CHECK STATUS OF PVEC AND POVE VECTORS        
C        
C     1) PVEC        
C        
      LPVEC = .TRUE.        
      IZ(1) = 0        
      CALL SOFTRL (NAME,NPVEC,IZ(1))        
      IF (IZ(1) .NE. 1) LPVEC = .FALSE.        
C        
C     2) POVE        
C        
      LPOVE = .TRUE.        
      IZ(1) = 0        
      IF (LLSUB) CALL SOFTRL (NAMELL,NPOVE,IZ(1))        
      IF (IZ(1) .NE. 1) LPOVE = .FALSE.        
C        
C     KNOWING THE STATUS OF PAPP, PVEC, POAP, POVE DEFINE CASE NO.      
C        
      IF (LPAPP) GO TO 50        
      NN(1) = 4        
      IF (LPVEC) NN(1) = 3        
      GO TO 60        
   50 NN(1) = 2        
      IF (LPVEC) NN(1) = 1        
   60 CONTINUE        
      IF (LPOAP) GO TO 70        
      NN(2) = 4        
      IF (LPOVE) NN(2) = 3        
      GO TO 80        
   70 NN(2) = 2        
      IF (LPOVE) NN(2) = 1        
   80 IGO = NN(2)        
C        
C     KNOWING NN(1) AND NN(2) THE CASE IS DEFINED        
C        
      IF (NN(1) .EQ. 1) GO TO (1001,7004,7004,1001), IGO        
      IF (NN(1) .EQ. 2) GO TO (7004,1001,7004,1001), IGO        
      IF (NN(1) .EQ. 3) GO TO 7004        
      IF (NN(1) .EQ. 4) GO TO 7004        
C        
C     READ IN LOAP DATA        
C        
 1001 IRW = 1        
      CALL SFETCH (NAME,NLOAP,IRW,ITLOAP)        
      IF (ITLOAP .GT. 1) GO TO 7003        
      CALL SUREAD (IZ(NSTART),-1,NWDS,ICHK)        
      NL = IZ(NSTART+2)        
      NS = IZ(NSTART+3)        
      NFINI  = 4 + NS*3 + NL        
      NSTART = 5 + NS*2        
      NAS = 1        
      NAF = NFINI        
      NCHAVE = NFINI        
      NSUBS  = NS        
      IF (NCHAVE .GT. NIZ) GO TO 7001        
      NBASN  = 4 + NSUBS*2 + 1        
      DO 90 ILOOP = 1,NSUBS        
      CALL SUREAD (IZ(NBASN),-1,NWDS,ICHK)        
   90 NBASN  = IZ(NBASN) + 1 + NBASN        
      NSTART = NAF + 1        
      NPS    = NSTART        
      LMERG  = .TRUE.        
C        
C     IF DRY RUN (IDRY .LT. 0) CHECK FOR LODS ITEM        
C        
      IF (IDRY .LT. 0) GO TO 1002        
      IF (LPVEC) GO TO 1002        
C        
C     SIMPLE COPY OF NEW APPENDED LOADS TO SOF        
C        
C     NEW  LODS  ITEM        
C        
      NITEM = NLODS        
      LMERG = .FALSE.        
      ITEST = 3        
      IRW   = 2        
      CALL SFETCH (NAME,NITEM,IRW,ITEST)        
      IF (ITEST .NE. 3) GO TO 7005        
      NWDS = 4 + 2*IZ(NAS+3)        
      CALL SUWRT (IZ(NAS),NWDS,2)        
      NBASN = NAS + NWDS        
      DO 101 N = 1,NSUBS        
      NWDS = IZ(NBASN) + 1        
      CALL SUWRT (IZ(NBASN),NWDS,2)        
      NBASN = NBASN + NWDS        
  101 CONTINUE        
C        
C     END OF ITEM CALL TO SUWRT        
C        
      CALL SUWRT (0,0,3)        
C        
C     NEW  PVEC  ITEM        
C        
      CALL MTRXO (IUAPP,NAME,NPVEC,0,ITEST)        
C        
C     NEW  POVE  ITEM  IF ANY        
C        
      CALL BUG (NPROG(1),101,LPOAP,1)        
      IF (LPOAP) CALL MTRXO (IUOAP,NAMELL,NPOVE,0,ITEST)        
C        
C     MODULE IS FINISHED WITH THE DIRECT COPY CASE        
C        
      GO TO 7000        
 1002 CONTINUE        
C        
C     ITS BEEN DETERMINED THAT A MERGE OPERATION WILL TAKE PLACE.  THE  
C     ONLY CHECK NOW IS TO SEE IF A LODS ITEM EXISTS.        
C        
      IRW  = 1        
      NITEM = NLODS        
      CALL SFETCH (NAME,NITEM,IRW,ITLODS)        
      IF (ITLODS.NE.1 .AND. IDRY.GT.0) GO TO 7003        
      IF (ITLODS.NE.1 .AND. IDRY.LT.0) GO TO 9999        
      CALL SUREAD (IZ(NSTART),-1,NWDS,ICHK)        
      NCNT = NWDS + NAF        
      NL   = IZ(NPS+2)        
      NS   = IZ(NPS+3)        
      NFINI= NPS + 3 + 3*NS + NL        
      NPF  = NFINI        
      NSTART = NPF + 1        
      NCHAVE = NFINI        
      IF (NCHAVE .GT. NIZ) GO TO 7001        
      NBASN = NPS + 3 + 2*NSUBS + 1        
      DO 91 ILOOP = 1,NSUBS        
      CALL SUREAD (IZ(NBASN),-1,NWDS,ICHK)        
   91 NBASN = NBASN + IZ(NBASN) + 1        
      NLDSA = IZ(NAS+2)        
      NLDSP = IZ(NPS+2)        
      NLOADS= NLDSA + NLDSP        
      NBASA = NAS + 3 + 2*NSUBS + 1        
      NBASP = NPS + 3 + 2*NSUBS + 1        
      NLBASA= IZ(NBASA)        
      NLBASP= IZ(NBASP)        
C        
C     CHECK FOR DUPLICATE LOAD IDS IN THE  LOAP  AND  LODS  ITEMS.      
C        
      DO 102 L = 1,NSUBS        
      IF (NLBASP .EQ. 0 .OR. NLBASA .EQ. 0) GO TO 104        
      DO 103 M = 1,NLBASA        
      DO 103 N = 1,NLBASP        
      IF( IZ(NBASA+M).NE.IZ(NBASP+N).OR.IZ(NBASA+M).EQ.0 ) GO TO 103    
      WRITE  (LP,6955) UFM,IZ(NBASA+M),NAME        
 6955 FORMAT (A23,' 6955, DUPLICATE LOAD IDS DURING APPEND OPERATION.', 
     1       '  LOAD ID NO.',I9,' SUBSTRUCTURE ',2A4)        
      IDRY = -2        
  103 CONTINUE        
  104 NBASA = NBASA + NLBASA + 1        
      NBASP = NBASP + NLBASP + 1        
      NLBASA = IZ(NBASA)        
      NLBASP = IZ(NBASP)        
  102 CONTINUE        
C        
C     END OF RUN IF A DRY RUN(IDRY .LT. 0)        
C        
      IF (IDRY .LT. 0) GO TO 9999        
C        
C     CALCULATE LENGTH OF THE MERG AND  N E W  LODS TABLE AND THEIR     
C     LOCATIONS IN OPEN CORE        
C        
      LMERGT = 2*NSUBS        
      NMERGS = NPF + 1        
      NMERGF = NPF + LMERGT        
      LNEWLT = 4 + 3*NSUBS + NLOADS        
      NNEWS  = NMERGF + 1        
      NNEWF  = NMERGF + LNEWLT        
C        
C     CREATE THE NEW LODS TABLE IN OPEN CORE - GROUP  0  FIRST        
C        
      IZ(NNEWS  ) = IZ(NAS  )        
      IZ(NNEWS+1) = IZ(NAS+1)        
      IZ(NNEWS+2) = NLOADS        
      IZ(NNEWS+3) = NSUBS        
      NLOOP = 2*NSUBS        
      NNEW1 = NNEWS + 3        
      NDEL1 = NAS + 3        
      DO 105 NS1 = 1,NLOOP        
  105 IZ(NNEW1+NS1) = IZ(NDEL1+NS1)        
C        
C     COMPLETION OF THE NEW LODS TABLE - GROUPS  1  THRU  NSUBS  --  AND
C     CREATION OF THE MERGE TABLE        
C        
      NBASN  = NNEW1 + NLOOP + 1        
      NBASA  = NAS + 3 + 2*NSUBS + 1        
      NBASP  = NPS + 3 + 2*NSUBS + 1        
      NLOADA = IZ(NBASA)        
      NLOADP = IZ(NBASP)        
      NLOADN = NLOADA + NLOADP        
      NMERGN = NMERGS        
      IMERGN = 1        
C        
C     ZERO THE MERG TABLE LOCATION        
C        
      DO 109 I = 1,LMERGT        
  109 IZ(NPF+I) = 0        
      DO 106 ILOOP = 1,NSUBS        
      IZ(NBASN) = NLOADN        
      IF (NLOADP .EQ. 0) GO TO 2108        
      DO 108 N = 1,NLOADP        
  108 IZ(NBASN+N) = IZ(NBASP+N)        
 2108 CONTINUE        
      NBASN = NBASN + NLOADP        
      IF (NLOADA .EQ. 0) GO TO 2107        
      DO 107 N = 1,NLOADA        
  107 IZ(NBASN+N) = IZ(NBASA+N)        
 2107 CONTINUE        
C        
C     LOCATION IN THE MERGE TABLE OF THE  1(S)        
C        
      IMERGN = IMERGN + NLOADP        
      IZ(NMERGN) = IMERGN        
      IMERGN = IMERGN + NLOADA        
      IZ(NMERGN+1) = NLOADA        
      NMERGN = NMERGN + 2        
      NBASN  = NBASN + NLOADA + 1        
      IF (ILOOP .EQ. NSUBS) GO TO 106        
      NBASA  = NBASA + NLOADA + 1        
      NBASP  = NBASP + NLOADP + 1        
      NLOADA = IZ(NBASA)        
      NLOADP = IZ(NBASP)        
      NLOADN = NLOADA + NLOADP        
  106 CONTINUE        
C        
C     END OF GENERATION OF NEW LODS ITEM AND CREATION OF MERGE TABLE    
C        
C     CALCULATE BEGINNING LOCATION OF MERGE VECTOR IN OPEN CORE        
C        
      NMRVCS = NNEWF + 1        
      NMERGN = NMERGS        
      NMRVCN = NMRVCS - 2        
      LVECT  = IZ(NNEWS+2)        
      NMRVCF = NNEWF + LVECT        
      NCHAVE = NMRVCF        
      IF (NCHAVE .GT. NIZ) GO TO 7001        
C        
C     FILL THE MERGE VECTOR WITH  1(S)  ACCORDING TO THE MERGE TABLE    
C        
C     1) ZERO FIRST        
C        
      DO 112 I = 1,LVECT        
  112 RZ(NMRVCS-1+I) = 0.        
C        
C     2) NOW FILL        
C        
      DO 110 ILOOP = 1,NSUBS        
      IDRC1 = IZ(NMERGN)        
      IDRC2 = IZ(NMERGN+1)        
      IF (IDRC2 .EQ. 0) GO TO 2111        
      DO 111 N = 1,IDRC2        
  111 RZ(NMRVCN+IDRC1+N) = 1.0        
 2111 CONTINUE        
      NMERGN = NMERGN + 2        
  110 CONTINUE        
C        
C     WRITE THE MERGE VECTOR ON SCRATCH  5  USING  PACK-SEE COMMON PACKX
C     THIS IS A COLUMN PARTITIONING VECTOR (REFERRED TO AS A ROW VECTOR 
C     BY MERGE)        
C        
      ITYPIN = 1        
      ITYPOT = 1        
      IFIRST = 1        
      ILAST  = LVECT        
      INCR   = 1        
      CALL GOPEN (ISCR5,IZ(IBUF1),IWRTRW)        
C        
C     ZERO THE TRAILER INFO. LOCATIONS        
C        
      DO 116 I = 1,7        
  116 MCBLOC(I) = 0        
      MCBLOC(1) = ISCR5        
      MCBLOC(3) = LVECT        
      MCBLOC(4) = IRECT        
      MCBLOC(5) = IRSP        
      CALL PACK (RZ(NMRVCS),ISCR5,MCBLOC(1))        
      CALL CLOSE (ISCR5,IREW)        
      CALL WRTTRL (MCBLOC(1))        
      IDUMP = -ISCR5        
      CALL DMPFIL (IDUMP,ADUMP,4000)        
C        
C     READ IN THE  PVEC  AND  POVE(IF EXISTS)  USING MTRXI        
C        
C     1) PVEC        
C        
      IUVEC = ISCR3        
      CALL MTRXI (IUVEC,NAME,NPVEC,0,ICHK)        
C        
C     2) POVE        
C        
      IUOVE = ISCR4        
      IF (LPOVE) CALL MTRXI (IUOVE,NAMELL,NPOVE,0,ICHK)        
C        
C     SET UP TO CALL MERGE FOR  PAPP  AND  PVEC        
C        
      IDUMP = -IUVEC        
      CALL DMPFIL (IDUMP,ADUMP,4000)        
      IDUMP = -IUAPP        
      CALL DMPFIL (IDUMP,ADUMP,4000)        
      ICORE = NMRVCF + 1        
      IZ(ICORE) = ISCR5        
      CALL RDTRL (IZ(ICORE))        
C        
C     SETUP NULL ROW PARTITIONING VECTOR USING  ISCR8        
C     THIS IS A ROW PARTITIONING VECTOR REFERRED TO AS A COLUMN VECTOR  
C     BY MERGE)        
C        
      MCBK11(1) = IUVEC        
      CALL RDTRL (MCBK11(1))        
      MCBK12(1) = IUAPP        
      CALL RDTRL (MCBK12(1))        
      DO 114 K = 1,7        
      MCBK21(K) = 0        
  114 MCBK22(K) = 0        
      IZ(ICORE+ 7) = ISCR8        
      IZ(ICORE+ 8) = 0        
      IZ(ICORE+ 9) = MCBK11(3)        
      IZ(ICORE+10) = IRECT        
      IZ(ICORE+11) = IRSP        
      IZ(ICORE+12) = 0        
      IZ(ICORE+13) = 0        
      NCNT = ICORE +13        
C        
      CALL GOPEN (ISCR8,IZ(IBUF1),IWRTRW)        
      ITYPIN = 1        
      ITYPOT = 1        
      IFIRST = 1        
      ILAST  = 1        
      INCR   = 1        
      CALL PACK (0,ISCR8,IZ(ICORE+7))        
      CALL CLOSE (ISCR8,IREW)        
      CALL WRTTRL (IZ(ICORE+7))        
      LCORE = IB3 - ICORE - 15        
      I = ICORE + 15        
      IRULE   = 0        
      MCBK(1) = ISCR6        
      MCBK(2) = MCBK11(2)+MCBK12(2)        
      MCBK(3) = MCBK11(3)        
      MCBK(4) = IRECT        
      MCBK(5) = MCBK11(5)        
      MCBK(6) = 0        
      MCBK(7) = 0        
      CALL MERGE (IZ(ICORE),IZ(ICORE+7),IZ(I))        
      CALL WRTTRL (MCBK(1))        
C        
C     SETUP TO MERGE  POVE  AND  POAP(IF THEY EXIST)        
C        
      IDUMP = -IUOVE        
      CALL DMPFIL (IDUMP,ADUMP,4000)        
      IDUMP = -IUOAP        
      CALL DMPFIL (IDUMP,ADUMP,4000)        
      IF (.NOT. LPOVE) GO TO 1005        
      MCBK11(1) = IUOVE        
      CALL RDTRL (MCBK11(1))        
      MCBK12(1) = IUOAP        
      CALL RDTRL (MCBK12(1))        
      DO 115 K = 1,7        
      MCBK21(K) = 0        
  115 MCBK22(K) = 0        
      IRULE   = 0        
      MCBK(1) = ISCR7        
      MCBK(2) = MCBK11(2)+MCBK12(2)        
      MCBK(3) = MCBK11(3)        
      MCBK(4) = IRECT        
      MCBK(5) = MCBK11(5)        
      MCBK(6) = 0        
      MCBK(7) = 0        
      CALL MERGE (IZ(ICORE),IZ(ICORE+7),IZ(I))        
      CALL WRTTRL (MCBK(1))        
C        
C     CHECK TIME REMAINING AND RETURN WITH USER FATAL MESSAGE IF NOT    
C     ENOUGH REMAINING        
C        
 1005 CALL TMTOGO (ITIME2)        
      IF (ITIME2 .LE. 0) GO TO 7007        
C        
C     CALCULATE TIME USED IN REACHING THIS LOCATION        
C        
      ITUSED = ITIME1 - ITIME2        
C        
C     CONTINUE IF ITIME2 IS GREATER THAN ITUSED        
C        
      IF (ITIME2 .LT. ITUSED) GO TO 7007        
C        
C     WRITE NEW LODS ITEM TO SOF        
C        
C     1) DELETE OLD LODS ITEM        
C        
      CALL DELETE (NAME,NLODS,ICHK)        
C        
C     DELETE LODS ITEMS ON ANY SUBSTRUCTURE SECONDARY TO NAME - THIS    
C     WILL ALLOW THE NEW LODS ITEM TO BE COPIED DURING FUTURE EQUIV     
C     OPERATIONS        
C        
      II = ITCODE (NLODS)        
      CALL FDSUB (NAME,IND)        
      CALL FMDI (IND,IMDI)        
      IPS = ANDF(ICORX(IMDI+1),1023)        
      IF (IPS .NE. 0) GO TO 118        
  117 ISS = ANDF(RSHIFT(ICORX(IMDI+1),10),1023)        
      IF (ISS .EQ. 0) GO TO 118        
      CALL FMDI (ISS,IMDI)        
      IBLK = ANDF(ICORX(IMDI+II),65535)        
      IF (IBLK .NE. 0 .AND. IBLK .NE. 65535) CALL RETBLK (IBLK)        
      ICORX(IMDI+II) = 0        
      MDIUP = .TRUE.        
      GO TO 117        
C        
C     2) BEGIN WRITING        
C        
  118 ICHK = 3        
      IRW  = 2        
      CALL SFETCH (NAME,NLODS,IRW,ICHK)        
      NWORDS = 4 + 2*IZ(NNEWS+3)        
      CALL SUWRT (IZ(NNEWS),NWORDS,2)        
      NBASN = NNEWS + NWORDS        
      DO 113 N = 1,NSUBS        
      NWORDS = IZ(NBASN) + 1        
      CALL SUWRT (IZ(NBASN),NWORDS,2)        
  113 NBASN = NBASN + NWORDS        
      CALL SUWRT (0,0,3)        
C        
C     WRITE NEW  PVEC  AND  POVE(IF IT EXISTS)  TO SOF        
C        
      CALL DELETE (NAME,NPVEC,ICHK)        
      CALL MTRXO (ISCR6,NAME,NPVEC,0,ICHK)        
      IF (LPOVE) CALL DELETE (NAMELL,NPOVE,ICHK)        
      IF (LPOVE) CALL MTRXO (ISCR7,NAMELL,NPOVE,0,ICHK)        
C        
      WRITE  (LP,6900) UIM,NAME        
 6900 FORMAT (A29,' 6900, LOADS HAVE BEEN SUCCESSFULLY APPENDED FOR ',  
     1       'SUBSTRUCTURE ',2A4)        
      GO TO 9999        
 7000 WRITE  (LP,6901) UIM,NAME        
 6901 FORMAT (A29,' 6901, ADDITIONAL LOADS HAVE BEEN SUCCESSFULLY ',    
     1       'MERGED FOR SUBSTRUCTURE ',2A4)        
      GO TO 9999        
 7001 WRITE  (LP,6951) UFM,NCHAVE        
 6951 FORMAT (A23,' 6951, INSUFFICIENT CORE TO LOAD TABLES', /5X,       
     1       'IN MODULE LODAPP, CORE =',I8)        
      CALL MESAGE (-8,NPROG,0)        
C        
 7002 WRITE  (LP,6952) SFM,NAME        
 6952 FORMAT (A25,' 6952, REQUESTED SUBSTRUCTURE ',2A4,        
     1       ' DOES NOT EXIST')        
      IDRY = -2        
      GO TO 9999        
 7003 WRITE  (LP,6101) SFM,NITEM,NAME        
 6101 FORMAT (A25,' 6101, REQUESTED SOF ITEM DOES NOT EXIST.  ITEM ',A4,
     1       ' SUBSTRUCTURE ',2A4)        
      IDRY = -2        
      GO TO 9999        
 7004 WRITE  (LP,6953) SFM,NAME        
 6953 FORMAT (A25,' 6953, A WRONG COMBINATION OF LOAD VECTORS EXISTS ', 
     1       'FOR SUBSTRUCTURE ',2A4)        
      IDRY = -2        
      GO TO 9999        
 7005 WRITE  (LP,6954) SFM,NITEM,NAME        
 6954 FORMAT (A25,' 6954, THE ,A4,62H ITEM EXISTS BUT HAS NO ',        
     1       'ASSOCIATED PVEC ITEM FOR SUBSTRUCTURE ',2A4)        
      IDRY = -2        
      GO TO 9999        
 7007 WRITE  (LP,6956) UFM,ITIME2        
 6956 FORMAT (A23,' 6956, INSUFFICIENT TIME REMAINING FOR MODULE ',     
     1       'LODAPP, TIME LEFT =',I8)        
      IDRY = -2        
 9999 CONTINUE        
      CALL SOFCLS        
C        
C     RETURN VALUE OF DRY PARAMETER        
C        
      BUF(3) = IDRY        
      RETURN        
      END        
