program triangulate;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows;

var inputfilename,outputfilename,s:string;

procedure OutputHelp;
begin
  writeln;
  writeln('Triangulation Program');
  writeln('Usage: triangulate <input file> <output file>');
end;

var edges:array[1..10000]of record e1,e2,count:integer;tr:array[1..2]of integer;end;
    tr:array[1..10000]of record v1,v2,v3:integer;end;
    vert:array[1..10000]of record s:string;tr:integer;end;
    ne,nt,nv:integer;

procedure CreateVerticiesList;
var f:textfile;
begin
  assignfile(f,inputfilename);
  reset(f);
  nv:=0;
  while not eof(f) do
  begin
    readln(f,s);

    inc(nv);
    vert[nv].s:=s;
    vert[nv].tr:=-1;
  end;
  closefile(f);
end;

procedure CreateEdgesList;
var f:textfile;
    i,x1,x2:integer;
begin
  assignfile(f,'111.bat');
  rewrite(f);
  s:='triangulate ' + inputfilename + ' -M > ' + outputfilename;
  writeln(f,s);
  closefile(f);

  WinExec('111.bat', SW_RESTORE);
//
  Sleep(500);

  assignfile(f,outputfilename);
  reset(f);
  ne:=0;
  while not eof(f) do
  begin
    readln(f,s);

    delete(s,1,7);
    i:=pos('-',s);
    x1:=strtoint(copy(s,1,i-1));
    x2:=strtoint(copy(s,i+1,length(s)));

    inc(ne);
    edges[ne].e1:=x1+1;
    edges[ne].e2:=x2+1;
    edges[ne].count:=0;

    readln(f,s);
    readln(f,s);
  end;
  closefile(f);
end;

procedure CreateTrianglesList;
var f:textfile;
begin
  assignfile(f,'111.bat');
  rewrite(f);
  s:='triangulate ' + inputfilename + ' > ' + outputfilename;
  writeln(f,s);
  writeln(f,'del .gmtcommands');
  closefile(f);

  WinExec('111.bat', SW_RESTORE);
  Sleep(400);

  assign(f,'111.bat');
  erase(f);

//

  assignfile(f,outputfilename);
  reset(f);
  nt:=0;
  while not eof(f) do
  begin
    inc(nt);
    readln(f,tr[nt].v1,tr[nt].v2,tr[nt].v3);

    inc(tr[nt].v1);
    inc(tr[nt].v2);
    inc(tr[nt].v3);

    if vert[tr[nt].v1].tr<0 then vert[tr[nt].v1].tr:=nt;
    if vert[tr[nt].v2].tr<0 then vert[tr[nt].v2].tr:=nt;
    if vert[tr[nt].v3].tr<0 then vert[tr[nt].v3].tr:=nt;
  end;
  closefile(f);
end;

procedure CountEdgesNum;
var i,x1,x2,x3,buf:integer;

  procedure AddEdge(v1,v2,trnum:integer);
  var i:integer;
  begin
    i:=1;
    while (i<=ne)and(edges[i].e1<=v1)do
    begin
      if (edges[i].e1=v1)and(edges[i].e2=v2)then
        break;
      inc(i);
    end;

    if i>ne then
    begin
      writeln('Error01');
      halt;
    end;

    inc(edges[i].count);
    edges[i].tr[edges[i].count]:=trnum;
  end;

begin
  for i:=1 to nt do
  begin
    x1:=tr[i].v1;
    x2:=tr[i].v2;
    x3:=tr[i].v3;

    if x1>x2 then begin buf:=x1;x1:=x2;x2:=buf;end;
    if x2>x3 then begin buf:=x2;x2:=x3;x3:=buf;end;
    if x1>x2 then begin buf:=x1;x1:=x2;x2:=buf;end;

    AddEdge(x1,x2,i);
    AddEdge(x2,x3,i);
    AddEdge(x1,x3,i);
  end;
end;

procedure OutputNewData;
var g:textfile;
    i,num:integer;
begin
  assignfile(g,outputfilename);
  rewrite(g);

  num:=0;
  for i:=1 to ne do
    if edges[i].count=2 then inc(num);

  writeln(g,num);
  writeln(g);

  for i:=1 to ne do
    if edges[i].count=2 then
      writeln(g,edges[i].tr[1]-1,' ',edges[i].tr[2]-1,' ',edges[i].e1,' ',edges[i].e2);
  writeln(g);

  writeln(g,nv);
  writeln(g);

  for i:=1 to nv do
    writeln(g,vert[i].tr-1,' ',vert[i].s);
  writeln(g);

  writeln(g,nt);
  writeln(g);

  for i:=1 to nt do
    writeln(g,tr[i].v1,' ',tr[i].v2,' ',tr[i].v3);

  close(g);
end;

begin
  if ParamCount<2 then
  begin
    OutputHelp;
    halt;
  end;

  inputfilename:=ParamStr(1);
  outputfilename:=ParamStr(2);

  CreateVerticiesList;
  CreateEdgesList;
  CreateTrianglesList;

  CountEdgesNum;

  OutputNewData;

end.
