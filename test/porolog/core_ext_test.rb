#
#   test/porolog/core_ext_test.rb     - Test Suite for Core Extensions
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'

describe 'Object' do
  
  let (:object1) { Object.new }
  let (:object2) { 42 }
  let (:object3) { { name: 'hello' } }
  let (:object4) { 'abc' }
  let (:object5) { 0.5 }
  
  describe '#myid' do
    
    it 'should return inspect' do
      assert_equal  object1.inspect,   object1.myid
      assert_equal  object2.inspect,   object2.myid
      assert_equal  object3.inspect,   object3.myid
      assert_equal  object4.inspect,   object4.myid
      assert_equal  object5.inspect,   object5.myid
    end
    
  end
  
  describe '#variables' do
    
    it 'should return empty array' do
      assert_equal  [],                object1.variables
      assert_equal  [],                object2.variables
      assert_equal  [],                object3.variables
      assert_equal  [],                object4.variables
      assert_equal  [],                object5.variables
    end
    
  end
  
  describe '#type' do
    
    it 'should return :atomic for atomic types' do
      assert_equal  :atomic,           object1.type
      assert_equal  :atomic,           object2.type
      assert_equal  :atomic,           object3.type
      assert_equal  :atomic,           object4.type
      assert_equal  :atomic,           object5.type
    end
    
  end
  
  describe '#/' do
    
    it 'should create an n Array with a Tail' do
      assert_Array_with_Tail    object1 / :T,     [object1], '*:T'
      assert_Array_with_Tail    [object2] / :T,   [object2], '*:T'
      #assert_Array_with_Tail    object2.tail(:T), [object2], '*:T'
      assert_Array_with_Tail    object3 / :T,     [object3], '*:T'
      assert_Array_with_Tail    object4 / :T,     [object4], '*:T'
      assert_Array_with_Tail    [object5] / :T,   [object5], '*:T'
      #assert_Array_with_Tail    object5.tail(:T), [object5], '*:T'
    end
    
  end
  
end

describe 'Symbol' do
  
  let (:symbol1) { :alpha }
  let (:symbol2) { :_ }
  let (:symbol3) { :'with some spaces' }
  let (:symbol4) { :X }
  let (:symbol5) { :p }
  
  describe '#myid' do
    
    it 'should return inspect' do
      assert_equal  symbol1.inspect,  symbol1.myid
      assert_equal  symbol2.inspect,  symbol2.myid
      assert_equal  symbol3.inspect,  symbol3.myid
      assert_equal  symbol4.inspect,  symbol4.myid
      assert_equal  symbol5.inspect,  symbol5.myid
    end
    
  end
  
  describe '#variables' do
    
    it 'should return an array of itself' do
      assert_equal  [symbol1],        symbol1.variables
      assert_equal  [symbol2],        symbol2.variables
      assert_equal  [symbol3],        symbol3.variables
      assert_equal  [symbol4],        symbol4.variables
      assert_equal  [symbol5],        symbol5.variables
    end
    
  end
  
  describe '#type' do
    
    it 'should return :variable for symbols' do
      assert_equal  :variable,        symbol1.type
      assert_equal  :variable,        symbol2.type
      assert_equal  :variable,        symbol3.type
      assert_equal  :variable,        symbol4.type
      assert_equal  :variable,        symbol5.type
    end
    
  end
  
  describe '#/' do
    
    it 'should create a HeadTail' do
      assert_Array_with_Tail    symbol1 / :T,     [symbol1], '*:T'
      assert_Array_with_Tail    symbol2 / :T,     [symbol2], '*:T'
      assert_Array_with_Tail    symbol3 / :T,     [symbol3], '*:T'
      assert_Array_with_Tail    symbol4 / :T,     [symbol4], '*:T'
      assert_Array_with_Tail    symbol5 / :T,     [symbol5], '*:T'
    end
    
  end
  
end

