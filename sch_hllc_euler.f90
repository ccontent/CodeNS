module mod_sch_hllc_euler
  implicit none
contains
  subroutine sch_hllc_euler( &
       lm,ityprk, &
       u,v,ff, &
       equat, &
       sn,lgsnlt, &
       rhol,ul,vl,wl,pl,rhor,ur,vr,wr,prr, &
       ps)
!
!***********************************************************************
!
!_DA  DATE_C : avril 2008 - Eric Goncalves / LEGI
!
!     ACT
!_A    Calcul des bilans de flux physiques. Schéma HLLC.
!_A    Avec extrapolation MUSCL (pour ordre 2 et 3).
!_A    Pas de limiteur de pentes
!
!***********************************************************************
!
    use para_var
    use para_fige
    use maillage
    use proprieteflu
    use schemanum
    implicit none
    integer          ::       i,     i1,   i1m1,   i1p1,     i2
    integer          ::    i2m1,   ind1,   ind2,isortie
    integer          ::  ityprk,      j,     j1,   j1m1,   j1p1
    integer          ::      j2,   j2m1,      k,     k1
    integer          ::    k1m1,   k1p1,     k2,   k2m1
    integer          ::    kdir, lgsnlt,     lm,      m,      n
    integer          ::     n0c,     n1,    nci,    ncj,    nck
    integer          ::     nid,   nijd,   ninc,    njd
    double precision ::                   al,                  am,                  ar,                cnds,                  el
    double precision ::                   er,                 fc1,                 fc2,                 fc3,                 fc4
    double precision ::                  fc5,                 fex,                 fey,                 fez,       ff(ip11,ip60)
    double precision ::                  fxx,                 fxy,                 fxz,                 fyy,                 fyz
    double precision ::                  fzz,                 gc1,                 gc2,                 gc3,                 gc4
    double precision ::                  gc5,                  gd,                 gd1,                 gd2,                 hc1
    double precision ::                  hc2,                 hc3,                 hc4,                 hc5,                  hl
    double precision ::                   hm,                  hr,                 ids,                  nx,                  ny
    double precision ::                   nz,            pl(ip00),           prr(ip00),            ps(ip11),                 pst
    double precision ::                  q2l,                 q2r,              rhoest,          rhol(ip00),                rhom
    double precision ::           rhor(ip00),               rhost,              rhoust,              rhovst,              rhowst
    double precision ::                  si1,                 si2,                 si3,                 si4,                 si5
    double precision ::                  sj1,                 sj2,                 sj3,                 sj4,                 sj5
    double precision ::                  sk1,                 sk2,                 sk3,                 sk4,                 sk5
    double precision ::                   sl,sn(lgsnlt,nind,ndir),                  sr,                 sst,        u(ip11,ip60)
    double precision ::             ul(ip00),                  um,            ur(ip00),        v(ip11,ip60),               vitm2
    double precision ::             vl(ip00),                  vm,                 vnl,                 vnm,                 vnr
    double precision ::             vr(ip00),            wl(ip00),                  wm,            wr(ip00)
!
!-----------------------------------------------------------------------
!
    character(len=7 ) :: equat
!
    isortie=0
!
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
    i1m1=i1-1
    j1m1=j1-1
    k1m1=k1-1
!
    nci = inc(1,0,0)
    ncj = inc(0,1,0)
    nck = inc(0,0,1)
!
!-----calcul des densites de flux convectives -----------------------------
!
    if(equat(3:5).eq.'2dk') then
       ind1 = indc(i1m1,j1m1,k1  )
       ind2 = indc(i2  ,j2  ,k2m1)
    elseif(equat(3:4).eq.'3d') then
       ind1 = indc(i1m1,j1m1,k1m1)
       ind2 = indc(i2  ,j2  ,k2  )
    endif
    do n=ind1,ind2
       m=n-n0c
       u(n,1)=0.
       u(n,2)=0.
       u(n,3)=0.
       u(n,4)=0.
       u(n,5)=0.
    enddo
!
!*******************************************************************************
! calcul du flux numerique par direction suivant les etapes successives :
!    1) evaluation des variables primitives extrapolees
!    2) evaluation des etats "star" et vitesses caracteristiques
!    3) evaluation du flux numerique
!*******************************************************************************
!
!------direction i-------------------------------------------------------
!
    kdir=1
    ninc=nci
!
!-----definition des variables extrapolees--------------------------------
!
    do k=k1,k2m1
       do j=j1,j2m1
          ind1 = indc(i1p1,j,k)
          ind2 = indc(i2m1,j,k)
          do n=ind1,ind2
             m=n-n0c
             rhol(m)=v(n-ninc,1)+0.25*muscl*( &
                  (1.-xk)*(v(n-ninc,1)-v(n-2*ninc,1)) &
                  +(1.+xk)*(v(n     ,1)-v(n-ninc  ,1)))
             ul(m)=v(n-ninc,2)/v(n-ninc,1)+0.25*muscl*( &
                  (1.-xk)*(v(n-ninc,2)/v(n-ninc,1)-v(n-2*ninc,2)/v(n-2*ninc,1)) &
                  +(1.+xk)*(v(n     ,2)/v(n     ,1)-v(n-ninc  ,2)/v(n-ninc  ,1)))
             vl(m)=v(n-ninc,3)/v(n-ninc,1)+0.25*muscl*( &
                  (1.-xk)*(v(n-ninc,3)/v(n-ninc,1)-v(n-2*ninc,3)/v(n-2*ninc,1)) &
                  +(1.+xk)*(v(n     ,3)/v(n     ,1)-v(n-ninc  ,3)/v(n-ninc  ,1)))
             wl(m)=v(n-ninc,4)/v(n-ninc,1)+0.25*muscl*( &
                  (1.-xk)*(v(n-ninc,4)/v(n-ninc,1)-v(n-2*ninc,4)/v(n-2*ninc,1)) &
                  +(1.+xk)*(v(n     ,4)/v(n     ,1)-v(n-ninc  ,4)/v(n-ninc  ,1)))
             pl(m)=ps(n-ninc)+0.25*muscl*( &
                  (1.-xk)*(ps(n-ninc)-ps(n-2*ninc)) &
                  +(1.+xk)*(ps(n     )-ps(n-  ninc)))
