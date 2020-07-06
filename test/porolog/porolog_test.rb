#
#   test/porolog/porolog_test.rb     - Test Suite for Porolog module
#
#     Luis Esteban      4 May 2018
#       created
#

require_relative '../test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end
  
  describe 'UNKNOWN_TAIL#inspect' do
    
    it 'should return distinctive notation' do
      assert_equal      '...',            UNKNOWN_TAIL.inspect
    end
    
  end
  
  describe '#predicate' do
    
    it 'should create a Predicate' do
      # -- Precondition Baseline --
      assert_equal      0,                Scope[:default].predicates.size
      
      # -- Test --
      single_predicate = predicate :single
      
      # -- Compare Result Against Baseline --
      assert_equal      1,                Scope[:default].predicates.size
      assert_equal      :single,          Scope[:default].predicates.first.name
      assert_Predicate  single_predicate, :single, []
    end
    
    it 'should define a method to create Arguments for solving' do
      refute                    respond_to?(:delta)
      
      predicate :delta
      
      assert                    respond_to?(:delta)
      assert_Arguments          delta(1, :X, ['left','right']),   :delta, [1, :X, ['left','right']]
    end
    
    it 'should create multiple Predicates' do
      assert_equal              0,        Scope[:default].predicates.size
      
      multiple_predicates = predicate :alpha, :beta, :gamma
      
      assert_equal              3,        Scope[:default].predicates.size
      assert_equal              :alpha,   Scope[:default].predicates[0].name
      assert_equal              :beta,    Scope[:default].predicates[1].name
      assert_equal              :gamma,   Scope[:default].predicates[2].name
      assert_instance_of        Array,    multiple_predicates
      assert_equal              3,        multiple_predicates.size
      assert_Predicate          multiple_predicates[0], :alpha, []
      assert_Predicate          multiple_predicates[1], :beta,  []
      assert_Predicate          multiple_predicates[2], :gamma, []
    end
    
    it 'should define multiple methods to create Arguments for solving' do
      refute                    respond_to?(:epsilon)
      refute                    respond_to?(:upsilon)
      
      predicate :epsilon, :upsilon
      
      assert                    respond_to?(:epsilon)
      assert                    respond_to?(:upsilon)
      assert_Arguments          epsilon(),   :epsilon, []
      assert_Arguments          upsilon([]), :upsilon, [[]]
    end
    
  end
  
  describe '#unify_goals' do
    
    it 'should unify goals for the same predicate' do
      # -- Setup --
      goal1 = new_goal :p, :m, :n
      goal2 = new_goal :p, :s, :t
      
      # -- Precondition Baseline --
      assert_Goal_variables   goal1,    { m: nil, n: nil }, [
        'Goal1.:m',
        'Goal1.:n',
      ].join("\n")
      
      assert_Goal_variables   goal2,    { s: nil, t: nil }, [
        'Goal2.:s',
        'Goal2.:t',
      ].join("\n")
      
      # -- Test --
      assert  unify_goals(goal1, goal2), name
      
      # -- Compare Result Against Baseline --
      assert_Goal_variables   goal1,    { m: nil, n: nil }, [
        'Goal1.:m',
        '  Goal2.:s',
        'Goal1.:n',
        '  Goal2.:t',
      ].join("\n")
      
      assert_Goal_variables   goal2,    { s: nil, t: nil }, [
        'Goal2.:s',
        '  Goal1.:m',
        'Goal2.:t',
        '  Goal1.:n',
      ].join("\n")
    end
    
    it 'should not unify goals for different predicates' do
      goal1 = new_goal :p, :x, :y
      goal2 = new_goal :q, :x, :y
      
      refute  unify_goals(goal1, goal2), name
      
      assert_equal      ['Cannot unify goals because they are for different predicates: :p and :q'],    goal1.log
      assert_equal      ['Cannot unify goals because they are for different predicates: :p and :q'],    goal2.log
    end
    
  end
  
  describe '#instantiate_unifications' do
    
    let(:goal1) { new_goal :p, :x, :y }
    let(:goal2) { new_goal :q, :i, :j, :k }
    let(:goal3) { new_goal :r, :n }
    
    it 'should precheck inconsistent unifications' do
      unifications = [
        [:x, :k, goal1, goal2],
        [:x, :j, goal1, goal2],
        [:x, 12, goal1, goal3],
        [:x, 37, goal1, goal3],
      ]
      
      refute    instantiate_unifications(unifications), name
    end
    
    it 'should create instantiations' do
      # -- Setup --
      unifications = [
        [:x, :k, goal1, goal2],
        [:x, :j, goal1, goal2],
        [:x, 12, goal1, goal3],
      ]
      
      # -- Precondition Baseline --
      assert_Goal_variables     goal1, { x: nil, y: nil }, [
        'Goal1.:x',
        'Goal1.:y',
      ].join("\n")
      
      assert_Goal_variables     goal2, { i: nil, j: nil, k: nil }, [
        'Goal2.:i',
        'Goal2.:j',
        'Goal2.:k',
      ].join("\n")
      
      assert_Goal_variables     goal3, { n: nil }, [
        'Goal3.:n',
      ].join("\n")
      
      # -- Test --
      assert    instantiate_unifications(unifications), name
      
      # -- Compare Result Against Baseline --
      assert_Goal_variables     goal1, { x: 12, y: nil }, [
        'Goal1.:x',
        '  Goal2.:k',
        '  Goal2.:j',
        '  Goal3.12',
        'Goal1.:y',
      ].join("\n")
      
      assert_Goal_variables     goal2, { i: nil, j: 12, k: 12 }, [
        'Goal2.:i',
        'Goal2.:j',
        '  Goal1.:x',
        '    Goal2.:k',
        '    Goal3.12',
        'Goal2.:k',
        '  Goal1.:x',
        '    Goal2.:j',
        '    Goal3.12',
      ].join("\n")
      
      assert_Goal_variables     goal3, { n: nil }, [
        'Goal3.:n',
      ].join("\n")
    end
    
    it 'should return false for inconsistent unifications not picked up by the precheck' do
      #   12
      #  /
      # i
      #  \
      #   x
      #  /
      # j
      #  \
      #   y
      #  /
      # k
      #  \
      #   37
      unifications = [
        [:x, :i, goal1, goal2],
        [:i, 12, goal2, goal3],
        [:j, :x, goal2, goal1],
        [:j, :y, goal2, goal1],
        [:k, :y, goal2, goal1],
        [:k, 37, goal2, goal3],
      ]
      
      refute    instantiate_unifications(unifications), name
      
      assert_Goal_variables     goal1, { x: nil, y: nil }, [
        'Goal1.:x',
        'Goal1.:y',
      ].join("\n")
      
      assert_Goal_variables     goal2, { i: nil, j: nil, k: nil }, [
        'Goal2.:i',
        'Goal2.:j',
        'Goal2.:k',
      ].join("\n")
      
      assert_Goal_variables     goal3, { n: nil }, [
        'Goal3.:n',
      ].join("\n")
    end
    
  end
  
  describe '#unify' do
    
    let(:goal)  { new_goal :p, :x, :y }
    let(:goal2) { new_goal :q, :x, :y }
    
    describe 'when [:atomic,:atomic]' do
      
      it 'should unify equal atomic numbers' do
        assert    unify(42, 42, goal),                    name
      end
      
      it 'should not unify unequal atomic numbers' do
        refute    unify(42, 99, goal),                    name
        
        expected_log = [
          'Cannot unify because 42 != 99 (atomic != atomic)',
        ]
        
        assert_equal    expected_log,                     goal.log
      end
      
    end
    
    describe 'when [:array,:array]' do
      
      before do
        @spy = Spy.on(self, :unify_arrays).and_call_through
      end
      
      after do
        assert_equal  1,  @spy.calls.size
      end
      
      it 'should unify empty arrays' do
        assert    unify([], [], goal),                    name
      end
      
      it 'should unify equal arrays' do
        assert    unify([7,11,13], [7,11,13], goal),      name
      end
      
      it 'should not unify unequal arrays' do
        refute    unify([7,11,13], [7,11,14], goal),      name
        
        expected_log = [
          'Cannot unify incompatible values: 13 with 14',
          'Cannot unify because [7, 11, 13] != [7, 11, 14] (array != array)',
        ]
        
        assert_equal    expected_log,                     goal.log
      end
      
      it 'should not unify arrays of different lengths' do
        refute    unify([7,11,13], [7,11,13,13], goal),   name
        
        expected_log = [
          'Cannot unify arrays of different lengths: [7, 11, 13] with [7, 11, 13, 13]',
          'Cannot unify because [7, 11, 13] != [7, 11, 13, 13] (array != array)',
        ]
        
        assert_equal    expected_log,                     goal.log
      end
      
    end
    
    describe 'when [:variable,:atomic]' do
      
      before do
        expects(:unify_arrays).times(0)
      end
      
      it 'should return an instantiation' do
        assert_equal    [[:word, 'word', goal, goal]],    unify(:word, 'word', goal),      name
      end
      
      it 'should not unify an instantiated variable with a different value' do
        goal.instantiate :word, 'other'
        
        assert_nil                                        unify(:word, 'word', goal),      name
        
        expected_log = [
          'Cannot unify because Goal1."other" != "word" (variable != atomic)',
        ]
        
        assert_equal    expected_log,                     goal.log
      end
      
    end
    
    describe 'when [:atomic,:variable]' do
      
      before do
        expects(:unify_arrays).times(0)
      end
      
      it 'should return an instantiation' do
        assert_equal    [[:word, 'word', goal, goal]],    unify('word', :word, goal),      name
      end
      
      it 'should not unify instantiated variables with different values' do
        goal.instantiate :word, 'something'
        
        assert_nil                                        unify('word', :word, goal),      name
        
        expected_log = [
          'Cannot unify because "word" != Goal1."something" (atomic != variable)',
        ]
        
        assert_equal    expected_log,                     goal.log
      end
      
    end
    
    describe 'when [:variable, :variable]' do
      
      before do
        expects(:unify_arrays).times(0)
      end
      
      it 'should return an instantiation' do
        assert_equal    [[:x, :y, goal, goal2]],    unify(:x, :y, goal, goal2),      name
      end
      
      it 'should not unify instantiated variables with different values' do
        goal.instantiate :word, 'something'
        goal.instantiate :draw, 'picturing'
        
        assert_nil                                        unify(:draw, :word, goal),      name
        
        expected_log = [
          'Cannot unify because Goal1."picturing" != Goal1."something" (variable != variable)'
        ]
        
        assert_equal    expected_log,   goal.log
      end
      
    end
    
    describe 'when [:variable, :array]' do
      
      it 'should return an instantiation' do
        expects(:unify_arrays).times(0)
        
        assert_equal    [[:list, [7,11,13], goal, goal]],     unify(:list, [7,11,13], goal),      name
      end
      
      it 'should not unify instantiated variables with different values' do
        goal.instantiate :word, [1,2,3,4]
        expects(:unify_arrays).times(1)
        
        assert_nil                                            unify(:word, [1,2,3,5], goal),      name
        
        expected_log = [
          'Cannot unify because Goal1.[1, 2, 3, 4] != [1, 2, 3, 5] (variable/array != array)'
        ]
        
        assert_equal    expected_log,   goal.log
      end
      
      it 'should not unify instantiated variables with a non-array value' do
        goal.instantiate :word, 1234
        expects(:unify_arrays).times(0)
        
        assert_nil                                            unify(:word, [1,2,3,5], goal),      name
        
        expected_log = [
          'Cannot unify because Goal1.1234 != [1, 2, 3, 5] (variable != array)'
        ]
        
        assert_equal    expected_log,   goal.log
      end
      
    end
    
    describe 'when [:array, :variable]' do
      
      it 'should not unify instantiated variables that are not instantiated with an array' do
        goal.instantiate :word, '1 2 3 4'
        
        assert_nil                                            unify([1,2,3,4], :word, goal),      name
        
        expected_log = [
          'Cannot unify because [1, 2, 3, 4] != Goal1."1 2 3 4" (array != variable)'
        ]
        
        assert_equal    expected_log,                     goal.log
      end
      
      it 'should return an instantiation' do
        expects(:unify_arrays).times(0)
        
        assert_equal    [[:list, [7,11,13], goal, goal]],     unify([7,11,13], :list, goal),      name
      end
      
      it 'should not unify instantiated variables with different values' do
        goal.instantiate :word, [1,2,3,4]
        expects(:unify_arrays).times(1)
        
        assert_nil                                            unify([1,2,3,5], :word, goal),      name
        
        expected_log = [
          'Cannot unify because [1, 2, 3, 5] != Goal1.[1, 2, 3, 4] (variable/array != array)'
        ]
        
        assert_equal    expected_log,                     goal.log
      end
      
      it 'should unify instantiated variables with unifiable values' do
        goal.instantiate :word, [1,2,3]/:w
        
        instantiations = unify([nil,nil,3,4,5], :word, goal)
        
        expected_log            = []
        expected_instantiations = [
          [:w, [4,5], goal, goal],
        ]
        
        assert_equal    expected_log,             goal.log
        assert_equal    expected_instantiations,  instantiations
      end
      
    end
    
    describe 'when [:array,:atomic], [:atomic,:array]' do
      
      before do
        expects(:unify_arrays).times(0)
      end
      
      it 'should return nil for unifying array and atomic' do
        assert_nil                                           unify([7,11,13], 'word', goal),      name
        
        expected_log = [
          'Cannot unify [7, 11, 13] with "word"',
        ]
        
        assert_equal    expected_log,                     goal.log
      end
      
      it 'should return nil for unifying atomic and array' do
        assert_nil                                           unify('word', [7,11,13], goal),      name
        
        expected_log = [
          'Cannot unify "word" with [7, 11, 13]',
        ]
        
        assert_equal    expected_log,                     goal.log
      end
      
    end
    
  end
  
  describe '#unify_arrays' do
    
    let(:g1)    { new_goal(:p, :x, :y) }
    let(:g2)    { new_goal(:q, :a, :b) }
    let(:goals) { [g1, g2]             }
    
    it 'should not unify arrays when left is not an Array' do
      expect_unify_arrays_with_calls 0, 0, 0
      
      refute_Unify_arrays [{}, []], goals, [
        'Cannot unify a non-array with an array: {} with []',
      ]
    end
    
    it 'should not unify arrays when right is not an Array' do
      expect_unify_arrays_with_calls 0, 0, 0
      
      refute_Unify_arrays [[], 4], goals, [
        'Cannot unify a non-array with an array: [] with 4',
      ]
    end
    
    it 'should unify but without unifications when left is the unknown array' do
      expect_unify_arrays_with_calls 0, 0, 0
      
      assert_Unify_arrays [UNKNOWN_ARRAY, [:a,:b,:c]], goals, [g2[:a], g2[:b], g2[:c]]
    end
    
    it 'should unify but without unifications when right is the unknown array' do
      expect_unify_arrays_with_calls 0, 0, 0
      
      assert_Unify_arrays [[:x,:y,:z], UNKNOWN_ARRAY], goals, [g1[:x], g1[:y], g1[:z]]
    end
    
    it 'should unify but without unifications when left and right are the unknown array' do
      expect_unify_arrays_with_calls 0, 0, 0
      
      assert_Unify_arrays [[UNKNOWN_TAIL], UNKNOWN_ARRAY], goals, UNKNOWN_ARRAY
    end
    
    arrays_without_tails = [
      [],
      [1, 2, 3],
      [1, 2, 3, 4],
      [:x, :y, :z],
      [['one'], ['word'], ['sentences']],
    ]
    
    arrays_with_tails = [
      []/:t,
      [1]/:z,
      [1, 2]/:s,
      [1, UNKNOWN_TAIL],
      [1, 2, 3, UNKNOWN_TAIL],
      [1, 2, 3, 4, UNKNOWN_TAIL],
      [:x, :y, :z, UNKNOWN_TAIL],
      [['one'], ['word'], ['sentences']]/:tail,
    ]
    
    arrays_without_tails.combination(2).each do |arrays|
      it "should call unify_arrays_with_no_tails when there are no tails: #{arrays.map(&:inspect).join(' and ')}" do
        expect_unify_arrays_with_calls 1, 0, 0
        
        unify_arrays(*arrays, *goals)
      end
    end
    
    arrays_with_tails.combination(2).each do |arrays|
      it "should call unify_arrays_with_all_tails when all arrays have tails: #{arrays.map(&:inspect).join(' and ')}" do
        expect_unify_arrays_with_calls 0, 0, 1
        
        unify_arrays(*arrays, *goals)
      end
    end
    
    (
      arrays_without_tails.product(arrays_with_tails) +
      arrays_with_tails.product(arrays_without_tails)
    ).each do |arrays|
      it "should call unify_arrays_with_some_tails when one array has a tail and the other does not: #{arrays.map(&:inspect).join(' and ')}" do
        expect_unify_arrays_with_calls 0, 1, 0
        
        unify_arrays(*arrays, *goals)
      end
    end
    
    it 'should unify identical arrays without variables' do
      assert_Unify_arrays [[1,2,3], [1,2,3]], goals, [1,2,3]
    end
    
    it 'should unify an array of variables with an array of atomics' do
      assert_Unify_arrays [[:a,:b,:c], [1,2,3]], goals, [1,2,3], [
        [:a, 1, g1, g2],
        [:b, 2, g1, g2],
        [:c, 3, g1, g2],
      ]
    end
    
    it 'should unify an array of atomics with an array of variables' do
      assert_Unify_arrays [[1,2,3], [:a,:b,:c]], goals, [1,2,3], [
        [:a, 1, g2, g1],
        [:b, 2, g2, g1],
        [:c, 3, g2, g1],
      ]
    end
    
    it 'should unify arrays of variables' do
      assert_Unify_arrays [[:x,:y,:z], [:a,:b,:c]], goals, [nil,nil,nil], [
        [:x, :a, g1, g2],
        [:y, :b, g1, g2],
        [:z, :c, g1, g2],
      ]
    end
    
    it 'should unify a fixed array with an array with a tail' do
      assert_Unify_arrays [[:a, 2, 3], [1]/:t], goals, [1,2,3], [
        [:a, 1,     g1, g2],
        [:t, [2,3], g2, g1],
      ]
    end
    
    it 'should unify a fixed array with the unknown array' do
      assert_Unify_arrays [[1,2,3], UNKNOWN_ARRAY], goals, [1,2,3]
    end
    
    it 'should unify the unknown array with the unknown array' do
      assert_Unify_arrays [UNKNOWN_ARRAY, UNKNOWN_ARRAY], goals, UNKNOWN_ARRAY
    end
    
    it 'should unify arrays with variable tails' do
      assert_Unify_arrays [[:a, :b]/:c, [:x, :y]/:z], goals, [nil,nil,UNKNOWN_TAIL], [
        [:a, :x, g1, g2],
        [:b, :y, g1, g2],
        [:c, :z, g1, g2],
      ]
    end
    
    it 'should unify arrays with variable tails of different lenths' do
      assert_Unify_arrays [[:a, :b]/:c, [:x]/:z], goals, [nil,nil,UNKNOWN_TAIL], [
        [g2[:x], g1[:a],            g2, g1],
        [g2[:z], [g1[:b]]/g1[:c],   g2, g1],
      ]
    end
    
    it 'should unify arrays with overlapping variables' do
      assert_Unify_arrays [[:a,:a,:c,:c,:e], [1,:b,:b,:d,:d]], goals, [1, nil, nil, nil, nil], [
        [g1[:a], g2[1],  g1, g2],
        [g1[:a], g2[:b], g1, g2],
        [g1[:c], g2[:b], g1, g2],
        [g1[:c], g2[:d], g1, g2],
        [g1[:e], g2[:d], g1, g2],
      ]
    end
    
    it 'should unify complementary arrays' do
      assert_Unify_arrays [[1,2]/:t, [:a,:b,3,4,5]], goals, [1,2,3,4,5], [
        [g2[:a], g1[1],     g2, g1],
        [g2[:b], g1[2],     g2, g1],
        [g1[:t], [3, 4, 5], g1, g2],
      ]
    end
    
  end
  
  describe '#unify_many_arrays' do
    
    let(:goal)   { new_goal(:p, :x, :y) }
    
    it 'should return nil when not all arrays are Arrays or variables' do
      arrays = [
        [1,2,3],
        123,
        :x,
      ]
      
      assert_nil      unify_many_arrays(arrays, [goal] * arrays.size),      name
      
      expected_log = [
        'Cannot unify: [1, 2, 3] with 123 with :x',
      ]
      
      assert_equal    expected_log,                     goal.log
    end
    
    it 'should not return nil when all arrays are Arrays or variables' do
      arrays = [
        [1,2,3],
        UNKNOWN_ARRAY,
        :x,
      ]
      
      result = unify_many_arrays(arrays, [goal] * arrays.size)
      refute_nil      result,      name
      
      merged, unifications = result
      
      expected_merged       = [1,2,3]
      expected_unifications = [
      ]
      
      assert_equal    expected_merged,          merged
      assert_equal    expected_unifications,    unifications
    end
    
    it 'should automatically merge unknown arrays' do
      arrays = [
        [1,2,3],
        UNKNOWN_ARRAY,
      ]
      
      assert_equal    [[1,2,3], []],        unify_many_arrays(arrays, [goal] * arrays.size),      name
    end
    
    it 'should call unify_arrays_with_no_tails when there are no Arrays with Tails' do
      expect_unify_arrays_with_calls 1, 0, 0
      
      arrays = [
        [1,   2,    3,  nil],
        [1,   nil,  3,  4],
        [nil, 2,    3,  nil],
      ]
      
      unify_many_arrays(arrays, [goal] * arrays.size)
    end
    
    it 'should call unify_arrays_with_all_tails when all Arrays have Tails' do
      expect_unify_arrays_with_calls 0, 0, 1
      
      arrays = [
        [1,   2,    3,  UNKNOWN_TAIL],
        [1,   nil,  3,  ]/:x,
      ]
      
      unify_many_arrays(arrays, [goal] * arrays.size)
    end
    
    it 'should call unify_arrays_with_some_tails when there is a combination of Arrays with and without Tails' do
      expect_unify_arrays_with_calls 0, 1, 0
      
      arrays = [
        [1,   2,    3,  UNKNOWN_TAIL],
        [1,   nil,  3,  4],
        [nil, 2,    3,  nil],
      ]
      
      unify_many_arrays(arrays, [goal] * arrays.size)
    end
    
  end
  
  describe '#has_tail?' do
    
    # -- Non-Arrays --
    let(:goal)                      { new_goal(:p, :x, :y) }
    let(:variable)                  { goal.variable(:x) }
    let(:object)                    { Object.new }
    let(:symbol)                    { :symbol }
    let(:integer)                   { 789 }
    
    # -- Arrays --
    let(:empty_array)               { [] }
    let(:finite_array)              { [1,2,3,4,5] }
    let(:array_with_unknown_tail)   { [1,2,3,4,5,UNKNOWN_TAIL] }
    let(:array_with_variable_tail)  { [1,2,3,4,5]/:tail }
    let(:unknown_array)             { UNKNOWN_ARRAY }
    
    describe 'when not given an Array' do
      
      it 'should return false when given an uninstantiated variable' do
        refute  has_tail?(variable), name
      end
      
      it 'should return false when given an Object' do
        refute  has_tail?(object), name
      end
      
      it 'should return false when given a Symbol' do
        refute  has_tail?(symbol), name
      end
      
      it 'should return false when given an Integer' do
        refute  has_tail?(integer), name
      end
      
    end
    
    describe 'when given an Array' do
      
      it 'should return false when the Array is empty' do
        refute  has_tail?(empty_array), name
      end
      
      it 'should return false when the last element is atomic' do
        refute  has_tail?(finite_array), name
      end
      
      it 'should return true when the last element is unknown' do
        assert  has_tail?(array_with_unknown_tail), name
      end
      
      it 'should return true when the last element is a Tail' do
        assert  has_tail?(array_with_variable_tail), name
      end
      
      it 'should return true when given an unknown array' do
        assert  has_tail?(unknown_array), name
      end
      
      describe 'and the array has an instantiated tail' do
        
        before do
          goal.instantiate :a, 1
          goal.instantiate :b, 2
          goal.instantiate :c, 3
          goal.instantiate :d, 4
          goal.instantiate :e, [5]
        end
        
        describe 'and to apply value to the array' do
          
          it 'should return false' do
            array = goal.variablise([:a, :b, :c, :d]/:e)
            
            refute  has_tail?(array, true), name
          end
          
        end
        
        describe 'and to not apply value to the array' do
          
          it 'should return true' do
            array = goal.variablise([:a, :b, :c, :d]/:e)
            
            assert  has_tail?(array, false), name
          end
          
        end
        
      end
      
    end
    
  end
  
  describe '#expand_splat' do
    
    it 'should return an empty array as is' do
      assert_equal    [],     expand_splat([])
    end
    
    it 'should return non-arrays as is' do
      assert_equal    5,      expand_splat(5)
    end
    
    it 'should expand an array of just a Tail' do
      assert_equal    :t,     expand_splat([]/:t)
    end
    
    it 'should not expand an array with a Tail' do
      assert_equal    [1,2,3]/:t,     expand_splat([1,2,3]/:t)
    end
    
    it 'should expand a tail' do
      assert_equal    [1,2,3,4,5],    expand_splat([1,2,3,Tail.new([4,5])])
    end
    
    it 'should expand nested arrays' do
      assert_equal    [99, [1,2,3,4], 99],    expand_splat([99,[1,2,3,Tail.new([4])],99])
    end
    
  end
  
  describe '#unify_arrays_with_no_tails' do
    
    let(:g1)    { new_goal(:p, :x, :y) }
    let(:g2)    { new_goal(:q, :a, :b) }
    let(:g3)    { new_goal(:r, :s, :t) }
    let(:g4)    { new_goal(:v, :i, :j) }
    let(:goals) { [g1, g2, g3, g4]     }
    
    it 'should return nil when any array has a tail' do
      arrays = [
        [1,  2,  3,  4],
        [1,  2,  3]/:tail,
        [:w, :x, :y, :z]
      ]
      arrays_goals = goals[0..arrays.size]
      
      assert_nil      unify_arrays_with_no_tails(arrays, arrays_goals, []), name
      
      expected_log = [
        'Wrong unification method called: no_tails but one or more of [[1, 2, 3, 4], [1, 2, 3, *:tail], [:w, :x, :y, :z]] has a tail',
      ]
      
      arrays_goals.each do |goal|
        assert_equal    expected_log,                     goal.log
      end
    end
    
    it 'should not unify finite arrays with unequal sizes' do
      # -- First > Last --
      arrays = [
        [nil, nil, nil, nil],
        [1,   2,   3]
      ]
      arrays_goals = goals[0...arrays.size]

      assert_nil                        unify_arrays_with_no_tails(arrays, arrays_goals, []), name
      
      # -- First = Last --
      arrays = [
        [nil, nil, nil],
        [1,   2,   3]
      ]
      arrays_goals = goals[0...arrays.size]
      
      expected_merged       = [1,2,3]
      expected_unifications = []

      merged, unifications = unify_arrays_with_no_tails(arrays, arrays_goals, [])
      
      assert_equal    expected_merged,          merged
      assert_equal    expected_unifications,    unifications
      
      # -- First < Last --
      arrays = [
        [nil, nil],
        [1,   2,   3]
      ]
      arrays_goals = goals[0...arrays.size]

      assert_nil                        unify_arrays_with_no_tails(arrays, arrays_goals, []), name
      
      # -- Check Log --
      expected_log = [
        'Cannot unify arrays of different lengths: [nil, nil, nil, nil] with [1, 2, 3]',
        'Cannot unify arrays of different lengths: [nil, nil] with [1, 2, 3]',
      ]
      
      arrays_goals.each do |goal|
        assert_equal    expected_log,                     goal.log
      end
    end
    
    it 'should merge values with nil as an empty slot' do
      arrays = [
        [1,   2,   3,   nil, nil],
        [nil, nil, nil, 4,   nil],
        [nil, nil, nil, nil, 5],
      ]
      arrays_goals = goals[0...arrays.size]
      
      merged, unifications = unify_arrays_with_no_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1, 2, 3, 4, 5]
      expected_unifications = []
      
      assert_equal  expected_merged,        merged
      assert_equal  expected_unifications,  unifications
    end
    
    it 'should return nil when the finite arrays have different sizes' do
      arrays = [
        [nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert_nil                        unify_arrays_with_no_tails(arrays, arrays_goals, []), name
      
      expected_log = [
        'Cannot unify arrays of different lengths: [nil] with [nil, nil, nil, nil] with [nil, nil, nil, nil, nil, nil]',
      ]
      
      arrays_goals.each do |goal|
        assert_equal    expected_log,                     goal.log
      end
    end
    
    it 'should return nil when the arrays have incompatible values' do
      arrays = [
        [1,   2,   3,   nil, nil],
        [nil, nil, nil, 4,   nil],
        [8,   nil, nil, nil, 5],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert_nil                        unify_arrays_with_no_tails(arrays, arrays_goals, []), name
      
      expected_log = [
        'Cannot unify incompatible values: 1 with 8',
      ]
      
      arrays_goals.each do |goal|
        assert_equal    expected_log,                     goal.log
      end
    end
    
    it 'should return necessary unifications to unify variables' do
      arrays = [
        [1,   2,   nil, nil, nil],
        [:j,  :n,  :n,  4,   nil],
        [:x,  nil, :m,  :y,  :z],
      ]
      arrays_goals = goals[0...arrays.size]
      
      merged, unifications = unify_arrays_with_no_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1, 2, nil, 4, nil]
      expected_unifications = [
        [g2[:j], g1[1],   g2, g1],
        [g3[:x], g1[1],   g3, g1],
        [g2[:j], g3[:x],  g2, g3],
        [g2[:n], g1[2],   g2, g1],
        [g2[:n], g3[:m],  g2, g3],
        [g3[:y], g2[4],   g3, g2],
      ]
      
      assert_equal    expected_merged,          merged
      assert_equal    expected_unifications,    unifications
    end
    
    it 'should deduce array goals from array elements when missing' do
      arrays = [
        [         nil, 2,   nil, g1.value(4), nil],
        g2.value([1,   nil, 3,   nil,         nil]),
        g3.value([nil, :x,  nil, nil,         5]),
      ]
      missing_goals = [nil, nil, nil]
      
      merged, unifications = unify_arrays_with_no_tails(arrays, missing_goals, [])
      
      expected_merged       = [1, 2, 3, 4, 5]
      expected_unifications = [
        [g3.variable(:x), g1.value(2), g3, g1]
      ]
      
      assert_equal    expected_merged,            merged
      assert_equal    expected_unifications,      unifications
    end
    
    it 'should map Values as is' do
      value1 = g1.value(91)
      g1.instantiate(:gi, [nil, value1, nil, 93])
      
      arrays = [
        [         nil, 2,    nil,  :gi,                   nil],
        g2.value([1,   nil,  3,    [90,  nil, nil, nil],  nil]),
        g3.value([nil, :x,   nil,  [nil, nil, 92,  :gy],  5]),
      ]
      
      arrays_goals = [g1, nil, nil]
      
      merged, unifications = unify_arrays_with_no_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1, 2, 3, [90, 91, 92, 93], 5]
      expected_unifications = [
        [g3.variable(:x),  g1.value(2),  g3, g1],
        [g3.variable(:gy), g1.value(93), g3, g1],
      ]
      
      assert_equal    expected_merged,          merged
      assert_equal    expected_unifications,    unifications
    end
    
    it 'should detect ununifiable values embedded in subarrays' do
      value1 = g1.value(91)
      g1.instantiate(:gi, [nil, value1, 92.1, 93])
      
      arrays = [
        [         nil, 2,    nil,  :gi,                   nil],
        g2.value([1,   nil,  3,    [90,  nil, nil, nil],  nil]),
        g3.value([nil, :x,   nil,  [nil, nil, 92,  :gy],  5]),
      ]
      
      arrays_goals = [g1, nil, nil]
      
      assert_nil      unify_arrays_with_no_tails(arrays, arrays_goals, []), name
      
      expected_log = [
        'Cannot unify incompatible values: 92.1 with 92',
        'Cannot unify: [nil, 91, 92.1, 93] with [90, nil, nil, nil] with [nil, nil, 92, Goal3.:gy]',
      ]
      
      [g1, g2, g3].each do |goal|
        assert_equal    expected_log,   goal.log
      end
    end
    
    it 'should not expand variables when they are instantiated to the unknown array' do
      arrays_goals = goals[0...4]
      g4.instantiate :z, UNKNOWN_ARRAY
      arrays = [
        [1,   2,   nil, nil, nil],
        [:j,  :n,  :n,  4,   nil],
        [:x,  nil, :m,  :y,  :z],
        :z
      ]
      
      assert_equal    UNKNOWN_ARRAY,      g4[:z].value
      
      merged, unifications = unify_arrays_with_no_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1, 2, nil, 4, nil]
      expected_unifications = [
        [g2[:j], g1[1],   g2, g1],
        [g2[:n], g1[2],   g2, g1],
        [g3[:x], g1[1],   g3, g1],
        [g4[:z], [g1[1],  g1[2], g1.value(nil), g1.value(nil), g1.value(nil)], g4, g1],
        [g2[:j], g3[:x],  g2, g3],
        [g2[:n], g3[:m],  g2, g3],
        [g3[:y], g2[4],   g3, g2],
        [g4[:z], [g2[:j], g2[:n],  g2[:n], g2[4],  g2.value(nil)], g4, g2],
        [g4[:z], [g3[:x], g3.value(nil), g3[:m], g3[:y], g3[:z]],  g4, g3],
      ]
      
      assert_equal    expected_merged,          merged
      assert_equal    expected_unifications,    unifications
    end
    
    it 'should not expand variables when they are instantiated to the unknown tail' do
      arrays_goals = goals[0...4]
      g4.instantiate :z, UNKNOWN_TAIL
      arrays = [
        [1,   2,   nil, nil, nil],
        [:j,  :n,  :n,  4,   nil],
        [:x,  nil, :m,  :y,  :z],
        :z
      ]
      
      assert_equal    g4[:z],             g4[:z].value
      
      merged, unifications = unify_arrays_with_no_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1, 2, nil, 4, nil]
      expected_unifications = [
        [g2[:j], g1[1],   g2, g1],
        [g2[:n], g1[2],   g2, g1],
        [g3[:x], g1[1],   g3, g1],
        [g4[:z], [g1[1],  g1[2], g1.value(nil), g1.value(nil), g1.value(nil)], g4, g1],
        [g2[:j], g3[:x],  g2, g3],
        [g2[:n], g3[:m],  g2, g3],
        [g3[:y], g2[4],   g3, g2],
        [g4[:z], [g2[:j], g2[:n],  g2[:n], g2[4],  g2.value(nil)], g4, g2],
        [g4[:z], [g3[:x], g3.value(nil), g3[:m], g3[:y], g3[:z]],  g4, g3],
      ]
      
      assert_equal    expected_merged,          merged
      assert_equal    expected_unifications,    unifications
    end
    
    it 'should not unify an atomic with an embedded unknown array ' do
      value1 = g1.value(91)
      g1.instantiate(:gi, [nil, value1, 92.1, 93])
      
      arrays = [
        [         nil, 2,    nil,  :gi,                   nil],
        g2.value([1,   nil,  3,    [90,  nil, nil, nil],  nil]),
        g3.value([nil, :x,   nil,  [nil, nil, UNKNOWN_ARRAY,  :gy],  5]),
      ]
      
      arrays_goals = [g1, nil, nil]
      
      assert_nil      unify_arrays_with_no_tails(arrays, arrays_goals, []), name
      
      expected_log = [
        'Cannot unify incompatible values: 92.1 with [...]',
        'Cannot unify: [nil, 91, 92.1, 93] with [90, nil, nil, nil] with [nil, nil, [...], Goal3.:gy]',
      ]
      
      [g1, g2, g3].each do |goal|
        assert_equal    expected_log,   goal.log
      end
    end
    
    it 'should not unify arrays where one embedded variable cannot be unified' do
      g1.instantiate(:a, :b)
      g2.instantiate(:a, 2)
      g3.instantiate(:a, 3)
      
      arrays = [
        [[:a]],
        [[:a]],
        [[:a]],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert_nil      unify_arrays_with_no_tails(arrays, arrays_goals, []), name
      
      assert_equal [
        'Cannot unify: [Goal1.:a] with [Goal2.2] with [Goal3.3]',
      ], g1.log
      
      assert_equal [
        'Cannot unify because Goal2.2 != Goal3.3 (atomic != atomic)',
        'Cannot unify: Goal2.2 with Goal3.3',
        'Cannot unify: [Goal1.:a] with [Goal2.2] with [Goal3.3]',
      ], g2.log
      
      assert_equal [
        'Cannot unify because Goal2.2 != Goal3.3 (atomic != atomic)',
        'Cannot unify: Goal2.2 with Goal3.3',
        'Cannot unify: [Goal1.:a] with [Goal2.2] with [Goal3.3]',
      ], g3.log
    end
    
    it 'should raise an exception when an array has no associated goal' do    # NOT DONE: need to expose the call to unify_arrays_with_no_tails
      
      error = assert_raises Porolog::NoGoalError do
        variable1 = Variable.new :x, g1
        value     = Value.new [7,11,13,23,29], g2
        
        variable1.values << [7,11,13,23,29]
        variable1.values << [7,12,13,23,29]
        
        variable1.instantiate value
      end
      
      assert_equal    'Array [7, 11, 13, 23, 29] has no goal for unification',    error.message
    end
    
  end
  
  describe '#unify_arrays_with_some_tails' do
    
    let(:g1)    { new_goal(:p, :x, :y) }
    let(:g2)    { new_goal(:q, :a, :b) }
    let(:g3)    { new_goal(:r, :s, :t) }
    let(:goals) { [g1, g2, g3]         }
    
    it 'should not unify a finite array with an array with a tail that has more finite elements' do
      arrays = [
        [nil, nil, nil, nil, UNKNOWN_TAIL],
        [1,   2,   3]
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert_nil                        unify_arrays_with_some_tails(arrays, arrays_goals, []), name
      
      expected_log = [
        'Cannot unify enough elements: [nil, nil, nil, nil, ...] with [Goal2.1, Goal2.2, Goal2.3]',
      ]
      
      assert_equal    expected_log,                     g1.log
      assert_equal    expected_log,                     g2.log
    end
    
    it 'should unify a finite array with an array with a tail that has less finite elements' do
      arrays = [
        [nil, nil, UNKNOWN_TAIL],
        [1,   2,   3]
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert_equal  [[1,2,3],[]],       unify_arrays_with_some_tails(arrays, arrays_goals, []), name
    end
    
    it 'should merge values with an unknown tail' do
      arrays = [
        [1,   2,   3,   UNKNOWN_TAIL],
        [nil, nil, nil, 4,   nil],
        [nil, nil, nil, nil, 5],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert_equal  [[1,2,3,4,5],[]],   unify_arrays_with_some_tails(arrays, arrays_goals, []), name
    end
    
    it 'should return nil when the finite arrays have different sizes' do
      arrays = [
        [nil, UNKNOWN_TAIL],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert_nil                        unify_arrays_with_some_tails(arrays, arrays_goals, []), name
      
      expected_log = [
        'Cannot unify different sizes of arrays: [nil, ...] with [nil, nil, nil, nil] with [nil, nil, nil, nil, nil, nil]',
      ]
      
      assert_equal    expected_log,                     g1.log
      assert_equal    expected_log,                     g2.log
      assert_equal    expected_log,                     g3.log
    end
    
    it 'should return nil when the arrays have incompatible values' do
      arrays = [
        [1, 2, 3, UNKNOWN_TAIL],
        [nil, nil, nil, 4, nil],
        [5,   nil, nil, nil, 5],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert_nil                        unify_arrays_with_some_tails(arrays, arrays_goals, []), name
      
      expected_log = [
        'Cannot unify enough elements: Goal1.1 with Goal3.5',
      ]
      
      assert_equal    expected_log,                     g1.log
      assert_equal    expected_log,                     g2.log
      assert_equal    expected_log,                     g3.log
    end
    
    it 'should return necessary unification to unify variables' do
      arrays = [
        [1,   2,   nil, UNKNOWN_TAIL],
        [:j,  :n,  :n,  4,  nil],
        [:x,  nil, :m,  :y, :z],
      ]
      arrays_goals = goals[0...arrays.size]
      
      merged, unifications = unify_arrays_with_some_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1, 2, nil, 4, nil]
      expected_unifications = [
        [g2.variable(:j), g1.value(1),      g2, g1],
        [g3.variable(:x), g1.value(1),      g3, g1],
        [g2.variable(:j), g3.variable(:x),  g2, g3],
        [g2.variable(:n), g1.value(2),      g2, g1],
        [g2.variable(:n), g3.variable(:m),  g2, g3],
        [g3.variable(:y), g2.value(4),      g3, g2],
      ]
      
      assert_equal  [expected_merged, expected_unifications],   [merged, unifications], name
    end
    
    it 'should handle a range of cases' do
      [
        [[[],                        [1,UNKNOWN_TAIL]      ],   nil, ['Cannot unify enough elements: [] with [Goal2.1, ...]']],
        [[[]/:t,                     [1]                   ],   [[1], [[g1.variable(:t), [1], g1, g2]]]],
        [[[],                        [1,2]/:s              ],   nil, ['Cannot unify enough elements: [] with [Goal2.1, Goal2.2, *Goal2.:s]']],
        [[[]/:t,                     [1,2]                 ],   [[1,2], [[g1.variable(:t), [1,2], g1, g2]]]],
        [[[1,2,3],                   [1,UNKNOWN_TAIL]      ],   [[1,2,3],[]]],
        [[[1,2,3,UNKNOWN_TAIL],      [1]                   ],   nil, ['Cannot unify enough elements: [Goal1.1, Goal1.2, Goal1.3, ...] with [Goal2.1]']],
        [[[1],                       [1,2,3,UNKNOWN_TAIL]  ],   nil, ['Cannot unify enough elements: [Goal1.1] with [Goal2.1, Goal2.2, Goal2.3, ...]']],
        [[[1]/:z,                    [1,2,3]               ],   [[1,2,3], [[g1.variable(:z), [2, 3], g1, g2]]]],
        [[[:x,:y,:z],                [1,2,3,4,UNKNOWN_TAIL]],   nil, ['Cannot unify enough elements: [Goal1.:x, Goal1.:y, Goal1.:z] with [Goal2.1, Goal2.2, Goal2.3, Goal2.4, ...]']],
        [[[:x,:y,:z,UNKNOWN_TAIL],   [1,2,3,4]             ],   [
          [1,2,3,4],
          [
            [g1.variable(:x), g2.value(1), g1, g2],
            [g1.variable(:y), g2.value(2), g1, g2],
            [g1.variable(:z), g2.value(3), g1, g2]
          ]
        ]],
      ].each do |arrays, expected, expected_log|
        arrays_goals = goals[0...arrays.size]
        
        result = unify_arrays_with_some_tails(arrays, arrays_goals, [])
        
        if expected.nil?
          assert_nil                  result
          
          arrays_goals.uniq.each do |goal|
            assert_equal    expected_log,                     goal.log
            goal.log[0..-1] = []
          end
        else
          assert_equal    expected,   result
        end
      end
    end
    
    it 'should raise a no goal error when no goals are supplied and the arrays have no embedded goals' do
      arrays = [
        [nil, nil, nil, nil, UNKNOWN_TAIL],
        [1,   2,   3]
      ]
      arrays_goals = [nil] * arrays.size
      
      error = assert_raises Porolog::NoGoalError do
        unify_arrays_with_some_tails(arrays, arrays_goals, [])
      end
      
      assert_equal '[nil, nil, nil, nil, ...] has no associated goal!  Cannot variablise!', error.message
    end
    
    it 'should derive goals from embedded goals when the goals are not supplied' do
      arrays_goals = [g1, nil]
      arrays = [
        [nil, nil, nil,   nil, UNKNOWN_TAIL],
        [1,   2,   g2[3], 4]
      ]
      
      refute              arrays.all?{|array| has_tail?(array, false)  },  "not all arrays should have a tail"
      refute              arrays.all?{|array| !has_tail?(array, false) },  "not all arrays should not have a tail"
      
      merged, unifications = unify_arrays_with_some_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1,2,3,4]
      expected_unifications = [
      ]
      
      assert_equal    expected_merged,              merged
      assert_equal    expected_unifications,        unifications
    end
    
    it 'should extract embedded variables and values in an array in a value' do
      arrays = [
        g1.value([nil, :b, nil,   nil, 5]),
        [1,   2,   g2[3], 4]/:t
      ]
      arrays_goals = goals[0...arrays.size]
      
      refute              arrays.all?{|array| has_tail?(array, false)  },  "not all arrays should have a tail"
      refute              arrays.all?{|array| !has_tail?(array, false) },  "not all arrays should not have a tail"
      
      merged, unifications = unify_arrays_with_some_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1,2,3,4,5]
      expected_unifications = [
        [g1[:b], g2[2], g1, g2],
        [g2[:t], [5],   g2, g1],
      ]
      
      assert_equal    expected_merged,              merged
      assert_equal    expected_unifications,        unifications
    end
    
    it 'should unify multiple atomics and tails' do
      arrays = [
        g1.value([nil, :b, nil,   nil, 5, 6, 7]),
        [1,   2,   g2[3], 4]/:t,
        [1,   2,   g3[3], 4]/:t,
      ]
      arrays_goals = goals[0...arrays.size]
      
      refute          arrays.all?{|array| has_tail?(array, false)  },  "not all arrays should have a tail"
      refute          arrays.all?{|array| !has_tail?(array, false) },  "not all arrays should not have a tail"
      
      merged, unifications = unify_arrays_with_some_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1,2,3,4,5,6,7]
      expected_unifications = [
        [g1[:b], g2[2],     g1, g2],
        [g1[:b], g3[2],     g1, g3],
        [g2[:t], [5,6,7],   g2, g1],
        [g3[:t], [5,6,7],   g3, g1],
      ]
      
      assert_equal    expected_merged,              merged
      assert_equal    expected_unifications,        unifications
    end
    
    it 'should not unify incompatible atomics' do
      arrays = [
        g1.value([nil, :b, nil,   nil, 5]),
        [1,   2,   g2[3], 4]/:t,
        [1,   3,   g3[3], 4]/:t,
      ]
      arrays_goals = goals[0...arrays.size]
      
      refute          arrays.all?{|array| has_tail?(array, false)  },  "not all arrays should have a tail"
      refute          arrays.all?{|array| !has_tail?(array, false) },  "not all arrays should not have a tail"
      
      assert_nil      unify_arrays_with_some_tails(arrays, arrays_goals, []), name
      
      assert_equal [
        'Cannot unify non-variables: 2 with 3'
      ], g1.log
      
      assert_equal [
        'Cannot unify non-variables: 2 with 3'
      ], g2.log
      
      assert_equal [
        'Cannot unify non-variables: 2 with 3'
      ], g3.log
    end
    
  end
  
  describe '#unify_arrays_with_all_tails' do    # NOT DONE: coverage
    
    let(:g1)    { new_goal(:p, :x, :y) }
    let(:g2)    { new_goal(:q, :a, :b) }
    let(:g3)    { new_goal(:r, :s, :t) }
    let(:goals) { [g1, g2, g3]         }
    
    let(:array_with_tail_1) { [1,  2,  Tail.new(:h)] }
    let(:array_with_tail_2) { [:h, :b]/:t }
    let(:array_with_tail_3) { [:x, :y, UNKNOWN_TAIL] }
    let(:head_and_tail_1)   { [1,  Tail.new([2,3])] }
    let(:head_and_tail_2)   { [:h]/:t }
    let(:head_and_tail_3)   { [:x, UNKNOWN_TAIL] }
    
    it 'should call unify_tail_with_tail when no array is headtail' do
      expects(:unify_tail_with_tail).times(1)
      expects(:unify_headtail_with_tail).times(0)
      expects(:unify_headtail_with_headtail).times(0)
      
      arrays = [
        array_with_tail_1,
        array_with_tail_2,
        array_with_tail_3,
      ]
      arrays_goals = goals[0...arrays.size]
      
      unify_arrays_with_all_tails(arrays, arrays_goals, [])
    end
    
    it 'should call unify_headtail_with_tail when all arrays but one are headtail' do
      expects(:unify_tail_with_tail).times(0)
      expects(:unify_headtail_with_tail).times(1)
      expects(:unify_headtail_with_headtail).times(0)
      
      arrays = [
        array_with_tail_1,
        head_and_tail_2,
        head_and_tail_3,
      ]
      arrays_goals = goals[0...arrays.size]
      
      unify_arrays_with_all_tails(arrays, arrays_goals, [])
    end
    
    it 'should include unifications of variables in a tail' do
      arrays = [
        [nil, nil, nil]/:list,
        [1,   2,   3,   nil, :y, UNKNOWN_TAIL],
        [nil, :x,  nil, 4,   Tail.new([nil,6])],
      ]
      arrays_goals = goals[0...arrays.size]
      
      g1.instantiate :list, [4,5,:z]
      
      merged, unifications = unify_arrays_with_all_tails(arrays, arrays_goals, [])
      
      expected_merged       = [1,2,3,4,5,6]
      expected_unifications = [
        [g3[:x], g2[2], g3, g2],
        [g2[:y], g1[5], g2, g1],
        [g1[:z], g3[6], g1, g3],
      ]
      
      assert_equal    expected_merged,              merged
      assert_equal    expected_unifications,        unifications
    end
    
    it 'should not unify arrays where one embedded variable cannot be unified' do
      g1.instantiate(:a, [g1.value(1), g1.value(2), g1.value(3), UNKNOWN_TAIL])
      g2.instantiate(:a, :b)
      g3.instantiate(:a, :b)
      
      arrays = [
        :a,
        [:a,Tail.new([1])],
        [:a, UNKNOWN_TAIL],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert_nil      unify_arrays_with_all_tails(arrays, arrays_goals, []), name
      
      assert_equal [
        'Cannot unify enough elements: Goal1.[Goal1.1, Goal1.2, Goal1.3, ...] with [Goal2.:a, Goal2.1]',
        'Cannot unify because Goal1.[Goal1.1, Goal1.2, Goal1.3, ...] != [:a, 1] (variable/array != array)',
        'Cannot unify embedded arrays: :a with [:a, 1]',
      ], g1.log
      
      assert_equal [
        'Cannot unify enough elements: Goal1.[Goal1.1, Goal1.2, Goal1.3, ...] with [Goal2.:a, Goal2.1]',
        'Cannot unify because Goal1.[Goal1.1, Goal1.2, Goal1.3, ...] != [:a, 1] (variable/array != array)',
        'Cannot unify embedded arrays: :a with [:a, 1]',
      ], g2.log
      
      assert_equal [
        'Cannot unify embedded arrays: :a with [:a, 1]',
      ], g3.log
    end
    
    it 'should unify arrays where all embedded variables can be unified' do
      arrays = [
        [g1.variable(:a), g1.value(2), g1.variable(:c), g1.value(4)],
        [g2.value(1), g1.variable(:b), g2.value(3), UNKNOWN_TAIL],
        [:a, :b, Tail.new([3,:d])],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert arrays.map(&:headtail?).none?
      
      expected_merged = [1,2,3,4]
      expected_unifications = [
        [g1.variable(:a), g2.value(1),      g1, g2],
        [g1.variable(:a), g3.variable(:a),  g1, g3],
        [g3.variable(:a), g2.value(1),      g3, g2],
        [g1.variable(:b), g1.value(2),      g1, g1],
        [g3.variable(:b), g1.value(2),      g3, g1],
        [g1.variable(:b), g3.variable(:b),  g1, g3],
        [g1.variable(:c), g2.value(3),      g1, g2],
        [g1.variable(:c), g3.value(3),      g1, g3],
        [g3.variable(:d), g1.value(4),      g3, g1]
      ]
      merged, unifications = unify_arrays_with_all_tails(arrays, arrays_goals, [])
      
      assert_equal [], g1.log
      assert_equal [], g2.log
      assert_equal [], g3.log
      
      assert_equal    expected_merged,        merged
      assert_equal    expected_unifications,  unifications
    end
    
    it 'should unify embedded arrays where all embedded variables can be unified' do
      arrays = [
        :e,
        [[1],[2],[3],[4]],
        [[1],[2],[3],[4]],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert arrays.map(&:headtail?).none?
      
      expected_merged = [[1],[2],[3],[4]]
      expected_unifications = [
        [:e, [[1], [2], [3], [4]], g1, g2]
      ]
      merged, unifications = unify_arrays_with_all_tails(arrays, arrays_goals, [])
      
      assert_equal [], g1.log
      assert_equal [], g2.log
      assert_equal [], g3.log
      
      assert_equal    expected_merged,        merged
      assert_equal    expected_unifications,  unifications
    end
    
  end
  
  describe '#unify_tail_with_tail' do
    
    let(:g1)    { new_goal(:p, :x, :y) }
    let(:g2)    { new_goal(:q, :a, :b) }
    let(:g3)    { new_goal(:r, :s, :t) }
    let(:g4)    { new_goal(:j, :k, :l) }
    let(:goals) { [g1, g2, g3, g4]     }
    
    it 'should reject a non-headtail array' do
      arrays = [
        [1,Tail.new([2,3])],
        [4],
        [7,UNKNOWN_TAIL],
      ]
      arrays_goals = goals[0...arrays.size]
      
      refute              arrays.all?(&:headtail?)
      
      assert_nil          unify_tail_with_tail(arrays, arrays_goals, [])
      
      msg = 'Wrong method called to unify [[1, *[2, 3]], [4], [7, ...]]'
      
      assert_equal        [msg],      g1.log
      assert_equal        [msg],      g2.log
      assert_equal        [msg],      g3.log
    end
    
    it 'should process more than two arrays that are a non-headtail' do
      arrays = [
        [1, 2, Tail.new([3,4])],
        [:a, :b]/:c,
        [:d, :e, UNKNOWN_TAIL],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert        arrays.all?{|array| has_tail?(array, false) }
      assert        arrays.map(&:headtail?).map(&:!).all?
      
      merged, unifications = unify_tail_with_tail(arrays, arrays_goals, [])
      
      expected_merged = [1,2,3,4]
      
      expected_unifications = [
        [g2.variable(:a), g1.value(1),          g2, g1],
        [g3.variable(:d), g1.value(1),          g3, g1],
        [g2.variable(:a), g3.variable(:d),      g2, g3],
        [g2.variable(:b), g1.value(2),          g2, g1],
        [g3.variable(:e), g1.value(2),          g3, g1],
        [g2.variable(:b), g3.variable(:e),      g2, g3],
        [g2.variable(:c), g1.variablise([3,4]), g2, g1],
      ]
      
      assert_equal  expected_merged,        merged
      assert_equal  expected_unifications,  unifications
    end
    
    it 'should unify arrays of different lengths' do
      arrays = [
        [1,   2,   UNKNOWN_TAIL],
        [nil, nil, 3,   4,   UNKNOWN_TAIL],
        [nil, nil, nil, nil, 5, 6, UNKNOWN_TAIL],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert        arrays.all?{|array| has_tail?(array) }
      assert        arrays.map(&:headtail?).map(&:!).all?
      
      merged, unifications = unify_tail_with_tail(arrays, arrays_goals, [])
      
      expected_merged = [
        g1.value(1),
        g1.value(2),
        g2.value(3),
        g2.value(4),
        g3.value(5),
        g3.value(6),
        UNKNOWN_TAIL,
      ]
      
      expected_unifications = [
      ]
      
      assert_equal expected_merged,       merged
      assert_equal expected_unifications, unifications
    end
    
    it 'should unify all combinations of tails and tails' do
      arrays = [
        [:a,:b]/:c,
        [:d,:e]/:f,
        [:g,:h]/:i,
        [:j,:k]/:l,
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert        arrays.all?{|array| has_tail?(array) }
      assert        arrays.map(&:headtail?).map(&:!).all?
      
      merged, unifications = unify_tail_with_tail(arrays, arrays_goals, [])
      
      expected_merged = [nil, nil, UNKNOWN_TAIL]
      
      expected_unifications = [
        [g1[:a], g2[:d], g1, g2],
        [g1[:a], g3[:g], g1, g3],
        [g1[:a], g4[:j], g1, g4],
        [g2[:d], g3[:g], g2, g3],
        [g2[:d], g4[:j], g2, g4],
        [g3[:g], g4[:j], g3, g4],
        [g1[:b], g2[:e], g1, g2],
        [g1[:b], g3[:h], g1, g3],
        [g1[:b], g4[:k], g1, g4],
        [g2[:e], g3[:h], g2, g3],
        [g2[:e], g4[:k], g2, g4],
        [g3[:h], g4[:k], g3, g4],
        [g1[:c], g2[:f], g1, g2],
        [g1[:c], g3[:i], g1, g3],
        [g1[:c], g4[:l], g1, g4],
        [g2[:f], g3[:i], g2, g3],
        [g2[:f], g4[:l], g2, g4],
        [g3[:i], g4[:l], g3, g4],
      ]
      
      assert_equal expected_merged,       merged
      assert_equal expected_unifications, unifications
    end
    
    it 'should not unify ununifiable arrays' do
      arrays = [
        [1,2,3,4,UNKNOWN_TAIL],
        [1,4,3,2,UNKNOWN_TAIL],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert        arrays.all?{|array| has_tail?(array) }
      assert        arrays.map(&:headtail?).map(&:!).all?
      
      assert_nil    unify_tail_with_tail(arrays, arrays_goals, []), name
      
      expected_log = [
        'Cannot unify incompatible values: 2 with 4',
        'Cannot unify Goal1.2 with Goal2.4',
      ]
      
      arrays_goals.each do |goal|
        assert_equal    expected_log,   goal.log
      end
    end
    
  end
  
  describe '#unify_headtail_with_tail' do
    
    let(:g1)    { new_goal(:p, :x, :y) }
    let(:g2)    { new_goal(:q, :a, :b) }
    let(:g3)    { new_goal(:r, :s, :t) }
    let(:g4)    { new_goal(:j, :k, :l) }
    let(:goals) { [g1, g2, g3, g4]     }
    
    it 'should reject a non-tail array' do
      arrays = [
        [1,Tail.new([2,3])],
        [4],
        [1,2,3,7,UNKNOWN_TAIL],
      ]
      arrays_goals = goals[0...arrays.size]
      
      refute              arrays.all?{|array| has_tail?(array) }
      
      assert_nil          unify_headtail_with_tail(arrays, arrays_goals, [])
      
      msg = 'Wrong method called to unify [[1, *[2, 3]], [4], [1, 2, 3, 7, ...]]'
      
      assert_equal        [msg],      g1.log
      assert_equal        [msg],      g2.log
      assert_equal        [msg],      g3.log
    end
    
    it 'should unify more than two arrays that have a tail' do
      arrays = [
        [1,  Tail.new([2,3])],
        [:a, :b]/:f,
        [:c, UNKNOWN_TAIL],
        [:d, :e, UNKNOWN_TAIL]
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?{|array| has_tail?(array, false) }
      
      merged, unifications = unify_headtail_with_tail(arrays, arrays_goals, [])
      
      expected_merged = [1,2,3]
      
      expected_unifications = [
        [g3[:c], g1[1],   g3, g1],
        [g2[:a], g4[:d],  g2, g4],
        [g2[:b], g4[:e],  g2, g4],
        [g2[:a], g1[1],   g2, g1],
        [g2[:b], g1[2],   g2, g1],
        [g2[:f], [3],     g2, g1],
        [g4[:d], g1[1],   g4, g1],
        [g4[:e], g1[2],   g4, g1],
        [g3[:c], g2[:a],  g3, g2],
        [g3[:c], g4[:d],  g3, g4]
      ]
      
      assert_equal expected_merged,       merged
      assert_equal expected_unifications, unifications
    end
    
    it 'should unify unifiable arrays with different length tails' do
      arrays = [
        [1,  UNKNOWN_TAIL],
        [:a, :b, :c, :d]/:f,
        [:c, UNKNOWN_TAIL],
        [:d, 2, UNKNOWN_TAIL]
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?{|array| has_tail?(array, false) }
      
      merged, unifications = unify_headtail_with_tail(arrays, arrays_goals, [])
      
      expected_merged = [1,2,nil,nil,UNKNOWN_TAIL]
      
      expected_unifications = [
        [g3[:c], g1[1],   g3, g1],
        [g2[:a], g4[:d],  g2, g4],
        [g2[:b], g4[2],   g2, g4],
        [g2[:a], g1[1],   g2, g1],
        [g4[:d], g1[1],   g4, g1],
        [g3[:c], g2[:a],  g3, g2],
        [g3[:c], g4[:d],  g3, g4],
      ]
      
      assert_equal expected_merged,       merged
      assert_equal expected_unifications, unifications
    end
    
    it 'should not unify unifiable heads across a headtail and an array with a tail' do
      g1.instantiate :h, 1
      g2.instantiate :h, 2
      arrays = [
        [:h]/:t,
        [:h,:b]/:t,
        [:h]/:t,
        [:h]/:t,
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?{|array| has_tail?(array, false) },  'all arrays should have a tail'
      refute              arrays.map(&:headtail?).all?,                   'not all arrays should be a headtail array'
      refute              arrays.map(&:headtail?).map(&:!).all?,          'not all arrays should be an array with a tail'
      
      assert_nil          unify_headtail_with_tail(arrays, arrays_goals, []), name
      
      assert_equal [
        'Cannot unify because Goal1.1 != Goal2.2 (variable != variable)',
        'Cannot unify heads: Goal1.:h with Goal2.:h',
      ],   g1.log
      assert_equal [
        'Cannot unify because Goal1.1 != Goal2.2 (variable != variable)',
        'Cannot unify heads: Goal1.:h with Goal2.:h',
      ],   g2.log
      assert_equal [
      ],   g3.log
      assert_equal [
      ],   g4.log
    end
    
    it 'should not unify tails with different values' do
      g1.instantiate :t, [2,3]
      g2.instantiate :t, [2,4]
      g3.instantiate :t, 4
      arrays = [
        [:h]/:t,
        [:h]/:t,
        [:h,:b]/:t,
        [:h]/:t,
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?{|array| has_tail?(array, false) },  'all arrays should have a tail'
      refute              arrays.map(&:headtail?).all?,                   'not all arrays should be a headtail array'
      refute              arrays.map(&:headtail?).map(&:!).all?,          'not all arrays should be an array with a tail'
      
      assert_nil          unify_headtail_with_tail(arrays, arrays_goals, []), name
      
      assert_equal [
        'Cannot unify because Goal1.[2, 3] != Goal2.[2, 4] (variable != variable)',
        'Cannot unify headtail tails: Goal1.:t with Goal2.:t',
        'Could not unify headtail arrays: [Goal1.:h, Goal1.2, Goal1.3] with [Goal2.:h, Goal2.2, Goal2.4] with [Goal4.:h, *Goal4.:t]',
      ],   g1.log
      assert_equal [
        'Cannot unify because Goal1.[2, 3] != Goal2.[2, 4] (variable != variable)',
        'Cannot unify headtail tails: Goal1.:t with Goal2.:t',
        'Could not unify headtail arrays: [Goal1.:h, Goal1.2, Goal1.3] with [Goal2.:h, Goal2.2, Goal2.4] with [Goal4.:h, *Goal4.:t]',
      ],   g2.log
      assert_equal        [
      ],   g3.log
      assert_equal        [
        'Could not unify headtail arrays: [Goal1.:h, Goal1.2, Goal1.3] with [Goal2.:h, Goal2.2, Goal2.4] with [Goal4.:h, *Goal4.:t]',
      ],   g4.log
    end
    
    it 'should not unify variable length arrays that have been instantiatd to different lengths' do
      g1.instantiate :t, [2,3]
      g2.instantiate :t, 3
      g3.instantiate :t, [2,3,4]
      arrays = [
        [:h]/:t,
        [:h,:b]/:t,
        [:h]/:t,
        [:h]/:t,
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?{|array| has_tail?(array, false) },  'all arrays should have a tail'
      refute              arrays.map(&:headtail?).all?,                   'not all arrays should be a headtail array'
      refute              arrays.map(&:headtail?).map(&:!).all?,          'not all arrays should be an array with a tail'
      
      assert_nil      unify_headtail_with_tail(arrays, arrays_goals, []), name
      
      assert_equal [
      ], g1.log
      assert_equal [
      ], g2.log
      assert_equal [
        'Cannot unify [Goal3.:h, Goal3.2, Goal3.3, Goal3.4] because it has a different length from 3'
      ], g3.log
      assert_equal [
      ], g4.log
    end
    
    it 'should not unify incompatible tails' do
      g1.instantiate :t, [2,3]
      g2.instantiate :b, 2
      g2.instantiate :t, [3]
      g3.instantiate :t, [4]
      arrays = [
        [:h]/:t,
        [:h,:b]/:t,
        [:h,:b]/:t,
        [:h]/:t,
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?{|array| has_tail?(array, false) },  'all arrays should have a tail'
      refute              arrays.map(&:headtail?).all?,                   'not all arrays should be a headtail array'
      refute              arrays.map(&:headtail?).map(&:!).all?,          'not all arrays should be an array with a tail'
      
      assert_nil    unify_headtail_with_tail(arrays, arrays_goals, []), name
      
      assert_equal [
      ], g1.log
      assert_equal [
        'Cannot unify incompatible values: 3 with 4',
        'Cannot unify: [3] with [4]',
        #'Cannot unify: Goal2.3 with Goal3.4',
      ], g2.log
      assert_equal [
        'Cannot unify incompatible values: 3 with 4',
        'Cannot unify: [3] with [4]',
      ], g3.log
      assert_equal [
      ], g4.log
    end
    
    it 'should expand tails that overlap extended heads' do
      g1.instantiate :t, [3,3]
      g2.instantiate :b, 2
      g2.instantiate :t, [3]
      arrays = [
        [:h]/:t,
        [:h,:b]/:t,
        [:h,:b]/:t,
        [:h]/:t,
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?{|array| has_tail?(array, false) },  'all arrays should have a tail'
      refute              arrays.map(&:headtail?).all?,                   'not all arrays should be a headtail array'
      refute              arrays.map(&:headtail?).map(&:!).all?,          'not all arrays should be an array with a tail'
      
      assert_nil        unify_headtail_with_tail(arrays, arrays_goals, []), name
      
      assert_equal [
        'Cannot unify incompatible values: 3 with 2',
        'Cannot unify because Goal1.[3, 3] != [Goal2.:b, *Goal2.:t] (variable/array != array)',
        'Cannot unify tails: Goal1.:t with [Goal2.:b, *Goal2.:t]',
      ], g1.log
      assert_equal [
        'Cannot unify incompatible values: 3 with 2',
        'Cannot unify because Goal1.[3, 3] != [Goal2.:b, *Goal2.:t] (variable/array != array)',
        'Cannot unify tails: Goal1.:t with [Goal2.:b, *Goal2.:t]',
      ], g2.log
      assert_equal [
      ], g3.log
      assert_equal [
      ], g4.log
    end
    
    it 'prioritises X over Y when merging' do
      # -- atomic over known array over non-array over unknown array/tail --
      # atomic over known
      #             known array over non-array
      #                              non-array over unknown array/tail
      # atomic over                  non-array
      #                   array over                unknown array/tail
      # atomic over                                 unknown array/tail
      
      g1.instantiate :t, [1,2,3]
      arrays = [
        :h/:t,
        UNKNOWN_ARRAY,
      ]
      arrays_goals = goals[0...arrays.size]
      
      merged, unifications = unify_headtail_with_tail(arrays, arrays_goals, [])
      
      expected_merged       = [nil, 1, 2, 3]
      expected_unifications = []
      
      assert_equal expected_merged,       merged
      assert_equal expected_unifications, unifications
    end
    
  end
  
  describe '#unify_headtail_with_headtail' do
    
    let(:g1)    { new_goal(:p, :x, :y) }
    let(:g2)    { new_goal(:q, :a, :b) }
    let(:g3)    { new_goal(:r, :s, :t) }
    let(:g4)    { new_goal(:j, :k, :l) }
    let(:goals) { [g1, g2, g3, g4]     }
    
    it 'should reject a non-headtail array' do
      arrays = [
        [1,Tail.new([2,3])],
        [4],
        [7,UNKNOWN_TAIL],
      ]
      arrays_goals = goals[0...arrays.size]
      
      refute              arrays.all?(&:headtail?)
      
      assert_nil          unify_headtail_with_headtail(arrays, arrays_goals, [])
      
      msg = 'Wrong method called to unify [[1, *[2, 3]], [4], [7, ...]]'
      
      arrays_goals.each do |goal|
        assert_equal        [msg],      goal.log
      end
    end
    
    it 'should not unify unequal heads' do
      arrays = [
        [1,Tail.new([2,3])],
        [4]/:y,
        [7,UNKNOWN_TAIL],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?(&:headtail?), "arrays should all be headtails: #{arrays.reject(&:headtail?).map(&:inspect).join(' and ')}"
      
      assert_nil          unify_headtail_with_headtail(arrays, arrays_goals, [])
      
      assert_equal [
        'Cannot unify because 1 != 4 (atomic != atomic)',
        'Cannot unify headtail heads: "1 with 4"',
      ], g1.log
      assert_equal [
        'Cannot unify because 1 != 4 (atomic != atomic)',
        'Cannot unify headtail heads: "1 with 4"',
      ], g2.log
      assert_equal [
      ], g3.log
    end
    
    it 'should process more than two arrays that are a headtail' do
      arrays = [
        [1, Tail.new([2,3])],
        [:a]/:f,
        [:c, UNKNOWN_TAIL],
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?(&:headtail?)
      
      merged, unifications = unify_headtail_with_headtail(arrays, arrays_goals, [])
      
      expected_merged = [1,2,3]
      
      expected_unifications = [
        [:a, 1,             g2, g1],
        [:f, [2,3],         g2, g1],
        [:c, 1,             g3, g1],
        [:a, :c,            g2, g3],
        [:f, UNKNOWN_TAIL,  g2, g3],
      ]
      
      assert_equal expected_merged,       merged
      assert_equal expected_unifications, unifications
      
      arrays_goals.each do |goal|
        assert_equal        [],         goal.log
      end
    end
    
    it 'should unify all combinations of heads and tails' do
      arrays = [
        [:a]/:b,
        [:c]/:d,
        [:e]/:f,
        [:g]/:h,
      ]
      arrays_goals = goals[0...arrays.size]
      
      assert              arrays.all?(&:headtail?)
      
      merged, unifications = unify_headtail_with_headtail(arrays, arrays_goals, [])
      
      expected_merged = [nil, UNKNOWN_TAIL]
      
      expected_unifications = [
        [:a, :c, g1, g2],
        [:b, :d, g1, g2],
        [:a, :e, g1, g3],
        [:b, :f, g1, g3],
        [:a, :g, g1, g4],
        [:b, :h, g1, g4],
        [:c, :e, g2, g3],
        [:d, :f, g2, g3],
        [:c, :g, g2, g4],
        [:d, :h, g2, g4],
        [:e, :g, g3, g4],
        [:f, :h, g3, g4],
      ]
      
      assert_equal expected_merged,       merged
      assert_equal expected_unifications, unifications
      
      arrays_goals.each do |goal|
        assert_equal        [],         goal.log
      end
    end
    
  end
  
end
