unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ColorGrd;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label3: TLabel;
    cb1: TCheckBox;
    i1: TPaintBox;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label4: TLabel;
    Edit5: TEdit;
    Edit6: TEdit;
    cb2: TCheckBox;
    Button4: TButton;
    SaveDialog1: TSaveDialog;
    Button5: TButton;
    OpenDialog1: TOpenDialog;
    cb3: TCheckBox;
    rg1: TRadioGroup;
    procedure FormPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure rg1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Unit2;

{$R *.dfm}

{
const
      c1=12;
      c2=10;
      c3=8;
      c4=7;
}

var c:array[1..800,1..600]of double;
    ct:boolean;
    pp:array[1..100]of double;
    np:integer;


procedure TForm1.FormPaint(Sender: TObject);
var i,j,w,h:integer;
    x1,x2,xc,yc,k,k1,k2,xx,yy,val,max,min,mm,xmax,ymax,xmin,ymin:double;
    r,g,b:integer;

  function realxval(x:double):integer;
  begin
    realxval:=round( (x-xc) /k)+w;
  end;
  function realyval(y:double):integer;
  begin
    realyval:=h-round( (y-yc) /k);
  end;

  procedure DrawTriangles;
  var v:array[1..3]of integer;
      i,j,j2:integer;
      x,y,xx,yy,xx2,yy2:double;
  begin
    for i:=1 to nt do
    begin
      v[1]:=triangles[i].v[1];
      v[2]:=triangles[i].v[2];
      v[3]:=triangles[i].v[3];

      x:=0;
      y:=0;
      for j:=1 to 3 do
      begin
        x:=x+verticies[v[j]].x;
        y:=y+verticies[v[j]].y;

        j2:=j+1;
        if j2>3 then j2:=j2-3;

        xx:=verticies[v[j]].x;
        yy:=verticies[v[j]].y;
        xx2:=verticies[v[j2]].x;
        yy2:=verticies[v[j2]].y;

        i1.Canvas.MoveTo(realxval(xx),realyval(yy));
        i1.Canvas.LineTo(realxval(xx2),realyval(yy2));
      end;

      x:=x/3;
      y:=y/3;

      i1.Canvas.TextOut(realxval(x),realyval(y),inttostr(i));
    end;
  end;

const xborder=10;//одинарные границы
      yborder=10;

var t,t2:boolean;
    lll:double;
    ii:integer;

begin
  if not candraw then exit;

  t:=cb2.Checked;
  t2:=cb3.Checked;

  w:=i1.Width  div 2;
  h:=i1.Height div 2;

  max:=-100000;
  min:=100000;

  xmax:=getxmax;
  xmin:=getxmin;
  ymax:=getymax;
  ymin:=getymin;

  k1:=(xmax-xmin)/(i1.Width-2*xborder);
  k2:=(ymax-ymin)/(i1.Height-2*yborder);

  xc:=(xmax+xmin)/2;
  yc:=(ymax+ymin)/2;

  if k1>k2 then k:=k1
  else k:=k2;

  if not ct then
  begin
    np:=0;
    inc(np);pp[np]:=0.4;
    inc(np);pp[np]:=0.45;
    inc(np);pp[np]:=0.5;
    inc(np);pp[np]:=0.55;
    inc(np);pp[np]:=0.6;
    inc(np);pp[np]:=0.65;
    inc(np);pp[np]:=0.7;
    inc(np);pp[np]:=0.75;
    inc(np);pp[np]:=0.8;
    inc(np);pp[np]:=0.85;
    inc(np);pp[np]:=0.9;
    inc(np);pp[np]:=0.95;
    inc(np);pp[np]:=1;
  end;

  for i:=1+xborder to i1.width-xborder do
    for j:=1+yborder to i1.height-yborder do
    begin
      if ct then
        val:=c[i,j]
      else
      begin
        xx:=(i-w)*k+xc; yy:=(h-j)*k+yc;
        val:=func(xx,yy);
        c[i,j]:=val;
      end;


      if (val>max)                             then max:=val;
      if (val<min)and(val<>-777)and(val<>-555) then min:=val;
    end;

//  max:=500;
//  min:=-500;

  ct:=true;

  if max<1000000 then
    edit1.text:=inttostr(round(max));
  if min>-1000000 then
    edit2.text:=inttostr(round(min));

  for i:=1+xborder to i1.width-xborder do
    for j:=1+yborder to i1.height-yborder do
    begin
      if ct then
        val:=c[i,j]
      else
      begin
        xx:=(i-w)*k+xc; yy:=(h-j)*k+yc;
        val:=func(xx,yy);
        c[i,j]:=val;
      end;

      if val=-555 then
      begin
        r:=255;
        g:=0;
        b:=0;

        i1.Canvas.pen.color:=rgb(r,g,b);
        i1.Canvas.brush.color:=rgb(r,g,b);

        i1.Canvas.Pixels[i,j]:=rgb(r,g,b);
      end
      else
      if (val<>-777)and((max-min<>0)or(max<>0)) then
      begin
        if val>max then val:=max;
        if val<min then val:=min;

        //shader
        if t and(i>1+xborder)and(i<i1.width-xborder)
