unit Unit2;

interface

uses SysUtils;

procedure interpolate;
procedure interpolate2;
procedure readdata(filename:string);
function func(x,y:double):double;
function checksol(write_log:boolean):integer;

function checkEQ_GOOD:boolean;

function getxmin:double;
function getxmax:double;
function getymin:double;
function getymax:double;
function getzmin:double;
function getzmax:double;

procedure generategrid(filename:string;num:integer);

type
  TEQ = (tqUsed, tqLComb, tqBad);

const num_eq_n=2500;

type
    spline = array[0..9]of double;

var num_eq:integer;
    verticies:array[1..num_eq_n]of record tr:integer;x,y,val:double;end;
    triangles:array[1..num_eq_n]of record v,e,tr:array[1..3]of integer;end;
    edges:array[1..num_eq_n]of record tr,v:array[1..2]of integer; b,g:double;end;
    n,nv,ne,nt:integer;

    xx: array[0..num_eq_n-1]of double;
    xxx:array[0..6500,0..100]of double;
    setted:array[0..6500]of boolean;
    a:array[1..num_eq_n,0..num_eq_n]of double;
    desc:array[1..num_eq_n]of string;
    used:array[1..num_eq_n]of TEQ;
    main:array[1..num_eq_n]of integer;//index of first non zero, and then main element

    not_zeroes_count:array[1..num_eq_n]of integer;
    csd:double;

    splines, splines2:array[0..num_eq_n div 10]of spline;
    ns:integer;
    log:textfile;
    candraw:boolean;
    xmin,xmax,ymin,ymax,zmin,zmax:double;
    EQ_GOOD,EQ_GOOD_prev:integer;
    output_type:integer;

implementation

function IsZero(d:double):boolean;forward;
function checksol2(write_log:boolean):integer;forward;
{$include unit2_01.inc}

procedure readdata(filename:string);
var f:textfile;
    v1,v2,tr1,tr2,buf,i,j:integer;
begin
  if not fileexists(filename)then exit;
  
  assignfile(f,filename);
  reset(f);

  readln(f,ne);
  num_eq:=ne*10;

  for i:=1 to ne do
  begin
    readln(f,edges[i].tr[1],edges[i].tr[2],edges[i].v[1],edges[i].v[2]);
//sorting
    if edges[i].tr[1]>edges[i].tr[2] then
    begin
      buf:=edges[i].tr[1]; edges[i].tr[1]:=edges[i].tr[2]; edges[i].tr[2]:=buf;
    end;
    if edges[i].v[1]>edges[i].v[2] then
    begin
      buf:=edges[i].v[1]; edges[i].v[1]:=edges[i].v[2]; edges[i].v[2]:=buf;
    end;
  end;

  readln(f,nv);
  for i:=1 to nv do
  begin
    readln(f,verticies[i].tr,verticies[i].x,verticies[i].y,verticies[i].val);

    if verticies[i].x>xmax then xmax:=verticies[i].x;
    if verticies[i].x<xmin then xmin:=verticies[i].x;
    if verticies[i].y>ymax then ymax:=verticies[i].y;
    if verticies[i].y<ymin then ymin:=verticies[i].y;
    if verticies[i].val>zmax then zmax:=verticies[i].val;
    if verticies[i].val<zmin then zmin:=verticies[i].val;
  end;

  readln(f,nt);
  for i:=1 to nt do
  begin
    readln(f,triangles[i].v[1],triangles[i].v[2],triangles[i].v[3]);
//sorting
    if triangles[i].v[1]>triangles[i].v[2] then
    begin
      buf:=triangles[i].v[1]; triangles[i].v[1]:=triangles[i].v[2]; triangles[i].v[2]:=buf;
    end;
    if triangles[i].v[2]>triangles[i].v[3] then
    begin
      buf:=triangles[i].v[2]; triangles[i].v[2]:=triangles[i].v[3]; triangles[i].v[3]:=buf;
    end;
    if triangles[i].v[1]>triangles[i].v[2] then
    begin
      buf:=triangles[i].v[1]; triangles[i].v[1]:=triangles[i].v[2]; triangles[i].v[2]:=buf;
    end;
