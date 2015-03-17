module mod_met_rbve
implicit none
contains
      subroutine met_rbve(t,ncin,ncbd)
!
!***********************************************************************
!
!     ACT  extrapolation des grandeurs turbulentes aux bords
!
!
!-----parameters figes--------------------------------------------------
!
      use para_var
      use para_fige
   use boundary
implicit none
double precision :: t
integer :: ncin
integer :: ncbd
integer :: m
integer :: mf
integer :: mfb
integer :: ml
integer :: mt
integer :: n
integer :: ni
!
!-----------------------------------------------------------------------
!
      dimension t(ip11,ip60)
      dimension ncbd(ip41)
      dimension ncin(ip41)
!
!     definition des variables aux bords (centre des facettes frontieres)
!
      do mf=1,nbd
        mfb=lbd(mf)
        mt=mmb(mfb)
!!$OMP SIMD
         do m=1,mt
            ml=mpb(mfb)+m
            n=ncbd(ml)
            ni=ncin(ml)
            t(n,6) = t(ni,6)
            t(n,7) = t(ni,7)
         enddo
      enddo
!
      return
      end subroutine
end module
