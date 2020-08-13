#
#   test/porolog/goal_test.rb     - Test Suite for Porolog::Goal
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'


describe 'Porolog' do
  
  before(:all) do
    reset
  end

  describe 'Goal' do
    
    let(:pred) { Porolog::Predicate.new :p }
    let(:args) { pred.(:x,:y) }
    let(:goal) { Porolog::Goal.new args }
    
    describe '.reset' do
      
      it 'should clear all goals' do
        new_goal :predicate1, :a
        new_goal :predicate2, :a, :b
        new_goal :predicate3, :a, :b, :c
        
        assert_equal  3,  Porolog::Goal.goals.size
        
        Porolog::Goal.reset
        
        assert_empty      Porolog::Goal.goals
      end
      
      it 'should call check_deleted for each goal' do
        Porolog::Goal.any_instance.expects(:check_deleted).with().returns(false).times(5)
        
        new_goal :p, :x, :y
        new_goal :q, :a
        new_goal :r, :a, :b, :c
        
        Porolog::Goal.reset
        
        new_goal :j, 1
        new_goal :k, ['a', 'b', 'c']
        
        Porolog::Goal.reset
      end
      
    end
    
    describe '.goals' do
      
      it 'should return all registered goals' do
        assert_equal  0,  Porolog::Goal.goals.size
        
        goal1 = new_goal :predicate1, :a
        
        assert_equal  [goal1],                Porolog::Goal.goals
        
        goal2 = new_goal :predicate2, :a, :b
        
        assert_equal  [goal1,goal2],          Porolog::Goal.goals
        
        goal3 = new_goal :predicate3, :a, :b, :c
        
        assert_equal  [goal1,goal2,goal3],    Porolog::Goal.goals
      end
      
    end
    
    describe '.new' do
      
      it 'should create a new Goal' do
        goal = Porolog::Goal.new nil
        
        assert_instance_of  Porolog::Goal,   goal
      end
      
    end
    
    describe '#initialize' do
      
      it 'should initialize calling_goal' do
        goal1 = Porolog::Goal.new args
        goal2 = Porolog::Goal.new args, goal1
        
        assert_nil              goal1.calling_goal
        assert_equal  goal1,    goal2.calling_goal
        
        assert_Goal   goal1,    :p, [:x,:y]
        assert_Goal   goal2,    :p, [:x,:y]
      end
      
      it 'should initialize arguments' do
        goal = Porolog::Goal.new args, nil
        
        assert_equal  goal.variablise(args),      goal.arguments
      end
      
      it 'should initialize terminate' do
        goal = Porolog::Goal.new args, nil
        
        assert_equal  false,                      goal.terminated?
      end
      
      it 'should initialize variables' do
        goal = Porolog::Goal.new args, nil
        
        assert_Goal_variables   goal, { x: nil, y: nil }, [
          'Goal1.:x',
          'Goal1.:y',
        ].join("\n")
      end
      
      it 'should register the goal as undeleted' do
        goal1 = Porolog::Goal.new args, nil
        goal2 = Porolog::Goal.new args, goal1
        
        assert_equal  [goal1,goal2],              Porolog::Goal.goals
      end
      
    end
    
    describe '#myid' do
      
      it 'should return the pretty id of the goal' do
        goal1 = Porolog::Goal.new args, nil
        goal2 = Porolog::Goal.new args, goal1
        
        assert_equal  'Goal1',          goal1.myid
        assert_equal  'Goal2',          goal2.myid
      end
      
    end

    describe '#ancestors' do
      
      it 'should return an Array of the parent goals' do
        goal1 = Porolog::Goal.new args
        goal2 = Porolog::Goal.new args, goal1
        goal3 = Porolog::Goal.new args, goal2
        goal4 = Porolog::Goal.new args, goal3
        
        assert_equal  [goal1],                          goal1.ancestors
        assert_equal  [goal1, goal2],                   goal2.ancestors
        assert_equal  [goal1, goal2, goal3],            goal3.ancestors
        assert_equal  [goal1, goal2, goal3, goal4],     goal4.ancestors
      end
      
    end
    
    describe '#ancestry' do
      
      it 'should return an Array of the parent goals' do
        goal1 = Porolog::Goal.new args
        goal2 = Porolog::Goal.new args, goal1
        goal3 = Porolog::Goal.new args, goal2
        goal4 = Porolog::Goal.new args, goal3
        
        ancestors = [
          'Goal1 -- Solve p(:x,:y)  {:x=>nil, :y=>nil}',
          '  Goal2 -- Solve p(:x,:y)  {:x=>nil, :y=>nil}',
          '    Goal3 -- Solve p(:x,:y)  {:x=>nil, :y=>nil}',
          '      Goal4 -- Solve p(:x,:y)  {:x=>nil, :y=>nil}',
        ]
        
        assert_equal  ancestors[0...1].join("\n"),      goal1.ancestry
        assert_equal  ancestors[0...2].join("\n"),      goal2.ancestry
        assert_equal  ancestors[0...3].join("\n"),      goal3.ancestry
        assert_equal  ancestors[0...4].join("\n"),      goal4.ancestry
      end
      
    end
    
    describe '#inspect' do
      
      it 'should show a description of the goal' do
        goal1 = Porolog::Goal.new args
        goal2 = Porolog::Goal.new pred.(1,:b,'word'), goal1
        goal3 = Porolog::Goal.new args, goal2
        goal4 = Porolog::Goal.new args, goal3
        
        assert_equal  'Goal1 -- Solve p(:x,:y)',        goal1.inspect
        assert_equal  'Goal2 -- Solve p(1,:b,"word")',  goal2.inspect
        assert_equal  'Goal3 -- Solve p(:x,:y)',        goal3.inspect
        assert_equal  'Goal4 -- Solve p(:x,:y)',        goal4.inspect
      end
      
    end
    
    describe '#delete!' do
      
      it 'should delete the goal' do
        goal1 = Porolog::Goal.new args
        goal2 = Porolog::Goal.new pred.(1,:b,'word'), goal1
        goal3 = Porolog::Goal.new args, goal2
        goal4 = Porolog::Goal.new args, goal3
        
        assert                                          goal2.delete!, 'goal should delete'
        assert_equal  [goal1, goal3, goal4],            Porolog::Goal.goals
      end
      
    end
    
    describe '#myid' do
      
      let(:pred) { Porolog::Predicate.new :p }
      let(:args) { pred.(:x,:y) }
      
      it 'should return the pretty id of the goal' do
        goal1 = Porolog::Goal.new args, nil
        goal2 = Porolog::Goal.new args, goal1
        
        assert_equal  'Goal1',          goal1.myid
        assert_equal  'Goal2',          goal2.myid
      end
      
    end
    
    describe '#deleted?' do
      
      it 'should return the deleted state of a goal' do
        goal = Porolog::Goal.new args
        
        refute    goal.deleted?, 'goal should not be deleted'
        
        Porolog::Goal.reset
        
        assert    goal.deleted?, 'goal should be deleted'
      end
      
      it 'should memoize the deleted state of a goal' do
        goal = Porolog::Goal.new args
        
        check_deleted_spy = Spy.on(goal, :check_deleted).and_call_through
        
        refute    goal.deleted?
        refute    goal.deleted?
        refute    goal.deleted?
        refute    goal.deleted?
        
        Porolog::Goal.reset
        
        assert    goal.deleted?
        assert    goal.deleted?
        assert    goal.deleted?
        assert    goal.deleted?
        
        assert_equal    5,    check_deleted_spy.calls.size
      end
      
    end
    
    describe '#check_deleted' do
      
      it 'should return false when the goal is not deleted and keep variables intact' do
        goal = Porolog::Goal.new args
        goal.variable(:x)
        goal.variable(:y)
        goal.variable(:z)
        
        variable_remove_spy = Spy.on_instance_method(Porolog::Variable, :remove)
        
        refute  goal.check_deleted, 'goal should not be deleted'
        
        assert_equal    0,    variable_remove_spy.calls.size
      end
      
      it 'should return true when the goal is deleted and remove all variables' do
        goal = Porolog::Goal.new args
        goal.variable(:x)
        goal.variable(:y)
        goal.variable(:z)
        
        variable_remove_spy = Spy.on_instance_method(Porolog::Variable, :remove)
        
        Porolog::Goal.reset
        
        assert  goal.check_deleted, 'goal should be deleted'
        
        assert_equal    3,    variable_remove_spy.calls.size
      end
      
    end
    
    describe '#terminate!' do
      
      it 'should set the goal to terminate and log the event' do
        goal = Porolog::Goal.new args
        
        assert          goal.terminate!,      'the goal should be set to terminate'
        assert_equal    ['terminating'],      goal.log
      end
      
    end
    
    describe '#terminated?' do
      
      it 'should return whether the goal is set to terminate or not' do
        goal = Porolog::Goal.new args
        
        refute          goal.terminated?,     'the goal should not be initialized to terminate'
        assert          goal.terminate!,      'the goal should be set to terminate'
        assert          goal.terminated?,     'the goal should be set to terminate'
      end
      
    end
    
    describe '#variablise' do
      
      it 'should convert a Symbol into a Variable' do
        assert_Variable   goal.variablise(:k),  :k, goal, [], []
      end
      
      it 'should return a Variable as is' do
        v = Porolog::Variable.new :r, goal
        assert_equal      v,                goal.variablise(v)
      end
      
      it 'should convert an Array into a Variables and Objects' do
        assert_equal      [goal.value(1),goal.variable(:a),goal.value('word')],   goal.variablise([1,:a,'word'])
      end
      
      it 'should return a duplicate of an Arguments' do
        duplicate = goal.variablise(args)
        assert_Arguments  duplicate,  :p, goal.variablise([:x, :y])
        refute_equal      args,       duplicate
      end
      
      it 'should convert a Tail into a Tail with a variablised value' do
        assert_Tail       goal.variablise(Porolog::Tail.new :m),  '*Goal1.:m'
      end
      
      it 'should return a Value as is' do
        v = Porolog::Value.new(45, goal)
        assert_equal      v,                goal.variablise(v)
      end
      
      it 'should return an unknown array as is' do
        assert_equal      Porolog::UNKNOWN_ARRAY,    goal.variablise(Porolog::UNKNOWN_ARRAY)
      end
      
      it 'should return an unknown tail as is' do
        assert_equal      Porolog::UNKNOWN_TAIL,     goal.variablise(Porolog::UNKNOWN_TAIL)
      end
      
      it 'should convert any other Object into a Value' do
        assert_Value      goal.variablise(23.61),  23.61, goal
      end
      
    end
    
    describe '#variables' do
      
      it 'should return a Hash of variables and their values' do
        goal = Porolog::Goal.new args
        goal.variable(:x)
        goal.variable(:y)
        goal.variable(:z)
        
        variables = goal.variables
        
        assert_instance_of      Hash, variables
        
        assert_Goal             goal, :p, [:x,:y]
        assert_Goal_variables   goal, { x: nil, y: nil, z: nil }, [
          'Goal1.:x',
          'Goal1.:y',
          'Goal1.:z',
        ].join("\n")
      end
      
    end
    
    describe '#inspect_variables' do
      
      it 'should return a string showing the instantiations of the variables of the goal' do
        # -- Initial Goal --
        goal = Porolog::Goal.new args
        
        x = goal.variable(:x)
        y = goal.variable(:y)
        z = goal.variable(:z)
        
        expected = [
          'Goal1.:x',
          'Goal1.:y',
          'Goal1.:z',
        ].join("\n")
        
        assert_equal    expected,     goal.inspect_variables
        
        # -- After First Instantiation --
        #   x.head = y
        x.instantiate y, nil, :head
        
        expected = [
          'Goal1.:x',
          '  [:head]Goal1.:y',
          'Goal1.:y',
          '  Goal1.:x[:head]',
          'Goal1.:z',
        ].join("\n")
        
        assert_equal    expected,     goal.inspect_variables
        
        # -- After Second Instantiation --
        #   x.head = y
        #   x.tail = z
        x.instantiate z, nil, :tail
        
        expected = [
          'Goal1.:x',
          '  [:head]Goal1.:y',
          '  [:tail]Goal1.:z',
          'Goal1.:y',
          '  Goal1.:x[:head]',
          '    [:tail]Goal1.:z',
          'Goal1.:z',
          '  Goal1.:x[:tail]',
          '    [:head]Goal1.:y',
        ].join("\n")
        
        assert_equal    expected,     goal.inspect_variables
        
        # -- After Third Instantiation --
        #   x = [*y, *z]
        #   y = 1,2,3
        y.instantiate goal.value([1,2,3])
        
        expected = [
          'Goal1.:x',
          '  [:head]Goal1.:y',
          '    Goal1.[1, 2, 3]',
          '  [:tail]Goal1.:z',
          'Goal1.:y',
          '  Goal1.:x[:head]',
          '    [:tail]Goal1.:z',
          '  Goal1.[1, 2, 3]',
          'Goal1.:z',
          '  Goal1.:x[:tail]',
          '    [:head]Goal1.:y',
          '      Goal1.[1, 2, 3]',
        ].join("\n")
        
        assert_equal    expected,     goal.inspect_variables
        
        # -- After Fourth Instantiation --
        #   x = [*y, *z]
        #   y = 1,2,3
        #   z = 4,5,6
        z.instantiate goal.value([4,5,6])
        
        expected = [
          'Goal1.:x',
          '  [:head]Goal1.:y',
          '    Goal1.[1, 2, 3]',
          '  [:tail]Goal1.:z',
          '    Goal1.[4, 5, 6]',
          'Goal1.:y',
          '  Goal1.:x[:head]',
          '    [:tail]Goal1.:z',
          '      Goal1.[4, 5, 6]',
          '  Goal1.[1, 2, 3]',
          'Goal1.:z',
          '  Goal1.:x[:tail]',
          '    [:head]Goal1.:y',
          '      Goal1.[1, 2, 3]',
          '  Goal1.[4, 5, 6]',
        ].join("\n")
        
        assert_equal    expected,     goal.inspect_variables
      end
      
    end
    
    describe '#values' do
      
      it 'should return the values that have been associated with the goal' do
        goal = Porolog::Goal.new args
        
        x = goal.variable(:x)
        y = goal.variable(:y)
        z = goal.variable(:z)
        
        x.instantiate y, nil, :head
        x.instantiate z, nil, :tail
        y.instantiate goal.value([1,2,3])
        z.instantiate goal.value([4,5,6])
        
        expected = [
          [1,2,3],
          [4,5,6],
        ]
        
        assert_equal    expected,     goal.values
      end
      
    end
    
    describe '#variable' do
      
      it 'should return a non-variable as is' do
        assert_equal    4.132,    goal.variable(4.132)
      end
      
      it 'should create and find a variable from a Symbol or Variable' do
        refute    goal.variables.key?(:v), ':v should not be a variable'
        
        variable1 = goal.variable :v
        
        assert    goal.variables.key?(:v), ':v should be a variable'
        
        variable2 = goal.variable :v
        
        assert    goal.variables.key?(:v), ':v should be a variable'
        
        variable3 = goal.variable variable2
        
        assert_equal    variable1, variable2
        assert_equal    variable2, variable3
      end
      
    end
    
    describe '#value' do
      
      it 'should create and find a value from an Object' do
        refute    goal.values.include?(99.02), '99.02 should not be a value'
        
        value1 = goal.value 99.02
        
        assert    goal.values.include?(99.02), '99.02 should be a value'
        
        value2 = goal.value 99.02
        
        assert_Value    value1,       99.02, goal
        assert_Value    value2,       99.02, goal
        
        assert_equal    [99.02],      goal.values
      end
      
    end
    
    describe '#value_of' do
      
      describe 'when name is a Symbol' do
        
        let(:variable_name) { :cymbal }
        
        it 'should create the Variable' do
          refute        goal.variables.key?(variable_name), "#{variable_name} should not exist"
          
          refute_nil    goal.value_of(variable_name)
          
          assert        goal.variables.key?(variable_name), "#{variable_name} should exist"
          
          variable       = goal.variable(variable_name)
          variable.instantiate 44.5
          
          assert_equal      44.5,   goal.value_of(variable_name)
        end
        
      end
      
      describe 'when name is not a Symbol' do
        
        let(:variable_name) { 99.28 }
        
        it 'should return the name as the value' do
          assert_equal    99.28,    goal.value_of(variable_name)
        end
        
      end
      
    end
    
    describe '#values_of' do
      
      it 'should return an Array with values_of applied to each element when given an Array' do
        goal.instantiate :thomas, '$10'
        
        expected = [[1,'two'], '$10', 999, 'giraffe', 0.5]
        
        assert_equal    expected,     goal.values_of([[1,'two'], :thomas, 999, 'giraffe', 0.5])
      end
      
      it 'should return the value_of the Variable when given a Variable' do
        goal.instantiate :jones, 'Fuzzy'
        
        variable1 = goal.variable(:jones)
        
        assert_equal    'Fuzzy',      goal.values_of(variable1)
      end
      
      it 'should return the value_of the Symbol when given a Symbol' do
        goal.instantiate :x, 'Staunch'
        
        assert_equal    'Staunch',    goal.values_of(:x)
      end
      
      it 'should return the value_of the Value when given a Value' do
        value1 = goal.value(123.76)
        
        assert_equal    123.76,       goal.values_of(value1)
      end
      
      it 'should somehow splat when given a Tail' do
        tail1 = Porolog::Tail.new ['apples','oranges','bananas']
        
        assert_equal    'apples',     goal.values_of(tail1)
      end
      
      it 'should return the Object as is when given an Object' do
        object = Object.new
        
        goal.expects(:value_of).times(0)
        
        assert_equal    object,     goal.values_of(object)
      end
      
    end
    
    describe '#solve' do
      
      it 'should find no solutions for a goal with no rules' do
        goal1 = new_goal :p, :x, :y
        
        solutions = goal1.solve
        
        assert_equal  [], solutions
      end
      
      it 'should solve a fact' do
        Porolog::predicate :fact
        
        fact(42).fact!
        
        solutions = fact(42).solve
        
        assert_equal  [{}],  solutions
      end
      
      it 'should not solve a fallacy' do
        Porolog::predicate :fact
        
        fact(42).fallacy!
        
        solutions = fact(42).solve
        
        assert_equal  [],  solutions
      end
      
      it 'should solve using head and tail with lists' do
        Porolog::predicate :head_tail
        
        head_tail([1,2,3,4,5,6,7]).fact!
        head_tail(['head','body','foot']).fact!
        
        solutions = head_tail(:head/:tail).solve
        
        assert_equal    [
          { head: 1,      tail: [2,3,4,5,6,7] },
          { head: 'head', tail: ['body','foot'] },
        ], solutions
      end
      
      it 'should solve a goal recursively' do
        Porolog::builtin :write
        Porolog::predicate :recursive
        
        recursive([]) << [:CUT, true]
        recursive(:head/:tail) << [
          write('(',:head,')'),
          recursive(:tail)
        ]
        
        assert_output '(1)(2)(3)(four)(5)(6)(7)' do
          solutions = recursive([1,2,3,'four',5,6,7]).solve
          
          assert_equal    [{}], solutions
        end
      end
      
    end
    
    describe '#satisfy' do
      
      let(:block) { ->(subgoal){} }
      
      it 'should return false when the goal has no arguments' do
        goal = Porolog::Goal.new nil
        
        block.expects(:call).times(0)
        
        refute          goal.satisfy(&block),   name
      end
      
      it 'should access the predicate of its arguments' do
        goal.arguments.expects(:predicate).with().returns(nil).times(1)
        block.expects(:call).times(0)
        
        refute          goal.satisfy(&block),   name
      end
      
      it 'should try to satisfy the predicate with itself' do
        pred.expects(:satisfy).with(goal).returns(nil).times(1)
        block.expects(:call).times(0)
        
        refute          goal.satisfy(&block),   name
      end
      
      it 'should call the block when the predicate is satisfied' do
        pred.(1,2).fact!
        pred.(3,4).fact!
        pred.(5,6).fact!
        
        block.expects(:call).returns(true).times(3)
        
        assert          goal.satisfy(&block),   name
      end
      
    end
    
    describe '#instantiate' do
      
      it 'creates an Array with a Tail using the slash notation with Symbols with a goal' do
        goal      = new_goal  :bravo, :x, :y, :z
        
        head_tail = goal.variablise(:head / :tail)
        
        assert_Array_with_Tail    head_tail,      [goal.variable(:head)], '*Goal1.:tail'
        
        assert_Goal_variables     goal, { x: nil, y: nil, z: nil, head: nil, tail: nil }, [
          'Goal1.:x',
          'Goal1.:y',
          'Goal1.:z',
          'Goal1.:head',
          'Goal1.:tail',
        ].join("\n")
      end
      
      it 'creates an Array with a Tail using the slash notation with a single head with a goal' do
        goal      = new_goal  :bravo, :x, :y, :z
        
        head_tail = goal.variablise([:head] / :tail)
        
        assert_Array_with_Tail    head_tail,      [goal.variable(:head)], '*Goal1.:tail'
        
        assert_Goal_variables     goal, { x: nil, y: nil, z: nil, head: nil, tail: nil }, [
          'Goal1.:x',
          'Goal1.:y',
          'Goal1.:z',
          'Goal1.:head',
          'Goal1.:tail',
        ].join("\n")
      end
      
      it 'creates variables from its contents with a goal' do
        Porolog::predicate :bravo
        arguments = Porolog::Predicate[:bravo].arguments(:x,:y,:z)
        goal      = arguments.goal
        
        head_tail = [:alpha,bravo(:a,:b,:c),[:carly]] / [:x,[:y],bravo(:p,:q/:r)]
        
        assert_equal  [:alpha,bravo(:a,:b,:c),[:carly], :x,[:y],bravo(:p,:q/:r)].inspect,    head_tail.inspect
        
        assert_Goal_variables   goal, { x: nil, y: nil, z: nil }, [
          'Goal1.:x',
          'Goal1.:y',
          'Goal1.:z',
        ].join("\n")
        
        head_tail = goal.variablise(head_tail)
        
        assert_equal  '[Goal1.:alpha, bravo(Goal1.:a,Goal1.:b,Goal1.:c), [Goal1.:carly], Goal1.:x, [Goal1.:y], bravo(Goal1.:p,[Goal1.:q, *Goal1.:r])]',    head_tail.inspect
        
        assert_Goal_variables   goal, { x: nil, y: nil, z: nil, alpha: nil, a: nil, b: nil, c: nil, carly: nil, p: nil, q: nil, r: nil }, [
          'Goal1.:x',
          'Goal1.:y',
          'Goal1.:z',
          'Goal1.:alpha',
          'Goal1.:a',
          'Goal1.:b',
          'Goal1.:c',
          'Goal1.:carly',
          'Goal1.:p',
          'Goal1.:q',
          'Goal1.:r',
        ].join("\n")
      end
      
      it 'should combine Array value of head and Array value of tail when it has a goal' do
        head_tail = [:first] / :last
        
        goal.instantiate :first, 'alpha',   goal
        goal.instantiate :last,  ['omega'], goal
        
        head_tail = goal.values_of(goal.variablise(head_tail))
        
        assert_equal    ['alpha','omega'],        head_tail
      end
      
    end
    
    describe '#inherit_variables' do
      
      it 'should return true for an initial goal' do
        goal    = new_goal :goal,    :x, :y, :z
        
        assert                  goal.inherit_variables
        assert_Goal_variables   goal, { x: nil, y: nil, z: nil }, [
          'Goal1.:x',
          'Goal1.:y',
          'Goal1.:z',
        ].join("\n")
      end
      
      it 'should instantiate combined variables of both goals' do
        goal    = new_goal :goal,    :x, :y, :z
        subgoal = new_goal :subgoal, :a, :b, :c
        
        assert  subgoal.inherit_variables(goal)
        assert_Goal_variables   goal, { x: nil, y: nil, z: nil, a: nil, b: nil, c: nil }, [
          'Goal1.:x',
          '  Goal2.:x',
          'Goal1.:y',
          '  Goal2.:y',
          'Goal1.:z',
          '  Goal2.:z',
          'Goal1.:a',
          '  Goal2.:a',
          'Goal1.:b',
          '  Goal2.:b',
          'Goal1.:c',
          '  Goal2.:c',
        ].join("\n")
        assert_Goal_variables   subgoal, { a: nil, b: nil, c: nil, x: nil, y: nil, z: nil }, [
          'Goal2.:a',
          '  Goal1.:a',
          'Goal2.:b',
          '  Goal1.:b',
          'Goal2.:c',
          '  Goal1.:c',
          'Goal2.:x',
          '  Goal1.:x',
          'Goal2.:y',
          '  Goal1.:y',
          'Goal2.:z',
          '  Goal1.:z',
        ].join("\n")
      end
      
      it 'should not make any instantiations when variables cannot be unified' do
        goal    = new_goal :goal,    :x, :y, :z
        subgoal = new_goal :subgoal, :a, :b, :c
        
        goal[:x].instantiate 1
        subgoal[:x].instantiate 2
        
        refute  subgoal.inherit_variables(goal)
        assert_equal  [
          'Cannot unify because 1 != 2 (variable != variable)',
        ], goal.log
        assert_equal  [
          'Cannot unify because 1 != 2 (variable != variable)',
          "Couldn't unify: :x WITH Goal1 AND Goal2"
        ], subgoal.log
        assert_Goal_variables   goal, { x: 1, y: nil, z: nil }, [
          'Goal1.:x',
          '  Goal1.1',
          'Goal1.:y',
          'Goal1.:z',
        ].join("\n")
        assert_Goal_variables   subgoal, { a: nil, b: nil, c: nil, x: 2 }, [
          'Goal2.:a',
          'Goal2.:b',
          'Goal2.:c',
          'Goal2.:x',
          '  Goal2.2',
        ].join("\n")
      end
      
    end
    
  end
  
end
