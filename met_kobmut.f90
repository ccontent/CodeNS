module mod_met_kobmut
  implicit none
contains
  subroutine met_kobmut( &
       ncyc, &
       l, &
       v,mu,mut)
!
!***********************************************************************
!
!_DA  DATE_C :  novembre 1998 - AUTEUR :  Eric Goncalves
!
!     ACT
!_A   Calcul de la viscosite turbulente a partir de k et omega
!_A   Modele k-omega bas Reynolds de Wilcox
!
!     INP
!_I    l          : arg int              ; numero de domaine
!_I    v          : arg real(ip11,ip60 ) ; variables a l'instant n+alpha
!_I    mu         : arg real(ip12      ) ; viscosite moleculaire
!
!     OUT
!_O    mut        : arg real(ip12      ) ; viscosite turbulente
!
!-----parameters figes--------------------------------------------------
!
    use para_var
    use para_fige
    use maillage
    use modeleturb
    implicit none
    integer          ::      i,    i1,    i2,  i2m1
    integer          :: idebug,     j,    j1,    j2,  j2m1
    integer          ::      k,    k1,    k2,  k2m1
    integer          ::      l,     n,    n0,   nci
    integer          ::    ncj,   nck,  ncyc,   nid,  nijd
    integer          ::    njd
    double precision ::       allfae,    mu(ip12),   mut(ip12),      omegha,        rapk
    double precision ::       reytur,v(ip11,ip60)
!
!-----------------------------------------------------------------------
!
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
    ncj = inc(0,1,0)
    nck = inc(0,0,1)
!
    idebug=0
!
!      modele bas Reynolds de Wilcox ou de Menter
!
    do k=k1,k2m1
       do j=j1,j2m1
          n=ind(i1-1,j,k)
          do i=i1,i2m1
             n=n+nci
             omegha=v(n,7)/v(n,1)
             reytur=v(n,6)/(omegha*mu(n))
             rapk=(reytur/rrk)
             allfae=(allfae0+rapk)/(1.+rapk)
             mut(n)=allfae*v(n,6)/omegha
          enddo
       enddo
    enddo
!
    return
  contains
    function    ind(i,j,k)
      implicit none
      integer          ::   i,ind,  j,  k
      ind=n0+1+(i-id1(l))+(j-jd1(l))*nid+(k-kd1(l))*nijd
    end function ind
    function    inc(id,jd,kd)
      implicit none
      integer          ::  id,inc, jd, kd
      inc=id+jd*nid+kd*nijd
    end function inc
  end subroutine met_kobmut
end module mod_met_kobmut
