      subroutine valreel(mot,imot,nm,rree,krree)
!
!***********************************************************************
!
!     ACT
!_A    Affectation de sa valeur au reel rree.
!
!-----parameters figes--------------------------------------------------
!
      use para_fige
      use chainecarac
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
      call reel(mot(nm),imot(nm),rree,kerr)
      if(kerr.eq.0)then
        comment=cr
        call synterr(mot,imot,nm,comment)
      else
        krree=2
      endif
!
      return
      end
