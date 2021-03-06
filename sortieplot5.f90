module mod_sortieplot5
  implicit none
contains
  subroutine sortieplot3( &
       x,y,z,l,t,dist, &
       mu,mut,toxy, &
       ps,cson,temp)
!
!***********************************************************************
!
!_DA  DATE_C :  2008 -- AUTEUR : LEGI / Eric Goncalves
!
!     ACT
!_A   Sortie tecplot pour calculs stationnaires.
!
!     VAL
!_L    titrt1     : com char             ; titre du calcul
!_L    c          :     char             ; caractere "
!
!-----parameters figes--------------------------------------------------
!
    use para_var
    use para_fige
    use maillage
    use sortiefichier
    use chainecarac
    use proprieteflu
    implicit none
    integer          ::    i,  i1,i1m1,  i2,i2m1
    integer          ::    j,  j1,j1m1,  j2
    integer          :: j2m1,   k,  k1,k1m1,  k2
    integer          :: k2m1,   l,   m,   n, n0c
    integer          ::  nid,nijd, njd
    double precision ::   cson(ip11),  dist(ip12),           e,    mu(ip12),   mut(ip12)
    double precision ::     ps(ip11),          qq,t(ip11,ip60),        taur,  temp(ip11)
    double precision ::   toxy(ip12),           u,           v,          ve,          vk
    double precision ::            w,     x(ip21),         xcc,         xme,         xmt
    double precision ::      y(ip21),         ycc,     z(ip21),         zcc
!
!-----------------------------------------------------------------------
!
    character(len=1 ) :: c
!
  open(sec  ,file='fsec',position="append")
    n0c=npc(l)
    i1=ii1(l)
    i2=ii2(l)
    j1=jj1(l)
    j2=jj2(l)
    k1=kk1(l)
    k2=kk2(l)
!
    nid = id2(l)-id1(l)+1
    njd = jd2(l)-jd1(l)+1
    nijd= nid*njd
!
    i1m1=i1-1
    j1m1=j1-1
    k1m1=k1-1
    i2m1=i2-1
    j2m1=j2-1
    k2m1=k2-1
!     double cote
    c=char(34)
!
    write(sec,'(''TITLE='',a1,a50,a1)')c,titrt1,c
    write(sec,'(''VARIABLES = '',a1,17(a,a1,'', '',a1),a,a1)')  &
         c,'x',c, c,'y',c, c,'Pstat',c, c,'rho',c, c,'dist',c,   &
         c,'u',c, c,'v',c, c,'M',c, c,'k',c, c,'eps',c,  &
         c,'uv',c, c,'Macht',c, c,'mut/mu',c, c,'i',c, c,'j',c
    write(sec,'("ZONE F=POINT, I=",i3," J=",i3)')j2m1,i2m1
!
    do k=k1,k2m1
       do i=i1,i2m1
          do j=j1,j2m1
             n=indc(i,j,k)
             m=n-n0c
!
             xcc=(x(n)     +x(n     +1)+x(n     +nid)+x(n     +nid+1) &
                  +x(n+nijd)+x(n+nijd+1)+x(n+nijd+nid)+x(n+nijd+nid+1))*0.125
             ycc=(y(n)     +y(n     +1)+y(n     +nid)+y(n     +nid+1) &
                  +y(n+nijd)+y(n+nijd+1)+y(n+nijd+nid)+y(n+nijd+nid+1))*0.125
             zcc=(z(n)     +z(n     +1)+z(n     +nid)+z(n     +nid+1) &
                  +z(n+nijd)+z(n+nijd+1)+z(n+nijd+nid)+z(n+nijd+nid+1))*0.125
!
             u=t(n,2)/t(n,1)
             v=t(n,3)/t(n,1)
             w=t(n,4)/t(n,1)
             e=t(n,5)/t(n,1)
             qq=u*u+v*v+w*w
             xme=sqrt(qq)/cson(n)
             vk=t(n,6)/t(n,1)
             ve=t(n,7)/t(n,1)
!         -<u'v'>=mut*toxy/(rho*(mu+mut))
             taur=mut(n)*toxy(n)/(t(n,1)*(mu(n)+mut(n)))
             xmt=sqrt(2*vk)/cson(n)
!
             write(sec,'(5(1pe14.6),8(1pe11.3),2i4)')  &
                  xcc,ycc,ps(n),t(n,1),dist(n),u,v,xme,vk,ve,taur, &
                  xmt,mut(n)/mu(n),i,j
          enddo
       enddo
    enddo
   close(sec)
!
    return
  contains
    function    indc(i,j,k)
      implicit none
      integer          ::    i,indc,   j,   k
      indc=n0c+1+(i-id1(l))+(j-jd1(l))*nid+(k-kd1(l))*nijd
    end function indc
  end subroutine sortieplot3
end module mod_sortieplot5