!
             rhor(m)=v(n,1)-0.25*muscl*((1.+xk)*(v(n,1)     -v(n-ninc,1)) &
                  +(1.-xk)*(v(n+ninc,1)-v(n     ,1)))
             ur(m)=v(n,2)/v(n,1)-0.25*muscl*( &
                  (1.+xk)*(v(n     ,2)/v(n     ,1)-v(n-ninc,2)/v(n-ninc,1)) &
                  +(1.-xk)*(v(n+ninc,2)/v(n+ninc,1)-v(n     ,2)/v(n     ,1)))
             vr(m)=v(n,3)/v(n,1)-0.25*muscl*( &
                  (1.+xk)*(v(n     ,3)/v(n     ,1)-v(n-ninc,3)/v(n-ninc,1)) &
                  +(1.-xk)*(v(n+ninc,3)/v(n+ninc,1)-v(n     ,3)/v(n     ,1)))
             wr(m)=v(n,4)/v(n,1)-0.25*muscl*( &
                  (1.+xk)*(v(n     ,4)/v(n     ,1)-v(n-ninc,4)/v(n-ninc,1)) &
                  +(1.-xk)*(v(n+ninc,4)/v(n+ninc,1)-v(n     ,4)/v(n     ,1)))
             prr(m)=ps(n)-0.25*muscl*((1.+xk)*(ps(n)     -ps(n-ninc)) &
                  +(1.-xk)*(ps(n+ninc)-ps(n     )))
          enddo
       enddo
    enddo
!
    do k=k1,k2m1
       do j=j1,j2m1
          ind1 = indc(i1p1,j,k)
          ind2 = indc(i2m1,j,k)
          do n=ind1,ind2
             m=n-n0c
!        vecteur normal unitaire a la face consideree
             cnds=sqrt(sn(m,kdir,1)*sn(m,kdir,1)+ &
                  sn(m,kdir,2)*sn(m,kdir,2)+ &
                  sn(m,kdir,3)*sn(m,kdir,3))
             nx=sn(m,kdir,1)/cnds
             ny=sn(m,kdir,2)/cnds
             nz=sn(m,kdir,3)/cnds
!        calcul des etats gauche et droit
             al=sqrt(gam*pl(m)/rhol(m))
             ar=sqrt(gam*prr(m)/rhor(m))
             q2l=ul(m)**2+vl(m)**2+wl(m)**2
             q2r=ur(m)**2+vr(m)**2+wr(m)**2
             hl=al*al/gam1+0.5*q2l
             hr=ar*ar/gam1+0.5*q2r
             el=pl(m)/(gam1*rhol(m))+0.5*q2l+pinfl/rhol(m)
             er=prr(m)/(gam1*rhor(m))+0.5*q2r+pinfl/rhor(m)
             vnl=ul(m)*nx+vl(m)*ny+wl(m)*nz
             vnr=ur(m)*nx+vr(m)*ny+wr(m)*nz
!        calcul des etats moyens de Roe
             gd=sqrt(rhor(m)/rhol(m))
             gd1=1./(1.+gd)
             gd2=gd*gd1
             rhom=sqrt(rhol(m)*rhor(m))
             um=gd1*ul(m)+gd2*ur(m)
             vm=gd1*vl(m)+gd2*vr(m)
             wm=gd1*wl(m)+gd2*wr(m)
             hm=gd1*hl+gd2*hr
             vitm2=0.5*(um**2+vm**2+wm**2)
             am=sqrt(gam1*(hm-vitm2))
             vnm=um*nx+vm*ny+wm*nz
!        calcul des vitesses caracteristiques
             sl=vnm-am
             sr=vnm+am
!        calcul de la vitesse et pression etoile
             sst=(rhor(m)*vnr*(sr-vnr)-rhol(m)*vnl*(sl-vnl)+ &
                  pl(m)-prr(m))/(rhor(m)*(sr-vnr)-rhol(m)*(sl-vnl))
             pst=rhol(m)*(vnl-sl)*(vnl-sst)+pl(m)
!        calcul du flux numerique a l'interface i-1/2
             if(sl.gt.0) then  !supersonique
                fxx=rhol(m)*ul(m)**2+pl(m)-pinfl
                fxy=rhol(m)*ul(m)*vl(m)
                fxz=rhol(m)*ul(m)*wl(m)
                fyy=rhol(m)*vl(m)**2+pl(m)-pinfl
                fyz=rhol(m)*vl(m)*wl(m)
                fzz=rhol(m)*wl(m)**2+pl(m)-pinfl
                fex=(rhol(m)*el+pl(m)-pinfl)*ul(m)
                fey=(rhol(m)*el+pl(m)-pinfl)*vl(m)
                fez=(rhol(m)*el+pl(m)-pinfl)*wl(m)
                fc1=rhol(m)*ul(m)*sn(m,kdir,1) &
                     +rhol(m)*vl(m)*sn(m,kdir,2) &
                     +rhol(m)*wl(m)*sn(m,kdir,3)
                fc2=fxx*sn(m,kdir,1)+fxy*sn(m,kdir,2)+fxz*sn(m,kdir,3)
                fc3=fxy*sn(m,kdir,1)+fyy*sn(m,kdir,2)+fyz*sn(m,kdir,3)
                fc4=fxz*sn(m,kdir,1)+fyz*sn(m,kdir,2)+fzz*sn(m,kdir,3)
                fc5=fex*sn(m,kdir,1)+fey*sn(m,kdir,2)+fez*sn(m,kdir,3)
             elseif(sr.lt.0.) then
                fxx=rhor(m)*ur(m)**2+prr(m)-pinfl
                fxy=rhor(m)*ur(m)*vr(m)
                fxz=rhor(m)*ur(m)*wr(m)
                fyy=rhor(m)*vr(m)**2+prr(m)-pinfl
                fyz=rhor(m)*vr(m)*wr(m)
                fzz=rhor(m)*wr(m)**2+prr(m)-pinfl
                fex=(rhor(m)*er+prr(m)-pinfl)*ur(m)
                fey=(rhor(m)*er+prr(m)-pinfl)*vr(m)
                fez=(rhor(m)*er+prr(m)-pinfl)*wr(m)
                fc1=rhor(m)*ur(m)*sn(m,kdir,1) &
                     +rhor(m)*vr(m)*sn(m,kdir,2) &
                     +rhor(m)*wr(m)*sn(m,kdir,3)
                fc2=fxx*sn(m,kdir,1)+fxy*sn(m,kdir,2)+fxz*sn(m,kdir,3)
                fc3=fxy*sn(m,kdir,1)+fyy*sn(m,kdir,2)+fyz*sn(m,kdir,3)
                fc4=fxz*sn(m,kdir,1)+fyz*sn(m,kdir,2)+fzz*sn(m,kdir,3)
                fc5=fex*sn(m,kdir,1)+fey*sn(m,kdir,2)+fez*sn(m,kdir,3)
             else
                if(sst.ge.0.) then
                   ids=1./(sl-sst)
                   rhost=rhol(m)*(sl-vnl)
                   rhoust=(rhost*ul(m)+(pst-pl(m))*nx)*ids
                   rhovst=(rhost*vl(m)+(pst-pl(m))*ny)*ids
                   rhowst=(rhost*wl(m)+(pst-pl(m))*nz)*ids
                   rhoest=(rhol(m)*el*(sl-vnl)+(pst  -pinfl)*sst &
                        -(pl(m)-pinfl)*vnl)*ids
                   fc1=rhost*ids*sst*cnds
                   fc2=(rhoust*sst+(pst-pinfl)*nx)*cnds
                   fc3=(rhovst*sst+(pst-pinfl)*ny)*cnds
                   fc4=(rhowst*sst+(pst-pinfl)*nz)*cnds
                   fc5=(rhoest+pst-pinfl)*sst*cnds
                elseif(sst.lt.0.) then
                   ids=1./(sr-sst)
                   rhost=rhor(m)*(sr-vnr)
                   rhoust=(rhost*ur(m)+(pst-prr(m))*nx)*ids
                   rhovst=(rhost*vr(m)+(pst-prr(m))*ny)*ids
                   rhowst=(rhost*wr(m)+(pst-prr(m))*nz)*ids
                   rhoest=(rhor(m)*er*(sr-vnr)+(pst  -pinfl)*sst &
                        -(prr(m)-pinfl)*vnr)*ids
                   fc1=rhost*ids*sst*cnds
                   fc2=(rhoust*sst+(pst-pinfl)*nx)*cnds
                   fc3=(rhovst*sst+(pst-pinfl)*ny)*cnds
                   fc4=(rhowst*sst+(pst-pinfl)*nz)*cnds
                   fc5=(rhoest+pst-pinfl)*sst*cnds
                endif
             endif
