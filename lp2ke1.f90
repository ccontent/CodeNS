      subroutine lp2ke1( &
                v,mu,mut,dist, &
                nxn,nyn,nzn, &
                ncin,ncbd,mfb,l, &
                vol,sn,ncyc, &
                mnpar,fgam,  &        
                tprod,utau,  &
                dpdx,dpdy,dpdz, &
                ps,temp)      
!
!***********************************************************************
!
!_DA  DATE_C : mars 2011 -- AUTEUR : Eric Goncalves / LEGI
!
!     ACT
!_A    Lois de paroi, modele k-e de Jones-Launder, parois adiabatiques
!_A    - la production de k est imposee a la paroi
!_A    - la dissipation epsilon est imposee a la paroi
!_A
!
!_I    mmb        : com int (mtt       ) ; nombre de facettes d'une frontiere
!_I    mpb        : com int (mtt       ) ; pointeur fin de front precedente
!_I                                        dans tableaux de base des front.
!_I    nba        : com int (mtb       ) ; rang de traitement d'une front
!_I    ndlb       : com int (mtb       ) ; numero dom contenant la frontiere
!_I    mpn        : com int (mtt       ) ; pointeur fin de front precedente
!_I                                        dans tab front a normales stockees
!_I    nbd        : com int              ; nombre de frontieres a traiter
!_I    lbd        : com int (mtt       ) ; numero de front a traiter
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
implicit none
double precision :: v
double precision :: dist
integer :: ncin
integer :: ncbd
integer :: mfb
integer :: l
double precision :: vol
double precision :: sn
integer :: ncyc
integer :: mnpar
double precision :: fgam
double precision :: tprod
double precision :: utau
double precision :: dpdx
double precision :: dpdy
double precision :: dpdz
double precision :: ps
double precision :: temp
double precision :: ca
double precision :: cklb2
double precision :: cklb3
double precision :: cmu2
double precision :: coefa
double precision :: coefb
double precision :: coefc
double precision :: coefc1
double precision :: coefp
double precision :: conv
double precision :: cste
double precision :: ctk
double precision :: ctmu
double precision :: ctmu2
double precision :: dconv
double precision :: dist2
double precision :: dnum
double precision :: dpc
double precision :: dpdt
double precision :: dy
double precision :: echleps
double precision :: eps
double precision :: f1i
double precision :: fmui
double precision :: fxi
integer :: ij
integer :: in
integer :: iter
integer :: j
integer :: kk
integer :: lgsnlt
integer :: m
integer :: m0ns
integer :: mb
integer :: mpar
integer :: mt
integer :: n0c
integer :: nc
integer :: ndis
integer :: nfacns
integer :: ni
integer :: nii
integer :: nn
integer :: npsn
integer :: ntab
double precision :: retur
double precision :: rhoi
double precision :: rk2
double precision :: rok2
double precision :: rop
double precision :: som1
double precision :: som2
double precision :: som3
double precision :: t1
double precision :: t2
double precision :: t3
double precision :: tn
double precision :: top
double precision :: top0
double precision :: topar
double precision :: topini
double precision :: tt
double precision :: upyp1
double precision :: v1t
double precision :: v1x
double precision :: v1y
double precision :: v1z
double precision :: xi
double precision :: yi
double precision :: yp02
!
!-----------------------------------------------------------------------
!
      parameter( ntab=50  )
      logical lamin
      real mu,mut,mup,sv,nxn,nyn,nzn
      real ki,li,dtop,seuil
!
      dimension mu(ip12),mut(ip12)
      dimension nxn(ip42),nyn(ip42),nzn(ip42)
      dimension ncin(ip41),ncbd(ip41)
      dimension v(ip11,ip60),dist(ip12)
      dimension mnpar(ip12),fgam(ip42),utau(ip42)
      dimension temp(ip11),vol(ip11),ps(ip11)
      dimension sn(ip31*ndir)
      dimension tprod(ip00),dpdx(ip00),dpdy(ip00),dpdz(ip00)       
!      
      DOUBLE PRECISION,DIMENSION(:),ALLOCATABLE :: alfaa,betaa,ff,vit,mui,muti,tempi,topc
      ALLOCATE(alfaa(ntab),betaa(ntab),ff(ntab),topc(2), &
            vit(ntab),mui(ntab),muti(ntab),tempi(ntab))
   
!      ndis=20
      ndis=30
      dtop=0.001
!      seuil=1.e-6
      seuil=1.e-7
      sv=110.4/tnz !air
!
!     constantes du calcul
      cmu2=1./(cmu**0.75)
      cklb2=18.**(4./3.)
      cklb3=18.**(1./3.)
      coefp=5.72/(vkar**2*18.)
      cste=25.5**4
!
      mt=mmb(mfb)  
      m0ns=mpn(mfb)
      n0c=npc(l)
!     
!     mise a zero des tableaux
      do in=1,ntab
        alfaa(in)=0.
        betaa(in)=0.
        vit(in)=0.
        tempi(in)=0.
      end do  