//
    for j:=1 to 3 do
    begin
      triangles[i].tr[j]:=-1;
      triangles[i].e[j]:=-1;
    end;
  end;

  for i:=1 to ne do
  begin
    tr1:=edges[i].tr[1]+1;
    tr2:=edges[i].tr[2]+1;

    v1:=edges[i].v[1];
    v2:=edges[i].v[2];

    if (verticies[v2].x-verticies[v1].x)=0 then
      edges[i].g:=0
    else
      edges[i].g:=(verticies[v2].y-verticies[v1].y)/(verticies[v2].x-verticies[v1].x);
    edges[i].b:=-(verticies[v2].y-edges[i].g*verticies[v2].x);

    if (v1=triangles[tr1].v[1])and(v2=triangles[tr1].v[2]) then
      begin triangles[tr1].tr[1]:=tr2-1; triangles[tr1].e[1]:=i; end;
    if (v1=triangles[tr1].v[2])and(v2=triangles[tr1].v[3]) then
      begin triangles[tr1].tr[2]:=tr2-1; triangles[tr1].e[2]:=i; end;
    if (v1=triangles[tr1].v[1])and(v2=triangles[tr1].v[3]) then
      begin triangles[tr1].tr[3]:=tr2-1; triangles[tr1].e[3]:=i; end;

    if (v1=triangles[tr2].v[1])and(v2=triangles[tr2].v[2]) then
      begin triangles[tr2].tr[1]:=tr1-1; triangles[tr2].e[1]:=i; end;
    if (v1=triangles[tr2].v[2])and(v2=triangles[tr2].v[3]) then
      begin triangles[tr2].tr[2]:=tr1-1; triangles[tr2].e[2]:=i; end;
    if (v1=triangles[tr2].v[1])and(v2=triangles[tr2].v[3]) then
      begin triangles[tr2].tr[3]:=tr1-1; triangles[tr2].e[3]:=i; end;
  end;

  closefile(f);
end;

{------------------------------------------------------------------------------}

procedure addvalues(k,pointnum:integer;x,y,val:double);
begin
  k:=k*10;

  inc(n);

  a[n,k+0]:=1;
  a[n,k+1]:=x;
  a[n,k+2]:=y;
  a[n,k+3]:=x*x;
  a[n,k+4]:=x*y;
  a[n,k+5]:=y*y;
  a[n,k+6]:=x*x*x;
  a[n,k+7]:=x*x*y;
  a[n,k+8]:=x*y*y;
  a[n,k+9]:=y*y*y;

  a[n,num_eq]:=val;

  desc[n]:='Func val '+inttostr(pointnum);
end;

procedure addMainEq(edgenum,k1,k2:integer;v1,v2,tip:integer);
var g,b,b3,b2,g2,g3,bg:double;
    n1,i,j:integer;
