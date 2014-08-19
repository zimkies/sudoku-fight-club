require 'benchmark'
class TES
attr_accessor :b
def initialize(b);@b=b.split("");end
def s?;!b.index"_"; end
def ec;b.map.with_index{|c,i|c=="_"?i:nil}.select{|c|c};end
def r j;l=j%9;start=j-l;(start..start+8).to_a.map{|i|b[i]};end
def c j;b.select.with_index{|c,i|i%9==j%9};end
def s j;b.select.with_index{|c,i|(i/27)*3+(i/3)%3==(j/27)*3+(j/3)%3};end
def pn j;(1..9).to_a-r(j)-c(j)-s(j);end
def solve;e;g unless s?||!v?;Board.new(b.join);end
def e;ec.each{|j|p=pn j;if p.length==0;b[j]=-1;break;end;if p.length==1;b[j]=p[0];e;break;end;};end
def g;c=ec.min_by{|p|pn(p).length};pn(c).each{|p|t=TES.new(@b.join);t.b[c]=p;t.solve;if t.s? && t.v?;@b=t.b;break;end;};@b;end
def v?;!@b.index -1;end
end
class Board
def initialize n;@n=n;end
def self.from_file f;new(f.map{|l|l.strip.gsub(' ','')}.join);end
def to_number;@n;end
end