!
!--------------------------------------------------------------
!-----initialisation de utau-----------------------------------
      if(ncyc.eq.icytur0) then 
!      boucle sur les facettes d'une frontiere paroi
       do m=1,mt
        mb=mpb(mfb)+m
        ni=ncin(mb)
        nc=ncbd(mb)
        nfacns=m0ns+m
        mpar=mnpar(ni)
!       test sur transition et regime d'ecoulement
        if((fgam(mpar).lt.1.e-3).and.(ktransi.gt.0)) then
!         laminaire
          lamin=.true.
        else
!         turbulent
          lamin=.false.
        endif
!       vitesse cellule 1
        v1x=v(ni,2)/v(ni,1)
        v1y=v(ni,3)/v(ni,1)
        v1z=v(ni,4)/v(ni,1)
!       tangente normee a la paroi     
        tn=v1x*nxn(nfacns)+v1y*nyn(nfacns)+v1z*nzn(nfacns)
        t1=v1x-tn*nxn(nfacns)
        t2=v1y-tn*nyn(nfacns)
        t3=v1z-tn*nzn(nfacns)
        tt=sqrt(t1**2+t2**2+t3**2)
        t1=t1/tt
        t2=t2/tt
        t3=t3/tt
!       composante tangentielle de la vitesse dans repere paroi : v1t
        v1t=v1x*t1+v1y*t2+v1z*t3
!       masse volumique a la paroi
        rop=v(ni,1)*temp(ni)/temp(nc)
!       viscosite moleculaire a la paroi
        mup=mu(ni)*sqrt(temp(nc)/temp(ni))*(1.+sv/temp(ni))/(1.+sv/temp(nc))
!       contrainte de frottement a la paroi : top
        upyp1=rop*v1t*dist(ni)/mup
        yp02=yp0**2
        if(upyp1.le.yp02 .or. lamin) then
!        loi lineaire
         top=mup*v1t/dist(ni)
        else
!        loi logarithmique
         top=mup*v1t/dist(ni)
         do iter=1,10
          top=rop*v1t**2/(log(dist(ni)*sqrt(rop*top)/mup)/vkar+cllog)**2
         enddo
        endif
        utau(nfacns)=sign(1.,top)*sqrt(abs(top)/rop) 
       enddo !fin boucle sur facettes paroi
      endif
!-----fin initialisation de utau--------------------------------
!---------------------------------------------------------------
!
!     calcul du terme de derivee de la pression dp/dx a la paroi
      npsn=ndir*npfb(l)+1
      lgsnlt=nnn(l)
       call pgrad( &
          sn(npsn),vol,lgsnlt,l, &
          ps,dpdx,dpdy,dpdz)
!
!     boucle sur les facettes parois
      do m=1,mt
        mb=mpb(mfb)+m
        ni=ncin(mb)
        nc=ncbd(mb)       
        nii=ni-n0c    
        nfacns=m0ns+m
        mpar=mnpar(ni)
!       vitesse cellule 1
        v1x=v(ni,2)/v(ni,1)
        v1y=v(ni,3)/v(ni,1)
        v1z=v(ni,4)/v(ni,1)
!       tangente normee a la paroi     
        tn=v1x*nxn(nfacns)+v1y*nyn(nfacns)+v1z*nzn(nfacns)
        t1=v1x-tn*nxn(nfacns)
        t2=v1y-tn*nyn(nfacns)
        t3=v1z-tn*nzn(nfacns)
        tt=sqrt(t1**2+t2**2+t3**2)
        t1=t1/tt
        t2=t2/tt
        t3=t3/tt
!       composante tangentielle de la vitesse dans repere paroi : v1t     
        v1t=v1x*t1+v1y*t2+v1z*t3
!       masse volumique a la paroi
        rop=v(ni,1)*temp(ni)/temp(nc)
!       terme de derivee de pression (dp/dt) a la paroi
        dpdt=dpdx(nii)*t1 + dpdy(nii)*t2 + dpdz(nii)*t3
!       calcul coefficients intermediaires
        coefc1=-cklb2*coefp*dpdt**2
        rk2=v(ni,6)**2
        dist2=dist(ni)**2
        dpc=dist(ni)**(sqrt(coefp))
!       calcul du top a partir de utau
        topar=rop*utau(nfacns)*abs(utau(nfacns))
!       calcul echelle de longueur l
        v(ni,7)=cklb3*cmu*v(ni,6)**1.5/(v(ni,7)*sqrt(2.*v(ni,1)))
!       distance
        dy=dist(ni)/(ndis-1)
!**************************************************************************
!--------boucle Newton sur top--------------------------------------------- 
!***************************************************************************
        dconv=1.
        do while (dconv.gt.seuil) 
          top0=topar