!        bilan de flux
             u(n,1)=u(n,1)-fc1
             u(n,2)=u(n,2)-fc2
             u(n,3)=u(n,3)-fc3
             u(n,4)=u(n,4)-fc4
             u(n,5)=u(n,5)-fc5
             u(n-ninc,1)=u(n-ninc,1)+fc1
             u(n-ninc,2)=u(n-ninc,2)+fc2
             u(n-ninc,3)=u(n-ninc,3)+fc3
             u(n-ninc,4)=u(n-ninc,4)+fc4
             u(n-ninc,5)=u(n-ninc,5)+fc5
          enddo
       enddo
    enddo
!
    do k=k1,k2m1
       ind1 = indc(i1,j1  ,k)
       ind2 = indc(i1,j2m1,k)
       do n=ind1,ind2,ncj
          m=n-n0c
          n1=n-ninc
          fxx=v(n1,2)*(v(n1,2)/v(n1,1))+ps(n-ninc)-pinfl
          fxy=v(n1,3)*(v(n1,2)/v(n1,1))
          fxz=v(n1,4)*(v(n1,2)/v(n1,1))
          fyy=v(n1,3)*(v(n1,3)/v(n1,1))+ps(n-ninc)-pinfl
          fyz=v(n1,4)*(v(n1,3)/v(n1,1))
          fzz=v(n1,4)*(v(n1,4)/v(n1,1))+ps(n-ninc)-pinfl
          fex=(v(n1,5)+ps(n-ninc)-pinfl)*v(n1,2)/v(n1,1)
          fey=(v(n1,5)+ps(n-ninc)-pinfl)*v(n1,3)/v(n1,1)
          fez=(v(n1,5)+ps(n-ninc)-pinfl)*v(n1,4)/v(n1,1)
!
          si1= v(n-ninc,2)*sn(m,kdir,1) &
               +v(n-ninc,3)*sn(m,kdir,2) &
               +v(n-ninc,4)*sn(m,kdir,3)
          si2= fxx*sn(m,kdir,1) &
               +fxy*sn(m,kdir,2) &
               +fxz*sn(m,kdir,3)
          si3= fxy*sn(m,kdir,1) &
               +fyy*sn(m,kdir,2) &
               +fyz*sn(m,kdir,3)
          si4= fxz*sn(m,kdir,1) &
               +fyz*sn(m,kdir,2) &
               +fzz*sn(m,kdir,3)
          si5= fex*sn(m,kdir,1) &
               +fey*sn(m,kdir,2) &
               +fez*sn(m,kdir,3)
          u(n,1)=u(n,1)-si1
          u(n,2)=u(n,2)-si2
          u(n,3)=u(n,3)-si3
          u(n,4)=u(n,4)-si4
          u(n,5)=u(n,5)-si5
       enddo
    enddo
!
    do k=k1,k2m1
       ind1 = indc(i2,j1  ,k)
       ind2 = indc(i2,j2m1,k)
       do n=ind1,ind2,ncj
          m=n-n0c
          fxx=v(n,2)*(v(n,2)/v(n,1))+ps(n)-pinfl
          fxy=v(n,3)*(v(n,2)/v(n,1))
          fxz=v(n,4)*(v(n,2)/v(n,1))
          fyy=v(n,3)*(v(n,3)/v(n,1))+ps(n)-pinfl
          fyz=v(n,4)*(v(n,3)/v(n,1))
          fzz=v(n,4)*(v(n,4)/v(n,1))+ps(n)-pinfl
          fex=(v(n,5)+ps(n)-pinfl)*v(n,2)/v(n,1)
          fey=(v(n,5)+ps(n)-pinfl)*v(n,3)/v(n,1)
          fez=(v(n,5)+ps(n)-pinfl)*v(n,4)/v(n,1)
!
          si1= v(n,2)*sn(m,kdir,1) &
               +v(n,3)*sn(m,kdir,2) &
               +v(n,4)*sn(m,kdir,3)
          si2= fxx*sn(m,kdir,1) &
               +fxy*sn(m,kdir,2) &
               +fxz*sn(m,kdir,3)
          si3= fxy*sn(m,kdir,1) &
               +fyy*sn(m,kdir,2) &
               +fyz*sn(m,kdir,3)
          si4= fxz*sn(m,kdir,1) &
               +fyz*sn(m,kdir,2) &
               +fzz*sn(m,kdir,3)
          si5= fex*sn(m,kdir,1) &
               +fey*sn(m,kdir,2) &
               +fez*sn(m,kdir,3)
          u(n-ninc,1)=u(n-ninc,1)+si1
          u(n-ninc,2)=u(n-ninc,2)+si2
          u(n-ninc,3)=u(n-ninc,3)+si3
          u(n-ninc,4)=u(n-ninc,4)+si4
          u(n-ninc,5)=u(n-ninc,5)+si5
       enddo
    enddo
