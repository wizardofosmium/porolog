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
      assert_equal        1,            Porolog::Scope.scopes.size
      assert_equal        [:default],   Porolog::Scope.scopes
      
      assert_Scope        Porolog::Scope[:default], :default, []
    end
    
    it 'should allow predicates with the same name to coexist in different scopes' do
      prime = prime1 = Porolog::Predicate.new :prime, :first

      prime.(2).fact!
      prime.(3).fact!
      prime.(5).fact!
      prime.(7).fact!
      prime.(11).fact!

      prime = prime2 = Porolog::Predicate.new :prime, :second

      prime.('pump A').fact!
      prime.('pump B').fact!
      prime.('pump C').fact!
      prime.('pump D').fact!

      assert_equal        [:default,:first,:second],            Porolog::Scope.scopes
      assert_Scope        Porolog::Scope[:default],  :default,  []
      assert_Scope        Porolog::Scope[:first],    :first,    [prime1]
      assert_Scope        Porolog::Scope[:second],   :second,   [prime2]
      
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
        Porolog::Scope.new :alpha
        Porolog::Scope.new :bravo
        Porolog::Scope.new :carly
        
        assert_equal        4,                                    Porolog::Scope.scopes.size
        assert_equal        [:default, :alpha, :bravo, :carly],   Porolog::Scope.scopes
      end
      
    end
    
    describe '.reset' do
      
      it 'should clear all scopes' do
        delta = Porolog::Predicate.new :delta
        
        Porolog::Scope.new :alpha
        Porolog::Scope.new :bravo
        Porolog::Scope.new :carly
        
        assert_equal        4,                                    Porolog::Scope.scopes.size
        assert_equal        [:default, :alpha, :bravo, :carly],   Porolog::Scope.scopes
        
        assert_Scope        Porolog::Scope[:default],  :default,  [delta]
        assert_Scope        Porolog::Scope[:alpha],    :alpha,    []
        assert_Scope        Porolog::Scope[:bravo],    :bravo,    []
        assert_Scope        Porolog::Scope[:carly],    :carly,    []
        
        Porolog::Scope.reset
        
        assert_equal        1,                                    Porolog::Scope.scopes.size
        assert_equal        [:default],                           Porolog::Scope.scopes
        
        assert_Scope        Porolog::Scope[:default], :default,   []
        
        assert_nil                                                Porolog::Scope[:alpha]
        assert_nil                                                Porolog::Scope[:bravo]
        assert_nil                                                Porolog::Scope[:carly]
      end
      
      it 'should clear all scopes and start with a default scope when reset' do
        test_predicate0  = Porolog::Predicate.new 'test_predicate0'
        test_predicate11 = Porolog::Predicate.new 'test_predicate11', :scope1
        test_predicate12 = Porolog::Predicate.new 'test_predicate12', :scope1
        test_predicate13 = Porolog::Predicate.new 'test_predicate13', :scope1
        test_predicate21 = Porolog::Predicate.new 'test_predicate21', :scope2
        test_predicate22 = Porolog::Predicate.new 'test_predicate22', :scope2
        test_predicate23 = Porolog::Predicate.new 'test_predicate23', :scope2
        
        assert_equal  [:default, :scope1, :scope2],                               Porolog::Scope.scopes
        assert_equal  [test_predicate0],                                          Porolog::Scope[:default].predicates
        assert_equal  [test_predicate11, test_predicate12, test_predicate13],     Porolog::Scope[:scope1 ].predicates
        assert_equal  [test_predicate21, test_predicate22, test_predicate23],     Porolog::Scope[:scope2 ].predicates
        
        Porolog::Scope.reset
        
        test_predicate3  = Porolog::Predicate.new 'test_predicate3'
        
        assert_equal  [:default],                                                 Porolog::Scope.scopes
        assert_equal  [test_predicate3],                                          Porolog::Scope[:default].predicates
        assert_nil                                                                Porolog::Scope[:scope1 ]
        assert_nil                                                                Porolog::Scope[:scope2 ]
      end
      
    end
    
    describe '.[]' do
      
      it 'should provide access to a scope by name' do
        alpha = Porolog::Scope.new :alpha
        bravo = Porolog::Scope.new :bravo
        carly = Porolog::Scope.new :carly
        
        assert_equal  alpha,  Porolog::Scope[:alpha]
        assert_equal  bravo,  Porolog::Scope[:bravo]
        assert_equal  carly,  Porolog::Scope[:carly]
        assert_nil            Porolog::Scope[:delta]
      end
      
    end
    
    describe '.new' do
    
      it 'should not create duplicate scopes (with the same name)' do
        Porolog::Scope.new :duplicate
        Porolog::Scope.new :duplicate
        Porolog::Scope.new :duplicate
        Porolog::Scope.new :duplicate
        
        assert_equal  2,                                Porolog::Scope.scopes.size
        assert_equal  1,                                Porolog::Scope.scopes.count(:duplicate)
        assert_equal  [:default, :duplicate],           Porolog::Scope.scopes
      end
      
    end
    
    describe '#initialize' do
      
      it 'should keep track of created scopes' do
        Porolog::Scope.new :alpha
        Porolog::Scope.new :bravo
        Porolog::Scope.new :carly
        
        assert_equal   [:default,:alpha,:bravo,:carly], Porolog::Scope.scopes
      end
      
      it 'should create scopes with no predicates' do
        scope = Porolog::Scope.new('test_scope_name')
        
        assert_respond_to   scope,              :predicates
        assert_equal        [],                 scope.predicates
      end
      
    end
    
    describe '#name' do
      
      it 'should create scopes with a name attribute' do
        scope = Porolog::Scope.new('test_scope_name')
        
        assert_respond_to   scope,              :name
        assert_equal        'test_scope_name',  scope.name
      end
      
    end
    
    describe '#predicates' do
      
      it 'should provide access to all the predicates of a scope' do
        test_predicate1 = Porolog::Predicate.new 'test_predicate1', :test
        test_predicate2 = Porolog::Predicate.new 'test_predicate2', :test
        
        assert_respond_to   Porolog::Scope[:test],                :predicates
        assert_equal        [test_predicate1,test_predicate2],    Porolog::Scope[:test].predicates
      end
      
    end
    
    describe '#[]' do
      
      it 'should provide access to a predicate of a scope by its name' do
        test_predicate3 = Porolog::Predicate.new 'test_predicate3', :test
        test_predicate4 = Porolog::Predicate.new 'test_predicate4', :test
        
        assert_includes     Porolog::Scope[:test].predicates,  test_predicate3
        
        assert_instance_of  Class,                    Porolog::Scope
        assert_instance_of  Porolog::Scope,           Porolog::Scope[:test]
        assert_instance_of  Porolog::Predicate,       Porolog::Scope[:test][:test_predicate3]
        
        assert_equal        test_predicate3,          Porolog::Scope[:test][:test_predicate3]
        assert_equal        test_predicate3,          Porolog::Scope[:test]['test_predicate3']
        assert_equal        test_predicate4,          Porolog::Scope[:test]['test_predicate4']
      end
      
    end
    
    describe '#[]=' do
      
      it 'should raise an error when trying to put anthing but a Predicate in a Scope' do
        error = assert_raises(Porolog::Scope::NotPredicateError){
          scope = Porolog::Scope.new :scope
          
          scope[:predicate] = 'predicate'
        }
        assert_equal error.message, '"predicate" is not a Predicate'
      end
      
      it 'should allow an existing predicate to be assigned to a scope' do
        test_predicate = Porolog::Predicate.new 'test_predicate', :test
        
        scope = Porolog::Scope.new :scope
        
        scope[:predicate] = test_predicate
        
        assert_equal        3,                                    Porolog::Scope.scopes.size
        assert_equal        [:default, :test, :scope],            Porolog::Scope.scopes
        
        assert_Scope        Porolog::Scope[:default],             :default, []
        assert_Scope        Porolog::Scope[:test],                :test,    [test_predicate]
        assert_Scope        Porolog::Scope[:scope],               :scope,   [test_predicate]
      end
      
    end
    
  end

end
