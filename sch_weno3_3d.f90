      subroutine sch_weno3_3d( &
                 lm,ityprk, &
                 u,v,ff, &
                 toxx,toxy,toxz,toyy,toyz,tozz,qcx,qcy,qcz, &
                 equat, &
                 sn,lgsnlt, &
                 fxx,fyy,fzz,fxy,fxz,fyz,fex,fey,fez, &
                 ps)
!
!******************************************************************
!
!_DA  DATE_C : decembre 2004 - Eric Goncalves / LEGI
!
!     ACT
!_A   Schema WENO de Jiang&Chu, ordre 3 en maillage regulier.
!_A   Formulation 2D avec schema de Roe.
!_A   Mapping de Henrik.
!
!*******************************************************************
!-----parameters figes----------------------------------------------
!
      use para_var
      use para_fige
      use maillage
      use proprieteflu
implicit none
integer :: inc
integer :: indc
integer :: id
integer :: jd
integer :: kd
integer :: i
integer :: j
integer :: k
integer :: lm
integer :: ityprk
double precision :: u
double precision :: v
double precision :: ff
double precision :: toxx
double precision :: toxy
double precision :: toxz
double precision :: toyy
double precision :: toyz
double precision :: tozz
double precision :: qcx
double precision :: qcy
double precision :: qcz
double precision :: sn
integer :: lgsnlt
double precision :: fxx
double precision :: fyy
double precision :: fzz
double precision :: fxy
double precision :: fxz
double precision :: fyz
double precision :: fex
double precision :: fey
double precision :: fez
double precision :: ps
double precision :: al
double precision :: am
double precision :: am2i
double precision :: ar
double precision :: beta11
double precision :: beta12
double precision :: beta21
double precision :: beta22
double precision :: beta31
double precision :: beta32
double precision :: beta41
double precision :: beta42
double precision :: beta51
double precision :: beta52
double precision :: c00
double precision :: c01
double precision :: c10
double precision :: c11
double precision :: cnds
double precision :: eps
double precision :: f11
double precision :: f12
double precision :: f21
double precision :: f22
double precision :: f31
double precision :: f32
double precision :: f41
double precision :: f42
double precision :: f51
double precision :: f52
double precision :: g11
double precision :: g12
double precision :: g21
double precision :: g22
double precision :: g31
double precision :: g32
double precision :: g41
double precision :: g42
double precision :: g51
double precision :: g52
double precision :: ga1
double precision :: ga2
double precision :: gd
double precision :: gd1
double precision :: gd2
double precision :: h11
double precision :: h12
double precision :: h21
double precision :: h22
double precision :: h31
double precision :: h32
double precision :: h41
double precision :: h42
double precision :: h51
double precision :: h52
double precision :: hl
double precision :: hm
double precision :: hr
integer :: i1
integer :: i1m1
integer :: i1p1
integer :: i2
integer :: i2m1
integer :: i2m2
integer :: iexp
integer :: ind1
integer :: ind2
integer :: isortie
integer :: j1
integer :: j1m1
integer :: j1p1
integer :: j2
integer :: j2m1
integer :: j2m2
integer :: k1
integer :: k1m1
integer :: k1p1
integer :: k2
integer :: k2m1
integer :: k2m2
integer :: kdir
integer :: m
integer :: m1
integer :: n
integer :: n0c
integer :: n1
integer :: nci
integer :: ncj
integer :: nck
integer :: nid
integer :: nijd
integer :: ninc
integer :: njd
double precision :: p11
double precision :: p12
double precision :: p13
double precision :: p14
double precision :: p15
double precision :: p21
double precision :: p22
double precision :: p23
double precision :: p24
double precision :: p25
double precision :: p31
double precision :: p32
double precision :: p33
double precision :: p34
double precision :: p35
double precision :: p41
double precision :: p42
double precision :: p43
double precision :: p44
double precision :: p45
double precision :: p51
double precision :: p52
double precision :: p53
double precision :: p54
double precision :: p55
double precision :: q11
double precision :: q12
double precision :: q13
double precision :: q14
double precision :: q15
double precision :: q1f
double precision :: q1f1m
double precision :: q1f1p
double precision :: q1f2p
double precision :: q21
double precision :: q22
double precision :: q23
double precision :: q24
double precision :: q25
double precision :: q2f
double precision :: q2f1m
double precision :: q2f1p
double precision :: q2f2p
double precision :: q31
double precision :: q32
double precision :: q33
double precision :: q34
double precision :: q35
double precision :: q3f
double precision :: q3f1m
double precision :: q3f1p
double precision :: q3f2p
double precision :: q41
double precision :: q42
double precision :: q43
double precision :: q44
double precision :: q45
double precision :: q4f
double precision :: q4f1m
double precision :: q4f1p
double precision :: q4f2p
double precision :: q51
double precision :: q52
double precision :: q53
double precision :: q54
double precision :: q55
double precision :: q5f
double precision :: q5f1m
double precision :: q5f1p
double precision :: q5f2p
double precision :: rhoami
double precision :: rhoiam
double precision :: rhom
double precision :: rhomi
double precision :: sw
double precision :: swm
double precision :: ul
double precision :: um
double precision :: ur
double precision :: v1
double precision :: v4
double precision :: v5
double precision :: vitm2
double precision :: vl
double precision :: vm
double precision :: vn
double precision :: vr
double precision :: w11
double precision :: w12
double precision :: w13
double precision :: w14
double precision :: w15
double precision :: w21
double precision :: w22
double precision :: w23
double precision :: w24
double precision :: w25
double precision :: wl
double precision :: wm
double precision :: wr
double precision :: ww11
double precision :: ww11m
double precision :: ww12
double precision :: ww12m
double precision :: ww13
double precision :: ww13m
double precision :: ww14
double precision :: ww14m
double precision :: ww15
double precision :: ww15m
double precision :: ww21
double precision :: ww21m
double precision :: ww22
double precision :: ww22m
double precision :: ww23
double precision :: ww23m
double precision :: ww24
double precision :: ww24m
double precision :: ww25
double precision :: ww25m
!
!-------------------------------------------------------------------
!
      real nx,ny,nz
      real f1,f2,f3,f4,f5,fc1,fc2,fc3,fc4,fc5,df1,df2,df3,df4,df5
      real g1,g2,g3,g4,g5,gc1,gc2,gc3,gc4,gc5,dg1,dg2,dg3,dg4,dg5
      real h1,h2,h3,h4,h5,hc1,hc2,hc3,hc4,hc5,dh1,dh2,dh3,dh4,dh5
      real fv2,fv3,fv4,fv5,gv2,gv3,gv4,gv5,hv2,hv3,hv4,hv5
      character(len=7 ) :: equat
      dimension u(ip11,ip60),v(ip11,ip60),ff(ip11,ip60),ps(ip11)
      dimension sn(lgsnlt,nind,ndir)
      dimension toxx(ip12),toxy(ip12),toxz(ip12), &
                toyy(ip12),toyz(ip12),tozz(ip12), &
                qcx (ip12),qcy (ip12),qcz (ip12)
      dimension fxx(ip00),fyy(ip00),fzz(ip00),fxy(ip00),fxz(ip00), &
                fyz(ip00),fex(ip00),fey(ip00),fez(ip00)

      indc(i,j,k)=n0c+1+(i-id1(lm))+(j-jd1(lm))*nid+(k-kd1(lm))*nijd
      inc(id,jd,kd)=id+jd*nid+kd*nijd

      n0c=npc(lm)
      i1=ii1(lm)
      i2=ii2(lm)
      j1=jj1(lm)
      j2=jj2(lm)
      k1=kk1(lm)
      k2=kk2(lm)
!
      nid = id2(lm)-id1(lm)+1
      njd = jd2(lm)-jd1(lm)+1
      nijd = nid*njd
!
      i1p1=i1+1
      j1p1=j1+1
      k1p1=k1+1
      i2m1=i2-1
      j2m1=j2-1
      k2m1=k2-1
      i2m2=i2-2
      j2m2=j2-2
      k2m2=k2-2
      i1m1=i1-1
      j1m1=j1-1
      k1m1=k1-1
!
      nci = inc(1,0,0)
      ncj = inc(0,1,0)
      nck = inc(0,0,1)
!
!     activation des sorties
      isortie=0
!      isortie=1
!
!-----calcul des densites de flux convectifs ----------------------
!
      ind1 = indc(i1m1,j1m1,k1m1)
      ind2 = indc(i2  ,j2  ,k2  )
      do n=ind1,ind2
       m=n-n0c
       u(n,1)=0.
       u(n,2)=0.
       u(n,3)=0.
       u(n,4)=0.
       u(n,5)=0.
       fxx(m)=v(n,2)*(v(n,2)/v(n,1))+ps(n)-pinfl
       fxy(m)=v(n,3)*(v(n,2)/v(n,1))
       fxz(m)=v(n,4)*(v(n,2)/v(n,1))
       fyy(m)=v(n,3)*(v(n,3)/v(n,1))+ps(n)-pinfl
       fyz(m)=v(n,4)*(v(n,3)/v(n,1))
       fzz(m)=v(n,4)*(v(n,4)/v(n,1))+ps(n)-pinfl
       fex(m)=(v(n,5)+ps(n)-pinfl)*v(n,2)/v(n,1)
       fey(m)=(v(n,5)+ps(n)-pinfl)*v(n,3)/v(n,1)
       fez(m)=(v(n,5)+ps(n)-pinfl)*v(n,4)/v(n,1)
      enddo
!
!     coefficient Crj
      c00=0.5
      c01=0.5
      c10=-0.5
      c11=1.5
!     coefficient gamma
      ga1=1./3.
      ga2=2./3.
!     epsilon petit
      eps=1.e-40
!
!*****************************************************************
!
!  Calcul du flux numerique par direction suivant les etapessuccessives :
!    1) evaluation des matrices de passage et des valeurs
!       propres associees a la matrice jacobienne A
!       (ces quantites sont evaluees a l'etat moyen de Roe)
!    2) calculs des flux associes aux variables caracteristiques
!    3) application de la procedure de reconstruction ENO scalaire
!       a chaque composante
!    4) calculs des flux convectifs a partir des flux reconstruits
!    5) ajout des flux visqueux evalues avec schema centre
!
!********************************************************************
!
!-----direction i-----------------------------------------
!
      kdir=1
      ninc=nci
!
      do k=k1,k2m1
       do j=j1,j2m1
        ind1 = indc(i1  ,j,k)
        ind2 = indc(i2m2,j,k)
        do n=ind1,ind2
         m=n-n0c
         m1=m+ninc
         n1=n+ninc
!        vecteur normal unitaire a la face consideree (face i+1/2)
         cnds=sqrt(sn(m1,kdir,1)*sn(m1,kdir,1)+ &
                   sn(m1,kdir,2)*sn(m1,kdir,2)+ &
                   sn(m1,kdir,3)*sn(m1,kdir,3))
         nx=sn(m1,kdir,1)/cnds
         ny=sn(m1,kdir,2)/cnds
         nz=sn(m1,kdir,3)/cnds
!        calcul des etats gauche et droit
         ul=v(n,2)/v(n,1)
         vl=v(n,3)/v(n,1)
         wl=v(n,4)/v(n,1)
         ur=v(n1,2)/v(n1,1)
         vr=v(n1,3)/v(n1,1)
         wr=v(n1,4)/v(n1,1)
         al=sqrt(gam*ps(n )/v(n,1))
         ar=sqrt(gam*ps(n1)/v(n1,1))
         hl=al*al/gam1+0.5*(ul**2+vl**2+wl**2)
         hr=ar*ar/gam1+0.5*(ur**2+vr**2+wr**2)
!        calcul de etat moyen de Roe
         gd=sqrt(v(n1,1)/v(n,1))
         gd1=1./(1.+gd)
         gd2=gd*gd1
         rhom=sqrt(v(n,1)*v(n1,1))
         rhomi=1./rhom
         um=gd1*ul+gd2*ur
         vm=gd1*vl+gd2*vr
         wm=gd1*wl+gd2*wr
         hm=gd1*hl+gd2*hr
         vitm2=0.5*(um**2+vm**2+wm**2)
         am=sqrt(abs(gam1*(hm-vitm2)))
         am2i=1./(am*am)
         vn=um*nx+vm*ny+wm*nz
         rhoiam=rhom/am
         rhoami=am2i/rhoiam
!        valeurs propres de la matrice jacobienne des flux
         v1=vn
         v4=vn+am
         v5=vn-am
!        calcul des matrices de passage a gauche Q et a droite P
         q11=(1.-gam1*vitm2*am2i)*nx-(vm*nz-wm*ny)*rhomi
         q12=gam1*um*nx*am2i
         q13=gam1*vm*nx*am2i+nz*rhomi
         q14=gam1*wm*nx*am2i-ny*rhomi
         q15=-gam1*nx*am2i
         q21=(1.-gam1*vitm2*am2i)*ny-(wm*nx-um*nz)*rhomi
         q22=gam1*um*ny*am2i-nz*rhomi
         q23=gam1*vm*ny*am2i
         q24=gam1*wm*ny*am2i+nx*rhomi
         q25=-gam1*ny*am2i
         q31=(1.-gam1*vitm2*am2i)*nz-(um*ny-vm*nx)*rhomi
         q32=gam1*um*nz*am2i+ny*rhomi
         q33=gam1*vm*nz*am2i-nx*rhomi
         q34=gam1*wm*nz*am2i
         q35=-gam1*nz*am2i
         q41=gam1*vitm2*rhoami-vn*rhomi
         q42=nx*rhomi-gam1*um*rhoami
         q43=ny*rhomi-gam1*vm*rhoami
         q44=nz*rhomi-gam1*wm*rhoami
         q45=gam1*rhoami
         q51=gam1*vitm2*rhoami+vn*rhomi
         q52=-nx*rhomi-gam1*um*rhoami
         q53=-ny*rhomi-gam1*vm*rhoami
         q54=-nz*rhomi-gam1*wm*rhoami
         q55=gam1*rhoami
!
         p11=nx
         p12=ny
         p13=nz
         p14=0.5*rhoiam
         p15=0.5*rhoiam
         p21=um*nx
         p22=um*ny-rhom*nz
         p23=um*nz+rhom*ny
         p24=0.5*rhoiam*(um+nx*am)
         p25=0.5*rhoiam*(um-nx*am)
         p31=vm*nx+rhom*nz
         p32=vm*ny
         p33=vm*nz-rhom*nx
         p34=0.5*rhoiam*(vm+ny*am)
         p35=0.5*rhoiam*(vm-ny*am)
         p41=wm*nx-rhom*ny
         p42=wm*ny+rhom*nx
         p43=wm*nz
         p44=0.5*rhoiam*(wm+nz*am)
         p45=0.5*rhoiam*(wm-nz*am)
         p51=vitm2*nx+rhom*(vm*nz-wm*ny)
         p52=vitm2*ny+rhom*(wm*nx-um*nz)
         p53=vitm2*nz+rhom*(um*ny-vm*nx)
         p54=0.5*rhoiam*(hm+am*vn)
         p55=0.5*rhoiam*(hm-am*vn)
!        produit de Q avec les flux Euler aux points (i-1) a (i+2)
         q1f1m=q11*v(n-ninc  ,2)+q12*fxx(m-ninc)  +q13*fxy(m-ninc) &
                                +q14*fxz(m-ninc)  +q15*fex(m-ninc)
         q1f  =q11*v(n       ,2)+q12*fxx(m)       +q13*fxy(m) &
                                +q14*fxz(m)       +q15*fex(m)
         q1f1p=q11*v(n+ninc  ,2)+q12*fxx(m+ninc)  +q13*fxy(m+ninc) &
                                +q14*fxz(m+ninc)  +q15*fex(m+ninc)
         q1f2p=q11*v(n+2*ninc,2)+q12*fxx(m+2*ninc)+q13*fxy(m+2*ninc) &
                                +q14*fxz(m+2*ninc)+q15*fex(m+2*ninc)
!
         q2f1m=q21*v(n-ninc  ,2)+q22*fxx(m-ninc)  +q23*fxy(m-ninc) &
                                +q24*fxz(m-ninc)  +q25*fex(m-ninc)
         q2f  =q21*v(n       ,2)+q22*fxx(m)       +q23*fxy(m) &
                                +q24*fxz(m)       +q25*fex(m)
         q2f1p=q21*v(n+ninc  ,2)+q22*fxx(m+ninc)  +q23*fxy(m+ninc) &
                                +q24*fxz(m+ninc)  +q25*fex(m+ninc)
         q2f2p=q21*v(n+2*ninc,2)+q22*fxx(m+2*ninc)+q23*fxy(m+2*ninc) &
                                +q24*fxz(m+2*ninc)+q25*fex(m+2*ninc)
!
         q3f1m=q31*v(n-ninc  ,2)+q32*fxx(m-ninc)  +q33*fxy(m-ninc) &
                                +q34*fxz(m-ninc)  +q35*fex(m-ninc)
         q3f  =q31*v(n       ,2)+q32*fxx(m)       +q33*fxy(m) &
                                +q34*fxz(m)       +q35*fex(m)
         q3f1p=q31*v(n+ninc  ,2)+q32*fxx(m+ninc)  +q33*fxy(m+ninc) &
                                +q34*fxz(m+ninc)  +q35*fex(m+ninc)
         q3f2p=q31*v(n+2*ninc,2)+q32*fxx(m+2*ninc)+q33*fxy(m+2*ninc) &
                                +q34*fxz(m+2*ninc)+q35*fex(m+2*ninc)
!
         q4f1m=q41*v(n-ninc  ,2)+q42*fxx(m-ninc)  +q43*fxy(m-ninc) &
                                +q44*fxz(m-ninc)  +q45*fex(m-ninc)
         q4f  =q41*v(n       ,2)+q42*fxx(m)       +q43*fxy(m) &
                                +q44*fxz(m)       +q45*fex(m)
         q4f1p=q41*v(n+ninc  ,2)+q42*fxx(m+ninc)  +q43*fxy(m+ninc) &
                                +q44*fxz(m+ninc)  +q45*fex(m+ninc)
         q4f2p=q41*v(n+2*ninc,2)+q42*fxx(m+2*ninc)+q43*fxy(m+2*ninc) &
                                +q44*fxz(m+2*ninc)+q45*fex(m+2*ninc)
!
         q5f1m=q51*v(n-ninc  ,2)+q52*fxx(m-ninc)  +q53*fxy(m-ninc) &
                                +q54*fxz(m-ninc)  +q55*fex(m-ninc)
         q5f  =q51*v(n       ,2)+q52*fxx(m)       +q53*fxy(m) &
                                +q54*fxz(m)       +q55*fex(m)
         q5f1p=q51*v(n+ninc  ,2)+q52*fxx(m+ninc)  +q53*fxy(m+ninc) &
                                +q54*fxz(m+ninc)  +q55*fex(m+ninc)
         q5f2p=q51*v(n+2*ninc,2)+q52*fxx(m+2*ninc)+q53*fxy(m+2*ninc) &
                                +q54*fxz(m+2*ninc)+q55*fex(m+2*ninc)
!        calcul des flux d'ordre 2 sur les 2 stencils
         f11=0.5*(1.+sign(1.,v1))*(q1f1m*c10 +q1f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q1f  *c00 +q1f1p*c01)
         f12=0.5*(1.+sign(1.,v1))*(q1f  *c00 +q1f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q1f1p*c11 +q1f2p*c10)
!
         f21=0.5*(1.+sign(1.,v1))*(q2f1m*c10 +q2f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q2f  *c00 +q2f1p*c01)
         f22=0.5*(1.+sign(1.,v1))*(q2f  *c00 +q2f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q2f1p*c11 +q2f2p*c10)
!
         f31=0.5*(1.+sign(1.,v1))*(q3f1m*c10 +q3f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q3f  *c00 +q3f1p*c01)
         f32=0.5*(1.+sign(1.,v1))*(q3f  *c00 +q3f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q3f1p*c11 +q3f2p*c10)
!
         f41=0.5*(1.+sign(1.,v4))*(q4f1m*c10 +q4f  *c11) &
            +0.5*(1.-sign(1.,v4))*(q4f  *c00 +q4f1p*c01)
         f42=0.5*(1.+sign(1.,v4))*(q4f  *c00 +q4f1p*c01) &
            +0.5*(1.-sign(1.,v4))*(q4f1p*c11 +q4f2p*c10)
