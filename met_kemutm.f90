      subroutine met_kemutm( &
                 l, &
                 sn,vol,t, &
                 dvxx,dvxy,dvxz,dvyx,dvyy,dvyz,dvzx,dvzy,dvzz, &
                 v,mu,mut, &
                 cmui1,cmui2,cmuj1,cmuj2,cmuk1,cmuk2)
!
!***********************************************************************
!
!_DA : aout 2001 - Eric Goncalves
!
!     ACT
!      camcu viscosite turbulente mut k-epsilon modifie avec C_mu variable
!
!-----parameters figes--------------------------------------------------
!
      use para_var
      use para_fige
      use maillage
      use modeleturb
!
!-----------------------------------------------------------------------
!
      real mu,mut,retur,ss2,ww2,ss,ww,eta,cmuv
      dimension mu(ip12),mut(ip12),vol(ip11)
      dimension v(ip11,ip60)
      dimension dvxx(ip00),dvxy(ip00),dvxz(ip00), &
                dvyx(ip00),dvyy(ip00),dvyz(ip00), &
                dvzx(ip00),dvzy(ip00),dvzz(ip00),t(ip00)
      dimension sn(ip31*ndir)
      dimension cmui1(ip21),cmui2(ip21),cmuj1(ip21),cmuj2(ip21), &
                cmuk1(ip21),cmuk2(ip21)
!
      ind(i,j,k)=n0+1+(i-id1(l))+(j-jd1(l))*nid+(k-kd1(l))*nijd
      inc(id,jd,kd)=id+jd*nid+kd*nijd
!
      n0=npc(l)
      i1=ii1(l)
      i2=ii2(l)
      j1=jj1(l)
      j2=jj2(l)
      k1=kk1(l)
      k2=kk2(l)
!
      i2m1=i2-1
      j2m1=j2-1
      k2m1=k2-1
!
      nid = id2(l)-id1(l)+1
      njd = jd2(l)-jd1(l)+1
      nijd= nid*njd
!
      nci = inc(1,0,0)
!
!       Calcul du gradient de la vitesse. Les tableaux ont ete reutilises
!       dans la phase implicite.
        call teq_gradv( &
             l, &
             sn, &
             vol,v, &
             t, &
             dvxx,dvxy,dvxz,dvyx,dvyy,dvyz,dvzx,dvzy,dvzz, &
             cmui1,cmui2,cmuj1,cmuj2,cmuk1,cmuk2)
!
        do k=k1,k2m1
         do j=j1,j2m1
          n=ind(i1-1,j,k)
          do i=i1,i2m1
           n=n+nci
           m=n-n0
           retur=(v(n,6)**2)/(v(n,7)*mu(n))
           ss2=(dvxx(m)**2+dvyy(m)**2+dvzz(m)**2)*2. &
                   + (dvxy(m)+dvyx(m))**2 &
                   + (dvxz(m)+dvzx(m))**2 &
                   + (dvyz(m)+dvzy(m))**2
           ww2=(dvxy(m)-dvyx(m))**2 &
             + (dvxz(m)-dvzx(m))**2 &
             + (dvyz(m)-dvzy(m))**2
           ss=v(n,6)*sqrt(ss2)/v(n,7)
           ww=v(n,6)*sqrt(ww2)/v(n,7)
           eta=amax1(ss,ww)
           cmuv=0.3*(1.-exp(-0.36*exp(0.75*eta)))/ &
                    (1.+0.35*eta**1.5)
           mut(n)=cmuv*retur*mu(n)
          enddo
         enddo
        enddo
!
      return
      end
