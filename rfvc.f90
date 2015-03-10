      subroutine rfvc( &
              t,ncbd,mnc, &
              ps,temp,cson)
!
!***********************************************************************
!
!     ACT
!_A    Calcul des variables (t) dans des mailles fictives adjacentes a des
!_A    frontieres coincidentes (valeurs dans le domaine coincident).
!
!     INP
!_I    ncbd       : arg int (ip41      ) ; ind dans un tab tous domaines d'une
!_I                                        cellule frontiere fictive
!_I    mnc        : arg int (ip43      ) ; ind dans un tab tous domaines d'une
!_I                                        cellule coincidente
!_I    mmb        : com int (mtt       ) ; nombre de pts d'une frontiere
!_I    mpb        : com int (mtt       ) ; pointeur fin de front precedente
!_I                                        dans tableaux de base des front.
!_I    mpc        : com int (mtt       ) ; pointeur fin de front precedente
!_I                                        dans tableaux front coinc
!_I    nbd        : com int              ; nombre de frontieres a traiter
!_I    lbd        : com int (mtt       ) ; numero de front a traiter
!
!     I/O
!_/    rfvc       t          : arg real(ip11,ip60 ) ; variables de calcul
!
!-----parameters figes--------------------------------------------------
!
      use para_var
      use para_fige
      use boundary
      use definition
implicit none
double precision :: t
integer :: ncbd
integer :: mnc
double precision :: ps
double precision :: temp
double precision :: cson
integer :: m
integer :: mb
integer :: mc
integer :: mf
integer :: mfb
integer :: mt
integer :: nc
integer :: nd
double precision :: tper
!
!-----------------------------------------------------------------------
!
      dimension t(ip11,ip60)
      dimension mnc(ip43),ncbd(ip41)
      dimension ps(ip11),temp(ip11),cson(ip11)
!
      do mf=1,nbd
       mfb=lbd(mf)
       mt =mmb(mfb)
       tper=protat*float(mper(mfb))
!DEC$ IVDEP
       do m=1,mt
        mc=mpc(mfb)+m
        nc=mnc(mc)
        mb=mpb(mfb)+m
        nd=ncbd(mb)
!       definition des variables aux points fictifs
        t(nd,1)= t(nc,1)
        t(nd,2)= t(nc,2)
        t(nd,3)= t(nc,3)*cos(tper)+t(nc,4)*sin(tper)
        t(nd,4)= t(nc,4)*cos(tper)-t(nc,3)*sin(tper)
        t(nd,5)= t(nc,5)
        ps(nd) = ps(nc)
        temp(nd)=temp(nc)
        cson(nd)=cson(nc)
       enddo
      enddo
!
      return
      end