!
         f51=0.5*(1.+sign(1.,v5))*(q5f1m*c10 +q5f  *c11) &
            +0.5*(1.-sign(1.,v5))*(q5f  *c00 +q5f1p*c01)
         f52=0.5*(1.+sign(1.,v5))*(q5f  *c00 +q5f1p*c01) &
            +0.5*(1.-sign(1.,v5))*(q5f1p*c11 +q5f2p*c10)
!        calcul des senseurs beta (au carre)
         iexp=2
!         iexp=1
         beta11=(0.5*(1.+sign(1.,v1))*(q1f-q1f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f1p-q1f)**2+eps)**iexp
         beta12=(0.5*(1.+sign(1.,v1))*(q1f1p-q1f)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f2p-q1f1p)**2+eps)**iexp
!
         beta21=(0.5*(1.+sign(1.,v1))*(q2f-q2f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f1p-q2f)**2+eps)**iexp
         beta22=(0.5*(1.+sign(1.,v1))*(q2f1p-q2f)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f2p-q2f1p)**2+eps)**iexp
!
         beta31=(0.5*(1.+sign(1.,v1))*(q3f-q3f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f1p-q3f)**2+eps)**iexp
         beta32=(0.5*(1.+sign(1.,v1))*(q3f1p-q3f)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f2p-q3f1p)**2+eps)**iexp
!
         beta41=(0.5*(1.+sign(1.,v4))*(q4f-q4f1m)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f1p-q4f)**2+eps)**iexp
         beta42=(0.5*(1.+sign(1.,v4))*(q4f1p-q4f)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f2p-q4f1p)**2+eps)**iexp
!
         beta51=(0.5*(1.+sign(1.,v5))*(q5f-q5f1m)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f1p-q5f)**2+eps)**iexp
         beta52=(0.5*(1.+sign(1.,v5))*(q5f1p-q5f)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f2p-q5f1p)**2+eps)**iexp
!        calculs des poids wi
         ww11=0.5*(1.+sign(1.,v1))*(ga1/beta11) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta11)
         ww21=0.5*(1.+sign(1.,v1))*(ga2/beta12) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta12)
         sw=ww11+ww21
         w11=ww11/sw
         w21=ww21/sw
   ww11m=w11*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w11+w11**2)/(ga1**2+w11*(1.-2.*ga1)) &
        +w11*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w11+w11**2)/(ga2**2+w11*(1.-2.*ga2))
   ww21m=w21*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w21+w21**2)/(ga2**2+w21*(1.-2.*ga2)) &   
        +w21*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w21+w21**2)/(ga1**2+w21*(1.-2.*ga1))
         swm=ww11m+ww21m
         w11=ww11m/swm 
         w21=ww21m/swm 
!
         ww12=0.5*(1.+sign(1.,v1))*(ga1/beta21) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta21)
         ww22=0.5*(1.+sign(1.,v1))*(ga2/beta22) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta22)
         sw=ww12+ww22
         w12=ww12/sw
         w22=ww22/sw
   ww12m=w12*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w12+w12**2)/(ga1**2+w12*(1.-2.*ga1)) &
        +w12*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w12+w12**2)/(ga2**2+w12*(1.-2.*ga2))
   ww22m=w22*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w22+w22**2)/(ga2**2+w22*(1.-2.*ga2)) &   
        +w22*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w22+w22**2)/(ga1**2+w22*(1.-2.*ga1))
         swm=ww12m+ww22m 
         w12=ww12m/swm 
         w22=ww22m/swm 
!
         ww13=0.5*(1.+sign(1.,v1))*(ga1/beta31) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta31)
         ww23=0.5*(1.+sign(1.,v1))*(ga2/beta32) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta32)
         sw=ww13+ww23
         w13=ww13/sw
         w23=ww23/sw
   ww13m=w13*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w13+w13**2)/(ga1**2+w13*(1.-2.*ga1)) &
        +w13*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w13+w13**2)/(ga2**2+w13*(1.-2.*ga2))
   ww23m=w23*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w23+w23**2)/(ga2**2+w23*(1.-2.*ga2)) &   
        +w23*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w23+w23**2)/(ga1**2+w23*(1.-2.*ga1))
         swm=ww13m+ww23m
         w13=ww13m/swm 
         w23=ww23m/swm 
!
         ww14=0.5*(1.+sign(1.,v4))*(ga1/beta41) &
             +0.5*(1.-sign(1.,v4))*(ga2/beta41)
         ww24=0.5*(1.+sign(1.,v4))*(ga2/beta42) &
             +0.5*(1.-sign(1.,v4))*(ga1/beta42)
         sw=ww14+ww24
         w14=ww14/sw
         w24=ww24/sw
   ww14m=w14*0.5*(1.+sign(1.,v4))*(ga1+ga1**2-3.*ga1*w14+w14**2)/(ga1**2+w14*(1.-2.*ga1)) &
        +w14*0.5*(1.-sign(1.,v4))*(ga2+ga2**2-3.*ga2*w14+w14**2)/(ga2**2+w14*(1.-2.*ga2))
   ww24m=w24*0.5*(1.+sign(1.,v4))*(ga2+ga2**2-3.*ga2*w24+w24**2)/(ga2**2+w24*(1.-2.*ga2)) &   
        +w24*0.5*(1.-sign(1.,v4))*(ga1+ga1**2-3.*ga1*w24+w24**2)/(ga1**2+w24*(1.-2.*ga1))
         swm=ww14m+ww24m 
         w14=ww14m/swm 
         w24=ww24m/swm 
!
         ww15=0.5*(1.+sign(1.,v5))*(ga1/beta51) &
             +0.5*(1.-sign(1.,v5))*(ga2/beta51)
         ww25=0.5*(1.+sign(1.,v5))*(ga2/beta52) &
             +0.5*(1.-sign(1.,v5))*(ga1/beta52)
         sw=ww15+ww25
         w15=ww15/sw
         w25=ww25/sw
   ww15m=w15*0.5*(1.+sign(1.,v5))*(ga1+ga1**2-3.*ga1*w15+w15**2)/(ga1**2+w15*(1.-2.*ga1)) &
        +w15*0.5*(1.-sign(1.,v5))*(ga2+ga2**2-3.*ga2*w15+w15**2)/(ga2**2+w15*(1.-2.*ga2))
   ww25m=w25*0.5*(1.+sign(1.,v5))*(ga2+ga2**2-3.*ga2*w25+w25**2)/(ga2**2+w25*(1.-2.*ga2)) &   
        +w25*0.5*(1.-sign(1.,v5))*(ga1+ga1**2-3.*ga1*w25+w25**2)/(ga1**2+w25*(1.-2.*ga1))
         swm=ww15m+ww25m
         w15=ww15m/swm 
         w25=ww25m/swm 
!        calcul des flux convectifs projetes
         fc1=w11*f11+w21*f12
         fc2=w12*f21+w22*f22
         fc3=w13*f31+w23*f32
         fc4=w14*f41+w24*f42
         fc5=w15*f51+w25*f52
!        produit avec matrice P pour retour dans l'espace physique
         f1=fc1*p11+fc2*p12+fc3*p13+fc4*p14+fc5*p15
         f2=fc1*p21+fc2*p22+fc3*p23+fc4*p24+fc5*p25
         f3=fc1*p31+fc2*p32+fc3*p33+fc4*p34+fc5*p35
         f4=fc1*p41+fc2*p42+fc3*p43+fc4*p44+fc5*p45
         f5=fc1*p51+fc2*p52+fc3*p53+fc4*p54+fc5*p55
!-------------------------------------------------------------------
!        produit de Q avec les flux Euler aux points (i-1) a (i+2)
         q1f1m=q11*v(n-ninc  ,3)+q12*fxy(m-ninc)  +q13*fyy(m-ninc) &
                                +q14*fyz(m-ninc)  +q15*fey(m-ninc)
         q1f  =q11*v(n       ,3)+q12*fxy(m)       +q13*fyy(m) &
                                +q14*fyz(m)       +q15*fey(m)
         q1f1p=q11*v(n+ninc  ,3)+q12*fxy(m+ninc)  +q13*fyy(m+ninc) &
                                +q14*fyz(m+ninc)  +q15*fey(m+ninc)
         q1f2p=q11*v(n+2*ninc,3)+q12*fxy(m+2*ninc)+q13*fyy(m+2*ninc) &
                                +q14*fyz(m+2*ninc)+q15*fey(m+2*ninc)
!
         q2f1m=q21*v(n-ninc  ,3)+q22*fxy(m-ninc)  +q23*fyy(m-ninc) &
                                +q24*fyz(m-ninc)  +q25*fey(m-ninc)
         q2f  =q21*v(n       ,3)+q22*fxy(m)       +q23*fyy(m) &
                                +q24*fyz(m)       +q25*fey(m)
         q2f1p=q21*v(n+ninc  ,3)+q22*fxy(m+ninc)  +q23*fyy(m+ninc) &
                                +q24*fyz(m+ninc)  +q25*fey(m+ninc)
         q2f2p=q21*v(n+2*ninc,3)+q22*fxy(m+2*ninc)+q23*fyy(m+2*ninc) &
                                +q24*fyz(m+2*ninc)+q25*fey(m+2*ninc)
!
         q3f1m=q31*v(n-ninc  ,3)+q32*fxy(m-ninc)  +q33*fyy(m-ninc) &
                                +q34*fyz(m-ninc)  +q35*fey(m-ninc)
         q3f  =q31*v(n       ,3)+q32*fxy(m)       +q33*fyy(m) &
                                +q34*fyz(m)       +q35*fey(m)
         q3f1p=q31*v(n+ninc  ,3)+q32*fxy(m+ninc)  +q33*fyy(m+ninc) &
                                +q34*fyz(m+ninc)  +q35*fey(m+ninc)
         q3f2p=q31*v(n+2*ninc,3)+q32*fxy(m+2*ninc)+q33*fyy(m+2*ninc) &
                                +q34*fyz(m+2*ninc)+q35*fey(m+2*ninc)
!
         q4f1m=q41*v(n-ninc  ,3)+q42*fxy(m-ninc)  +q43*fyy(m-ninc) &
                                +q44*fyz(m-ninc)  +q45*fey(m-ninc)
         q4f  =q41*v(n       ,3)+q42*fxy(m)       +q43*fyy(m) &
                                +q44*fyz(m)       +q45*fey(m)
         q4f1p=q41*v(n+ninc  ,3)+q42*fxy(m+ninc)  +q43*fyy(m+ninc) &
                                +q44*fyz(m+ninc)  +q45*fey(m+ninc)
         q4f2p=q41*v(n+2*ninc,3)+q42*fxy(m+2*ninc)+q43*fyy(m+2*ninc) &
                                +q44*fyz(m+2*ninc)+q45*fey(m+2*ninc)
!
         q5f1m=q51*v(n-ninc  ,3)+q52*fxy(m-ninc)  +q53*fyy(m-ninc) &
                                +q54*fyz(m-ninc)  +q55*fey(m-ninc)
         q5f  =q51*v(n       ,3)+q52*fxy(m)       +q53*fyy(m) &
                                +q54*fyz(m)       +q55*fey(m)
         q5f1p=q51*v(n+ninc  ,3)+q52*fxy(m+ninc)  +q53*fyy(m+ninc) &
                                +q54*fyz(m+ninc)  +q55*fey(m+ninc)
         q5f2p=q51*v(n+2*ninc,3)+q52*fxy(m+2*ninc)+q53*fyy(m+2*ninc) &
                                +q54*fyz(m+2*ninc)+q55*fey(m+2*ninc)
!        calcul des flux d'ordre 2 sur les 2 stencils
         g11=0.5*(1.+sign(1.,v1))*(q1f1m*c10 +q1f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q1f  *c00 +q1f1p*c01)
         g12=0.5*(1.+sign(1.,v1))*(q1f  *c00 +q1f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q1f1p*c11 +q1f2p*c10)
!
         g21=0.5*(1.+sign(1.,v1))*(q2f1m*c10 +q2f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q2f  *c00 +q2f1p*c01)
         g22=0.5*(1.+sign(1.,v1))*(q2f  *c00 +q2f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q2f1p*c11 +q2f2p*c10)
!
         g31=0.5*(1.+sign(1.,v1))*(q3f1m*c10 +q3f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q3f  *c00 +q3f1p*c01)
         g32=0.5*(1.+sign(1.,v1))*(q3f  *c00 +q3f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q3f1p*c11 +q3f2p*c10)
!
         g41=0.5*(1.+sign(1.,v4))*(q4f1m*c10 +q4f  *c11) &
            +0.5*(1.-sign(1.,v4))*(q4f  *c00 +q4f1p*c01)
         g42=0.5*(1.+sign(1.,v4))*(q4f  *c00 +q4f1p*c01) &
            +0.5*(1.-sign(1.,v4))*(q4f1p*c11 +q4f2p*c10)
!
         g51=0.5*(1.+sign(1.,v5))*(q5f1m*c10 +q5f  *c11) &
            +0.5*(1.-sign(1.,v5))*(q5f  *c00 +q5f1p*c01)
         g52=0.5*(1.+sign(1.,v5))*(q5f  *c00 +q5f1p*c01) &
            +0.5*(1.-sign(1.,v5))*(q5f1p*c11 +q5f2p*c10)
!        calcul des senseurs beta (au carre)
         iexp=2
!         iexp=1
         beta11=(0.5*(1.+sign(1.,v1))*(q1f-q1f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f1p-q1f)**2+eps)**iexp
         beta12=(0.5*(1.+sign(1.,v1))*(q1f1p-q1f)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f2p-q1f1p)**2+eps)**iexp
!
         beta21=(0.5*(1.+sign(1.,v1))*(q2f-q2f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f1p-q2f)**2+eps)**iexp
         beta22=(0.5*(1.+sign(1.,v1))*(q2f1p-q2f)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f2p-q2f1p)**2+eps)**iexp
!
         beta31=(0.5*(1.+sign(1.,v1))*(q3f-q3f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f1p-q3f)**2+eps)**iexp
         beta32=(0.5*(1.+sign(1.,v1))*(q3f1p-q3f)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f2p-q3f1p)**2+eps)**iexp
!
         beta41=(0.5*(1.+sign(1.,v4))*(q4f-q4f1m)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f1p-q4f)**2+eps)**iexp
         beta42=(0.5*(1.+sign(1.,v4))*(q4f1p-q4f)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f2p-q4f1p)**2+eps)**iexp
!
         beta51=(0.5*(1.+sign(1.,v5))*(q5f-q5f1m)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f1p-q5f)**2+eps)**iexp
         beta52=(0.5*(1.+sign(1.,v5))*(q5f1p-q5f)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f2p-q5f1p)**2+eps)**iexp
!        calculs des poids wi
         ww11=0.5*(1.+sign(1.,v1))*(ga1/beta11) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta11)
         ww21=0.5*(1.+sign(1.,v1))*(ga2/beta12) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta12)
         sw=ww11+ww21
         w11=ww11/sw
         w21=ww21/sw
   ww11m=w11*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w11+w11**2)/(ga1**2+w11*(1.-2.*ga1)) &
        +w11*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w11+w11**2)/(ga2**2+w11*(1.-2.*ga2))
   ww21m=w21*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w21+w21**2)/(ga2**2+w21*(1.-2.*ga2)) &   
        +w21*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w21+w21**2)/(ga1**2+w21*(1.-2.*ga1))
         swm=ww11m+ww21m
         w11=ww11m/swm 
         w21=ww21m/swm 
!
         ww12=0.5*(1.+sign(1.,v1))*(ga1/beta21) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta21)
         ww22=0.5*(1.+sign(1.,v1))*(ga2/beta22) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta22)
         sw=ww12+ww22
         w12=ww12/sw
         w22=ww22/sw
   ww12m=w12*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w12+w12**2)/(ga1**2+w12*(1.-2.*ga1)) &
        +w12*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w12+w12**2)/(ga2**2+w12*(1.-2.*ga2))
   ww22m=w22*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w22+w22**2)/(ga2**2+w22*(1.-2.*ga2)) &   
        +w22*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w22+w22**2)/(ga1**2+w22*(1.-2.*ga1))
         swm=ww12m+ww22m 
         w12=ww12m/swm 
         w22=ww22m/swm 
!
         ww13=0.5*(1.+sign(1.,v1))*(ga1/beta31) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta31)
         ww23=0.5*(1.+sign(1.,v1))*(ga2/beta32) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta32)
         sw=ww13+ww23
         w13=ww13/sw
         w23=ww23/sw
   ww13m=w13*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w13+w13**2)/(ga1**2+w13*(1.-2.*ga1)) &
        +w13*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w13+w13**2)/(ga2**2+w13*(1.-2.*ga2))
   ww23m=w23*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w23+w23**2)/(ga2**2+w23*(1.-2.*ga2)) &   
        +w23*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w23+w23**2)/(ga1**2+w23*(1.-2.*ga1))
         swm=ww13m+ww23m
         w13=ww13m/swm 
         w23=ww23m/swm 
!
         ww14=0.5*(1.+sign(1.,v4))*(ga1/beta41) &
             +0.5*(1.-sign(1.,v4))*(ga2/beta41)
         ww24=0.5*(1.+sign(1.,v4))*(ga2/beta42) &
             +0.5*(1.-sign(1.,v4))*(ga1/beta42)
         sw=ww14+ww24
         w14=ww14/sw
         w24=ww24/sw
   ww14m=w14*0.5*(1.+sign(1.,v4))*(ga1+ga1**2-3.*ga1*w14+w14**2)/(ga1**2+w14*(1.-2.*ga1)) &
        +w14*0.5*(1.-sign(1.,v4))*(ga2+ga2**2-3.*ga2*w14+w14**2)/(ga2**2+w14*(1.-2.*ga2))
   ww24m=w24*0.5*(1.+sign(1.,v4))*(ga2+ga2**2-3.*ga2*w24+w24**2)/(ga2**2+w24*(1.-2.*ga2)) &   
        +w24*0.5*(1.-sign(1.,v4))*(ga1+ga1**2-3.*ga1*w24+w24**2)/(ga1**2+w24*(1.-2.*ga1))
         swm=ww14m+ww24m 
         w14=ww14m/swm 
         w24=ww24m/swm 
!
         ww15=0.5*(1.+sign(1.,v5))*(ga1/beta51) &
             +0.5*(1.-sign(1.,v5))*(ga2/beta51)
         ww25=0.5*(1.+sign(1.,v5))*(ga2/beta52) &
             +0.5*(1.-sign(1.,v5))*(ga1/beta52)
         sw=ww15+ww25
         w15=ww15/sw
         w25=ww25/sw
   ww15m=w15*0.5*(1.+sign(1.,v5))*(ga1+ga1**2-3.*ga1*w15+w15**2)/(ga1**2+w15*(1.-2.*ga1)) &
        +w15*0.5*(1.-sign(1.,v5))*(ga2+ga2**2-3.*ga2*w15+w15**2)/(ga2**2+w15*(1.-2.*ga2))
   ww25m=w25*0.5*(1.+sign(1.,v5))*(ga2+ga2**2-3.*ga2*w25+w25**2)/(ga2**2+w25*(1.-2.*ga2)) &   
        +w25*0.5*(1.-sign(1.,v5))*(ga1+ga1**2-3.*ga1*w25+w25**2)/(ga1**2+w25*(1.-2.*ga1))
         swm=ww15m+ww25m
         w15=ww15m/swm 
         w25=ww25m/swm 
!        calcul des flux convectifs projetes
         gc1=w11*g11+w21*g12
         gc2=w12*g21+w22*g22
         gc3=w13*g31+w23*g32
         gc4=w14*g41+w24*g42
         gc5=w15*g51+w25*g52
!        produit avec matrice P pour retour dans l'espace physique
         g1=gc1*p11+gc2*p12+gc3*p13+gc4*p14+gc5*p15
         g2=gc1*p21+gc2*p22+gc3*p23+gc4*p24+gc5*p25
         g3=gc1*p31+gc2*p32+gc3*p33+gc4*p34+gc5*p35
         g4=gc1*p41+gc2*p42+gc3*p43+gc4*p44+gc5*p45
         g5=gc1*p51+gc2*p52+gc3*p53+gc4*p54+gc5*p55
!-------------------------------------------------------------------
!        produit de Q avec les flux Euler aux points (i-1) a (i+2)
         q1f1m=q11*v(n-ninc  ,4)+q12*fxz(m-ninc)  +q13*fyz(m-ninc) &
                                +q14*fzz(m-ninc)  +q15*fez(m-ninc) 
         q1f  =q11*v(n       ,4)+q12*fxz(m)       +q13*fyz(m) &
                                +q14*fzz(m)       +q15*fez(m)
         q1f1p=q11*v(n+ninc  ,4)+q12*fxz(m+ninc)  +q13*fyz(m+ninc) &
                                +q14*fzz(m+ninc)  +q15*fez(m+ninc)     
         q1f2p=q11*v(n+2*ninc,4)+q12*fxz(m+2*ninc)+q13*fyz(m+2*ninc) &
                                +q14*fzz(m+2*ninc)+q15*fez(m+2*ninc)
