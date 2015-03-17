module mod_met_smkes
  implicit none
contains
  subroutine met_smkes( &
       l, &
       mu,s,cfke, &
       tprod,bark,bare,tsv6,tsv7)
!
!***********************************************************************
!
!     ACT  calcul du terme source
!
!-----parameters figes--------------------------------------------------
!
    use para_var
    use para_fige
    use maillage
    use modeleturb
    implicit none
    integer          ::    i,  i1,i1m1,i1p1,  i2
    integer          :: i2m1,  id, inc,indc,   j
    integer          ::   j1,j1p1,  j2,j2m1,  jd
    integer          ::    k,  k1,k1p1,  k2,k2m1
    integer          ::   kd,   l,   m,   n, n0c
    integer          ::  nci, ncj, nck, nid,nijd
    integer          ::  njd
    double precision ::    arg,     b,  bare,  bark,  c1f1
    double precision ::   c2f2,  cfke,     d,   esk,    f1
    double precision ::     f2,     g,    mu,rdelta, retur
    double precision :: roe2sk,     s, tprod,  tsv6,  tsv7
    double precision ::      x,   xl1,   xl2
!
!-----------------------------------------------------------------------
!
    dimension s(ip11,ip60)
    dimension mu(ip12),tsv6(ip12),tsv7(ip12)
    dimension tprod(ip00),bark(ip00),bare(ip00)
    dimension cfke(ip13)
!
    indc(i,j,k)=n0c+1+(i-id1(l))+(j-jd1(l))*nid+(k-kd1(l))*nijd
    inc(id,jd,kd)=id+jd*nid+kd*nijd
!
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
    i1p1=i1+1
    j1p1=j1+1
    k1p1=k1+1
    i2m1=i2-1
    j2m1=j2-1
    k2m1=k2-1
    i1m1=i1-1
!
    nci  = inc(1,0,0)
    ncj  = inc(0,1,0)
    nck  = inc(0,0,1)
!
    f1=1.
    do k=k1,k2m1
       do j=j1,j2m1
          n=indc(i1m1,j,k)
          do i=i1,i2m1
             n=n+nci
             m=n-n0c
             retur=(s(n,6)**2)/(s(n,7)*mu(n))
             arg  =-retur**2
             f2   =(1.-0.3*exp(arg))
             esk  =s(n,7)/s(n,6)
             roe2sk=(s(n,7)*s(n,7))/s(n,6)
!           mise a zero des termes bas Reynolds pour lois de paroi
             if(lparoi.eq.1) then
                bark(m)=0.
                bare(m)=0.
                f2=1.
             endif
             tsv6(n)=tprod(m)-s(n,7) + bark(m)
             tsv7(n)=cke1*f1*tprod(m)*esk -cke2*f2*roe2sk+bare(m)
!
!--------------rayon spectral ke
!
             c1f1=cke1*f1
             c2f2=cke2*f2
             d=-bark(m)
             x=c1f1*tprod(m)-c2f2*s(n,7)
             g=max(0.,d*(d-2.*(x-c2f2*s(n,7))))
             rdelta=sqrt((x-c2f2*s(n,7))**2+4*x*s(n,7)+g)
             b=x-c2f2*s(n,7)-d
             xl1=0.5*(b+rdelta)/s(n,6)
             xl2=0.5*(b-rdelta)/s(n,6)
             cfke(n)=max(abs(xl1),abs(xl2))
          enddo
       enddo
    enddo
!
    return
  end subroutine met_smkes
end module mod_met_smkes
