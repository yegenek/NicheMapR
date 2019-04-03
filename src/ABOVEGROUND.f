      SUBROUTINE ABOVEGROUND

C     NICHEMAPR: SOFTWARE FOR BIOPHYSICAL MECHANISTIC NICHE MODELLING

C     COPYRIGHT (C) 2018 MICHAEL R. KEARNEY AND WARREN P. PORTER

C     THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C     IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C     THE FREE SOFTWARE FOUNDATION, EITHER VERSION 3 OF THE LICENSE, OR (AT
C      YOUR OPTION) ANY LATER VERSION.

C     THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C     WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C     MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C     GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C     YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C     ALONG WITH THIS PROGRAM. IF NOT, SEE HTTP://WWW.GNU.ORG/LICENSES/.
C
C     COMPUTES ABOVEGROUND MICROCLIMATE TO WHICH THE ANIMAL IS EXPOSED

      USE AACOMMONDAT
      IMPLICIT NONE
      EXTERNAL FUN

      DOUBLE PRECISION A1,A2,A3,A4,A4B,A5,A6,ABSAN,ABSSB,AL,ALT,AMASS
      DOUBLE PRECISION ANDENS,AREF,ASIL,ASILN,ASILP,ATOT,BP,BREF,CP,CREF
      DOUBLE PRECISION DB,DENAIR,DEPSUB,DP,E,EMISAN,EMISSB,EMISSK,ESAT
      DOUBLE PRECISION F12,F13,F14,F15,F16,F21,F23,F24,F25,F26,F31,F32
      DOUBLE PRECISION F41,F42,F51,F52,F61,FATOBJ,FATOSB,FATOSK,FLSHCOND
      DOUBLE PRECISION FLUID,FLYMETAB,FLYSPEED,FLYTIME,FUN,G,H2O_BALPAST
      DOUBLE PRECISION HSHSOI,HSOIL,MAXSHD,MICRO,MSHSOI,MSOIL,NM,PATMOS
      DOUBLE PRECISION PCTDIF,PHI,PHIMAX,PHIMIN,PI,POND_DEPTH,PSHSOI
      DOUBLE PRECISION PSOIL,PSTD,PTCOND,PTCOND_ORIG,QSOL,QSOLR,R,RELHUM
      DOUBLE PRECISION RH,RHO1_3,RHREF,RW,SHADE,SIDEX,SIG,SUBTK
      DOUBLE PRECISION TA,TALOC,TANNUL,TIME,TOBJ,TQSOL,TR,TRANS1,TREF
      DOUBLE PRECISION TSHLOW,TSHSKI,TSHSOI,TSKIN,TSKY,TSKYC,TSOIL,TSUB
      DOUBLE PRECISION TSUBST,TVINC,TVIR,TWATER,TWING,VAPREF
      DOUBLE PRECISION VD,VEL,VLOC,VREF,WB,WC,WEVAP,WQSOL,WTRPOT,Z,ZEN
      DOUBLE PRECISION ZSOIL

      INTEGER AQUATIC,CLIMBING,FEEDING,FLIGHT,FLYER,FLYTEST,IHOUR
      INTEGER INWATER,WINGCALC,WINGMOD

      DIMENSION HSHSOI(25),HSOIL(25),MSHSOI(25),MSOIL(25),PSHSOI(25)
      DIMENSION PSOIL(25),QSOL(25),RH(25),RHREF(25),TALOC(25),TIME(25)
      DIMENSION TREF(25),TSHLOW(25),TSHSKI(25),TSHSOI(25),TSKYC(25)
      DIMENSION TSOIL(25),TSUB(25),VLOC(25),VREF(25),Z(25),ZSOIL(10)

      COMMON/CLIMB/CLIMBING
      COMMON/ENVAR1/QSOL,RH,TSKYC,TIME,TALOC,TREF,RHREF
      COMMON/ENVAR2/TSUB,VREF,Z,TANNUL,VLOC
      COMMON/FLY/FLYTIME,FLYSPEED,FLYMETAB,FLIGHT,FLYER,FLYTEST
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG
      COMMON/FUN4/TSKIN,R,WEVAP,TR,ALT,BP,H2O_BALPAST
      COMMON/FUN5/WC,ZEN,PCTDIF,ABSSB,ABSAN,ASILN,FATOBJ,NM
      COMMON/PONDDATA/INWATER,AQUATIC,TWATER,POND_DEPTH,FEEDING
      COMMON/SHADE/MAXSHD
      COMMON/SHENV1/TSHSKI,TSHLOW
      COMMON/SOIL/TSOIL,TSHSOI,ZSOIL,MSOIL,MSHSOI,PSOIL,PSHSOI,HSOIL,
     & HSHSOI
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51
     &,SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52
     &,F61,TQSOL,A1,A2,A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26
     &,WINGCALC,WINGMOD
      COMMON/WSOLAR/ASIL,SHADE
      COMMON/WDSUB1/ANDENS,ASILP,EMISSB,EMISSK,FLUID,G,IHOUR
      COMMON/WDSUB2/QSOLR,TOBJ,TSKY,MICRO

      DATA PI/3.14159265/

