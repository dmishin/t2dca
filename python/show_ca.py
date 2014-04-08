from time2d_ca import *
from matplotlib import pyplot as pp
from optparse import OptionParser

if __name__=="__main__":

    parser = OptionParser(usage = "%prog [options] ca_index\nShow CA diagram")

    parser.add_option("-p", "--pattern", dest="pattern",
                      default = "1",
                      help="define initial pattern, default is 1", metavar="PATTERN")
    parser.add_option("-w", "--width", dest="width",
                      default = 101,
                      type=int,
                      help="width", metavar="CELLS")
    parser.add_option("-t", "--time", dest="time",
                      default = 100,
                      type=int,
                      help="time (height)", metavar="STEPS")
    
    (options, args) = parser.parse_args()
    
    if len(args) > 1:
        parser.error("Too many args")
    elif len(args) == 1:
        index = int(args[0])
        if index < 0 or index >= 256:
            parser.error("Index out of range")
    else:
        parser.error("CA not specified")
    
    table = index2table(index)
    
    field = [0]*options.width

    pattern = list(map(int, options.pattern))
    for pi in pattern:
        if pi not in (0,1):
            parser.error("Pattern must contain only 0 and 1")
    put_at = (options.width - len(pattern)) // 2
    field[put_at:put_at+len(pattern)] = pattern
    
    fields = [field]
    for i in range(options.time):
        field = tfm([field[-1]]+field+[field[0]], table)
        fields.append(field)

    pp.matshow( fields )
    pp.show()
