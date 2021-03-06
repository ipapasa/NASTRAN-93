      SUBROUTINE DDR1B (IN1,IN2,IOUT)        
C        
C     THIS ROUTINE REPLACES DISPLACEMNTS ON IN1 WITH DISPLACEMENTS ON   
C     IN2  AND WRITES ON  IOUT        
C        
      INTEGER SYSBUF, MCB(7)        
      COMMON /SYSTEM/ SYSBUF        
      COMMON /UNPAKX/ ITC,II,JJ,INCR        
CZZ   COMMON /ZZDDRB/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
C        
C        
      NZ = KORSZ(Z) - SYSBUF        
      CALL GOPEN (IN1,Z(NZ+1),0)        
      NZ = NZ - SYSBUF        
      CALL GOPEN (IN2,Z(NZ+1),0)        
      NZ = NZ - SYSBUF        
      CALL GOPEN (IOUT,Z(NZ+1),1)        
      MCB(1) = IN1        
      CALL RDTRL (MCB)        
      MCB(1) = IOUT        
      ND  = MCB(2)/3        
      ITC = MCB(5)        
      INCR = 1        
      MCB(2) = 0        
      MCB(6) = 0        
      MCB(7) = 0        
      DO 40 I = 1,ND        
      CALL SKPREC (IN1,1)        
      CALL CYCT2B (IN2,IOUT,1,Z,MCB)        
      CALL CYCT2B (IN1,IOUT,2,Z,MCB)        
   40 CONTINUE        
      CALL WRTTRL (MCB)        
      CALL CLOSE (IN1,1)        
      CALL CLOSE (IN2,1)        
      CALL CLOSE (IOUT,1)        
      RETURN        
      END        
