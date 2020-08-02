#
#   test/porolog/predicate/builtin_test.rb     - Test Suite for Porolog::Predicate::Builtin
#
#     Luis Esteban      30 July 2020
#       created
#

require_relative '../../test_helper'

describe 'Porolog' do
  
  describe 'Predicate' do
    
    describe 'Builtin' do
        
      before(:all) do
        reset
      end
      
      describe '#write' do
        
        it 'should output an atom' do
          assert_output 'hello' do
            builtin :write
            
            assert_solutions    write('hello'), [{}]
          end
        end
        
        it 'should output an integer' do
          assert_output '456' do
            builtin :write
            
            assert_solutions    write(456), [{}]
          end
        end
        
        it 'should output an uninstantiated variable' do
          assert_output ':X' do
            builtin :write
            
            assert_solutions    write(:X), [{ X: nil }]
          end
        end
        
        it 'should output an instantiated variable' do
          assert_output '72' do
            builtin :write, :is
            predicate :inst
            
            inst(:X, :Y) << [
              is(:Y, :X) {|x| x + 4 },
              write(:Y)
            ]
            
            assert_solutions    inst(23 + 45, :Y), [{ Y: 72 }]
          end
        end
        
      end
      
      describe '#writenl' do
        
        it 'should output an atom and a new line' do
          assert_output "hello\n" do
            builtin :writenl
            
            assert_solutions    writenl('hello'), [{}]
          end
        end
        
        it 'should output an integer and a new line' do
          assert_output "456\n" do
            builtin :writenl
            
            assert_solutions    writenl(456), [{}]
          end
        end
        
        it 'should output an uninstantiated variable and a new line' do
          assert_output ":X\n" do
            builtin :writenl
            
            assert_solutions    writenl(:X), [{ X: nil }]
          end
        end
        
        it 'should output an instantiated variable and a new line' do
          assert_output "72\n" do
            builtin :writenl, :is
            predicate :inst
            
            inst(:X, :Y) << [
              is(:Y, :X) {|x| x + 4 },
              writenl(:Y)
            ]
            
            assert_solutions    inst(23 + 45, :Y), [{ Y: 72 }]
          end
        end
        
      end
      
      describe '#nl' do
        
        it 'should output a newline' do
          assert_output "\n\n\n" do
            builtin :nl
            predicate :f, :n
            
            n(1).fact!
            n(5).fact!
            n(7).fact!
            
            f() << [
              n(:X),
              nl
            ]
            
            assert_solutions    f(), [
              {},
              {},
              {},
            ]
          end
        end
        
      end
      
      describe '#is' do
        
        it 'should raise an exception when not provided with a variable' do
          builtin :is
          predicate :is_test
          
          is_test(:variable) << [
            # :nocov:
            is(6) { 6 }
            # :nocov:
          ]
          
          assert_raises NonVariableError do
            assert_solutions    is_test(6),  [{}]
          end
        end
        
        it 'should not raise an exception when provided with an instantiated variable' do
          builtin :is
          predicate :is_test
          
          is_test(:variable) << [
            is(:variable) { 6 }
          ]
          
          assert_solutions    is_test(6),  [{}]
        end
        
        it 'should call the block provided and instantiate the variable to the result of the provided block' do
          builtin :is
          predicate :is_test
          
          calls = []
          
          is_test(:variable1, :variable2) << [
            is(:variable1) {
              calls << 'first is called'
              'first'
            },
            is(:variable2) {
              calls << 'second is called'
              'second'
            }
          ]
          
          assert_solutions    is_test(:X, :Y),  [{ X: 'first', Y: 'second'}]
          assert_equal        [
            'first is called',
            'second is called',
          ], calls
        end
        
        it 'should return false when the variable cannot be instantiated' do
          builtin :is
          predicate :is_test
          
          calls = []
          
          is_test(:variable1, :variable2) << [
            is(:variable1) {
              calls << 'first is called'
              'first'
            },
            is(:variable2) {
              # :nocov:
              calls << 'second is called'
              'second'
              # :nocov:
            }
          ]
          
          assert_solutions    is_test('one', 'two'),  []
          assert_equal        [
            'first is called',
          ], calls
        end
        
      end
      
      describe '#eq' do
        
        it 'should return no solutions when given unequal values' do
          builtin :eq
          
          assert_solutions  eq([3,2,1,4], [1,2,3,4]), []
        end
        
        it 'should return a solution when given equal values' do
          builtin :eq
          
          assert_solutions  eq([1,2,3,4], [1,2,3,4]), [{}]
        end
        
        it 'should return a solution with an unbound variable when given the same unbound variable' do
          builtin :eq
          
          assert_solutions  eq(:X, :X), [{ X: nil}]
        end
        
        it 'should return no solutions when given two unbound variables' do
          builtin :eq
          
          assert_solutions  eq(:X, :Y), []
        end
        
        it 'should return one solution with unbound variables when given given two uninstantiated variables that are bound to each other' do
          builtin :eq, :is
          predicate :bind_and_eq
          
          bind_and_eq(:X, :Y) << [
            is(:X, :Y) { |y| y },
            eq(:X, :Y)
          ]
          
          assert_solutions  bind_and_eq(:X, :Y), [{ X: nil, Y: nil }]
        end
        
        it 'should return no solutions when given two uninstantiated variables that are not bound to each other' do
          builtin :eq, :is
          predicate :bind_and_eq
          
          bind_and_eq(:X, :Y) << [
            is(:X, :P) { |p| p },
            is(:Y, :Q) { |q| q },
            eq(:X, :Y)
          ]
          
          assert_solutions  bind_and_eq(:X, :Y), []
        end
        
        it 'should return no solutions when given a value and an uninstantiated variable' do
          builtin :eq
          
          assert_solutions  eq([1,2,3,4], :L), []
          assert_solutions  eq(:L, [1,2,3,4]), []
        end
        
      end
      
      describe '#is_eq' do
        
        it 'should return no solutions when given unequal values' do
          builtin :is_eq
          
          assert_solutions  is_eq([3,2,1,4], [1,2,3,4]), []
        end
        
        it 'should return a solution when given equal values' do
          builtin :is_eq
          
          assert_solutions  is_eq([1,2,3,4], [1,2,3,4]), []
        end
        
        it 'should return a solution with an unbound variable when given the same unbound variable' do
          builtin :is_eq
          
          assert_solutions  is_eq(:X, :X), [{ X: nil}]
        end
        
        it 'should return no solutions when given given two unbound variables' do
          builtin :is_eq
          
          assert_solutions  is_eq(:X, :Y), [{ X: nil, Y: nil }]
        end
        
        it 'should return one solution with unbound variables when given given two uninstantiated variables that are bound to each other' do
          builtin :is_eq, :is
          predicate :bind_and_eq
          
          bind_and_eq(:X, :Y) << [
            is(:X, :Y) { |y| y },
            is_eq(:X, :Y)
          ]
          
          assert_solutions  bind_and_eq(:X, :Y), [{ X: nil, Y: nil }]
        end
        
        it 'should return no solutions when given given two uninstantiated variables that are not bound to each other' do
          builtin :is_eq, :is
          predicate :bind_and_eq
          
          bind_and_eq(:X, :Y) << [
            is(:X, :P) { |p| p },
            is(:Y, :Q) { |q| q },
            is_eq(:X, :Y)
          ]
          
          assert_solutions  bind_and_eq(:X, :Y), [{ X: nil, Y: nil }]
        end
        
        it 'should not instantiate the right hand side when not given a left hand side variable' do
          builtin :is_eq
          
          assert_solutions  is_eq([1,2,3,4], :L), []
        end
        
        it 'should instantiate the left hand side variable' do
          builtin :is_eq
          
          assert_solutions  is_eq(:L, [1,2,3,4]), [{ L: [1,2,3,4] }]
        end
        
      end
      
      describe '#ruby' do
        
        it 'should execute ruby code' do
          builtin :ruby
          predicate :logic, :data
          
          data(1).fact!
          data(5).fact!
          data(7).cut_fact!
          data(9).fact!
          
          ruby_log = []
          
          logic(:N) << [
            ruby(:N){|goal, n|
              ruby_log << (n.type == :variable ? n.to_sym : n)
            },
            data(:N),
            ruby(:N){|goal, n|
              ruby_log << (n.type == :variable ? n.to_sym : n)
            }
          ]
          
          assert_solutions  logic(:N), [
            { N: 1 },
            { N: 5 },
            { N: 7 },
          ]
          assert_equal      [:N,1,5,7],     ruby_log
        end
        
        it 'should execute ruby code which triggers a failure' do
          builtin :ruby
          predicate :logic, :data
          
          data(1).fact!
          data(5).fact!
          data(7).cut_fact!
          data(9).fact!
          
          ruby_log = []
          
          logic(:N) << [
            ruby(:N){|goal, n|
              ruby_log << (n.type == :variable ? n.to_sym : n)
            },
            data(:N),
            ruby(:N){|goal, n|
              ruby_log << (n.type == :variable ? n.to_sym : n)
              :fail
            }
          ]
          
          assert_solutions  logic(:N), [
          ]
          assert_equal      [:N,1,5,7],     ruby_log
        end
        
      end
      
      describe '#noteq' do
        
        it 'should return no solutions when given unequal values' do
          builtin :noteq
          
          assert_solutions  noteq([3,2,1,4], [1,2,3,4]), [{}]
        end
        
        it 'should return a solution when given equal values' do
          builtin :noteq
          
          assert_solutions  noteq([1,2,3,4], [1,2,3,4]), []
        end
        
        it 'should return a solution with an unbound variable when given the same unbound variable' do
          builtin :noteq
          
          assert_solutions  noteq(:X, :X), []
        end
        
        it 'should return no solutions when given two unbound variables' do
          builtin :noteq
          
          assert_solutions  noteq(:X, :Y), [{ X: nil, Y: nil }]
        end
        
        it 'should return one solution with unbound variables when given given two uninstantiated variables that are bound to each other' do
          builtin :noteq, :is
          predicate :bind_and_noteq
          
          bind_and_noteq(:X, :Y) << [
            is(:X, :Y) { |y| y },
            noteq(:X, :Y)
          ]
          
          assert_solutions  bind_and_noteq(:X, :Y), []
        end
        
        it 'should return no solutions when given two uninstantiated variables that are not bound to each other' do
          builtin :noteq, :is
          predicate :bind_and_noteq
          
          bind_and_noteq(:X, :Y) << [
            is(:X, :P) { |p| p },
            is(:Y, :Q) { |q| q },
            noteq(:X, :Y)
          ]
          
          assert_solutions  bind_and_noteq(:X, :Y), [{ X: nil, Y: nil }]
        end
        
        it 'should return a solution when given an unbound variable' do
          builtin :noteq
          
          assert_solutions  noteq([1,2,3,4], :L), [{ L: nil }]
          assert_solutions  noteq(:L, [1,2,3,4]), [{ L: nil }]
        end
        
      end
      
      describe '#is_noteq' do
        
        it 'should return solutions without the exclusions' do
          builtin :is_noteq
          
          assert_solutions  is_noteq(:X, [1,2,3,4,5], 2, 5), [
            { X: 1, _a: [1,3,4] },
            { X: 3, _a: [1,3,4] },
            { X: 4, _a: [1,3,4] }
          ]
        end
        
        it 'should return no solutions when the exclusions are not unique' do
          builtin :is_noteq
          
          assert_solutions  is_noteq(:X, [1,2,3,4,5], 2, 5, 2), []
        end
        
        it 'should return no solutions when the target is not a variable' do
          builtin :is_noteq
          
          assert_solutions  is_noteq(7, [1,2,3,4,5], 2, 5, 2), []
        end
        
      end
      
      describe '#less' do
        
        it 'should return no solutions when given a greater value' do
          builtin :less
          
          assert_solutions  less(7, 4), []
          assert_solutions  less('h', 'b'), []
          assert_solutions  less(1.01, 1.003), []
        end
        
        it 'should return no solutions when given equal values' do
          builtin :less
          
          assert_solutions  less(4, 4), []
          assert_solutions  less('b', 'b'), []
          assert_solutions  less(1.003, 1.003), []
        end
        
        it 'should return a solution when given lesser values' do
          builtin :less
          
          assert_solutions  less(2, 4), [{}]
        end
        
        it 'should return no solutions with an unbound variable when given the same unbound variable' do
          builtin :less
          
          assert_solutions  less(:X, :X), []
        end
        
        it 'should return no solutions when given two unbound variables' do
          builtin :less
          
          assert_solutions  less(:X, :Y), []
        end
        
      end
      
      describe '#gtr' do
        
        it 'should return no solutions when given a lesser value' do
          builtin :gtr
          
          assert_solutions  gtr(4, 7), []
          assert_solutions  gtr('b', 'h'), []
          assert_solutions  gtr(1.003, 1.01), []
        end
        
        it 'should return no solutions when given equal values' do
          builtin :gtr
          
          assert_solutions  gtr(4, 4), []
          assert_solutions  gtr('b', 'b'), []
          assert_solutions  gtr(1.003, 1.003), []
        end
        
        it 'should return a solution when given greater values' do
          builtin :gtr
          
          assert_solutions  gtr(4, 2), [{}]
        end
        
        it 'should return no solutions with an unbound variable when given the same unbound variable' do
          builtin :gtr
          
          assert_solutions  gtr(:X, :X), []
        end
        
        it 'should return no solutions when given two unbound variables' do
          builtin :gtr
          
          assert_solutions  gtr(:X, :Y), []
        end
        
      end
      
      describe '#lesseq' do
        
        it 'should return no solutions when given a greater value' do
          builtin :lesseq
          
          assert_solutions  lesseq(7, 4), []
          assert_solutions  lesseq('h', 'b'), []
          assert_solutions  lesseq(1.01, 1.003), []
        end
        
        it 'should return a solution when given equal values' do
          builtin :lesseq
          
          assert_solutions  lesseq(4, 4), [{}]
          assert_solutions  lesseq('b', 'b'), [{}]
          assert_solutions  lesseq(1.003, 1.003), [{}]
        end
        
        it 'should return a solution when given lesser values' do
          builtin :lesseq
          
          assert_solutions  lesseq(2, 4), [{}]
          assert_solutions  lesseq('b', 'h'), [{}]
          assert_solutions  lesseq(1.003, 1.01), [{}]
        end
        
        it 'should return a solution with an unbound variable when given the same unbound variable' do
          builtin :lesseq
          
          assert_solutions  lesseq(:X, :X), [{ X: nil }]
        end
        
        it 'should return no solutions when given two unbound variables' do
          builtin :lesseq
          
          assert_solutions  lesseq(:X, :Y), []
        end
        
        it 'should return no solutions when given one unbound variable' do
          builtin :lesseq
          
          assert_solutions  lesseq(:X, 11), []
        end
        
      end
      
      describe '#gtreq' do
        
        it 'should return no solutions when given a lesser value' do
          builtin :gtreq
          
          assert_solutions  gtreq(4, 7), []
          assert_solutions  gtreq('b', 'h'), []
          assert_solutions  gtreq(1.003, 1.01), []
        end
        
        it 'should return a solution when given equal values' do
          builtin :gtreq
          
          assert_solutions  gtreq(4, 4), [{}]
          assert_solutions  gtreq('b', 'b'), [{}]
          assert_solutions  gtreq(1.003, 1.003), [{}]
        end
        
        it 'should return a solution when given gtreqer values' do
          builtin :gtreq
          
          assert_solutions  gtreq(4, 2), [{}]
          assert_solutions  gtreq('h', 'b'), [{}]
          assert_solutions  gtreq(1.01, 1.003), [{}]
        end
        
        it 'should return a solution with an unbound variable when given the same unbound variable' do
          builtin :gtreq
          
          assert_solutions  gtreq(:X, :X), [{ X: nil }]
        end
        
        it 'should return no solutions when given two unbound variables' do
          builtin :gtreq
          
          assert_solutions  gtreq(:X, :Y), []
        end
        
        it 'should return no solutions when given one unbound variable' do
          builtin :gtreq
          
          assert_solutions  gtreq(:X, 11), []
        end
        
      end
      
      describe '#length' do
        
        it 'should return a solution for an array and an integer' do
          builtin :length
          
          assert_solutions  length([1,2,3,4,5], 5),   [{}]
        end
        
        it 'should return no solutions for an array and an integer that do not satisy the length' do
          builtin :length
          
          assert_solutions  length([1,2,3,4,5], 2),   []
        end
        
        it 'should instaniate the length of the list' do
          builtin :length
          
          assert_solutions  length([1,2,3,4,5], :N),   [{ N: 5 }]
        end
        
        it 'should instaniate the list' do
          builtin :length
          
          assert_solutions  length(:L, 4),   [
            { L: [nil, nil, nil, nil], _a: nil, _b: nil, _c: nil, _d: nil }
          ]
        end
        
        it 'should return no solutions for a variable array and length' do
          builtin :length
          
          assert_solutions  length(:L, :N),   []
        end
        
        it 'should return no solutions for invalid types' do
          builtin :length
          
          assert_solutions  length(3, [1,2,3]),   []
        end
        
      end
      
      describe '#between' do
        
        it 'should return a solution when the value is in range' do
          builtin :between
          
          assert_solutions  between(3, 1, 10),  [{}]
        end
        
        it 'should return no solutions when the value is not in range' do
          builtin :between
          
          assert_solutions  between(-40, 1, 10),  []
        end
        
        it 'should return no solutions when given an uninstantiated variable for the range' do
          builtin :between
          
          assert_solutions  between(:X, 1, :Ten),  []
          assert_solutions  between(:X, :One, 10), []
        end
        
        it 'should return solutions for instantiating' do
          builtin :between
          
          assert_solutions  between(:X, 1, 10),  [
            { X: 1 },
            { X: 2 },
            { X: 3 },
            { X: 4 },
            { X: 5 },
            { X: 6 },
            { X: 7 },
            { X: 8 },
            { X: 9 },
            { X: 10 },
          ]
        end
        
        it 'should instantiate the minimum possible when the value is above the lower bound' do
          builtin :between
          
          assert_solutions  between(4, 1, :upper),  [{ upper: 4}]
        end
        
        it 'should instantiate the maximum possible when the value is below the upper bound' do
          builtin :between
          
          assert_solutions  between(4, :lower, 10), [{ lower: 4}]
        end
        
        it 'should return no solutions the value is below the lower bound' do
          builtin :between
          
          assert_solutions  between(-7, 1, :upper), []
        end
        
        it 'should return no solutions the value is above the upper bound' do
          builtin :between
          
          assert_solutions  between(24, :lower, 10), []
        end
        
        it 'should instantiate both bounds when given a value' do
          builtin :between
          
          assert_solutions  between(24, :lower, :upper),  [{ lower: 24, upper: 24 }]
        end
        
      end
      
      describe '#member' do
        
        it 'should return no solutions for a non-member' do
          builtin :member
          
          assert_solutions  member(5, [1,2,3,4]),   []
        end
        
        it 'should return no solutions for a non-list' do
          builtin :member
          
          assert_solutions  member(5, 5),   []
        end
        
        it 'should return a solution for a member' do
          builtin :member
          
          assert_solutions  member(3, [1,2,3,4]),   [{}]
        end
        
        it 'should return a solution for an array member' do
          builtin :member
          
          assert_solutions  member([2,3], [[1,2],[2,3],[3,4]]),   [{}]
        end
        
        it 'should return a solution for a member' do
          builtin :member
          
          assert_solutions  member(3, [1,2,3,4]),   [{}]
        end
        
        it 'should return a solution for a member' do
          builtin :member
          
          assert_solutions  member(3, [1,2,:C,4]),   [{ C: 3 }]
        end
        
        it 'should return a solution for an array member' do
          builtin :member
          
          assert_solutions  member([:A,3], [[1,2],[2,3],[3,4]]),   [{ A: 2 }]
        end
        
        it 'should return a solution for an array member' do
          builtin :member
          
          assert_solutions  member([2,3], [[1,:B],[:B,3],[3,4]]),   [{ B: 2 }]
        end
        
        it 'should return solutions for each member' do
          builtin :member
          
          assert_solutions  member(:M, [[1,2],[2,3],[3,4]]),   [
            { M: [1,2] },
            { M: [2,3] },
            { M: [3,4] },
          ]
        end
        
        it 'should return limited solutions for variables' do
          builtin :member
          
          assert_solutions  member(:M, :L, 12),   Array.new(12){|i|
            v = '_a'
            { M: nil, L: [*([nil] * (i+1)), UNKNOWN_TAIL] }.merge((1..(i * (i + 1) / 2)).map{ m = v.dup ; v.succ! ; [m.to_sym, nil] }.to_h)
          }
        end
        
      end
      
      describe '#append' do
        
        it 'should return no solutions for a non-append' do
          builtin :append
          
          assert_solutions  append([1,2,3], [4,5,6], [1,2,7,4,5,6]),   []
        end
        
        it 'should return a solution for a valid append' do
          builtin :append
          
          assert_solutions  append([1,2,3], [4,5,6], [1,2,3,4,5,6]),   [{}]
        end
        
        it 'should return no solutions for a non-list' do
          builtin :append
          
          assert_solutions  append(5, 5, 55),   []
        end
        
        it 'should return a solution for a valid append' do
          builtin :append
          
          assert_solutions  append([1,2,3], [4,5,6], [1,2,3,4,5,6]),   [{}]
        end
        
        it 'should return a solution for an array append' do
          builtin :append
          
          assert_solutions  append([[1,2],[2,3],[3,4]], [[4,5],[5,6],[6,7]], [[1,2],[2,3],[3,4],[4,5],[5,6],[6,7]]),   [{}]
        end
        
        it 'should instantiate prefix variable' do
          builtin :append
          
          assert_solutions  append(:prefix, [[4,5],[5,6],[6,7]], [[1,2],[2,3],[3,4],[4,5],[5,6],[6,7]]),   [
            { prefix: [[1, 2], [2, 3], [3, 4]] }
          ]
        end
        
        it 'should instantiate suffix variable' do
          builtin :append
          
          assert_solutions  append([[1,2],[2,3],[3,4]], :suffix, [[1,2],[2,3],[3,4],[4,5],[5,6],[6,7]]),   [
            { suffix: [[4, 5], [5, 6], [6, 7]] }
          ]
        end
        
        it 'should instantiate embedded variables' do
          builtin :append
          
          assert_solutions  append([[:A,:B],[:C,:D],[:E,:F]], [:G,:H,:I], [[1,2],[2,3],[3,4],[4,5],[5,6],[6,7]]),   [
            { A: 1, B: 2, C: 2, D: 3, E: 3, F: 4, G: [4, 5], H: [5, 6], I: [6, 7] }
          ]
        end
        
        it 'should instantiate embedded variables' do
          builtin :append
          
          assert_solutions  append([1,2,3,4], ['apple','banana','carrot'], :L),   [
            { L: [1, 2, 3, 4, 'apple', 'banana', 'carrot'] }
          ]
        end
        
        it 'should return solutions for all possible splits of a list' do
          builtin :append
          
          assert_solutions  append(:M, :L, [1,2,3,4,5]),   [
            { M: [],              L: [1, 2, 3, 4, 5] },
            { M: [1],             L: [2, 3, 4, 5] },
            { M: [1, 2],          L: [3, 4, 5] },
            { M: [1, 2, 3],       L: [4, 5] },
            { M: [1, 2, 3, 4],    L: [5] },
            { M: [1, 2, 3, 4, 5], L: [] }
          ]
        end
        
        it 'should instantiate using a head and tail for an unbound variable and an array' do
          builtin :append, :is_eq
          predicate :append_is_eq
          
          append_is_eq(:A, :B, :C) << [
            append(:A, :B, :C),
            is_eq(:A, [1, 2, 3]),
          ]
          
          assert_solutions  append_is_eq(:A, [4,5,6], :C),   [
            { A: [1, 2, 3], C: [1, 2, 3, 4, 5, 6] }
          ]
        end
        
        it 'should instantiate using a head and tail for unbound variables' do
          builtin :append, :is_eq
          predicate :append_is_eq
          
          append_is_eq(:A, :B, :C) << [
            append(:A, :B, :C),
            is_eq(:B, [4, 5, 6]),
          ]
          
          assert_solutions  append_is_eq([1,2,3], :B, :C),   [
            { B: [4, 5, 6], C: [1, 2, 3, 4, 5, 6] }
          ]
        end
        
        it 'should instantiate using a head and tail for unbound variables' do
          builtin :append, :is_eq
          predicate :append_is_eq
          
          append_is_eq(:A, :B, :C) << [
            append(:A, :B, :C),
            is_eq(:A, [1, 2, 3]),
            is_eq(:B, [4, 5, 6]),
          ]
          
          assert_solutions  append_is_eq(:A, :B, :C),   [
            { A: [1, 2, 3], B: [4, 5, 6], C: [1, 2, 3, 4, 5, 6] }
          ]
        end
        
      end
      
      describe '#permutation' do
        
        it 'returns no solutions for non-arrays' do
          builtin :permutation
          
          assert_solutions  permutation('1234', '1234'), []
        end
        
        it 'returns a solution for identical arrays without variables' do
          builtin :permutation
          
          assert_solutions  permutation([1,2,3,4], [1,2,3,4]), [{}]
        end
        
        it 'returns a solutions for rearranged arrays without variables' do
          builtin :permutation
          
          assert_solutions  permutation([3,2,1,4], [1,2,3,4]), [{}]
        end
        
        it 'returns a solution and instantiates a variable' do
          builtin :permutation
          
          assert_solutions  permutation([3,2,:A,4], [1,2,3,4]), [{ A: 1 }]
        end
        
        it 'returns solutions of permutations of instantiations' do
          builtin :permutation
          
          assert_solutions  permutation([3,2,:A,:B], [1,2,3,4]), [
            { A: 1, B: 4 },
            { A: 4, B: 1 },
          ]
        end
        
        it 'returns solutions of permutations of instantiations in the other list' do
          builtin :permutation
          
          assert_solutions  permutation([3,2,1,4], [:A,2,3,:B]), [
            { A: 1, B: 4 },
            { A: 4, B: 1 },
          ]
        end
        
        it 'infers instantiations of variables in both arrays' do
          builtin :permutation
          
          assert_solutions  permutation([3,2,:A,4], [1,2,:C,4]), [
            { A: 1, C: 3 }
          ]
        end
        
        it 'infers instantiations of variables in both arrays when they represent the same value' do
          builtin :permutation
          
          assert_solutions  permutation([:A,2,1,4], [1,2,:C,4]), [
            { A: 1, C: 1 },
            { A: 2, C: 2 },
            { A: nil, C: nil },
            { A: 4, C: 4 }
          ]
        end
        
        it 'returns all permutations of an array' do
          builtin :permutation
          
          assert_solutions  permutation([3,2,1,4], :L), [
            { L: [3, 2, 1, 4] },
            { L: [3, 2, 4, 1] },
            { L: [3, 1, 2, 4] },
            { L: [3, 1, 4, 2] },
            { L: [3, 4, 2, 1] },
            { L: [3, 4, 1, 2] },
            { L: [2, 3, 1, 4] },
            { L: [2, 3, 4, 1] },
            { L: [2, 1, 3, 4] },
            { L: [2, 1, 4, 3] },
            { L: [2, 4, 3, 1] },
            { L: [2, 4, 1, 3] },
            { L: [1, 3, 2, 4] },
            { L: [1, 3, 4, 2] },
            { L: [1, 2, 3, 4] },
            { L: [1, 2, 4, 3] },
            { L: [1, 4, 3, 2] },
            { L: [1, 4, 2, 3] },
            { L: [4, 3, 2, 1] },
            { L: [4, 3, 1, 2] },
            { L: [4, 2, 3, 1] },
            { L: [4, 2, 1, 3] },
            { L: [4, 1, 3, 2] },
            { L: [4, 1, 2, 3] }
          ], goals: 1
        end
        
        it 'returns all permutations of an array when arguments are swapped' do
          builtin :permutation
          
          assert_solutions  permutation(:L, [3,2,1,4]), [
            { L: [3, 2, 1, 4] },
            { L: [3, 2, 4, 1] },
            { L: [3, 1, 2, 4] },
            { L: [3, 1, 4, 2] },
            { L: [3, 4, 2, 1] },
            { L: [3, 4, 1, 2] },
            { L: [2, 3, 1, 4] },
            { L: [2, 3, 4, 1] },
            { L: [2, 1, 3, 4] },
            { L: [2, 1, 4, 3] },
            { L: [2, 4, 3, 1] },
            { L: [2, 4, 1, 3] },
            { L: [1, 3, 2, 4] },
            { L: [1, 3, 4, 2] },
            { L: [1, 2, 3, 4] },
            { L: [1, 2, 4, 3] },
            { L: [1, 4, 3, 2] },
            { L: [1, 4, 2, 3] },
            { L: [4, 3, 2, 1] },
            { L: [4, 3, 1, 2] },
            { L: [4, 2, 3, 1] },
            { L: [4, 2, 1, 3] },
            { L: [4, 1, 3, 2] },
            { L: [4, 1, 2, 3] }
          ], goals: 1
        end
        
      end
      
      describe '#reverse' do
        
        it 'returns no solutions for non-arrays' do
          builtin :reverse
          
          assert_solutions  reverse('1234', '1234'), []
        end
        
        it 'returns a solution for mirrored arrays without variables' do
          builtin :reverse
          
          assert_solutions  reverse([1,2,3,4], [4,3,2,1]), [{}]
        end
        
        it 'returns a solution and instantiates a variable' do
          builtin :reverse
          
          assert_solutions  reverse([4,3,:A,1], [1,2,3,4]), [{ A: 2 }]
        end
        
        it 'returns a solution and instantiates multiple variables' do
          builtin :reverse
          
          assert_solutions  reverse([4,3,:A,:B], [1,2,3,4]), [
            { A: 2, B: 1 },
          ]
        end
        
        it 'returns a solution and instantiates multiple variables in the other list' do
          builtin :reverse
          
          assert_solutions  reverse([4,3,2,1], [:A,2,3,:B]), [
            { A: 1, B: 4 },
          ]
        end
        
        it 'infers instantiations of variables in both arrays' do
          builtin :reverse
          
          assert_solutions  reverse([4,3,:A,1], [1,2,:C,4]), [
            { A: 2, C: 3 }
          ]
        end
        
        it 'infers instantiations of variables in both arrays when they represent the same value' do
          builtin :reverse
          
          assert_solutions  reverse([:A,3,2,1], [1,:A,3,:C]), [
            { A: 2, C: 2 },
          ]
        end
        
        it 'allows unbound variables' do
          builtin :reverse
          
          assert_solutions  reverse([:A,3,2,1], :L), [
            { A: nil, L: [1,2,3,nil] },
          ]
        end
        
        it 'instantiates a variable to the reversed array' do
          builtin :reverse
          
          assert_solutions  reverse([4,3,2,1], :L), [
            { L: [1, 2, 3, 4] },
          ], goals: 1
        end
        
        it 'instantiates a variable to the reversed array when arguments are swapped' do
          builtin :reverse
          
          assert_solutions  reverse(:L, [4,3,2,1]), [
            { L: [1, 2, 3, 4] },
          ], goals: 1
        end
        
        it 'returns no solutions for uninstantiated variables' do
          builtin :reverse
          
          assert_solutions  reverse(:X, :Y), [], goals: 1
        end
        
      end
      
      describe '#var' do
        
        it 'should be unsuccessful for an atom' do
          builtin :var
          
          assert_solutions  var('1234'), []
        end
        
        it 'should be successful for an uninstantiated variable' do
          builtin :var, :is_eq
          predicate :vartest
          
          vartest(:variable) << [
            var(:variable),
            is_eq(:variable, 'value')
          ]
          
          assert_solutions  vartest(:V), [{ V: 'value' }]
        end
        
        it 'should be successful for an uninstantiated bound variable' do
          builtin :var, :is_eq
          predicate :vartest
          
          vartest(:variable) << [
            is_eq(:variable, :bound),
            var(:variable),
            is_eq(:bound, 'bound')
          ]
          
          assert_solutions  vartest(:V), [{ V: 'bound' }]
        end
        
        it 'should be successful for an uninstantiated bound variable' do
          builtin :var, :is_eq
          predicate :vartest
          
          vartest(:variable) << [
            is_eq(:variable, 'instantiated'),
            var(:variable)
          ]
          
          assert_solutions  vartest(:V), []
        end
        
      end
      
      describe '#nonvar' do
        
        it 'should be successful for an atom' do
          builtin :nonvar
          
          assert_solutions  nonvar('1234'), [{}]
        end
        
        it 'should be unsuccessful for an uninstantiated variable' do
          builtin :nonvar, :is_eq
          predicate :nonvartest
          
          nonvartest(:variable) << [
            nonvar(:variable),
            is_eq(:variable, 'value')
          ]
          
          assert_solutions  nonvartest(:V), []
        end
        
        it 'should be unsuccessful for an uninstantiated bound variable' do
          builtin :nonvar, :is_eq
          predicate :nonvartest
          
          nonvartest(:variable) << [
            is_eq(:variable, :bound),
            nonvar(:variable),
            is_eq(:bound, 'bound')
          ]
          
          assert_solutions  nonvartest(:V), []
        end
        
        it 'should be unsuccessful for an uninstantiated bound variable' do
          builtin :nonvar, :is_eq
          predicate :nonvartest
          
          nonvartest(:variable) << [
            is_eq(:variable, 'instantiated'),
            nonvar(:variable)
          ]
          
          assert_solutions  nonvartest(:V), [{ V: 'instantiated' }]
        end
        
      end
      
      describe '#atom' do
        
        it 'should be satisfied with a String' do
          builtin :atom
          
          assert_solutions  atom('banana'), [{}]
        end
        
        it 'should not be satisfied with an Integer' do
          builtin :atom
          
          assert_solutions  atom(6), []
        end
        
        it 'should not be satisfied with an Array' do
          builtin :atom
          
          assert_solutions  atom([]), []
        end
        
      end
      
      describe '#atomic' do
        
        it 'should be satisfied with a String' do
          builtin :atomic
          
          assert_solutions  atomic('banana'), [{}]
        end
        
        it 'should be satisfied with an Integer' do
          builtin :atomic
          
          assert_solutions  atomic(6), [{}]
        end
        
        it 'should not be satisfied with an Array' do
          builtin :atomic
          
          assert_solutions  atomic([]), []
        end
        
        it 'should not be satisfied with an uninstantiated variable' do
          builtin :atomic
          
          assert_solutions  atomic(:X), []
        end
        
      end
      
      describe '#integer' do
        
        it 'should not be satisfied with a String' do
          builtin :integer
          
          assert_solutions  integer('banana'), []
        end
        
        it 'should be satisfied with an Integer' do
          builtin :integer
          
          assert_solutions  integer(6), [{}]
        end
        
        it 'should not be satisfied with an Array' do
          builtin :integer
          
          assert_solutions  integer([]), []
        end
        
        it 'should not be satisfied with an uninstantiated variable' do
          builtin :integer
          
          assert_solutions  integer(:X), []
        end
        
      end
      
    end
    
  end

end
