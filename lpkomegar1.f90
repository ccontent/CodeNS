      subroutine lpkomegar1( &
                 v,mu,mut,dist, &
                 nxn,nyn,nzn, &
                 ncin,ncbd,mfb,l, &
                 mnpar,fgam,tprod, &
                 dvxx,dvxy,dvxz,dvyx,dvyy,dvyz,dvzx,dvzy,dvzz, &
                 temp)
!
!***********************************************************************
!
!_DA  DATE_C : juin 2002 - AUTEUR : Eric Goncalves / SINUMEF
!
!     ACT
!_A    Lois de paroi : modele k-omega de Kok et Menter avec
!_A    conditions de realisabilite de Durbin.
!_A    - parois adiabatiques
!_A    - production de k imposee a la paroi
!_A    - omega imposee a la paroi
!
!
!-----parameters figes--------------------------------------------------
!
      use para_var
      use para_fige
      use maillage
      use boundary
      use proprieteflu
      use definition
      use modeleturb
!
!-----------------------------------------------------------------------
!
      logical lamin
      real mu,mut,mup,sv,ss,alpha
      real nxn,nyn,nzn,n1,n2,n3
!
      dimension mu(ip12),mut(ip12)
      dimension nxn(ip42),nyn(ip42),nzn(ip42)
      dimension ncin(ip41),ncbd(ip41)
      dimension v(ip11,ip60),dist(ip12)
      dimension mnpar(ip12),fgam(ip42)
      dimension tprod(ip00)
      dimension dvxx(ip00),dvxy(ip00),dvxz(ip00), &
                dvyx(ip00),dvyy(ip00),dvyz(ip00), &
                dvzx(ip00),dvzy(ip00),dvzz(ip00)
      dimension temp(ip11)
!
      cmu1=1./sqrt(0.09)
      cmu2=1./(0.09**0.75)
      cmu3=0.09**0.25
      sv=110.4/tnz !air

      mt=mmb(mfb)
      m0ns=mpn(mfb)
      n0c=npc(l)
!
!       boucle sur les facettes d'une frontiere paroi
        do m=1,mt
          mb=mpb(mfb)+m
          ni=ncin(mb)
          nc=ncbd(mb)
          nfacns=m0ns+m
          nii=ni-n0c
          mpar=mnpar(ni)
!         test sur transition et regime d'ecoulement
          if((fgam(mpar).lt.1.e-3).and.(ktransi.gt.0)) then
!           laminaire
            lamin=.true.
          else
!           turbulent
            lamin=.false.
          endif
!         vitesse cellule adjacente a la paroi (cellule 1)
          v1x=v(ni,2)/v(ni,1)
          v1y=v(ni,3)/v(ni,1)
          v1z=v(ni,4)/v(ni,1)
!         normale a la paroi
          n1=nxn(nfacns)
          n2=nyn(nfacns)
          n3=nzn(nfacns)
!         tangente normee a la paroi
          tn=v1x*n1+v1y*n2+v1z*n3
          t1=v1x-tn*n1
          t2=v1y-tn*n2
          t3=v1z-tn*n3
          tt=sqrt(t1**2+t2**2+t3**2)
          t1=t1/tt
          t2=t2/tt
          t3=t3/tt
!         composante tangentielle de la vitesse dans repere paroi : v1t
          v1t=v1x*t1+v1y*t2+v1z*t3
!         temperature cellule 1 : temp1
          temp1=temp(ni)
!         temperature a la paroi : tparoi
          pka=cp*(mu(ni)/pr+mut(ni)/prt)
          pkb=mu(ni)+mut(ni)
          tparoi=temp1+0.5*pkb*v1t**2/pka
!         viscosite moleculaire a la paroi
          mup=mu(ni)*sqrt(tparoi/temp1)*(1.+sv/temp1)/(1.+sv/tparoi)
!         masse volumique a la paroi
          rop=v(ni,1)*temp1/tparoi
!         correction de compressibilite (loi de Van Driest)
          co=sqrt(2.*pka*tparoi/pkb)
          v1t=co*asin(v1t/co)
!         contrainte de frottement a la paroi : top
          upyp1=rop*v1t*dist(ni)/mup
          yp02=yp0**2
!         loi standard
          if(upyp1.le.yp02 .or. lamin) then
!           loi lineaire
            top=mup*v1t/dist(ni)
          else
!           loi logarithmique
            top=mup*v1t/dist(ni)
            do iter=1,10
              top=rop*v1t**2/(log(dist(ni)*sqrt(rop*top)/mup)/vkar+cllog)**2
            enddo
          endif
!
!          if(lamin) then
!          loi lineaire
!           top=mup*v1t/dist(ni)
!          else
!          loi de Spalding
!           top=mup*v1t/dist(ni)
!           upl=v1t*sqrt(rop/top)
!           do jj=1,15
!            fu=rop*dist(ni)*v1t/(mup*upl) - upl - exp(-vkar*cllog)*
!     &        (exp(vkar*upl) -1. -vkar*upl - 0.5*(vkar*upl)**2 -
!     &          ((vkar*upl)**3)/6.)
!            dfu=-rop*dist(ni)*v1t/(mup*upl**2)-1.-exp(-vkar*cllog)*
!     &          vkar*(exp(vkar*upl) -1. -vkar*upl - 0.5*(vkar*upl)**2)
!            upl=upl-fu/dfu
!           enddo
!          endif
!          top=rop*(v1t/upl)**2
!         vitesse de frottement : uto
          uto=sqrt(top/rop)
!         calcul de la production de k -> valeur moyenne sur la cellule adjacente
          ye=2.*dist(ni)
          yv=5.*mup/(rop*uto)
          prodk=top**1.5*log(ye/yv)/(ye*vkar*sqrt(rop))
!         calcul de omega = k^0.5/cmu*l_eps
          retur=sqrt(rop*v(ni,6))*dist(ni)/mu(ni)
          echleps=vkar*cmu3*dist(ni)*(1.-exp(-retur/(2.*vkar*cmu2)))
          omega=sqrt(v(ni,6)/v(ni,1))/echleps
          v(ni,7)=max(v(ni,1)*omega,epse)
          v(nc,7)=v(ni,7)
!         realisabilite
          ss=v(ni,1)*sqrt(4.*(dvxx(nii)**2+dvyy(nii)**2+dvzz(nii)**2)/3. &
             + (dvzy(nii)+dvyz(nii))**2 + (dvxz(nii)+dvzx(nii))**2 &
             + (dvyx(nii)+dvxy(nii))**2)/v(ni,7)
          alpha=amin1(1.,cmu1/ss)              !correspond a c=0.52
          tprod(nii)=prodk*alpha
!          tprod(nii)=prodk
          if(dist(ni).lt.yv) tprod(nii)=0.
        enddo
!
      return
      end