begin
  g:=edges[edgenum].g;
  b:=edges[edgenum].b;

  b2:=b*b;
  b3:=b2*b;
  g2:=g*g;
  g3:=g2*g;
  bg:=b*g;

  k1:=k1*10;
  k2:=k2*10;

  n1:=n;

  if tip = 0 then
  begin
  {1}
    inc(n); a[n,k1+0]:=1; a[n,k1+2]:=-b; a[n,k1+5]:=b2; a[n,k1+9]:=-b3;
    desc[n]:='EQ - 1,'+inttostr(k1)+','+inttostr(k2);
  {2}
    inc(n); a[n,k1+2]:=1; a[n,k1+5]:=-2*b; a[n,k1+9]:=3*b2;
    desc[n]:='EQ - 2,'+inttostr(k1)+','+inttostr(k2);
  {3}
    inc(n); a[n,k1+3]:=1; a[n,k1+4]:=g; a[n,k1+5]:=g2;
    desc[n]:='EQ - 3,'+inttostr(k1)+','+inttostr(k2);
  {4}
    inc(n); a[n,k1+6]:=1; a[n,k1+7]:=g; a[n,k1+8]:=g2; a[n,k1+9]:=g3;
    desc[n]:='EQ - 4,'+inttostr(k1)+','+inttostr(k2);

  {5}
    inc(n); a[n,k1+1]:=1; a[n,k1+4]:=-b; a[n,k1+8]:=b2;
    desc[n]:='EQ - 5,'+inttostr(k1)+','+inttostr(k2);
  {6}
    inc(n); a[n,k1+3]:=2; a[n,k1+4]:=g; a[n,k1+7]:=-2*b; a[n,k1+8]:=2*bg;
    desc[n]:='EQ - 6,'+inttostr(k1)+','+inttostr(k2);
  {7}
    inc(n); a[n,k1+4]:=1; a[n,k1+5]:=2*g; a[n,k1+8]:=-2*b; a[n,k1+9]:=-6*bg;
    desc[n]:='EQ - 7,'+inttostr(k1)+','+inttostr(k2);
  {8}
    inc(n); a[n,k1+7]:=1; a[n,k1+8]:=2*g; a[n,k1+9]:=3*g2;
    desc[n]:='EQ - 8,'+inttostr(k1)+','+inttostr(k2);
  end
  else
  begin
  {1}
    inc(n); a[n,k1+0]:=1; a[n,k1+5]:=-b2; a[n,k1+9]:=2*b3;
    desc[n]:='EQ - 1,'+inttostr(k1)+','+inttostr(k2);
  {2}
    inc(n); a[n,k1+2]:=1; a[n,k1+5]:=-2*b; a[n,k1+9]:=3*b2;
    desc[n]:='EQ - 2,'+inttostr(k1)+','+inttostr(k2);
  {3}
    inc(n); a[n,k1+3]:=1; a[n,k1+5]:=-g2; a[n,k1+9]:=-6*g2*b;
    desc[n]:='EQ - 3,'+inttostr(k1)+','+inttostr(k2);
  {4}
    inc(n); a[n,k1+6]:=1; a[n,k1+9]:=-g3;
    desc[n]:='EQ - 4,'+inttostr(k1)+','+inttostr(k2);

  {5}
    inc(n); a[n,k1+1]:=1; a[n,k1+5]:=2*bg; a[n,k1+9]:=6*g*b2;
    desc[n]:='EQ - 5,'+inttostr(k1)+','+inttostr(k2);
  {6}
    inc(n); a[n,k1+4]:=1; a[n,k1+5]:=2*g; a[n,k1+9]:=6*bg;
    desc[n]:='EQ - 6,'+inttostr(k1)+','+inttostr(k2);
  {7}
    inc(n); a[n,k1+7]:=1; a[n,k1+9]:=3*g2;
    desc[n]:='EQ - 7,'+inttostr(k1)+','+inttostr(k2);
  {8}
    inc(n); a[n,k1+8]:=1;
    desc[n]:='EQ - 8,'+inttostr(k1)+','+inttostr(k2);
  end;

  for i:=n1+1 to n do
  begin
    for j:=0 to 9 do
      a[i,k2+j]:=-a[i,k1+j];
  end;
end;

procedure init_eq(n_eq:integer);
var j:integer;
begin
  not_zeroes_count[n_eq]:=0;
  used[n_eq]:=tqUsed;

  for j:=0 to num_eq do
    if not IsZero(a[n_eq,j])then
      inc(not_zeroes_count[n_eq]);
end;

procedure init(tip:integer);
var i,j:integer;
begin
  for i:=1 to num_eq do
    for j:=0 to num_eq do
      a[i,j]:=0;

  n:=0;
  for i:=1 to ne do
    addMainEq(i,edges[i].tr[1],edges[i].tr[2],edges[i].v[1],edges[i].v[2],tip);
  for i:=1 to nv do
    addvalues(verticies[i].tr,i,verticies[i].x,verticies[i].y,verticies[i].val);
  for i:=1 to n do
    init_eq(i);
