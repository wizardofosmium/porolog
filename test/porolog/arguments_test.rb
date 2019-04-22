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
  
  describe 'Arguments' do
    
    describe '.reset' do
      
      it 'should delete/unregister all Arguments' do
        p = Predicate.new :p
        
        args1 = Arguments.new p, [1,:x,'word',[2,:y,0.3]]
        args2 = Arguments.new p, [2]
        args3 = Arguments.new p, [3,:x,:y,:z]
        
        assert_equal    'Arguments1',       args1.myid
        assert_equal    'Arguments2',       args2.myid
        assert_equal    'Arguments3',       args3.myid
        
        Arguments.reset
        
        args4 = Arguments.new p, [4,[1,2,3]]
        args5 = Arguments.new p, [5,[]]
        
        assert_equal    'Arguments-999',    args1.myid
        assert_equal    'Arguments-999',    args2.myid
        assert_equal    'Arguments-999',    args3.myid
        assert_equal    'Arguments1',       args4.myid
        assert_equal    'Arguments2',       args5.myid
        
        Arguments.reset
        
        assert_equal    'Arguments-999',    args1.myid
        assert_equal    'Arguments-999',    args2.myid
        assert_equal    'Arguments-999',    args3.myid
        assert_equal    'Arguments-999',    args4.myid
        assert_equal    'Arguments-999',    args5.myid
      end
      
    end
    
    describe '.new' do
      
      it 'should create a new Arguments' do
        predicate = Predicate.new :p
        arguments = Arguments.new predicate, [1,:x,'word',[2,:y,0.3]]
        
        assert_Arguments arguments, :p, [1,:x,'word',[2,:y,0.3]]
      end
      
    end
    
    describe '.arguments' do
      
      it 'should return all registered arguments' do
        assert_equal        0, Arguments.arguments.size
        
        predicate1 = Predicate.new :p
        arguments1 = Arguments.new predicate1, [:x,:y,:z]
        
        assert_equal        1, Arguments.arguments.size
        assert_Arguments    Arguments.arguments.last, :p, [:x,:y,:z]
        
        predicate2 = Predicate.new :q
        arguments2 = Arguments.new predicate2, [:a,:b,:c,:d]
        
        assert_equal        2, Arguments.arguments.size
        assert_Arguments    Arguments.arguments.last, :q, [:a,:b,:c,:d]
        
        assert_equal        [arguments1,arguments2],   Arguments.arguments
      end
      
    end
    
    describe '#initialize' do
      
      it 'should initialize predicate and arguments' do
        predicate = Predicate.new :p
        arguments = Arguments.new predicate, [:x,:y,:z]
        
        assert_equal  predicate,      arguments.predicate
        assert_equal  [:x,:y,:z],     arguments.arguments
      end
      
      it 'should register the arguments' do
        predicate  = Predicate.new :p
        arguments1 = Arguments.new predicate, [:x]
        arguments2 = Arguments.new predicate, [:x,:y]
        arguments3 = Arguments.new predicate, [:x,:y,:z]
        
        assert_equal  [
          arguments1,
          arguments2,
          arguments3,
        ],      Arguments.arguments
      end
      
    end
    
    describe '#myid' do
      
      it 'should return its class and index as a String' do
        predicate = Predicate.new :p
        arguments1 = Arguments.new predicate, [:x]
        arguments2 = Arguments.new predicate, [:x,:y]
        arguments3 = Arguments.new predicate, [:x,:y,:z]
        
        assert_equal  'Arguments1',     arguments1.myid
        assert_equal  'Arguments2',     arguments2.myid
        assert_equal  'Arguments3',     arguments3.myid
      end
      
      it 'should return its class and -999 as a String when deleted/reset' do
        predicate = Predicate.new :p
        arguments1 = Arguments.new predicate, [:x]
        arguments2 = Arguments.new predicate, [:x,:y]
        arguments3 = Arguments.new predicate, [:x,:y,:z]
        
        Arguments.reset
        
        assert_equal  'Arguments-999',  arguments1.myid
        assert_equal  'Arguments-999',  arguments2.myid
        assert_equal  'Arguments-999',  arguments3.myid
      end
      
    end
    
    describe '#inspect' do
      
      it 'should show the predicate and arguments' do
        predicate1 = Predicate.new :p
        predicate2 = Predicate.new :q
        predicate3 = Predicate.new :generic
        arguments1 = Arguments.new predicate1, [:x]
        arguments2 = Arguments.new predicate2, [:list, [1,2,3]]
        arguments3 = Arguments.new predicate3, [:a,:b,:c]
        
        assert_equal  'p(:x)',                  arguments1.inspect
        assert_equal  'q(:list,[1, 2, 3])',     arguments2.inspect
        assert_equal  'generic(:a,:b,:c)',      arguments3.inspect
      end
      
    end
    
    describe '#fact!' do
      
      it 'should create a fact for its predicate' do
        predicate1 = Predicate.new :predicate1
        arguments1 = predicate1.(1,'a',0.1)
        
        arguments1.fact!
        
        assert_equal '[  predicate1(1,"a",0.1):- true]', predicate1.rules.inspect
      end
      
    end
    
    describe '#falicy!' do
      
      it 'should create a falicy for its predicate' do
        predicate1 = Predicate.new :predicate1
        arguments1 = predicate1.(1,'a',0.1)
        
        arguments1.falicy!
        
        assert_equal '[  predicate1(1,"a",0.1):- false]', predicate1.rules.inspect
      end
      
    end
    
    describe '#cut_fact!' do
      
      it 'should create a fact for its predicate and terminate solving the goal' do
        predicate1 = Predicate.new :predicate1
        arguments1 = predicate1.(1,'a',0.1)
        
        arguments1.cut_fact!
        
        assert_equal '[  predicate1(1,"a",0.1):- [:CUT, true]]', predicate1.rules.inspect
      end
      
    end
    
    describe '#cut_falicy!' do
      
      it 'should create a falicy for its predicate and terminate solving the goal' do
        predicate1 = Predicate.new :predicate1
        arguments1 = predicate1.(1,'a',0.1)
        
        arguments1.cut_falicy!
        
        assert_equal '[  predicate1(1,"a",0.1):- [:CUT, false]]', predicate1.rules.inspect
      end
      
    end
    
    describe '#<<' do
      
      it 'should create a rule for its predicate' do
        predicate1 = Predicate.new :predicate1
        arguments1 = predicate1.(1,'a',0.1)
        
        arguments1 << [
          1,2,3
        ]
        
        assert_equal '[  predicate1(1,"a",0.1):- [1, 2, 3]]', predicate1.rules.inspect
      end
      
    end
    
    describe '#evaluates' do
      
      it 'should add a block as a rule to its predicate' do
        predicate1 = Predicate.new :predicate1
        arguments1 = predicate1.(1,'a',0.1)
        
        line = __LINE__ ; arguments2 = arguments1.evaluates do |*args|
          $stderr.puts "args = #{args.inspect}"
        end
        
        assert_instance_of  Arguments,  arguments2
        
        part1 = "[  predicate1(1,\"a\",0.1):- #<Proc:0x"
        part2 = "@#{__FILE__}:#{line}>]"
        
        matcher = Regexp.new(
          '\A' +
          Regexp.escape(part1) +
          '[[:xdigit:]]+' +
          Regexp.escape(part2) +
          '\Z'
        )
        assert_match matcher, predicate1.rules.inspect
      end
    end
    
    describe '#variables' do
      
      it 'should find variable arguments' do
        skip 'until CoreExt added'
        
        predicate1 = Predicate.new :alpha
        arguments1 = predicate1.(1,'a',0.1,:a,2.2,:b,'b',:C,1234)
        variables1 = arguments1.variables
        
        assert_equal  [:a,:b,:C], variables1
      end
      
      it 'should find nested variable arguments' do
        skip 'until CoreExt added'
        
        predicate1 = Predicate.new :alpha
        predicate2 = Predicate.new :bravo
        
        arguments = predicate1.(1,'a',0.1,:a,predicate2.(:P,4,:Q),2.2,:b,'b',:C,1234)
        variables = arguments.variables
        
        assert_equal  [:a,:P,:Q,:b,:C], variables
      end
      
      it 'should find embedded variable arguments' do
        skip 'until CoreExt added'
        
        predicate1 = Predicate.new :alpha
        predicate2 = Predicate.new :bravo
        
        arguments = predicate1.(1,[:e1],'a',:h/:t,0.1,:a,predicate2.(:P,[6,:r,8]/predicate2.([:z]),4,:Q),2.2,:b,'b',:C,1234)
        variables = arguments.variables
        
        assert_equal  [:e1,:h,:t,:a,:P,:r,:z,:Q,:b,:C], variables
      end
      
    end
    
    describe '#goal' do
      
      it 'should return a new goal for solving the arguments' do
        skip 'until Goal added'
        
        predicate1 = Predicate.new :alpha
        arguments1 = predicate1.(1,'a',0.1,:a,2.2,:b,'b',:C,1234)
        
        goal = arguments1.goal
        
        assert_instance_of  Goal,         goal
        assert_equal        arguments1,   goal.arguments
      end
      
    end
    
    describe '#solutions' do
      
      it 'should memoize solutions' do
        skip 'until Goal added'
        # TODO: it 'should memoize solutions' do
      end
      
    end
    
    describe '#solve' do
      
      it 'should unify and solve a simple predicate' do
        skip 'until Goal added'
        
        alpha = Predicate.new :alpha
        args1 = Arguments.new alpha, [1,2]
        args2 = Arguments.new alpha, [:p,:q]
        
        args1.fact!
        
        solutions = args2.solve
        
        assert_equal  [{ p: 1, q: 2 }],   solutions
      end
      
      it 'should unify and solve a simple predicate with multiple solutions' do
        skip 'until Goal added'
        
        predicate :alpha
        
        alpha(1,2).fact!
        alpha(3,4).fact!
        
        solutions = alpha(:p,:q).solve
        
        assert_equal  [
          { p: 1, q: 2 },
          { p: 3, q: 4 },
        ],solutions
      end
      
      it 'should unify and solve a simple predicate with multiple solutions involving a head and tail' do
        skip 'until Goal added'
        
        predicate :alpha
        
        alpha([1,2,3]).fact!
        alpha([3,4,5]).fact!
        
        solutions = alpha(:p/:q).solve
        
        assert_equal  [
          { p: 1, q: [2,3] },
          { p: 3, q: [4,5] },
        ],solutions
      end
      
      it 'should unify and solve a basic predicate' do
        skip 'until Goal added'
        
        predicate :likes

        likes('mary','food').fact!
        likes('mary','wine').fact!
        likes('john','wine').fact!
        likes('john','mary').fact!

        assert_equal  true,   likes('mary','food').valid? 
        assert_equal  true,   likes('john','wine').valid? 
        assert_equal  false,  likes('john','food').valid?

        solutions = likes(:who,:what).solve
        
        assert_equal  [
          { who: 'mary', what: 'food' },
          { who: 'mary', what: 'wine' },
          { who: 'john', what: 'wine' },
          { who: 'john', what: 'mary' },
        ],solutions
      end
      
      it 'should unify and solve a deeper predicate' do
        skip 'until Goal added'
        
        predicate :male, :female, :parent

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
        
        predicate :mother, :father, :sibling, :isnt

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
        skip 'until Goal added'
        
        predicate :alpha, :beta, :gamma
        
        gamma([1,2]).fact!
        gamma([2,3]).fact!
        
        gamma([:h/:t]) << [
          gamma(:h),
          gamma(:t),
        ]
        
        alpha(:l) << [
          gamma(:l)
        ]
        
        solutions = alpha(:p/:q).solve
        
        assert_equal  [
          { p: 1, q: 2 },
          { p: 2, q: 3 },
        ],solutions
      end
      
      it 'should call a builtin predicate' do
        skip 'until StandardPredicates added'
        
        predicate :callwrite
        
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
        skip 'until StandardPredicates added'
        
        predicate :passon, :copy

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
      
      it 'should pass on instantiations between goals' do
        skip 'until StandardPredicates added'
        
        predicate :count
        
        count(1) << [
          write("1: END\n"),
          :CUT
        ]
        count(:N) << [
          write("N = ",:N),
          is(:M,:N){|n| n - 1 },
          write(" M = ",:M,"\n"),
          count(:M),
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
        skip 'until StandardPredicates added'
        
        predicate :move

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
        skip 'until Goal added'
        
        predicate :size

        size([],0).cut_fact!
        size(:H/:T,:N) << [
          size(:T,:NT),
          is(:N,:NT){|nt| nt + 1 },
        ]
        
        solutions = size([],:N).solve
        
        assert_equal  [
          { N: 0 }
        ],solutions
        
        solutions = size([13,17,19,23],:N).solve
        
        assert_equal  [
          { N: 4 },
        ],solutions
      end
      
      it 'should solve tower of Hanoi with list representation' do
        skip 'until StandardPredicates added and converted to list representation'
        # TODO: convert to list representation
        
        predicate :move

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
      
    end
    
    describe '#solve_for' do
      
      it 'should solve a predicate for specified variables' do
        skip 'until Goal added'
        
        predicate :alpha
        
        alpha(1,2).fact!
        
        solutions = alpha(:p,:q).solve_for(:p,:q)
        
        assert_equal [[1,2]], solutions
      end
      
      it 'should solve a predicate with multiple solutions for specified variables' do
        skip 'until Goal added'
        
        predicate :alpha
        
        alpha(1,2).fact!
        alpha(3,4).fact!
        alpha(5,6).fact!
        alpha(5,7).fact!
        
        solutions = alpha(:p,:q).solve_for(:p)
        
        assert_equal [
          [1],
          [3],
          [5],
          [5],
        ], solutions
      end
      
    end
    
    describe '#valid?' do
      
      it 'should return true when a solution is found' do
        # TODO: it 'should return true when a solution is found' do
      end
      
      it 'should return false when no solution is found' do
        # TODO: it 'should return false when no solution is found' do
      end
      
    end
    
    describe '#dup' do
      
      it 'should create a duplicate arguments for another goal' do
        skip 'until HeadTail added'
        # TODO: it 'should create a duplicate arguments for another goal' do
      end
      
    end
    
    describe '#==' do
      
      it 'should return true for Arguments with identical predicates and arguments' do
        predicate1 = Predicate.new :omega
        arguments1 = predicate1.(1,'a',0.1)
        
        predicate2 = Predicate.new :omega
        arguments2 = predicate2.(1,'a',0.1)
        
        assert    arguments1 == arguments2, 'Arguments with identical predicates and arguments should return true'
      end
      
      it 'should return false for Arguments with identical predicates and arguments' do
        predicate1 = Predicate.new :omega
        arguments1 = predicate1.(1,'a',0.1)
        
        predicate2 = Predicate.new :omega
        arguments2 = predicate2.(1,'a',0.2)
        
        refute    arguments1 == arguments2, 'Arguments with non-identical predicates and arguments should return false'
      end
      
    end
    
  end
  
end
