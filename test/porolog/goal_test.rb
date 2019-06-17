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
    
    describe '.reset' do
      
      it 'should clear all goals' do
        new_goal :predicate1, :a
        new_goal :predicate2, :a, :b
        new_goal :predicate3, :a, :b, :c
        
        assert_equal  3,  Goal.goals.size
        
        Goal.reset
        
        assert_empty      Goal.goals
      end
      
      it 'should call check_deleted for each goal' do
        Goal.any_instance.expects(:check_deleted).with().returns(false).times(5)
        
        new_goal :p, :x, :y
        new_goal :q, :a
        new_goal :r, :a, :b, :c
        
        Goal.reset
        
        new_goal :j, 1
        new_goal :k, ['a', 'b', 'c']
        
        Goal.reset
      end
      
      it 'should clear the goal cache' do
        # TECH-CREDIT: Probably not going to use a cache; we'll see ...
      end
      
    end
    
    describe '.goals' do
      
      it 'should return all registered goals' do
        assert_equal  0,  Goal.goals.size
        
        goal1 = new_goal :predicate1, :a
        
        assert_equal  1,                      Goal.goals.size
        assert_equal  [goal1],                Goal.goals
        
        goal2 = new_goal :predicate2, :a, :b
        
        assert_equal  2,                      Goal.goals.size
        assert_equal  [goal1,goal2],          Goal.goals
        
        goal3 = new_goal :predicate3, :a, :b, :c
        
        assert_equal  3,                      Goal.goals.size
        assert_equal  [goal1,goal2,goal3],    Goal.goals
      end
      
    end
    
    describe '.new' do
      
      it 'should create a new Goal' do
        goal = Goal.new nil
        
        assert_instance_of  Goal,   goal
      end
      
    end
    
    describe '#initialize' do
      
      it 'should initialize calling_goal' do
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal1 = Goal.new args
        goal2 = Goal.new args, goal1
        
        assert_nil              goal1.calling_goal
        assert_equal  goal1,    goal2.calling_goal
        
        assert_Goal   goal1,    :p, [:x,:y]
        assert_Goal   goal2,    :p, [:x,:y]
      end
      
      it 'should initialize arguments' do
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal = Goal.new args, nil
        
        assert_equal  args,     goal.arguments
      end
      
      it 'should initialize terminate' do
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal = Goal.new args, nil
        
        assert_equal  false,    goal.terminate
      end
      
      it 'should initialize variables' do
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal = Goal.new args, nil
        
        assert_Goal_variables   goal, {}, ''
      end
      
      it 'should register the goal as undeleted' do
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal1 = Goal.new args, nil
        goal2 = Goal.new args, goal1
        
        assert_equal  [goal1,goal2],    Goal.goals
      end
      
    end
    
    describe '#myid' do
      
      let(:pred) { Predicate.new :p }
      let(:args) { pred.(:x,:y) }
      
      it 'should return the pretty id of the goal' do
        goal1 = Goal.new args, nil
        goal2 = Goal.new args, goal1
        
        assert_equal  'Goal1',          goal1.myid
        assert_equal  'Goal2',          goal2.myid
      end
      
    end
    
    describe '#deleted?' do
      
      it 'should return the deleted state of a goal' do
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal = Goal.new args
        
        refute    goal.deleted?, 'goal should not be deleted'
        
        Goal.reset
        
        assert    goal.deleted?, 'goal should be deleted'
      end
      
      it 'should memoize the deleted state of a goal' do
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal = Goal.new args
        
        check_deleted_spy = Spy.on(goal, :check_deleted).and_call_through
        
        refute    goal.deleted?
        refute    goal.deleted?
        refute    goal.deleted?
        refute    goal.deleted?
        
        Goal.reset
        
        assert    goal.deleted?
        assert    goal.deleted?
        assert    goal.deleted?
        assert    goal.deleted?
        
        assert_equal    5,    check_deleted_spy.calls.size
      end
      
    end
    
    describe '#check_deleted' do
      
      it 'should return false when the goal is not deleted and keep variables intact' do
        skip 'until Variable added'
        
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal = Goal.new args
        goal.variable(:x)
        goal.variable(:y)
        goal.variable(:z)
        
        variable_remove_spy = Spy.on_instance_method(Variable, :remove)
        
        refute  goal.check_deleted
        
        assert_equal    0,    variable_remove_spy.calls.size
      end
      
      it 'should return true when the goal is deleted and remove all variables' do
        skip 'until Variable added'
        
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal = Goal.new args
        goal.variable(:x)
        goal.variable(:y)
        goal.variable(:z)
        
        variable_remove_spy = Spy.on_instance_method(Variable, :remove)
        
        Goal.reset
        
        assert  goal.check_deleted
        
        assert_equal    3,    variable_remove_spy.calls.size
      end
      
    end
    
    describe '#variables' do
      
      it 'should return a Hash of variables and their values' do
        skip 'until Variable added'
        
        pred = Predicate.new :p
        args = pred.(:x,:y)
        
        goal = Goal.new args
        goal.variable(:x)
        goal.variable(:y)
        goal.variable(:z)
        
        variables = goal.variables
        
        assert_instance_of      Hash, variables
        
        assert_Goal             goal, :p, [:x,:y]
        assert_Goal_variables   goal, { x: nil, y: nil, z: nil }, ''
      end
      
    end
    
    describe '#variable' do
      
      let(:pred) { Predicate.new :p }
      let(:args) { pred.(:x,:y) }
      let(:goal) { Goal.new args }
      
      it 'should return a non-variable as is' do
        skip 'until Variable added'
        
        assert_equal    4.132,    goal.variable(4.132)
      end
      
      it 'should create and find a variable from a Symbol or Variable' do
        skip 'until Variable added'
        
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
    
    describe '#value_of' do
      
      let(:pred) { Predicate.new :p }
      let(:args) { pred.(:x,:y) }
      let(:goal) { Goal.new args }
      
      describe 'when name is a Symbol' do
        let(:variable_name) { :cymbal }
        
        it 'should create the Variable' do
          skip 'until Variable added'
          
          refute        goal.variables.key?(variable_name), "#{variable_name} should not exist"
          
          assert_nil    goal.value_of(variable_name)
          
          assert        goal.variables.key?(variable_name), "#{variable_name} should exist"
          
          variable       = goal.variable(variable_name)
          variable.value = 44.5
          
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
    
    describe '#solve' do
      
      it 'should find no solutions for a goal with no rules' do
        skip 'until CoreExt added'
        
        goal1 = new_goal :p, :x, :y
        
        solutions = goal1.solve
        
        assert_equal  [], solutions
      end
      
      it 'should solve a fact' do
        skip 'until CoreExt added'
        
        predicate :fact
        
        fact(42).fact!
        
        solutions = fact(42).solve
        
        assert_equal  [{}],  solutions
      end
      
      it 'should not solve a falicy' do
        skip 'until CoreExt added'
        
        predicate :fact
        
        fact(42).falicy!
        
        solutions = fact(42).solve
        
        assert_equal  [],  solutions
      end
      
      it 'should solve using head and tail with lists' do
        skip 'until HeadTail added'
        
        predicate :head_tail
        
        head_tail([1,2,3,4,5,6,7]).fact!
        head_tail(['head','body','foot']).fact!
        
        solutions = head_tail(:head/:tail).solve
        
        assert_equal    [
          { head: 1,      tail: [2,3,4,5,6,7] },
          { head: 'head', tail: ['body','foot'] },
        ], solutions
      end
      
      it 'should solve a goal recursively' do
        skip 'until HeadTail added'
        
        predicate :recursive
        
        recursive([]) << [:CUT, true]
        recursive(:head/:tail) << [
          write('(',:head,')'),
          alpha(:tail)
        ]
        
        assert_output '(1)(2)(3)(four)(5)(6)(7)' do
          solutions = alpha([1,2,3,'four',5,6,7]).solve
          
          assert_equal    [{}], solutions
        end
        
      end
      
    end
    
  end
  
end
