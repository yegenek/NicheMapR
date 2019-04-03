      SUBROUTINE SHADEADJUST
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

C     ADJUSTS THE AMOUNT OF SHADE.

      IMPLICIT NONE

      DOUBLE PRECISION ACTHR,AL,ANDENS,ASIL,ASILP
      DOUBLE PRECISION DEPSEL,DEPSUB,EMISSB,EMISSK,FLUID,G,NEWDEP,PTCOND
      DOUBLE PRECISION QSOL,QSOLR,RH,SHADE,SUBTK,TMINPR,TBASK
      DOUBLE PRECISION TA,TALOC,TANNUL,TC,TCORES,TDIGPR,TIME,TMAXPR
      DOUBLE PRECISION TOBJ,TREF,TSKY,TSKYC,TSHSOI,TSOIL,TSUB,TSUBST
      DOUBLE PRECISION VEL,VREF,Z,ZSOIL,FLSHCOND,QCONV,QCOND
      DOUBLE PRECISION AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG
      DOUBLE PRECISION QSOLAR,QIRIN,QMETAB,QRESP,QSEVAP,QIROUT
      DOUBLE PRECISION TSKIN,R,WEVAP,TR,ALT,BP,MAXSHD
      DOUBLE PRECISION TPREF,TEMERGE,H2O_BALPAST,SIDEX,WQSOL
      DOUBLE PRECISION CUSTOMGEOM,SHP,PTCOND_ORIG
      DOUBLE PRECISION RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51
     &    ,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52,F23,F24,F25,F26
     &,F61,TQSOL,A1,A2,A3,A4,A4B,A5,A6,F13,F14,F15,F16,RHREF
      DOUBLE PRECISION MSOIL,MSHSOI,PSOIL,PSHSOI,HSOIL,HSHSOI

      INTEGER IHOUR,GEOMETRY,MICRO,NODNUM,WINGMOD,WINGCALC

      CHARACTER*1 BURROW,DAYACT,CLIMB,CKGRSHAD,CREPUS,NOCTURN
      DIMENSION  ACTHR(25),DEPSEL(25),TCORES(25)
      DIMENSION TSOIL(25),ZSOIL(10),TSHSOI(25)
      DIMENSION QSOL(25),RH(25),TSKYC(25)
      DIMENSION TALOC(25),TIME(25),TREF(25),TSUB(25),VREF(25),Z(25)
      DIMENSION CUSTOMGEOM(8),SHP(3),RHREF(25)
      DIMENSION MSOIL(25),MSHSOI(25),PSOIL(25),PSHSOI(25),HSOIL(25)
     & ,HSHSOI(25)

      COMMON/FUN1/QSOLAR,QIRIN,QMETAB,QRESP,QSEVAP,QIROUT,QCONV,QCOND
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG
      COMMON/FUN4/TSKIN,R,WEVAP,TR,ALT,BP,H2O_BALPAST
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51
     &,SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52
     &,F61,TQSOL,A1,A2,A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26
     &,WINGCALC,WINGMOD
      COMMON/WDSUB1/ANDENS,ASILP,EMISSB,EMISSK,FLUID,G,IHOUR
      COMMON/WDSUB2/QSOLR,TOBJ,TSKY,MICRO
      COMMON/ENVAR1/QSOL,RH,TSKYC,TIME,TALOC,TREF,RHREF
      COMMON/ENVAR2/TSUB,VREF,Z,TANNUL
      COMMON/SOIL/TSOIL,TSHSOI,ZSOIL,MSOIL,MSHSOI,PSOIL,PSHSOI,HSOIL,
     & HSHSOI
      COMMON/WSOLAR/ASIL,SHADE
      COMMON/BEHAV1/DAYACT,BURROW,CLIMB,CKGRSHAD,CREPUS,NOCTURN
      COMMON/BEHAV2/GEOMETRY,NODNUM,CUSTOMGEOM,SHP
      COMMON/BEHAV3/ACTHR
      COMMON/TREG/TC
      COMMON/TPREFR/TMAXPR,TMINPR,TDIGPR,TPREF,TBASK,TEMERGE
      COMMON/DEPTHS/DEPSEL,TCORES
      COMMON/WUNDRG/NEWDEP
      COMMON/SHADE/MAXSHD

      IF(MAXSHD.GT.100.)THEN
       MAXSHD=100.
      ENDIF

      IF(SHADE.LT.MAXSHD)THEN
C      INCREASE SHADE, AND DO A SOLUTION IN THE NEW ENVIRONMENT
       SHADE=SHADE+3.
       IF(SHADE.GT.MAXSHD)THEN
        SHADE=MAXSHD
       ENDIF
C      GET THE CLIMATE FOR CHANGED SHADE
       CALL ABOVEGROUND
       IF(QSOL(IHOUR).GT.0.00000)THEN
        CALL SOLAR
       ENDIF
      ENDIF
      CALL RADIN

      RETURN
      END