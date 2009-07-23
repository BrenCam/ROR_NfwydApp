# To change this template, choose Tools | Templates
# and open the template in the editor.

def printarray (a)
	a.each_with_index { |i,x| printf("index: %s, value = %s; \n",x,i)}
end


#puts "Hello World"
l = ['a','b','c','d','e']
wlist =%w(one two three)
printarray(wlist)
#printarray(l)
puts  "\n>>> Done <<<"