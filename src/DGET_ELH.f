      SUBROUTINE DGET_ELH(N,A,AELH,DAELH,RPAR)

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

C     EQUATIONS TO COMPUTE RATES OF CHANGE IN RESERVE, STRUCTURAL LENGTH AND MATURITY FOR AN INSECT

      IMPLICIT NONE
      INTEGER N
      DOUBLE PRECISION A,AELH,DAELH,DE,DH,DL,E,E_G,E_M,E_S,F,G,H,K_J,K_M
      DOUBLE PRECISION KAP,L,L_M,P_AM,P_M,R,RPAR,SC,U_H,V,VDOT
      DIMENSION AELH(N),DAELH(N),RPAR(13)

      F=RPAR(1)
      K_M=RPAR(2)
      VDOT=RPAR(3)
      K_J=RPAR(4)
      E_M=RPAR(5)
      G=RPAR(6)
      KAP=RPAR(7)
      E_G=RPAR(8)
      P_M=RPAR(9)
      P_AM=RPAR(10)
      L_M=RPAR(11)
      A  = AELH(1)! % D, TIME SINCE BIRTH
      E  = AELH(2)! % J, RESERVE
      L  = AELH(3)! % CM, STRUCTURAL LENGTH
      H  = AELH(4)! % J, REPRODUCTION BUFFER
      H  = AELH(5)! % J, REPRODUCTION BUFFER

C     USE EMBRYO EQUATION FOR LENGTH, FROM KOOIJMAN 2009 EQ. 2
      V = L**3.D+00                         ! CM^3, STRUCTURAL VOLUME
      E_S = E/ V/ E_M                      ! -, SCALED RESERVE DENSITY
      DL=(VDOT*E_S-K_M*G*L)/(3.D+00 *(E_S+G))    ! CM/TIME, CHANGE IN LENGTH
      R=VDOT*(E_S/L-1.D+00/L_M)/(E_S+G)
      SC = L**2.D+00 *(G*E_S)/(G+E_S)*(1.D+00+((K_M)*L)/VDOT)
      DE = -1.D+00 *SC*P_AM                     ! J/TIME, CHANGE IN RESERVE
      U_H=H/P_AM                          ! SCALED MATURITY
      DH=((1.D+00-KAP)*SC-K_J*U_H)*P_AM        ! J/T, CHANGE IN MATURITY

      DAELH(1)=1.0D+00
      DAELH(2)=DE
      DAELH(3)=DL
      DAELH(4)=DH
      DAELH(5)=DH

      RETURN
      END       