!
         q2f1m=q21*v(n-ninc  ,4)+q22*fxz(m-ninc)  +q23*fyz(m-ninc) &
                                +q24*fzz(m-ninc)  +q25*fez(m-ninc)
         q2f  =q21*v(n       ,4)+q22*fxz(m)       +q23*fyz(m) &
                                +q24*fzz(m)       +q25*fez(m)
         q2f1p=q21*v(n+ninc  ,4)+q22*fxz(m+ninc)  +q23*fyz(m+ninc) &
                                +q24*fzz(m+ninc)  +q25*fez(m+ninc)
         q2f2p=q21*v(n+2*ninc,4)+q22*fxz(m+2*ninc)+q23*fyz(m+2*ninc) &
                                +q24*fzz(m+2*ninc)+q25*fez(m+2*ninc)
!
         q3f1m=q31*v(n-ninc  ,4)+q32*fxz(m-ninc)  +q33*fyz(m-ninc) &
                                +q34*fzz(m-ninc)  +q35*fez(m-ninc)
         q3f  =q31*v(n       ,4)+q32*fxz(m)       +q33*fyz(m) &
                                +q34*fzz(m)       +q35*fez(m)
         q3f1p=q31*v(n+ninc  ,4)+q32*fxz(m+ninc)  +q33*fyz(m+ninc) &
                                +q34*fzz(m+ninc)  +q35*fez(m+ninc)
         q3f2p=q31*v(n+2*ninc,4)+q32*fxz(m+2*ninc)+q33*fyz(m+2*ninc) &
                                +q34*fzz(m+2*ninc)+q35*fez(m+2*ninc)
!
         q4f1m=q41*v(n-ninc  ,4)+q42*fxz(m-ninc)  +q43*fyz(m-ninc) &
                                +q44*fzz(m-ninc)  +q45*fez(m-ninc)
         q4f  =q41*v(n       ,4)+q42*fxz(m)       +q43*fyz(m) &
                                +q44*fzz(m)       +q45*fez(m)
         q4f1p=q41*v(n+ninc  ,4)+q42*fxz(m+ninc)  +q43*fyz(m+ninc) &
                                +q44*fzz(m+ninc)  +q45*fez(m+ninc)
         q4f2p=q41*v(n+2*ninc,4)+q42*fxz(m+2*ninc)+q43*fyz(m+2*ninc) &
                                +q44*fzz(m+2*ninc)+q45*fez(m+2*ninc)
!
         q5f1m=q51*v(n-ninc  ,4)+q52*fxz(m-ninc)  +q53*fyz(m-ninc) &
                                +q54*fzz(m-ninc)  +q55*fez(m-ninc)
         q5f  =q51*v(n       ,4)+q52*fxz(m)       +q53*fyz(m) &
                                +q54*fzz(m)       +q55*fez(m)
         q5f1p=q51*v(n+ninc  ,4)+q52*fxz(m+ninc)  +q53*fyz(m+ninc) &
                                +q54*fzz(m+ninc)  +q55*fez(m+ninc)
         q5f2p=q51*v(n+2*ninc,4)+q52*fxz(m+2*ninc)+q53*fyz(m+2*ninc) &
                                +q54*fzz(m+2*ninc)+q55*fez(m+2*ninc)
!        calcul des flux d'ordre 2 sur les 2 stencils       
         h11=0.5*(1.+sign(1.,v1))*(q1f1m*c10 +q1f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q1f  *c00 +q1f1p*c01)
         h12=0.5*(1.+sign(1.,v1))*(q1f  *c00 +q1f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q1f1p*c11 +q1f2p*c10)
!     
         h21=0.5*(1.+sign(1.,v1))*(q2f1m*c10 +q2f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q2f  *c00 +q2f1p*c01)
         h22=0.5*(1.+sign(1.,v1))*(q2f  *c00 +q2f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q2f1p*c11 +q2f2p*c10)
!
         h31=0.5*(1.+sign(1.,v1))*(q3f1m*c10 +q3f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q3f  *c00 +q3f1p*c01)
         h32=0.5*(1.+sign(1.,v1))*(q3f  *c00 +q3f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q3f1p*c11 +q3f2p*c10)
!
         h41=0.5*(1.+sign(1.,v4))*(q4f1m*c10 +q4f  *c11) &
            +0.5*(1.-sign(1.,v4))*(q4f  *c00 +q4f1p*c01)
         h42=0.5*(1.+sign(1.,v4))*(q4f  *c00 +q4f1p*c01) &
            +0.5*(1.-sign(1.,v4))*(q4f1p*c11 +q4f2p*c10)
!
         h51=0.5*(1.+sign(1.,v5))*(q5f1m*c10 +q5f  *c11) &
            +0.5*(1.-sign(1.,v5))*(q5f  *c00 +q5f1p*c01)
         h52=0.5*(1.+sign(1.,v5))*(q5f  *c00 +q5f1p*c01) &
            +0.5*(1.-sign(1.,v5))*(q5f1p*c11 +q5f2p*c10)
!        calcul des senseurs beta (au carre)
         iexp=2
!         iexp=1 
         beta11=(0.5*(1.+sign(1.,v1))*(q1f-q1f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f1p-q1f)**2+eps)**iexp
         beta12=(0.5*(1.+sign(1.,v1))*(q1f1p-q1f)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f2p-q1f1p)**2+eps)**iexp
!
         beta21=(0.5*(1.+sign(1.,v1))*(q2f-q2f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f1p-q2f)**2+eps)**iexp
         beta22=(0.5*(1.+sign(1.,v1))*(q2f1p-q2f)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f2p-q2f1p)**2+eps)**iexp
!
         beta31=(0.5*(1.+sign(1.,v1))*(q3f-q3f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f1p-q3f)**2+eps)**iexp
         beta32=(0.5*(1.+sign(1.,v1))*(q3f1p-q3f)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f2p-q3f1p)**2+eps)**iexp
!
         beta41=(0.5*(1.+sign(1.,v4))*(q4f-q4f1m)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f1p-q4f)**2+eps)**iexp
         beta42=(0.5*(1.+sign(1.,v4))*(q4f1p-q4f)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f2p-q4f1p)**2+eps)**iexp
!
         beta51=(0.5*(1.+sign(1.,v5))*(q5f-q5f1m)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f1p-q5f)**2+eps)**iexp
         beta52=(0.5*(1.+sign(1.,v5))*(q5f1p-q5f)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f2p-q5f1p)**2+eps)**iexp
!        calculs des poids wi    
         ww11=0.5*(1.+sign(1.,v1))*(ga1/beta11) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta11)
         ww21=0.5*(1.+sign(1.,v1))*(ga2/beta12) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta12)
         sw=ww11+ww21
         w11=ww11/sw
         w21=ww21/sw
   ww11m=w11*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w11+w11**2)/(ga1**2+w11*(1.-2.*ga1)) &
        +w11*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w11+w11**2)/(ga2**2+w11*(1.-2.*ga2))
   ww21m=w21*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w21+w21**2)/(ga2**2+w21*(1.-2.*ga2)) &   
        +w21*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w21+w21**2)/(ga1**2+w21*(1.-2.*ga1))
         swm=ww11m+ww21m
         w11=ww11m/swm 
         w21=ww21m/swm 
!
         ww12=0.5*(1.+sign(1.,v1))*(ga1/beta21) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta21)
         ww22=0.5*(1.+sign(1.,v1))*(ga2/beta22) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta22)
         sw=ww12+ww22
         w12=ww12/sw
         w22=ww22/sw
   ww12m=w12*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w12+w12**2)/(ga1**2+w12*(1.-2.*ga1)) &
        +w12*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w12+w12**2)/(ga2**2+w12*(1.-2.*ga2))
   ww22m=w22*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w22+w22**2)/(ga2**2+w22*(1.-2.*ga2)) &   
        +w22*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w22+w22**2)/(ga1**2+w22*(1.-2.*ga1))
         swm=ww12m+ww22m 
         w12=ww12m/swm 
         w22=ww22m/swm 
!
         ww13=0.5*(1.+sign(1.,v1))*(ga1/beta31) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta31)
         ww23=0.5*(1.+sign(1.,v1))*(ga2/beta32) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta32)
         sw=ww13+ww23
         w13=ww13/sw
         w23=ww23/sw
   ww13m=w13*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w13+w13**2)/(ga1**2+w13*(1.-2.*ga1)) &
        +w13*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w13+w13**2)/(ga2**2+w13*(1.-2.*ga2))
   ww23m=w23*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w23+w23**2)/(ga2**2+w23*(1.-2.*ga2)) &   
        +w23*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w23+w23**2)/(ga1**2+w23*(1.-2.*ga1))
         swm=ww13m+ww23m
         w13=ww13m/swm 
         w23=ww23m/swm 
!
         ww14=0.5*(1.+sign(1.,v4))*(ga1/beta41) &
             +0.5*(1.-sign(1.,v4))*(ga2/beta41)
         ww24=0.5*(1.+sign(1.,v4))*(ga2/beta42) &
             +0.5*(1.-sign(1.,v4))*(ga1/beta42)
         sw=ww14+ww24
         w14=ww14/sw
         w24=ww24/sw
   ww14m=w14*0.5*(1.+sign(1.,v4))*(ga1+ga1**2-3.*ga1*w14+w14**2)/(ga1**2+w14*(1.-2.*ga1)) &
        +w14*0.5*(1.-sign(1.,v4))*(ga2+ga2**2-3.*ga2*w14+w14**2)/(ga2**2+w14*(1.-2.*ga2))
   ww24m=w24*0.5*(1.+sign(1.,v4))*(ga2+ga2**2-3.*ga2*w24+w24**2)/(ga2**2+w24*(1.-2.*ga2)) &   
        +w24*0.5*(1.-sign(1.,v4))*(ga1+ga1**2-3.*ga1*w24+w24**2)/(ga1**2+w24*(1.-2.*ga1))
         swm=ww14m+ww24m 
         w14=ww14m/swm 
         w24=ww24m/swm 
!
         ww15=0.5*(1.+sign(1.,v5))*(ga1/beta51) &
             +0.5*(1.-sign(1.,v5))*(ga2/beta51)
         ww25=0.5*(1.+sign(1.,v5))*(ga2/beta52) &
             +0.5*(1.-sign(1.,v5))*(ga1/beta52)
         sw=ww15+ww25
         w15=ww15/sw
         w25=ww25/sw
   ww15m=w15*0.5*(1.+sign(1.,v5))*(ga1+ga1**2-3.*ga1*w15+w15**2)/(ga1**2+w15*(1.-2.*ga1)) &
        +w15*0.5*(1.-sign(1.,v5))*(ga2+ga2**2-3.*ga2*w15+w15**2)/(ga2**2+w15*(1.-2.*ga2))
   ww25m=w25*0.5*(1.+sign(1.,v5))*(ga2+ga2**2-3.*ga2*w25+w25**2)/(ga2**2+w25*(1.-2.*ga2)) &   
        +w25*0.5*(1.-sign(1.,v5))*(ga1+ga1**2-3.*ga1*w25+w25**2)/(ga1**2+w25*(1.-2.*ga1))
         swm=ww15m+ww25m
         w15=ww15m/swm 
         w25=ww25m/swm 
!        calcul des flux convectifs projetes
         hc1=w11*h11+w21*h12
         hc2=w12*h21+w22*h22
         hc3=w13*h31+w23*h32
         hc4=w14*h41+w24*h42
         hc5=w15*h51+w25*h52
!        produit avec matrice P pour retour dans l'espace physique
         h1=hc1*p11+hc2*p12+hc3*p13+hc4*p14+hc5*p15
         h2=hc1*p21+hc2*p22+hc3*p23+hc4*p24+hc5*p25
         h3=hc1*p31+hc2*p32+hc3*p33+hc4*p34+hc5*p35
         h4=hc1*p41+hc2*p42+hc3*p43+hc4*p44+hc5*p45
         h5=hc1*p51+hc2*p52+hc3*p53+hc4*p54+hc5*p55
!        calcul du flux numerique et bilan de flux
         df1=f1*sn(m1,kdir,1)+g1*sn(m1,kdir,2)+h1*sn(m1,kdir,3)
         df2=f2*sn(m1,kdir,1)+g2*sn(m1,kdir,2)+h2*sn(m1,kdir,3)
         df3=f3*sn(m1,kdir,1)+g3*sn(m1,kdir,2)+h3*sn(m1,kdir,3)
         df4=f4*sn(m1,kdir,1)+g4*sn(m1,kdir,2)+h4*sn(m1,kdir,3)
         df5=f5*sn(m1,kdir,1)+g5*sn(m1,kdir,2)+h5*sn(m1,kdir,3)
!        calcul des flux visqueux (multiplies par -2)
         fv2=(toxx(n)+toxx(n1))*sn(m1,kdir,1) &
            +(toxy(n)+toxy(n1))*sn(m1,kdir,2) &
            +(toxz(n)+toxz(n1))*sn(m1,kdir,3) 
         fv3=(toxy(n)+toxy(n1))*sn(m1,kdir,1) &
            +(toyy(n)+toyy(n1))*sn(m1,kdir,2) &
            +(toyz(n)+toyz(n1))*sn(m1,kdir,3)
         fv4=(toxz(n)+toxz(n1))*sn(m1,kdir,1) &
            +(toyz(n)+toyz(n1))*sn(m1,kdir,2) &
            +(tozz(n)+tozz(n1))*sn(m1,kdir,3)
         fv5=(toxx(n )*ul+toxy(n )*vl+toxz(n )*wl+qcx(n ) &
             +toxx(n1)*ur+toxy(n1)*vr+toxz(n1)*wr+qcx(n1))*sn(m1,kdir,1) &
            +(toxy(n )*ul+toyy(n )*vl+toyz(n )*wl+qcy(n ) &
             +toxy(n1)*ur+toyy(n1)*vr+toyz(n1)*wr+qcy(n1))*sn(m1,kdir,2) &
            +(toxz(n )*ul+toyz(n )*vl+tozz(n )*wl+qcz(n ) &
             +toxz(n1)*ur+toyz(n1)*vr+tozz(n1)*wr+qcz(n1))*sn(m1,kdir,3)

         u(n1,1)=u(n1,1)-df1
         u(n1,2)=u(n1,2)-df2+0.5*fv2
         u(n1,3)=u(n1,3)-df3+0.5*fv3
         u(n1,4)=u(n1,4)-df4+0.5*fv4
         u(n1,5)=u(n1,5)-df5+0.5*fv5
         u(n,1)=u(n,1)+df1
         u(n,2)=u(n,2)+df2-0.5*fv2
         u(n,3)=u(n,3)+df3-0.5*fv3
         u(n,4)=u(n,4)+df4-0.5*fv4
         u(n,5)=u(n,5)+df5-0.5*fv5
        enddo
       enddo
      enddo
!
!------direction j----------------------------------------------
!
      kdir=2
      ninc=ncj
!
      do k=k1,k2m1
       do j=j1,j2m2
        ind1 = indc(i1  ,j,k)
        ind2 = indc(i2m1,j,k)
        do n=ind1,ind2
         m=n-n0c
         m1=m+ninc
         n1=n+ninc
!        vecteur normal unitaire a la face consideree (face j+1/2)
         cnds=sqrt(sn(m1,kdir,1)*sn(m1,kdir,1)+ &
                   sn(m1,kdir,2)*sn(m1,kdir,2)+ &
                   sn(m1,kdir,3)*sn(m1,kdir,3))
         nx=sn(m1,kdir,1)/cnds
         ny=sn(m1,kdir,2)/cnds
         nz=sn(m1,kdir,3)/cnds
!        calcul des etats gauche et droit
         ul=v(n,2)/v(n,1)
         vl=v(n,3)/v(n,1)
         wl=v(n,4)/v(n,1)
         ur=v(n1,2)/v(n1,1)
         vr=v(n1,3)/v(n1,1)
         wr=v(n1,4)/v(n1,1)
         al=sqrt(gam*ps(n )/v(n,1))
         ar=sqrt(gam*ps(n1)/v(n1,1))
         hl=al*al/gam1+0.5*(ul**2+vl**2+wl**2)
         hr=ar*ar/gam1+0.5*(ur**2+vr**2+wr**2)
!        calcul des etats moyens de Roe
         gd=sqrt(v(n1,1)/v(n,1))
         gd1=1./(1.+gd)
         gd2=gd*gd1
         rhom=sqrt(v(n,1)*v(n1,1))
         rhomi=1./rhom
         um=gd1*ul+gd2*ur
         vm=gd1*vl+gd2*vr
         wm=gd1*wl+gd2*wr
         hm=gd1*hl+gd2*hr
         vitm2=0.5*(um**2+vm**2+wm**2)
         am=sqrt(abs(gam1*(hm-vitm2)))
         am2i=1./(am*am)
         vn=um*nx+vm*ny+wm*nz
         rhoiam=rhom/am
         rhoami=am2i/rhoiam
!        valeurs propres
         v1=vn
         v4=vn+am
         v5=vn-am
!        calcul des matrices de passage a gauche Q et a droite P
         q11=(1.-gam1*vitm2*am2i)*nx-(vm*nz-wm*ny)*rhomi
         q12=gam1*um*nx*am2i
         q13=gam1*vm*nx*am2i+nz*rhomi
         q14=gam1*wm*nx*am2i-ny*rhomi
         q15=-gam1*nx*am2i
         q21=(1.-gam1*vitm2*am2i)*ny-(wm*nx-um*nz)*rhomi
         q22=gam1*um*ny*am2i-nz*rhomi
         q23=gam1*vm*ny*am2i
         q24=gam1*wm*ny*am2i+nx*rhomi
         q25=-gam1*ny*am2i
         q31=(1.-gam1*vitm2*am2i)*nz-(um*ny-vm*nx)*rhomi
         q32=gam1*um*nz*am2i+ny*rhomi
         q33=gam1*vm*nz*am2i-nx*rhomi
         q34=gam1*wm*nz*am2i
         q35=-gam1*nz*am2i
         q41=gam1*vitm2*rhoami-vn*rhomi
         q42=nx*rhomi-gam1*um*rhoami
         q43=ny*rhomi-gam1*vm*rhoami
         q44=nz*rhomi-gam1*wm*rhoami
         q45=gam1*rhoami
         q51=gam1*vitm2*rhoami+vn*rhomi
         q52=-nx*rhomi-gam1*um*rhoami
         q53=-ny*rhomi-gam1*vm*rhoami
         q54=-nz*rhomi-gam1*wm*rhoami
         q55=gam1*rhoami
!
         p11=nx
         p12=ny
         p13=nz
         p14=0.5*rhoiam
         p15=0.5*rhoiam
         p21=um*nx
         p22=um*ny-rhom*nz
         p23=um*nz+rhom*ny
         p24=0.5*rhoiam*(um+nx*am)
         p25=0.5*rhoiam*(um-nx*am)
         p31=vm*nx+rhom*nz
         p32=vm*ny
         p33=vm*nz-rhom*nx
         p34=0.5*rhoiam*(vm+ny*am)
         p35=0.5*rhoiam*(vm-ny*am)
         p41=wm*nx-rhom*ny
         p42=wm*ny+rhom*nx
         p43=wm*nz
         p44=0.5*rhoiam*(wm+nz*am)
         p45=0.5*rhoiam*(wm-nz*am)
         p51=vitm2*nx+rhom*(vm*nz-wm*ny)
         p52=vitm2*ny+rhom*(wm*nx-um*nz)
         p53=vitm2*nz+rhom*(um*ny-vm*nx)
         p54=0.5*rhoiam*(hm+am*vn)
         p55=0.5*rhoiam*(hm-am*vn)
!        produit de Q avec les flux Euler aux points (i-1) a (i+2)
         q1f1m=q11*v(n-ninc  ,2)+q12*fxx(m-ninc)  +q13*fxy(m-ninc) &
                                +q14*fxz(m-ninc)  +q15*fex(m-ninc)
         q1f  =q11*v(n       ,2)+q12*fxx(m)       +q13*fxy(m) &
                                +q14*fxz(m)       +q15*fex(m)
         q1f1p=q11*v(n+ninc  ,2)+q12*fxx(m+ninc)  +q13*fxy(m+ninc) &
                                +q14*fxz(m+ninc)  +q15*fex(m+ninc)
         q1f2p=q11*v(n+2*ninc,2)+q12*fxx(m+2*ninc)+q13*fxy(m+2*ninc) &
                                +q14*fxz(m+2*ninc)+q15*fex(m+2*ninc)