!         boucle pour calculer la derivee de la fonction pour le Newton    
          do kk=1,2
           topini=topar 
           conv=1.            
           coefa=-cklb2*coefp*topar**2
           coefb=-2.*cklb2*coefp*topar*dpdt
           coefc=coefc1+4.*rk2/dist2
           ca=(4.*rk2+coefa/coefp-coefb*dist(ni)/(1.-coefp) &
                 -coefc*dist2/(4.-coefp)-4.*rk2/(4.-coefp))/dpc
!          viscosite a la paroi 
           mup=mu(ni)
!          balayage pour calculet muti
           do nn=2,ndis
            yi=(nn-1)*dy
            mui(nn)=mu(ni)
!           test sur la transition 
            if((fgam(mpar).lt.1.e-3).and.(ktransi.gt.0)) then
              muti(nn)=0.
            else    
             rhoi=v(ni,1)
             rok2=ca*yi**(sqrt(coefp))-coefa/coefp+coefb*yi/ &
                (1.-coefp)+coefc*yi**2/(4.-coefp) + 4.*rk2*yi**2/(dist2*(4.-coefp))
             ki=sqrt(rok2)/(2.*rhoi)
             li=vkar*yi+(v(ni,7)/v(ni,1)-vkar*dist(ni))*(yi**2/dist2)  
             xi=rhoi*sqrt(2.*ki)*li/(mui(nn)*cklb3)
             f1i=exp(-50.*(li/(vkar*yi))**2)
             fxi=xi**2*(4.+xi**2)
             fmui=((cste*f1i+fxi)/(cste+fxi))**0.25
             muti(nn)=mui(nn)*xi*fmui 
            endif  
            ff(nn)=muti(nn)/(mui(nn)+muti(nn))**2  
           end do 
!--------------------------------------------------------------- 
!         integration de la vitesse
!--------------------------------------------------------------       
!         initialisation du calcul
          vit(1)=0.
          vit(ndis)=v1t
          ctk=-0.5*(mup+mui(2)+muti(2))/dy
          ctmu2=0.5*(mui(2)+muti(2)+mui(3)+muti(3))/dy 
          betaa(ndis)=v1t
!         calcul des alfa, beta 
          do ij=ndis-1,3,-1
            ctmu=0.5*(mui(ij)+muti(ij)+mui(ij+1)+muti(ij+1))/dy 
            alfaa(ij)=(ctk+ctmu*alfaa(ij+1))/ctmu
            betaa(ij)=-(dpdt*(ij-1)*dy-ctmu*betaa(ij+1))/ctmu
          end do
          vit(2)=(dy*dpdt-ctmu2*betaa(3))/(-ctmu2+ctk+ctmu2*alfaa(3))
          do j=3,ndis-1
            vit(j)=alfaa(j)*vit(2)+betaa(j)
          end do
          mup=mu(ni)
          topc(kk)=-ctk*vit(2)-dy*0.5*dpdt       
          topar=topini+dtop          
         enddo
         dnum=topc(2)-topc(1)-dtop
         if(abs(dnum).le.tiny(1.)) then
           topar=0.
         else
           topar=top0-(topc(1)-top0)*dtop/(topc(2)-topc(1)-dtop)
         endif
         dconv=abs(top0-topar)    
         dtop=dconv
!************************************************************************
!------fin boucle du Newton----------------------------------------------
!************************************************************************
        end do
!       test sur la transition 
        if((fgam(mpar).lt.1.e-3).and.(ktransi.gt.0)) then
!        tprod(nii)=0.
         v(ni,7)=roeinf
         v(ni,6)=rokinf
        else
!        calcul de la production de k -> valeur moyenne sur la cellule adjacente 
         som1=0.
         som2=0.
         som3=0.
         ff(1)=0.
         do kk=1,ndis-1   
          som1=som1+(ff(kk)+ff(kk+1))*0.5*dy
          som2=som2+(ff(kk)*(kk-1)+ff(kk+1)*kk)*0.5*dy**2 
          som3=som3+(ff(kk)*(kk-1)**2+ff(kk+1)*kk**2)*0.5*dy**3    
         end do 
         tprod(nii)=(topar**2*som1 + 2.*topar*dpdt*som2 + &
                     dpdt**2*som3)/dist(ni)      
  
!        calcul de epsilon = k^1.5 / l_eps en cellule 1
         retur=sqrt(rop*v(ni,6))*dist(ni)/mu(ni)
         echleps=vkar*cmu2*dist(ni)*(1.-exp(-retur/(2.*vkar*cmu2)))
         eps=(v(ni,6)/v(ni,1))**1.5/echleps
         v(ni,7)=max(v(ni,1)*eps,epse)
         v(nc,7)=0.
        endif  
!       vitesse de frottement utau
        utau(nfacns)=sign(1.,topar)*sqrt(abs(topar)/rop) 
!     fin boucle sur facettes d'une frontiere paroi      
      enddo

DEALLOCATE(alfaa,betaa,ff,vit,mui,muti,tempi,topc)

      return
      end
