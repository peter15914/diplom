///////////////////////////////////////////////////////////////////////
function IsZero(d:double):boolean;
const eps:double=0.00000001;
begin
  IsZero:=(abs(d)<eps);
end;
///////////////////////////////////////////////////////////////////////
procedure add_yyy(num, add:integer; val:double);
//прибавляем к переменной num переменную add, умноженную на val
var i:integer;
begin
  for i:=0 to ny do
    yyy[num,i]:=yyy[num,i]+yyy[add,i]*val;
end;
///////////////////////////////////////////////////////////////////////
procedure add_triangle(kold, knew, edgenum:integer);
var b,g,b2,g2:double;
begin
  b:=edges[edgenum].b;
  g:=edges[edgenum].g;

  b2:=b*b;
  g2:=g*g;

  yyy[10*knew+5, 10+2*(knew-1)  ]:=1;
  yyy[10*knew+9, 10+2*(knew-1)+1]:=1;

  knew:=10*knew;
  kold:=10*kold;

  add_yyy(knew+0, kold+0, 1);
  add_yyy(knew+0, kold+5, -b2);
  add_yyy(knew+0, kold+9, 2*b2*b);
  add_yyy(knew+0, knew+5, b2);
  add_yyy(knew+0, knew+9, -2*b2*b);

  add_yyy(knew+2, kold+2, 1);
  add_yyy(knew+2, kold+5, -2*b);
  add_yyy(knew+2, kold+9, 3*b2);
  add_yyy(knew+2, knew+5, 2*b);
  add_yyy(knew+2, knew+9, -3*b2);

  add_yyy(knew+3, kold+3, 1);
  add_yyy(knew+3, kold+5, -g2);
  add_yyy(knew+3, kold+9, 6*b*g2);
  add_yyy(knew+3, knew+5, g2);
  add_yyy(knew+3, knew+9, -6*b*g2);

  add_yyy(knew+6, kold+6, 1);
  add_yyy(knew+6, kold+9, -2*g*g2);
  add_yyy(knew+6, knew+9, 2*g*g2);

  add_yyy(knew+1, kold+1, 1);
  add_yyy(knew+1, kold+5, 2*b*g);
  add_yyy(knew+1, kold+9, -6*b2*g);
  add_yyy(knew+1, knew+5, -2*b*g);
  add_yyy(knew+1, knew+9, 6*b2*g);

  add_yyy(knew+4, kold+4, 1);
  add_yyy(knew+4, kold+5, 2*g);
  add_yyy(knew+4, kold+9, -6*b*g);
  add_yyy(knew+4, knew+5, -2*g);
  add_yyy(knew+4, knew+9, 6*b*g);

  add_yyy(knew+7, kold+7, 1);
  add_yyy(knew+7, kold+9, 3*g2);
  add_yyy(knew+7, knew+9, -3*g2);

  add_yyy(knew+8, kold+8, 1);
end;
///////////////////////////////////////////////////////////////////////
procedure add_bbb(nb, k:integer; val:double);
var i:integer;
begin
  for i:=0 to ny do
    bbb[nb,i]:=bbb[nb,i]+yyy[k,i]*val;
end;
///////////////////////////////////////////////////////////////////////
procedure addedge_to_bbb(edgenum:integer);
var i,k1,k2:integer;
    b,g,b2,g2:double;
begin
  b:=edges[edgenum].b;
  g:=edges[edgenum].g;
  b2:=b*b;
  g2:=g*g;
  k1:=edges[edgenum].tr[1]*10;
  k2:=edges[edgenum].tr[2]*10;

