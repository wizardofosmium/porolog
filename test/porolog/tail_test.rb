#
#   test/porolog/tail_test.rb     - Test Suite for Porolog::Tail
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end

  describe 'Tail' do
    
    describe '.new' do
      
      it 'creates an unknown tail when no value is provided' do
        tail = Tail.new
        
        assert_Tail               tail,             '*...'
        assert_equal              UNKNOWN_TAIL,     tail.value
      end
      
      it 'creates a tail with a value' do
        tail = Tail.new [2,3,5,7,11,13]
        
        assert_Tail               tail,             '*[2, 3, 5, 7, 11, 13]'
        assert_equal              [2,3,5,7,11,13],  tail.value
      end
      
      it 'creates a tail with a variable' do
        tail = Tail.new :x
        
        assert_Tail               tail,             '*:x'
        assert_equal              :x,               tail.value
      end
      
    end
    
    describe '#value' do
      
      let(:object) { Object.new }
      
      before do
        def object.inspect
          super.gsub(/Object:0x[[:xdigit:]]+/,'Object:0xXXXXXX')
        end
      end
      
      it 'returns its value' do
        tail = Tail.new object
        
        assert_Tail               tail,             '*#<Object:0xXXXXXX>'
        assert_equal              object,           tail.value
      end
      
    end
    
    describe '#inspect' do
      
      it 'returns a string showing a splat operation is implied' do
        tail = Tail.new [2,3,5,7,11,13]
        
        assert_equal      '*[2, 3, 5, 7, 11, 13]',  tail.inspect
      end
      
    end
    
    describe '#variables' do
      
      it 'returns an empty Array when it was created without arguments' do
        tail = Tail.new
        
        assert_equal      [],                       tail.variables
      end
      
      it 'returns an empty Array when it was created with an Array of atomics' do
        tail = Tail.new [2,3,5,7,11,13]
        
        assert_equal      [],                       tail.variables
      end
      
      it 'returns an Array of Symbols when it was created with a Symbol' do
        tail = Tail.new :t
        
        assert_equal      [:t],                     tail.variables
      end
      
      it 'returns an Array of Symbols when it was created with an Array with embedded Symbols' do
        tail = Tail.new [2,3,:x,7,[:y,[:z]],13]
        
        assert_equal      [:x,:y,:z],               tail.variables
      end
      
    end
    
    describe '#==' do
      
      it 'returns true for unknown tails' do
        tail1 = Tail.new
        tail2 = Tail.new
        
        assert            tail1 == tail2, name
      end
      
      it 'returns false for different symbols' do
        tail1 = Tail.new :t
        tail2 = Tail.new :x
        
        refute            tail1 == tail2, name
      end
      
      it 'returns true for equal values' do
        tail1 = Tail.new 12.34
        tail2 = Tail.new 12.34
        
        assert            tail1 == tail2, name
      end
      
    end
    
  end

end
