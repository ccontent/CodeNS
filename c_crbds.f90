module mod_c_crbds
  implicit none
contains
  subroutine c_crbds( &
       mot,imot,nmot, &
       ncbd)
!
!***********************************************************************
!
!     ACT
!_A    Realisation de l'action crbds.
!
!***********************************************************************
!-----parameters figes--------------------------------------------------
!
    use para_var
    use para_fige
    use sortiefichier
    use mod_b2_crbds
    use mod_b1_crbds
    use mod_tcmd_crbds
    use mod_crbds
    implicit none
    integer          :: imax,imin,imot,jmax,jmin
    integer          :: kini,kmax,kmin,   l,mfbe
    integer          :: ncbd,nmot
!
!-----------------------------------------------------------------------
!
    character(len=32) ::  mot(nmx)
    character(len=2 ) :: indmf
!
    dimension imot(nmx)
    dimension ncbd(ip41)
!
    call tcmd_crbds( &
         mot,imot,nmot, &
         mfbe,kini,l, &
         imin,imax,jmin,jmax,kmin,kmax, &
         indmf)
!
    if (kimp.ge.1) then
       call b1_crbds( &
            mfbe,kini,l,imin,imax,jmin,jmax,kmin,kmax, &
            indmf)
    endif
!
    call crbds( &
         mfbe,kini,l, &
         imin,imax,jmin,jmax,kmin,kmax, &
         indmf, &
         ncbd)
!
    if(kimp.ge.2) then
       call b2_crbds(mfbe)
    endif
!
    return
  end subroutine c_crbds
end module mod_c_crbds