!
!------direction j----------------------------------------------
!
    kdir=2
    ninc=ncj
!
    do k=k1,k2m1
       do j=j1p1,j2m1
          ind1 = indc(i1  ,j,k)
          ind2 = indc(i2m1,j,k)
          do n=ind1,ind2
             m=n-n0c
             rhol(m)=v(n-ninc,1)+0.25*muscl*( &
                  (1.-xk)*(v(n-ninc,1)-v(n-2*ninc,1)) &
                  +(1.+xk)*(v(n     ,1)-v(n-ninc  ,1)))
             ul(m)=v(n-ninc,2)/v(n-ninc,1)+0.25*muscl*( &
                  (1.-xk)*(v(n-ninc,2)/v(n-ninc,1)-v(n-2*ninc,2)/v(n-2*ninc,1)) &
                  +(1.+xk)*(v(n     ,2)/v(n     ,1)-v(n-ninc  ,2)/v(n-ninc  ,1)))
             vl(m)=v(n-ninc,3)/v(n-ninc,1)+0.25*muscl*( &
                  (1.-xk)*(v(n-ninc,3)/v(n-ninc,1)-v(n-2*ninc,3)/v(n-2*ninc,1)) &
                  +(1.+xk)*(v(n     ,3)/v(n     ,1)-v(n-ninc  ,3)/v(n-ninc  ,1)))
             wl(m)=v(n-ninc,4)/v(n-ninc,1)+0.25*muscl*( &
                  (1.-xk)*(v(n-ninc,4)/v(n-ninc,1)-v(n-2*ninc,4)/v(n-2*ninc,1)) &
                  +(1.+xk)*(v(n     ,4)/v(n     ,1)-v(n-ninc  ,4)/v(n-ninc  ,1)))
             pl(m)=ps(n-ninc)+0.25*muscl*( &
                  (1.-xk)*(ps(n-ninc)-ps(n-2*ninc)) &
                  +(1.+xk)*(ps(n     )-ps(n-  ninc)))
!
             rhor(m)=v(n,1)-0.25*muscl*((1.+xk)*(v(n,1)     -v(n-ninc,1)) &
                  +(1.-xk)*(v(n+ninc,1)-v(n     ,1)))
             ur(m)=v(n,2)/v(n,1)-0.25*muscl*( &
                  (1.+xk)*(v(n     ,2)/v(n     ,1)-v(n-ninc,2)/v(n-ninc,1)) &
                  +(1.-xk)*(v(n+ninc,2)/v(n+ninc,1)-v(n     ,2)/v(n     ,1)))
             vr(m)=v(n,3)/v(n,1)-0.25*muscl*( &
                  (1.+xk)*(v(n     ,3)/v(n     ,1)-v(n-ninc,3)/v(n-ninc,1)) &
                  +(1.-xk)*(v(n+ninc,3)/v(n+ninc,1)-v(n     ,3)/v(n     ,1)))
             wr(m)=v(n,4)/v(n,1)-0.25*muscl*( &
                  (1.+xk)*(v(n     ,4)/v(n     ,1)-v(n-ninc,4)/v(n-ninc,1)) &
                  +(1.-xk)*(v(n+ninc,4)/v(n+ninc,1)-v(n     ,4)/v(n     ,1)))
             prr(m)=ps(n)-0.25*muscl*((1.+xk)*(ps(n)     -ps(n-ninc)) &
                  +(1.-xk)*(ps(n+ninc)-ps(n     )))
          enddo
       enddo
    enddo
!
    do k=k1,k2m1
       do j=j1p1,j2m1
          ind1 = indc(i1  ,j,k)
          ind2 = indc(i2m1,j,k)
          do n=ind1,ind2
             m=n-n0c
!        vecteur normal unitaire a la face consideree
             cnds=sqrt(sn(m,kdir,1)*sn(m,kdir,1)+ &
                  sn(m,kdir,2)*sn(m,kdir,2)+ &
                  sn(m,kdir,3)*sn(m,kdir,3))
             nx=sn(m,kdir,1)/cnds
             ny=sn(m,kdir,2)/cnds
             nz=sn(m,kdir,3)/cnds
!        calcul des etats gauche et droit
             al=sqrt(gam*pl(m)/rhol(m))
             ar=sqrt(gam*prr(m)/rhor(m))
             q2l=ul(m)**2+vl(m)**2+wl(m)**2
             q2r=ur(m)**2+vr(m)**2+wr(m)**2
             hl=al*al/gam1+0.5*q2l
             hr=ar*ar/gam1+0.5*q2r
             el=pl(m)/(gam1*rhol(m))+0.5*q2l+pinfl/rhol(m)
             er=prr(m)/(gam1*rhor(m))+0.5*q2r+pinfl/rhor(m)
             vnl=ul(m)*nx+vl(m)*ny+wl(m)*nz
             vnr=ur(m)*nx+vr(m)*ny+wr(m)*nz
!        calcul des etats moyens de Roe
             gd=sqrt(rhor(m)/rhol(m))
             gd1=1./(1.+gd)
             gd2=gd*gd1
             rhom=sqrt(rhol(m)*rhor(m))
             um=gd1*ul(m)+gd2*ur(m)
             vm=gd1*vl(m)+gd2*vr(m)
             wm=gd1*wl(m)+gd2*wr(m)
             hm=gd1*hl+gd2*hr
             vitm2=0.5*(um**2+vm**2+wm**2)
             am=sqrt(gam1*(hm-vitm2))
             vnm=um*nx+vm*ny+wm*nz
!        calcul des vitesses caracteristiques
             sl=vnm-am
             sr=vnm+am
!        calcul de la vitesse et pression etoile
             sst=(rhor(m)*vnr*(sr-vnr)-rhol(m)*vnl*(sl-vnl)+ &
                  pl(m)-prr(m))/(rhor(m)*(sr-vnr)-rhol(m)*(sl-vnl))
             pst=rhol(m)*(vnl-sl)*(vnl-sst)+pl(m)
