#
#   test/porolog/value_test.rb     - Test Suite for Porolog::Value
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end

  describe 'Value' do
    
    let(:goal) { new_goal :generic, [:m, :n] }
    let(:v)    { Value.new 456.123, goal }
    
    describe '.new' do
      
      it 'should create a new value' do
        assert_instance_of  Value,      v
      end
      
    end
    
    describe '#initialize' do
      
      it 'should initialize value and goal' do
        assert_equal        456.123,    v.value
        assert_equal        goal,       v.goal
      end
      
      it 'should raise an error when a goal is not provided' do
        assert_raises Value::GoalError do
          Value.new 456.789, 'goal'
        end
      end
      
      it 'should copy the value of another Value' do
        other = Value.new 123.456, goal
        v     = Value.new other,   goal
        
        refute_instance_of  Value,      v.value
        assert_equal        123.456,    v.value
      end
      
    end
    
    describe '#inspect' do
      
      it 'should show the goal and the value' do
        assert_equal        'Goal1.456.123',                            v.inspect
      end
      
    end
    
    describe '#instantiations' do
      
      it 'should return no instantiations' do
        assert_equal        [],                                         v.instantiations
      end
      
    end
    
    describe '#inspect_with_instantiations' do
      
      let(:depth) { rand(0..10) }
      let(:index) { rand(0..10) }
      
      it 'should should show the goal and value' do
        assert_equal        'Goal1.456.123',                            v.inspect_with_instantiations
      end
      
      it 'should should show the goal and indexed value' do
        assert_equal        "Goal1.456.123[#{index}]",                  v.inspect_with_instantiations(nil, 0, index)
      end
      
      it 'should should show the goal and value indentation showing instantiation depth' do
        assert_equal        "#{'  ' * depth}Goal1.456.123",             v.inspect_with_instantiations(nil, depth)
      end
      
      it 'should should show the goal and value indentation showing instantiation depth and indexed value' do
        assert_equal        "#{'  ' * depth}Goal1.456.123[#{index}]",   v.inspect_with_instantiations(nil, depth, index)
      end
      
    end
    
    describe '#remove' do
      
      let(:predicate1) { Predicate.new :removal }
      let(:arguments1) { predicate1.arguments(:m,:n) }
      let(:goal1)      { arguments1.goal }
      let(:goal2)      { arguments1.goal }
      let(:goal3)      { arguments1.goal }
      let(:goal4)      { arguments1.goal }
      
      let(:variable1)  { Variable.new :x,  goal1 }
      let(:variable2)  { Variable.new :y,  goal2 }
      let(:variable3)  { Variable.new :z,  goal3 }
      let(:variable4)  { Variable.new :a,  goal1 }
      let(:value1)     { Value.new 'word', goal2 }
      let(:value2)     { Value.new 'draw', goal4 }
      
      before do
        reset
        
        variable1.instantiate variable2
        variable1.instantiate variable3
        variable2.instantiate value1
        variable4.instantiate value2
        
        assert_Goal_variables     goal1,  { m: nil, n: nil, x: 'word', a: 'draw' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
          '  Goal3.:z',
          'Goal1.:a',
          '  Goal4."draw"',
        ].join("\n")
        
        assert_equal    2,        variable1.instantiations.size
        assert_equal    2,        variable2.instantiations.size
        assert_equal    1,        variable3.instantiations.size
        assert_equal    1,        variable4.instantiations.size
        
        assert_Instantiation      variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation      variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable2.instantiations[1], variable2, value1,    nil, nil
        assert_Instantiation      variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation      variable4.instantiations[0], variable4, value2,    nil, nil
        
        assert_equal    'word',   variable1.value
        assert_equal    'word',   variable2.value
        assert_equal    'word',   variable3.value
        assert_equal    'draw',   variable4.value
      end
      
      it 'should remove all instantiations case 1: remove value1' do
        
        value1.remove
        
        assert_Goal_variables     goal1,  { m: nil, n: nil, x: nil, a: 'draw' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '  Goal3.:z',
          'Goal1.:a',
          '  Goal4."draw"',
        ].join("\n")
        
        assert_equal    2,          variable1.instantiations.size
        assert_equal    1,          variable2.instantiations.size
        assert_equal    1,          variable3.instantiations.size
        assert_equal    1,          variable4.instantiations.size
        
        assert_Instantiation        variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation        variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation        variable2.instantiations[0], variable1, variable2, nil, nil
        assert_nil                  variable2.instantiations[1]
        assert_Instantiation        variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation        variable4.instantiations[0], variable4, value2,    nil, nil
        
        assert_equal    variable1,  variable1.value
        assert_equal    variable2,  variable2.value
        assert_equal    variable3,  variable3.value
        assert_equal    'draw',     variable4.value
      end
      
      it 'should remove all instantiations case 2: remove value2' do
        
        value2.remove
        
        assert_Goal_variables     goal1,  { m: nil, n: nil, x: 'word', a: nil }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
          '  Goal3.:z',
          'Goal1.:a',
        ].join("\n")
        
        assert_equal    2,          variable1.instantiations.size
        assert_equal    2,          variable2.instantiations.size
        assert_equal    1,          variable3.instantiations.size
        assert_equal    0,          variable4.instantiations.size
        
        assert_Instantiation        variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation        variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation        variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation        variable2.instantiations[1], variable2, value1,    nil, nil
        assert_Instantiation        variable3.instantiations[0], variable1, variable3, nil, nil
        assert_nil                  variable4.instantiations[0]
        
        assert_equal    'word',     variable1.value
        assert_equal    'word',     variable2.value
        assert_equal    'word',     variable3.value
        assert_equal    variable4,  variable4.value
      end
      
    end unless 'Variable added'
    
    describe '#method_missing' do
      
      it 'should pass any unexpected methods to the value' do
        assert_equal        456,        v.to_i
        assert_equal        466.123,    v + 10
      end
      
    end
    
    describe '#respond_to?' do
      
      it 'should respond to Value methods and methods of the actual value' do
        assert_equal        true,       v.respond_to?(:instantiations)
        assert_equal        true,       v.respond_to?(:inspect_with_instantiations)
        assert_equal        true,       v.respond_to?(:value)
        assert_equal        true,       v.respond_to?(:to_i)
        assert_equal        true,       v.respond_to?(:+)
      end
      
    end
    
    describe '#value' do
      
      it 'should take any number of arguments to be compatible with the value method of a variable' do
        assert_equal        456.123,    v.value
        assert_equal        456.123,    v.value(nil)
        assert_equal        456.123,    v.value(1,2,3)
        assert_equal        456.123,    v.value([])
      end
      
    end
    
    describe '#type' do
      
      let(:float)   { Value.new 456.789,    goal }
      let(:integer) { Value.new 456,        goal }
      let(:string)  { Value.new 'average',  goal }
      let(:array)   { Value.new [1,2,3],    goal }
      let(:object)  { Value.new Object.new, goal }
      
      it 'should return atomic for Float' do
        assert_equal        :atomic,    float.type
      end
      
      it 'should return atomic for Integer' do
        assert_equal        :atomic,    integer.type
      end
      
      it 'should return atomic for String' do
        assert_equal        :atomic,    string.type
      end
      
      it 'should return atomic for Array' do
        assert_equal        :array,     array.type
      end
      
      it 'should return atomic for Object' do
        assert_equal        :atomic,    object.type
      end
      
    end
    
    describe '#==' do
      
      it 'should return false for Values of different types' do
        v1 = Value.new 456.789,   goal
        v2 = Value.new 'average', goal
        
        refute      v1 == v2,     "#{name}: #{v1.value.inspect} == #{v2.value.inspect}"
      end
      
      it 'should return false for Values of the same type but different values' do
        v1 = Value.new 456.789,   goal
        v2 = Value.new 123.456,   goal
        
        refute      v1 == v2,     "#{name}: #{v1.value.inspect} == #{v2.value.inspect}"
      end
      
      it 'should return true for Values of the same type and the same value' do
        v1 = Value.new 456.789,   goal
        v2 = Value.new 456.789,   goal
        
        assert      v1 == v2,     "#{name}: #{v1.value.inspect} == #{v2.value.inspect}"
      end
      
    end
    
    describe '#variables' do
      
      it 'should return an empty Array for a Float value' do
        float = Value.new 456.789, goal
        
        assert_equal        [],             float.variables
      end
      
      it 'should return an Array of Symbols for embedded Variables' do
        array = Value.new [1, :b, 3, ['four', :e, 6], [[:g, 8]]], goal
        
        assert_equal        [:b, :e, :g],   array.variables
      end
      
    end
    
  end
  
end
