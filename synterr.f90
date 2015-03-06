      subroutine synterr(mot,imot,nmot,comment)
!
!***********************************************************************
!
!     ACT
!_A    Message d'erreur en cas de donnees.
!
!-----parameters figes--------------------------------------------------
!
      use para_fige
	  use sortiefichier
!
!-----------------------------------------------------------------------
!
      character *1316 command
      character *32 comment
      character *32 mot(nmx)
      character *7 formatcm
      character *4 longcm
      dimension imot(nmx)
!
      call cctcmd(command,lgcmd,mot,imot,1,nmot)
!
      if (lgcmd.lt.(lgcmdx-3)) then
        lgcmd=lgcmd+1
        command(lgcmd:lgcmd)='   '
        do ipos=1,3
        lgcmd=lgcmd+1
        command(lgcmd:lgcmd)='.'
        enddo
      endif
!
      write(longcm,'(i4)') lgcmd
      formatcm='(a'//longcm//')'
!
      write(imp,'(/a)') &
           ' !! Attention !! erreur detectee dans la commande :'
      write(imp,formatcm) command
      write(imp,'(a)') comment
!
      stop 'Erreur de syntaxe dans une commande!'
!
      return
      end
