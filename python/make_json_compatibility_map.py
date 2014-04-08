from matplotlib import pyplot as pp
from collections import Counter
import json

from elementary_ca import is_linear, index2table, is_additive, table2index, mirror_ca
from time2d_ca import load_data
import os.path


mapped = dict()

all_pairs = set()

for a, b in load_data("time2d_compatible_automata.csv"):
    all_pairs.add((a,b))
    all_pairs.add((b,a))
    akey = "%x"%a
    bkey = "%x"%b
    try:
        a_rules = mapped[akey]
    except KeyError:
        a_rules = dict()
        mapped[akey] = a_rules
    a_rules[bkey] = 1


rule_props = dict()

byNumberOfDuals = Counter()
for rule in range(256):
    rtable = index2table(rule)
    mirror_index = table2index(mirror_ca(rtable))

    nduals = sum(1 for r in range(256) if (r,rule) in all_pairs)
    byNumberOfDuals[nduals] += 1
    flags=[]
    if is_additive( rtable, lambda x,y: x|y):
        flags.append("|")
    if is_additive( rtable, lambda x,y: x&y):
        flags.append("&")
    if is_additive( rtable, lambda x,y: x^y):
        flags.append("^")
    props = { "flags": "".join(flags),
              "mirror": "%x"%(mirror_index),
              "nduals": "%x"%(nduals) }
    rule_props["%x"%rule] = props

print("How many duals numbers have:")
print("N duals\tCount")
for nDuals, count in byNumberOfDuals.most_common():
    print( "%d\t%d"%(nDuals, count))
print("--------")

ofile = "rules_compatibility_map.js"
if not os.path.exists(ofile):
    with open(ofile, "w") as ofile:
        ofile.write("window.RULES_COMPATIBILITY_MAP=")
        json.dump(mapped, ofile, separators=(',', ':'))
        ofile.write(";\n")
        ofile.write("window.RULE_PROPERTIES=");
        json.dump(rule_props, ofile, separators=(',', ':'))
        ofile.write(";\n")
else:
    print(ofile, "already exists, not touching it")
    
    