!
         q2f1m=q21*v(n-ninc  ,2)+q22*fxx(m-ninc)  +q23*fxy(m-ninc) &
                                +q24*fxz(m-ninc)  +q25*fex(m-ninc)
         q2f  =q21*v(n       ,2)+q22*fxx(m)       +q23*fxy(m) &
                                +q24*fxz(m)       +q25*fex(m)
         q2f1p=q21*v(n+ninc  ,2)+q22*fxx(m+ninc)  +q23*fxy(m+ninc) &
                                +q24*fxz(m+ninc)  +q25*fex(m+ninc)
         q2f2p=q21*v(n+2*ninc,2)+q22*fxx(m+2*ninc)+q23*fxy(m+2*ninc) &
                                +q24*fxz(m+2*ninc)+q25*fex(m+2*ninc)
!
         q3f1m=q31*v(n-ninc  ,2)+q32*fxx(m-ninc)  +q33*fxy(m-ninc) &
                                +q34*fxz(m-ninc)  +q35*fex(m-ninc)
         q3f  =q31*v(n       ,2)+q32*fxx(m)       +q33*fxy(m) &
                                +q34*fxz(m)       +q35*fex(m)
         q3f1p=q31*v(n+ninc  ,2)+q32*fxx(m+ninc)  +q33*fxy(m+ninc) &
                                +q34*fxz(m+ninc)  +q35*fex(m+ninc)
         q3f2p=q31*v(n+2*ninc,2)+q32*fxx(m+2*ninc)+q33*fxy(m+2*ninc) &
                                +q34*fxz(m+2*ninc)+q35*fex(m+2*ninc)
!
         q4f1m=q41*v(n-ninc  ,2)+q42*fxx(m-ninc)  +q43*fxy(m-ninc) &
                                +q44*fxz(m-ninc)  +q45*fex(m-ninc)
         q4f  =q41*v(n       ,2)+q42*fxx(m)       +q43*fxy(m) &
                                +q44*fxz(m)       +q45*fex(m)
         q4f1p=q41*v(n+ninc  ,2)+q42*fxx(m+ninc)  +q43*fxy(m+ninc) &
                                +q44*fxz(m+ninc)  +q45*fex(m+ninc)
         q4f2p=q41*v(n+2*ninc,2)+q42*fxx(m+2*ninc)+q43*fxy(m+2*ninc) &
                                +q44*fxz(m+2*ninc)+q45*fex(m+2*ninc)
!
         q5f1m=q51*v(n-ninc  ,2)+q52*fxx(m-ninc)  +q53*fxy(m-ninc) &
                                +q54*fxz(m-ninc)  +q55*fex(m-ninc)
         q5f  =q51*v(n       ,2)+q52*fxx(m)       +q53*fxy(m) &
                                +q54*fxz(m)       +q55*fex(m)
         q5f1p=q51*v(n+ninc  ,2)+q52*fxx(m+ninc)  +q53*fxy(m+ninc) &
                                +q54*fxz(m+ninc)  +q55*fex(m+ninc)
         q5f2p=q51*v(n+2*ninc,2)+q52*fxx(m+2*ninc)+q53*fxy(m+2*ninc) &
                                +q54*fxz(m+2*ninc)+q55*fex(m+2*ninc)
!        calcul des flux d'ordre 2 sur les 2 stencils
         f11=0.5*(1.+sign(1.,v1))*(q1f1m*c10 +q1f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q1f  *c00 +q1f1p*c01)
         f12=0.5*(1.+sign(1.,v1))*(q1f  *c00 +q1f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q1f1p*c11 +q1f2p*c10)
!
         f21=0.5*(1.+sign(1.,v1))*(q2f1m*c10 +q2f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q2f  *c00 +q2f1p*c01)
         f22=0.5*(1.+sign(1.,v1))*(q2f  *c00 +q2f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q2f1p*c11 +q2f2p*c10)
!
         f31=0.5*(1.+sign(1.,v1))*(q3f1m*c10 +q3f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q3f  *c00 +q3f1p*c01)
         f32=0.5*(1.+sign(1.,v1))*(q3f  *c00 +q3f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q3f1p*c11 +q3f2p*c10)
!
         f41=0.5*(1.+sign(1.,v4))*(q4f1m*c10 +q4f  *c11) &
            +0.5*(1.-sign(1.,v4))*(q4f  *c00 +q4f1p*c01)
         f42=0.5*(1.+sign(1.,v4))*(q4f  *c00 +q4f1p*c01) &
            +0.5*(1.-sign(1.,v4))*(q4f1p*c11 +q4f2p*c10)
!
         f51=0.5*(1.+sign(1.,v5))*(q5f1m*c10 +q5f  *c11) &
            +0.5*(1.-sign(1.,v5))*(q5f  *c00 +q5f1p*c01)
         f52=0.5*(1.+sign(1.,v5))*(q5f  *c00 +q5f1p*c01) &
            +0.5*(1.-sign(1.,v5))*(q5f1p*c11 +q5f2p*c10)
!        calcul des senseurs beta (au carre)
         iexp=2
!         iexp=1
         beta11=(0.5*(1.+sign(1.,v1))*(q1f-q1f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f1p-q1f)**2+eps)**iexp
         beta12=(0.5*(1.+sign(1.,v1))*(q1f1p-q1f)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f2p-q1f1p)**2+eps)**iexp
!
         beta21=(0.5*(1.+sign(1.,v1))*(q2f-q2f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f1p-q2f)**2+eps)**iexp
         beta22=(0.5*(1.+sign(1.,v1))*(q2f1p-q2f)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f2p-q2f1p)**2+eps)**iexp
!
         beta31=(0.5*(1.+sign(1.,v1))*(q3f-q3f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f1p-q3f)**2+eps)**iexp
         beta32=(0.5*(1.+sign(1.,v1))*(q3f1p-q3f)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f2p-q3f1p)**2+eps)**iexp
!
         beta41=(0.5*(1.+sign(1.,v4))*(q4f-q4f1m)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f1p-q4f)**2+eps)**iexp
         beta42=(0.5*(1.+sign(1.,v4))*(q4f1p-q4f)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f2p-q4f1p)**2+eps)**iexp
!
         beta51=(0.5*(1.+sign(1.,v5))*(q5f-q5f1m)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f1p-q5f)**2+eps)**iexp
         beta52=(0.5*(1.+sign(1.,v5))*(q5f1p-q5f)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f2p-q5f1p)**2+eps)**iexp
!        calculs des poids wi
         ww11=0.5*(1.+sign(1.,v1))*(ga1/beta11) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta11)
         ww21=0.5*(1.+sign(1.,v1))*(ga2/beta12) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta12)
         sw=ww11+ww21
         w11=ww11/sw
         w21=ww21/sw
   ww11m=w11*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w11+w11**2)/(ga1**2+w11*(1.-2.*ga1)) &
        +w11*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w11+w11**2)/(ga2**2+w11*(1.-2.*ga2))
   ww21m=w21*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w21+w21**2)/(ga2**2+w21*(1.-2.*ga2)) &   
        +w21*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w21+w21**2)/(ga1**2+w21*(1.-2.*ga1))
         swm=ww11m+ww21m
         w11=ww11m/swm 
         w21=ww21m/swm 
!
         ww12=0.5*(1.+sign(1.,v1))*(ga1/beta21) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta21)
         ww22=0.5*(1.+sign(1.,v1))*(ga2/beta22) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta22)
         sw=ww12+ww22
         w12=ww12/sw
         w22=ww22/sw
   ww12m=w12*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w12+w12**2)/(ga1**2+w12*(1.-2.*ga1)) &
        +w12*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w12+w12**2)/(ga2**2+w12*(1.-2.*ga2))
   ww22m=w22*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w22+w22**2)/(ga2**2+w22*(1.-2.*ga2)) &   
        +w22*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w22+w22**2)/(ga1**2+w22*(1.-2.*ga1))
         swm=ww12m+ww22m 
         w12=ww12m/swm 
         w22=ww22m/swm 
!
         ww13=0.5*(1.+sign(1.,v1))*(ga1/beta31) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta31)
         ww23=0.5*(1.+sign(1.,v1))*(ga2/beta32) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta32)
         sw=ww13+ww23
         w13=ww13/sw
         w23=ww23/sw
   ww13m=w13*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w13+w13**2)/(ga1**2+w13*(1.-2.*ga1)) &
        +w13*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w13+w13**2)/(ga2**2+w13*(1.-2.*ga2))
   ww23m=w23*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w23+w23**2)/(ga2**2+w23*(1.-2.*ga2)) &   
        +w23*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w23+w23**2)/(ga1**2+w23*(1.-2.*ga1))
         swm=ww13m+ww23m
         w13=ww13m/swm 
         w23=ww23m/swm 
!
         ww14=0.5*(1.+sign(1.,v4))*(ga1/beta41) &
             +0.5*(1.-sign(1.,v4))*(ga2/beta41)
         ww24=0.5*(1.+sign(1.,v4))*(ga2/beta42) &
             +0.5*(1.-sign(1.,v4))*(ga1/beta42)
         sw=ww14+ww24
         w14=ww14/sw
         w24=ww24/sw
   ww14m=w14*0.5*(1.+sign(1.,v4))*(ga1+ga1**2-3.*ga1*w14+w14**2)/(ga1**2+w14*(1.-2.*ga1)) &
        +w14*0.5*(1.-sign(1.,v4))*(ga2+ga2**2-3.*ga2*w14+w14**2)/(ga2**2+w14*(1.-2.*ga2))
   ww24m=w24*0.5*(1.+sign(1.,v4))*(ga2+ga2**2-3.*ga2*w24+w24**2)/(ga2**2+w24*(1.-2.*ga2)) &   
        +w24*0.5*(1.-sign(1.,v4))*(ga1+ga1**2-3.*ga1*w24+w24**2)/(ga1**2+w24*(1.-2.*ga1))
         swm=ww14m+ww24m 
         w14=ww14m/swm 
         w24=ww24m/swm 
!
         ww15=0.5*(1.+sign(1.,v5))*(ga1/beta51) &
             +0.5*(1.-sign(1.,v5))*(ga2/beta51)
         ww25=0.5*(1.+sign(1.,v5))*(ga2/beta52) &
             +0.5*(1.-sign(1.,v5))*(ga1/beta52)
         sw=ww15+ww25
         w15=ww15/sw
         w25=ww25/sw
   ww15m=w15*0.5*(1.+sign(1.,v5))*(ga1+ga1**2-3.*ga1*w15+w15**2)/(ga1**2+w15*(1.-2.*ga1)) &
        +w15*0.5*(1.-sign(1.,v5))*(ga2+ga2**2-3.*ga2*w15+w15**2)/(ga2**2+w15*(1.-2.*ga2))
   ww25m=w25*0.5*(1.+sign(1.,v5))*(ga2+ga2**2-3.*ga2*w25+w25**2)/(ga2**2+w25*(1.-2.*ga2)) &   
        +w25*0.5*(1.-sign(1.,v5))*(ga1+ga1**2-3.*ga1*w25+w25**2)/(ga1**2+w25*(1.-2.*ga1))
         swm=ww15m+ww25m
         w15=ww15m/swm 
         w25=ww25m/swm 
!        calcul des flux convectifs projetes
         fc1=w11*f11+w21*f12
         fc2=w12*f21+w22*f22
         fc3=w13*f31+w23*f32
         fc4=w14*f41+w24*f42
         fc5=w15*f51+w25*f52
!        produit avec matrice P pour retour dans l'espace physique
         f1=fc1*p11+fc2*p12+fc3*p13+fc4*p14+fc5*p15
         f2=fc1*p21+fc2*p22+fc3*p23+fc4*p24+fc5*p25
         f3=fc1*p31+fc2*p32+fc3*p33+fc4*p34+fc5*p35
         f4=fc1*p41+fc2*p42+fc3*p43+fc4*p44+fc5*p45
         f5=fc1*p51+fc2*p52+fc3*p53+fc4*p54+fc5*p55
!-----------------------------------------------------------------
!        produit de Q avec les flux Euler aux points (i-1) a (i+2)
         q1f1m=q11*v(n-ninc  ,3)+q12*fxy(m-ninc)  +q13*fyy(m-ninc) &
                                +q14*fyz(m-ninc)  +q15*fey(m-ninc)
         q1f  =q11*v(n       ,3)+q12*fxy(m)       +q13*fyy(m) &
                                +q14*fyz(m)       +q15*fey(m)
         q1f1p=q11*v(n+ninc  ,3)+q12*fxy(m+ninc)  +q13*fyy(m+ninc) &
                                +q14*fyz(m+ninc)  +q15*fey(m+ninc)
         q1f2p=q11*v(n+2*ninc,3)+q12*fxy(m+2*ninc)+q13*fyy(m+2*ninc) &
                                +q14*fyz(m+2*ninc)+q15*fey(m+2*ninc)
!
         q2f1m=q21*v(n-ninc  ,3)+q22*fxy(m-ninc)  +q23*fyy(m-ninc) &
                                +q24*fyz(m-ninc)  +q25*fey(m-ninc)
         q2f  =q21*v(n       ,3)+q22*fxy(m)       +q23*fyy(m) &
                                +q24*fyz(m)       +q25*fey(m)
         q2f1p=q21*v(n+ninc  ,3)+q22*fxy(m+ninc)  +q23*fyy(m+ninc) &
                                +q24*fyz(m+ninc)  +q25*fey(m+ninc)
         q2f2p=q21*v(n+2*ninc,3)+q22*fxy(m+2*ninc)+q23*fyy(m+2*ninc) &
                                +q24*fyz(m+2*ninc)+q25*fey(m+2*ninc)
!
         q3f1m=q31*v(n-ninc  ,3)+q32*fxy(m-ninc)  +q33*fyy(m-ninc) &
                                +q34*fyz(m-ninc)  +q35*fey(m-ninc)
         q3f  =q31*v(n       ,3)+q32*fxy(m)       +q33*fyy(m) &
                                +q34*fyz(m)       +q35*fey(m)
         q3f1p=q31*v(n+ninc  ,3)+q32*fxy(m+ninc)  +q33*fyy(m+ninc) &
                                +q34*fyz(m+ninc)  +q35*fey(m+ninc)
         q3f2p=q31*v(n+2*ninc,3)+q32*fxy(m+2*ninc)+q33*fyy(m+2*ninc) &
                                +q34*fyz(m+2*ninc)+q35*fey(m+2*ninc)
!
         q4f1m=q41*v(n-ninc  ,3)+q42*fxy(m-ninc)  +q43*fyy(m-ninc) &
                                +q44*fyz(m-ninc)  +q45*fey(m-ninc)
         q4f  =q41*v(n       ,3)+q42*fxy(m)       +q43*fyy(m) &
                                +q44*fyz(m)       +q45*fey(m)
         q4f1p=q41*v(n+ninc  ,3)+q42*fxy(m+ninc)  +q43*fyy(m+ninc) &
                                +q44*fyz(m+ninc)  +q45*fey(m+ninc)
         q4f2p=q41*v(n+2*ninc,3)+q42*fxy(m+2*ninc)+q43*fyy(m+2*ninc) &
                                +q44*fyz(m+2*ninc)+q45*fey(m+2*ninc)
!
         q5f1m=q51*v(n-ninc  ,3)+q52*fxy(m-ninc)  +q53*fyy(m-ninc) &
                                +q54*fyz(m-ninc)  +q55*fey(m-ninc)
         q5f  =q51*v(n       ,3)+q52*fxy(m)       +q53*fyy(m) &
                                +q54*fyz(m)       +q55*fey(m)
         q5f1p=q51*v(n+ninc  ,3)+q52*fxy(m+ninc)  +q53*fyy(m+ninc) &
                                +q54*fyz(m+ninc)  +q55*fey(m+ninc)
         q5f2p=q51*v(n+2*ninc,3)+q52*fxy(m+2*ninc)+q53*fyy(m+2*ninc) &
                                +q54*fyz(m+2*ninc)+q55*fey(m+2*ninc)
!        calcul des flux d'ordre 2 sur les 2 stencils
         g11=0.5*(1.+sign(1.,v1))*(q1f1m*c10 +q1f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q1f  *c00 +q1f1p*c01)
         g12=0.5*(1.+sign(1.,v1))*(q1f  *c00 +q1f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q1f1p*c11 +q1f2p*c10)
!
         g21=0.5*(1.+sign(1.,v1))*(q2f1m*c10 +q2f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q2f  *c00 +q2f1p*c01)
         g22=0.5*(1.+sign(1.,v1))*(q2f  *c00 +q2f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q2f1p*c11 +q2f2p*c10)
!
         g31=0.5*(1.+sign(1.,v1))*(q3f1m*c10 +q3f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q3f  *c00 +q3f1p*c01)
         g32=0.5*(1.+sign(1.,v1))*(q3f  *c00 +q3f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q3f1p*c11 +q3f2p*c10)
!
         g41=0.5*(1.+sign(1.,v4))*(q4f1m*c10 +q4f  *c11) &
            +0.5*(1.-sign(1.,v4))*(q4f  *c00 +q4f1p*c01)
         g42=0.5*(1.+sign(1.,v4))*(q4f  *c00 +q4f1p*c01) &
            +0.5*(1.-sign(1.,v4))*(q4f1p*c11 +q4f2p*c10)
!
         g51=0.5*(1.+sign(1.,v5))*(q5f1m*c10 +q5f  *c11) &
            +0.5*(1.-sign(1.,v5))*(q5f  *c00 +q5f1p*c01)
         g52=0.5*(1.+sign(1.,v5))*(q5f  *c00 +q5f1p*c01) &
            +0.5*(1.-sign(1.,v5))*(q5f1p*c11 +q5f2p*c10)
!        calcul des senseurs beta (au carre)
         iexp=2
!         iexp=1
         beta11=(0.5*(1.+sign(1.,v1))*(q1f-q1f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f1p-q1f)**2+eps)**iexp
         beta12=(0.5*(1.+sign(1.,v1))*(q1f1p-q1f)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f2p-q1f1p)**2+eps)**iexp
!
         beta21=(0.5*(1.+sign(1.,v1))*(q2f-q2f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f1p-q2f)**2+eps)**iexp
         beta22=(0.5*(1.+sign(1.,v1))*(q2f1p-q2f)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f2p-q2f1p)**2+eps)**iexp
!
         beta31=(0.5*(1.+sign(1.,v1))*(q3f-q3f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f1p-q3f)**2+eps)**iexp
         beta32=(0.5*(1.+sign(1.,v1))*(q3f1p-q3f)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f2p-q3f1p)**2+eps)**iexp
!
         beta41=(0.5*(1.+sign(1.,v4))*(q4f-q4f1m)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f1p-q4f)**2+eps)**iexp
         beta42=(0.5*(1.+sign(1.,v4))*(q4f1p-q4f)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f2p-q4f1p)**2+eps)**iexp
!
         beta51=(0.5*(1.+sign(1.,v5))*(q5f-q5f1m)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f1p-q5f)**2+eps)**iexp
         beta52=(0.5*(1.+sign(1.,v5))*(q5f1p-q5f)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f2p-q5f1p)**2+eps)**iexp
!        calculs des poids wi
         ww11=0.5*(1.+sign(1.,v1))*(ga1/beta11) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta11)
         ww21=0.5*(1.+sign(1.,v1))*(ga2/beta12) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta12)
         sw=ww11+ww21
         w11=ww11/sw
         w21=ww21/sw
   ww11m=w11*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w11+w11**2)/(ga1**2+w11*(1.-2.*ga1)) &
        +w11*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w11+w11**2)/(ga2**2+w11*(1.-2.*ga2))
   ww21m=w21*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w21+w21**2)/(ga2**2+w21*(1.-2.*ga2)) &   
        +w21*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w21+w21**2)/(ga1**2+w21*(1.-2.*ga1))
         swm=ww11m+ww21m
         w11=ww11m/swm 
         w21=ww21m/swm 
