import csv
from elementary_ca import *

def load_data(fname):
    data = []
    with open(fname, "r") as f:
        for row in csv.reader(f, delimiter=","):
            i1, i2 = map(int, row)
            data.append((i1,i2))
    return data


def are_interchangible(tbl1, tbl2):
    for i in range(2**5):
        fld = digits(i,5)
        a12 = tfm(tfm(fld,tbl2),tbl1)
        a21 = tfm(tfm(fld,tbl1),tbl2)
        assert len(a12) == 1 and len(a21) == 1
        if a12[0] != a21[0]:
            return False
    return True


def do_search_compatible( fname ):
    interchangibles = []

    for i1 in range(2**8):
        tbl1 = index2table(i1)
        for i2 in range(i1+1, 2**8):
            tbl2 = index2table(i2)
            if are_interchangible(tbl1, tbl2):
                interchangibles.append( (i1, i2) )

    with open(fname, "w") as ofile:
        for i1, i2 in interchangibles:
            ofile.write("%d, %d\n"%(i1,i2))    
    print ("Found:", len(interchangibles))
    print ("Wrote file", fname)

    

if __name__=="__main__":
    t = index2table(110)
    print (tfm([1,1,0,0,0,0,0,0], t))
    fname = "time2d_compatible_automata.csv"
    do_search_compatible(fname)
