exports = exports ? window

digits = ( x, n, p=2)->
  ds = []
  for i in [0...n] by 1
    ds.push(x % p)
    x = (x / p) | 0
  return ds

from_digits = ( ds, p=2)->
  x=0
  ppow = 1
  for d in ds
    x = x + d*ppow
    ppow *= p
  return x

from_digits_rev = ( ds, p=2)->
  x=0
  for d in ds
    x = x*p + d
  return x

exports.index2table = index2table = ( i )->digits(i, 8)

index2table.tfm = tfm = ( fld, table )->
  #"""transform the world. Decreases world length by 2"""
  ofld = []
  for i in [0 ... fld.length-2] by 1
    blk = fld[i...i+3]
    blk.reverse()
    code = from_digits blk
    ofld.push  table[code]
  return ofld

exports.tfm_circular = tfm_circular = ( fld, table )->  
  tfm ( [fld[fld.length-1]].concat(fld, [fld[0]])), table

is_linear = (table)->
  #"""returns true, if the linear ca is linear, relative to XOR operator"""
  for x1 in [0...8]
    for x2 in [0...8]
      if table[x1] ^ table[x2] isnt table[x1 ^ x2]
        return false
  true

__mirror_3_digits = (from_digits_rev(digits(i,3)) for i in [0...8] )

mirror_ca = (table)->
  for i in [0...8]
    table[__mirror_3_digits[i]]
      

mirror_ca_index = (idx)-> from_digits mirror_ca index2table idx