{1}////////////////////
  inc(nb);
  for i:=0 to nq do bbb[nb][i]:=0;
  add_bbb(nb,k1+0,1);
  add_bbb(nb,k1+5,-b2);
  add_bbb(nb,k1+9,2*b2*b);
  add_bbb(nb,k2+0,-1);
  add_bbb(nb,k2+5,b2);
  add_bbb(nb,k2+9,-2*b2*b);
{2}////////////////////
  inc(nb);
  for i:=0 to nq do bbb[nb][i]:=0;
  add_bbb(nb,k1+2,1);
  add_bbb(nb,k1+5,-2*b);
  add_bbb(nb,k1+9,3*b2);
  add_bbb(nb,k2+2,-1);
  add_bbb(nb,k2+5,2*b);
  add_bbb(nb,k2+9,-3*b2);
{3}////////////////////
  inc(nb);
  for i:=0 to nq do bbb[nb][i]:=0;
  add_bbb(nb,k1+3,1);
  add_bbb(nb,k1+5,-g2);
  add_bbb(nb,k1+9,6*g2*b);
  add_bbb(nb,k2+3,-1);
  add_bbb(nb,k2+5,g2);
  add_bbb(nb,k2+9,-6*g2*b);
{4}////////////////////
  inc(nb);
  for i:=0 to nq do bbb[nb][i]:=0;
  add_bbb(nb,k1+6,1);
  add_bbb(nb,k1+9,-2*g2*g);
  add_bbb(nb,k2+6,-1);
  add_bbb(nb,k2+9,2*g2*g);
{5}////////////////////
  inc(nb);
  for i:=0 to nq do bbb[nb][i]:=0;
  add_bbb(nb,k1+1,1);
  add_bbb(nb,k1+5,2*g*b);
  add_bbb(nb,k1+9,-6*g*b2);
  add_bbb(nb,k2+1,-1);
  add_bbb(nb,k2+5,-2*g*b);
  add_bbb(nb,k2+9,6*g*b2);
{6}////////////////////
  inc(nb);
  for i:=0 to nq do bbb[nb][i]:=0;
  add_bbb(nb,k1+4,1);
  add_bbb(nb,k1+5,2*g);
  add_bbb(nb,k1+9,-6*g*b);
  add_bbb(nb,k2+4,-1);
  add_bbb(nb,k2+5,-2*g);
  add_bbb(nb,k2+9,6*g*b);
{7}////////////////////
  inc(nb);
  for i:=0 to nq do bbb[nb][i]:=0;
  add_bbb(nb,k1+7,1);
  add_bbb(nb,k1+9,3*g2);
  add_bbb(nb,k2+7,-1);
  add_bbb(nb,k2+9,-3*g2);
{8}////////////////////
  inc(nb);
  for i:=0 to nq do bbb[nb][i]:=0;
  add_bbb(nb,k1+8,1);
  add_bbb(nb,k2+8,-1);
end;
///////////////////////////////////////////////////////////////////////
procedure addvalues_to_bbb(pointnum:integer);
var x,y,val:double;
    i,k:integer;
begin
  inc(nb);
  for i:=0 to nq do bbb[nb][i]:=0;

  x:=verticies[pointnum].x;
  y:=verticies[pointnum].y;
  val:=verticies[pointnum].val;
  k:=verticies[pointnum].tr*10;

  add_bbb(nb,k+0,1);
  add_bbb(nb,k+1,x);
  add_bbb(nb,k+2,y);
  add_bbb(nb,k+3,x*x);
  add_bbb(nb,k+4,x*y);
  add_bbb(nb,k+5,y*y);
  add_bbb(nb,k+6,x*x*x);
  add_bbb(nb,k+7,x*x*y);
  add_bbb(nb,k+8,x*y*y);
  add_bbb(nb,k+9,y*y*y);

  bbb[nb,nq]:=val;

  desc[nb]:='Func val '+inttostr(pointnum);
end;
///////////////////////////////////////////////////////////////////////
function getval(x,y:double; k:integer):double;
begin
  result:=0;
  result:=result+splines[k][0];
  result:=result+splines[k][1]*x;
  result:=result+splines[k][2]*y;
  result:=result+splines[k][3]*x*x;
  result:=result+splines[k][4]*x*y;
  result:=result+splines[k][5]*y*y;
  result:=result+splines[k][6]*x*x*x;
  result:=result+splines[k][7]*x*x*y;
  result:=result+splines[k][8]*x*y*y;
  result:=result+splines[k][9]*y*y*y;
end;
///////////////////////////////////////////////////////////////////////
function checksol2(write_log:boolean):integer;
var i,j,v:integer;
    v1,v2:double;
begin
  Result:=0;

  if (write_log)then
    writeln(log,'checking solution');

  for i:=1 to nt do
  begin
    for j:=1 to 3 do
    begin
      v:=triangles[i].v[j];
      v1:=getval(verticies[v].x,verticies[v].y,(i-1));
      v2:=verticies[v].val;
      if not IsZero(v1-v2)then
      begin
        if abs(v1-v2)<0.1 then
        begin
          writeln(log, 'small error in eq ',i,' ',v1:0:3,' ',v2:0:3);
          result:=2;
        end
        else
        begin
          writeln(log, 'error in eq ',i,' ',v1:0:3,' ',v2:0:3);
          result:=1;
          exit;
        end;
      end;
    end;
  end;

