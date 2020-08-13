#
#   test/porolog/arguments_test.rb     - Test Suite for Porolog::Arguments
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end
  
  let(:pred_name)   { :pred }
  let(:pred)        { Porolog::Predicate.new pred_name }
  let(:pred1)       { Porolog::Predicate.new :p }
  let(:pred2)       { Porolog::Predicate.new :q }
  
  describe 'Arguments' do
    
    describe '.reset' do
      
      it 'should delete/unregister all Arguments' do
        args1 = Porolog::Arguments.new pred, [1,:x,'word',[2,:y,0.3]]
        args2 = Porolog::Arguments.new pred, [2]
        args3 = Porolog::Arguments.new pred, [3,:x,:y,:z]
        
        assert_equal    'Arguments1',       args1.myid
        assert_equal    'Arguments2',       args2.myid
        assert_equal    'Arguments3',       args3.myid
        
        Porolog::Arguments.reset
        
        args4 = Porolog::Arguments.new pred, [4,[1,2,3]]
        args5 = Porolog::Arguments.new pred, [5,[]]
        
        assert_equal    'Arguments-999',    args1.myid
        assert_equal    'Arguments-999',    args2.myid
        assert_equal    'Arguments-999',    args3.myid
        assert_equal    'Arguments1',       args4.myid
        assert_equal    'Arguments2',       args5.myid
        
        Porolog::Arguments.reset
        
        assert_equal    'Arguments-999',    args1.myid
        assert_equal    'Arguments-999',    args2.myid
        assert_equal    'Arguments-999',    args3.myid
        assert_equal    'Arguments-999',    args4.myid
        assert_equal    'Arguments-999',    args5.myid
      end
      
    end
    
    describe '.new' do
      
      it 'should create a new Arguments' do
        arguments = Porolog::Arguments.new pred, [1, :x, 'word', [2, :y, 0.3]]
        
        assert_Arguments    arguments, :pred, [1, :x, 'word', [2, :y, 0.3]]
      end
      
    end
    
    describe '.arguments' do
      
      it 'should return all registered arguments' do
        # -- No Arguments --
        assert_equal        0,    Porolog::Arguments.arguments.size
        
        # -- One Arguments --
        arguments1 = Porolog::Arguments.new pred1, [:x,:y,:z]
        
        assert_equal        1,    Porolog::Arguments.arguments.size
        assert_Arguments    Porolog::Arguments.arguments.last, :p, [:x,:y,:z]
        
        # -- Two Arguments --
        arguments2 = Porolog::Arguments.new pred2, [:a,:b,:c,:d]
        
        assert_equal        2,    Porolog::Arguments.arguments.size
        assert_Arguments    Porolog::Arguments.arguments.last, :q, [:a,:b,:c,:d]
        
        
        assert_equal        [arguments1, arguments2],     Porolog::Arguments.arguments
      end
      
    end
    
    describe '#initialize' do
      
      it 'should initialize predicate and arguments' do
        arguments = Porolog::Arguments.new pred, [:x,:y,:z]
        
        assert_equal  pred,           arguments.predicate
        assert_equal  [:x,:y,:z],     arguments.arguments
      end
      
      it 'should register the arguments' do
        arguments1 = Porolog::Arguments.new pred, [:x]
        arguments2 = Porolog::Arguments.new pred, [:x,:y]
        arguments3 = Porolog::Arguments.new pred, [:x,:y,:z]
        
        assert_equal  [
          arguments1,
          arguments2,
          arguments3,
        ],      Porolog::Arguments.arguments
      end
      
    end
    
    describe '#myid' do
      
      it 'should return its class and index as a String' do
        arguments1 = Porolog::Arguments.new pred, [:x]
        arguments2 = Porolog::Arguments.new pred, [:x,:y]
        arguments3 = Porolog::Arguments.new pred, [:x,:y,:z]
        
        assert_equal  'Arguments1',     arguments1.myid
        assert_equal  'Arguments2',     arguments2.myid
        assert_equal  'Arguments3',     arguments3.myid
      end
      
      it 'should return its class and -999 as a String when deleted/reset' do
        arguments1 = Porolog::Arguments.new pred, [:x]
        arguments2 = Porolog::Arguments.new pred, [:x,:y]
        arguments3 = Porolog::Arguments.new pred, [:x,:y,:z]
        
        Porolog::Arguments.reset
        
        assert_equal  'Arguments-999',  arguments1.myid
        assert_equal  'Arguments-999',  arguments2.myid
        assert_equal  'Arguments-999',  arguments3.myid
      end
      
    end
    
    describe '#inspect' do
      
      it 'should show the predicate and arguments' do
        predicate1 = Porolog::Predicate.new :p
        predicate2 = Porolog::Predicate.new :q
        predicate3 = Porolog::Predicate.new :generic
        
        arguments1 = Porolog::Arguments.new predicate1, [:x]
        arguments2 = Porolog::Arguments.new predicate2, [:list, [1,2,3]]
        arguments3 = Porolog::Arguments.new predicate3, [:a,:b,:c]
        
        assert_equal  'p(:x)',                  arguments1.inspect
        assert_equal  'q(:list,[1, 2, 3])',     arguments2.inspect
        assert_equal  'generic(:a,:b,:c)',      arguments3.inspect
      end
      
    end
    
    describe '#fact!' do
      
      it 'should create a fact for its predicate' do
        arguments1 = pred.(1,'a',0.1)
        
        arguments1.fact!
        
        assert_equal '[  pred(1,"a",0.1):- true]', pred.rules.inspect
      end
      
    end
    
    describe '#fallacy!' do
      
      it 'should create a fallacy for its predicate' do
        arguments1 = pred.(1,'a',0.1)
        
        arguments1.fallacy!
        
        assert_equal '[  pred(1,"a",0.1):- false]', pred.rules.inspect
      end
      
    end
    
    describe '#cut_fact!' do
      
      it 'should create a fact for its predicate and terminate solving the goal' do
        arguments1 = pred.(1,'a',0.1)
        
        arguments1.cut_fact!
        
        assert_equal '[  pred(1,"a",0.1):- [:CUT, true]]', pred.rules.inspect
      end
      
    end
    
    describe '#cut_fallacy!' do
      
      it 'should create a fallacy for its predicate and terminate solving the goal' do
        arguments1 = pred.(1,'a',0.1)
        
        arguments1.cut_fallacy!
        
        assert_equal '[  pred(1,"a",0.1):- [:CUT, false]]', pred.rules.inspect
      end
      
    end
    
    describe '#<<' do
      
      it 'should create a rule for its predicate' do
        arguments1 = pred.(1,'a',0.1)
        
        arguments1 << [
          pred1.(1,2,3)
        ]
        
        assert_equal '[  pred(1,"a",0.1):- [p(1,2,3)]]', pred.rules.inspect
      end
      
    end
    
    describe '#evaluates' do
      
      it 'should add a block as a rule to its predicate' do
        arguments1 = pred.(1,'a',0.1)
        
        line = __LINE__ ; arguments2 = arguments1.evaluates do |*args|
          #:nocov:
          $stderr.puts "args = #{args.inspect}"
          #:nocov:
        end
        
        assert_instance_of  Porolog::Arguments,  arguments2
        
        part1 = "[  pred(1,\"a\",0.1):- #<Proc:0x"
        part2 = "@#{__FILE__}:#{line}>]"
        
        matcher = Regexp.new(
          '\A' +
          Regexp.escape(part1) +
          '[[:xdigit:]]+' +
          Regexp.escape(part2) +
          '\Z'
        )
        assert_match matcher, pred.rules.inspect
      end
    end
    
    describe '#variables' do
      
      it 'should find variable arguments' do
        arguments1 = pred.(1,'a',0.1,:a,2.2,:b,'b',:C,1234)
        variables1 = arguments1.variables
        
        assert_equal  [:a,:b,:C], variables1
      end
      
      it 'should find nested variable arguments' do
        arguments = pred1.(1, 'a', 0.1, :a, pred2.(:P, 4, :Q), 2.2, :b, 'b', :C, 1234)
        variables = arguments.variables
        
        assert_equal  [:a,:P,:Q,:b,:C], variables
      end
      
      it 'should find embedded variable arguments' do
        arguments = pred1.(1, [:e1], 'a', :h/:t, 0.1, :a, pred2.(:P, [6, :r, 8]/pred2.([:z]), 4, :Q), 2.2, :b, 'b', :C, 1234)
        variables = arguments.variables
        
        assert_equal  [:e1,:h,:t,:a,:P,:r,:z,:Q,:b,:C], variables
      end
      
    end
    
    describe '#goal' do
      
      it 'should return a new goal for solving the arguments' do
        arguments1 = pred1.(1, 'a', 0.1, :a, 2.2, :b, 'b', :C, 1234)
        
        goal = arguments1.goal
        
        assert_Goal         goal,         :p, [1, 'a', 0.1, :a, 2.2, :b, 'b', :C, 1234]
      end
      
    end
    
    describe '#solutions' do
      
      it 'should memoize solutions' do
        args1 = Porolog::Arguments.new pred, [1,2]
        args2 = Porolog::Arguments.new pred, [:p,:q]
        
        args1.fact!
        
        solve_spy = Spy.on(args2, :solve).and_call_through
        
        assert_equal  [{ p: 1, q: 2 }],   args2.solutions
        assert_equal  [{ p: 1, q: 2 }],   args2.solutions
        assert_equal  [{ p: 1, q: 2 }],   args2.solutions
        assert_equal  [{ p: 1, q: 2 }],   args2.solutions
        assert_equal  [{ p: 1, q: 2 }],   args2.solutions
        
        assert_equal  1,                  solve_spy.calls.size
      end
      
    end
    
    describe '#solve' do
      
      it 'should unify and solve a simple predicate' do
        args1 = Porolog::Arguments.new pred, [1,2]
        args2 = Porolog::Arguments.new pred, [:p,:q]
        
        args1.fact!
        
        solutions = args2.solve
        
        assert_equal  [{ p: 1, q: 2 }],   solutions
      end
      
      it 'should unify and solve a simple predicate with multiple solutions' do
        Porolog::predicate :simple
        
        simple(1,2).fact!
        simple(3,4).fact!
        
        solutions = simple(:p,:q).solve
        
        assert_equal  [
          { p: 1, q: 2 },
          { p: 3, q: 4 },
        ],solutions
      end
      
      it 'should unify and solve a simple predicate with multiple solutions involving a head and tail' do
        Porolog::predicate :basic
        
        basic([1,2,3]).fact!
        basic([3,4,5]).fact!
        
        solutions = basic(:p/:q).solve
        
        assert_equal  [
          { p: 1, q: [2,3] },
          { p: 3, q: [4,5] },
        ],solutions
      end
      
      it 'should unify and solve a normal predicate' do
        Porolog::predicate :likes

        likes('mary','food').fact!
        likes('mary','wine').fact!
        likes('john','wine').fact!
        likes('john','mary').fact!

        assert_equal  true,   likes('mary','food').valid? 
        assert_equal  true,   likes('john','wine').valid? 
        assert_equal  false,  likes('john','food').valid?

        solutions = likes(:who,:what).solve
        
        assert_equal [
          { who: 'mary', what: 'food' },
          { who: 'mary', what: 'wine' },
          { who: 'john', what: 'wine' },
          { who: 'john', what: 'mary' },
        ], solutions
      end
      
      it 'should allow isnt to be defined' do
        Porolog::predicate :isnt
        
        isnt(:A,:A) << [:CUT, false]
        isnt(:A,:B) << [:CUT, true]
        
        solutions = isnt(123,123).solve
        assert_equal [], solutions
        
        solutions = isnt(123,124).solve
        assert_equal [{}], solutions
      end
      
      it 'should unify and solve a deeper predicate' do
        Porolog::predicate :male, :female, :parent

        male('james1').fact!
        male('charles1').fact!
        male('charles2').fact!
        male('james2').fact!
        male('george1').fact!

        female('catherine').fact!
        female('elizabeth').fact!
        female('sophia').fact!

        parent('charles1', 'james1').fact!
        parent('elizabeth', 'james1').fact!
        parent('charles2', 'charles1').fact!
        parent('catherine', 'charles1').fact!
        parent('james2', 'charles1').fact!
        parent('sophia', 'elizabeth').fact!
        parent('george1', 'sophia').fact!

        assert_equal  false,  parent('charles1', 'george1').valid?
        
        solutions = parent('charles1', :X).solve
        
        assert_equal  [
          { X: 'james1' }
        ], solutions
        
        solutions = parent(:X, 'charles1').solve
        
        assert_equal  [
          { X: 'charles2' },
          { X: 'catherine' },
          { X: 'james2' },
        ], solutions
        
        
        Porolog::predicate :mother, :father, :sibling, :isnt

        mother(:X,:M) << [
          parent(:X,:M),
          female(:M)
        ]

        father(:X,:F) << [
          parent(:X,:F),
          male(:F)
        ]

        isnt(:A,:A) << [:CUT, false]
        isnt(:A,:B) << [:CUT, true]

        sibling(:X,:Y) << [
          parent(:X,:P),
          parent(:Y,:P),
          isnt(:X,:Y)
        ]
        
        solutions = mother(:child, :mother).solve
        
        assert_equal  [
          { child: 'sophia',    mother: 'elizabeth' },
          { child: 'george1',   mother: 'sophia'    },
        ], solutions
        
        solutions = father(:child, :father).solve
        
        assert_equal  [
          { child: 'charles1',  father: 'james1'  },
          { child: 'elizabeth', father: 'james1'  },
          { child: 'charles2',  father: 'charles1'},
          { child: 'catherine', father: 'charles1'},
          { child: 'james2',    father: 'charles1'}
        ], solutions
        
        solutions = sibling(:s1, :s2).solve
        
        assert_equal  [
          { s1: 'charles1',   s2: 'elizabeth' },
          { s1: 'elizabeth',  s2: 'charles1'  },
          { s1: 'charles2',   s2: 'catherine' },
          { s1: 'charles2',   s2: 'james2'    },
          { s1: 'catherine',  s2: 'charles2'  },
          { s1: 'catherine',  s2: 'james2'    },
          { s1: 'james2',     s2: 'charles2'  },
          { s1: 'james2',     s2: 'catherine' }
        ], solutions
      end
      
      it 'should unify and solve a predicate involving a head and tail' do
        Porolog::predicate :join, :split, :head, :tail
        
        head(1).fact!
        head(4).fact!
        tail([2,3]).fact!
        tail([5,6]).fact!
        
        split(:h/:t) << [
          head(:h),
          tail(:t),
        ]
        
        join(:l) << [
          split(:l)
        ]
        
        solutions = join(:l).solve
        
        assert_equal  [
          { l: [1,2,3] },
          { l: [1,5,6] },
          { l: [4,2,3] },
          { l: [4,5,6] },
        ],solutions
        
        solutions = join(:p/:q).solve
        
        assert_equal  [
          { p: 1, q: [2,3] },
          { p: 1, q: [5,6] },
          { p: 4, q: [2,3] },
          { p: 4, q: [5,6] },
        ],solutions
      end
      
      it 'should call a builtin predicate' do
        Porolog::builtin :write
        Porolog::predicate :callwrite
        
        callwrite(:MESSAGE) << [
          write(:MESSAGE,"\n")
        ]
        
        assert_output "hello world\n" do
          solutions = callwrite('hello world').solve
          
          assert_equal  [
            {},
          ],solutions
        end
      end
      
      it 'should pass on instantiations between goals' do
        Porolog::builtin :write
        Porolog::predicate :passon, :copy

        copy(:A,:A).fact!

        passon(1,:A) << [
          write('1: A=',:A,"\n"),
        ]
        passon(5,:E) << [
          write('5: E=',:E,"\n"),
          copy(:E,:F),
          write('5: F=',:F,"\n"),
          passon(1,:F)
        ]

        assert_output "5: E=passed on\n5: F=passed on\n1: A=passed on\n" do
          solutions = passon(5,'passed on').solve
          
          assert_equal  [
            {},
          ],solutions
        end
      end
      
      it 'should implement simple recursion' do
        Porolog::builtin :write, :is, :gtr
        Porolog::predicate :count
        
        count(1) << [
          write("1: END\n"),
          :CUT
        ]
        count(:N) << [
          gtr(:N,1),
          write("N = ",:N),
          is(:M,:N){|n| n - 1 },
          write(" M = ",:M,"\n"),
          count(:M),
          :CUT
        ]
        
        expected_output = [
          'N = 10 M = 9',
          'N = 9 M = 8',
          'N = 8 M = 7',
          'N = 7 M = 6',
          'N = 6 M = 5',
          'N = 5 M = 4',
          'N = 4 M = 3',
          'N = 3 M = 2',
          'N = 2 M = 1',
          '1: END',
        ].map{|s| "#{s}\n" }.join
        
        assert_output expected_output do
          solutions = count(10).solve
          
          assert_equal  [
            {},
          ],solutions
        end
      end
      
      it 'should solve tower of Hanoi' do
        Porolog::builtin :gtr, :is, :write
        Porolog::predicate :move

        move(1,:X,:Y,:Z) << [
          write('Move top disk from ', :X, ' to ', :Y, "\n"),
        ]
        move(:N,:X,:Y,:Z) << [
          gtr(:N,1),
          is(:M,:N){|n| n - 1 },
          move(:M,:X,:Z,:Y), 
          move(1,:X,:Y,:Q), 
          move(:M,:Z,:Y,:X),
        ]
        
        expected_output = [
          'Move top disk from left to center',
          'Move top disk from left to right',
          'Move top disk from center to right',
          'Move top disk from left to center',
          'Move top disk from right to left',
          'Move top disk from right to center',
          'Move top disk from left to center',
          'Move top disk from left to right',
          'Move top disk from center to right',
          'Move top disk from center to left',
          'Move top disk from right to left',
          'Move top disk from center to right',
          'Move top disk from left to center',
          'Move top disk from left to right',
          'Move top disk from center to right',
        ].map{|s| "#{s}\n" }.join
        
        assert_output expected_output do
          solutions = move(4,'left','right','center').solve
          
          assert_equal  [
            {},
          ],solutions
        end
      end
      
      it 'should solve a peeling off predicate' do
        Porolog::builtin :is
        Porolog::predicate :peel

        peel([],0).cut_fact!
        peel(:H/:T,:N) << [
          peel(:T,:NT),
          is(:N,:NT){|nt| nt + 1 },
        ]
        
        solutions = peel([],:N).solve
        
        assert_equal  [
          { N: 0 }
        ],solutions
        
        solutions = peel([13,17,19,23],:N).solve
        
        assert_equal  [
          { N: 4 },
        ],solutions
      end
      
      it 'should solve tower of Hanoi with list representation' do
        # TODO: convert to list representation
        
        Porolog::builtin :gtr, :is, :append, :write
        Porolog::predicate :tower, :move
        
        tower(1, :X, :Y, :Z, [[:X,:Z]]).fact!
        tower(:N, :X, :Y, :Z, :S) << [
          gtr(:N,1),
          is(:M,:N){|n| n - 1 },
          tower(:M, :X, :Z, :Y, :S1), 
          tower( 1, :X, :Y, :Z, :S2), 
          tower(:M, :Y, :X, :Z, :S3),
          append(:S1,  :S2, :S12),
          append(:S12, :S3, :S),
        ]
        
        solutions = tower(3, 'left', 'middle', 'right', :moves).solve
        
        expected_solutions = [
          {
            moves: [
              ['left',   'right'],
              ['left',   'middle'],
              ['right',  'middle'],
              ['left',   'right'],
              ['middle', 'left'],
              ['middle', 'right'],
              ['left',   'right']
            ]
          }
        ]
        
        assert_equal  expected_solutions, solutions

        solutions = tower(4, 'left', 'middle', 'right', :moves).solve
        
        expected_solutions = [
          {
            moves: [
              ['left',    'middle'],
              ['left',    'right'],
              ['middle',  'right'],
              ['left',    'middle'],
              ['right',   'left'],
              ['right',   'middle'],
              ['left',    'middle'],
              ['left',    'right'],
              ['middle',  'right'],
              ['middle',  'left'],
              ['right',   'left'],
              ['middle',  'right'],
              ['left',    'middle'],
              ['left',    'right'],
              ['middle',  'right']
            ]
          }
        ]
        
        assert_equal  expected_solutions, solutions
      end
      
    end
    
    describe '#solve_for' do
      
      it 'should solve a predicate for specified variables' do
        Porolog::predicate :alpha
        
        alpha(1,2).fact!
        
        solutions = alpha(:p,:q).solve_for(:q,:p)
        
        assert_equal [[2,1]], solutions
      end
      
      it 'should solve a predicate for a specified variable' do
        Porolog::predicate :alpha
        
        alpha(1,2).fact!
        alpha(3,5).fact!
        
        solutions = alpha(:p,:q).solve_for(:q)
        
        assert_equal [2,5], solutions
      end
      
      it 'should solve a predicate with multiple solutions for specified variables' do
        Porolog::predicate :alpha
        
        alpha(1,2).fact!
        alpha(3,4).fact!
        alpha(5,6).fact!
        alpha(5,7).fact!
        
        solutions = alpha(:p,:q).solve_for(:p)
        
        assert_equal [1,3,5,5], solutions
      end
      
    end
    
    describe '#valid?' do
      
      it 'should return true when a solution is found' do
        Porolog::predicate :f
        
        f(3).fact!
        
        assert    f(3).valid?, name
      end
      
      it 'should return false when no solution is found' do
        Porolog::predicate :f
        
        f(1).fact!
        f(2).fact!
        f(4).fact!
        f(5).fact!
        
        refute    f(3).valid?, name
      end
      
      it 'should return false when a fallacy is found' do
        Porolog::predicate :f
        
        f(3).fallacy!
        
        refute    f(3).valid?, name
      end
      
    end
    
    describe '#dup' do
      
      let(:args1) { pred.(1,'a',0.1,:a,2.2,:b,'b',:C,1234) }
      let(:goal)  { args1.goal }
      let(:args2) { args1.dup(goal) }
      
      it 'should create a new Arguments' do
        assert_Arguments  args1, :pred, [1,'a',0.1,:a,2.2,:b,'b',:C,1234]
        
        refute_equal      args2.__id__, args1.__id__
      end
      
      it 'should variablise the arguments for the goal' do
        assert_Arguments  args2, :pred, [1, 'a', 0.1, goal.variable(:a), 2.2, goal.variable(:b), 'b', goal.variable(:C), 1234]
      end
      
    end
    
    describe '#==' do
      
      it 'should return true for Arguments with identical predicates and arguments' do
        predicate1 = Porolog::Predicate.new :omega
        arguments1 = predicate1.(1,'a',0.1)
        
        predicate2 = Porolog::Predicate.new :omega
        arguments2 = predicate2.(1,'a',0.1)
        
        assert    arguments1 == arguments2, 'Arguments with identical predicates and arguments should return true'
      end
      
      it 'should return false for Arguments with non-identical arguments' do
        predicate1 = Porolog::Predicate.new :omega
        arguments1 = predicate1.(1,'a',0.1)
        
        predicate2 = Porolog::Predicate.new :omega
        arguments2 = predicate2.(1,'a',0.2)
        
        refute    arguments1 == arguments2, 'Arguments with non-identical arguments should return false'
      end
      
      it 'should return false for Arguments with non-identical predicates' do
        predicate1 = Porolog::Predicate.new :omega
        arguments1 = predicate1.(1,'a',0.1)
        
        predicate2 = Porolog::Predicate.new :omegb
        arguments2 = predicate2.(1,'a',0.1)
        
        refute    arguments1 == arguments2, 'Arguments with non-identical predicates should return false'
      end
      
    end
    
  end
  
end
