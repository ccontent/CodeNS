module mod_met_rbsc
implicit none
contains
      subroutine met_rbsc( &
                 s1x,s1y,s1z,s2x,s2y,s2z, &
                 ncbd,ncin,mnc)
!
!***********************************************************************
!
!     ACT
!
!-----parameters figes--------------------------------------------------
!
      use para_var
      use para_fige
   use boundary
implicit none
double precision :: s1x
double precision :: s1y
double precision :: s1z
double precision :: s2x
double precision :: s2y
double precision :: s2z
integer :: ncbd
integer :: ncin
integer :: mnc
integer :: m
integer :: mb
integer :: mc
integer :: mf
integer :: mfb
integer :: mt
integer :: nc
integer :: nd
integer :: ndm
!
!-----------------------------------------------------------------------
!
      dimension s1x(ip12),s1y (ip12),s1z(ip12), &
                s2x(ip12),s2y (ip12),s2z(ip12)
      dimension ncin(ip41),ncbd(ip41)
      dimension mnc(ip43)
!
      do mf=1,nbd
!
         mfb=lbd(mf)
         mt=mmb(mfb)
!
!!$OMP SIMD
         do m=1,mt
            mc=mpc(mfb)+m
            nc=mnc(mc)
            mb=mpb(mfb)+m
            nd=ncbd(mb)
            ndm=ncin(mb)
!
!     definition des variables aux bords (centre des facettes frontieres)
!
            s1x(nd) = 0.5*( s1x(ndm)+s1x(nc) )
            s1y(nd) = 0.5*( s1y(ndm)+s1y(nc) )
            s1z(nd) = 0.5*( s1z(ndm)+s1z(nc) )
            s2x(nd) = 0.5*( s2x(ndm)+s2x(nc) )
            s2y(nd) = 0.5*( s2y(ndm)+s2y(nc) )
            s2z(nd) = 0.5*( s2z(ndm)+s2z(nc) )
!
         enddo
!
      enddo
!
      return
      end subroutine
end module
