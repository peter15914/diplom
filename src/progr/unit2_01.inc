procedure outp;forward;
procedure countfreevars;forward;
procedure outp_aaa;forward;
procedure solve_aaa;forward;

function getxmin:double;
begin Result:=xmin; end;

function getxmax:double;
begin Result:=xmax; end;

function getymin:double;
begin Result:=ymin; end;

function getymax:double;
begin Result:=ymax; end;

function getzmin:double;
begin Result:=zmin; end;

function getzmax:double;
begin Result:=zmax; end;

function min(x,y:double):double;
begin
  min:=x;
  if y<x then min:=y;
end;

function max(x,y:double):double;
begin
  max:=x;
  if x<y then max:=y;
end;

function max2(x,y:integer):integer;
begin
  max2:=x;
  if x<y then max2:=y;
end;

function troika(x1,y1,x2,y2,x3,y3:double):double;
var val:double;
begin
  val:=x1*y2-y1*x2+x2*y3-y2*x3-x1*y3+y1*x3;

  if val<0 then troika:=-1
  else troika:=1;
end;

function pointintriangle(x,y,x1,y1,x2,y2,x3,y3:double):boolean;
var t1,t2,t3,t4:double;
begin
  Result:=true;

  if (x=x1)and(y=y1)then exit;
  if (x=x2)and(y=y2)then exit;
  if (x=x3)and(y=y3)then exit;

  t1:=troika(x1,y1,x2,y2,x3,y3);
  t2:=troika(x,y,x1,y1,x2,y2);
  t3:=troika(x,y,x2,y2,x3,y3);
  t4:=troika(x,y,x3,y3,x1,y1);

  result:=(t1=t2)and(t2=t3)and(t3=t4);
end;

procedure outp;
var i,j:integer;
begin
  for i:=1 to n do
  begin
    write(log,i:2,' ');
    for j:=0 to num_eq do
      write(log,a[i,j]:6:2,' ');
    writeln(log);
  end;

  writeln(log,'---------------------------------------------');
  writeln(log);
end;


procedure outp_eq_usage;
var i,j:integer;
begin
  EQ_GOOD_prev:=EQ_GOOD;

  EQ_GOOD:=0;
  j:=0;

  writeln(log,'-------------------Equation usage------------');
  for i:=1 to n do
  begin
    if used[i]=tqBad then
    begin
      inc(j);
      writeln(log,j:2,'. Bad eq -',IntToStr(i),' ',desc[i])
    end
    else
    if used[i]=tqLComb then
    begin
      inc(j);
      writeln(log,j:2,'. LComb eq -',IntToStr(i),' ',desc[i])
    end
    else
      inc(EQ_GOOD);
  end;

  writeln(log,'---------------------------------------------');
  writeln(log);
end;

procedure outpsol;
var i,j:integer;
var k1,k2:integer;
begin
  k1:=8;
  k2:=2;

  for j:=0 to 9 do
  begin
    for i:=0 to (nt - 1) do
      write(log,xx[i*10+j]:k1:k2,' ');
    writeln(log);
  end;

  writeln(log);
//  writeln(log,'---------------------------------------------');
end;

function checksol(write_log:boolean):integer;
var i,j:integer;
    v1,v2,error:double;
    buf:array[0..num_eq_n]of double;
    s:string;
begin
  result:=checksol2(write_log);
  exit;

  Result:=0;

  if (write_log)then
    writeln(log,'checking solution');

  for i:=1 to n do
  if used[i]=tqUsed then
  begin
    v1:=0;
    v2:=0;

    for j:=0 to num_eq-1 do
      buf[j]:=xx[j]*a[i,j];

    for j:=0 to num_eq-1 do
      v1:=v1+buf[j];
//    for j:=10 to 19 do
//      v2:=v2+buf[j];

    if not IsZero(v1+v2-a[i,num_eq]) then
    begin
      if abs( v1+v2-a[i,num_eq] )>0.2 then
      begin
        s:='error in checking equation ';
        Result:=1;
      end
      else
      begin
        s:='small error in checking equation ';

        if result=0 then
          Result:=2;
      end;

      if (write_log)then
      begin
        error:=-666;
        if not IsZero(a[i,num_eq])then
          error:=abs((v1+v2)/a[i,num_eq]-1)
        else
        if not IsZero(v1+v2)then
          error:=abs(a[i,num_eq]/(v1+v2)-1);

        writeln(log,s,i,' ',desc[i],' ',v1+v2:0:3,' ',a[i,num_eq]:0:3,' ',error:0:3);
      end;
    end;
  end;

end;

function first_X_derivative(splinenum:integer;x,y:double):double;
var a:spline;
begin
  a:=splines[splinenum];
  Result:=a[1]+2*a[3]*x+a[4]*y+3*a[6]*x*x+2*a[7]*x*y+a[8]*y*y;
end;

function first_Y_derivative(splinenum:integer;x,y:double):double;
var a:spline;
begin
  a:=splines[splinenum];
  Result:=a[2]+2*a[5]*y+a[4]*x+a[7]*x*x+2*a[8]*x*y+3*a[9]*y*y;
end;

function second_X_derivative(splinenum:integer;x,y:double):double;
var a:spline;
begin
  a:=splines[splinenum];
  Result:=2*a[3]+6*a[6]*x+2*a[7]*y;
end;

function second_Y_derivative(splinenum:integer;x,y:double):double;
var a:spline;
begin
  a:=splines[splinenum];
  Result:=2*a[5]+2*a[8]*x+6*a[9]*y;
end;

procedure tempoutput;
var k1,k2,i,j:integer;
begin
  k1:=8;
  k2:=2;

  for j:=0 to 9 do
  begin
    for i:=0 to nt-1 do
      write(log,xxx[i*10+j][0]:k1:k2,' ');
    writeln(log);
  end;
end;