!        calcul du flux numerique a l'interface j-1/2
             if(sl.gt.0) then !supersonique
                fxx=rhol(m)*ul(m)**2+pl(m)-pinfl
                fxy=rhol(m)*ul(m)*vl(m)
                fxz=rhol(m)*ul(m)*wl(m)
                fyy=rhol(m)*vl(m)**2+pl(m)-pinfl
                fyz=rhol(m)*vl(m)*wl(m)
                fzz=rhol(m)*wl(m)**2+pl(m)-pinfl
                fex=(rhol(m)*el+pl(m)-pinfl)*ul(m)
                fey=(rhol(m)*el+pl(m)-pinfl)*vl(m)
                fez=(rhol(m)*el+pl(m)-pinfl)*wl(m)
                gc1=rhol(m)*ul(m)*sn(m,kdir,1) &
                     +rhol(m)*vl(m)*sn(m,kdir,2) &
                     +rhol(m)*wl(m)*sn(m,kdir,3)
                gc2=fxx*sn(m,kdir,1)+fxy*sn(m,kdir,2)+fxz*sn(m,kdir,3)
                gc3=fxy*sn(m,kdir,1)+fyy*sn(m,kdir,2)+fyz*sn(m,kdir,3)
                gc4=fxz*sn(m,kdir,1)+fyz*sn(m,kdir,2)+fzz*sn(m,kdir,3)
                gc5=fex*sn(m,kdir,1)+fey*sn(m,kdir,2)+fez*sn(m,kdir,3)
             elseif(sr.lt.0.) then
                fxx=rhor(m)*ur(m)**2+prr(m)-pinfl
                fxy=rhor(m)*ur(m)*vr(m)
                fxz=rhor(m)*ur(m)*wr(m)
                fyy=rhor(m)*vr(m)**2+prr(m)-pinfl
                fyz=rhor(m)*vr(m)*wr(m)
                fzz=rhor(m)*wr(m)**2+prr(m)-pinfl
                fex=(rhor(m)*er+prr(m)-pinfl)*ur(m)
                fey=(rhor(m)*er+prr(m)-pinfl)*vr(m)
                fez=(rhor(m)*er+prr(m)-pinfl)*wr(m)
                gc1=rhor(m)*ur(m)*sn(m,kdir,1) &
                     +rhor(m)*vr(m)*sn(m,kdir,2) &
                     +rhor(m)*wr(m)*sn(m,kdir,3)
                gc2=fxx*sn(m,kdir,1)+fxy*sn(m,kdir,2)+fxz*sn(m,kdir,3)
                gc3=fxy*sn(m,kdir,1)+fyy*sn(m,kdir,2)+fyz*sn(m,kdir,3)
                gc4=fxz*sn(m,kdir,1)+fyz*sn(m,kdir,2)+fzz*sn(m,kdir,3)
                gc5=fex*sn(m,kdir,1)+fey*sn(m,kdir,2)+fez*sn(m,kdir,3)
             else
                if(sst.ge.0.) then
                   ids=1./(sl-sst)
                   rhost=rhol(m)*(sl-vnl)
                   rhoust=(rhost*ul(m)+(pst-pl(m))*nx)*ids
                   rhovst=(rhost*vl(m)+(pst-pl(m))*ny)*ids
                   rhowst=(rhost*wl(m)+(pst-pl(m))*nz)*ids
                   rhoest=(rhol(m)*el*(sl-vnl)+(pst  -pinfl)*sst &
                        -(pl(m)-pinfl)*vnl)*ids
                   gc1=rhost*ids*sst*cnds
                   gc2=(rhoust*sst+(pst-pinfl)*nx)*cnds
                   gc3=(rhovst*sst+(pst-pinfl)*ny)*cnds
                   gc4=(rhowst*sst+(pst-pinfl)*nz)*cnds
                   gc5=(rhoest+pst-pinfl)*sst*cnds
                elseif(sst.lt.0.) then
                   ids=1./(sr-sst)
                   rhost=rhor(m)*(sr-vnr)
                   rhoust=(rhost*ur(m)+(pst-prr(m))*nx)*ids
                   rhovst=(rhost*vr(m)+(pst-prr(m))*ny)*ids
                   rhowst=(rhost*wr(m)+(pst-prr(m))*nz)*ids
                   rhoest=(rhor(m)*er*(sr-vnr)+(pst  -pinfl)*sst &
                        -(prr(m)-pinfl)*vnr)*ids
                   gc1=rhost*ids*sst*cnds
                   gc2=(rhoust*sst+(pst-pinfl)*nx)*cnds
                   gc3=(rhovst*sst+(pst-pinfl)*ny)*cnds
                   gc4=(rhowst*sst+(pst-pinfl)*nz)*cnds
                   gc5=(rhoest+pst-pinfl)*sst*cnds
                endif
             endif
!        bilan de flux
             u(n,1)=u(n,1)-gc1
             u(n,2)=u(n,2)-gc2
             u(n,3)=u(n,3)-gc3
             u(n,4)=u(n,4)-gc4
             u(n,5)=u(n,5)-gc5
             u(n-ninc,1)=u(n-ninc,1)+gc1
             u(n-ninc,2)=u(n-ninc,2)+gc2
             u(n-ninc,3)=u(n-ninc,3)+gc3
             u(n-ninc,4)=u(n-ninc,4)+gc4
             u(n-ninc,5)=u(n-ninc,5)+gc5
          enddo
       enddo
    enddo
!
    do k=k1,k2m1
       ind1 = indc(i1  ,j1,k)
       ind2 = indc(i2m1,j1,k)
       do n=ind1,ind2
          m=n-n0c
          n1=n-ninc
          fxx=v(n1,2)*(v(n1,2)/v(n1,1))+ps(n-ninc)-pinfl
          fxy=v(n1,3)*(v(n1,2)/v(n1,1))
          fxz=v(n1,4)*(v(n1,2)/v(n1,1))
          fyy=v(n1,3)*(v(n1,3)/v(n1,1))+ps(n-ninc)-pinfl
          fyz=v(n1,4)*(v(n1,3)/v(n1,1))
          fzz=v(n1,4)*(v(n1,4)/v(n1,1))+ps(n-ninc)-pinfl
          fex=(v(n1,5)+ps(n-ninc)-pinfl)*v(n1,2)/v(n,1)
          fey=(v(n1,5)+ps(n-ninc)-pinfl)*v(n1,3)/v(n,1)
          fez=(v(n1,5)+ps(n-ninc)-pinfl)*v(n1,4)/v(n,1)
