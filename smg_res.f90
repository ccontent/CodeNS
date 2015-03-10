      subroutine smg_res( &
                 itypdf, &
                 lm,dfi,df)
!
!***********************************************************************
!
!     ACT
!_A    Accumulation de flux et de "forcing function".
!
!***********************************************************************
!-----parameters figes--------------------------------------------------
!
      use para_var
      use para_fige
      use maillage
implicit none
integer :: indc
integer :: i
integer :: j
integer :: k
integer :: itypdf
integer :: lm
double precision :: dfi
double precision :: df
integer :: i1
integer :: i2
integer :: i2m1
integer :: ind1
integer :: ind2
integer :: j1
integer :: j2
integer :: j2m1
integer :: k1
integer :: k2
integer :: k2m1
integer :: m
integer :: n
integer :: n0c
integer :: nid
integer :: nijd
integer :: njd
!
!-----------------------------------------------------------------------
!
      dimension df(ip11,ip60),dfi(ip11,ip60)
!
      indc(i,j,k)=1+(i-id1(lm))+(j-jd1(lm))*nid +(k-kd1(lm))*nijd
!
      n0c=npc(lm)
      i1 =ii1(lm)
      i2 =ii2(lm)
      j1 =jj1(lm)
      j2 =jj2(lm)
      k1 =kk1(lm)
      k2 =kk2(lm)
!
      i2m1=i2-1
      j2m1=j2-1
      k2m1=k2-1
!
      nid  = id2(lm)-id1(lm)+1
      njd  = jd2(lm)-jd1(lm)+1
      nijd = nid*njd
!
      do k = k1,k2m1
       do j = j1,j2m1
        ind1 = indc(i1,j,k)
        ind2 = indc(i2m1,j,k)
        if(itypdf.ne.0) then
         do m = ind1,ind2
          n = m+n0c
          df(n,1)=df(n,1) + dfi(n,1)
          df(n,2)=df(n,2) + dfi(n,2)
          df(n,3)=df(n,3) + dfi(n,3)
          df(n,4)=df(n,4) + dfi(n,4)
          df(n,5)=df(n,5) + dfi(n,5)
         enddo
        else
         do m = ind1,ind2
          n = m+n0c
          df(n,1)=dfi(n,1)
          df(n,2)=dfi(n,2)
          df(n,3)=dfi(n,3)
          df(n,4)=dfi(n,4)
          df(n,5)=dfi(n,5)
         enddo
        endif
       enddo
      enddo
!
      return
      end
