#
#   test/porolog/variable_test.rb     - Test Suite for Porolog::Variable
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'

describe 'Porolog' do
  
  describe 'Variable' do
    
    let(:predicate1)  { Porolog::Predicate.new :generic }
    let(:arguments1)  { predicate1.arguments(:m,:n) }
    let(:goal1)       { arguments1.goal }
    let(:goal2)       { arguments1.goal }
    let(:goal3)       { arguments1.goal }
    
    before do
      reset
    end
    
    describe '.new' do
      
      it 'should create a new variable in a goal' do
        variable = Porolog::Variable.new :x, goal1
        
        assert_instance_of      Porolog::Variable,    variable
        assert_Goal_variables   goal1,                { m: nil, n: nil, x: nil },  [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
        ].join("\n")
      end
      
    end
    
    describe '#initialize' do
      
      it 'should initialize name, goal, instantiations, and values' do
        variable = Porolog::Variable.new :x, goal1
        
        assert_Variable     variable,   :x, goal1, [], []
      end
      
      it 'should convert a string name to a symbol name' do
        variable = Porolog::Variable.new 's', goal1
        
        assert_equal        :s,         variable.name
      end
      
      it 'should convert a variable name to its name' do
        other    = Porolog::Variable.new 'other',  goal1
        variable = Porolog::Variable.new other,    goal1
        
        assert_equal            :other,     variable.name
        assert_Goal_variables   goal1,     { m: nil, n: nil, other: nil },   [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:other',
        ].join("\n")
      end
      
      it 'should convert a value name to its name and initialize its values' do
        value    = Porolog::Value.new    'other',  goal1
        variable = Porolog::Variable.new value,    goal1
        
        assert_equal        'other',    variable.name
        assert_equal        [value],    variable.values
        
        assert_equal        'other',    variable.value
      end
      
      it 'should convert other types as a name to its value' do
        # TECH-DEBT: Not super sure about this spec!
        variable = Porolog::Variable.new 0.875,    goal1
        
        assert_equal        '0.875',    variable.name
        assert_instance_of  Array,      variable.values
        assert_equal        1,          variable.values.size
        
        assert_Value        variable.values.first,    0.875, goal1
        assert_equal        0.875,      variable.value
      end
      
      it 'should raise an error when a goal is not provided' do
        assert_raises Porolog::Variable::GoalError do
          Porolog::Variable.new :x, 'goal'
        end
      end
      
      it 'should declare the variable in the goal' do
        Porolog::Variable.new :x, goal1
        
        assert_Goal_variables     goal1,   { m: nil, n: nil, x: nil },   [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
        ].join("\n")
      end
      
    end
    
    describe '#to_sym' do
      
      it 'should convert a variable to a Symbol' do
        variable = Porolog::Variable.new 'v', goal1
        
        assert_equal        :v,         variable.to_sym
      end
      
    end
    
    describe '#type' do
      
      it 'should return variable from uninstantiated variables' do
        variable = Porolog::Variable.new 'v', goal1
        
        assert_equal        :variable,  variable.type
      end
      
      it 'should return variable from instantiated variables' do
        variable = Porolog::Variable.new 'v', goal1
        variable.instantiate 'string value'
        
        assert_equal        :variable,  variable.type
      end
      
    end
    
    describe '#inspect' do
      
      it 'should show the goal and name' do
        variable = Porolog::Variable.new 'v', goal1
        
        assert_equal        'Goal1.:v', variable.inspect
      end
      
    end
    
    describe '#inspect_with_instantiations' do
      
      it 'should show a variable without instantiations as inspect does' do
        variable = Porolog::Variable.new :x, goal1
        
        assert_equal variable.inspect, variable.inspect_with_instantiations
      end
      
      it 'should return all instantiations of a variable with nested instantiations' do
        variable1  = Porolog::Variable.new :x, goal1
        variable2  = Porolog::Variable.new :y, goal1
        variable3  = Porolog::Variable.new :z, goal1
        
        variable1.instantiate variable2
        variable2.instantiate variable3
        
        assert_equal        'Goal1.:x',               variable1.inspect
        assert_equal        'Goal1.:y',               variable2.inspect
        assert_equal        'Goal1.:z',               variable3.inspect
        
        assert_instance_of  Array,                    variable1.instantiations
        assert_instance_of  Array,                    variable2.instantiations
        assert_instance_of  Array,                    variable3.instantiations
        
        assert_equal        1,                        variable1.instantiations.size
        assert_equal        2,                        variable2.instantiations.size
        assert_equal        1,                        variable3.instantiations.size
        
        assert_instance_of  Porolog::Instantiation,   variable1.instantiations.first
        assert_equal        'Goal1.:x = Goal1.:y',    variable1.instantiations.first.inspect
        
        assert_instance_of  Porolog::Instantiation,   variable2.instantiations[0]
        assert_equal        'Goal1.:x = Goal1.:y',    variable2.instantiations[0].inspect
        
        assert_instance_of  Porolog::Instantiation,   variable2.instantiations[1]
        assert_equal        'Goal1.:y = Goal1.:z',    variable2.instantiations[1].inspect
        
        assert_instance_of  Porolog::Instantiation,   variable3.instantiations.first
        assert_equal        'Goal1.:y = Goal1.:z',    variable3.instantiations.first.inspect
        
        assert_equal        variable1.instantiations + variable3.instantiations,  variable2.instantiations
        
        assert_equal(
          [
            'Goal1.:x',
            '  Goal1.:y',
            '    Goal1.:z',
            'Goal1.:y',
            '  Goal1.:x',
            '  Goal1.:z',
            'Goal1.:z',
            '  Goal1.:y',
            '    Goal1.:x',
          ].join("\n"),
          [
            variable1.inspect_with_instantiations,
            variable2.inspect_with_instantiations,
            variable3.inspect_with_instantiations,
          ].join("\n")
        )
      end
      
    end
    
    describe '#value' do
      
      it 'should return the variable when no value has been instantiated' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal1
        
        variable1.instantiate variable2
        
        assert_equal  variable1,    variable1.value
      end
      
      it 'should return the indirect value through instantiations' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal1
        value     = Porolog::Value.new [1,2,3], goal1
        
        variable1.instantiate variable2
        variable2.instantiate value
        
        assert_equal    [1,2,3],    variable1.value
      end
      
      it 'should not return unbound headtails' do
        assert_Goal   goal1, :generic, [:m, :n]
        
        # -- Create Variables --
        variable1     = Porolog::Variable.new :x, goal1
        variable2     = Porolog::Variable.new :y, goal1
        variable3     = Porolog::Variable.new :z, goal1
        
        assert_Goal_variables   goal1, { m: nil, n: nil, x: nil, y: nil, z: nil }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          'Goal1.:y',
          'Goal1.:z',
        ].join("\n")
        
        # -- Create Values --
        headtail      = goal1.variablise(:m/:n)
        assert_Array_with_Tail         headtail, [goal1.variable(:m)], '*Goal1.:n'
        
        value1        = Porolog::Value.new headtail, goal1
        value2        = Porolog::Value.new [1,2,3],  goal1
        
        assert_Value    value1, headtail,   goal1
        assert_Value    value2, [1,2,3],    goal1
        
        # -- Instantiate --
        #   Goal1.:x
        #     Goal1.:y
        i1 = variable1.instantiate variable2
        
        assert_Instantiation        i1,   variable1, variable2, nil, nil
        
        # -- Assert No Values --
        assert_equal    variable1,  variable1.value
        assert_equal    variable2,  variable2.value
        assert_equal    variable3,  variable3.value
        
        assert_Goal_variables       goal1, { m: nil, n: nil, x: nil, y: nil, z: nil }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal1.:y',
          'Goal1.:y',
          '  Goal1.:x',
          'Goal1.:z',
        ].join("\n")
        
        # -- Instantiate --
        #   Goal1.:x
        #     Goal1.:z
        i2 = variable1.instantiate variable3
        
        assert_Instantiation        i2,   variable1, variable3, nil, nil
        
        # -- Assert No Values --
        assert_equal    variable1,  variable1.value
        assert_equal    variable2,  variable2.value
        assert_equal    variable3,  variable3.value
        
        assert_Goal_variables       goal1, { m: nil, n: nil, x: nil, y: nil, z: nil }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal1.:y',
          '  Goal1.:z',
          'Goal1.:y',
          '  Goal1.:x',
          '    Goal1.:z',
          'Goal1.:z',
          '  Goal1.:x',
          '    Goal1.:y',
        ].join("\n")
        
        # -- Instantiate --
        #   Goal1.:y
        #     [Goal1.:m, *Goal1.:n]
        i3 = variable2.instantiate value1
          
        assert_Instantiation        i3,   variable2, value1, nil, nil
        assert_equal    headtail,   variable1.value
        assert_equal    headtail,   variable2.value
        assert_equal    headtail,   variable3.value
        assert_equal    headtail,   goal1.value_of(:x)
        assert_equal    headtail,   goal1.value_of(:y)
        assert_equal    headtail,   goal1.value_of(:z)
        assert_Goal_variables       goal1, {
          m: nil,
          n: nil,
          x: [nil, Porolog::UNKNOWN_TAIL],
          y: [nil, Porolog::UNKNOWN_TAIL],
          z: [nil, Porolog::UNKNOWN_TAIL]
        }, [
          'Goal1.:m',
          '  Goal1.:y[:head]',
          '    Goal1.:x',
          '      Goal1.:z',
          '    Goal1.[Goal1.:m, *Goal1.:n]',
          '    [:tail]Goal1.:n',
          'Goal1.:n',
          '  Goal1.:y[:tail]',
          '    Goal1.:x',
          '      Goal1.:z',
          '    Goal1.[Goal1.:m, *Goal1.:n]',
          '    [:head]Goal1.:m',
          'Goal1.:x',
          '  Goal1.:y',
          '    Goal1.[Goal1.:m, *Goal1.:n]',
          '    [:head]Goal1.:m',
          '    [:tail]Goal1.:n',
          '  Goal1.:z',
          'Goal1.:y',
          '  Goal1.:x',
          '    Goal1.:z',
          '  Goal1.[Goal1.:m, *Goal1.:n]',
          '  [:head]Goal1.:m',
          '  [:tail]Goal1.:n',
          'Goal1.:z',
          '  Goal1.:x',
          '    Goal1.:y',
          '      Goal1.[Goal1.:m, *Goal1.:n]',
          '      [:head]Goal1.:m',
          '      [:tail]Goal1.:n',
        ].join("\n")
          
        # -- Instantiate --
        i3 = variable3.instantiate value2
        
        assert_Instantiation        i3,   variable3, value2, nil, nil
        assert_equal    [1,2,3],    variable1.value
        assert_equal    [1,2,3],    variable2.value
        assert_equal    [1,2,3],    variable3.value
        
        assert_Goal_variables       goal1, { m: 1, n: [2,3], x: [1,2,3], y: [1,2,3], z: [1,2,3] }, [
          'Goal1.:m',
          '  Goal1.:y[:head]',
          '    Goal1.:x',
          '      Goal1.:z',
          '        Goal1.[1, 2, 3]',
          '    Goal1.[Goal1.:m, *Goal1.:n]',
          '    [:tail]Goal1.:n',
          'Goal1.:n',
          '  Goal1.:y[:tail]',
          '    Goal1.:x',
          '      Goal1.:z',
          '        Goal1.[1, 2, 3]',
          '    Goal1.[Goal1.:m, *Goal1.:n]',
          '    [:head]Goal1.:m',
          'Goal1.:x',
          '  Goal1.:y',
          '    Goal1.[Goal1.:m, *Goal1.:n]',
          '    [:head]Goal1.:m',
          '    [:tail]Goal1.:n',
          '  Goal1.:z',
          '    Goal1.[1, 2, 3]',
          'Goal1.:y',
          '  Goal1.:x',
          '    Goal1.:z',
          '      Goal1.[1, 2, 3]',
          '  Goal1.[Goal1.:m, *Goal1.:n]',
          '  [:head]Goal1.:m',
          '  [:tail]Goal1.:n',
          'Goal1.:z',
          '  Goal1.:x',
          '    Goal1.:y',
          '      Goal1.[Goal1.:m, *Goal1.:n]',
          '      [:head]Goal1.:m',
          '      [:tail]Goal1.:n',
          '  Goal1.[1, 2, 3]',
        ].join("\n")
      end
      
      it 'should not return the indirect value through instantiations after uninstantiating' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal1
        value     = Porolog::Value.new [1,2,3], goal1
        
        variable1.instantiate variable2
        variable2.instantiate value
        
        assert_equal    [1,2,3],    variable1.value
        
        variable2.uninstantiate goal1
        
        assert_equal    variable1,  variable1.value
        assert_equal    variable2,  variable2.value
      end
      
      it 'should not instantiate multiple unequal values' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal2
        variable3 = Porolog::Variable.new :z, goal3
        
        value1    = Porolog::Value.new [1,2,3], goal2
        value2    = Porolog::Value.new 'word',  goal3
        
        i1 = variable1.instantiate variable2
        i2 = variable1.instantiate variable3
        i3 = variable2.instantiate value1
        i4 = variable3.instantiate value2
        
        assert_Instantiation    i1,     variable1,  variable2,  nil,  nil
        assert_Instantiation    i2,     variable1,  variable3,  nil,  nil
        assert_Instantiation    i3,     variable2,  value1,     nil,  nil
        assert_nil              i4
        
        assert_Goal_variables   goal1, { m: nil, n: nil, x: [1,2,3] }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2.[1, 2, 3]',
          '  Goal3.:z',
        ].join("\n")
        assert_Goal_variables   goal2, { m: nil, n: nil, y: [1,2,3] }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '    Goal3.:z',
          '  Goal2.[1, 2, 3]',
        ].join("\n")
        assert_Goal_variables   goal3, { m: nil, n: nil, z: [1,2,3] }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '    Goal2.:y',
          '      Goal2.[1, 2, 3]',
        ].join("\n")
      end
      
      it 'should not raise an exception when multiple values are equal' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal2
        variable3 = Porolog::Variable.new :z, goal3
        
        value1    = Porolog::Value.new 'word', goal2
        value2    = Porolog::Value.new 'word', goal3
        
        variable1.instantiate variable2
        variable1.instantiate variable3
        variable2.instantiate value1
        variable3.instantiate value2
        
        [
          value1,
          value2,
          variable1,
          variable2,
          variable3,
        ].each do |v|
          assert_equal    'word',   v.value,    "#{v.inspect} value should be 'word'"
        end
      end
      
      it 'should raise an exception when the variable has multiple different non-array values' do
        variable1 = Porolog::Variable.new :x, goal1
        
        variable1.values << 1
        variable1.values << 'one'
        
        error = assert_raises Porolog::Variable::MultipleValuesError do
          variable1.value
        end
        
        assert_equal    'Multiple values detected for Goal1.:x: [1, "one"]',    error.message
      end
      
      it 'should prioritise non-variables over variables' do
        variable1 = Porolog::Variable.new :x, goal1
        
        assert_equal    goal1[:x],     variable1.value
        
        variable1.values << :variable
        
        assert_equal    :variable,      variable1.value
        
        variable1.values << 'non-variable'
        variable1.values << :variable
        
        assert_equal    'non-variable', variable1.value
      end
      
      it 'should prioritise variables over an unknown array' do
        variable1 = Porolog::Variable.new :x, goal1
        
        assert_equal    goal1[:x],     variable1.value
        
        variable1.values << Porolog::UNKNOWN_ARRAY
        
        assert_equal    Porolog::UNKNOWN_ARRAY,  variable1.value
        
        variable1.values << :variable1
        variable1.values << :variable2
        variable1.values << Porolog::UNKNOWN_ARRAY
        
        assert_equal    :variable1,     variable1.value
      end
      
      it 'should unify a matching flathead and flattail pair' do
        variable1 = Porolog::Variable.new :x, goal1
        
        variable1.values << [1, 2, Porolog::UNKNOWN_TAIL]
        variable1.values << [Porolog::UNKNOWN_TAIL, 3, 4]
        
        assert_equal    [1,2,3,4],     variable1.value
      end
      
      it 'should unify a matching flattail and flathead pair' do
        variable1 = Porolog::Variable.new :x, goal1
        
        variable1.values << [Porolog::UNKNOWN_TAIL, 3, 4]
        variable1.values << [1, 2, Porolog::UNKNOWN_TAIL]
        
        assert_equal    [1,2,3,4],     variable1.value
      end
      
      it 'should return nil when the values are incompatible' do
        variable1 = Porolog::Variable.new :x, goal1
        
        variable1.values << [1, 3, 4]
        variable1.values << [1, 2, Porolog::UNKNOWN_TAIL]
        
        assert_nil                     variable1.value
      end
      
      it 'should unify a special case' do
        variable1 = Porolog::Variable.new :x, goal1
        
        variable1.values << [1,[3,4]]
        variable1.values << goal1[:h]/goal1[:t]
        
        assert_equal    [1,[3,4]],     variable1.value
      end
      
    end
    
    describe '#instantiate' do
      
      it 'should instantiate with another variable' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal2
        
        variable1.instantiate variable2
        
        assert_equal  "Goal1.:x\n  Goal2.:y",       variable1.inspect_with_instantiations
        assert_equal  "Goal2.:y\n  Goal1.:x",       variable2.inspect_with_instantiations
      end
      
      it 'should instantiate with a value' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal2
        value     = Porolog::Value.new 'word', goal2
        
        variable1.instantiate variable2
        variable2.instantiate value
        
        assert_equal  'word',                                       variable1.value
        assert_equal  "Goal1.:x\n  Goal2.:y\n    Goal2.\"word\"",   variable1.inspect_with_instantiations
        assert_equal  "Goal2.:y\n  Goal1.:x\n  Goal2.\"word\"",     variable2.inspect_with_instantiations
      end
      
      it 'should instantiate with an indexed variable' do
        # -- Elements --
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal2
        value     = Porolog::Value.new [7,11,13,23,29], goal2
        
        # -- Make Instantiations --
        #
        #   Goal1.:x == Goal2.y[2], Goal2.y == Goal2.[7,11,13,23,29]
        #
        variable1.instantiate variable2, 2
        variable2.instantiate value
        
        # -- Assert instantiations --
        assert_equal        1,          variable1.instantiations.size
        assert_equal        2,          variable2.instantiations.size
        
        assert_equal        'Goal1.:x = Goal2.:y[2]',                               variable1.instantiations[0].inspect
        assert_equal        'Goal1.:x = Goal2.:y[2]',                               variable2.instantiations[0].inspect
        assert_equal        'Goal2.:y = Goal2.[7, 11, 13, 23, 29]',                 variable2.instantiations[1].inspect
        
        assert_equal        variable1.instantiations[0],                            variable2.instantiations[0]
        
        assert_Instantiation    variable1.instantiations[0], variable1, variable2, nil, 2
        assert_Instantiation    variable2.instantiations[0], variable1, variable2, nil, 2
        assert_Instantiation    variable2.instantiations[1], variable2, value,     nil, nil
        
        assert_Value            variable2.instantiations[1].variable2,  [7, 11, 13, 23, 29], goal2
        
        # -- Assert Values --
        assert_equal  13,                     variable1.value
        assert_equal  [7, 11, 13, 23, 29],    variable2.value
        
        # -- Assert inspects --
        assert_equal  "Goal1.:x\n  Goal2.:y[2]\n    Goal2.[7, 11, 13, 23, 29]",    variable1.inspect_with_instantiations
        assert_equal  "Goal2.:y\n  [2]Goal1.:x\n  Goal2.[7, 11, 13, 23, 29]",      variable2.inspect_with_instantiations
      end
      
      it 'should instantiate indexed with an indexed variable' do
        # -- Elements --
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal2
        variable3 = Porolog::Variable.new :z, goal2
        value     = Porolog::Value.new [[],[1,2,3],'word',[7,11,13,23,29]], goal2
        
        assert_Value    value,        [[],[1,2,3],'word',[7,11,13,23,29]], goal2
        
        # -- Assert goal variables --
        assert_Goal_variables    goal1,    { m: nil, n: nil, x: nil },   [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
        ].join("\n")
        assert_Goal_variables    goal2,    { m: nil, n: nil, y: nil, z: nil },  [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          'Goal2.:z',
        ].join("\n")
        
        # -- Make instantiations --
        #
        #   Goal1.:x == Goal2.:y[2], Goal2.:y == [[],[1,2,3],'word',[7,11,13,23,29]][3]
        #
        variable1.instantiate variable2, 2
        
        #   Goal2.:y == [[],[1,2,3],'word',[7,11,13,23,29]][3]
        #            == [7,11,13,23,29]
        variable2.instantiate value,     3
        
        # -- Assert Values --
        assert_equal        13,                     variable1.value
        assert_equal        [7,11,13,23,29],        variable2.value
        assert_equal        variable3,              variable3.value
        
        # -- Assert instantiations --
        assert_equal        1,          variable1.instantiations.size
        assert_equal        2,          variable2.instantiations.size
        assert_equal        0,          variable3.instantiations.size
        
        assert_equal        'Goal1.:x = Goal2.:y[2]',                               variable1.instantiations[0].inspect
        assert_equal        'Goal1.:x = Goal2.:y[2]',                               variable2.instantiations[0].inspect
        assert_equal        'Goal2.:y = Goal2.[[], [1, 2, 3], "word", [7, 11, 13, 23, 29]][3]',              variable2.instantiations[1].inspect
        
        assert_equal        variable1.instantiations[0],                            variable2.instantiations[0]
        
        assert_Instantiation    variable1.instantiations[0], variable1, variable2, nil, 2
        assert_Instantiation    variable2.instantiations[0], variable1, variable2, nil, 2
        assert_Instantiation    variable2.instantiations[1], variable2, value,     nil, 3
        
        assert_Value        variable2.instantiations[1].variable2,  [[],[1,2,3],'word',[7,11,13,23,29]], goal2
        
        # -- Assert overall instantiations --
        assert_equal        "Goal2.:y\n  [2]Goal1.:x\n  Goal2.[[], [1, 2, 3], \"word\", [7, 11, 13, 23, 29]][3]",    variable2.inspect_with_instantiations
        assert_equal        "Goal1.:x\n  Goal2.:y[2]\n    Goal2.[[], [1, 2, 3], \"word\", [7, 11, 13, 23, 29]][3]",  variable1.inspect_with_instantiations
        
        # -- Assert values --
        assert_equal        [],                           variable1.values
        assert_equal        0,                            variable2.values.size
        assert_equal        [],                           variable3.values
        
        assert_equal        [7,11,13,23,29],              variable2.value
        assert_equal        13,                           variable1.value
        assert_equal        [7, 11, 13, 23, 29],          variable2.value
        
        assert_Goal_variables    goal1,    { m: nil, n: nil, x: 13 }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y[2]',
          '    Goal2.[[], [1, 2, 3], "word", [7, 11, 13, 23, 29]][3]',
        ].join("\n")

        assert_Goal_variables    goal2,    { m: nil, n: nil, y: [7, 11, 13, 23, 29], z: nil}, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  [2]Goal1.:x',
          '  Goal2.[[], [1, 2, 3], "word", [7, 11, 13, 23, 29]][3]',
          'Goal2.:z',
        ].join("\n")
        
        assert_Goal_variables    goal1,    { m: nil, n: nil, x: 13              }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y[2]',
          '    Goal2.[[], [1, 2, 3], "word", [7, 11, 13, 23, 29]][3]'
        ].join("\n")
        
        assert_Goal_variables    goal2,    { m: nil, n: nil, y: [7, 11, 13, 23, 29], z: nil }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  [2]Goal1.:x',
          '  Goal2.[[], [1, 2, 3], "word", [7, 11, 13, 23, 29]][3]',
          'Goal2.:z'
        ].join("\n")
      end
      
      it 'should instantiate with an indexed value' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal2
        value     = Porolog::Value.new [7,11,13,23,29], goal2
        
        variable1.instantiate variable2
        variable2.instantiate value, 3
        
        assert_equal  "Goal1.:x\n  Goal2.:y\n    Goal2.[7, 11, 13, 23, 29][3]",   variable1.inspect_with_instantiations
        assert_equal  "Goal2.:y\n  Goal1.:x\n  Goal2.[7, 11, 13, 23, 29][3]",     variable2.inspect_with_instantiations
      end
      
      it 'should instantiate with an indexed variable' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal2
        value     = Porolog::Value.new [7,11,13,23,29], goal2
        
        variable1.instantiate variable2, 2
        variable2.instantiate value
        
        assert_equal  13,   variable1.value
        assert_equal  "Goal1.:x\n  Goal2.:y[2]\n    Goal2.[7, 11, 13, 23, 29]",  variable1.inspect_with_instantiations
        assert_equal  "Goal2.:y\n  [2]Goal1.:x\n  Goal2.[7, 11, 13, 23, 29]",    variable2.inspect_with_instantiations
      end
      
      it 'should instantiate with an indexed value' do
        variable1 = Porolog::Variable.new :x, goal1
        variable2 = Porolog::Variable.new :y, goal2
        value     = Porolog::Value.new [7,11,13,23,29], goal2
        
        variable1.instantiate variable2
        variable2.instantiate value, 3
        
        assert_equal  "Goal1.:x\n  Goal2.:y\n    Goal2.[7, 11, 13, 23, 29][3]",   variable1.inspect_with_instantiations
        assert_equal  "Goal2.:y\n  Goal1.:x\n  Goal2.[7, 11, 13, 23, 29][3]",     variable2.inspect_with_instantiations
      end
      
      it 'should detect deep conflicting instantiations' do
        #          g1:a
        #       g2:b  g3:c
        #    g4:d        g5:e
        # g6:f              g7:g
        #   8                 9
        reset
        g1 = arguments1.goal
        g2 = arguments1.goal
        g3 = arguments1.goal
        g4 = arguments1.goal
        g5 = arguments1.goal
        g6 = arguments1.goal
        g7 = arguments1.goal
        
        a = g1.variable :a
        b = g2.variable :b
        c = g3.variable :c
        d = g4.variable :d
        e = g5.variable :e
        f = g6.variable :f
        g = g7.variable :g
        
        assert_instance_of  Porolog::Instantiation,   f.instantiate(g6.value(8))
        assert_instance_of  Porolog::Instantiation,   g.instantiate(g7.value(9))
        
        assert_instance_of  Porolog::Instantiation,   a.instantiate(b)
        assert_instance_of  Porolog::Instantiation,   a.instantiate(c)
        assert_instance_of  Porolog::Instantiation,   b.instantiate(d)
        assert_instance_of  Porolog::Instantiation,   d.instantiate(f)
        assert_instance_of  Porolog::Instantiation,   c.instantiate(e)
        assert_nil                                    e.instantiate(g)
        
        assert_Goal_variables g1, { m: nil, n: nil, a: 8 }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:a',
          '  Goal2.:b',
          '    Goal4.:d',
          '      Goal6.:f',
          '        Goal6.8',
          '  Goal3.:c',
          '    Goal5.:e',
        ].join("\n")
        assert_Goal_variables g2, { m: nil, n: nil, b: 8 }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:b',
          '  Goal1.:a',
          '    Goal3.:c',
          '      Goal5.:e',
          '  Goal4.:d',
          '    Goal6.:f',
          '      Goal6.8',
        ].join("\n")
        assert_Goal_variables g3, { m: nil, n: nil, c: 8 }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:c',
          '  Goal1.:a',
          '    Goal2.:b',
          '      Goal4.:d',
          '        Goal6.:f',
          '          Goal6.8',
          '  Goal5.:e',
        ].join("\n")
        assert_Goal_variables g4, { m: nil, n: nil, d: 8 }, [
          'Goal4.:m',
          'Goal4.:n',
          'Goal4.:d',
          '  Goal2.:b',
          '    Goal1.:a',
          '      Goal3.:c',
          '        Goal5.:e',
          '  Goal6.:f',
          '    Goal6.8',
        ].join("\n")
        assert_Goal_variables g5, { m: nil, n: nil, e: 8 }, [
          'Goal5.:m',
          'Goal5.:n',
          'Goal5.:e',
          '  Goal3.:c',
          '    Goal1.:a',
          '      Goal2.:b',
          '        Goal4.:d',
          '          Goal6.:f',
          '            Goal6.8',
        ].join("\n")
        assert_Goal_variables g6, { m: nil, n: nil, f: 8 }, [
          'Goal6.:m',
          'Goal6.:n',
          'Goal6.:f',
          '  Goal6.8',
          '  Goal4.:d',
          '    Goal2.:b',
          '      Goal1.:a',
          '        Goal3.:c',
          '          Goal5.:e',
        ].join("\n")
        assert_Goal_variables g7, { m: nil, n: nil, g: 9 }, [
          'Goal7.:m',
          'Goal7.:n',
          'Goal7.:g',
          '  Goal7.9',
        ].join("\n")
      end
      
      it 'should return nil when the there are multiple different values' do
        variable1 = Porolog::Variable.new :x, goal1
        value     = Porolog::Value.new 111, goal2
        
        variable1.values << 112
        
        instantiation = variable1.instantiate value
        
        assert_nil    instantiation, name
      end
      
    end
    
    describe '#remove' do
      
      let(:variable1) { Porolog::Variable.new :x,  goal1 }
      let(:variable2) { Porolog::Variable.new :y,  goal2 }
      let(:variable3) { Porolog::Variable.new :z,  goal3 }
      let(:value1)    { Porolog::Value.new 'word', goal2 }
      let(:value2)    { Porolog::Value.new 'word', goal3 }
      
      before do
        variable1.instantiate variable2
        variable1.instantiate variable3
        variable2.instantiate value1
        variable3.instantiate value2
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '    Goal3.:z',
          '      Goal3."word"',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '    Goal2.:y',
          '      Goal2."word"',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    2,        variable1.instantiations.size
        assert_equal    2,        variable2.instantiations.size
        assert_equal    2,        variable3.instantiations.size
        
        assert_Instantiation      variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation      variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable2.instantiations[1], variable2, value1,    nil, nil
        assert_Instantiation      variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation      variable3.instantiations[1], variable3, value2,    nil, nil
        
        assert_equal    'word',   variable1.value
        assert_equal    'word',   variable2.value
        assert_equal    'word',   variable3.value
      end
      
      it 'should remove all instantiations case 1: remove variable1' do
        
        variable1.remove
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: nil }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    0,          variable1.instantiations.size
        assert_equal    1,          variable2.instantiations.size
        assert_equal    1,          variable3.instantiations.size
        
        assert_nil                  variable1.instantiations[0]
        assert_nil                  variable1.instantiations[1]
        assert_nil                  variable2.instantiations[1]
        assert_Instantiation        variable2.instantiations[0], variable2, value1,    nil, nil
        assert_nil                  variable3.instantiations[1]
        assert_Instantiation        variable3.instantiations[0], variable3, value2,    nil, nil
        
        assert_equal    variable1,  variable1.value
        assert_equal    'word',     variable2.value
        assert_equal    'word',     variable3.value
      end
      
      it 'should remove all instantiations case 2: remove variable2' do
        
        variable2.remove
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: nil }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    1,          variable1.instantiations.size
        assert_equal    0,          variable2.instantiations.size
        assert_equal    2,          variable3.instantiations.size
        
        assert_nil                  variable1.instantiations[1]
        assert_Instantiation        variable1.instantiations[0], variable1, variable3, nil, nil
        assert_nil                  variable2.instantiations[0]
        assert_nil                  variable2.instantiations[1]
        assert_Instantiation        variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation        variable3.instantiations[1], variable3, value2,    nil, nil
        
        assert_equal    'word',     variable1.value
        assert_equal    variable2,  variable2.value
        assert_equal    'word',     variable3.value
      end
      
      it 'should remove all instantiations case 3: remove variable3' do
        
        variable3.remove
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: nil }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
        ].join("\n")
        
        assert_equal    1,          variable1.instantiations.size
        assert_equal    2,          variable2.instantiations.size
        assert_equal    0,          variable3.instantiations.size
        
        assert_Instantiation        variable1.instantiations[0], variable1, variable2, nil, nil
        assert_nil                  variable1.instantiations[1]
        assert_Instantiation        variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation        variable2.instantiations[1], variable2, value1,    nil, nil
        assert_nil                  variable3.instantiations[0]
        assert_nil                  variable3.instantiations[1]
        
        assert_equal    'word',     variable1.value
        assert_equal    'word',     variable2.value
        assert_equal    variable3,  variable3.value
      end
      
    end
    
    describe '#uninstantiate' do
      
      let(:variable1) { Porolog::Variable.new :x,  goal1 }
      let(:variable2) { Porolog::Variable.new :y,  goal2 }
      let(:variable3) { Porolog::Variable.new :z,  goal3 }
      let(:value1)    { Porolog::Value.new 'word', goal2 }
      let(:value2)    { Porolog::Value.new 'word', goal3 }
      
      before do
        variable1.instantiate variable2
        variable1.instantiate variable3
        variable2.instantiate value1
        variable3.instantiate value2
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '    Goal3.:z',
          '      Goal3."word"',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '    Goal2.:y',
          '      Goal2."word"',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    2,        variable1.instantiations.size
        assert_equal    2,        variable2.instantiations.size
        assert_equal    2,        variable3.instantiations.size
        
        assert_Instantiation      variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation      variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable2.instantiations[1], variable2, value1,    nil, nil
        assert_Instantiation      variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation      variable3.instantiations[1], variable3, value2,    nil, nil
        
        assert_equal    'word',   variable1.value
        assert_equal    'word',   variable2.value
        assert_equal    'word',   variable3.value
      end
      
      it 'should remove all instantiations and values case 1' do
        
        variable1.uninstantiate(goal1)
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '    Goal3.:z',
          '      Goal3."word"',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '    Goal2.:y',
          '      Goal2."word"',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    2,        variable1.instantiations.size
        assert_equal    2,        variable2.instantiations.size
        assert_equal    2,        variable3.instantiations.size
        
        assert_Instantiation      variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation      variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable2.instantiations[1], variable2, value1,    nil, nil
        assert_Instantiation      variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation      variable3.instantiations[1], variable3, value2,    nil, nil
        
        assert_equal    'word',   variable1.value
        assert_equal    'word',   variable2.value
        assert_equal    'word',   variable3.value
      end
      
      it 'should remove all instantiations and values case 2' do
        
        variable1.uninstantiate(goal2)
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: nil }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    0,          variable1.instantiations.size
        assert_equal    1,          variable2.instantiations.size
        assert_equal    2,          variable3.instantiations.size
        
        assert_nil                  variable1.instantiations[0]
        assert_nil                  variable1.instantiations[1]
        assert_nil                  variable2.instantiations[1]
        assert_Instantiation        variable2.instantiations[0], variable2, value1,    nil, nil
        assert_Instantiation        variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation        variable3.instantiations[1], variable3, value2,    nil, nil
        
        assert_equal    variable1,  variable1.value
        assert_equal    'word',     variable2.value
        assert_equal    'word',     variable3.value
      end
      
      it 'should remove all instantiations and values case 3' do
        
        variable1.uninstantiate(goal3)
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    1,        variable1.instantiations.size
        assert_equal    2,        variable2.instantiations.size
        assert_equal    1,        variable3.instantiations.size
        
        assert_Instantiation      variable1.instantiations[0], variable1, variable2, nil, nil
        assert_nil                variable1.instantiations[1]
        assert_Instantiation      variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable2.instantiations[1], variable2, value1,    nil, nil
        assert_nil                variable3.instantiations[1]
        assert_Instantiation      variable3.instantiations[0], variable3, value2,    nil, nil
        
        assert_equal    'word',   variable1.value
        assert_equal    'word',   variable2.value
        assert_equal    'word',   variable3.value
      end
      
      it 'should remove all instantiations and values case 4' do
        
        variable2.uninstantiate(goal1)
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: nil }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    1,          variable1.instantiations.size
        assert_equal    0,          variable2.instantiations.size
        assert_equal    2,          variable3.instantiations.size
        
        assert_nil                  variable1.instantiations[1]
        assert_Instantiation        variable1.instantiations[0], variable1, variable3, nil, nil
        assert_nil                  variable2.instantiations[0]
        assert_nil                  variable2.instantiations[1]
        assert_Instantiation        variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation        variable3.instantiations[1], variable3, value2,    nil, nil
        
        assert_equal    'word',     variable1.value
        assert_equal    variable2,  variable2.value
        assert_equal    'word',     variable3.value
      end
      
      it 'should remove all instantiations and values case 5' do
        
        variable2.uninstantiate(goal2)
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '    Goal3.:z',
          '      Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '    Goal2.:y',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    2,        variable1.instantiations.size
        assert_equal    1,        variable2.instantiations.size
        assert_equal    2,        variable3.instantiations.size
        
        assert_Instantiation      variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation      variable2.instantiations[0], variable1, variable2, nil, nil
        assert_nil                variable2.instantiations[1]
        assert_Instantiation      variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation      variable3.instantiations[1], variable3, value2,    nil, nil
        
        assert_equal    'word',   variable1.value
        assert_equal    'word',   variable2.value
        assert_equal    'word',   variable3.value
      end
      
      it 'should remove all instantiations and values case 6' do
        
        variable2.uninstantiate(goal3)
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '    Goal3.:z',
          '      Goal3."word"',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '    Goal2.:y',
          '      Goal2."word"',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    2,        variable1.instantiations.size
        assert_equal    2,        variable2.instantiations.size
        assert_equal    2,        variable3.instantiations.size
        
        assert_Instantiation      variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation      variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable2.instantiations[1], variable2, value1,    nil, nil
        assert_Instantiation      variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation      variable3.instantiations[1], variable3, value2,    nil, nil
        
        assert_equal    'word',   variable1.value
        assert_equal    'word',   variable2.value
        assert_equal    'word',   variable3.value
      end
      
      it 'should remove all instantiations and values case 7' do
        
        variable3.uninstantiate(goal1)
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: nil }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
        ].join("\n")
        
        assert_equal    1,          variable1.instantiations.size
        assert_equal    2,          variable2.instantiations.size
        assert_equal    0,          variable3.instantiations.size
        
        assert_Instantiation        variable1.instantiations[0], variable1, variable2, nil, nil
        assert_nil                  variable1.instantiations[1]
        assert_Instantiation        variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation        variable2.instantiations[1], variable2, value1,    nil, nil
        assert_nil                  variable3.instantiations[0]
        assert_nil                  variable3.instantiations[1]
        
        assert_equal    'word',     variable1.value
        assert_equal    'word',     variable2.value
        assert_equal    variable3,  variable3.value
      end
      
      it 'should remove all instantiations and values case 8' do
        
        variable3.uninstantiate(goal2)
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
          '  Goal3.:z',
          '    Goal3."word"',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '    Goal3.:z',
          '      Goal3."word"',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '    Goal2.:y',
          '      Goal2."word"',
          '  Goal3."word"',
        ].join("\n")
        
        assert_equal    2,        variable1.instantiations.size
        assert_equal    2,        variable2.instantiations.size
        assert_equal    2,        variable3.instantiations.size
        
        assert_Instantiation      variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation      variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable2.instantiations[1], variable2, value1,    nil, nil
        assert_Instantiation      variable3.instantiations[0], variable1, variable3, nil, nil
        assert_Instantiation      variable3.instantiations[1], variable3, value2,    nil, nil
        
        assert_equal    'word',   variable1.value
        assert_equal    'word',   variable2.value
        assert_equal    'word',   variable3.value
      end
      
      it 'should remove all instantiations and values case 9' do
        
        variable3.uninstantiate(goal3)
        
        assert_Goal_variables     goal1, { m: nil, n: nil, x: 'word' }, [
          'Goal1.:m',
          'Goal1.:n',
          'Goal1.:x',
          '  Goal2.:y',
          '    Goal2."word"',
          '  Goal3.:z',
        ].join("\n")
        
        assert_Goal_variables     goal2, { m: nil, n: nil, y: 'word' }, [
          'Goal2.:m',
          'Goal2.:n',
          'Goal2.:y',
          '  Goal1.:x',
          '    Goal3.:z',
          '  Goal2."word"',
        ].join("\n")
        
        assert_Goal_variables     goal3, { m: nil, n: nil, z: 'word' }, [
          'Goal3.:m',
          'Goal3.:n',
          'Goal3.:z',
          '  Goal1.:x',
          '    Goal2.:y',
          '      Goal2."word"',
        ].join("\n")
        
        assert_equal    2,        variable1.instantiations.size
        assert_equal    2,        variable2.instantiations.size
        assert_equal    1,        variable3.instantiations.size
        
        assert_Instantiation      variable1.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable1.instantiations[1], variable1, variable3, nil, nil
        assert_Instantiation      variable2.instantiations[0], variable1, variable2, nil, nil
        assert_Instantiation      variable2.instantiations[1], variable2, value1,    nil, nil
        assert_Instantiation      variable3.instantiations[0], variable1, variable3, nil, nil
        assert_nil                variable3.instantiations[1]
        
        assert_equal    'word',   variable1.value
        assert_equal    'word',   variable2.value
        assert_equal    'word',   variable3.value
      end
      
    end
    
    describe '#[]' do
      
      it 'should return the element at the specified index' do
        variable = Porolog::Variable.new :x, goal1
        value    = Porolog::Value.new [3,5,7,11,13,17], goal2
        
        variable.instantiate value
        
        assert_equal    [3,5,7,11,13,17],     variable.value
        assert_equal    13,                   variable[4]
      end
      
      it 'should return nil for an out of range index' do
        variable = Porolog::Variable.new :x, goal1
        value    = Porolog::Value.new [3,5,7,11,13,17], goal2
        
        variable.instantiate value
        
        assert_equal    [3,5,7,11,13,17],     variable.value
        assert_nil                            variable[200]
      end
      
      it 'should return nil when the value is not an array' do
        variable = Porolog::Variable.new :x, goal1
        value    = Porolog::Value.new 12, goal2
        
        variable.instantiate value
        
        assert_equal    12,                   variable.value
        assert_nil                            variable[0]
      end
      
      it 'should return the head' do
        variable = Porolog::Variable.new :x, goal1
        value    = Porolog::Value.new [3,5,7,11,13,17], goal2
        
        variable.instantiate value
        
        assert_equal    [3,5,7,11,13,17],     variable.value
        assert_equal    3,                    variable[:head]
      end
      
      it 'should return the tail' do
        variable = Porolog::Variable.new :x, goal1
        value    = Porolog::Value.new [3,5,7,11,13,17], goal2
        
        variable.instantiate value
        
        assert_equal    [3,5,7,11,13,17],     variable.value
        assert_equal    [5,7,11,13,17],       variable[:tail]
      end
      
    end
    
    describe '#variables' do
      
      it 'should return an Array of itself' do
        variable = Porolog::Variable.new :x, goal1
        
        assert_equal    [variable],   variable.variables
      end
      
    end
    
  end

end
