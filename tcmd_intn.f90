      subroutine tcmd_intn(mot,imot,nmot)
!
!***********************************************************************
!
!     ACT
!_A    Traduction des mots lus en donnees neccessaires a
!_A    l'action intn.
!
!-----parameters figes--------------------------------------------------
!
      use para_fige
      use chainecarac
      use kcle
      use schemanum
!
!-----------------------------------------------------------------------
!
      character *32 comment
      character *32 mot(nmx)
      dimension imot(nmx)
!
      do icmt=1,32
      comment(icmt:icmt)=' '
      enddo
!
      if(knumt.eq.2) knumt=3
!
      if(nmot.eq.3)then
        comment=cb
        call synterr(mot,imot,2,comment)
      endif
!
      nm=3
!
      nm=nm+1
        if(nmot.lt.nm) then
          comment=ci
          call synterr(mot,imot,nmot,comment)
        else
          call valenti(mot,imot,nm,numt,knumt)
        endif
!
      return
      end