end;

procedure solve(write_log:boolean);              {прямой ход метода Гаусса}
var i,j,ii,jj:integer;
    k:double;
    aold_is_zero:boolean;
begin
  for i:=1 to n do            {пробегаем все уравнения}
  if used[i]=tqUsed then
  begin
    if(write_log)then begin writeln(log,i); outp; end;

    j:=0;
    while (j<num_eq)and(IsZero(a[i,j])) do
      inc(j);

    if j>=num_eq then
    begin
      if IsZero(a[i,num_eq])then
        used[i]:=tqLComb
      else
        used[i]:=tqBad;

      if (used[i]=tqLComb)and(not_zeroes_count[i]<>0) then
      begin
        writeln(log,'but no_zeroes_count[i]=',not_zeroes_count[i]);
        ASSERT(false);
      end;
      continue;
    end;

    k:=a[i,j];

    main[i]:=j;

    //пробегаем по этому уравнению
    for jj:=0 to num_eq do
    begin
      aold_is_zero:=IsZero(a[i,jj]);
      if aold_is_zero then continue;

      a[i,jj]:=a[i,jj]/k;

      if IsZero(a[i,jj]) then
      begin
        a[i,jj]:=0;
        dec(not_zeroes_count[i]);
      end;
    end;

    //теперь пашем все остальные
    for ii:= i+1 to n do
    if (used[ii]=tqUsed)and(not IsZero(a[ii,j])) then
    begin
      k:=a[ii,j];
      for jj:=0 to num_eq do
      begin
        aold_is_zero:=IsZero(a[ii,jj]);
        a[ii,jj]:=a[ii,jj]-a[i,jj]*k;

        if IsZero(a[ii,jj]) then
        begin
          a[ii,jj]:=0;
          if not aold_is_zero then
            dec(not_zeroes_count[ii]);
        end
        else if aold_is_zero then
             begin
               inc(not_zeroes_count[ii]);
             end;
      end;
    end;

    {проверяем, не стало ли какое-нибудь уравнение вырожденным}
    for ii:=1 to n do
    if used[ii]=tqUsed then
    begin
      if not_zeroes_count[ii]<0 then
        ASSERT(false)
      else
      if not_zeroes_count[ii]=0 then
        used[ii]:=tqLComb
      else
      if (not_zeroes_count[ii]=1)and(not IsZero(a[ii,num_eq])) then
      begin
        used[ii]:=tqBad;
        ASSERT(false);
      end;
    end;
  end;//for i:=1 to n do            {пробегаем все уравнения}

end;//procedure solve;              {прямой ход метода Гаусса}

procedure back;
var i,j,ii:integer;
    k:double;
begin
  for i:=n downto 1 do
  if used[i]=tqUsed then
  begin
    j:=main[i];

    if(IsZero(a[i,j]))then
    begin
      writeln(log,'can''t count');
      ASSERT(false);
      xx[j]:=0;
      {exit;}
    end
    else
    begin
      xx[j]:=a[i,num_eq]/a[i,j];
      if IsZero(xx[j]) then
        xx[j]:=0;

      for ii:=i-1 downto 1 do
      begin
        if not IsZero(a[ii,j]) then
        begin
          k:=a[ii,j];
          a[ii,j]:=0;
          a[ii,num_eq]:=a[ii,num_eq]-k*xx[j];
        end;
      end;
    end;
  end;
end;

function func(x,y:double):double;
var k,i,v1,v2,v3:integer;
    a:array[0..9]of double;
begin

  if output_type=1 then
  begin
    a[0]:=-37.392;
    a[1]:=0.3440;
    a[2]:=  -0.9804;
    a[3]:=   0.028;
    a[4]:=   0.564;
    a[5]:=  0.0760;
    a[6]:=   -0.181;
    a[7]:=   0.181;
    a[8]:=   -0.04;
    a[9]:=  0.027;

