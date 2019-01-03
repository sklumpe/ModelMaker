####################################################
# VMD Mutlimodel_RMSD Visualizer
# Sven Klumpe, November 2018
####################################################


#################################
# create plot of network of states of a molecular machine, 
# connected by weighted edges according to RMSD values
# Sven Klumpe, November 2018
#################################

from graphviz import Digraph
import numpy as np
from random import *
import sys
from Tkinter import *

def plot_multimodel(list,RMSD_matrix,window_size,window_upper_bound):
	dot = Digraph(comment='The Round Table')

	dot.graph_attr["layout"]="circo"
	dot.edge_attr['lblstyle']='above, sloped'
	#dot.attr('node',shape='circle')
	#dot.attr('node',shape='hexagon')

	#alphabet=['a','b','c','d','e','f','g','h','i','j','k','l]
	n=len(list)
	
	
	#random matrix for testing
	#RMSD_matrix=np.zeros((n,n))
	#for i in range(0,n):
	#	for j in range(0,n):
	#		RMSD_matrix[i,j]=randint(1,100)
	#print(RMSD_matrix)
	
	for i in range(0,n):
		dot.attr('node',shape='circle')
		dot.node(str(i),list[i])

#for i in range(1,n+1):
#	for j in range(i+1,n+1):
#		dot.attr('node',shape='box')
#		dot.node(str(i)+str(j),str(RMSD_matrix[i-1,j-1]))
	
	for i in range(0,n):
		for j in range(i+1,n):
			#edges_list.append(str(i)+str(j))
			dot.edge_attr['labeldistance']=str((i+1+j+1)/2.0)
			#dot.edge_attr['labeldistance']=str(randint(0,6))
			if i%2==1 and j%2==1:
				dot.edge(str(i),str(j), headlabel='''<<table border="0" cellborder="1" cellspacing="0"><tr><td bgcolor="white"><font color="black">'''+str(RMSD_matrix[i,j])+"</font></td></tr> </table>>", penwidth=str(10*(1/RMSD_matrix[i,j])))
			elif i%2==0 and j%2==0:
				dot.edge(str(i),str(j), taillabel='''<<table border="0" cellborder="1" cellspacing="0"><tr><td bgcolor="white"><font color="black">'''+str(RMSD_matrix[i,j])+"</font></td></tr> </table>>", penwidth=str(10*(1/RMSD_matrix[i,j])))
			elif j-i==1:
				dot.edge(str(i),str(j), headlabel='''<<table border="0" cellborder="1" cellspacing="0"><tr><td bgcolor="white"><font color="black">'''+str(RMSD_matrix[i,j])+"</font></td></tr> </table>>", penwidth=str(10*(1/RMSD_matrix[i,j])))
			else:
				dot.edge(str(i),str(j), taillabel='''<<table border="0" cellborder="1" cellspacing="0"><tr><td bgcolor="white"><font color="black">'''+str(RMSD_matrix[i,j])+"</font></td></tr> </table>>", penwidth=str(10*(1/RMSD_matrix[i,j])))

	dot.edge_attr['dir']='none'
	dot.edge_attr['fontsize']='6'
	dot.edge_attr['labelloc']='c'
	dot.edge_attr['labelangle']='2'
	dot.edge_attr['lblstyle']='above, sloped'
	#dot.edge_attr['style']='dotted'
	dot.render('bla2.gv',view=True)
	return()

#liste=['s1','s2','s3','s4','s5','s6']
matrix=[]
#liste1=sys.argv[1]
liste=[]
#for i in liste1:
#	liste.append(str(i))
for i in sys.argv:
	if i == sys.argv[0]:
		print('bla')
		continue
	if i == sys.argv[1]:
		for j in i.split(' '):
			if j=='':
				continue
			else:
				print(j)
				print j.split('.')[0]
				liste.append(str(j.split('.')[0]))
	else:
		print(i)

root = Tk()
#s=root.tk.eval('array get arr')
s=sys.argv[3]

def parse_tcl_matrix(array):
	splitted_array=array.split(' ')
	print(splitted_array)
	#print(len(splitted_array)/2)
	
	RMSD_matrix=np.zeros(((int(len(splitted_array)/4)),(int(len(splitted_array)/4))))
	for i in range(len(splitted_array)):
		if i%2==1:
			continue
		elif i == len(splitted_array)-1:
			break
		else:
			numbering=splitted_array[i].split(',')
			print(int(numbering[0]))
			if splitted_array[i+1]=='{}':
				continue
			else:
				RMSD_matrix[int(numbering[0]),int(numbering[1])]=round(float(splitted_array[i+1]),1)
	return(RMSD_matrix)	
#root=Tkinter.tk()
#s = root.tk.eval('array get arr')
#print(s)
matrix=parse_tcl_matrix(s)
#print(matrix)
max_value=np.amax(matrix)
#print(max_value)
min_value=np.amin(matrix)
window_size=(max_value-min_value)/3.0
window_upper_bound=max_value-window_size

#print(matrix)
#print(liste)
plot_multimodel(liste,matrix,window_size,window_upper_bound)