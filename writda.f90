      subroutine writda( &
                 l,kda,eqt,utau, &
                 imin,imax,jmin,jmax,kmin,kmax, &
                 v1,v2,v3,v4,v5,v6,v7,ndmut,mut)
!
!***********************************************************************
!
!     ACT
!_A    Ecriture sur l'unite logique kda des variables aerodynamiques (v)
!_A    et de la viscosite turbulente (mut) de points d'un domaine structure.
!_A    Ecriture sur l'unite logique kda des variables aerodynamiques (v)
!_A    et de la viscosite turbulente (mut) si appel depuis "svfw" (ndmut=ip12)
!_A    ou du champ des residus si appel depuis "svfw" (ndmut=1 et "eqt"=" res  ")
!
!     INP
!_I    l          : arg int              ; numero de domaine
!_I    kda        : arg int              ; unite logique, variables
!_I    eqt        : arg char             ; type d'equations modelisant l'ecoulement
!_I    imin       : arg int              ; indice min en i
!_I    imax       : arg int              ; indice max en i
!_I    jmin       : arg int              ; indice min en j
!_I    jmax       : arg int              ; indice max en j
!_I    kmin       : arg int              ; indice min en k
!_I    kmax       : arg int              ; indice max en k
!_I    v1         : arg real(ip00      ) ; variable 1 a stocker
!_I    v2         : arg real(ip00      ) ; variable 2 a stocker
!_I    v3         : arg real(ip00      ) ; variable 3 a stocker
!_I    v4         : arg real(ip00      ) ; variable 4 a stocker
!_I    v5         : arg real(ip00      ) ; variable 5 a stocker
!_I    ndmut      : arg int              ; dimension du tableau mut
!_I    mut        : arg real(ip12      ) ; viscosite turbulente
!_I    id1        : com int (lt        ) ; indice min en i fictif
!_I    id2        : com int (lt        ) ; indice max en i fictif
!_I    jd1        : com int (lt        ) ; indice min en j fictif
!_I    jd2        : com int (lt        ) ; indice max en j fictif
!_I    kd1        : com int (lt        ) ; indice min en k fictif
!
!-----parameters figes--------------------------------------------------
!
      use para_var
      use para_fige
      use chainecarac
      use maillage
      use modeleturb
implicit none
integer :: ind
integer :: i
integer :: j
integer :: k
integer :: l
integer :: kda
double precision :: utau
integer :: imin
integer :: imax
integer :: jmin
integer :: jmax
integer :: kmin
integer :: kmax
double precision :: v1
double precision :: v2
double precision :: v3
double precision :: v4
double precision :: v5
double precision :: v6
double precision :: v7
integer :: ndmut
integer :: m
integer :: nid
integer :: nijd
integer :: njd
!
!-----------------------------------------------------------------------
!
      character(len=7 ) :: eqt
      real mut
      dimension v1(ip00),v2(ip00),v3(ip00),v4(ip00), &
                v5(ip00),v6(ip00),v7(ip00)
      dimension mut(ndmut)
      dimension utau(ip42)
!
      ind(i,j,k)=1+(i-id1(l))+(j-jd1(l))*nid+(k-kd1(l))*nijd
!
      if(l.eq.1) rewind kda
!
      nid = id2(l)-id1(l)+1
      njd = jd2(l)-jd1(l)+1
      nijd = nid*njd
!
      write(kda) &
      ((( v1(ind(i,j,k)),i=imin,imax),j=jmin,jmax),k=kmin,kmax)
      write(kda) &
      ((( v2(ind(i,j,k)),i=imin,imax),j=jmin,jmax),k=kmin,kmax)
      write(kda) &
      ((( v3(ind(i,j,k)),i=imin,imax),j=jmin,jmax),k=kmin,kmax)
      write(kda) &
      ((( v4(ind(i,j,k)),i=imin,imax),j=jmin,jmax),k=kmin,kmax)
      write(kda) &
      ((( v5(ind(i,j,k)),i=imin,imax),j=jmin,jmax),k=kmin,kmax)
      if(eqt(1:2).eq.'ns') then
        write(kda) &
        (((mut(ind(i,j,k)),i=imin,imax),j=jmin,jmax),k=kmin,kmax)
      endif
!
      if(eqt(6:7).eq.'ke') then
!      if (eqt(6:7).eq.'ke' .or. &
!         (eqt(2:4).eq.'res' .and. ip60.eq.7) ) then
         write(kda) &
         ((( v6(ind(i,j,k)),i=imin,imax),j=jmin,jmax),k=kmin,kmax)
         write(kda) &
         ((( v7(ind(i,j,k)),i=imin,imax),j=jmin,jmax),k=kmin,kmax)
         if (eqt(6:7).eq.'ke'.and. (kutau.eq.1)) then
!          modeles de Chien ou k-omega bas Reynolds de Wilcox
!          ou modeles de Wilcox, Menter avec rugosite
           write(kda)mdimtnx
           write(kda)(utau(m),m=1,mdimtnx)
         endif
      endif

!     open(100,file='testecri.tec',form='formatted',status='unknown')
!     do j=1,jmax
!      do i=1,imax
!       do k=1,1 
!        write(1,'(8(e20.12),3i5)')  &
!           v1(ind(i,j,k)),v2(ind(i,j,k)),v3(ind(i,j,k)),v4(ind(i,j,k)),v5(ind(i,j,k)), &
!     v6(ind(i,j,k)),v7(ind(i,j,k)),mut(ind(i,j,k)),i,j,k
!        enddo      
!       enddo
!      enddo
!      close(100)
!
      return
      end
