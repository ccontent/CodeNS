module mod_utvrt
  implicit none
contains
  subroutine utvrt( &
       bceqt, &
       mfl,l,rod,roud,rovd,rowd,roed, &
       ncbd, &
       y,z, &
       mmb,mpb)
!
!***********************************************************************
!
!     Condition de vorticite pour restituer les conditions a l'infini
!     sur un maillage limite.
!
!************************************************************************
!-----parameters figes--------------------------------------------------
!
    use para_var
    use para_fige
    use maillage
    use definition
    use proprieteflu       
    implicit none
    integer          ::    id,  inc,   jd,   kd,    l
    integer          ::     m,  mfl,   ml,  mmb,  mpb
    integer          ::    mt,  n0c,  n0n,   nc, ncbd
    integer          ::   nci, ncij,ncijk, ncik,  ncj
    integer          ::  ncjk,  nck,  nid, nijd,  njd
    integer          ::    nn
    double precision ::      a,alpha0,alphar, bceqt, beta0
    double precision ::  betar,degrad,     p,  pis2,     q
    double precision ::  rmach,    ro,   rod,   roe,  roed
    double precision ::    rou,  roud,   rov,  rovd,   row
    double precision ::   rowd,     y,    ym,     z,    zm
!
!-----------------------------------------------------------------------
!
    dimension bceqt(ip41,neqt)
    dimension ncbd(ip41)
    dimension y(ip21),z(ip21)
    dimension rod(ip40),roud(ip40),rovd(ip40),rowd(ip40),roed(ip40)
    dimension mmb(mtt),mpb(mtt)
!
    inc(id,jd,kd)=id+jd*nid+kd*nijd
!
    n0n=npn(l)
    n0c=npc(l)
!
    nid = id2(l)-id1(l)+1
    njd = jd2(l)-jd1(l)+1
    nijd = nid*njd
!
    nci = inc(1,0,0)
    ncj = inc(0,1,0)
    nck = inc(0,0,1)
    ncij = inc(1,1,0)
    ncik = inc(1,0,1)
    ncjk = inc(0,1,1)
    ncijk= inc(1,1,1)
!
    pis2  =atan2(1.,0.)
    degrad=pis2/90.
!
    ml=mpb(mfl)+1
    rmach =bceqt(ml,1)
    alpha0=bceqt(ml,2)
    beta0 =bceqt(ml,3)
!
    ro    =roa1/(1.+gam2*rmach**2)**gam4
    a     =aa1 /(1.+gam2*rmach**2)**.5
    p     =pa1 /(1.+gam2*rmach**2)**(gam/gam1)
    q     =rmach*a
    alphar=alpha0*degrad
    betar=beta0*degrad
    rou   =ro*q*cos(alphar)*cos(betar)
    rov   =-ro*q*sin(betar)
    row   =ro*q*sin(alphar)*cos(betar)
    roe   =p/gam1+.5*ro*q**2
!
    mt=mmb(mfl)
    do m=1,mt
       ml=mpb(mfl)+m
       nc=ncbd(ml)
       nn=nc-n0c+n0n
!
       ym  = 0.125*( y (nn     )+y (nn+nci  ) &
            +y (nn+ncj )+y (nn+ncij ) &
            +y (nn+nck )+y (nn+ncik ) &
            +y (nn+ncjk)+y (nn+ncijk) )
       zm  = 0.125*( z (nn     )+z (nn+nci  ) &
            +z (nn+ncj )+z (nn+ncij ) &
            +z (nn+nck )+z (nn+ncik ) &
            +z (nn+ncjk)+z (nn+ncijk) )
!
       rod (m) =ro
       roud(m)=rou
       rovd(m)=rov+omg*zm*ro
       rowd(m)=row-omg*ym*ro
       roed(m)=roe+.5*(rovd(m)**2-rov**2+ &
            rowd(m)**2-row**2)/ro
    enddo
!
    return
  end subroutine utvrt

end module mod_utvrt