!
          sj1= v(n-ninc,2)*sn(m,kdir,1) &
               +v(n-ninc,3)*sn(m,kdir,2) &
               +v(n-ninc,4)*sn(m,kdir,3)
          sj2= fxx*sn(m,kdir,1) &
               +fxy*sn(m,kdir,2) &
               +fxz*sn(m,kdir,3)
          sj3= fxy*sn(m,kdir,1) &
               +fyy*sn(m,kdir,2) &
               +fyz*sn(m,kdir,3)
          sj4= fxz*sn(m,kdir,1) &
               +fyz*sn(m,kdir,2) &
               +fzz*sn(m,kdir,3)
          sj5= fex*sn(m,kdir,1) &
               +fey*sn(m,kdir,2) &
               +fez*sn(m,kdir,3)
          u(n,1)=u(n,1)-sj1
          u(n,2)=u(n,2)-sj2
          u(n,3)=u(n,3)-sj3
          u(n,4)=u(n,4)-sj4
          u(n,5)=u(n,5)-sj5
       enddo
    enddo
!
    do k=k1,k2m1
       ind1 = indc(i1  ,j2,k)
       ind2 = indc(i2m1,j2,k)
       do n=ind1,ind2
          m=n-n0c
          fxx=v(n,2)*(v(n,2)/v(n,1))+ps(n)-pinfl
          fxy=v(n,3)*(v(n,2)/v(n,1))
          fxz=v(n,4)*(v(n,2)/v(n,1))
          fyy=v(n,3)*(v(n,3)/v(n,1))+ps(n)-pinfl
          fyz=v(n,4)*(v(n,3)/v(n,1))
          fzz=v(n,4)*(v(n,4)/v(n,1))+ps(n)-pinfl
          fex=(v(n,5)+ps(n)-pinfl)*v(n,2)/v(n,1)
          fey=(v(n,5)+ps(n)-pinfl)*v(n,3)/v(n,1)
          fez=(v(n,5)+ps(n)-pinfl)*v(n,4)/v(n,1)
!
          sj1= v(n,2)*sn(m,kdir,1) &
               +v(n,3)*sn(m,kdir,2) &
               +v(n,4)*sn(m,kdir,3)
          sj2= fxx*sn(m,kdir,1) &
               +fxy*sn(m,kdir,2) &
               +fxz*sn(m,kdir,3)
          sj3= fxy*sn(m,kdir,1) &
               +fyy*sn(m,kdir,2) &
               +fyz*sn(m,kdir,3)
          sj4= fxz*sn(m,kdir,1) &
               +fyz*sn(m,kdir,2) &
               +fzz*sn(m,kdir,3)
          sj5= fex*sn(m,kdir,1) &
               +fey*sn(m,kdir,2) &
               +fez*sn(m,kdir,3)
          u(n-ninc,1)=u(n-ninc,1)+sj1
          u(n-ninc,2)=u(n-ninc,2)+sj2
          u(n-ninc,3)=u(n-ninc,3)+sj3
          u(n-ninc,4)=u(n-ninc,4)+sj4
          u(n-ninc,5)=u(n-ninc,5)+sj5
       enddo
    enddo
!
!c------direction k-------------------------------------------------------
!
    if(equat(3:4).eq.'3d') then
       kdir=3
       ninc=nck
!
       do k=k1p1,k2m1
          do j=j1,j2m1
             ind1 = indc(i1  ,j,k)
             ind2 = indc(i2m1,j,k)
             do n=ind1,ind2
                m=n-n0c
                rhol(m)=v(n-ninc,1)+0.25*muscl*( &
                     (1.-xk)*(v(n-ninc,1)-v(n-2*ninc,1)) &
                     +(1.+xk)*(v(n     ,1)-v(n-ninc  ,1)))
                ul(m)=v(n-ninc,2)/v(n-ninc,1)+0.25*muscl*( &
                     (1.-xk)*(v(n-ninc,2)/v(n-ninc,1)-v(n-2*ninc,2)/v(n-2*ninc,1)) &
                     +(1.+xk)*(v(n     ,2)/v(n     ,1)-v(n-ninc  ,2)/v(n-ninc  ,1)))
                vl(m)=v(n-ninc,3)/v(n-ninc,1)+0.25*muscl*( &
                     (1.-xk)*(v(n-ninc,3)/v(n-ninc,1)-v(n-2*ninc,3)/v(n-2*ninc,1)) &
                     +(1.+xk)*(v(n     ,3)/v(n     ,1)-v(n-ninc  ,3)/v(n-ninc  ,1)))
                wl(m)=v(n-ninc,4)/v(n-ninc,1)+0.25*muscl*( &
                     (1.-xk)*(v(n-ninc,4)/v(n-ninc,1)-v(n-2*ninc,4)/v(n-2*ninc,1)) &
                     +(1.+xk)*(v(n     ,4)/v(n     ,1)-v(n-ninc  ,4)/v(n-ninc  ,1)))
                pl(m)=ps(n-ninc)+0.25*muscl*( &
                     (1.-xk)*(ps(n-ninc)-ps(n-2*ninc)) &
                     +(1.+xk)*(ps(n     )-ps(n-  ninc)))
!
                rhor(m)=v(n,1)-0.25*muscl*((1.+xk)*(v(n,1)     -v(n-ninc,1)) &
                     +(1.-xk)*(v(n+ninc,1)-v(n     ,1)))
                ur(m)=v(n,2)/v(n,1)-0.25*muscl*( &
                     (1.+xk)*(v(n     ,2)/v(n     ,1)-v(n-ninc,2)/v(n-ninc,1)) &
                     +(1.-xk)*(v(n+ninc,2)/v(n+ninc,1)-v(n     ,2)/v(n     ,1)))
                vr(m)=v(n,3)/v(n,1)-0.25*muscl*( &
                     (1.+xk)*(v(n     ,3)/v(n     ,1)-v(n-ninc,3)/v(n-ninc,1)) &
                     +(1.-xk)*(v(n+ninc,3)/v(n+ninc,1)-v(n     ,3)/v(n     ,1)))
                wr(m)=v(n,4)/v(n,1)-0.25*muscl*( &
                     (1.+xk)*(v(n     ,4)/v(n     ,1)-v(n-ninc,4)/v(n-ninc,1)) &
                     +(1.-xk)*(v(n+ninc,4)/v(n+ninc,1)-v(n     ,4)/v(n     ,1)))
                prr(m)=ps(n)-0.25*muscl*((1.+xk)*(ps(n)     -ps(n-ninc)) &
                     +(1.-xk)*(ps(n+ninc)-ps(n     )))
             enddo
          enddo
       enddo
!
       do k=k1p1,k2m1
          do j=j1,j2m1
             ind1 = indc(i1,j,k)
             ind2 = indc(i2m1,j,k)
             do n=ind1,ind2
                m=n-n0c