//    for i:=0 to 9 do
//      a[i]:=a[i]/10;

//    Result:=a[0]+a[1]*x+a[2]*y+a[3]*x*x+
//          a[4]*x*y+a[5]*y*y+a[6]*x*x*x+
//          a[7]*x*x*y+a[8]*x*y*y+a[9]*y*y*y;

    //result:=sin(x)+0.5*sin(y)+2;
    result:=sqr(2*x-0.5)+sqr(1*y+0.5)+0.3;

//    result:=sqr(result)*result;
    result:=1/result;
    exit;
  end;

  k:=-1;

  for i:=1 to nv do
  begin
    if (x=verticies[i].x)and(y=verticies[i].y) then
    begin
      func:=-555;
      exit;
    end;
  end;

  for i:=1 to nt do
  begin
    v1:=triangles[i].v[1];
    v2:=triangles[i].v[2];
    v3:=triangles[i].v[3];

    if pointintriangle(x,y,verticies[v1].x,verticies[v1].y,verticies[v2].x,verticies[v2].y,
       verticies[v3].x,verticies[v3].y) then
    begin
      k:=i-1;
      break;
    end;
  end;

  if k<0 then
  begin
    func:=-777;
    exit;
  end;
  Result:=splines[k][0]+splines[k][1]*x+splines[k][2]*y+splines[k][3]*x*x+
          splines[k][4]*x*y+splines[k][5]*y*y+splines[k][6]*x*x*x+
          splines[k][7]*x*x*y+splines[k][8]*x*y*y+splines[k][9]*y*y*y;
end;


function checkEQ_GOOD:boolean;
begin
  result:=(EQ_GOOD_prev=EQ_GOOD);
end;

var freevars:array[1..num_eq_n]of integer;
    freevals:array[0..num_eq_n]of double;
    nf:integer;

function check_second_derrivatives(outp:boolean):double;
var s1,s2,i,v1,v2:integer;
    x,y,fx1,fy1,fx2,fy2:double;
begin
  Result:=0;
  
  for i:=1 to ne do
  begin
    if (outp)then
      writeln(log,'----------checking second derr ',i);

    v1:=edges[i].v[1];
    v2:=edges[i].v[2];

    s1:=edges[i].tr[1];
    s2:=edges[i].tr[2];

    x:=(verticies[v1].x+verticies[v2].x)/2;
    y:=(verticies[v1].y+verticies[v2].y)/2;

    fx1:=second_X_derivative(s1,x,y);
    fx2:=second_X_derivative(s2,x,y);
    fy1:=second_Y_derivative(s1,x,y);
    fy2:=second_Y_derivative(s2,x,y);

    Result:=Result+sqr(fx2-fx1)+sqr(fy2-fy1);//111
    if outp then
    begin
      if not IsZero(fx1-fx2)then
        writeln(log,'second derrivative x error ',i,' ',s1,' ',s2,' ',fx1:0:3,' ',fx2:0:3);
      if not IsZero(fy1-fy2)then
        writeln(log,'second derrivative y error ',i,' ',s1,' ',s2,' ',fx1:0:3,' ',fx2:0:3);
    end;
  end;
end;

procedure check_first_derrivatives;
var s1,s2,i,v1,v2:integer;
    x,y,fx1,fy1,fx2,fy2:double;