!
         ww12=0.5*(1.+sign(1.,v1))*(ga1/beta21) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta21)
         ww22=0.5*(1.+sign(1.,v1))*(ga2/beta22) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta22)
         sw=ww12+ww22
         w12=ww12/sw
         w22=ww22/sw
   ww12m=w12*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w12+w12**2)/(ga1**2+w12*(1.-2.*ga1)) &
        +w12*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w12+w12**2)/(ga2**2+w12*(1.-2.*ga2))
   ww22m=w22*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w22+w22**2)/(ga2**2+w22*(1.-2.*ga2)) &   
        +w22*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w22+w22**2)/(ga1**2+w22*(1.-2.*ga1))
         swm=ww12m+ww22m 
         w12=ww12m/swm 
         w22=ww22m/swm 
!
         ww13=0.5*(1.+sign(1.,v1))*(ga1/beta31) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta31)
         ww23=0.5*(1.+sign(1.,v1))*(ga2/beta32) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta32)
         sw=ww13+ww23
         w13=ww13/sw
         w23=ww23/sw
   ww13m=w13*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w13+w13**2)/(ga1**2+w13*(1.-2.*ga1)) &
        +w13*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w13+w13**2)/(ga2**2+w13*(1.-2.*ga2))
   ww23m=w23*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w23+w23**2)/(ga2**2+w23*(1.-2.*ga2)) &   
        +w23*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w23+w23**2)/(ga1**2+w23*(1.-2.*ga1))
         swm=ww13m+ww23m
         w13=ww13m/swm 
         w23=ww23m/swm 
!
         ww14=0.5*(1.+sign(1.,v4))*(ga1/beta41) &
             +0.5*(1.-sign(1.,v4))*(ga2/beta41)
         ww24=0.5*(1.+sign(1.,v4))*(ga2/beta42) &
             +0.5*(1.-sign(1.,v4))*(ga1/beta42)
         sw=ww14+ww24
         w14=ww14/sw
         w24=ww24/sw
   ww14m=w14*0.5*(1.+sign(1.,v4))*(ga1+ga1**2-3.*ga1*w14+w14**2)/(ga1**2+w14*(1.-2.*ga1)) &
        +w14*0.5*(1.-sign(1.,v4))*(ga2+ga2**2-3.*ga2*w14+w14**2)/(ga2**2+w14*(1.-2.*ga2))
   ww24m=w24*0.5*(1.+sign(1.,v4))*(ga2+ga2**2-3.*ga2*w24+w24**2)/(ga2**2+w24*(1.-2.*ga2)) &   
        +w24*0.5*(1.-sign(1.,v4))*(ga1+ga1**2-3.*ga1*w24+w24**2)/(ga1**2+w24*(1.-2.*ga1))
         swm=ww14m+ww24m 
         w14=ww14m/swm 
         w24=ww24m/swm 
!
         ww15=0.5*(1.+sign(1.,v5))*(ga1/beta51) &
             +0.5*(1.-sign(1.,v5))*(ga2/beta51)
         ww25=0.5*(1.+sign(1.,v5))*(ga2/beta52) &
             +0.5*(1.-sign(1.,v5))*(ga1/beta52)
         sw=ww15+ww25
         w15=ww15/sw
         w25=ww25/sw
   ww15m=w15*0.5*(1.+sign(1.,v5))*(ga1+ga1**2-3.*ga1*w15+w15**2)/(ga1**2+w15*(1.-2.*ga1)) &
        +w15*0.5*(1.-sign(1.,v5))*(ga2+ga2**2-3.*ga2*w15+w15**2)/(ga2**2+w15*(1.-2.*ga2))
   ww25m=w25*0.5*(1.+sign(1.,v5))*(ga2+ga2**2-3.*ga2*w25+w25**2)/(ga2**2+w25*(1.-2.*ga2)) &   
        +w25*0.5*(1.-sign(1.,v5))*(ga1+ga1**2-3.*ga1*w25+w25**2)/(ga1**2+w25*(1.-2.*ga1))
         swm=ww15m+ww25m
         w15=ww15m/swm 
         w25=ww25m/swm 
!        calcul des flux convectifs projetes
         gc1=w11*g11+w21*g12
         gc2=w12*g21+w22*g22
         gc3=w13*g31+w23*g32
         gc4=w14*g41+w24*g42
         gc5=w15*g51+w25*g52
!        produit avec matrice P pour retour dans l'espace physique
         g1=gc1*p11+gc2*p12+gc3*p13+gc4*p14+gc5*p15
         g2=gc1*p21+gc2*p22+gc3*p23+gc4*p24+gc5*p25
         g3=gc1*p31+gc2*p32+gc3*p33+gc4*p34+gc5*p35
         g4=gc1*p41+gc2*p42+gc3*p43+gc4*p44+gc5*p45
         g5=gc1*p51+gc2*p52+gc3*p53+gc4*p54+gc5*p55
!-------------------------------------------------------------------
!        produit de Q avec les flux Euler aux points (i-1) a (i+2)
         q1f1m=q11*v(n-ninc  ,4)+q12*fxz(m-ninc)  +q13*fyz(m-ninc) &
                                +q14*fzz(m-ninc)  +q15*fez(m-ninc) 
         q1f  =q11*v(n       ,4)+q12*fxz(m)       +q13*fyz(m) &
                                +q14*fzz(m)       +q15*fez(m)
         q1f1p=q11*v(n+ninc  ,4)+q12*fxz(m+ninc)  +q13*fyz(m+ninc) &
                                +q14*fzz(m+ninc)  +q15*fez(m+ninc)     
         q1f2p=q11*v(n+2*ninc,4)+q12*fxz(m+2*ninc)+q13*fyz(m+2*ninc) &
                                +q14*fzz(m+2*ninc)+q15*fez(m+2*ninc)
!
         q2f1m=q21*v(n-ninc  ,4)+q22*fxz(m-ninc)  +q23*fyz(m-ninc) &
                                +q24*fzz(m-ninc)  +q25*fez(m-ninc)
         q2f  =q21*v(n       ,4)+q22*fxz(m)       +q23*fyz(m) &
                                +q24*fzz(m)       +q25*fez(m)
         q2f1p=q21*v(n+ninc  ,4)+q22*fxz(m+ninc)  +q23*fyz(m+ninc) &
                                +q24*fzz(m+ninc)  +q25*fez(m+ninc)
         q2f2p=q21*v(n+2*ninc,4)+q22*fxz(m+2*ninc)+q23*fyz(m+2*ninc) &
                                +q24*fzz(m+2*ninc)+q25*fez(m+2*ninc)
!
         q3f1m=q31*v(n-ninc  ,4)+q32*fxz(m-ninc)  +q33*fyz(m-ninc) &
                                +q34*fzz(m-ninc)  +q35*fez(m-ninc)
         q3f  =q31*v(n       ,4)+q32*fxz(m)       +q33*fyz(m) &
                                +q34*fzz(m)       +q35*fez(m)
         q3f1p=q31*v(n+ninc  ,4)+q32*fxz(m+ninc)  +q33*fyz(m+ninc) &
                                +q34*fzz(m+ninc)  +q35*fez(m+ninc)
         q3f2p=q31*v(n+2*ninc,4)+q32*fxz(m+2*ninc)+q33*fyz(m+2*ninc) &
                                +q34*fzz(m+2*ninc)+q35*fez(m+2*ninc)
!
         q4f1m=q41*v(n-ninc  ,4)+q42*fxz(m-ninc)  +q43*fyz(m-ninc) &
                                +q44*fzz(m-ninc)  +q45*fez(m-ninc)
         q4f  =q41*v(n       ,4)+q42*fxz(m)       +q43*fyz(m) &
                                +q44*fzz(m)       +q45*fez(m)
         q4f1p=q41*v(n+ninc  ,4)+q42*fxz(m+ninc)  +q43*fyz(m+ninc) &
                                +q44*fzz(m+ninc)  +q45*fez(m+ninc)
         q4f2p=q41*v(n+2*ninc,4)+q42*fxz(m+2*ninc)+q43*fyz(m+2*ninc) &
                                +q44*fzz(m+2*ninc)+q45*fez(m+2*ninc)
!
         q5f1m=q51*v(n-ninc  ,4)+q52*fxz(m-ninc)  +q53*fyz(m-ninc) &
                                +q54*fzz(m-ninc)  +q55*fez(m-ninc)
         q5f  =q51*v(n       ,4)+q52*fxz(m)       +q53*fyz(m) &
                                +q54*fzz(m)       +q55*fez(m)
         q5f1p=q51*v(n+ninc  ,4)+q52*fxz(m+ninc)  +q53*fyz(m+ninc) &
                                +q54*fzz(m+ninc)  +q55*fez(m+ninc)
         q5f2p=q51*v(n+2*ninc,4)+q52*fxz(m+2*ninc)+q53*fyz(m+2*ninc) &
                                +q54*fzz(m+2*ninc)+q55*fez(m+2*ninc)
!        calcul des flux d'ordre 2 sur les 2 stencils       
         h11=0.5*(1.+sign(1.,v1))*(q1f1m*c10 +q1f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q1f  *c00 +q1f1p*c01)
         h12=0.5*(1.+sign(1.,v1))*(q1f  *c00 +q1f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q1f1p*c11 +q1f2p*c10)
!     
         h21=0.5*(1.+sign(1.,v1))*(q2f1m*c10 +q2f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q2f  *c00 +q2f1p*c01)
         h22=0.5*(1.+sign(1.,v1))*(q2f  *c00 +q2f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q2f1p*c11 +q2f2p*c10)
!
         h31=0.5*(1.+sign(1.,v1))*(q3f1m*c10 +q3f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q3f  *c00 +q3f1p*c01)
         h32=0.5*(1.+sign(1.,v1))*(q3f  *c00 +q3f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q3f1p*c11 +q3f2p*c10)
!
         h41=0.5*(1.+sign(1.,v4))*(q4f1m*c10 +q4f  *c11) &
            +0.5*(1.-sign(1.,v4))*(q4f  *c00 +q4f1p*c01)
         h42=0.5*(1.+sign(1.,v4))*(q4f  *c00 +q4f1p*c01) &
            +0.5*(1.-sign(1.,v4))*(q4f1p*c11 +q4f2p*c10)
!
         h51=0.5*(1.+sign(1.,v5))*(q5f1m*c10 +q5f  *c11) &
            +0.5*(1.-sign(1.,v5))*(q5f  *c00 +q5f1p*c01)
         h52=0.5*(1.+sign(1.,v5))*(q5f  *c00 +q5f1p*c01) &
            +0.5*(1.-sign(1.,v5))*(q5f1p*c11 +q5f2p*c10)
!        calcul des senseurs beta (au carre)
         iexp=2
!         iexp=1 
         beta11=(0.5*(1.+sign(1.,v1))*(q1f-q1f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f1p-q1f)**2+eps)**iexp
         beta12=(0.5*(1.+sign(1.,v1))*(q1f1p-q1f)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f2p-q1f1p)**2+eps)**iexp
!
         beta21=(0.5*(1.+sign(1.,v1))*(q2f-q2f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f1p-q2f)**2+eps)**iexp
         beta22=(0.5*(1.+sign(1.,v1))*(q2f1p-q2f)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f2p-q2f1p)**2+eps)**iexp
!
         beta31=(0.5*(1.+sign(1.,v1))*(q3f-q3f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f1p-q3f)**2+eps)**iexp
         beta32=(0.5*(1.+sign(1.,v1))*(q3f1p-q3f)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f2p-q3f1p)**2+eps)**iexp
!
         beta41=(0.5*(1.+sign(1.,v4))*(q4f-q4f1m)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f1p-q4f)**2+eps)**iexp
         beta42=(0.5*(1.+sign(1.,v4))*(q4f1p-q4f)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f2p-q4f1p)**2+eps)**iexp
!
         beta51=(0.5*(1.+sign(1.,v5))*(q5f-q5f1m)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f1p-q5f)**2+eps)**iexp
         beta52=(0.5*(1.+sign(1.,v5))*(q5f1p-q5f)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f2p-q5f1p)**2+eps)**iexp
!        calculs des poids wi    
         ww11=0.5*(1.+sign(1.,v1))*(ga1/beta11) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta11)
         ww21=0.5*(1.+sign(1.,v1))*(ga2/beta12) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta12)
         sw=ww11+ww21
         w11=ww11/sw
         w21=ww21/sw
   ww11m=w11*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w11+w11**2)/(ga1**2+w11*(1.-2.*ga1)) &
        +w11*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w11+w11**2)/(ga2**2+w11*(1.-2.*ga2))
   ww21m=w21*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w21+w21**2)/(ga2**2+w21*(1.-2.*ga2)) &   
        +w21*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w21+w21**2)/(ga1**2+w21*(1.-2.*ga1))
         swm=ww11m+ww21m
         w11=ww11m/swm 
         w21=ww21m/swm 
!
         ww12=0.5*(1.+sign(1.,v1))*(ga1/beta21) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta21)
         ww22=0.5*(1.+sign(1.,v1))*(ga2/beta22) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta22)
         sw=ww12+ww22
         w12=ww12/sw
         w22=ww22/sw
   ww12m=w12*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w12+w12**2)/(ga1**2+w12*(1.-2.*ga1)) &
        +w12*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w12+w12**2)/(ga2**2+w12*(1.-2.*ga2))
   ww22m=w22*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w22+w22**2)/(ga2**2+w22*(1.-2.*ga2)) &   
        +w22*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w22+w22**2)/(ga1**2+w22*(1.-2.*ga1))
         swm=ww12m+ww22m 
         w12=ww12m/swm 
         w22=ww22m/swm 
!
         ww13=0.5*(1.+sign(1.,v1))*(ga1/beta31) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta31)
         ww23=0.5*(1.+sign(1.,v1))*(ga2/beta32) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta32)
         sw=ww13+ww23
         w13=ww13/sw
         w23=ww23/sw
   ww13m=w13*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w13+w13**2)/(ga1**2+w13*(1.-2.*ga1)) &
        +w13*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w13+w13**2)/(ga2**2+w13*(1.-2.*ga2))
   ww23m=w23*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w23+w23**2)/(ga2**2+w23*(1.-2.*ga2)) &   
        +w23*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w23+w23**2)/(ga1**2+w23*(1.-2.*ga1))
         swm=ww13m+ww23m
         w13=ww13m/swm 
         w23=ww23m/swm 
!
         ww14=0.5*(1.+sign(1.,v4))*(ga1/beta41) &
             +0.5*(1.-sign(1.,v4))*(ga2/beta41)
         ww24=0.5*(1.+sign(1.,v4))*(ga2/beta42) &
             +0.5*(1.-sign(1.,v4))*(ga1/beta42)
         sw=ww14+ww24
         w14=ww14/sw
         w24=ww24/sw
   ww14m=w14*0.5*(1.+sign(1.,v4))*(ga1+ga1**2-3.*ga1*w14+w14**2)/(ga1**2+w14*(1.-2.*ga1)) &
        +w14*0.5*(1.-sign(1.,v4))*(ga2+ga2**2-3.*ga2*w14+w14**2)/(ga2**2+w14*(1.-2.*ga2))
   ww24m=w24*0.5*(1.+sign(1.,v4))*(ga2+ga2**2-3.*ga2*w24+w24**2)/(ga2**2+w24*(1.-2.*ga2)) &   
        +w24*0.5*(1.-sign(1.,v4))*(ga1+ga1**2-3.*ga1*w24+w24**2)/(ga1**2+w24*(1.-2.*ga1))
         swm=ww14m+ww24m 
         w14=ww14m/swm 
         w24=ww24m/swm 
!
         ww15=0.5*(1.+sign(1.,v5))*(ga1/beta51) &
             +0.5*(1.-sign(1.,v5))*(ga2/beta51)
         ww25=0.5*(1.+sign(1.,v5))*(ga2/beta52) &
             +0.5*(1.-sign(1.,v5))*(ga1/beta52)
         sw=ww15+ww25
         w15=ww15/sw
         w25=ww25/sw
   ww15m=w15*0.5*(1.+sign(1.,v5))*(ga1+ga1**2-3.*ga1*w15+w15**2)/(ga1**2+w15*(1.-2.*ga1)) &
        +w15*0.5*(1.-sign(1.,v5))*(ga2+ga2**2-3.*ga2*w15+w15**2)/(ga2**2+w15*(1.-2.*ga2))
   ww25m=w25*0.5*(1.+sign(1.,v5))*(ga2+ga2**2-3.*ga2*w25+w25**2)/(ga2**2+w25*(1.-2.*ga2)) &   
        +w25*0.5*(1.-sign(1.,v5))*(ga1+ga1**2-3.*ga1*w25+w25**2)/(ga1**2+w25*(1.-2.*ga1))
         swm=ww15m+ww25m
         w15=ww15m/swm 
         w25=ww25m/swm 
!        calcul des flux convectifs projetes
         hc1=w11*h11+w21*h12
         hc2=w12*h21+w22*h22
         hc3=w13*h31+w23*h32
         hc4=w14*h41+w24*h42
         hc5=w15*h51+w25*h52
!        produit avec matrice P pour retour dans l'espace physique
         h1=hc1*p11+hc2*p12+hc3*p13+hc4*p14+hc5*p15
         h2=hc1*p21+hc2*p22+hc3*p23+hc4*p24+hc5*p25
         h3=hc1*p31+hc2*p32+hc3*p33+hc4*p34+hc5*p35
         h4=hc1*p41+hc2*p42+hc3*p43+hc4*p44+hc5*p45
         h5=hc1*p51+hc2*p52+hc3*p53+hc4*p54+hc5*p55
!        calcul du flux numerique et bilan de flux
         dg1=f1*sn(m1,kdir,1)+g1*sn(m1,kdir,2)+h1*sn(m1,kdir,3)
         dg2=f2*sn(m1,kdir,1)+g2*sn(m1,kdir,2)+h2*sn(m1,kdir,3)
         dg3=f3*sn(m1,kdir,1)+g3*sn(m1,kdir,2)+h3*sn(m1,kdir,3)
         dg4=f4*sn(m1,kdir,1)+g4*sn(m1,kdir,2)+h4*sn(m1,kdir,3)
         dg5=f5*sn(m1,kdir,1)+g5*sn(m1,kdir,2)+h5*sn(m1,kdir,3)
!        calcul des flux visqueux (multiplies par -2)
         gv2=(toxx(n)+toxx(n1))*sn(m1,kdir,1) &
            +(toxy(n)+toxy(n1))*sn(m1,kdir,2) &
            +(toxz(n)+toxz(n1))*sn(m1,kdir,3) 
         gv3=(toxy(n)+toxy(n1))*sn(m1,kdir,1) &
            +(toyy(n)+toyy(n1))*sn(m1,kdir,2) &
            +(toyz(n)+toyz(n1))*sn(m1,kdir,3)
         gv4=(toxz(n)+toxz(n1))*sn(m1,kdir,1) &
            +(toyz(n)+toyz(n1))*sn(m1,kdir,2) &
            +(tozz(n)+tozz(n1))*sn(m1,kdir,3)
         gv5=(toxx(n )*ul+toxy(n )*vl+toxz(n )*wl+qcx(n ) &
             +toxx(n1)*ur+toxy(n1)*vr+toxz(n1)*wr+qcx(n1))*sn(m1,kdir,1) &
            +(toxy(n )*ul+toyy(n )*vl+toyz(n )*wl+qcy(n ) &
             +toxy(n1)*ur+toyy(n1)*vr+toyz(n1)*wr+qcy(n1))*sn(m1,kdir,2) &
            +(toxz(n )*ul+toyz(n )*vl+tozz(n )*wl+qcz(n ) &
             +toxz(n1)*ur+toyz(n1)*vr+tozz(n1)*wr+qcz(n1))*sn(m1,kdir,3)
         u(n1,1)=u(n1,1)-dg1
         u(n1,2)=u(n1,2)-dg2+0.5*gv2
         u(n1,3)=u(n1,3)-dg3+0.5*gv3
         u(n1,4)=u(n1,4)-dg4+0.5*gv4
         u(n1,5)=u(n1,5)-dg5+0.5*gv5
         u(n,1)=u(n,1)+dg1
         u(n,2)=u(n,2)+dg2-0.5*gv2
         u(n,3)=u(n,3)+dg3-0.5*gv3
         u(n,4)=u(n,4)+dg4-0.5*gv4
         u(n,5)=u(n,5)+dg5-0.5*gv5
        enddo
       enddo
      enddo
!
!------direction k----------------------------------------------
!
      kdir=3
      ninc=nck
!
      do k=k1,k2m2
       do j=j1,j2m1
        ind1 = indc(i1  ,j,k)
        ind2 = indc(i2m1,j,k)
        do n=ind1,ind2
         m=n-n0c
         m1=m+ninc 
         n1=n+ninc 