!        vecteur normal unitaire a la face consideree
                cnds=sqrt(sn(m,kdir,1)*sn(m,kdir,1)+ &
                     sn(m,kdir,2)*sn(m,kdir,2)+ &
                     sn(m,kdir,3)*sn(m,kdir,3))
                nx=sn(m,kdir,1)/cnds
                ny=sn(m,kdir,2)/cnds
                nz=sn(m,kdir,3)/cnds
!        calcul des etats gauche et droit
                al=sqrt(gam*pl(m)/rhol(m))
                ar=sqrt(gam*prr(m)/rhor(m))
                q2l=ul(m)**2+vl(m)**2+wl(m)**2
                q2r=ur(m)**2+vr(m)**2+wr(m)**2
                hl=al*al/gam1+0.5*q2l
                hr=ar*ar/gam1+0.5*q2r
                el=pl(m)/(gam1*rhol(m))+0.5*q2l+pinfl/rhol(m)
                er=prr(m)/(gam1*rhor(m))+0.5*q2r+pinfl/rhor(m)
                vnl=ul(m)*nx+vl(m)*ny+wl(m)*nz
                vnr=ur(m)*nx+vr(m)*ny+wr(m)*nz
!        calcul des etats moyens de Roe
                gd=sqrt(rhor(m)/rhol(m))
                gd1=1./(1.+gd)
                gd2=gd*gd1
                rhom=sqrt(rhol(m)*rhor(m))
                um=gd1*ul(m)+gd2*ur(m)
                vm=gd1*vl(m)+gd2*vr(m)
                wm=gd1*wl(m)+gd2*wr(m)
                hm=gd1*hl+gd2*hr
                vitm2=0.5*(um**2+vm**2+wm**2)
                am=sqrt(gam1*(hm-vitm2))
                vnm=um*nx+vm*ny+wm*nz
!        calcul des vitesses caracteristiques
                sl=vnm-am
                sr=vnm+am
!        calcul de la vitesse et pression etoile
                sst=(rhor(m)*vnr*(sr-vnr)-rhol(m)*vnl*(sl-vnl)+ &
                     pl(m)-prr(m))/(rhor(m)*(sr-vnr)-rhol(m)*(sl-vnl))
                pst=rhol(m)*(vnl-sl)*(vnl-sst)+pl(m)
!        calcul du flux numerique a l'interface k-1/2
                if(sl.gt.0) then
                   fxx=rhol(m)*ul(m)**2+pl(m)-pinfl
                   fxy=rhol(m)*ul(m)*vl(m)
                   fxz=rhol(m)*ul(m)*wl(m)
                   fyy=rhol(m)*vl(m)**2+pl(m)-pinfl
                   fyz=rhol(m)*vl(m)*wl(m)
                   fzz=rhol(m)*wl(m)**2+pl(m)-pinfl
                   fex=(rhol(m)*el+pl(m)-pinfl)*ul(m)
                   fey=(rhol(m)*el+pl(m)-pinfl)*vl(m)
                   fez=(rhol(m)*el+pl(m)-pinfl)*wl(m)
                   hc1=rhol(m)*ul(m)*sn(m,kdir,1) &
                        +rhol(m)*vl(m)*sn(m,kdir,2) &
                        +rhol(m)*wl(m)*sn(m,kdir,3)
                   hc2=fxx*sn(m,kdir,1)+fxy*sn(m,kdir,2)+fxz*sn(m,kdir,3)
                   hc3=fxy*sn(m,kdir,1)+fyy*sn(m,kdir,2)+fyz*sn(m,kdir,3)
                   hc4=fxz*sn(m,kdir,1)+fyz*sn(m,kdir,2)+fzz*sn(m,kdir,3)
                   hc5=fex*sn(m,kdir,1)+fey*sn(m,kdir,2)+fez*sn(m,kdir,3)
                elseif(sr.lt.0.) then
                   fxx=rhor(m)*ur(m)**2+prr(m)-pinfl
                   fxy=rhor(m)*ur(m)*vr(m)
                   fxz=rhor(m)*ur(m)*wr(m)
                   fyy=rhor(m)*vr(m)**2+prr(m)-pinfl
                   fyz=rhor(m)*vr(m)*wr(m)
                   fzz=rhor(m)*wr(m)**2+prr(m)-pinfl
                   fex=(rhor(m)*er+prr(m)-pinfl)*ur(m)
                   fey=(rhor(m)*er+prr(m)-pinfl)*vr(m)
                   fez=(rhor(m)*er+prr(m)-pinfl)*wr(m)
                   hc1=rhor(m)*ur(m)*sn(m,kdir,1) &
                        +rhor(m)*vr(m)*sn(m,kdir,2) &
                        +rhor(m)*wr(m)*sn(m,kdir,3)
                   hc2=fxx*sn(m,kdir,1)+fxy*sn(m,kdir,2)+fxz*sn(m,kdir,3)
                   hc3=fxy*sn(m,kdir,1)+fyy*sn(m,kdir,2)+fyz*sn(m,kdir,3)
                   hc4=fxz*sn(m,kdir,1)+fyz*sn(m,kdir,2)+fzz*sn(m,kdir,3)
                   hc5=fex*sn(m,kdir,1)+fey*sn(m,kdir,2)+fez*sn(m,kdir,3)
                else
                   if(sst.ge.0.) then
                      ids=1./(sl-sst)
                      rhost=rhol(m)*(sl-vnl)
                      rhoust=(rhost*ul(m)+(pst-pl(m))*nx)*ids
                      rhovst=(rhost*vl(m)+(pst-pl(m))*ny)*ids
                      rhowst=(rhost*wl(m)+(pst-pl(m))*nz)*ids
                      rhoest=(rhol(m)*el*(sl-vnl)+(pst  -pinfl)*sst &
                           -(pl(m)-pinfl)*vnl)*ids
                      hc1=rhost*ids*sst*cnds
                      hc2=(rhoust*sst+(pst-pinfl)*nx)*cnds
                      hc3=(rhovst*sst+(pst-pinfl)*ny)*cnds
                      hc4=(rhowst*sst+(pst-pinfl)*nz)*cnds
                      hc5=(rhoest+pst-pinfl)*sst*cnds
                   elseif(sst.lt.0.) then
                      ids=1./(sr-sst)
                      rhost=rhor(m)*(sr-vnr)
                      rhoust=(rhost*ur(m)+(pst-prr(m))*nx)*ids
                      rhovst=(rhost*vr(m)+(pst-prr(m))*ny)*ids
                      rhowst=(rhost*wr(m)+(pst-prr(m))*nz)*ids
                      rhoest=(rhor(m)*er*(sr-vnr)+(pst  -pinfl)*sst &
                           -(prr(m)-pinfl)*vnr)*ids
                      hc1=rhost*ids*sst*cnds
                      hc2=(rhoust*sst+(pst-pinfl)*nx)*cnds
                      hc3=(rhovst*sst+(pst-pinfl)*ny)*cnds
                      hc4=(rhowst*sst+(pst-pinfl)*nz)*cnds
                      hc5=(rhoest+pst-pinfl)*sst*cnds
                   endif
                endif