begin
  for i:=1 to ne do
  begin
    writeln(log,'----------checking derr ',i);

    v1:=edges[i].v[1];
    v2:=edges[i].v[2];

    s1:=edges[i].tr[1];
    s2:=edges[i].tr[2];

    x:=(verticies[v1].x+verticies[v2].x)/2;
    y:=(verticies[v1].y+verticies[v2].y)/2;

    fx1:=first_X_derivative(s1,x,y);
    fx2:=first_X_derivative(s2,x,y);
    fy1:=first_Y_derivative(s1,x,y);
    fy2:=first_Y_derivative(s2,x,y);

    if not IsZero(fx1-fx2)then
      writeln(log,'derrivative x error ',i,' ',s1,' ',s2,' ',fx1:0:3,' ',fx2:0:3);
    if not IsZero(fy1-fy2)then
      writeln(log,'derrivative y error ',i,' ',s1,' ',s2,' ',fx1:0:3,' ',fx2:0:3);
  end;
end;

procedure backspecial;
var i,j,ii,jj:integer;
begin
  for i:=0 to nt*10-1 do
  begin
    if i>=num_eq_n then
    begin
      ASSERT(false);
      break;
    end;
    setted[i]:=false;
    for j:=0 to nf do
      xxx[i][j]:=0;
  end;

  for i:=1 to nf do
  begin
    xxx[freevars[i]][i]:=1;
    setted[freevars[i]]:=true;
  end;

  for i:=n downto 1 do
  if (used[i]=tqUsed) then
  begin
    ii:=main[i];//ii-main elemet of the row
    if setted[ii] then
      continue;

    for j:=0 to num_eq-1 do
      if (j<>ii)and(not IsZero(a[i,j]))then
      begin
        //must substract here var № j from var № ii
        for jj:=0 to nf do
          xxx[ii][jj]:=xxx[ii][jj]-a[i,j]*xxx[j][jj];
      end;

    //must add here a[i,num_eq] to var № ii

    xxx[ii][0]:=xxx[ii][0]+a[i,num_eq];

    ASSERT(IsZero(1-a[i,ii]));

    setted[ii]:=true;
  end;
  //we have counted koeffs before notfree vars.

  // now we must get sysyem and find freevars
  countfreevars;
  outp_aaa;
  solve_aaa;
end;

var jjj:array[1..1000,0..10]of double;
    aaa:array[1..10,0..10]of double;

procedure countfreevars;
var k1,k2,i,j,ii,v1,v2:integer;
    x,y,sum:double;

procedure add_koeffs(edgenum,xnum:integer;k:double);
var j:integer;
begin
  for j:=0 to nf do
    jjj[edgenum][j]:=jjj[edgenum][j]+k*xxx[xnum][j];
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
      jjj[i][j]:=0;
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
  end;
  //now we have koeffs for J on every edge

  //we must get a system for finding freevars
  for i:=1 to nf do
  begin
    for j:=0 to nf do
    begin
      //finding aaa[i,j]
      sum:=0;

      for ii:=1 to ne do
        sum:=sum+jjj[ii][i]*jjj[ii][j];

      aaa[i,j]:=sum;
    end;
  end;
end;

procedure outp_aaa;
var i,j,k1,k2:integer;
begin
  k1:=8;
  k2:=2;

  for i:=1 to nf do
  begin
    for j:=0 to nf do
      write(log,aaa[i,j]:k1:k2,' ');
    writeln(log);
  end;
end;

procedure solve_aaa;
var i,j,ii,jj:integer;
    k:double;
    main:array[1..10]of integer;
begin
  for i:=1 to nf do
  begin
    j:=1;
    while (j<=nf)and(aaa[i,j]=0) do inc(j);
    if j>nf then
    begin
      ASSERT(false);
      exit;
    end;

    main[i]:=j;
    //processing all other equations
    k:=aaa[i,j];
    for jj:=0 to nf do
    if not IsZero(aaa[i,jj])then
      aaa[i,jj]:=aaa[i,jj]/k;

    for ii:= i+1 to nf do
    if not IsZero(aaa[ii,j]) then
    begin
      k:=aaa[ii,j];
      for jj:=0 to nf do
        aaa[ii,jj]:=aaa[ii,jj]-k*aaa[i,jj];
    end;
  end;

  //back processing

  for i:=nf downto 2 do
  begin
    for j:=i-1 downto 1 do
    begin
      k:=aaa[j][main[i]];
      aaa[j][main[i]]:=0;

      aaa[j][0]:=aaa[j][0]-k*aaa[i][0];
    end;
  end;

