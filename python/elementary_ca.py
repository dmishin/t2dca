def digits( x, n, p=2):
    ds = []
    for i in range(n):
        ds.append(x % p)
        x = x // p
    return ds

def from_digits( ds, p=2):
    x=0
    ppow = 1
    for d in ds:
        x = x + d*ppow
        ppow *= p
    return x

def from_digits_rev( ds, p=2):
    x=0
    for d in ds:
        x = x*p + d
    return x

def index2table( i ):
    return digits(i, 8)

def tfm( fld, table ):
    """transform the world. Decreases world length by 2"""
    ofld = []
    for i in range(len(fld)-2):
        code = from_digits_rev(fld[i:i+3])
        ofld.append( table[code] )
    return ofld

def tfm_circular( fld, table ):
    return tfm( [fld[-1]]+fld+[fld[0]], table )

def is_linear(table):
    """returns true, if the linear ca is linear, relative to XOR operator"""
    return is_additive(table, lambda x,y: x^y)

def is_additive(table, operation):
    for x1 in range(8):
        for x2 in range(8):
            if operation(table[x1], table[x2]) != table[operation(x1,x2)]:
                return False
    return True

__mirror_3_digits = [from_digits_rev(digits(i,3)) for i in range(8) ]
def mirror_ca(table):
    return [table[__mirror_3_digits[i]]
            for i in range(8) ]

def mirror_ca_index(idx):
    return table2index( mirror_ca( index2table( idx ) ) )
        
def table2index(table):
    assert(len(table) == 8)
    return from_digits(table)