!        bilan de flux
                u(n,1)=u(n,1)-hc1
                u(n,2)=u(n,2)-hc2
                u(n,3)=u(n,3)-hc3
                u(n,4)=u(n,4)-hc4
                u(n,5)=u(n,5)-hc5
                u(n-ninc,1)=u(n-ninc,1)+hc1
                u(n-ninc,2)=u(n-ninc,2)+hc2
                u(n-ninc,3)=u(n-ninc,3)+hc3
                u(n-ninc,4)=u(n-ninc,4)+hc4
                u(n-ninc,5)=u(n-ninc,5)+hc5
             enddo
          enddo
       enddo
!
       do j=j1,j2m1
          ind1 = indc(i1  ,j,k1)
          ind2 = indc(i2m1,j,k1)
          do n=ind1,ind2
             m=n-n0c
             n1=n-ninc
             fxx=v(n1,2)*(v(n1,2)/v(n1,1))+ps(n-ninc)-pinfl
             fxy=v(n1,3)*(v(n1,2)/v(n1,1))
             fxz=v(n1,4)*(v(n1,2)/v(n1,1))
             fyy=v(n1,3)*(v(n1,3)/v(n1,1))+ps(n-ninc)-pinfl
             fyz=v(n1,4)*(v(n1,3)/v(n1,1))
             fzz=v(n1,4)*(v(n1,4)/v(n1,1))+ps(n-ninc)-pinfl
             fex=(v(n1,5)+ps(n-ninc)-pinfl)*v(n1,2)/v(n,1)
             fey=(v(n1,5)+ps(n-ninc)-pinfl)*v(n1,3)/v(n,1)
             fez=(v(n1,5)+ps(n-ninc)-pinfl)*v(n1,4)/v(n,1)
!
             sk1= v(n-ninc,2)*sn(m,kdir,1) &
                  +v(n-ninc,3)*sn(m,kdir,2) &
                  +v(n-ninc,4)*sn(m,kdir,3)
             sk2= fxx*sn(m,kdir,1) &
                  +fxy*sn(m,kdir,2) &
                  +fxz*sn(m,kdir,3)
             sk3= fxy*sn(m,kdir,1) &
                  +fyy*sn(m,kdir,2) &
                  +fyz*sn(m,kdir,3)
             sk4= fxz*sn(m,kdir,1) &
                  +fyz*sn(m,kdir,2) &
                  +fzz*sn(m,kdir,3)
             sk5= fex*sn(m,kdir,1) &
                  +fey*sn(m,kdir,2) &
                  +fez*sn(m,kdir,3)
             u(n,1)=u(n,1)-sk1
             u(n,2)=u(n,2)-sk2
             u(n,3)=u(n,3)-sk3
             u(n,4)=u(n,4)-sk4
             u(n,5)=u(n,5)-sk5
          enddo
       enddo
!
       do j=j1,j2m1
          ind1 = indc(i1  ,j,k2)
          ind2 = indc(i2m1,j,k2)
          do n=ind1,ind2
             m=n-n0c
             fxx=v(n,2)*(v(n,2)/v(n,1))+ps(n)-pinfl
             fxy=v(n,3)*(v(n,2)/v(n,1))
             fxz=v(n,4)*(v(n,2)/v(n,1))
             fyy=v(n,3)*(v(n,3)/v(n,1))+ps(n)-pinfl
             fyz=v(n,4)*(v(n,3)/v(n,1))
             fzz=v(n,4)*(v(n,4)/v(n,1))+ps(n)-pinfl
             fex=(v(n,5)+ps(n)-pinfl)*v(n,2)/v(n,1)
             fey=(v(n,5)+ps(n)-pinfl)*v(n,3)/v(n,1)
             fez=(v(n,5)+ps(n)-pinfl)*v(n,4)/v(n,1)
!
             sk1= v(n,2)*sn(m,kdir,1) &
                  +v(n,3)*sn(m,kdir,2) &
                  +v(n,4)*sn(m,kdir,3)
             sk2= fxx*sn(m,kdir,1) &
                  +fxy*sn(m,kdir,2) &
                  +fxz*sn(m,kdir,3)
             sk3= fxy*sn(m,kdir,1) &
                  +fyy*sn(m,kdir,2) &
                  +fyz*sn(m,kdir,3)
             sk4= fxz*sn(m,kdir,1) &
                  +fyz*sn(m,kdir,2) &
                  +fzz*sn(m,kdir,3)
             sk5= fex*sn(m,kdir,1) &
                  +fey*sn(m,kdir,2) &
                  +fez*sn(m,kdir,3)
             u(n-ninc,1)=u(n-ninc,1)+sk1
             u(n-ninc,2)=u(n-ninc,2)+sk2
             u(n-ninc,3)=u(n-ninc,3)+sk3
             u(n-ninc,4)=u(n-ninc,4)+sk4
             u(n-ninc,5)=u(n-ninc,5)+sk5
          enddo
       enddo
    endif
!
    if(isortie.eq.1) then
       write(6,'("===>sch_hllc_euler: ecriture increment expli")')
       k=1
       i=80
       do j=j1,j2m1
          n=indc(i,j,k)
          m=n-n0c
          write(6,'(i4,i6,4(1pe12.4))') &
               j,n,u(n,1),u(n,2),u(n,4),u(n,5)
       enddo
    endif
!
!-----calcul de la 'forcing function'---------------------------
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
  contains
    function    indc(i,j,k)
      implicit none
      integer          ::    i,indc,   j,   k
      indc=n0c+1+(i-id1(lm))+(j-jd1(lm))*nid+(k-kd1(lm))*nijd
    end function indc
    function    inc(id,jd,kd)
      implicit none
      integer          ::  id,inc, jd, kd
      inc=id+jd*nid+kd*nijd
    end function inc

  end subroutine sch_hllc_euler
end module mod_sch_hllc_euler
