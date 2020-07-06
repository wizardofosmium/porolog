#
#   lib/porolog/instantiation.rb      - Plain Old Ruby Objects Prolog Engine -- Instantiation
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Instantiation implements an instantiation of a Variable of a Goal.
  # An Instantiation joins two expressions.  At least one expression must have a variable.
  # An index may be provided to index into the value of either expression, or both may have an index.
  # Thus, an element of each list could be instantiated without reference to the other elements:
  #   x = [a,b,c,d,e]
  #            |
  #   y =   [p,q,r,s]
  #
  # @author Luis Esteban
  #
  # @!attribute variable1
  #   @return [Variable,Object] one end of the instantiation.
  # @!attribute variable2
  #   @return [Variable,Object] the other end of the instantiation.
  # @!attribute index1
  #   @return [Object,nil] the index into the value of variable1.
  # @!attribute index2
  #   @return [Object,nil] the index into the value of variable2.
  #
  class Instantiation
    
    # Error class for rescuing or detecting any Instantiation error.
    class Error               < PorologError ; end
    # Error class indicating that an instantiation was created without any Variables.
    class NoVariableError     < Error        ; end
    # Error class indicating that an index could not be used although requested.
    class UnhandledIndexError < Error        ; end
    
    attr_accessor :variable1, :variable2, :index1, :index2
    
    # Clears all instantiations.
    # @return [Boolean] success
    def self.reset
      @@instantiations = {}
      true
    end
    
    reset
    
    # @return [Hash{Array => Porolog::Instantiation}] all Instantiations
    def self.instantiations
      @@instantiations
    end
    
    # Finds or creates a new instantiation.  At least one of the variables must be a Variable.
    # @param variable1 [Porolog::Variable,Porolog::Value,Object] one end of the instantiation to be made.
    # @param variable2 [Porolog::Variable,Porolog::Value,Object] the other end of the instantiation to be made.
    # @param index1 [Integer,Symbol,nil] index into the value of variable1.
    # @param index2 [Integer,Symbol,nil] index into the value of variable2.
    # @return [Porolog::Instantiation] the found or created Instantiation.
    def self.new(variable1, index1, variable2, index2)
      raise NoVariableError, "Cannot instantiate non-variables: #{variable1.inspect} and #{variable2.inspect}" unless variable1.is_a?(Variable) || variable2.is_a?(Variable)
      
      variable1 = Value.new variable1, variable2.goal unless variable1.is_a?(Variable) || variable1.is_a?(Value)
      variable2 = Value.new variable2, variable1.goal unless variable2.is_a?(Variable) || variable2.is_a?(Value)
      
      instantiation = \
        @@instantiations[[variable1, index1, variable2, index2]] ||
        @@instantiations[[variable2, index2, variable1, index1]] ||
        super
      
      instantiation
    end
    
    # Initializes and registers a new Instantiation.  At least one of the variables must be a Variable.
    # @param variable1 [Porolog::Variable,Porolog::Value,Object] one end of the instantiation to be made.
    # @param variable2 [Porolog::Variable,Porolog::Value,Object] the other end of the instantiation to be made.
    # @param index1 [Integer,Symbol,nil] index into the value of variable1.
    # @param index2 [Integer,Symbol,nil] index into the value of variable2.
    # @return [Porolog::Instantiation] the found or created Instantiation.
    def initialize(variable1, index1, variable2, index2)
      @variable1 = variable1
      @variable2 = variable2
      @index1    = index1
      @index2    = index2
      
      @variable1.instantiations << self
      @variable2.instantiations << self
      
      @@instantiations[signature] = self
    end
    
    # @return [Array] the signature of the Instantiation, which aids in avoiding duplication instantiations.
    def signature
      @signature ||= [@variable1, @index1, @variable2, @index2].freeze
      @signature
    end
    
    # @return [String] pretty representation.
    def inspect(indent = 0)
      index1 = @index1 ? "[#{@index1.inspect}]" : ''
      index2 = @index2 ? "[#{@index2.inspect}]" : ''
      
      "#{'  ' * indent}#{@variable1.inspect}#{index1} = #{@variable2.inspect}#{index2}"
    end
    
    # Removes itself from its variables' Instantiations and unregisters itself.
    # @return [Boolean] success
    def remove
      @variable1.instantiations.delete(self)  if @variable1.is_a?(Variable) || @variable1.is_a?(Value)
      @variable2.instantiations.delete(self)  if @variable2.is_a?(Variable) || @variable2.is_a?(Value)
      
      @deleted = true
      @@instantiations.delete(signature)
      @deleted
    end
    
    # Returns the Goal of the other Variable to the one provided.
    # @param variable [Porolog::Variable] the provided Variable.
    # @return [Porolog::Goal,nil] the Goal of the other Variable.
    def other_goal_to(variable)
      return nil unless variables.include?(variable)
      
      other_variable = (variables - [variable]).first
      other_variable && other_variable.goal
    end
    
    # @return [Array<Porolog::Goal>] the Goals of the Variables of the Instantiation.
    def goals
      [@variable1.goal,@variable2.goal]
    end
    
    # @return [Array<Porolog::Variable,Object>] the Variables of the Instantiation.
    def variables
      [@variable1,@variable2]
    end
    
    # @param visited [Array] prevents infinite recursion.
    # @return [Array] the values of the Variables of the Instantiation.
    def values(visited = [])
      return [] if visited.include?(self)
      
      vv1 = values_for(@variable1, visited)
      vv2 = values_for(@variable2, visited)
      
      (vv1 + vv2).uniq
    end
    
    # @param value [Object] the provided value.
    # @param index [Integer,Symbol,Array<Integer>] the index.
    # @param visited [Array] prevents infinite recursion.
    # @return [Object] the indexed value of the provided value.
    def value_indexed(value, index, visited = [])
      return nil unless value
      return nil if value.type == :variable
      return nil if value == [] && index == :tail
      
      visit = [value, index]
      return nil if visited.include?(visit)
      visited = visited + [visit]
      
      case index
        when Integer
          if value.respond_to?(:last) && value.last == UNKNOWN_TAIL
            if index >= value.length - 1
              UNKNOWN_TAIL
            else
              value[index]
            end
          elsif value.is_a?(Numeric)
            value
          else
            value[index]
          end
        
        when Symbol
          value_value = value.value(visited)
          if value_value.respond_to?(index)
            value_value.send(index)
          else
            value
          end
        
        when Array
          if index.empty?
            value[1..-1]
          else
            value[0...index.first]
          end
        
        else
          if index
            raise UnhandledIndexError, "Unhandled index: #{index.inspect} of #{value.inspect}"
          else
            value
          end
      end
    end
    
    # @param variable [Porolog::Variable,Porolog::Value] the specified variable (or end of the Instantiation).
    # @param visited [Array] prevents infinite recursion.
    # @return [Array<Object>] the values for the specified variable by finding the values of the other variable (i.e. the other end) and applying any indexes.
    def values_for(variable, visited = [])
      return [] if visited.include?(self)
      visited = visited + [self]
      
      if variable == @variable1
        if @index1
          [value_at_index(value_indexed(@variable2.value(visited), @index2, visited), @index1)]
        else
          if @variable2.is_a?(Variable)
            [value_indexed(@variable2.value(visited), @index2, visited)]
          else
            [value_indexed(@variable2, @index2, visited)]
          end
        end
      elsif variable == @variable2
        if @index2
          [value_at_index(value_indexed(@variable1.value(visited), @index1, visited), @index2)]
        else
          if @variable1.is_a?(Variable)
            [value_indexed(@variable1.value(visited), @index1, visited)]
          else
            [value_indexed(@variable1, @index1, visited)]
          end
        end
      else
        []
      end.compact
    end
    
    # @param value [Object] the known value.
    # @param index [Integer,Symbol,Array] the known index.
    # @return [Array] an Array where the known value is at the known index.
    def value_at_index(value, index)
      value && case index
        when Integer
          result        = []
          result[index] = value
          result       << UNKNOWN_TAIL
          result
        
        when Symbol
          case index
            when :head
              [value, UNKNOWN_TAIL]
            when :tail
              [nil, *value]
            else
              raise UnhandledIndexError, "Unhandled index: #{index.inspect} for #{value.inspect}"
          end
        
        when Array
          if index.empty?
            [nil, *value]
          else
            #result                 = []
            #result[0..index.first] = value
            #result
            #[*([*value][0..index.first]), UNKNOWN_TAIL]
            [value, UNKNOWN_TAIL]
          end
        
        else
          if index
            raise UnhandledIndexError, "Unhandled index: #{index.inspect} for #{value.inspect}"
          else
            value
          end
      end
    end
    
    # @param variable [Porolog::Variable,Porolog::Value] the specified variable.
    # @return [Boolean] whether the specified variable is not indexed.
    def without_index_on?(variable)
      [
        [@variable1,@index1],
        [@variable2,@index2],
      ].any?{|pair|
        pair.first == variable && pair.last.nil?
      }
    end
    
    # @return [Boolean] whether the Instantiation has been deleted (memoized).
    def deleted?
      @deleted ||= @variable1.goal.deleted? || @variable2.goal.deleted?
      @deleted
    end
    
    # @param goal [Porolog::Goal] the provided Goal.
    # @return [Boolean] whether the Instantiation attaches to a variable in the provided Goal.
    def belongs_to?(goal)
      [
        @variable1.goal,
        @variable2.goal,
      ].include?(goal)
    end
    
  end
  
end