end;
///////////////////////////////////////////////////////////////////////
procedure check_yyy;
var i,j,jj,num:integer;
    val:double;
begin
  read_2nd_spline;

  for i:=0 to 10*nt-1 do
  begin
    val:=0;
    for j:=0 to 9 do
      val:=val+yyy[i,j]*splines2[0,j];

    num:=1;
    for j:=10 to 10+2*nt do
    begin
      if odd(j) then jj:=9
      else jj:=5;

      val:=val+yyy[i,j]*splines2[num,jj];
      if odd(j) then inc(num);
    end;

    if abs(val-splines2[i div 10,i mod 10])>0.1 then
    begin
      writeln(log,'!!!!error ',i,' ',val:0:3,' ',splines2[i div 10,i mod 10]:0:3);
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////
procedure read_2nd_spline;
var f:textfile;
    i,j:integer;
begin
  assignfile(f,'444_by_best');
  reset(f);

  for i:=0 to 9 do
  begin
    for j:=0 to nt-1 do
      read(f,splines2[j,i]);
    readln(f);
  end;

  closefile(f);
end;
///////////////////////////////////////////////////////////////////////
procedure check_bbb;
var i,j,jj,ii:integer;
    val:double;
begin
  read_2nd_spline;

  for i:=1 to nb do
  begin
    val:=0;
    for j:=0 to nq-1 do
    begin
      if j<10 then
      begin
        ii:=0;
        jj:=j;
      end
      else
      begin
        if odd(j) then jj:=9
        else jj:=5;
        ii:=(j-10)div 2 +1;
      end;
      val:=val+bbb[i,j]*splines2[ii,jj];
    end;

    if abs(val-bbb[i,nq])>0.01 then
    begin
      writeln(log,'----error ',i,' ',val:0:3,' ',bbb[i,nq]:0:3);
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////
procedure check_bbb_solution;
var i,j:integer;
    val:double;
begin
  writeln(log,'----checking bbb solution !!!');
  for i:=1 to nb do
  begin
    val:=0;
    for j:=0 to nq-1 do
      val:=val+x3[j]*bbb2[i,j];

    if abs(val-bbb2[i,nq])>0.01 then
    begin
      writeln(log,'bbb_error ',i,' ',val:0:3,' ',bbb2[i,nq]:0:3);
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////
procedure solve_bbb;
var i,j,ii,jj,max:integer;
    k:double;
begin
  for i:=0 to x3_len do x3[i]:=0;

  for i:=1 to nb do
    used[i]:=tqUsed;

  for i:=1 to nb do
  begin
    max:=0;
    j:=1;
    while j<nq do
    begin
      if abs(bbb[i,max])<abs(bbb[i,j]) then max:=j;
      inc(j);
    end;

    if IsZero(bbb[i][max])then
    begin
      if IsZero(bbb[i,nq]) then used[i]:=tqLComb
      else used[i]:=tqBad;
      continue;
    end;
    main[i]:=max; j:=max;
//
    k:=bbb[i,j];
    for ii:=0 to nq do
      if not IsZero(bbb[i,ii]) then bbb[i,ii]:=bbb[i,ii]/k;

    for ii:=i+1 to nb do
    if used[ii]=tqUsed then
    if not IsZero(bbb[ii,j]) then
    begin
      k:=bbb[ii,j];
      for jj:=0 to nq do
      begin
        bbb[ii,jj]:=bbb[ii,jj]-k*bbb[i,jj];
        if IsZero(bbb[ii,jj])then bbb[ii,jj]:=0;
      end;

      bbb[ii,j]:=0;
    end;
  end;

(*  for i:=1 to nb do
  if used[i]<>tqUsed then
  begin
    if used[i]=tqLComb then
      writeln(log,i:2,'. is LComb')
    else
      writeln(log,i:2,'. is Bad')
  end;*)
end;
///////////////////////////////////////////////////////////////////////
procedure back_bbb;
var i,j:integer;
begin
//back
  for i:=nb downto 1 do
  if used[i]=tqUsed then
  begin
    x3[main[i]]:=bbb[i][nq]/bbb[i][main[i]];
    for j:=i-1 downto 1 do
    if used[j]=tqUsed then
    begin
      bbb[j,nq]:=bbb[j,nq]-bbb[i,nq]*bbb[j,main[i]];
      bbb[j,main[i]]:=0;
    end;
  end;
end;

