#
#   test/porolog/rule_test.rb     - Test Suite for Porolog::Rule
#
#     Luis Esteban      2 May 2018
#       created
#


require_relative '../test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end

  describe 'Rule' do
    
    describe '.reset' do
      
      it 'should delete/unregister all rules' do
        pred = Porolog::Predicate.new :pred
        args = Porolog::Arguments.new pred, [1,2,3]
        
        rule1 = Porolog::Rule.new args, [1,2]
        rule2 = Porolog::Rule.new args, [3,4,5]
        rule3 = Porolog::Rule.new args, [6]
        
        assert_equal  'Rule1',    rule1.myid
        assert_equal  'Rule2',    rule2.myid
        assert_equal  'Rule3',    rule3.myid
        
        Porolog::Rule.reset
        
        rule4 = Porolog::Rule.new args, [7,8,9,0]
        rule5 = Porolog::Rule.new args, [:CUT,false]
        
        assert_equal  'Rule-999', rule1.myid
        assert_equal  'Rule-999', rule2.myid
        assert_equal  'Rule-999', rule3.myid
        assert_equal  'Rule1',    rule4.myid
        assert_equal  'Rule2',    rule5.myid
      end
      
    end
    
    describe '.new' do
      
      it 'should create a new rule' do
        pred = Porolog::Predicate.new :pred
        args = Porolog::Arguments.new pred, [1,2,3]
        defn = [true]
        rule = Porolog::Rule.new args, defn
        
        assert_Rule         rule, :pred, [1,2,3], [true]
      end
      
    end
    
    describe '#initialize' do
      
      it 'should initialize arguments and definition' do
        pred = Porolog::Predicate.new :pred
        args = Porolog::Arguments.new pred, [1,2,3]
        defn = [:CUT,false]
        rule = Porolog::Rule.new args, defn
        
        assert_Rule   rule,   :pred, [1,2,3], [:CUT,false]
        assert_equal  args,   rule.arguments
        assert_equal  defn,   rule.definition
      end
      
    end
    
    describe '#myid' do
      
      it 'should show the rule index' do
        pred = Porolog::Predicate.new :pred
        args = Porolog::Arguments.new pred, [1,2,3]
        defn = [:CUT,false]
        rule = Porolog::Rule.new args, defn
        
        assert_equal  'Rule1',    rule.myid
      end
      
      it 'should show -999 when deleted/unregistered' do
        pred = Porolog::Predicate.new :pred
        args = Porolog::Arguments.new pred, [1,2,3]
        defn = [:CUT,false]
        rule = Porolog::Rule.new args, defn
        
        Porolog::Rule.reset
        
        assert_equal  'Rule-999', rule.myid
      end
      
    end
    
    describe '#inspect' do
      
      it 'should show the predicate, arguments, and definition' do
        pred = Porolog::Predicate.new :pred
        args = Porolog::Arguments.new pred, [1,2,3]
        defn = [:CUT,false]
        rule = Porolog::Rule.new args, defn
        
        assert_equal  '  pred(1,2,3):- [:CUT, false]',    rule.inspect
      end
      
    end
    
    describe '#satisfy' do
      
      it 'should create a subgoal and unify with the goal' do
        pred = Porolog::Predicate.new :pred
        args = Porolog::Arguments.new pred, [:a,:b,:c]
        defn = [true]
        rule = Porolog::Rule.new args, defn
        
        goal = new_goal :pred, :x, :y, :z
        
        called = false
        rule.satisfy(goal) do |solution_goal|
          called = true
          
          assert_Goal             solution_goal,    :pred, [:a, :b, :c].map{|name| solution_goal.variable(name) }
          assert_Goal_variables   solution_goal,    { a: nil, b: nil, c: nil }, [
            'Goal2.:a',
            '  Goal1.:x',
            'Goal2.:b',
            '  Goal1.:y',
            'Goal2.:c',
            '  Goal1.:z',
          ].join("\n")
          
          assert_equal            goal,             solution_goal.calling_goal
        end
        
        assert  called, 'the satisfy block should be called'
      end
      
      it 'should delete the subgoal even if it does not unify with the goal' do
        pred = Porolog::Predicate.new :alpha
        args = Porolog::Arguments.new pred, [1,2,3,4]
        defn = [true]
        rule = Porolog::Rule.new args, defn
        
        goal    = new_goal :beta, :x, :y
        
        subgoal = new_goal :gamma, :x, :y
        subgoal.expects(:delete!).with().times(1)
        subgoal_spy = Spy.on(Porolog::Goal, :new).and_return(subgoal)
        called      = false
        
        rule.satisfy(goal) do |solution_goal|
          #:nocov:
          called = true
          #:nocov:
        end
        refute called, 'the satisfy block should not be called'
        assert_equal  1,  subgoal_spy.calls.size
      end
      
    end
    
    describe '#satisfy_definition' do
      
      it 'should call block with subgoal and return true when the definition is true' do
        pred = Porolog::Predicate.new :normal
        args = Porolog::Arguments.new pred, [12]
        rule = Porolog::Rule.new args, true
        
        check  = 56
        result = rule.satisfy_definition(12, 34) do |subgoal|
          assert_equal    34,   subgoal
          check = 78
        end
        assert_equal    true,   result
        assert_equal    78,     check
      end
      
      it 'should not call block but return false when the definition is false' do
        pred = Porolog::Predicate.new :negative
        args = Porolog::Arguments.new pred, [12]
        rule = Porolog::Rule.new args, false
        
        check  = 56
        result = rule.satisfy_definition(12, 34) do |subgoal|
          #:nocov:
          check = 78
          #:nocov:
        end
        assert_equal    false,  result
        assert_equal    56,     check
      end
      
      it 'should call block with subgoal when the definition is an Array' do
        pred1 = Porolog::Predicate.new :success
        args1 = Porolog::Arguments.new pred1, [:any]
        Porolog::Rule.new args1, true
        
        pred2 = Porolog::Predicate.new :conjunction
        args2 = Porolog::Arguments.new pred2, [12]
        rule2 = Porolog::Rule.new args2, [true,true,true]
        
        check  = 56
        result = rule2.satisfy_definition(args1.goal, args2.goal) do |subgoal|
          check = 78
        end
        assert_equal    true,   result
        assert_equal    78,     check
      end
      
      it 'should raise an exception when the definition is unknown' do
        Porolog::predicate :strange
        
        strange(12) << 3.4
        
        exception = assert_raises Porolog::Rule::DefinitionError do
          strange(:X).solve
        end
        assert_equal  'UNEXPECTED TYPE OF DEFINITION: 3.4 (Float)',  exception.message
      end
      
    end
    
    describe '#satisfy_conjunction' do
      
      let(:pred1  ) { Porolog::Predicate.new :parent }
      let(:pred2  ) { Porolog::Predicate.new :child }
      let(:args1  ) { Porolog::Arguments.new pred1, [1,2,3,4] }
      let(:args2  ) { Porolog::Arguments.new pred2, [:x,:y] }
      let(:goal   ) { Porolog::Goal.new args1, nil }
      let(:subgoal) { Porolog::Goal.new args2, goal }
      
      it 'should handle CUT expression' do
        rule = Porolog::Rule.new args1, [:CUT,true]
        
        goal.expects(:terminate!).with().times(1)
        rule_spy = Spy.on(rule, :satisfy_conjunction).and_call_through
        called   = false
        
        result = rule.satisfy_conjunction(goal, subgoal, rule.definition) do |solution_goal|
          called = true
        end
        
        assert          result,                         'satisfy_conjunction should succeed'
        assert          called,                         'the satisfy block should be called'
        assert_equal    2,                              rule_spy.calls.size
        assert_equal    [goal, subgoal, [true]],        rule_spy.calls[0].args    # innermost call; finishes first
        assert_equal    [goal, subgoal, [:CUT,true]],   rule_spy.calls[1].args    # outermost call; finishes last
      end
      
      it 'should handle CUT expression at the end of a conjunction' do
        rule = Porolog::Rule.new args1, [:CUT]
        
        goal.expects(:terminate!).with().times(1)
        rule_spy = Spy.on(rule, :satisfy_conjunction).and_call_through
        called   = false
        
        result = rule.satisfy_conjunction(goal, subgoal, rule.definition) do |solution_goal|
          called = true
        end
        
        assert          result,                         'satisfy_conjunction should succeed'
        assert          called,                         'the satisfy block should be called'
        assert_equal    1,                              rule_spy.calls.size
        assert_equal    [goal, subgoal, [:CUT]],        rule_spy.calls[0].args
      end
      
      it 'should handle true expression' do
        rule = Porolog::Rule.new args1, [true]
        
        goal.expects(:terminate!).with().times(0)
        rule_spy = Spy.on(rule, :satisfy_conjunction).and_call_through
        called   = false
        
        result = rule.satisfy_conjunction(goal, subgoal, rule.definition) do |solution_goal|
          called = true
        end
        
        assert          result,                         'satisfy_conjunction should succeed'
        assert          called,                         'the satisfy block should be called'
        assert_equal    1,                              rule_spy.calls.size
        assert_equal    [goal, subgoal, [true]],        rule_spy.calls[0].args
      end
      
      it 'should handle false expression' do
        rule = Porolog::Rule.new args1, [false]
        
        goal.expects(:terminate!).with().times(0)
        rule_spy = Spy.on(rule, :satisfy_conjunction).and_call_through
        called   = false
        
        result = rule.satisfy_conjunction(goal, subgoal, rule.definition) do |solution_goal|
          #:nocov:
          called = true
          #:nocov:
        end
        
        refute          result,                         'satisfy_conjunction should not succeed'
        refute          called,                         'the satisfy block should not be called'
        assert_equal    1,                              rule_spy.calls.size
        assert_equal    [goal, subgoal, [false]],       rule_spy.calls[0].args
      end
      
      it 'should handle nil expression' do
        rule = Porolog::Rule.new args1, []
        
        goal.expects(:terminate!).with().times(0)
        rule_spy = Spy.on(rule, :satisfy_conjunction).and_call_through
        called   = false
        
        result = rule.satisfy_conjunction(goal, subgoal, rule.definition) do |solution_goal|
          #:nocov:
          called = true
          #:nocov:
        end
        
        assert          result,                         'satisfy_conjunction should not succeed'
        assert          called,                         'the satisfy block should not be called'
        assert_equal    1,                              rule_spy.calls.size
        assert_equal    [goal, subgoal, []],            rule_spy.calls[0].args
      end
      
      it 'should evaluate conjunctions until a fail' do
        conjunction = [true, true, true, false, true, :CUT, true]
        rule = Porolog::Rule.new args1, conjunction
        
        goal.expects(:terminate!).with().times(0)
        rule_spy = Spy.on(rule, :satisfy_conjunction).and_call_through
        called   = false
        
        result = rule.satisfy_conjunction(goal, subgoal, rule.definition) do |solution_goal|
          #:nocov:
          called = true
          #:nocov:
        end
        
        refute          result,                               'satisfy_conjunction should not succeed'
        refute          called,                               'the satisfy block should not be called'
        assert_equal    4,                                    rule_spy.calls.size
        assert_equal    [goal, subgoal, conjunction[3..-1]],  rule_spy.calls[0].args
        assert_equal    [goal, subgoal, conjunction[2..-1]],  rule_spy.calls[1].args
        assert_equal    [goal, subgoal, conjunction[1..-1]],  rule_spy.calls[2].args
        assert_equal    [goal, subgoal, conjunction[0..-1]],  rule_spy.calls[3].args
      end
      
      it 'should unify and instantiate variables with a subgoal and satisfy the subgoal and uninstantiate the instantiations' do
        goal    = Porolog::Goal.new args1, nil
        subgoal = Porolog::Goal.new args2, goal
        
        Porolog::predicate :gamma
        
        gamma(8,5).fact!
        
        rule = Porolog::Rule.new args1, [gamma(:j,:k)]
        
        subsubgoal = new_goal :gamma, :y, :z
        subsubgoal_spy = Spy.on(Porolog::Goal, :new).and_return do |*args|
          Spy.off(Porolog::Goal, :new)
          subsubgoal
        end
        
        goal.expects(:terminate!).with().times(0)
        subgoal.expects(:terminate!).with().times(0)
        subsubgoal.expects(:terminate!).with().times(0)
        
        goal.expects(:delete!).with().times(0)
        subgoal.expects(:delete!).with().times(0)
        subsubgoal.expects(:delete!).with().times(1)
        
        rule_spy = Spy.on(rule, :satisfy_conjunction).and_call_through
        called   = false
        
        result = rule.satisfy_conjunction(goal, subgoal, rule.definition) do |solution_goal|
          called = true
          assert_Goal               goal,       :parent, [1,2,3,4]
          assert_Goal_variables     goal,       {}, ''
          assert_Goal_variables     subgoal,    { x: nil, y: 8, z: 5 }, [
            'Goal2.:x',
            '  Goal3.:x',
            'Goal2.:y',
            '  Goal3.:y',
            '    Goal4.8',
            'Goal2.:z',
            '  Goal3.:z',
            '    Goal4.5',
          ].join("\n")
          assert_Goal_variables     subsubgoal, { x: nil, y: 8, z: 5 }, [
            'Goal3.:y',
            '  Goal2.:y',
            '  Goal4.8',
            'Goal3.:z',
            '  Goal2.:z',
            '  Goal4.5',
            'Goal3.:x',
            '  Goal2.:x',
          ].join("\n")
        end
        
        assert          result,                           'satisfy_conjunction should succeed'
        assert          called,                           'the satisfy block should be called'
        assert_equal    1,                                subsubgoal_spy.calls.size
        assert_equal    1,                                rule_spy.calls.size
        assert_equal    [goal, subgoal, [gamma(:j,:k)]],  rule_spy.calls[0].args
        
        assert_Goal_variables     subgoal,    { x: nil, y: nil, z: nil }, [
          'Goal2.:x',
          '  Goal3.:x',
          'Goal2.:y',
          '  Goal3.:y',
          'Goal2.:z',
          '  Goal3.:z',
        ].join("\n")
        assert_Goal_variables     subsubgoal, { x: nil, y: nil, z: nil }, [
          'Goal3.:y',
          '  Goal2.:y',
          'Goal3.:z',
          '  Goal2.:z',
          'Goal3.:x',
          '  Goal2.:x',
        ].join("\n")
      end
      
      it 'should not unify and not instantiate variables with a subgoal nor satisfy the subgoal when it cannot be unified' do
        # -- Create Goals --
        goal    = Porolog::Goal.new args1, nil
        subgoal = Porolog::Goal.new args2, goal
        subgoal.instantiate :y, 7
        
        # -- Create goal for satisfy_conjunction() --
        subsubgoal = new_goal :gamma, :y, :y, :z
        subsubgoal.instantiate    :y, 3
        
        # -- Check goals are setup correctly --
        assert_Goal     goal,                                   :parent,  [1,2,3,4]
        assert_Goal     subgoal,                                :child,   [:x,:y]
        assert_equal    'Goal1 -- Solve parent(1,2,3,4)',       goal.inspect
        assert_equal    'Goal2 -- Solve child(:x,:y)',          subgoal.inspect
        
        assert_Goal_variables   goal,       {}, [].join("\n")
        
        assert_Goal_variables   subgoal,    { x: nil, y: 7 }, [
          'Goal2.:x',
          'Goal2.:y',
          '  Goal2.7',
        ].join("\n")
        
        assert_Goal_variables   subsubgoal, { y: 3, z: nil }, [
          'Goal3.:y',
          '  Goal3.3',
          'Goal3.:z',
        ].join("\n")
        
        # -- Define Predicate --
        Porolog::predicate :gamma
        
        gamma(8,5).fact!
        
        rule = Porolog::Rule.new args1, [gamma(:j,:k)]
        
        # -- Prepare Checks for satisfy_conjunction() --
        subsubgoal_spy = Spy.on(Porolog::Goal, :new).and_return do |*args|
          Spy.off(Porolog::Goal, :new)
          subsubgoal
        end
        
        goal.      expects(:terminate!).with().times(0)
        subgoal.   expects(:terminate!).with().times(0)
        subsubgoal.expects(:terminate!).with().times(0)
        
        goal.      expects(:delete!).with().times(0)
        subgoal.   expects(:delete!).with().times(0)
        subsubgoal.expects(:delete!).with().times(1)
        
        rule_spy = Spy.on(rule, :satisfy_conjunction).and_call_through
        called   = false
        
        # -- Pre-execution Checks --
        assert_Goal_variables     goal,       {}, [].join("\n")
        assert_Goal_variables     subgoal,    { x: nil, y: 7 }, [
          'Goal2.:x',
          'Goal2.:y',
          '  Goal2.7',
        ].join("\n")
        assert_Goal_variables     subsubgoal, { y: 3, z: nil }, [
          'Goal3.:y',
          '  Goal3.3',
          'Goal3.:z',
        ].join("\n")
        
        # -- Execute Code --
        result = rule.satisfy_conjunction(goal, subgoal, rule.definition) do |solution_goal|
          #:nocov:
          called = true
          #:nocov:
        end
        
        # -- Peform Checks --
        refute          result,                           'satisfy_conjunction should not succeed'
        refute          called,                           'the satisfy block should not be called'
        assert_equal    1,                                subsubgoal_spy.calls.size
        assert_equal    1,                                rule_spy.calls.size
        assert_equal    [goal, subgoal, [gamma(:j,:k)]],  rule_spy.calls[0].args
        
        assert_Goal_variables     goal,       {}, [].join("\n")
        
        assert_Goal_variables     subgoal,    { x: nil, y: 7 }, [
          'Goal2.:x',
          'Goal2.:y',
          '  Goal2.7',
        ].join("\n")
        
        assert_Goal_variables     subsubgoal, { x: nil, y: 3, z: nil }, [
          'Goal3.:y',
          '  Goal3.3',
          'Goal3.:z',
          'Goal3.:x',
        ].join("\n")
      end
      
    end
    
  end

end
