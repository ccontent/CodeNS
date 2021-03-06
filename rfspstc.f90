module mod_rfspstc
  implicit none
contains
  subroutine rfspstc(l,t)
!
!***********************************************************************
!
!     ACT
!_A    Determination des variables de calcul sur les aretes et dans les
!_A    coins des domaines structures par extrapolation.
!
!     INP
!_I    l          : arg int              ; numero de domaine
!_I    npc        : com int (lt        ) ; pointeur fin de dom precedent
!_I                                        dans tab toutes cellules
!_I    id1        : com int (lt        ) ; indice min en i fictif
!_I    ii1        : com int (lt        ) ; indice min en i reel
!_I    ii2        : com int (lt        ) ; indice max en i reel
!_I    id2        : com int (lt        ) ; indice max en i fictif
!_I    jd1        : com int (lt        ) ; indice min en j fictif
!_I    jj1        : com int (lt        ) ; indice min en j reel
!_I    jj2        : com int (lt        ) ; indice max en j reel
!_I    jd2        : com int (lt        ) ; indice max en j fictif
!_I    kd1        : com int (lt        ) ; indice min en k fictif
!_I    kk1        : com int (lt        ) ; indice min en k reel
!_I    kk2        : com int (lt        ) ; indice max en k reel
!
!-----parameters figes--------------------------------------------------
!
    use para_var
    use para_fige
    use maillage
    implicit none
    integer          ::    i,  i1,i1m1,  i2,i2m1
    integer          :: iinc,  is,   j,  j1,j1m1
    integer          ::   j2,j2m1,jinc,  js,   k
    integer          ::   k1,k1m1,  k2,k2m1,kinc
    integer          ::   ks,   l,   n,  n0,  n1
    integer          ::   n2,  n3,  n4, nid,nijd
    integer          ::  njd
    double precision :: t(ip11)
!
!-----------------------------------------------------------------------
!
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
    nid = id2(l)-id1(l)+1
    njd = jd2(l)-jd1(l)+1
    nijd = nid*njd
!
    i1m1=i1-1
    j1m1=j1-1
    k1m1=k1-1
!
    i2m1=i2-1
    j2m1=j2-1
    k2m1=k2-1
!
!     extrapolation des variables
!
    iinc = i2-i1m1
    jinc = j2-j1m1
    kinc = k2-k1m1
!
    ks = -1
    do k = k1m1,k2,kinc
       ks = -ks
       js = -1
       do j = j1m1,j2,jinc
          js = -js
          do i = i1,i2m1
             n = ind(i,j,k)
             n1= ind(i,j+js,k+ks)
             n2= ind(i,j+js,k   )
             n3= ind(i,j   ,k+ks)
             t(n) = t(n2)+t(n3)-t(n1)
          enddo
       enddo
    enddo
!
    is = -1
    do i = i1m1,i2,iinc
       is = -is
       ks = -1
       do k = k1m1,k2,kinc
          ks = -ks
          do j = j1,j2m1
             n = ind(i,j,k)
             n1= ind(i+is,j,k+ks)
             n2= ind(i+is,j,k   )
             n3= ind(i   ,j,k+ks)
             t(n) = t(n2)+t(n3)-t(n1)
          enddo
       enddo
    enddo
!
    js = -1
    do j = j1m1,j2,jinc
       js = -js
       is = -1
       do i = i1m1,i2,iinc
          is = -is
          do k = k1,k2m1
             n = ind(i,j,k)
             n1= ind(i+is,j+js,k)
             n2= ind(i   ,j+js,k)
             n3= ind(i+is,j   ,k)
             t(n) = t(n2)+t(n3)-t(n1)
          enddo
       enddo
    enddo
!
    ks = -1
    do k = k1m1,k2,kinc
       ks = -ks
       js = -1
       do j = j1m1,j2,jinc
          js = -js
          is = -1
          do i = i1m1,i2,iinc
             is = -is
             n = ind(i,j,k)
             n1= ind(i+is,j+js,k   )
             n2= ind(i   ,j+js,k+ks)
             n3= ind(i+is,j   ,k+ks)
             n4= ind(i+is,j+js,k+ks)
             t(n) = t(n1)+t(n2)+t(n3)-2.0*t(n4)
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
  end subroutine rfspstc
end module mod_rfspstc
