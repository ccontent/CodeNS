module mod_at_dlist
  implicit none
contains
  subroutine at_dlist( &
       x,y,z, &
       xpar,ypar,zpar, &
       ncin, &
       m1tb,m2tb,nfrtb, &
       nfbi)
!
!***********************************************************************
!
!     ACT
!_A    Construction des tableaux de correspondance "m1, m2, No paroi"
!_A    avec le numero de facette paroi pour frontiere "nfbi"
!
!     INP
!_I    iminb      : com int (mtt       ) ; indice min en i d'une frontiere
!_I    imaxb      : com int (mtt       ) ; indice max en i d'une frontiere
!_I    jminb      : com int (mtt       ) ; indice min en j d'une frontiere
!_I    jmaxb      : com int (mtt       ) ; indice max en j d'une frontiere
!_I    kminb      : com int (mtt       ) ; indice min en k d'une frontiere
!_I    kmaxb      : com int (mtt       ) ; indice max en k d'une frontiere
!_I    mpb        : com int (mtt       ) ; pointeur fin de front precedente
!_I                                        dans tableaux de base des front.
!_I    mmb        : com int (mtt       ) ; nombre de pts d'une frontie
!_I    ncin       : arg int (ip41      ) ; ind dans un tab tous domaines de la
!_I                                        cell. interieure adjacente a la front
!_I    nfbi       : arg int              ; numero interne de frontiere
!_I    nfbn       : com int (mtb       ) ; numero dans numerotation interne
!_I    xpar       : arg real(ip00      ) ; coordonnee x centre facette paroi
!_I                                        dans tab normales stockees
!_I    ypar       : arg real(ip00      ) ; coordonnee y centre facette paroi
!_I    zpar       : arg real(ip00      ) ; coordonnee z centre facette paroi
!
!     OUT
!_O    m1tb       : arg int  (ip00     ) ; indice m1 facette frontiere paroi
!_O    m2tb       : arg int  (ip00     ) ; indice m2 facette frontiere paroi
!_O    nfrb       : arg int  (ip00     ) ; numero frontiere paroi de la facette
!
!-----parameters figes--------------------------------------------------
!
    use para_var
    use para_fige
    use boundary
    implicit none
    integer          ::         idm,      imaxf,      iminf,      jmaxf,      jminf
    integer          ::       kmaxf,      kminf,          l,        m0b,        m0n
    integer          ::          m1,      m1max, m1tb(ip00),         m2,      m2max
    integer          ::  m2tb(ip00),       mfac,      mfacn, ncin(ip41),       nfbi
    integer          :: nfrtb(ip00)
    double precision ::    x(ip21),xpar(ip00),   y(ip21),ypar(ip00),   z(ip21)
    double precision :: zpar(ip00)
!
!-----------------------------------------------------------------------
!
!
    l=ndlb(nfbi)
    m0b=mpb(nfbi)
    m0n=mpn(nfbi)
!
    iminf=iminb(nfbi)
    imaxf=imaxb(nfbi)
    jminf=jminb(nfbi)
    jmaxf=jmaxb(nfbi)
    kminf=kminb(nfbi)
    kmaxf=kmaxb(nfbi)
!
    if (iminf.eq.imaxf) then
       m1max=jmaxf-jminf+1
       m2max=kmaxf-kminf+1
    elseif (jminf.eq.jmaxf) then
       m1max=imaxf-iminf+1
       m2max=kmaxf-kminf+1
    elseif (kminf.eq.kmaxf) then
       m1max=imaxf-iminf+1
       m2max=jmaxf-jminf+1
    end if
    idm=m1max-1
!
!     boucle sur toutes les facettes de la paroi
    do m2=1,m2max-1
      do m1=1,m1max-1
       mfac =m0b+m1+(m2-1)*idm
       mfacn=m0n+m1+(m2-1)*idm
       m1tb(mfacn)=m1
       m2tb(mfacn)=m2
       nfrtb(mfacn)=nfbi
      enddo
    enddo
!
    return
  end subroutine at_dlist
end module mod_at_dlist
