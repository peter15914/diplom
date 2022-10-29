procedure solve_bbb;forward;
procedure check_yyy;forward;
procedure check_bbb;forward;
procedure read_2nd_spline;forward;
procedure check_bbb_solution;forward;
procedure back_bbb;forward;
procedure back_special;forward;
procedure countfreevars2;forward;
procedure outp_aaa2;forward;
procedure solve_aaa2;forward;
procedure countyyy2;forward;

///////////////////////////////////////////////////////////////////////
const x3_len=3500;
var yyy:array[0..7000,0..2000]of double;
    bbb,bbb2:array[0..2500,0..1300]of double;
    nq,nb,nb1,nb2,ny:integer;
    x3,x4:array[0..x3_len]of double;

var jjj2:array[1..1000,0..100]of double;
    aaa2:array[1..100,0..100]of double;

var yyy2:array[0..1000,0..100]of double;


{$include unit2_03.inc}

///////////////////////////////////////////////////////////////////////
procedure interpolate2;
var i,j,trnum,knew,kold:integer;
    te,tt:array[1..1000]of boolean;
    o,o2:array[1..1000]of integer;
    no,no2:integer;

begin
//инициализируем все переменные через первоначальные
//используемые при этом ребра помечаем
  for i:=1 to max2(ne,nt) do
  begin
    te[i]:=false;
    tt[i]:=false;
  end;

  for i:=0 to nt*10-1 do
  for j:=0 to 10+nt*2 do
    yyy[i,j]:=0;

//инициализируем переменные для тр-ка № 0
  for i:=0 to 9 do
    yyy[i,i]:=1;
//
  ny:=10+(nt-1)*2-1;
  no:=1;
  o[1]:=0;
  //пока очередь не пуста
  while no>0 do
  begin
    no2:=0;

    //для каждого треугольника в очереди
    for i:=1 to no do
    begin
      trnum:=o[i]+1;
      tt[trnum]:=true;
//      writeln(log,trnum-1);

      for j:=1 to 3 do
      if (triangles[trnum].tr[j]>=0)and(not tt[triangles[trnum].tr[j]+1]) then
      begin
        inc(no2); o2[no2]:=triangles[trnum].tr[j];
        te[triangles[trnum].e[j]]:=true;
        tt[o2[no2]+1]:=true;

        //теперь устанавливаем переменные
        kold:=(trnum-1);
        knew:=o2[no2];

        add_triangle(kold, knew, triangles[trnum].e[j]);
      end;
    end;

    for i:=1 to no2 do
      o[i]:=o2[i];
    no:=no2;
  end;
//  check_yyy;  exit;

  nq:=ny+1;
  nb:=0;
//составляем систему для каждого значения функции
  for i:=1 to nv do
  begin
    addvalues_to_bbb(i);
  end;
//  check_bbb;  exit;

//добавляем к ней уравнения на неиспользованных ребрах
  for i:=1 to ne do
  if te[i]=false then
  begin
    addedge_to_bbb(i);
  end;
//  check_bbb;  exit;

//решаем полученную систему
//  bbb2:=bbb;
  solve_bbb;

  //finding free vars
  nb2:=0;
  for i:=1 to nb do
    if used[i]=tqUsed then inc(nb2);

  nf:=0;
  nb1:=nb;
  while (nb1>=0)and(used[nb1]<>tqUsed)do dec(nb1);
  if nb1>=0 then
  for i:=0 to nq-1 do
    if not IsZero(bbb[nb1,i])then
    begin
      if i<>main[nb1] then
      begin
        inc(nf);
//        if i<10 then
          freevars[nf]:=i
(*        else
        if not odd(i) then
          freevars[nf]:=((i-10)div 2 +1)*10 +5
        else
          freevars[nf]:=((i-10)div 2 +1)*10 +9;
*)      end;
    end;

  EQ_GOOD:=nt*10-nf;  
//  nf:=0;
  if nf=0 then
  begin
    back_bbb;
    //check_bbb_solution;
  end
  else
  begin
    // ASSERT(nq=nb2+nf+1);
    nb:=nb1;
    back_special;
  end;

  if nf=0 then
  for i:=0 to nt*10-1 do
  begin
    x4[i]:=0;
    for j:=0 to ny do
      x4[i]:=x4[i]+yyy[i][j]*x3[j];
  end;

  for i:=0 to nt-1 do
    for j:=0 to 9 do
      splines[i][j]:=x4[i*10+j];

  csd:=check_second_derrivatives(false);
  //outpsol;

  check_first_derrivatives;
  candraw:=true;
end;

