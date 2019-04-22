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
  
  describe '#predicate' do
    
    it 'should create a Predicate' do
      assert_equal    0,        Scope[:default].predicates.size
      
      single_predicate = predicate :single
      
      assert_equal      1,                Scope[:default].predicates.size
      assert_equal      :single,          Scope[:default].predicates.first.name
      assert_Predicate  single_predicate, :single, []
    end
    
    it 'should define a method to create Arguments for solving' do
      refute                    respond_to?(:delta)
      
      predicate :delta
      
      assert                    respond_to?(:delta)
      assert_Arguments          delta(1, :X, ['left','right']), :delta, [1, :X, ['left','right']]
    end
    
    it 'should create multiple Predicates' do
      assert_equal    0,        Scope[:default].predicates.size
      
      multiple_predicates = predicate :alpha, :beta, :gamma
      
      assert_equal          3,        Scope[:default].predicates.size
      assert_equal          :alpha,   Scope[:default].predicates[0].name
      assert_equal          :beta,    Scope[:default].predicates[1].name
      assert_equal          :gamma,   Scope[:default].predicates[2].name
      assert_instance_of    Array,    multiple_predicates
      assert_equal          3,        multiple_predicates.size
      assert_Predicate      multiple_predicates[0], :alpha, []
      assert_Predicate      multiple_predicates[1], :beta,  []
      assert_Predicate      multiple_predicates[2], :gamma, []
    end
    
    it 'should define multiple methods to create Arguments for solving' do
      refute                    respond_to?(:epsilon)
      refute                    respond_to?(:upsilon)
      
      predicate :epsilon, :upsilon
      
      assert                    respond_to?(:epsilon)
      assert_Arguments          epsilon(), :epsilon, []
      assert                    respond_to?(:upsilon)
      assert_Arguments          upsilon([]), :upsilon, [[]]
    end
    
  end
  
end