!        vecteur normal unitaire a la face consideree (face k+1/2)
         cnds=sqrt(sn(m1,kdir,1)*sn(m1,kdir,1)+ &
                   sn(m1,kdir,2)*sn(m1,kdir,2)+ &
                   sn(m1,kdir,3)*sn(m1,kdir,3))
         nx=sn(m1,kdir,1)/cnds
         ny=sn(m1,kdir,2)/cnds
         nz=sn(m1,kdir,3)/cnds
!        calcul des etats gauche et droit
         ul=v(n,2)/v(n,1)
         vl=v(n,3)/v(n,1)
         wl=v(n,4)/v(n,1)
         ur=v(n1,2)/v(n1,1)
         vr=v(n1,3)/v(n1,1)
         wr=v(n1,4)/v(n1,1)
         al=sqrt(gam*ps(n )/v(n,1))
         ar=sqrt(gam*ps(n1)/v(n1,1))
         hl=al*al/gam1+0.5*(ul**2+vl**2+wl**2)
         hr=ar*ar/gam1+0.5*(ur**2+vr**2+wr**2)
!        calcul de etat moyen de Roe
         gd=sqrt(v(n1,1)/v(n,1))
         gd1=1./(1.+gd)
         gd2=gd*gd1
         rhom=sqrt(v(n,1)*v(n1,1))
         rhomi=1./rhom
         um=gd1*ul+gd2*ur
         vm=gd1*vl+gd2*vr
         wm=gd1*wl+gd2*wr
         hm=gd1*hl+gd2*hr
         vitm2=0.5*(um**2+vm**2+wm**2)
         am=sqrt(abs(gam1*(hm-vitm2)))
         am2i=1./(am*am)
         vn=um*nx+vm*ny+wm*nz
         rhoiam=rhom/am
         rhoami=am2i/rhoiam
!        valeurs propres de la matrice jacobienne des flux
         v1=vn
         v4=vn+am
         v5=vn-am
!        calcul des matrices de passage a gauche Q et a droite P
         q11=(1.-gam1*vitm2*am2i)*nx-(vm*nz-wm*ny)*rhomi
         q12=gam1*um*nx*am2i
         q13=gam1*vm*nx*am2i+nz*rhomi
         q14=gam1*wm*nx*am2i-ny*rhomi
         q15=-gam1*nx*am2i
         q21=(1.-gam1*vitm2*am2i)*ny-(wm*nx-um*nz)*rhomi
         q22=gam1*um*ny*am2i-nz*rhomi
         q23=gam1*vm*ny*am2i
         q24=gam1*wm*ny*am2i+nx*rhomi
         q25=-gam1*ny*am2i
         q31=(1.-gam1*vitm2*am2i)*nz-(um*ny-vm*nx)*rhomi
         q32=gam1*um*nz*am2i+ny*rhomi
         q33=gam1*vm*nz*am2i-nx*rhomi
         q34=gam1*wm*nz*am2i
         q35=-gam1*nz*am2i
         q41=gam1*vitm2*rhoami-vn*rhomi
         q42=nx*rhomi-gam1*um*rhoami
         q43=ny*rhomi-gam1*vm*rhoami
         q44=nz*rhomi-gam1*wm*rhoami
         q45=gam1*rhoami
         q51=gam1*vitm2*rhoami+vn*rhomi
         q52=-nx*rhomi-gam1*um*rhoami
         q53=-ny*rhomi-gam1*vm*rhoami
         q54=-nz*rhomi-gam1*wm*rhoami
         q55=gam1*rhoami
!
         p11=nx
         p12=ny
         p13=nz
         p14=0.5*rhoiam
         p15=0.5*rhoiam
         p21=um*nx
         p22=um*ny-rhom*nz
         p23=um*nz+rhom*ny
         p24=0.5*rhoiam*(um+nx*am)
         p25=0.5*rhoiam*(um-nx*am)
         p31=vm*nx+rhom*nz
         p32=vm*ny
         p33=vm*nz-rhom*nx
         p34=0.5*rhoiam*(vm+ny*am)
         p35=0.5*rhoiam*(vm-ny*am)
         p41=wm*nx-rhom*ny
         p42=wm*ny+rhom*nx
         p43=wm*nz
         p44=0.5*rhoiam*(wm+nz*am)
         p45=0.5*rhoiam*(wm-nz*am)
         p51=vitm2*nx+rhom*(vm*nz-wm*ny)
         p52=vitm2*ny+rhom*(wm*nx-um*nz)
         p53=vitm2*nz+rhom*(um*ny-vm*nx)
         p54=0.5*rhoiam*(hm+am*vn)
         p55=0.5*rhoiam*(hm-am*vn)
!        produit de Q avec les flux Euler aux points (i-1) a (i+2)
         q1f1m=q11*v(n-ninc  ,2)+q12*fxx(m-ninc)  +q13*fxy(m-ninc) &
                                +q14*fxz(m-ninc)  +q15*fex(m-ninc)
         q1f  =q11*v(n       ,2)+q12*fxx(m)       +q13*fxy(m) &
                                +q14*fxz(m)       +q15*fex(m)
         q1f1p=q11*v(n+ninc  ,2)+q12*fxx(m+ninc)  +q13*fxy(m+ninc) &
                                +q14*fxz(m+ninc)  +q15*fex(m+ninc)
         q1f2p=q11*v(n+2*ninc,2)+q12*fxx(m+2*ninc)+q13*fxy(m+2*ninc) &
                                +q14*fxz(m+2*ninc)+q15*fex(m+2*ninc)
!
         q2f1m=q21*v(n-ninc  ,2)+q22*fxx(m-ninc)  +q23*fxy(m-ninc) &
                                +q24*fxz(m-ninc)  +q25*fex(m-ninc)
         q2f  =q21*v(n       ,2)+q22*fxx(m)       +q23*fxy(m) &
                                +q24*fxz(m)       +q25*fex(m)
         q2f1p=q21*v(n+ninc  ,2)+q22*fxx(m+ninc)  +q23*fxy(m+ninc) &
                                +q24*fxz(m+ninc)  +q25*fex(m+ninc)
         q2f2p=q21*v(n+2*ninc,2)+q22*fxx(m+2*ninc)+q23*fxy(m+2*ninc) &
                                +q24*fxz(m+2*ninc)+q25*fex(m+2*ninc)
!
         q3f1m=q31*v(n-ninc  ,2)+q32*fxx(m-ninc)  +q33*fxy(m-ninc) &
                                +q34*fxz(m-ninc)  +q35*fex(m-ninc)
         q3f  =q31*v(n       ,2)+q32*fxx(m)       +q33*fxy(m) &
                                +q34*fxz(m)       +q35*fex(m)
         q3f1p=q31*v(n+ninc  ,2)+q32*fxx(m+ninc)  +q33*fxy(m+ninc) &
                                +q34*fxz(m+ninc)  +q35*fex(m+ninc)
         q3f2p=q31*v(n+2*ninc,2)+q32*fxx(m+2*ninc)+q33*fxy(m+2*ninc) &
                                +q34*fxz(m+2*ninc)+q35*fex(m+2*ninc)
!
         q4f1m=q41*v(n-ninc  ,2)+q42*fxx(m-ninc)  +q43*fxy(m-ninc) &
                                +q44*fxz(m-ninc)  +q45*fex(m-ninc)
         q4f  =q41*v(n       ,2)+q42*fxx(m)       +q43*fxy(m) &
                                +q44*fxz(m)       +q45*fex(m)
         q4f1p=q41*v(n+ninc  ,2)+q42*fxx(m+ninc)  +q43*fxy(m+ninc) &
                                +q44*fxz(m+ninc)  +q45*fex(m+ninc)
         q4f2p=q41*v(n+2*ninc,2)+q42*fxx(m+2*ninc)+q43*fxy(m+2*ninc) &
                                +q44*fxz(m+2*ninc)+q45*fex(m+2*ninc)
!
         q5f1m=q51*v(n-ninc  ,2)+q52*fxx(m-ninc)  +q53*fxy(m-ninc) &
                                +q54*fxz(m-ninc)  +q55*fex(m-ninc)
         q5f  =q51*v(n       ,2)+q52*fxx(m)       +q53*fxy(m) &
                                +q54*fxz(m)       +q55*fex(m)
         q5f1p=q51*v(n+ninc  ,2)+q52*fxx(m+ninc)  +q53*fxy(m+ninc) &
                                +q54*fxz(m+ninc)  +q55*fex(m+ninc)
         q5f2p=q51*v(n+2*ninc,2)+q52*fxx(m+2*ninc)+q53*fxy(m+2*ninc) &
                                +q54*fxz(m+2*ninc)+q55*fex(m+2*ninc)
!        calcul des flux d'ordre 2 sur les 2 stencils
         f11=0.5*(1.+sign(1.,v1))*(q1f1m*c10 +q1f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q1f  *c00 +q1f1p*c01)
         f12=0.5*(1.+sign(1.,v1))*(q1f  *c00 +q1f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q1f1p*c11 +q1f2p*c10)
!
         f21=0.5*(1.+sign(1.,v1))*(q2f1m*c10 +q2f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q2f  *c00 +q2f1p*c01)
         f22=0.5*(1.+sign(1.,v1))*(q2f  *c00 +q2f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q2f1p*c11 +q2f2p*c10)
!
         f31=0.5*(1.+sign(1.,v1))*(q3f1m*c10 +q3f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q3f  *c00 +q3f1p*c01)
         f32=0.5*(1.+sign(1.,v1))*(q3f  *c00 +q3f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q3f1p*c11 +q3f2p*c10)
!
         f41=0.5*(1.+sign(1.,v4))*(q4f1m*c10 +q4f  *c11) &
            +0.5*(1.-sign(1.,v4))*(q4f  *c00 +q4f1p*c01)
         f42=0.5*(1.+sign(1.,v4))*(q4f  *c00 +q4f1p*c01) &
            +0.5*(1.-sign(1.,v4))*(q4f1p*c11 +q4f2p*c10)
!
         f51=0.5*(1.+sign(1.,v5))*(q5f1m*c10 +q5f  *c11) &
            +0.5*(1.-sign(1.,v5))*(q5f  *c00 +q5f1p*c01)
         f52=0.5*(1.+sign(1.,v5))*(q5f  *c00 +q5f1p*c01) &
            +0.5*(1.-sign(1.,v5))*(q5f1p*c11 +q5f2p*c10)
!        calcul des senseurs beta (au carre)
         iexp=2
!         iexp=1
         beta11=(0.5*(1.+sign(1.,v1))*(q1f-q1f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f1p-q1f)**2+eps)**iexp
         beta12=(0.5*(1.+sign(1.,v1))*(q1f1p-q1f)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f2p-q1f1p)**2+eps)**iexp
!
         beta21=(0.5*(1.+sign(1.,v1))*(q2f-q2f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f1p-q2f)**2+eps)**iexp
         beta22=(0.5*(1.+sign(1.,v1))*(q2f1p-q2f)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f2p-q2f1p)**2+eps)**iexp
!
         beta31=(0.5*(1.+sign(1.,v1))*(q3f-q3f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f1p-q3f)**2+eps)**iexp
         beta32=(0.5*(1.+sign(1.,v1))*(q3f1p-q3f)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f2p-q3f1p)**2+eps)**iexp
!
         beta41=(0.5*(1.+sign(1.,v4))*(q4f-q4f1m)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f1p-q4f)**2+eps)**iexp
         beta42=(0.5*(1.+sign(1.,v4))*(q4f1p-q4f)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f2p-q4f1p)**2+eps)**iexp
!
         beta51=(0.5*(1.+sign(1.,v5))*(q5f-q5f1m)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f1p-q5f)**2+eps)**iexp
         beta52=(0.5*(1.+sign(1.,v5))*(q5f1p-q5f)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f2p-q5f1p)**2+eps)**iexp
!        calculs des poids wi
         ww11=0.5*(1.+sign(1.,v1))*(ga1/beta11) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta11)
         ww21=0.5*(1.+sign(1.,v1))*(ga2/beta12) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta12)
         sw=ww11+ww21
         w11=ww11/sw
         w21=ww21/sw
   ww11m=w11*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w11+w11**2)/(ga1**2+w11*(1.-2.*ga1)) &
        +w11*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w11+w11**2)/(ga2**2+w11*(1.-2.*ga2))
   ww21m=w21*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w21+w21**2)/(ga2**2+w21*(1.-2.*ga2)) &   
        +w21*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w21+w21**2)/(ga1**2+w21*(1.-2.*ga1))
         swm=ww11m+ww21m
         w11=ww11m/swm 
         w21=ww21m/swm 
!
         ww12=0.5*(1.+sign(1.,v1))*(ga1/beta21) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta21)
         ww22=0.5*(1.+sign(1.,v1))*(ga2/beta22) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta22)
         sw=ww12+ww22
         w12=ww12/sw
         w22=ww22/sw
   ww12m=w12*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w12+w12**2)/(ga1**2+w12*(1.-2.*ga1)) &
        +w12*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w12+w12**2)/(ga2**2+w12*(1.-2.*ga2))
   ww22m=w22*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w22+w22**2)/(ga2**2+w22*(1.-2.*ga2)) &   
        +w22*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w22+w22**2)/(ga1**2+w22*(1.-2.*ga1))
         swm=ww12m+ww22m 
         w12=ww12m/swm 
         w22=ww22m/swm 
!
         ww13=0.5*(1.+sign(1.,v1))*(ga1/beta31) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta31)
         ww23=0.5*(1.+sign(1.,v1))*(ga2/beta32) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta32)
         sw=ww13+ww23
         w13=ww13/sw
         w23=ww23/sw
   ww13m=w13*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w13+w13**2)/(ga1**2+w13*(1.-2.*ga1)) &
        +w13*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w13+w13**2)/(ga2**2+w13*(1.-2.*ga2))
   ww23m=w23*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w23+w23**2)/(ga2**2+w23*(1.-2.*ga2)) &   
        +w23*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w23+w23**2)/(ga1**2+w23*(1.-2.*ga1))
         swm=ww13m+ww23m
         w13=ww13m/swm 
         w23=ww23m/swm 
!
         ww14=0.5*(1.+sign(1.,v4))*(ga1/beta41) &
             +0.5*(1.-sign(1.,v4))*(ga2/beta41)
         ww24=0.5*(1.+sign(1.,v4))*(ga2/beta42) &
             +0.5*(1.-sign(1.,v4))*(ga1/beta42)
         sw=ww14+ww24
         w14=ww14/sw
         w24=ww24/sw
   ww14m=w14*0.5*(1.+sign(1.,v4))*(ga1+ga1**2-3.*ga1*w14+w14**2)/(ga1**2+w14*(1.-2.*ga1)) &
        +w14*0.5*(1.-sign(1.,v4))*(ga2+ga2**2-3.*ga2*w14+w14**2)/(ga2**2+w14*(1.-2.*ga2))
   ww24m=w24*0.5*(1.+sign(1.,v4))*(ga2+ga2**2-3.*ga2*w24+w24**2)/(ga2**2+w24*(1.-2.*ga2)) &   
        +w24*0.5*(1.-sign(1.,v4))*(ga1+ga1**2-3.*ga1*w24+w24**2)/(ga1**2+w24*(1.-2.*ga1))
         swm=ww14m+ww24m 
         w14=ww14m/swm 
         w24=ww24m/swm 
!
         ww15=0.5*(1.+sign(1.,v5))*(ga1/beta51) &
             +0.5*(1.-sign(1.,v5))*(ga2/beta51)
         ww25=0.5*(1.+sign(1.,v5))*(ga2/beta52) &
             +0.5*(1.-sign(1.,v5))*(ga1/beta52)
         sw=ww15+ww25
         w15=ww15/sw
         w25=ww25/sw
   ww15m=w15*0.5*(1.+sign(1.,v5))*(ga1+ga1**2-3.*ga1*w15+w15**2)/(ga1**2+w15*(1.-2.*ga1)) &
        +w15*0.5*(1.-sign(1.,v5))*(ga2+ga2**2-3.*ga2*w15+w15**2)/(ga2**2+w15*(1.-2.*ga2))
   ww25m=w25*0.5*(1.+sign(1.,v5))*(ga2+ga2**2-3.*ga2*w25+w25**2)/(ga2**2+w25*(1.-2.*ga2)) &   
        +w25*0.5*(1.-sign(1.,v5))*(ga1+ga1**2-3.*ga1*w25+w25**2)/(ga1**2+w25*(1.-2.*ga1))
         swm=ww15m+ww25m
         w15=ww15m/swm 
         w25=ww25m/swm 
!        calcul des flux convectifs projetes
         fc1=w11*f11+w21*f12
         fc2=w12*f21+w22*f22
         fc3=w13*f31+w23*f32
         fc4=w14*f41+w24*f42
         fc5=w15*f51+w25*f52
!        produit avec matrice P pour retour dans l'espace physique
         f1=fc1*p11+fc2*p12+fc3*p13+fc4*p14+fc5*p15
         f2=fc1*p21+fc2*p22+fc3*p23+fc4*p24+fc5*p25
         f3=fc1*p31+fc2*p32+fc3*p33+fc4*p34+fc5*p35
         f4=fc1*p41+fc2*p42+fc3*p43+fc4*p44+fc5*p45
         f5=fc1*p51+fc2*p52+fc3*p53+fc4*p54+fc5*p55
!-------------------------------------------------------------------
!        produit de Q avec les flux Euler aux points (i-1) a (i+2)
         q1f1m=q11*v(n-ninc  ,3)+q12*fxy(m-ninc)  +q13*fyy(m-ninc) &
                                +q14*fyz(m-ninc)  +q15*fey(m-ninc)
         q1f  =q11*v(n       ,3)+q12*fxy(m)       +q13*fyy(m) &
                                +q14*fyz(m)       +q15*fey(m)
         q1f1p=q11*v(n+ninc  ,3)+q12*fxy(m+ninc)  +q13*fyy(m+ninc) &
                                +q14*fyz(m+ninc)  +q15*fey(m+ninc)
         q1f2p=q11*v(n+2*ninc,3)+q12*fxy(m+2*ninc)+q13*fyy(m+2*ninc) &
                                +q14*fyz(m+2*ninc)+q15*fey(m+2*ninc)
!
         q2f1m=q21*v(n-ninc  ,3)+q22*fxy(m-ninc)  +q23*fyy(m-ninc) &
                                +q24*fyz(m-ninc)  +q25*fey(m-ninc)
         q2f  =q21*v(n       ,3)+q22*fxy(m)       +q23*fyy(m) &
                                +q24*fyz(m)       +q25*fey(m)
         q2f1p=q21*v(n+ninc  ,3)+q22*fxy(m+ninc)  +q23*fyy(m+ninc) &
                                +q24*fyz(m+ninc)  +q25*fey(m+ninc)
         q2f2p=q21*v(n+2*ninc,3)+q22*fxy(m+2*ninc)+q23*fyy(m+2*ninc) &
                                +q24*fyz(m+2*ninc)+q25*fey(m+2*ninc)
!
         q3f1m=q31*v(n-ninc  ,3)+q32*fxy(m-ninc)  +q33*fyy(m-ninc) &
                                +q34*fyz(m-ninc)  +q35*fey(m-ninc)
         q3f  =q31*v(n       ,3)+q32*fxy(m)       +q33*fyy(m) &
                                +q34*fyz(m)       +q35*fey(m)
         q3f1p=q31*v(n+ninc  ,3)+q32*fxy(m+ninc)  +q33*fyy(m+ninc) &
                                +q34*fyz(m+ninc)  +q35*fey(m+ninc)
         q3f2p=q31*v(n+2*ninc,3)+q32*fxy(m+2*ninc)+q33*fyy(m+2*ninc) &
                                +q34*fyz(m+2*ninc)+q35*fey(m+2*ninc)
!
         q4f1m=q41*v(n-ninc  ,3)+q42*fxy(m-ninc)  +q43*fyy(m-ninc) &
                                +q44*fyz(m-ninc)  +q45*fey(m-ninc)
         q4f  =q41*v(n       ,3)+q42*fxy(m)       +q43*fyy(m) &
                                +q44*fyz(m)       +q45*fey(m)
         q4f1p=q41*v(n+ninc  ,3)+q42*fxy(m+ninc)  +q43*fyy(m+ninc) &
                                +q44*fyz(m+ninc)  +q45*fey(m+ninc)
         q4f2p=q41*v(n+2*ninc,3)+q42*fxy(m+2*ninc)+q43*fyy(m+2*ninc) &
                                +q44*fyz(m+2*ninc)+q45*fey(m+2*ninc)
