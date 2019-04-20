#
#   test/porolog/scope_test.rb     - Test Suite for Porolog::Scope
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end
  
  describe 'Scope' do
    
    it 'should already declare the default scope' do
      assert_equal        1,            Scope.scopes.size
      assert_equal        [:default],   Scope.scopes
      
      assert_scope        Scope[:default], :default, []
    end
    
    it 'should allow predicates with the same name to coexist in different scopes' do
      skip 'until Arguments added'
      
      prime = prime1 = Predicate.new :prime, :first

      prime.(2).fact!
      prime.(3).fact!
      prime.(5).fact!
      prime.(7).fact!
      prime.(11).fact!

      prime = prime2 = Predicate.new :prime, :second

      prime.('pump A').fact!
      prime.('pump B').fact!
      prime.('pump C').fact!
      prime.('pump D').fact!

      assert_equal        [:default,:first,:second],          Scope.scopes
      assert_scope        Scope[:default],  :default, []
      assert_scope        Scope[:first],    :first,   [prime1]
      assert_scope        Scope[:second],   :second,  [prime2]
      
      assert_equal        :prime,     prime1.name
      assert_equal        :prime,     prime2.name
      
      solutions = [
        { X:  2 },
        { X:  3 },
        { X:  5 },
        { X:  7 },
        { X: 11 },
      ]
      assert_equal        solutions,                prime1.(:X).solve
      
      solutions = [
        { X: 'pump A' },
        { X: 'pump B' },
        { X: 'pump C' },
        { X: 'pump D' },
      ]
      assert_equal        solutions,                prime2.(:X).solve
    end
    
    describe '.scopes' do
      
      it 'should return the names of all registered scopes' do
        Scope.new :alpha
        Scope.new :bravo
        Scope.new :carly
        
        assert_equal        4,                                    Scope.scopes.size
        assert_equal        [:default, :alpha, :bravo, :carly],   Scope.scopes
      end
      
    end
    
    describe '.reset' do
      
      it 'should clear all scopes' do
        delta = Predicate.new :delta
        
        Scope.new :alpha
        Scope.new :bravo
        Scope.new :carly
        
        assert_equal        4,                                    Scope.scopes.size
        assert_equal        [:default, :alpha, :bravo, :carly],   Scope.scopes
        
        assert_scope        Scope[:default],  :default, [delta]
        assert_scope        Scope[:alpha],    :alpha,   []
        assert_scope        Scope[:bravo],    :bravo,   []
        assert_scope        Scope[:carly],    :carly,   []
        
        Scope.reset
        
        assert_equal        1,                                    Scope.scopes.size
        assert_equal        [:default],                           Scope.scopes
        
        assert_scope        Scope[:default], :default, []
        
        assert_nil                                                Scope[:alpha]
        assert_nil                                                Scope[:bravo]
        assert_nil                                                Scope[:carly]
      end
      
      it 'should clear all scopes and start with a default scope when reset' do
        test_predicate0  = Predicate.new 'test_predicate0'
        test_predicate11 = Predicate.new 'test_predicate11', :scope1
        test_predicate12 = Predicate.new 'test_predicate12', :scope1
        test_predicate13 = Predicate.new 'test_predicate13', :scope1
        test_predicate21 = Predicate.new 'test_predicate21', :scope2
        test_predicate22 = Predicate.new 'test_predicate22', :scope2
        test_predicate23 = Predicate.new 'test_predicate23', :scope2
        
        assert_equal  [:default, :scope1, :scope2],                               Scope.scopes
        assert_equal  [test_predicate0],                                          Scope[:default].predicates
        assert_equal  [test_predicate11, test_predicate12, test_predicate13],     Scope[:scope1 ].predicates
        assert_equal  [test_predicate21, test_predicate22, test_predicate23],     Scope[:scope2 ].predicates
        
        Scope.reset
        
        test_predicate3  = Predicate.new 'test_predicate3'
        
        assert_equal  [:default],                                                 Scope.scopes
        assert_equal  [test_predicate3],                                          Scope[:default].predicates
        assert_nil                                                                Scope[:scope1 ]
        assert_nil                                                                Scope[:scope2 ]
      end
      
    end
    
    describe '.[]' do
      
      it 'should provide access to a scope by name' do
        alpha = Scope.new :alpha
        bravo = Scope.new :bravo
        carly = Scope.new :carly
        
        assert_equal  alpha,  Scope[:alpha]
        assert_equal  bravo,  Scope[:bravo]
        assert_equal  carly,  Scope[:carly]
        assert_nil            Scope[:delta]
      end
      
    end
    
    describe '.new' do
    
      it 'should not create duplicate scopes (with the same name)' do
        Scope.new :duplicate
        Scope.new :duplicate
        Scope.new :duplicate
        Scope.new :duplicate
        
        assert_equal  2,                                Scope.scopes.size
        assert_equal  1,                                Scope.scopes.count(:duplicate)
        assert_equal  [:default, :duplicate],           Scope.scopes
      end
      
    end
    
    describe '#initialize' do
      
      it 'should keep track of created scopes' do
        Scope.new :alpha
        Scope.new :bravo
        Scope.new :carly
        
        assert_equal   [:default,:alpha,:bravo,:carly], Scope.scopes
      end
      
      it 'should create scopes with no predicates' do
        scope = Scope.new('test_scope_name')
        
        assert_respond_to   scope,              :predicates
        assert_equal        [],                 scope.predicates
      end
      
    end
    
    describe '#name' do
      
      it 'should create scopes with a name attribute' do
        scope = Scope.new('test_scope_name')
        
        assert_respond_to   scope,              :name
        assert_equal        'test_scope_name',  scope.name
      end
      
    end
    
    describe '#predicates' do
      
      it 'should provide access to all the predicates of a scope' do
        test_predicate1 = Predicate.new 'test_predicate1', :test
        test_predicate2 = Predicate.new 'test_predicate2', :test
        
        assert_respond_to   Scope[:test],                         :predicates
        assert_equal        [test_predicate1,test_predicate2],    Scope[:test].predicates
      end
      
    end
    
    describe '#[]' do
      
      it 'should provide access to a predicate of a scope by its name' do
        test_predicate3 = Predicate.new 'test_predicate3', :test
        test_predicate4 = Predicate.new 'test_predicate4', :test
        
        assert_includes     Scope[:test].predicates,  test_predicate3
        
        assert_instance_of  Class,                    Scope
        assert_instance_of  Scope,                    Scope[:test]
        assert_instance_of  Predicate,                Scope[:test][:test_predicate3]
        
        assert_equal        test_predicate3,          Scope[:test][:test_predicate3]
        assert_equal        test_predicate3,          Scope[:test]['test_predicate3']
        assert_equal        test_predicate4,          Scope[:test]['test_predicate4']
      end
      
    end
    
    describe '#[]=' do
      
      it 'should raise an error when trying to put anthing but a Predicate in a Scope' do
        error = assert_raises(Porolog::Scope::NotPredicateError){
          scope = Scope.new :scope
          
          scope[:predicate] = 'predicate'
        }
        assert_equal error.message, '"predicate" is not a Predicate'
      end
      
      it 'should allow an existing predicate to be assigned to a scope' do
        test_predicate = Predicate.new 'test_predicate', :test
        
        scope = Scope.new :scope
        
        scope[:predicate] = test_predicate
        
        assert_equal        3,                                    Scope.scopes.size
        assert_equal        [:default, :test, :scope],            Scope.scopes
        
        assert_scope        Scope[:default],                      :default, []
        assert_scope        Scope[:test],                         :test,    [test_predicate]
        assert_scope        Scope[:scope],                        :scope,   [test_predicate]
      end
      
    end
    
  end

end
