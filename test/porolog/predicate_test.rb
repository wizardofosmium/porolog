#
#   test/porolog/predicate_test.rb     - Test Suite for Porolog::Predicate
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end
  
  describe 'Predicate' do
    
    it 'should default to creating predicates in the default scope' do
      assert_equal    :default,     Porolog::Predicate.scope.name
      
      test = Porolog::Predicate.new 'test'
      
      assert_includes Porolog::Scope[:default].predicates, test
    end
    
    describe '.scope' do
      
      it 'should return the current scope for new predicates' do
        assert_equal  Porolog::Scope[:default],     Porolog::Predicate.scope
        
        alpha = Porolog::Predicate.new 'alpha', :new_scope
        
        assert_equal  Porolog::Scope[:default],     Porolog::Predicate.scope
        
        Porolog::Predicate.scope :new_scope
        
        assert_equal  Porolog::Scope[:new_scope],   Porolog::Predicate.scope
        
        bravo = Porolog::Predicate.new 'bravo'
        
        assert_equal  [],                           Porolog::Scope[:default  ].predicates
        assert_equal  [alpha,bravo],                Porolog::Scope[:new_scope].predicates
      end
    
      it 'should allow predicate scope to be created and set' do
        Porolog::Predicate.scope :internal
        assert_equal             :internal, Porolog::Predicate.scope.name
        
        Porolog::Predicate.new 'alpha'
        
        Porolog::Predicate.scope :external
        assert_equal             :external, Porolog::Predicate.scope.name
        
        Porolog::Predicate.new 'bravo'
        
        Porolog::Predicate.scope :internal
        assert_equal             :internal, Porolog::Predicate.scope.name
        
        Porolog::Predicate.new 'carly'
        Porolog::Predicate.new 'delta', :external
        
        assert_equal             :internal, Porolog::Predicate.scope.name
        
        assert_equal  [:alpha,:carly],      Porolog::Scope[:internal].predicates.map(&:name)
        assert_equal  [:bravo,:delta],      Porolog::Scope[:external].predicates.map(&:name)
      end
      
    end
    
    describe '.scope=' do
    
      it 'should also allow predicate scope to be assigned' do
        Porolog::Predicate.scope = :internal
        assert_equal               :internal, Porolog::Predicate.scope.name
        
        alpha = Porolog::Predicate.new 'alpha'
        
        Porolog::Predicate.scope = :external
        assert_equal               :external, Porolog::Predicate.scope.name
        
        bravo = Porolog::Predicate.new 'bravo'
        
        Porolog::Predicate.scope = :internal
        assert_equal               :internal, Porolog::Predicate.scope.name
        
        carly = Porolog::Predicate.new 'carly'
        delta = Porolog::Predicate.new 'delta', :external
        
        assert_equal               :internal, Porolog::Predicate.scope.name
        
        assert_equal  [alpha,carly],          Porolog::Scope[:internal].predicates
        assert_equal  [bravo,delta],          Porolog::Scope[:external].predicates
      end
      
    end
    
    describe '.reset' do
    
      it 'should revert to the default scope when reset' do
        Porolog::Predicate.scope = :other
        assert_equal      :other,       Porolog::Predicate.scope.name
        
        Porolog::Predicate.reset
        assert_equal      :default,     Porolog::Predicate.scope.name
        
        Porolog::Predicate.scope :temporary
        
        alpha = Porolog::Predicate.new   :alpha
        
        assert_equal    :temporary,     Porolog::Predicate.scope.name
        assert_equal    [alpha],        Porolog::Predicate.scope.predicates
        
        Porolog::Predicate.reset
        
        bravo = Porolog::Predicate.new   :bravo
        
        assert_equal    :default,       Porolog::Predicate.scope.name
        assert_equal    [bravo],        Porolog::Predicate.scope.predicates
      end
      
    end
    
    describe '.[]' do
      
      it 'should return a predicate by name' do
        alpha = Porolog::Predicate.new  :alpha
        
        assert_equal    alpha,          Porolog::Predicate[:alpha]
      end
      
    end
    
    describe '.new' do
      
      it 'should create a new predicate' do
        alpha = Porolog::Predicate.new   :alpha
        
        assert_instance_of Porolog::Predicate,   alpha
      end
      
      it 'should not create a predicate if a predicate with the same name already exists in the scope but instead return the existing one' do
        predicate1 = Porolog::Predicate.new 'predicate1', :left
        predicate2 = Porolog::Predicate.new 'predicate1', :right
        
        refute_equal  predicate1, predicate2
        
        Porolog::Predicate.scope :left
        predicate3 = Porolog::Predicate.new :predicate1
        
        assert_equal  predicate1, predicate3
      end
      
    end
    
    describe '#initialize' do
    
      it 'can create predicates in different scopes' do
        left  = Porolog::Scope.new :left
        #right = Scope.new :right       # Not explicitly creating scope :right
        
        assert_equal    left,           Porolog::Predicate.scope(:left)
        assert_equal    :left,          Porolog::Predicate.scope.name
        
        left_test = Porolog::Predicate.new 'left_test'
        
        assert_equal    :left,          Porolog::Predicate.scope.name
        refute_empty    left.predicates
        assert_includes left.predicates, left_test
        
        right_test = Porolog::Predicate.new 'right_test', :right
        
        assert_includes Porolog::Scope[:right].predicates, right_test
        assert_equal    :left,          Porolog::Predicate.scope.name
        
        assert_equal    [left_test],    Porolog::Scope[:left ].predicates
        assert_equal    [right_test],   Porolog::Scope[:right].predicates
      end
    
      it 'should not create a Predicate named "predicate"' do
        assert_raises Porolog::Predicate::NameError do
          Porolog::predicate :predicate
        end
        assert_raises Porolog::Predicate::NameError do
          Porolog::predicate 'predicate'
        end
        assert_raises Porolog::Predicate::NameError do
          Porolog::Predicate.new :predicate
        end
        assert_raises Porolog::Predicate::NameError do
          Porolog::Predicate.new 'predicate'
        end
      end
      
    end
    
    describe '#call' do
    
      it 'should create an Arguments when "called"' do
        p = Porolog::Predicate.new :p
        
        arguments = p.(1,2,3)
        
        assert_instance_of  Porolog::Arguments,   arguments
        assert_equal        [1,2,3],              arguments.arguments
        assert_equal        'p(1,2,3)',           arguments.inspect
      end
      
    end
    
    describe '#arguments' do
    
      it 'should provide a convenience method to create an Arguments' do
        p = Porolog::Predicate.new :p
        
        arguments = p.arguments(1,2,3)
        
        assert_instance_of  Porolog::Arguments,   arguments
        assert_equal        [1,2,3],              arguments.arguments
        assert_equal        'p(1,2,3)',           arguments.inspect
      end
      
    end
    
    describe '#name' do
    
      it 'should create predicates with a name attribute, which is converted to a Symbol' do
        test_predicate = Porolog::Predicate.new('test_predicate_name')
        
        assert_respond_to   test_predicate,         :name
        assert_equal        :test_predicate_name,   test_predicate.name
      end
      
    end
    
    describe '#rules' do
    
      it 'should create predicates with an empty set of rules' do
        test_predicate = Porolog::Predicate.new('test_predicate_name')
        
        assert_respond_to   test_predicate,         :rules
        assert_equal        [],                     test_predicate.rules
      end
    
      it 'should add new facts to a predicate' do
        alpha = Porolog::Predicate.new 'alpha'
        
        alpha.('p','q').fact!
        
        assert_equal    1,                                  alpha.rules.size
        assert_equal    true,                               alpha.rules.first.definition
        assert_equal    '  alpha("p","q"):- true',          alpha.rules.first.inspect
        assert_equal    'alpha:-  alpha("p","q"):- true',   alpha.inspect
        
        assert_Predicate  alpha, :alpha, [alpha.rules.first]
      end
      
      it 'should add new fallacies to a predicate' do
        alpha = Porolog::Predicate.new 'alpha'
        
        alpha.('p','q').fallacy!
        
        assert_equal    1,                                  alpha.rules.size
        assert_equal    false,                              alpha.rules.first.definition
        assert_equal    '  alpha("p","q"):- false',         alpha.rules.first.inspect
        assert_equal    'alpha:-  alpha("p","q"):- false',  alpha.inspect
        
        assert_Predicate  alpha, :alpha, [alpha.rules.first]
      end
      
    end
    
    describe '#inspect' do
      
      it 'should return a summary of the predicate' do
        alpha = Porolog::Predicate.new 'alpha'
        
        assert_equal    'alpha:-',  alpha.inspect
      end
      
      it 'should return a summary of the predicate with rules' do
        alpha = Porolog::Predicate.new 'alpha'
        
        alpha.(:x,:y) << [
          alpha.(:x,:y),
          alpha.(:y,:x),
          :CUT
        ]
        
        assert_equal    'alpha:-  alpha(:x,:y):- [alpha(:x,:y), alpha(:y,:x), :CUT]',  alpha.inspect
      end
      
    end
    
    describe '#<<' do
      
      it 'should add new rules to a predicate' do
        alpha = Porolog::Predicate.new 'alpha'
        
        alpha.(:P,:Q) << [
          alpha.(:P,:Q),
          alpha.(:Q,:P),
        ]
        alpha.(:P,:Q) << [
          alpha.(:P,:P),
          alpha.(:Q,:Q),
        ]
        
        assert_equal        2,                              alpha.rules.size
        assert_instance_of  Array,                          alpha.rules.first.definition
        assert_equal        2,                              alpha.rules.first.definition.size
        
        assert_Arguments    alpha.rules.first.definition[0],  :alpha, [:P,:Q]
        assert_Arguments    alpha.rules.first.definition[1],  :alpha, [:Q,:P]
        
        assert_equal    '  alpha(:P,:Q):- [alpha(:P,:Q), alpha(:Q,:P)]',        alpha.rules.first.inspect
        assert_equal    [
          'alpha:-',
          '  alpha(:P,:Q):- [alpha(:P,:Q), alpha(:Q,:P)]',
          '  alpha(:P,:Q):- [alpha(:P,:P), alpha(:Q,:Q)]',
        ].join("\n"),                                                           alpha.inspect
        
        assert_Predicate  alpha, :alpha, [alpha.rules[0],alpha.rules[1]]
      end
      
    end
    
    describe '#builtin?' do
      
      it 'should return false for normal predicates' do
        p = Porolog::predicate :normal
        
        assert_equal    false,    p.builtin?
      end
      
      it 'should return true for builtin predicates' do
        p = Porolog::builtin :append
        
        assert_equal    true,     p.builtin?
      end
      
    end
    
    describe '#satisfy_builtin' do
      
      module Porolog
        class Predicate
          module Builtin
            def user_defined(goal, block, *args, &arg_block)
              puts 'Called user_defined'
              block.call(goal, *args) || false
            end
          end
        end
      end
      
      let(:predicate1)  { Porolog::Predicate.new :user_defined, builtin: true }
      let(:arguments1)  { predicate1.arguments(:m,:n) }
      let(:goal)        { arguments1.goal }
      
      it 'should satisfy builtin predicate' do
        called = false
        
        assert_output "Called user_defined\n" do
          predicate1.satisfy_builtin(goal) {|*args|
            called = args
          }
        end
        
        assert_equal    [goal, goal[:m], goal[:n]],       called
      end
      
    end
    
    describe '.call_builtin' do
      
      it 'should raise an exception when no such builtin predicate exists' do
        assert_raises NameError do
          Predicate.call_builtin(:non_existent)
        end
        
      end
      
      it 'should call a builtin predicate' do
        module Porolog
          class Predicate
            module Builtin
              def custom(goal, block, *args, &arg_block)
                block.call(goal, *args) || false
              end
            end
          end
        end
        called = false
        
        goal = new_goal :a, :b, :c
        block = ->(goal, *args){
          called = [goal] + args
        }
        Porolog::Predicate.call_builtin(:custom, goal, block, goal[:X], [1,2,3]) { 1 }
        assert_equal    [goal, goal[:X], [1,2,3]],      called
      end
      
    end
    
  end

end