!
         q5f1m=q51*v(n-ninc  ,3)+q52*fxy(m-ninc)  +q53*fyy(m-ninc) &
                                +q54*fyz(m-ninc)  +q55*fey(m-ninc)
         q5f  =q51*v(n       ,3)+q52*fxy(m)       +q53*fyy(m) &
                                +q54*fyz(m)       +q55*fey(m)
         q5f1p=q51*v(n+ninc  ,3)+q52*fxy(m+ninc)  +q53*fyy(m+ninc) &
                                +q54*fyz(m+ninc)  +q55*fey(m+ninc)
         q5f2p=q51*v(n+2*ninc,3)+q52*fxy(m+2*ninc)+q53*fyy(m+2*ninc) &
                                +q54*fyz(m+2*ninc)+q55*fey(m+2*ninc)
!        calcul des flux d'ordre 2 sur les 2 stencils
         g11=0.5*(1.+sign(1.,v1))*(q1f1m*c10 +q1f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q1f  *c00 +q1f1p*c01)
         g12=0.5*(1.+sign(1.,v1))*(q1f  *c00 +q1f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q1f1p*c11 +q1f2p*c10)
!
         g21=0.5*(1.+sign(1.,v1))*(q2f1m*c10 +q2f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q2f  *c00 +q2f1p*c01)
         g22=0.5*(1.+sign(1.,v1))*(q2f  *c00 +q2f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q2f1p*c11 +q2f2p*c10)
!
         g31=0.5*(1.+sign(1.,v1))*(q3f1m*c10 +q3f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q3f  *c00 +q3f1p*c01)
         g32=0.5*(1.+sign(1.,v1))*(q3f  *c00 +q3f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q3f1p*c11 +q3f2p*c10)
!
         g41=0.5*(1.+sign(1.,v4))*(q4f1m*c10 +q4f  *c11) &
            +0.5*(1.-sign(1.,v4))*(q4f  *c00 +q4f1p*c01)
         g42=0.5*(1.+sign(1.,v4))*(q4f  *c00 +q4f1p*c01) &
            +0.5*(1.-sign(1.,v4))*(q4f1p*c11 +q4f2p*c10)
!
         g51=0.5*(1.+sign(1.,v5))*(q5f1m*c10 +q5f  *c11) &
            +0.5*(1.-sign(1.,v5))*(q5f  *c00 +q5f1p*c01)
         g52=0.5*(1.+sign(1.,v5))*(q5f  *c00 +q5f1p*c01) &
            +0.5*(1.-sign(1.,v5))*(q5f1p*c11 +q5f2p*c10)
!        calcul des senseurs beta (au carre)
         iexp=2
!         iexp=1
         beta11=(0.5*(1.+sign(1.,v1))*(q1f-q1f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f1p-q1f)**2+eps)**iexp
         beta12=(0.5*(1.+sign(1.,v1))*(q1f1p-q1f)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f2p-q1f1p)**2+eps)**iexp
!
         beta21=(0.5*(1.+sign(1.,v1))*(q2f-q2f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f1p-q2f)**2+eps)**iexp
         beta22=(0.5*(1.+sign(1.,v1))*(q2f1p-q2f)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f2p-q2f1p)**2+eps)**iexp
!
         beta31=(0.5*(1.+sign(1.,v1))*(q3f-q3f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f1p-q3f)**2+eps)**iexp
         beta32=(0.5*(1.+sign(1.,v1))*(q3f1p-q3f)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f2p-q3f1p)**2+eps)**iexp
!
         beta41=(0.5*(1.+sign(1.,v4))*(q4f-q4f1m)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f1p-q4f)**2+eps)**iexp
         beta42=(0.5*(1.+sign(1.,v4))*(q4f1p-q4f)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f2p-q4f1p)**2+eps)**iexp
!
         beta51=(0.5*(1.+sign(1.,v5))*(q5f-q5f1m)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f1p-q5f)**2+eps)**iexp
         beta52=(0.5*(1.+sign(1.,v5))*(q5f1p-q5f)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f2p-q5f1p)**2+eps)**iexp
!        calculs des poids wi
         ww11=0.5*(1.+sign(1.,v1))*(ga1/beta11) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta11)
         ww21=0.5*(1.+sign(1.,v1))*(ga2/beta12) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta12)
         sw=ww11+ww21
         w11=ww11/sw
         w21=ww21/sw
   ww11m=w11*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w11+w11**2)/(ga1**2+w11*(1.-2.*ga1)) &
        +w11*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w11+w11**2)/(ga2**2+w11*(1.-2.*ga2))
   ww21m=w21*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w21+w21**2)/(ga2**2+w21*(1.-2.*ga2)) &   
        +w21*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w21+w21**2)/(ga1**2+w21*(1.-2.*ga1))
         swm=ww11m+ww21m
         w11=ww11m/swm 
         w21=ww21m/swm 
!
         ww12=0.5*(1.+sign(1.,v1))*(ga1/beta21) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta21)
         ww22=0.5*(1.+sign(1.,v1))*(ga2/beta22) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta22)
         sw=ww12+ww22
         w12=ww12/sw
         w22=ww22/sw
   ww12m=w12*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w12+w12**2)/(ga1**2+w12*(1.-2.*ga1)) &
        +w12*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w12+w12**2)/(ga2**2+w12*(1.-2.*ga2))
   ww22m=w22*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w22+w22**2)/(ga2**2+w22*(1.-2.*ga2)) &   
        +w22*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w22+w22**2)/(ga1**2+w22*(1.-2.*ga1))
         swm=ww12m+ww22m 
         w12=ww12m/swm 
         w22=ww22m/swm 
!
         ww13=0.5*(1.+sign(1.,v1))*(ga1/beta31) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta31)
         ww23=0.5*(1.+sign(1.,v1))*(ga2/beta32) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta32)
         sw=ww13+ww23
         w13=ww13/sw
         w23=ww23/sw
   ww13m=w13*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w13+w13**2)/(ga1**2+w13*(1.-2.*ga1)) &
        +w13*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w13+w13**2)/(ga2**2+w13*(1.-2.*ga2))
   ww23m=w23*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w23+w23**2)/(ga2**2+w23*(1.-2.*ga2)) &   
        +w23*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w23+w23**2)/(ga1**2+w23*(1.-2.*ga1))
         swm=ww13m+ww23m
         w13=ww13m/swm 
         w23=ww23m/swm 
!
         ww14=0.5*(1.+sign(1.,v4))*(ga1/beta41) &
             +0.5*(1.-sign(1.,v4))*(ga2/beta41)
         ww24=0.5*(1.+sign(1.,v4))*(ga2/beta42) &
             +0.5*(1.-sign(1.,v4))*(ga1/beta42)
         sw=ww14+ww24
         w14=ww14/sw
         w24=ww24/sw
   ww14m=w14*0.5*(1.+sign(1.,v4))*(ga1+ga1**2-3.*ga1*w14+w14**2)/(ga1**2+w14*(1.-2.*ga1)) &
        +w14*0.5*(1.-sign(1.,v4))*(ga2+ga2**2-3.*ga2*w14+w14**2)/(ga2**2+w14*(1.-2.*ga2))
   ww24m=w24*0.5*(1.+sign(1.,v4))*(ga2+ga2**2-3.*ga2*w24+w24**2)/(ga2**2+w24*(1.-2.*ga2)) &   
        +w24*0.5*(1.-sign(1.,v4))*(ga1+ga1**2-3.*ga1*w24+w24**2)/(ga1**2+w24*(1.-2.*ga1))
         swm=ww14m+ww24m 
         w14=ww14m/swm 
         w24=ww24m/swm 
!
         ww15=0.5*(1.+sign(1.,v5))*(ga1/beta51) &
             +0.5*(1.-sign(1.,v5))*(ga2/beta51)
         ww25=0.5*(1.+sign(1.,v5))*(ga2/beta52) &
             +0.5*(1.-sign(1.,v5))*(ga1/beta52)
         sw=ww15+ww25
         w15=ww15/sw
         w25=ww25/sw
   ww15m=w15*0.5*(1.+sign(1.,v5))*(ga1+ga1**2-3.*ga1*w15+w15**2)/(ga1**2+w15*(1.-2.*ga1)) &
        +w15*0.5*(1.-sign(1.,v5))*(ga2+ga2**2-3.*ga2*w15+w15**2)/(ga2**2+w15*(1.-2.*ga2))
   ww25m=w25*0.5*(1.+sign(1.,v5))*(ga2+ga2**2-3.*ga2*w25+w25**2)/(ga2**2+w25*(1.-2.*ga2)) &   
        +w25*0.5*(1.-sign(1.,v5))*(ga1+ga1**2-3.*ga1*w25+w25**2)/(ga1**2+w25*(1.-2.*ga1))
         swm=ww15m+ww25m
         w15=ww15m/swm 
         w25=ww25m/swm 
!        calcul des flux convectifs projetes
         gc1=w11*g11+w21*g12
         gc2=w12*g21+w22*g22
         gc3=w13*g31+w23*g32
         gc4=w14*g41+w24*g42
         gc5=w15*g51+w25*g52
!        produit avec matrice P pour retour dans l'espace physique
         g1=gc1*p11+gc2*p12+gc3*p13+gc4*p14+gc5*p15
         g2=gc1*p21+gc2*p22+gc3*p23+gc4*p24+gc5*p25
         g3=gc1*p31+gc2*p32+gc3*p33+gc4*p34+gc5*p35
         g4=gc1*p41+gc2*p42+gc3*p43+gc4*p44+gc5*p45
         g5=gc1*p51+gc2*p52+gc3*p53+gc4*p54+gc5*p55
!-------------------------------------------------------------------
!        produit de Q avec les flux Euler aux points (i-1) a (i+2)
         q1f1m=q11*v(n-ninc  ,4)+q12*fxz(m-ninc)  +q13*fyz(m-ninc) &
                                +q14*fzz(m-ninc)  +q15*fez(m-ninc) 
         q1f  =q11*v(n       ,4)+q12*fxz(m)       +q13*fyz(m) &
                                +q14*fzz(m)       +q15*fez(m)
         q1f1p=q11*v(n+ninc  ,4)+q12*fxz(m+ninc)  +q13*fyz(m+ninc) &
                                +q14*fzz(m+ninc)  +q15*fez(m+ninc)     
         q1f2p=q11*v(n+2*ninc,4)+q12*fxz(m+2*ninc)+q13*fyz(m+2*ninc) &
                                +q14*fzz(m+2*ninc)+q15*fez(m+2*ninc)
!
         q2f1m=q21*v(n-ninc  ,4)+q22*fxz(m-ninc)  +q23*fyz(m-ninc) &
                                +q24*fzz(m-ninc)  +q25*fez(m-ninc)
         q2f  =q21*v(n       ,4)+q22*fxz(m)       +q23*fyz(m) &
                                +q24*fzz(m)       +q25*fez(m)
         q2f1p=q21*v(n+ninc  ,4)+q22*fxz(m+ninc)  +q23*fyz(m+ninc) &
                                +q24*fzz(m+ninc)  +q25*fez(m+ninc)
         q2f2p=q21*v(n+2*ninc,4)+q22*fxz(m+2*ninc)+q23*fyz(m+2*ninc) &
                                +q24*fzz(m+2*ninc)+q25*fez(m+2*ninc)
!
         q3f1m=q31*v(n-ninc  ,4)+q32*fxz(m-ninc)  +q33*fyz(m-ninc) &
                                +q34*fzz(m-ninc)  +q35*fez(m-ninc)
         q3f  =q31*v(n       ,4)+q32*fxz(m)       +q33*fyz(m) &
                                +q34*fzz(m)       +q35*fez(m)
         q3f1p=q31*v(n+ninc  ,4)+q32*fxz(m+ninc)  +q33*fyz(m+ninc) &
                                +q34*fzz(m+ninc)  +q35*fez(m+ninc)
         q3f2p=q31*v(n+2*ninc,4)+q32*fxz(m+2*ninc)+q33*fyz(m+2*ninc) &
                                +q34*fzz(m+2*ninc)+q35*fez(m+2*ninc)
!
         q4f1m=q41*v(n-ninc  ,4)+q42*fxz(m-ninc)  +q43*fyz(m-ninc) &
                                +q44*fzz(m-ninc)  +q45*fez(m-ninc)
         q4f  =q41*v(n       ,4)+q42*fxz(m)       +q43*fyz(m) &
                                +q44*fzz(m)       +q45*fez(m)
         q4f1p=q41*v(n+ninc  ,4)+q42*fxz(m+ninc)  +q43*fyz(m+ninc) &
                                +q44*fzz(m+ninc)  +q45*fez(m+ninc)
         q4f2p=q41*v(n+2*ninc,4)+q42*fxz(m+2*ninc)+q43*fyz(m+2*ninc) &
                                +q44*fzz(m+2*ninc)+q45*fez(m+2*ninc)
!
         q5f1m=q51*v(n-ninc  ,4)+q52*fxz(m-ninc)  +q53*fyz(m-ninc) &
                                +q54*fzz(m-ninc)  +q55*fez(m-ninc)
         q5f  =q51*v(n       ,4)+q52*fxz(m)       +q53*fyz(m) &
                                +q54*fzz(m)       +q55*fez(m)
         q5f1p=q51*v(n+ninc  ,4)+q52*fxz(m+ninc)  +q53*fyz(m+ninc) &
                                +q54*fzz(m+ninc)  +q55*fez(m+ninc)
         q5f2p=q51*v(n+2*ninc,4)+q52*fxz(m+2*ninc)+q53*fyz(m+2*ninc) &
                                +q54*fzz(m+2*ninc)+q55*fez(m+2*ninc)
!        calcul des flux d'ordre 2 sur les 2 stencils       
         h11=0.5*(1.+sign(1.,v1))*(q1f1m*c10 +q1f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q1f  *c00 +q1f1p*c01)
         h12=0.5*(1.+sign(1.,v1))*(q1f  *c00 +q1f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q1f1p*c11 +q1f2p*c10)
!     
         h21=0.5*(1.+sign(1.,v1))*(q2f1m*c10 +q2f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q2f  *c00 +q2f1p*c01)
         h22=0.5*(1.+sign(1.,v1))*(q2f  *c00 +q2f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q2f1p*c11 +q2f2p*c10)
!
         h31=0.5*(1.+sign(1.,v1))*(q3f1m*c10 +q3f  *c11) &
            +0.5*(1.-sign(1.,v1))*(q3f  *c00 +q3f1p*c01)
         h32=0.5*(1.+sign(1.,v1))*(q3f  *c00 +q3f1p*c01) &
            +0.5*(1.-sign(1.,v1))*(q3f1p*c11 +q3f2p*c10)
!
         h41=0.5*(1.+sign(1.,v4))*(q4f1m*c10 +q4f  *c11) &
            +0.5*(1.-sign(1.,v4))*(q4f  *c00 +q4f1p*c01)
         h42=0.5*(1.+sign(1.,v4))*(q4f  *c00 +q4f1p*c01) &
            +0.5*(1.-sign(1.,v4))*(q4f1p*c11 +q4f2p*c10)
!
         h51=0.5*(1.+sign(1.,v5))*(q5f1m*c10 +q5f  *c11) &
            +0.5*(1.-sign(1.,v5))*(q5f  *c00 +q5f1p*c01)
         h52=0.5*(1.+sign(1.,v5))*(q5f  *c00 +q5f1p*c01) &
            +0.5*(1.-sign(1.,v5))*(q5f1p*c11 +q5f2p*c10)
!        calcul des senseurs beta (au carre)
         iexp=2
!         iexp=1 
         beta11=(0.5*(1.+sign(1.,v1))*(q1f-q1f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f1p-q1f)**2+eps)**iexp
         beta12=(0.5*(1.+sign(1.,v1))*(q1f1p-q1f)**2 &
                +0.5*(1.-sign(1.,v1))*(q1f2p-q1f1p)**2+eps)**iexp
!
         beta21=(0.5*(1.+sign(1.,v1))*(q2f-q2f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f1p-q2f)**2+eps)**iexp
         beta22=(0.5*(1.+sign(1.,v1))*(q2f1p-q2f)**2 &
                +0.5*(1.-sign(1.,v1))*(q2f2p-q2f1p)**2+eps)**iexp
!
         beta31=(0.5*(1.+sign(1.,v1))*(q3f-q3f1m)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f1p-q3f)**2+eps)**iexp
         beta32=(0.5*(1.+sign(1.,v1))*(q3f1p-q3f)**2 &
                +0.5*(1.-sign(1.,v1))*(q3f2p-q3f1p)**2+eps)**iexp
!
         beta41=(0.5*(1.+sign(1.,v4))*(q4f-q4f1m)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f1p-q4f)**2+eps)**iexp
         beta42=(0.5*(1.+sign(1.,v4))*(q4f1p-q4f)**2 &
                +0.5*(1.-sign(1.,v4))*(q4f2p-q4f1p)**2+eps)**iexp
!
         beta51=(0.5*(1.+sign(1.,v5))*(q5f-q5f1m)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f1p-q5f)**2+eps)**iexp
         beta52=(0.5*(1.+sign(1.,v5))*(q5f1p-q5f)**2 &
                +0.5*(1.-sign(1.,v5))*(q5f2p-q5f1p)**2+eps)**iexp
!        calculs des poids wi    
         ww11=0.5*(1.+sign(1.,v1))*(ga1/beta11) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta11)
         ww21=0.5*(1.+sign(1.,v1))*(ga2/beta12) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta12)
         sw=ww11+ww21
         w11=ww11/sw
         w21=ww21/sw
   ww11m=w11*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w11+w11**2)/(ga1**2+w11*(1.-2.*ga1)) &
        +w11*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w11+w11**2)/(ga2**2+w11*(1.-2.*ga2))
   ww21m=w21*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w21+w21**2)/(ga2**2+w21*(1.-2.*ga2)) &   
        +w21*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w21+w21**2)/(ga1**2+w21*(1.-2.*ga1))
         swm=ww11m+ww21m
         w11=ww11m/swm 
         w21=ww21m/swm 
!
         ww12=0.5*(1.+sign(1.,v1))*(ga1/beta21) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta21)
         ww22=0.5*(1.+sign(1.,v1))*(ga2/beta22) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta22)
         sw=ww12+ww22
         w12=ww12/sw
         w22=ww22/sw
   ww12m=w12*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w12+w12**2)/(ga1**2+w12*(1.-2.*ga1)) &
        +w12*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w12+w12**2)/(ga2**2+w12*(1.-2.*ga2))
   ww22m=w22*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w22+w22**2)/(ga2**2+w22*(1.-2.*ga2)) &   
        +w22*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w22+w22**2)/(ga1**2+w22*(1.-2.*ga1))
         swm=ww12m+ww22m 
         w12=ww12m/swm 
         w22=ww22m/swm 
!
         ww13=0.5*(1.+sign(1.,v1))*(ga1/beta31) &
             +0.5*(1.-sign(1.,v1))*(ga2/beta31)
         ww23=0.5*(1.+sign(1.,v1))*(ga2/beta32) &
             +0.5*(1.-sign(1.,v1))*(ga1/beta32)
         sw=ww13+ww23
         w13=ww13/sw
         w23=ww23/sw
   ww13m=w13*0.5*(1.+sign(1.,v1))*(ga1+ga1**2-3.*ga1*w13+w13**2)/(ga1**2+w13*(1.-2.*ga1)) &
        +w13*0.5*(1.-sign(1.,v1))*(ga2+ga2**2-3.*ga2*w13+w13**2)/(ga2**2+w13*(1.-2.*ga2))
   ww23m=w23*0.5*(1.+sign(1.,v1))*(ga2+ga2**2-3.*ga2*w23+w23**2)/(ga2**2+w23*(1.-2.*ga2)) &   
        +w23*0.5*(1.-sign(1.,v1))*(ga1+ga1**2-3.*ga1*w23+w23**2)/(ga1**2+w23*(1.-2.*ga1))
         swm=ww13m+ww23m
         w13=ww13m/swm 
         w23=ww23m/swm 
!
         ww14=0.5*(1.+sign(1.,v4))*(ga1/beta41) &
             +0.5*(1.-sign(1.,v4))*(ga2/beta41)
         ww24=0.5*(1.+sign(1.,v4))*(ga2/beta42) &
             +0.5*(1.-sign(1.,v4))*(ga1/beta42)
         sw=ww14+ww24
         w14=ww14/sw
         w24=ww24/sw
   ww14m=w14*0.5*(1.+sign(1.,v4))*(ga1+ga1**2-3.*ga1*w14+w14**2)/(ga1**2+w14*(1.-2.*ga1)) &
        +w14*0.5*(1.-sign(1.,v4))*(ga2+ga2**2-3.*ga2*w14+w14**2)/(ga2**2+w14*(1.-2.*ga2))
   ww24m=w24*0.5*(1.+sign(1.,v4))*(ga2+ga2**2-3.*ga2*w24+w24**2)/(ga2**2+w24*(1.-2.*ga2)) &   
        +w24*0.5*(1.-sign(1.,v4))*(ga1+ga1**2-3.*ga1*w24+w24**2)/(ga1**2+w24*(1.-2.*ga1))
         swm=ww14m+ww24m 
         w14=ww14m/swm 
         w24=ww24m/swm 