procedure back_special;
var i,j,ii,jj:integer;
begin
  for i:=0 to nt*10-1 do
  begin
    setted[i]:=false;
    for j:=0 to nf do
      xxx[i][j]:=0;
  end;

  for i:=1 to nf do
  begin
    for j:=0 to nf do
      xxx[freevars[i]][j]:=0;
    xxx[freevars[i]][i]:=1;
    setted[freevars[i]]:=true;
  end;

  for i:=nb downto 1 do
  if (used[i]=tqUsed) then
  begin
    ii:=main[i];//ii-main elemet of the row
    if setted[ii] then
      continue;

    for j:=0 to nq-1 do
      if (j<>ii)and(not IsZero(bbb[i,j]))then
      begin
        //must substract here var № j from var № ii
        for jj:=0 to nf do
          xxx[ii][jj]:=xxx[ii][jj]-bbb[i,j]*xxx[j][jj];//??
      end;

    //must add here bbb[i,nq] to var № ii

    xxx[ii][0]:=xxx[ii][0]+bbb[i,nq];

    ASSERT(IsZero(1-bbb[i,ii]));

    setted[ii]:=true;
  end;
  //we have counted koeffs before notfree bbb vars.

  countyyy2;

  // now we must get sysyem and find freevars
  countfreevars2;
  outp_aaa2;
  solve_aaa2;

//setting freevals  
  freevals[0]:=1;
  for i:=1 to nf do
    freevals[i]:=0;
  for i:=1 to nf do
    freevals[i]:=-aaa2[i][0];
//
  for i:=0 to 10*nt-1 do
  begin
    x4[i]:=0;
    for ii:=0 to nf do
      x4[i]:=x4[i]+yyy2[i][ii]*freevals[ii];
  end;
end;

procedure countyyy2;
var i,j,ii:integer;
    val:double;
begin
  for i:=0 to 10*nt-1 do
  begin
    for j:=0 to nf do yyy2[i,j]:=0;

    for j:=0 to ny do
    if not IsZero(yyy[i,j])then
    begin
      for ii:=0 to nf do
        yyy2[i,ii]:=yyy2[i,ii]+yyy[i,j]*xxx[j,ii];
    end;
  end;
end;

procedure countfreevars2;
var k1,k2,i,j,ii,v1,v2:integer;
    x,y,sum:double;

procedure add_koeffs(edgenum,xnum:integer;k:double);
var j:integer;
begin
  for j:=0 to nf do
    jjj2[edgenum][j]:=jjj2[edgenum][j]+k*yyy2[xnum][j];
end;

begin
  for i:=1 to ne do
  begin
    v1:=edges[i].v[1];
    v2:=edges[i].v[2];

    k1:=edges[i].tr[1]*10;
    k2:=edges[i].tr[2]*10;

    x:=(verticies[v1].x+verticies[v2].x)/2;
    y:=(verticies[v1].y+verticies[v2].y)/2;

    for j:=0 to nf do
      jjj2[i][j]:=0;
      
//x derrivative
    add_koeffs(i,k2+3,1);
    add_koeffs(i,k2+6,3*x);
    add_koeffs(i,k2+7,y);
    add_koeffs(i,k1+3,-1);
    add_koeffs(i,k1+6,-3*x);
    add_koeffs(i,k1+7,-y);
//y derrivative
    add_koeffs(i,k2+5,1);
    add_koeffs(i,k2+8,x);
    add_koeffs(i,k2+9,3*y);
    add_koeffs(i,k2+5,-1);
    add_koeffs(i,k2+8,-x);
    add_koeffs(i,k2+9,-3*y);
  end;//for i:=1 to ne do
  //now we have koeffs for J on every edge

  //we must get a system for finding freevars
  for i:=1 to nf do
  begin
    for j:=0 to nf do
    begin
      //finding aaa2[i,j]
      sum:=0;

      for ii:=1 to ne do
        sum:=sum+jjj2[ii][i]*jjj2[ii][j];

      aaa2[i,j]:=sum;
    end;
  end;
end;

procedure outp_aaa2;
var i,j,k1,k2:integer;
begin
  k1:=8;
  k2:=2;

  writeln(log,'!!!outp aaa');
  for i:=1 to nf do
  begin
    for j:=0 to nf do
      write(log,aaa2[i,j]:k1:k2,' ');
    writeln(log);
  end;
end;

procedure solve_aaa2;
var i,j,ii,jj:integer;
    k:double;
    main:array[1..100]of integer;
begin
  for i:=1 to nf do
  begin
    j:=1;
    while (j<=nf)and(aaa2[i,j]=0) do inc(j);
    if j>nf then
    begin
      ASSERT(false);
      exit;
    end;

    main[i]:=j;
    //processing all other equations
    k:=aaa2[i,j];
    for jj:=0 to nf do
    if not IsZero(aaa2[i,jj])then
      aaa2[i,jj]:=aaa2[i,jj]/k;

    for ii:= i+1 to nf do
    if not IsZero(aaa2[ii,j]) then
    begin
      k:=aaa2[ii,j];
      for jj:=0 to nf do
        aaa2[ii,jj]:=aaa2[ii,jj]-k*aaa2[i,jj];
    end;
  end;

  //back processing

  for i:=nf downto 2 do
  begin
    for j:=i-1 downto 1 do
    begin
      k:=aaa2[j][main[i]];
      aaa2[j][main[i]]:=0;

      aaa2[j][0]:=aaa2[j][0]-k*aaa2[i][0];
    end;
  end;

end;

