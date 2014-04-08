import unittest
from elementary_ca import *

class TestElementaryCa(unittest.TestCase):
    def test_digits(self):
        self.assertEqual( digits(5,3), [1,0,1] )
        self.assertEqual( digits(5,4), [1,0,1,0])
        self.assertEqual( digits(0,3), [0,0,0] )
        self.assertEqual( digits(30,8), [0,1,1,1,1,0,0,0])

    def test_from_digits(self):
        self.assertEqual( from_digits( [1,0,1]), 5 )
        self.assertEqual( from_digits( []), 0 )
        self.assertEqual( from_digits( [1] ), 1)
        self.assertEqual( from_digits( [0,1,1,1,1,0,0,0]), 30 )

    def test_from_digits_rev(self):
        for x in range(1000):
            ds = digits(x, 12)
            ids = ds[::-1]
            self.assertEqual( from_digits(ds[::-1]), from_digits_rev(ds) )

    def test_to_from_digits_big(self):
        for i in range(1000):
            self.assertEqual( from_digits( digits(i, 12)), i )

    def test_is_additive(self):
        oand = lambda x,y: x & y
        oor = lambda x,y: x | y
        oxor = lambda x,y: x ^ y

        self.assertTrue( is_additive( index2table(0), oand ) )
        self.assertTrue( is_additive( index2table(0), oor ) )

        self.assertTrue( is_additive( index2table(90), oxor ) )
        self.assertTrue( is_additive( index2table(250), oor ) )

        self.assertFalse( is_additive( index2table(90), oor ) )
        self.assertFalse( is_additive( index2table(250), oxor ) )


    def test_is_linear(self):
        self.assertTrue( is_linear( index2table( 0 ) ) )
        self.assertFalse( is_linear( index2table( 110 ) ))
        self.assertFalse( is_linear( index2table( 30 ) ))
        self.assertFalse( is_linear( index2table( 255 ) ))

        for shift_index in [170, 204, 240]:
            self.assertTrue( is_linear( index2table( shift_index ) ) )

        self.assertTrue( is_linear( index2table( 170 ^ 204 ) ) )
        self.assertTrue( is_linear( index2table( 170 ^ 240 ) ) )
        self.assertTrue( is_linear( index2table( 170 ^ 204 ^ 240 ) ) )
                          

    def test_mirror_ca(self):
        self.assertEqual( mirror_ca(index2table(0)), 
                          index2table(0) )
        self.assertEqual( mirror_ca(index2table(150)),
                          index2table(150) )
        self.assertEqual( mirror_ca(index2table(170)),
                          index2table(240) )
        self.assertEqual( mirror_ca(index2table(240)),
                          index2table(170) )

        self.assertNotEqual( mirror_ca(index2table(240)),
                             index2table(240) )

        self.assertNotEqual( mirror_ca(index2table(170)),
                             index2table(170) )
        
    def test_evaluate(self):
        automaton30 = index2table(30)
        field = [0,0,0,0,1,0,0,0,0]
        
        field = tfm( [0]+field+[0], automaton30)
        self.assertEqual( field, [0,0,0,1,1,1,0,0,0] )

        field = tfm( [0]+field+[0], automaton30)
        self.assertEqual( field, [0,0,1,1,0,0,1,0,0] )

        field = tfm( [0]+field+[0], automaton30)
        self.assertEqual( field, [0,1,1,0,1,1,1,1,0] )

    def test_evaluate_circular(self):
        shift_automaton = index2table(170)
        field = [0,0,1,0]
        
        field = tfm_circular( field, shift_automaton)
        self.assertEqual( field, [0,1,0,0] )
        field = tfm_circular( field, shift_automaton)
        self.assertEqual( field, [1,0,0,0] )
        field = tfm_circular( field, shift_automaton)
        self.assertEqual( field, [0,0,0,1] )
        
    