end;

procedure interpolate;
var (*tr1,tr2,*)i,j,ii,tip:integer;
    t:boolean;
//    val1,val2,g,b,b2,g2:double;
begin
  interpolate2;
  exit;

  tip:=0;

  init(0);

  solve(false);

  outp_eq_usage;

//finding free vars
  nf:=0;
  t:=false;
  for i:=0 to num_eq-1 do
    if not IsZero(a[n,i])then
    begin
      if t then
      begin
        inc(nf);
        freevars[nf]:=i;
      end;
      t:=true;
    end;

  freevals[0]:=1;
  for i:=1 to nf do
    freevals[i]:=0;

  if tip=0 then
    back
  else
    backspecial;

  outp_eq_usage;

  for i:=1 to nf do
    freevals[i]:=-aaa[i][0];

  if tip=1 then
    for i:=0 to nt-1 do
      for j:=0 to 9 do
      begin
        xx[i*10+j]:=0;
        for ii:=0 to nf do
          xx[i*10+j]:=xx[i*10+j]+xxx[i*10+j][ii]*freevals[ii];
      end;

  for i:=0 to nt-1 do
    for j:=0 to 9 do
      splines[i][j]:=xx[i*10+j];

  csd:=check_second_derrivatives(false);
  outpsol;
  init(0);
  checksol(true);

  ///
(*  for i:=1 to ne do
  begin
    tr1:=edges[i].tr[1]*10;
    tr2:=edges[i].tr[2]*10;

    b:=edges[i].b;
    g:=edges[i].g;
    b2:=b*b;
    g2:=g*g;

    //{8}xx[tr1+8]
    //{7}3*g2*xx[tr1+9]+xx[tr1+7]
    //{6}xx[tr1+4]+2*g*xx[tr1+5]+6*g*b*xx[tr1+9];
    //{5}xx[tr1+1]+2*g*b*xx[tr1+5]+6*g*b2*xx[tr1+9];
    //{4}xx[tr1+6]-2*g*g2*xx[tr1+9];
    //{3}xx[tr1+3]-g2*xx[tr1+5]-6*g2*b*xx[tr1+9];
    //{2}xx[tr1+2]-2*b*xx[tr1+5]+3*b2*xx[tr1+9];
    //{1}xx[tr1+0]-b2*xx[tr1+5]+2*b2*b*xx[tr1+9];

    val1:=xx[tr1+0]-b2*xx[tr1+5]+2*b2*b*xx[tr1+9];
    val2:=xx[tr2+0]-b2*xx[tr2+5]+2*b2*b*xx[tr2+9];

    if abs( val1-val2 )>0.0001 then
      Assert(false);
  end;*)

  ///

  check_first_derrivatives;
  candraw:=true;
end;

{$include unit2_02.inc}

procedure generategrid(filename:string;num:integer);
var xx,yy,xl,yl:double;
    g:textfile;
    i,j:integer;
begin
  xl:=(xmax-xmin)/num;
  yl:=(ymax-ymin)/num;

  assign(g,filename);
  rewrite(g);

  writeln(g,num,' ',num);

  xx:=xmin;
  for i:=1 to num do
  begin
    yy:=ymin;
    for j:=1 to num do
    begin
      writeln(g,xx:0:3,' ',yy:0:3,' ',func(xx,yy):0:3);

      yy:=yy+yl;
    end;

    xx:=xx+xl;
  end;

  close(g);
end;

initialization
  EQ_GOOD:=-1;
  assignfile(log,'log');
  rewrite(log);

  output_type:=0;
  candraw:=false;

  xmin:=10000;
  xmax:=-10000;
  ymin:=10000;
  ymax:=-10000;
  zmin:=10000;
  zmax:=-10000;

finalization
  closefile(log);

end.