!
         ww15=0.5*(1.+sign(1.,v5))*(ga1/beta51) &
             +0.5*(1.-sign(1.,v5))*(ga2/beta51)
         ww25=0.5*(1.+sign(1.,v5))*(ga2/beta52) &
             +0.5*(1.-sign(1.,v5))*(ga1/beta52)
         sw=ww15+ww25
         w15=ww15/sw
         w25=ww25/sw
   ww15m=w15*0.5*(1.+sign(1.,v5))*(ga1+ga1**2-3.*ga1*w15+w15**2)/(ga1**2+w15*(1.-2.*ga1)) &
        +w15*0.5*(1.-sign(1.,v5))*(ga2+ga2**2-3.*ga2*w15+w15**2)/(ga2**2+w15*(1.-2.*ga2))
   ww25m=w25*0.5*(1.+sign(1.,v5))*(ga2+ga2**2-3.*ga2*w25+w25**2)/(ga2**2+w25*(1.-2.*ga2)) &   
        +w25*0.5*(1.-sign(1.,v5))*(ga1+ga1**2-3.*ga1*w25+w25**2)/(ga1**2+w25*(1.-2.*ga1))
         swm=ww15m+ww25m
         w15=ww15m/swm 
         w25=ww25m/swm 
!        calcul des flux convectifs projetes
         hc1=w11*h11+w21*h12
         hc2=w12*h21+w22*h22
         hc3=w13*h31+w23*h32
         hc4=w14*h41+w24*h42
         hc5=w15*h51+w25*h52
!        produit avec matrice P pour retour dans l'espace physique
         h1=hc1*p11+hc2*p12+hc3*p13+hc4*p14+hc5*p15
         h2=hc1*p21+hc2*p22+hc3*p23+hc4*p24+hc5*p25
         h3=hc1*p31+hc2*p32+hc3*p33+hc4*p34+hc5*p35
         h4=hc1*p41+hc2*p42+hc3*p43+hc4*p44+hc5*p45
         h5=hc1*p51+hc2*p52+hc3*p53+hc4*p54+hc5*p55
!        calcul du flux numerique et bilan de flux
         dh1=f1*sn(m1,kdir,1)+g1*sn(m1,kdir,2)+h1*sn(m1,kdir,3)
         dh2=f2*sn(m1,kdir,1)+g2*sn(m1,kdir,2)+h2*sn(m1,kdir,3)
         dh3=f3*sn(m1,kdir,1)+g3*sn(m1,kdir,2)+h3*sn(m1,kdir,3)
         dh4=f4*sn(m1,kdir,1)+g4*sn(m1,kdir,2)+h4*sn(m1,kdir,3)
         dh5=f5*sn(m1,kdir,1)+g5*sn(m1,kdir,2)+h5*sn(m1,kdir,3)
!        calcul des flux visqueux (multiplies par -2)
         hv2=(toxx(n)+toxx(n1))*sn(m1,kdir,1) &
            +(toxy(n)+toxy(n1))*sn(m1,kdir,2) &
            +(toxz(n)+toxz(n1))*sn(m1,kdir,3) 
         hv3=(toxy(n)+toxy(n1))*sn(m1,kdir,1) &
            +(toyy(n)+toyy(n1))*sn(m1,kdir,2) &
            +(toyz(n)+toyz(n1))*sn(m1,kdir,3)
         hv4=(toxz(n)+toxz(n1))*sn(m1,kdir,1) &
            +(toyz(n)+toyz(n1))*sn(m1,kdir,2) &
            +(tozz(n)+tozz(n1))*sn(m1,kdir,3)
         hv5=(toxx(n )*ul+toxy(n )*vl+toxz(n )*wl+qcx(n ) &
             +toxx(n1)*ur+toxy(n1)*vr+toxz(n1)*wr+qcx(n1))*sn(m1,kdir,1) &
            +(toxy(n )*ul+toyy(n )*vl+toyz(n )*wl+qcy(n ) &
             +toxy(n1)*ur+toyy(n1)*vr+toyz(n1)*wr+qcy(n1))*sn(m1,kdir,2) &
            +(toxz(n )*ul+toyz(n )*vl+tozz(n )*wl+qcz(n ) &
             +toxz(n1)*ur+toyz(n1)*vr+tozz(n1)*wr+qcz(n1))*sn(m1,kdir,3)

         u(n1,1)=u(n1,1)-dh1
         u(n1,2)=u(n1,2)-dh2+0.5*hv2
         u(n1,3)=u(n1,3)-dh3+0.5*hv3
         u(n1,4)=u(n1,4)-dh4+0.5*hv4
         u(n1,5)=u(n1,5)-dh5+0.5*hv5
         u(n,1)=u(n,1)+dh1
         u(n,2)=u(n,2)+dh2-0.5*hv2
         u(n,3)=u(n,3)+dh3-0.5*hv3
         u(n,4)=u(n,4)+dh4-0.5*hv4
         u(n,5)=u(n,5)+dh5-0.5*hv5
        enddo
       enddo
      enddo
!
!-----traitement des bords------------------------------------------
!
      kdir=1
      ninc=nci
!
      do k=k1,k2m1
       ind1 = indc(i1,j1  ,k)
       ind2 = indc(i1,j2m1,k)
       do n=ind1,ind2,ncj
        m=n-n0c
!       flux a la facette frontiere 
        f1=v(n-ninc,2)*sn(m,kdir,1) & 
         + v(n-ninc,3)*sn(m,kdir,2) &
         + v(n-ninc,4)*sn(m,kdir,3)
        f2=(fxx(m-ninc)-toxx(n-ninc))*sn(m,kdir,1) &
          +(fxy(m-ninc)-toxy(n-ninc))*sn(m,kdir,2) &
          +(fxz(m-ninc)-toxz(n-ninc))*sn(m,kdir,3)
        f3=(fxy(m-ninc)-toxy(n-ninc))*sn(m,kdir,1) &
          +(fyy(m-ninc)-toyy(n-ninc))*sn(m,kdir,2) &
          +(fyz(m-ninc)-toyz(n-ninc))*sn(m,kdir,3)
        f4=(fxz(m-ninc)-toxz(n-ninc))*sn(m,kdir,1) &
          +(fyz(m-ninc)-toyz(n-ninc))*sn(m,kdir,2) &
          +(fzz(m-ninc)-tozz(n-ninc))*sn(m,kdir,3)
        f5=(fex(m-ninc)-(toxx(n-ninc)*v(n-ninc,2)+toxy(n-ninc)*v(n-ninc,3)+ &
                   toxz(n-ninc)*v(n-ninc,4))/v(n-ninc,1)-qcx(n-ninc))*sn(m,kdir,1) &
          +(fey(m-ninc)-(toxy(n-ninc)*v(n-ninc,2)+toyy(n-ninc)*v(n-ninc,3)+ &
                   toyz(n-ninc)*v(n-ninc,4))/v(n-ninc,1)-qcy(n-ninc))*sn(m,kdir,2) &
          +(fez(m-ninc)-(toxz(n-ninc)*v(n-ninc,2)+toyz(n-ninc)*v(n-ninc,3)+ &
                   tozz(n-ninc)*v(n-ninc,4))/v(n-ninc,1)-qcz(n-ninc))*sn(m,kdir,3)
        u(n,1)=u(n,1)-f1
        u(n,2)=u(n,2)-f2
        u(n,3)=u(n,3)-f3
        u(n,4)=u(n,4)-f4
        u(n,5)=u(n,5)-f5
       enddo
      enddo
!
      do k=k1,k2m1
       ind1 = indc(i2m1,j1  ,k)
       ind2 = indc(i2m1,j2m1,k)
       do n=ind1,ind2,ncj       
        m=n-n0c
        m1=m+ninc
        n1=n+ninc
!       flux a la facette frontiere             
        f1=v(n1,2)*sn(m1,kdir,1) &
         + v(n1,3)*sn(m1,kdir,2) &
         + v(n1,4)*sn(m1,kdir,3)
        f2=(fxx(m1)-toxx(n1))*sn(m1,kdir,1) &
          +(fxy(m1)-toxy(n1))*sn(m1,kdir,2) &
          +(fxz(m1)-toxz(n1))*sn(m1,kdir,3)
        f3=(fxy(m1)-toxy(n1))*sn(m1,kdir,1) &
          +(fyy(m1)-toyy(n1))*sn(m1,kdir,2) &
          +(fyz(m1)-toyz(n1))*sn(m1,kdir,3)
        f4=(fxz(m1)-toxz(n1))*sn(m1,kdir,1) &
          +(fyz(m1)-toyz(n1))*sn(m1,kdir,2) &
          +(fzz(m1)-tozz(n1))*sn(m1,kdir,3)
        f5=(fex(m1)-(toxx(n1)*v(n1,2)+toxy(n1)*v(n1,3) &
          + toxz(n1)*v(n1,4))/v(n1,1)-qcx(n1))*sn(m1,kdir,1) &
          +(fey(m1)-(toxy(n1)*v(n1,2)+toyy(n1)*v(n1,3) &
          + toyz(n1)*v(n1,4))/v(n1,1)-qcy(n1))*sn(m1,kdir,2) &
          +(fez(m1)-(toxz(n1)*v(n1,2)+toyz(n1)*v(n1,3) &
          + tozz(n1)*v(n1,4))/v(n1,1)-qcz(n1))*sn(m1,kdir,3)
        u(n,1)=u(n,1)+f1
        u(n,2)=u(n,2)+f2
        u(n,3)=u(n,3)+f3
        u(n,4)=u(n,4)+f4        
        u(n,5)=u(n,5)+f5
       enddo
      enddo         
!
      kdir=2
      ninc=ncj
!
      do k=k1,k2m1
       ind1 = indc(i1  ,j1,k)
       ind2 = indc(i2m1,j1,k)
       do n=ind1,ind2
        m=n-n0c
!       flux a la facette frontiere 
        g1=v(n-ninc,2)*sn(m,kdir,1) &
         + v(n-ninc,3)*sn(m,kdir,2) &
         + v(n-ninc,4)*sn(m,kdir,3)
        g2=(fxx(m-ninc)-toxx(n-ninc))*sn(m,kdir,1) &
          +(fxy(m-ninc)-toxy(n-ninc))*sn(m,kdir,2) &
          +(fxz(m-ninc)-toxz(n-ninc))*sn(m,kdir,3)
        g3=(fxy(m-ninc)-toxy(n-ninc))*sn(m,kdir,1) &
          +(fyy(m-ninc)-toyy(n-ninc))*sn(m,kdir,2) &
          +(fyz(m-ninc)-toyz(n-ninc))*sn(m,kdir,3)
        g4=(fxz(m-ninc)-toxz(n-ninc))*sn(m,kdir,1) &
          +(fyz(m-ninc)-toyz(n-ninc))*sn(m,kdir,2) &
          +(fzz(m-ninc)-tozz(n-ninc))*sn(m,kdir,3)
        g5=(fex(m-ninc)-(toxx(n-ninc)*v(n-ninc,2)+toxy(n-ninc)*v(n-ninc,3)+ &
                   toxz(n-ninc)*v(n-ninc,4))/v(n-ninc,1)-qcx(n-ninc))*sn(m,kdir,1) &
          +(fey(m-ninc)-(toxy(n-ninc)*v(n-ninc,2)+toyy(n-ninc)*v(n-ninc,3)+ &
                      toyz(n-ninc)*v(n-ninc,4))/v(n-ninc,1)-qcy(n-ninc))*sn(m,kdir,2) &
          +(fez(m-ninc)-(toxz(n-ninc)*v(n-ninc,2)+toyz(n-ninc)*v(n-ninc,3)+ &
                   tozz(n-ninc)*v(n-ninc,4))/v(n-ninc,1)-qcz(n-ninc))*sn(m,kdir,3)
        u(n,1)=u(n,1)-g1
        u(n,2)=u(n,2)-g2
        u(n,3)=u(n,3)-g3
        u(n,4)=u(n,4)-g4
        u(n,5)=u(n,5)-g5
       enddo
      enddo

      do k=k1,k2m1
       ind1 = indc(i1  ,j2m1,k)
       ind2 = indc(i2m1,j2m1,k)
       do n=ind1,ind2
        m=n-n0c
        m1=m+ninc
        n1=n+ninc
!       flux a la facette frontiere        
        g1=v(n1,2)*sn(m1,kdir,1) &
         + v(n1,3)*sn(m1,kdir,2) &
         + v(n1,4)*sn(m1,kdir,3)
        g2=(fxx(m1)-toxx(n1))*sn(m1,kdir,1) &
          +(fxy(m1)-toxy(n1))*sn(m1,kdir,2) &
          +(fxz(m1)-toxz(n1))*sn(m1,kdir,3)
        g3=(fxy(m1)-toxy(n1))*sn(m1,kdir,1) &
          +(fyy(m1)-toyy(n1))*sn(m1,kdir,2) &
          +(fyz(m1)-toyz(n1))*sn(m1,kdir,3)
        g4=(fxz(m1)-toxz(n1))*sn(m1,kdir,1) &
          +(fyz(m1)-toyz(n1))*sn(m1,kdir,2) &
          +(fzz(m1)-tozz(n1))*sn(m1,kdir,3)
        g5=(fex(m1)-(toxx(n1)*v(n1,2)+toxy(n1)*v(n1,3) &
          + toxz(n1)*v(n1,4))/v(n1,1)-qcx(n1))*sn(m1,kdir,1) &
          +(fey(m1)-(toxy(n1)*v(n1,2)+toyy(n1)*v(n1,3) &
          + toyz(n1)*v(n1,4))/v(n1,1)-qcy(n1))*sn(m1,kdir,2) &
          +(fez(m1)-(toxz(n1)*v(n1,2)+toyz(n1)*v(n1,3) &
          + tozz(n1)*v(n1,4))/v(n1,1)-qcz(n1))*sn(m1,kdir,3)
        u(n,1)=u(n,1)+g1
        u(n,2)=u(n,2)+g2
        u(n,3)=u(n,3)+g3
        u(n,4)=u(n,4)+g4
        u(n,5)=u(n,5)+g5
       enddo
      enddo 
!
      kdir=3
      ninc=nck
!
      do j=j1,j2m1
       ind1 = indc(i1  ,j,k1)
       ind2 = indc(i2m1,j,k1)
       do n=ind1,ind2
        m=n-n0c
!       flux a la facette frontiere 
        h1=v(n-ninc,2)*sn(m,kdir,1) &
         + v(n-ninc,3)*sn(m,kdir,2) &
         + v(n-ninc,4)*sn(m,kdir,3)
        h2=(fxx(m-ninc)-toxx(n-ninc))*sn(m,kdir,1) &
          +(fxy(m-ninc)-toxy(n-ninc))*sn(m,kdir,2) &
          +(fxz(m-ninc)-toxz(n-ninc))*sn(m,kdir,3)
        h3=(fxy(m-ninc)-toxy(n-ninc))*sn(m,kdir,1) &
          +(fyy(m-ninc)-toyy(n-ninc))*sn(m,kdir,2) &
          +(fyz(m-ninc)-toyz(n-ninc))*sn(m,kdir,3)
        h4=(fxz(m-ninc)-toxz(n-ninc))*sn(m,kdir,1) &
          +(fyz(m-ninc)-toyz(n-ninc))*sn(m,kdir,2) &
          +(fzz(m-ninc)-tozz(n-ninc))*sn(m,kdir,3)
        h5=(fex(m-ninc)-(toxx(n-ninc)*v(n-ninc,2)+toxy(n-ninc)*v(n-ninc,3)+ &
                   toxz(n-ninc)*v(n-ninc,4))/v(n-ninc,1)-qcx(n-ninc))*sn(m,kdir,1) &
          +(fey(m-ninc)-(toxy(n-ninc)*v(n-ninc,2)+toyy(n-ninc)*v(n-ninc,3)+ &
                      toyz(n-ninc)*v(n-ninc,4))/v(n-ninc,1)-qcy(n-ninc))*sn(m,kdir,2) &
          +(fez(m-ninc)-(toxz(n-ninc)*v(n-ninc,2)+toyz(n-ninc)*v(n-ninc,3)+ &
                   tozz(n-ninc)*v(n-ninc,4))/v(n-ninc,1)-qcz(n-ninc))*sn(m,kdir,3)
        u(n,1)=u(n,1)-h1
        u(n,2)=u(n,2)-h2
        u(n,3)=u(n,3)-h3
        u(n,4)=u(n,4)-h4
        u(n,5)=u(n,5)-h5
       enddo
      enddo
!
      do j=j1,j2m1
       ind1 = indc(i1  ,j,k2m1)
       ind2 = indc(i2m1,j,k2m1)
       do n=ind1,ind2
        m=n-n0c
!       flux a la facette frontiere
        m1=m+ninc
        n1=n+ninc
        h1=v(n1,2)*sn(m1,kdir,1) &
         + v(n1,3)*sn(m1,kdir,2) &
         + v(n1,4)*sn(m1,kdir,3)
        h2=(fxx(m1)-toxx(n1))*sn(m1,kdir,1) &
          +(fxy(m1)-toxy(n1))*sn(m1,kdir,2) &
          +(fxz(m1)-toxz(n1))*sn(m1,kdir,3)
        h3=(fxy(m1)-toxy(n1))*sn(m1,kdir,1) &
          +(fyy(m1)-toyy(n1))*sn(m1,kdir,2) &
          +(fyz(m1)-toyz(n1))*sn(m1,kdir,3)
        h4=(fxz(m1)-toxz(n1))*sn(m1,kdir,1) &
          +(fyz(m1)-toyz(n1))*sn(m1,kdir,2) &
          +(fzz(m1)-tozz(n1))*sn(m1,kdir,3)
        h5=(fex(m1)-(toxx(n1)*v(n1,2)+toxy(n1)*v(n1,3) &
          + toxz(n1)*v(n1,4))/v(n1,1)-qcx(n1))*sn(m1,kdir,1) &
          +(fey(m1)-(toxy(n1)*v(n1,2)+toyy(n1)*v(n1,3) &
          + toyz(n1)*v(n1,4))/v(n1,1)-qcy(n1))*sn(m1,kdir,2) &
          +(fez(m1)-(toxz(n1)*v(n1,2)+toyz(n1)*v(n1,3) &
          + tozz(n1)*v(n1,4))/v(n1,1)-qcz(n1))*sn(m1,kdir,3)
        u(n,1)=u(n,1)+h1
        u(n,2)=u(n,2)+h2
        u(n,3)=u(n,3)+h3
        u(n,4)=u(n,4)+h4
        u(n,5)=u(n,5)+h5
       enddo
      enddo                                  
!
      if(isortie.eq.1) then
       write(6,'("===>sch_weno3: flux direction i")')
       k=1
       i=13
       do j=j1,j2
        n=indc(i,j,k)
        m=n-n0c
       enddo
!
       write(6,'("===>sch_weno3: flux direction j")')
       k=1
       i=13
       do j=j1,j2
        n=indc(i,j,k)
        m=n-n0c
       enddo
!
       write(6,'("===>sch_weno3: increment explicite")')
       k=1
!       i=13
       i=160
       do j=j1,j2m1
        n=indc(i,j,k)
        m=n-n0c
        write(6,'(i4,i6,4(1pe12.4))') &
          j,n,u(n,1),u(n,2),u(n,4),u(n,5)
       enddo
      endif
!
!-----calcul de la forcing function pour le multigrille--------------
!
      if(ityprk.ne.0) then
       do k=k1,k2m1
        do j=j1,j2m1
         ind1=indc(i1,j,k)
         ind2=indc(i2m1,j,k)
         do n=ind1,ind2
          m=n-n0c
          ff(n,1) = ff(n,1) - u(n,1)
          ff(n,2) = ff(n,2) - u(n,2)
          ff(n,3) = ff(n,3) - u(n,3)
          ff(n,4) = ff(n,4) - u(n,4)
          ff(n,5) = ff(n,5) - u(n,5)
         enddo
        enddo
       enddo
      endif

      return
      end
