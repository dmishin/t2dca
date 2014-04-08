from matplotlib import pyplot as pp
from numpy import array, zeros

from time2d_ca import load_data, is_linear, index2table


shift_automata = {170, 204, 240} #These 3 automata simply shift the cells
boring_automata = shift_automata.union({0, 255-0, 255-170, 255-204, 255-240})
linear_automata = set( i for i in range(256) if is_linear(index2table(i)))

def as_matrix(d):
    mtx = zeros((256, 256))
    for i1,i2 in d:
        mtx[i1,i2] = 1
        mtx[i2,i1] = 1

    for i in range(256):
        mtx[i,i] = 1
    return mtx

def show_nonlinear(d):
    print ("Linear automata are:", list(sorted(linear_automata)))
    noticed = set()
    for i1,i2 in d:
        if i1 == 0 or i2 == 255: continue
        if i1 in shift_automata or i2 in shift_automata: continue
        if i1 not in linear_automata or i2 not in linear_automata:
            print (i1, i2)
            noticed.add(i1)
            noticed.add(i2)
    print ("All noticed automata:", list(sorted(noticed)))

if __name__=="__main__":
    d = load_data("time2d_compatible_automata.csv")

    #show_nonlinear(d)

    pp.matshow(as_matrix(d))
    pp.show()
    

    