//            and(j>1+yborder)and(j<i1.height-yborder)
            then
        begin
          x1:=c[i-1,j];
          x2:=c[i+1,j];

          lll:=arctan((x2-x1)/k);
          if  lll>PI/2.1 then
            val:=val/2;
        end;

        if max-min<>0 then
        begin
          val:=(val-min)/(max-min);
        end
        else val:=0.9;

        mm:=0.3;
        val:=mm+val*(1-mm);

        if val>1 then val:=1;

        if t2 then
        begin
          ii:=1;
          while (ii<=np)and(val>pp[ii]) do inc(ii);
          val:=pp[ii];
        end;  

//        r:=round(255*val/1.2); if r>255 then r:=255;
//        g:=round(255*val); if g>255 then g:=255;
//        b:=round(255*val/1.2); if b>255 then b:=255;

        r:=round(255*val/1.7); if r>255 then r:=255;
        g:=round(255*val/1.2); if g>255 then g:=255;
        b:=round(255*val); if b>255 then b:=255;

        i1.Canvas.Pixels[i,j]:=clbtnface;//rgb(r,g,b);
      end;
    end;

   if cb1.Checked then
     DrawTriangles;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if opendialog1.Execute then
  begin
    ct:=false;
    zmax:=-1000000;
    zmin:=1000000;
    xmax:=-1000000;
    xmin:=1000000;
    ymax:=-1000000;
    ymin:=1000000;
    readdata(opendialog1.filename);
    edit5.Text:=floattostr(getzmax);
    edit6.Text:=floattostr(getzmin);
    candraw:=false;
    repaint;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var ret:integer;
begin
  ct:=false;
  edit5.Text:=floattostr(getzmax);
  edit6.Text:=floattostr(getzmin);
  
  interpolate;

  ret:=checksol(false);

  if ret=0 then label3.Caption:='Solution is checked'
  else
  if ret=1 then label3.Caption:='Error'
  else
  if ret=2 then label3.Caption:='Small Error';

  edit3.Text:=inttostr(nt*10-EQ_GOOD);
  edit4.Text:=floattostr(csd);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=27 then close;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ct:=false;

  if rg1.itemindex>0 then
  begin
//    ct:=true;
//    candraw:=true;
  end;

  repaint
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if savedialog1.Execute then
    generategrid(savedialog1.filename,100);
end;

const num=100;
var tt:array[1..num,1..num]of record x,y,z:double;end;

procedure TForm1.Button5Click(Sender: TObject);
var i,j:integer;
    xl,xr,yl,yr,lx,ly:double;
    g:textfile;

var p:array[1..100]of record i,j:integer;end;
    np:integer;

begin
  xl:=-1;
  xr:=1;
  yl:=-1;
  yr:=1;

  lx:=(xr-xl)/(num-1);
  ly:=(yr-yl)/(num-1);

  for i:=1 to num do
  for j:=1 to num do
  begin
    tt[i,j].x:= xl+(j-1)*lx;
    tt[i,j].y:= yl+(i-1)*ly;
    tt[i,j].z:= func( tt[i,j].x, tt[i,j].y);
  end;

  assignfile(g,'aaqq.grd');
  rewrite(g);
  for i:=1 to num do
  for j:=1 to num do
    writeln(g,tt[i,j].x:0:3, ' ', tt[i,j].y:0:3, ' ', tt[i,j].z:0:3);

  closefile(g);

  np:=0;
  inc(np); p[np].i:=2; p[np].j:=1;
  inc(np); p[np].i:=num; p[np].j:=num-2;
  inc(np); p[np].i:=num-1; p[np].j:=3;
  inc(np); p[np].i:=1; p[np].j:=num -3;

  inc(np); p[np].i:=1; p[np].j:=4;
  inc(np); p[np].i:=num div 2-1; p[np].j:=num div 2;
  inc(np); p[np].i:=num div 2-2; p[np].j:=5;
  inc(np); p[np].i:=1; p[np].j:=num div 2-5;

  inc(np); p[np].i:=10; p[np].j:=11;
  inc(np); p[np].i:=19; p[np].j:=91;

  inc(np); p[np].i:=20; p[np].j:=12;
  inc(np); p[np].i:=29; p[np].j:=92;

  inc(np); p[np].i:=30; p[np].j:=13;
  inc(np); p[np].i:=31; p[np].j:=33;

  inc(np); p[np].i:=41; p[np].j:=34;
  inc(np); p[np].i:=42; p[np].j:=64;
  inc(np); p[np].i:=43; p[np].j:=94;

  inc(np); p[np].i:=50; p[np].j:=15;
  inc(np); p[np].i:=53; p[np].j:=95;

  inc(np); p[np].i:=60; p[np].j:=16;
  inc(np); p[np].i:=63; p[np].j:=96;

  inc(np); p[np].i:=70; p[np].j:=17;
  inc(np); p[np].i:=73; p[np].j:=97;

  inc(np); p[np].i:=80; p[np].j:=18;
  inc(np); p[np].i:=81; p[np].j:=38;
  inc(np); p[np].i:=82; p[np].j:=68;

  inc(np); p[np].i:=90; p[np].j:=19;
  inc(np); p[np].i:=93; p[np].j:=99;


  assignfile(g,'data5');
  rewrite(g);
  for i:=1 to np do
    writeln(g,tt[p[i].i,p[i].j].x:0:3, ' ', tt[p[i].i,p[i].j].y:0:3, ' ', tt[p[i].i,p[i].j].z:0:3);

  closefile(g);
end;

procedure TForm1.rg1Click(Sender: TObject);
begin
  output_type:=rg1.itemindex;
  xmin:=-1;
  xmax:=1;
  ymin:=-1;
  ymax:=1;
end;

initialization
  readdata('datanew');
  ct:=false;

end.
