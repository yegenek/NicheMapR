      SUBROUTINE DGET_AVELH(N,A,AVELH,DAVELH,RPAR)

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

C     EQUATIONS TO COMPUTE RATES OF CHANGE IN RESERVE, STRUCTURAL VOLUME, MATURITY REPRODUCTION BUFFER FOR AN INSECT

      IMPLICIT NONE

      INTEGER N

      DOUBLE PRECISION A,AVELH,DAVELH,DE,DH,DL,DV,E,E_M,E_S,F,G,H,K_EL
      DOUBLE PRECISION K_J,KAP,L,L_M,M_V,MU_E,P_C,R,RPAR,V,V_J,Y_EV

      DIMENSION AVELH(N),DAVELH(N),RPAR(13)

      F=RPAR(1)
      K_EL=RPAR(2)
      V_J=RPAR(3)
      E_M=RPAR(4)
      G=RPAR(5)
      KAP=RPAR(6)
      M_V=RPAR(7)
      Y_EV=RPAR(8)
      MU_E=RPAR(9)
      K_J=RPAR(10)
      L_M=RPAR(11)

      A  = AVELH(1)! % H, TIME SINCE PUPATION
      V  = AVELH(2)! % CM3, STRUCTURAL VOLUME OF LARVA
      E  = AVELH(3)! % J, RESERVE OF LARVA
      L  = AVELH(4)! % CM, STRUCTURAL LENGTH OF IMAGO
      H  = AVELH(5)! % J, MATURITY

      DV = -1.D+00 * V * K_EL                 ! CM^3/H, CHANGE IN LARVAL STRUCTURAL VOLUME
      E_S = E/ L**3.D+00/ E_M                    ! -, SCALED RESERVE DENSITY
      R = V_J*(E_S / L - 1.D+00 / L_M)/ (E_S + G) ! 1/H, SPECIFIC GROWTH RATE
      P_C = E * (V_J / L - R)              ! J/H, MOBILISATION RATE
      DE = -1.D+00 * DV * M_V * Y_EV * MU_E - P_C   ! J/H, CHANGE IN RESERVE
      DL = R * L/ 3.D+00                   ! CM/H, CHANGE IN LENGTH
      DH = (1.D+00 - KAP) * P_C - K_J * H     ! J/H, CHANGE IN MATURITY

      DAVELH(1)=1.0D+00
      DAVELH(2)=DV
      DAVELH(3)=DE
      DAVELH(4)=DL
      DAVELH(5)=DH

      RETURN
      END       