describe 'Array' do
  
  let(:array1) { [1, 2, :A, 4, [:B, 6, 7, :C], 9] }
  let(:array2) { [] }
  let(:array3) { UNKNOWN_ARRAY }
  let(:array4) { [1, :B, 3, UNKNOWN_TAIL] }
  
  describe '#/' do
    
    it 'creates an Array using the slash notation with Arrays' do
      head_tail = [1] / [2,3,4,5]
      
      assert_equal              [1,2,3,4,5],      head_tail
    end
    
    it 'should combine a head Array and a tail Array when they have no variables' do
      assert_equal    [1,2,3,4,5,6],              [1,2,3] / [4,5,6]
    end
    
    it 'should combine an embedded head Array and an embedded tail Array when they have no variables' do
      assert_equal    [1,2,3,4,5,6,7,8,9],        [1,2,3] / [4,5,6] / [7,8,9]
    end
    
    it 'should create a HeadTail' do
      assert_Array_with_Tail    array1 / :T,      array1, '*:T'
      assert_Array_with_Tail    array2 / :T,      array2, '*:T'
      assert_Array_with_Tail    array3 / :T,      array3, '*:T'
      assert_Array_with_Tail    array4 / :T,      array4, '*:T'
    end
    
  end
  
  describe '#variables' do
    
    it 'should return an array of the embedded Symbols' do
      assert_equal    [:A, :B, :C],     array1.variables
      assert_equal    [],               array2.variables
      assert_equal    [],               array3.variables
      assert_equal    [:B],             array4.variables
    end
    
  end
  
  describe '#value' do
    
    it 'should return simple Arrays as is' do
      assert_equal    [1, 2, :A, 4, [:B, 6, 7, :C], 9],     array1.value
      assert_equal    [],                                   array2.value
      assert_equal    [UNKNOWN_TAIL],                       array3.value
      assert_equal    [1, :B, 3, UNKNOWN_TAIL],             array4.value
    end
    
    it 'should expand Tails that are an Array' do
      array = [1,2,3,Tail.new([7,8,9])]
      
      assert_equal    [1,2,3,7,8,9],                        array.value
    end
    
    it 'should return the value of instantiated variables in a Tail' do
      goal  = new_goal :tailor, :h, :t
      array = goal.variablise([:h, :b] / :t)
      goal.instantiate :h, [1,2,3]
      goal.instantiate :t, [7,8,9]
      
      assert_equal    [goal.value([1,2,3]),goal.variable(:b), goal.value(7), goal.value(8), goal.value(9)],     array.value
    end
    
    it 'should return the value of instantiated variables in a Tail' do
      goal  = new_goal :taylor, :head, :tail
      array = [Tail.new(goal.value([5,6,7,8]))]
      
      assert_equal    [5,6,7,8],                            array.value
    end
    
  end
  
  describe '#type' do
    
    it 'should return :variable for symbols' do
      assert_equal    :array,           array1.type
      assert_equal    :array,           array2.type
      assert_equal    :array,           array3.type
      assert_equal    :array,           array4.type
    end
    
  end
  
  describe '#head' do
    
    it 'should return the first element when no headsize is provided' do
      assert_equal    1,                array1.head
      assert_nil                        array2.head
      assert_nil                        array3.head
      assert_equal    1,                array4.head
    end
    
    it 'should return the first headsize elements' do
      assert_equal    [1, 2],           array1.head(2)
      assert_equal    [],               array2.head(2)
      assert_equal    [UNKNOWN_TAIL],   array3.head(2)
      assert_equal    [1, :B],          array4.head(2)
    end
    
    it 'should return an extended head if the tail is uninstantiated' do
      assert_equal    [1, 2, :A, 4, [:B, 6, 7, :C], 9],   array1.head(9)
      assert_equal    [],                                 array2.head(9)
      assert_equal    [UNKNOWN_TAIL],                     array3.head(9)
      assert_equal    [1, :B, 3, UNKNOWN_TAIL],           array4.head(9)
    end
    
  end
  
  describe '#tail' do
    
    it 'should return the tail after the first element when no headsize is provided' do
      assert_equal    [2, :A, 4, [:B, 6, 7, :C], 9],      array1.tail
      assert_equal    [],                                 array2.tail
      assert_equal    [UNKNOWN_TAIL],                     array3.tail
      assert_equal    [:B, 3, UNKNOWN_TAIL],              array4.tail
    end
    
    it 'should return the tail after the first headsize elements' do
      assert_equal    [:A, 4, [:B, 6, 7, :C], 9],         array1.tail(2)
      assert_equal    [],                                 array2.tail(2)
      assert_equal    [UNKNOWN_TAIL],                     array3.tail(2)
      assert_equal    [3, UNKNOWN_TAIL],                  array4.tail(2)
    end
    
    it 'should return an extended tail if the tail is uninstantiated' do
      assert_equal    [],                                 array1.tail(9)
      assert_equal    [],                                 array2.tail(9)
      assert_equal    [UNKNOWN_TAIL],                     array3.tail(9)
      assert_equal    [UNKNOWN_TAIL],                     array4.tail(9)
    end
    
  end
  
  describe '#clean' do
    
    let(:predicate1)  { Predicate.new :generic }
    let(:arguments1)  { predicate1.arguments(:m,:n) }
    let(:goal1)       { arguments1.goal }
    
    let(:array5)      { [1, 2, goal1[:A], 4, [goal1[:B], 6, 7, goal1[:C]], 9] }
    let(:array6)      { [1, goal1[:B], 3]/:T }
    let(:array7)      { [1, goal1[:B], 3]/goal1[:T] }
    
    it 'should return simple Arrays as is' do
      assert_equal    [1, 2, :A, 4, [:B, 6, 7, :C], 9],     array1.clean
      assert_equal    [],                                   array2.clean
      assert_equal    [UNKNOWN_TAIL],                       array3.clean
      assert_equal    [1, :B, 3, UNKNOWN_TAIL],             array4.clean
    end
    
    it 'should return the values of its elements with variables replaced by nil and Tails replaced by UNKNOWN_TAIL' do
      assert_equal    [1, 2, nil, 4, [nil, 6, 7, nil], 9],  array5.clean
      assert_equal    [1, nil, 3, UNKNOWN_TAIL],            array6.clean
      assert_equal    [1, nil, 3, UNKNOWN_TAIL],            array7.clean
    end
    
  end
  
end
