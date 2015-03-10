      subroutine met_bark( &
                 l, &
                 equat, &
                 sn, &
                 vol,s,mu, &
                 t,dtdx,dtdy,dtdz,bark, &
                 cmui1,cmui2,cmuj1,cmuj2,cmuk1,cmuk2)
!
!***********************************************************************
!
!     ACT
!      calcul des termes bas Reynolds de l'equation pour k.
!
!-----parameters figes--------------------------------------------------
!
      use para_var
      use para_fige
      use maillage
implicit none
integer :: indc
integer :: i
integer :: j
integer :: k
integer :: l
double precision :: sn
double precision :: vol
double precision :: s
double precision :: t
double precision :: dtdx
double precision :: dtdy
double precision :: dtdz
double precision :: bark
double precision :: cmui1
double precision :: cmui2
double precision :: cmuj1
double precision :: cmuj2
double precision :: cmuk1
double precision :: cmuk2
integer :: i1
integer :: i1m1
integer :: i2
integer :: i2m1
integer :: imax
integer :: imin
integer :: ind1
integer :: ind2
integer :: j1
integer :: j1m1
integer :: j2
integer :: j2m1
integer :: jmax
integer :: jmin
integer :: k1
integer :: k1m1
integer :: k2
integer :: k2m1
integer :: kmax
integer :: kmin
integer :: lgsnlt
integer :: m
integer :: n
integer :: n0c
integer :: nid
integer :: nijd
integer :: njd
integer :: npsn
!
!-----------------------------------------------------------------------
!
      character(len=7 ) :: equat
      real mu
      dimension s(ip11,ip60)
      dimension sn(ip31*ndir)
      dimension t(ip00),dtdx(ip00),dtdy(ip00),dtdz(ip00),bark(ip00)
      dimension mu(ip12),vol(ip11)
      dimension cmui1(ip21),cmui2(ip21),cmuj1(ip21),cmuj2(ip21), &
                cmuk1(ip21),cmuk2(ip21)
!
      indc(i,j,k)=n0c+1+(i-id1(l))+(j-jd1(l))*nid+(k-kd1(l))*nijd
!
      n0c=npc(l)
      i1=ii1(l)
      i2=ii2(l)
      j1=jj1(l)
      j2=jj2(l)
      k1=kk1(l)
      k2=kk2(l)
!
      i1m1=i1-1
      j1m1=j1-1
      k1m1=k1-1
!
      i2m1=i2-1
      j2m1=j2-1
      k2m1=k2-1
!
      nid = id2(l)-id1(l)+1
      njd = jd2(l)-jd1(l)+1
      nijd= nid*njd
!
      imin=i1m1
      imax=i2
      jmin=j1m1
      jmax=j2
      kmin=k1m1
      kmax=k2
!
!calcul de grad(sqrt(k))
!
      if (equat(3:5).eq.'2di') then
         imin=i1
         imax=i2m1
      endif
      if (equat(3:5).eq.'2dj') then
         jmin=j1
         jmax=j2m1
      endif
      if (equat(3:5).eq.'2dk') then
         kmin=k1
         kmax=k2m1
      endif
!
      do k=kmin,kmax
       do j=jmin,jmax
        ind1=indc(imin,j,k)
        ind2=indc(imax,j,k)
        do n=ind1,ind2
          m=n-n0c
          t(m)= sqrt(s(n,6)/s(n,1))
        enddo
       enddo
      enddo
!
      npsn  =ndir*npfb(l)+1
      lgsnlt=nnn(l)
!
      call teq_grads( &
                 l, &
                 equat, &
                 sn(npsn),lgsnlt, &
                 vol, &
                 t   , &
                 dtdx,dtdy,dtdz, &
                 cmui1,cmui2,cmuj1,cmuj2,cmuk1,cmuk2)
!
      ind1=indc(i1  ,j1  ,k1  )
      ind2=indc(i2m1,j2m1,k2m1)
      do n=ind1,ind2
        m=n-n0c
        bark(m)=dtdx(m)*dtdx(m)+dtdy(m)*dtdy(m)+dtdz(m)*dtdz(m)
        bark(m)=-2.*mu(n)*bark(m)
      enddo

      return
      end
