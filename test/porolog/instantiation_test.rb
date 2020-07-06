#
#   test/porolog/instantiation_test.rb     - Test Suite for Porolog::Instantiation
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end
  
  describe 'Instantiation' do
    
    let(:goal1)         { new_goal :generic, :m, :n }
    let(:goal2)         { new_goal :specifc, :p, :q }
    let(:goal3)         { new_goal :other,   :x, :y }
    let(:variable1)     { goal1.variable(:x) }
    let(:variable2)     { goal2.variable(:y) }
    let(:variable3)     { goal3.variable(:z) }
    let(:variable4)     { goal3.variable(:v) }
    let(:instantiation) { Instantiation.new variable1, nil, variable2, nil }
    
    describe '.reset' do
      
      it 'should delete/unregister all instantiations' do
        assert_equal    0,    Instantiation.instantiations.size
        
        Instantiation.new variable1, nil, variable2, nil
        Instantiation.new variable1, nil, variable2, 2
        Instantiation.new variable1, nil, variable3, nil
        Instantiation.new variable1, 1,   variable3, nil
        Instantiation.new variable1, nil, variable2, :head
        
        assert_equal    5,    Instantiation.instantiations.size
        
        assert          Instantiation.reset, name
        
        assert_equal    0,    Instantiation.instantiations.size
      end
      
    end
    
    describe '.instantiations' do
      
      it 'should be empty to start with' do
        assert_equal({}, Instantiation.instantiations)
      end
      
      it 'should return all registered instantiations' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable1, nil, variable2, 2
        instantiation3 = Instantiation.new variable1, nil, variable3, nil
        instantiation4 = Instantiation.new variable1, 1,   variable3, nil
        instantiation5 = Instantiation.new variable2, nil, variable3, nil
        
        assert_equal(
          {
            instantiation1.signature => instantiation1,
            instantiation2.signature => instantiation2,
            instantiation3.signature => instantiation3,
            instantiation4.signature => instantiation4,
            instantiation5.signature => instantiation5,
          },
          Instantiation.instantiations
        )
      end
      
    end
    
    describe '.new' do
      
      it 'should create a new instantiation' do
        instantiation = Instantiation.new variable1, nil, variable2, nil
        
        assert_instance_of  Instantiation,  instantiation
      end
      
      it 'should not create duplicate instantiations' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable1, nil, variable2, 2
        instantiation3 = Instantiation.new variable1, nil, variable3, nil
        instantiation4 = Instantiation.new variable1, 1,   variable3, nil
        instantiation5 = Instantiation.new variable1, nil, variable2, nil
        
        assert_equal  instantiation1, instantiation5
        assert_equal(
          {
            [variable1, nil, variable2, nil] => instantiation1,
            [variable1, nil, variable2, 2  ] => instantiation2,
            [variable1, 1,   variable3, nil] => instantiation4,
            [variable1, nil, variable3, nil] => instantiation3,
          },
          Instantiation.instantiations
        )
      end
      
    end
    
    describe '#initialize' do
      
      it 'should initialize variable1, variable2, index1, and index2' do
        instantiation = Instantiation.new variable1, nil, variable2, nil
        
        assert_Instantiation      instantiation, variable1, variable2, nil, nil
      end
      
      it 'should append itself to its variables' do
        instantiation = Instantiation.new variable1, nil, variable2, nil
        
        assert_equal    [instantiation],    variable1.instantiations
        assert_equal    [instantiation],    variable2.instantiations
      end
      
      it 'should register the instantiation' do
        instantiation = Instantiation.new variable1, nil, variable2, nil
        
        assert_equal    [instantiation],                      Instantiation.instantiations.values
        assert_equal    [[variable1, nil, variable2, nil]],   Instantiation.instantiations.keys
        assert_equal(
          {
            [variable1, nil, variable2, nil] => instantiation
          },
          Instantiation.instantiations
        )
      end
      
    end
    
    describe '#signature' do
      
      it 'should return the signature of the instantiation' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable1, 4,   variable2, :head
        
        assert_equal    [variable1, nil, variable2, nil  ],   instantiation1.signature
        assert_equal    [variable1, 4,   variable2, :head],   instantiation2.signature
      end
      
    end
    
    describe '#inspect' do
      
      it 'should show its variables and their indices' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable1, 4,   variable2, :head
        
        assert_equal    'Goal1.:x = Goal2.:y',                instantiation1.inspect
        assert_equal    'Goal1.:x[4] = Goal2.:y[:head]',      instantiation2.inspect
      end
      
    end
    
    describe '#remove' do
      
      it 'should remove itself from instantiations of both variables' do
        instantiation = Instantiation.new variable1, nil, variable2, nil
        
        assert_equal    [instantiation],        variable1.instantiations
        assert_equal    [instantiation],        variable2.instantiations
        
        instantiation.remove
        
        assert_equal    [],                     variable1.instantiations
        assert_equal    [],                     variable2.instantiations
      end
      
      it 'should be marked as deleted' do
        instantiation = Instantiation.new variable1, nil, variable2, nil
        
        refute          instantiation.deleted?,               'instantiation should not be marked deleted'
        
        instantiation.remove
        
        assert          instantiation.deleted?,               'instantiation should be marked deleted'
      end
      
      it 'should unregister itself' do
        assert_equal    [],                                   Instantiation.instantiations.values
        
        instantiation = Instantiation.new variable1, nil, variable2, nil
        
        assert_equal    [instantiation],                      Instantiation.instantiations.values
        assert_equal    [[variable1, nil, variable2, nil]],   Instantiation.instantiations.keys
        assert_equal(
          {
            [variable1, nil, variable2, nil] => instantiation
          },
          Instantiation.instantiations
        )
        
        instantiation.remove
        
        assert_equal    [],                                   Instantiation.instantiations.values
        assert_equal    [],                                   Instantiation.instantiations.keys
        assert_equal(
          {
          },
          Instantiation.instantiations
        )
      end
      
    end
    
    describe '#other_goal_to' do
      
      it 'should return the goal of the other variable' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        
        assert_equal    goal2,        instantiation1.other_goal_to(variable1)
        assert_equal    goal1,        instantiation1.other_goal_to(variable2)
        assert_nil                    instantiation1.other_goal_to(variable3)
        assert_nil                    instantiation2.other_goal_to(variable1)
        assert_equal    goal3,        instantiation2.other_goal_to(variable2)
        assert_equal    goal2,        instantiation2.other_goal_to(variable3)
      end
      
    end
    
    describe '#goals' do
      
      it 'should return the goals' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable1, 4,   variable3, :head
        
        assert_equal    [goal1, goal2],   instantiation1.goals
        assert_equal    [goal1, goal3],   instantiation2.goals
      end
      
    end
    
    describe '#variables' do
      
      it 'should return both variables' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        
        assert_equal    [variable1,variable2],    instantiation1.variables
        assert_equal    [variable2,variable3],    instantiation2.variables
      end
      
    end
    
    describe '#values' do
      
      it 'should return all values instantiated to its variables' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        
        assert_equal    [],                   instantiation1.values
        assert_equal    [],                   instantiation2.values
        
        variable3.instantiate Value.new('word',goal3)
        
        assert_equal    ['word'],             instantiation1.values
        assert_equal    ['word'],             instantiation2.values
      end
      
      it 'should return all indexed values instantiated to its variables' do
        instantiation1 = Instantiation.new variable1, nil, variable2, 3
        instantiation2 = Instantiation.new variable2, 4,   variable3, nil
        
        assert_equal    [],                                 instantiation1.values
        assert_equal    [],                                 instantiation2.values
        
        variable2.instantiate Value.new([2,3,5,7,11,13,17,19,23],goal2)
        
        assert_equal    7,                                  variable1.value
        assert_equal    [2,3,5,7,11,13,17,19,23],           variable2.value
        assert_equal    11,                                 variable3.value
        
        assert_equal    [7],                                instantiation1.values
        assert_equal    [11],                               instantiation2.values
        
        variable2.uninstantiate goal2
        
        assert_equal    variable1,                          variable1.value
        assert_equal    variable2,                          variable2.value
        assert_equal    variable3,                          variable3.value
        
        assert_equal    [],                                 instantiation1.values
        assert_equal    [],                                 instantiation2.values
        
        words = %w{two three five seven eleven thirteen seventeen nineteen twenty-three}
        variable2.instantiate Value.new(words, goal2)
        
        assert_equal    'seven',                            variable1.value
        assert_equal    words,                              variable2.value
        assert_equal    'eleven',                           variable3.value
        
        assert_equal    ['seven'],                          instantiation1.values
        assert_equal    ['eleven'],                         instantiation2.values
      end
      
    end
    
    describe '#value_indexed' do
      
      it 'should return unknown tail when value has an unknown tail and the index is greater than the fixed portion of the list' do
        assert_equal    UNKNOWN_TAIL, instantiation.value_indexed([2,3,5,7,UNKNOWN_TAIL],99)
      end
      
      it 'should return indexed element when value has an unknown tail and the index is less than the fixed portion of the list' do
        assert_equal    5,            instantiation.value_indexed([2,3,5,7,UNKNOWN_TAIL],2)
      end
      
      it 'should return the component when value is a Variable and the index is a Symbol' do
        value = goal1.value([2,3,5,7,UNKNOWN_TAIL])
        
        assert_equal    2,                        instantiation.value_indexed(value,:head)
        assert_equal    [3,5,7,UNKNOWN_TAIL],     instantiation.value_indexed(value,:tail)
      end
      
      it 'should return nil when value is nil' do
        assert_nil                    instantiation.value_indexed(nil,nil)
        assert_nil                    instantiation.value_indexed(nil,4)
        assert_nil                    instantiation.value_indexed(nil,:head)
        assert_nil                    instantiation.value_indexed(nil,:tail)
      end
      
      it 'should return nil when value is a Variable' do
        assert_nil                    instantiation.value_indexed(variable3,nil)
        assert_nil                    instantiation.value_indexed(variable3,4)
        assert_nil                    instantiation.value_indexed(variable3,:head)
        assert_nil                    instantiation.value_indexed(variable3,:tail)
      end
      
      it 'should return nil when value is a Symbol' do
        assert_nil                    instantiation.value_indexed(:z,nil)
        assert_nil                    instantiation.value_indexed(:z,4)
        assert_nil                    instantiation.value_indexed(:z,:head)
        assert_nil                    instantiation.value_indexed(:z,:tail)
      end
      
      it 'should return nil when value is an empty Array and index is :tail' do
        assert_nil                    instantiation.value_indexed([],:tail)
      end
      
      it 'should return the indexed value when index is an Integer' do
        assert_equal    7,            instantiation.value_indexed([2,3,5,7,11],3)
        assert_equal    14,           instantiation.value_indexed(14,3)
        assert_equal    'd',          instantiation.value_indexed('word',3)
        assert_equal    6.4,          instantiation.value_indexed(6.4,3)
      end
      
      it 'should return the component when index is a Symbol' do
        assert_equal    5,            instantiation.value_indexed([2,3,5,7,11],:length)
        assert_equal    11,           instantiation.value_indexed([2,3,5,7,11],:last)
        assert_equal    [2,3,5,7,11], instantiation.value_indexed([2,3,5,7,11],:nothing)
      end
      
      it 'should return the dynamically sized head when index is an Array' do
        assert_equal    [3,5,7,11],   instantiation.value_indexed([2,3,5,7,11],[])
        assert_equal    [],           instantiation.value_indexed([2,3,5,7,11],[0])
        assert_equal    [2],          instantiation.value_indexed([2,3,5,7,11],[1])
        assert_equal    [2,3],        instantiation.value_indexed([2,3,5,7,11],[2])
        assert_equal    [2],          instantiation.value_indexed([2,3,5,7,11],[1,1])
      end
      
      it 'should raise an error when index is unexpected' do
        assert_raises Instantiation::UnhandledIndexError do
          assert_equal    [2,3,5,7,11], instantiation.value_indexed([2,3,5,7,11],12.34)
        end
        assert_raises Instantiation::UnhandledIndexError do
          assert_equal    [2,3,5,7,11], instantiation.value_indexed([2,3,5,7,11],'hello')
        end
        assert_raises Instantiation::UnhandledIndexError do
          assert_equal    [2,3,5,7,11], instantiation.value_indexed([2,3,5,7,11],Object)
        end
        object = Object.new
        assert_raises Instantiation::UnhandledIndexError do
          assert_equal    [2,3,5,7,11], instantiation.value_indexed([2,3,5,7,11],object)
        end
      end
      
    end
    
    describe '#values_for' do
      
      it 'should return all values instantiated to the specified variable' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        
        assert_equal    [],             instantiation1.values_for(variable1)
        assert_equal    [],             instantiation1.values_for(variable2)
        assert_equal    [],             instantiation1.values_for(variable3)
        assert_equal    [],             instantiation2.values_for(variable1)
        assert_equal    [],             instantiation2.values_for(variable2)
        assert_equal    [],             instantiation2.values_for(variable3)
        
        variable3.instantiate Value.new('word',goal3)
        
        assert_Goal_variables  goal1,   { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal3.:z',
          '      Goal3."word"',
        ].join("\n")
        assert_Goal_variables  goal2,   { p: nil, q: nil, y: 'word' }, [
          'Goal2.:p',
          'Goal2.:q',
          'Goal2.:y',
          '  Goal1.:x',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        assert_Goal_variables  goal3,   { x: nil, y: nil, z: 'word' }, [
          'Goal3.:x',
          'Goal3.:y',
          'Goal3.:z',
          '  Goal2.:y',
          '    Goal1.:x',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    ['word'],       instantiation1.values_for(variable1)
        assert_equal    [],             instantiation1.values_for(variable2)
        assert_equal    [],             instantiation1.values_for(variable3)
        assert_equal    [],             instantiation2.values_for(variable1)
        assert_equal    ['word'],       instantiation2.values_for(variable2)
        assert_equal    [],             instantiation2.values_for(variable3)
      end
      
      it 'should return all indexed values instantiated to its variables' do
        instantiation1 = Instantiation.new variable1, nil, variable2, 3
        instantiation2 = Instantiation.new variable2, 4,   variable3, nil
        
        assert_equal    [],             instantiation1.values_for(variable1)
        assert_equal    [],             instantiation1.values_for(variable2)
        assert_equal    [],             instantiation2.values_for(variable2)
        assert_equal    [],             instantiation2.values_for(variable3)
        
        variable2.instantiate Value.new([2,3,5,7,11,13,17,19,23],goal2)
        
        assert_equal    7,                                  variable1.value
        assert_equal    [2,3,5,7,11,13,17,19,23],           variable2.value
        assert_equal    11,                                 variable3.value
        
        assert_equal    [7],                                instantiation1.values_for(variable1)
        assert_equal    [],                                 instantiation1.values_for(variable2)
        assert_equal    [],                                 instantiation2.values_for(variable2)
        assert_equal    [11],                               instantiation2.values_for(variable3)
        
        variable2.uninstantiate goal2
        
        assert_equal    variable1,                          variable1.value
        assert_equal    variable2,                          variable2.value
        assert_equal    variable3,                          variable3.value
        
        assert_equal    [],                                 instantiation1.values
        assert_equal    [],                                 instantiation2.values
        
        words = %w{two three five seven eleven thirteen seventeen nineteen twenty-three}
        variable2.instantiate Value.new(words, goal2)
        
        assert_equal    'seven',                            variable1.value
        assert_equal    words,                              variable2.value
        assert_equal    'eleven',                           variable3.value
        
        assert_equal    ['seven'],                          instantiation1.values
        assert_equal    ['eleven'],                         instantiation2.values
      end
      
      it 'should not infinitely recurse' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        instantiation3 = Instantiation.new variable3, nil, variable1, nil
        
        assert_equal    [],           instantiation1.values_for(variable1)
        assert_equal    [],           instantiation1.values_for(variable2)
        assert_equal    [],           instantiation2.values_for(variable2)
        assert_equal    [],           instantiation2.values_for(variable3)
        assert_equal    [],           instantiation3.values_for(variable3)
        assert_equal    [],           instantiation3.values_for(variable1)
      end
      
      it 'should return an uninstantiated tail when the head is known only' do
        instantiation1 = Instantiation.new variable1, :head, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        instantiation3 = Instantiation.new variable3, nil, variable4, nil
        
        goal3.instantiate :v, 'head', goal3
        
        assert_Goal_variables   goal1, { m: nil, n: nil, x: [goal3.value('head'), UNKNOWN_TAIL] }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  [:head]Goal2.:y',
          '    Goal3.:z',
          '      Goal3.:v',
          '        Goal3."head"',
        ].join("\n")
        
        assert_Goal_variables   goal3, { x: nil, y: nil, z: 'head', v: 'head' }, [
          'Goal3.:x',
          'Goal3.:y',
          'Goal3.:z',
          '  Goal2.:y',
          '    Goal1.:x[:head]',
          '  Goal3.:v',
          '    Goal3."head"',
          'Goal3.:v',
          '  Goal3.:z',
          '    Goal2.:y',
          '      Goal1.:x[:head]',
          '  Goal3."head"',
        ].join("\n")
        
        assert_equal    [['head', UNKNOWN_TAIL]],                   instantiation1.values_for(variable1)
        assert_equal    [],                                         instantiation1.values_for(variable2)
        assert_equal    ['head'],                                   instantiation2.values_for(variable2)
        assert_equal    [],                                         instantiation2.values_for(variable3)
        assert_equal    ['head'],                                   instantiation3.values_for(variable3)
        assert_equal    [],                                         instantiation3.values_for(variable4)
      end
      
      it 'should return an uninstantiated head when the tail is known only' do
        instantiation1 = Instantiation.new variable1, :tail, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        instantiation3 = Instantiation.new variable3, nil, variable4, nil
        
        goal3.instantiate :v, ['this','is','the','tail'], goal3
        
        assert_Goal_variables   goal1, { m: nil, n: nil, x: [nil, 'this','is','the','tail'] }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  [:tail]Goal2.:y',
          '    Goal3.:z',
          '      Goal3.:v',
          '        Goal3.["this", "is", "the", "tail"]',
        ].join("\n")
        
        assert_Goal_variables   goal3, { x: nil, y: nil, z: ['this','is','the','tail'], v: ['this','is','the','tail'] }, [
          'Goal3.:x',
          'Goal3.:y',
          'Goal3.:z',
          '  Goal2.:y',
          '    Goal1.:x[:tail]',
          '  Goal3.:v',
          '    Goal3.["this", "is", "the", "tail"]',
          'Goal3.:v',
          '  Goal3.:z',
          '    Goal2.:y',
          '      Goal1.:x[:tail]',
          '  Goal3.["this", "is", "the", "tail"]',
        ].join("\n")
        
        assert_equal    [[nil, 'this','is','the','tail']],          instantiation1.values_for(variable1)
        assert_equal    [],                                         instantiation1.values_for(variable2)
        assert_equal    [goal3.value(['this','is','the','tail'])],  instantiation2.values_for(variable2)
        assert_equal    [],                                         instantiation2.values_for(variable3)
        assert_equal    [goal3.value(['this','is','the','tail'])],  instantiation3.values_for(variable3)
        assert_equal    [],                                         instantiation3.values_for(variable4)
      end
      
      it 'should return a list with uninstantiated elements and tail with the value at the index' do
        instantiation1 = Instantiation.new variable1, 3,   variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        instantiation3 = Instantiation.new variable3, nil, variable4, nil
        
        goal3.instantiate :v, 45.9, goal3
        
        assert_Goal_variables   goal1, { m: nil, n: nil, x: [nil, nil, nil, goal3.value(45.9), UNKNOWN_TAIL] }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  [3]Goal2.:y',
          '    Goal3.:z',
          '      Goal3.:v',
          '        Goal3.45.9',
        ].join("\n")
        
        assert_Goal_variables   goal3, { x: nil, y: nil, z: 45.9, v: 45.9 }, [
          'Goal3.:x',
          'Goal3.:y',
          'Goal3.:z',
          '  Goal2.:y',
          '    Goal1.:x[3]',
          '  Goal3.:v',
          '    Goal3.45.9',
          'Goal3.:v',
          '  Goal3.:z',
          '    Goal2.:y',
          '      Goal1.:x[3]',
          '  Goal3.45.9',
        ].join("\n")
        
        assert_equal    [[nil, nil, nil, 45.9, UNKNOWN_TAIL]],      instantiation1.values_for(variable1)
        assert_equal    [],                                         instantiation1.values_for(variable2)
        assert_equal    [goal3.value(45.9)],                        instantiation2.values_for(variable2)
        assert_equal    [],                                         instantiation2.values_for(variable3)
        assert_equal    [goal3.value(45.9)],                        instantiation3.values_for(variable3)
        assert_equal    [],                                         instantiation3.values_for(variable4)
      end
      
      it 'should return the value of variable1 when the specified variable is variable2 and variable1 is not a Variable' do
        value1 = goal1.value('titanium')
        
        instantiation1 = Instantiation.new value1,    nil, variable3, nil
        
        assert_equal    [value1],       instantiation1.values_for(variable3)
      end
      
    end
    
    describe '#value_at_index' do
      
      describe 'when index is nil' do
        
        it 'should return nil for a nil value' do
          assert_nil                    instantiation.value_at_index(nil,nil)
        end
        
        it 'should return the value for a non-nil value' do
          assert_equal  'orange',       instantiation.value_at_index('orange',nil)
        end
        
      end
      
      describe 'when index is Integer' do
        
        it 'should return nil for nil value' do
          assert_nil                                                    instantiation.value_at_index(nil,5)
        end
      
        it 'should return an Array for an Integer indexed value' do
          assert_equal    [nil,nil,nil,nil,nil,'word',UNKNOWN_TAIL],    instantiation.value_at_index('word',5)
        end
        
      end
      
      describe 'when index is Symbol' do
        
        it 'should return an Array for a head indexed value' do
          assert_equal    [['word','from','list'],UNKNOWN_TAIL],        instantiation.value_at_index(['word','from','list'],:head)
        end
        
        it 'should return an Array for a tail indexed value' do
          assert_equal    [nil,'word','from','list'],                   instantiation.value_at_index(['word','from','list'],:tail)
        end
        
        it 'should return an error for an unrecognised symbol indexed value' do
          assert_raises Instantiation::UnhandledIndexError do
            assert_equal    :error,                                       instantiation.value_at_index(['word','from','list'],:size)
          end
        end
        
      end
      
      describe 'when index is Array' do
        
        it 'should return an Array for a tail indexed value' do
          assert_equal    [nil,'word','from','list'],                   instantiation.value_at_index(['word','from','list'],[])
        end
        
        it 'should return an Array for a tail indexed value' do
          assert_equal    [['word','from','list'], UNKNOWN_TAIL],       instantiation.value_at_index(['word','from','list'],[1])
        end
        
        it 'should return an Array for a tail indexed value' do
          assert_equal    [['word','from','list'], UNKNOWN_TAIL],       instantiation.value_at_index(['word','from','list'],[2])
        end
        
        it 'should return an Array for a tail indexed value' do
          assert_equal    [['word','from','list'], UNKNOWN_TAIL],       instantiation.value_at_index(['word','from','list'],[-2])
        end
        
      end
      
      describe 'when index is Float' do
        
        it 'should return an error for an unrecognised symbol indexed value' do
          assert_raises Instantiation::UnhandledIndexError do
            assert_equal    ['word','from','list'],                       instantiation.value_at_index(['word','from','list'],2.3)
          end
        end
        
      end
      
      it 'should return all values instantiated to the specified variable' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        
        assert_equal    [],             instantiation1.values_for(variable1)
        assert_equal    [],             instantiation1.values_for(variable2)
        assert_equal    [],             instantiation1.values_for(variable3)
        assert_equal    [],             instantiation2.values_for(variable1)
        assert_equal    [],             instantiation2.values_for(variable2)
        assert_equal    [],             instantiation2.values_for(variable3)
        
        variable3.instantiate Value.new('word',goal3)
        
        assert_Goal_variables  goal1,   { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal3.:z',
          '      Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables  goal2,   { p: nil, q: nil, y: 'word' }, [
          'Goal2.:p',
          'Goal2.:q',
          'Goal2.:y',
          '  Goal1.:x',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables  goal3,   { x: nil, y: nil, z: 'word' }, [
          'Goal3.:x',
          'Goal3.:y',
          'Goal3.:z',
          '  Goal2.:y',
          '    Goal1.:x',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    ['word'],       instantiation1.values_for(variable1)
        assert_equal    [],             instantiation1.values_for(variable2)
        assert_equal    [],             instantiation1.values_for(variable3)
        assert_equal    [],             instantiation2.values_for(variable1)
        assert_equal    ['word'],       instantiation2.values_for(variable2)
        assert_equal    [],             instantiation2.values_for(variable3)
      end
      
      it 'should return all indexed values instantiated to its variables' do
        instantiation1 = Instantiation.new variable1, nil, variable2, 3
        instantiation2 = Instantiation.new variable2, 4,   variable3, nil
        
        assert_equal    [],             instantiation1.values_for(variable1)
        assert_equal    [],             instantiation1.values_for(variable2)
        assert_equal    [],             instantiation2.values_for(variable2)
        assert_equal    [],             instantiation2.values_for(variable3)
        
        variable2.instantiate Value.new([2,3,5,7,11,13,17,19,23],goal2)
        
        assert_equal    7,                                  variable1.value
        assert_equal    [2,3,5,7,11,13,17,19,23],           variable2.value
        assert_equal    11,                                 variable3.value
        
        assert_equal    [7],                                instantiation1.values_for(variable1)
        assert_equal    [],                                 instantiation1.values_for(variable2)
        assert_equal    [],                                 instantiation2.values_for(variable2)
        assert_equal    [11],                               instantiation2.values_for(variable3)
        
        variable2.uninstantiate goal2
        
        assert_equal    variable1,                          variable1.value
        assert_equal    variable2,                          variable2.value
        assert_equal    variable3,                          variable3.value
        
        assert_equal    [],                                 instantiation1.values
        assert_equal    [],                                 instantiation2.values
        
        words = %w{two three five seven eleven thirteen seventeen nineteen twenty-three}
        variable2.instantiate Value.new(words, goal2)
        
        assert_equal    'seven',                            variable1.value
        assert_equal    words,                              variable2.value
        assert_equal    'eleven',                           variable3.value
        
        assert_equal    ['seven'],                          instantiation1.values
        assert_equal    ['eleven'],                         instantiation2.values
      end
      
      it 'should not infinitely recurse' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        instantiation3 = Instantiation.new variable3, nil, variable1, nil
        
        assert_equal    [],           instantiation1.values_for(variable1)
        assert_equal    [],           instantiation1.values_for(variable2)
        assert_equal    [],           instantiation2.values_for(variable2)
        assert_equal    [],           instantiation2.values_for(variable3)
        assert_equal    [],           instantiation3.values_for(variable3)
        assert_equal    [],           instantiation3.values_for(variable1)
      end
      
    end
    
    describe '#without_index_on' do
      
      it 'should return true for a variable without an index in the instantiation' do
        instantiation = Instantiation.new variable1, nil, variable2, nil
        
        assert_equal    true,       instantiation.without_index_on?(variable1)
        assert_equal    true,       instantiation.without_index_on?(variable2)
      end
      
      it 'should return correctly when the instantiation has one index' do
        instantiation = Instantiation.new variable1, 3, variable2, nil
        
        assert_equal    false,      instantiation.without_index_on?(variable1)
        assert_equal    true,       instantiation.without_index_on?(variable2)
      end
      
      it 'should return correctly when the instantiation has one index (other one)' do
        instantiation = Instantiation.new variable1, nil, variable2, 3
        
        assert_equal    true,       instantiation.without_index_on?(variable1)
        assert_equal    false,      instantiation.without_index_on?(variable2)
      end
      
      it 'should return false when the instantiation has two indexes' do
        instantiation = Instantiation.new variable1, 3, variable2, 3
        
        assert_equal    false,      instantiation.without_index_on?(variable1)
        assert_equal    false,      instantiation.without_index_on?(variable2)
      end
      
      it 'should return false for a variable not in the instantiation' do
        instantiation = Instantiation.new variable1, nil, variable2, nil
        
        assert_equal    false,      instantiation.without_index_on?(variable3)
      end
      
    end
    
    describe '#deleted?' do
      
      it 'should return true when removed' do
        refute          instantiation.deleted?,               'instantiation should not be marked deleted'
        
        instantiation.remove
        
        assert          instantiation.deleted?,               'instantiation should be marked deleted'
      end
      
      it 'should return true when the goal of variable1 is deleted' do
        refute          instantiation.deleted?,               'instantiation should not be marked deleted'
        
        Goal.goals.delete(goal1)
        
        assert          instantiation.deleted?,               'instantiation should be marked deleted'
      end
      
      it 'should return true when the goal of variable2 is deleted' do
        refute          instantiation.deleted?,               'instantiation should not be marked deleted'
        
        Goal.goals.delete(goal2)
        
        assert          instantiation.deleted?,               'instantiation should be marked deleted'
      end
      
    end
    
    describe '#belongs_to?' do
      
      it 'should correctly determine the relationship between an instantition and a goal' do
        instantiation1 = Instantiation.new variable1, nil, variable2, nil
        instantiation2 = Instantiation.new variable2, nil, variable3, nil
        
        assert          instantiation1.belongs_to?(goal1),   'instantiation1 should belong to goal1'
        assert          instantiation1.belongs_to?(goal2),   'instantiation1 should belong to goal2'
        refute          instantiation1.belongs_to?(goal3),   'instantiation1 should not belong to goal3'
        refute          instantiation2.belongs_to?(goal1),   'instantiation2 should not belong to goal1'
        assert          instantiation2.belongs_to?(goal2),   'instantiation2 should belong to goal2'
        assert          instantiation2.belongs_to?(goal3),   'instantiation2 should belong to goal3'
      end
      
    end
    
  end

end