C     NOTE: SHADMET COMES FROM THE % SHADE OF THE VEGETATION FOR THE GROUND.  THIS MIGHT BE <100%.
C     HOWEVER, SMALL ANIMALS MAY STILL BE ABLE TO SEEK 100% SHADE.  IN THAT
C     CASE, THE RADIANT ENVIRONMENT WILL BE THAT OF THE LOCAL AIR TEMPERATURE (NOT IMPLEMENTED HERE).

C	  SOLAR ENVIRONMENT
      QSOLR = QSOL(IHOUR)*((100.-SHADE)/100.) !ADJUST SOLAR FOR SHADE
      ZEN = Z(IHOUR) * PI / 180. !GET SOLAR ZENITH ANGLE (RADIANS)

C	  CONVECTIVE AND HUMIDITY ENVIRONMENT
      IF(FLYTEST.EQ.1)THEN ! ASSUME FLYING AT 2M
       TA = TREF(IHOUR)
       VEL = FLYSPEED
       RELHUM = RHREF(IHOUR)
      ELSE
       IF(CLIMBING.EQ.1)THEN ! ASSUME HAS CLIMBED TO 2M
        TA = TREF(IHOUR)
        VEL = VREF(IHOUR)
       ELSE
       TA = TALOC(IHOUR)*((MAXSHD-SHADE)/MAXSHD) + ! WEIGHTED MEAN OF VALUE IN MIN AND MAX AVAILABLE SHADE ACCORDING TO %SHADE CHOSEN
     &    (TSHLOW(IHOUR)*(SHADE/MAXSHD))
       VEL = VLOC (IHOUR) ! CHOOSE LOCAL HEIGHT WIND SPEED
       ENDIF
C      ADJUST RELATIVE HUMIDITY TO NEW AIR TEMP
       RELHUM = RH(IHOUR)
       WB=0.
       DP=999.
C      BP CALCULATED FROM ALTITUDE USING THE STANDARD ATMOSPHERE
C      EQUATIONS FROM SUBROUTINE DRYAIR2    (TRACY ET AL,1972)
       PSTD=101325.
       PATMOS=PSTD*((1.-(.0065*ALT/288.))**(1./.190284))
       BP = PATMOS
       DB = TALOC(IHOUR)
      CALL WETAIR2(DB,WB,RELHUM,DP,BP,E,ESAT,VD,RW,TVIR,TVINC,
     * DENAIR,CP,WTRPOT)
       VAPREF = E
       DB = TA
       RELHUM=100
      CALL WETAIR2(DB,WB,RELHUM,DP,BP,E,ESAT,VD,RW,TVIR,TVINC,
     * DENAIR,CP,WTRPOT)
       RELHUM = (VAPREF/ESAT)* 100.
       IF(RELHUM.GT.100.)THEN
        RELHUM = 100.
       ENDIF
       IF(RELHUM.LT.0.000)THEN
        RELHUM = 0.01
       ENDIF
      ENDIF
      
C	  RADIANT ENVIRONMENT (SKY AND GROUND)
      TSKY=TSKYC(IHOUR)*((MAXSHD-SHADE)/MAXSHD)+(TSHSKI(IHOUR) ! WEIGHTED MEAN OF VALUE IN MIN AND MAX AVAILABLE SHADE ACCORDING TO %SHADE CHOSEN
     & *(SHADE/MAXSHD))
      TSUBST = TSOIL(1)*((MAXSHD-SHADE)/MAXSHD) + TSHSOI(1)* ! WEIGHTED MEAN OF VALUE IN MIN AND MAX AVAILABLE SHADE ACCORDING TO %SHADE CHOSEN
     & (SHADE/MAXSHD)

C	  AQUATIC ENVIRONMENT
      IF(INWATER.EQ.1)THEN ! THIS MIGHT NOT BE NECESSARY
       TSUBST=TWATER
       TSKY=TWATER
      ENDIF
      
      TOBJ = TSUBST ! ASSUMING NO NEARBY OBJECT IN THIS VERSION

      RETURN
      END