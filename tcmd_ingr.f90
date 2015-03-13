module mod_tcmd_ingr
implicit none
contains
      subroutine tcmd_ingr( &
                 mot,imot,nmot, &
                 ldom,ldomd,king)
!
!***********************************************************************
!
!     ACT
!_A    Traduction des mots lus en donnees neccessaires a
!_A    l'action ingr.
!
!-----parameters figes--------------------------------------------------
!
      use para_fige
      use chainecarac
      use maillage
      use kcle
use mod_valenti
use mod_vallent
implicit none
integer :: imot
integer :: nmot
integer :: ldom
integer :: ldomd
integer :: king
integer :: icmt
integer :: kval
integer :: nm
!
!-----------------------------------------------------------------------
!
      character(len=32) ::  comment
      character(len=32) ::  mot(nmx)
      dimension imot(nmx)
      dimension ldom(nobj)
!
      do icmt=1,32
      comment(icmt:icmt)=' '
      enddo
      kval=0
!
      nm=3
      nm=nm+1
      if(nmot.lt.nm) then
        comment=cm
        call synterr(mot,imot,nmot,comment)
      else
        call vallent(mot,imot,nm,ldom,ldomd,lzx,klzx)
      endif
!
      nm=nm+1
      if(nmot.lt.nm) then
        comment=ci
        call synterr(mot,imot,nmot,comment)
      else
        call valenti(mot,imot,nm,king,kval)
      endif
!
      return
      end subroutine
end module
