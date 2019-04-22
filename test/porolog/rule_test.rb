#
#   test/porolog/rule_test.rb     - Test Suite for Porolog::Rule
#
#     Luis Esteban      2 May 2018
#       created
#

require_relative '../test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end

  describe 'Rule' do
    
    describe '.reset' do
      
      it 'should delete/unregister all rules' do
        pred = Predicate.new :pred
        args = Arguments.new pred, [1,2,3]
        
        rule1 = Rule.new args, [1,2]
        rule2 = Rule.new args, [3,4,5]
        rule3 = Rule.new args, [6]
        
        assert_equal  'Rule1',    rule1.myid
        assert_equal  'Rule2',    rule2.myid
        assert_equal  'Rule3',    rule3.myid
        
        Rule.reset
        
        rule4 = Rule.new args, [7,8,9,0]
        rule5 = Rule.new args, [:CUT,false]
        
        assert_equal  'Rule-999', rule1.myid
        assert_equal  'Rule-999', rule2.myid
        assert_equal  'Rule-999', rule3.myid
        assert_equal  'Rule1',    rule4.myid
        assert_equal  'Rule2',    rule5.myid
      end
      
    end
    
    describe '.new' do
      
      it 'should create a new rule' do
        pred = Predicate.new :pred
        args = Arguments.new pred, [1,2,3]
        defn = [true]
        rule = Rule.new args, defn
        
        assert_Rule         rule, :pred, [1,2,3], [true]
      end
      
    end
    
    describe '#initialize' do
      
      it 'should initialize arguments and definition' do
        pred = Predicate.new :pred
        args = Arguments.new pred, [1,2,3]
        defn = [:CUT,false]
        rule = Rule.new args, defn
        
        assert_Rule   rule,   :pred, [1,2,3], [:CUT,false]
        assert_equal  args,   rule.arguments
        assert_equal  defn,   rule.definition
      end
      
    end
    
    describe '#myid' do
      
      it 'should show the rule index' do
        pred = Predicate.new :pred
        args = Arguments.new pred, [1,2,3]
        defn = [:CUT,false]
        rule = Rule.new args, defn
        
        assert_equal  'Rule1',    rule.myid
      end
      
      it 'should show -999 when deleted/unregistered' do
        pred = Predicate.new :pred
        args = Arguments.new pred, [1,2,3]
        defn = [:CUT,false]
        rule = Rule.new args, defn
        
        Rule.reset
        
        assert_equal  'Rule-999', rule.myid
      end
      
    end
    
    describe '#inspect' do
      
      it 'should show the predicate, arguments, and definition' do
        pred = Predicate.new :pred
        args = Arguments.new pred, [1,2,3]
        defn = [:CUT,false]
        rule = Rule.new args, defn
        
        assert_equal  '  pred(1,2,3):- [:CUT, false]',    rule.inspect
      end
      
    end
    
  end

end
