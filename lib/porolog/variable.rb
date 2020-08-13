#
#   lib/porolog/variable.rb      - Plain Old Ruby Objects Prolog Engine -- Variable
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog
  
  # A Porolog::Variable is used to hold instantiations during the process of satisfying a goal.
  # It implements a variable of a goal.
  # It allows instantiations to be made and removed as the goal
  # is attempted to be satisfied.
  #
  # @author Luis Esteban
  #
  # @!attribute name
  #   @return [Symbol] The name of the variable.
  # @!attribute goal
  #   @return [Porolog::Goal] The Goal for which this Variable's instantiations are bound.
  # @!attribute instantiations
  #   @return [Array<Porolog::Instantiation>] The Instantiations of this Variable.
  # @!attribute values
  #   @return [Array<Porolog::Value>] the Values of the Variable when used as an anonymous Variable.
  #
  class Variable
    
    # Error class for rescuing or detecting any Variable error.
    class Error                 < PorologError  ; end
    # Error class indicating a Variable has been instantiated to multiple different values at the same time.
    class MultipleValuesError   < Error         ; end
    # Error class indicating a Variable has been created without a Goal.
    class GoalError             < Error         ; end
    # Error class indicating a Variable has been instantiated to a value that contains itself.
    class SelfReferentialError  < Error         ; end
    # Error class indicating an unexpected scenario has occurred.
    class UnexpectedError       < Error         ; end
    
    attr_accessor :name, :goal, :instantiations, :values
    
    # Initializes the Variable and attaches it to the Goal.
    # @param name [Object] the name used to refer to the Variable.
    # @param goal [Porolog::Goal] the Goal the Variable is to be attached to.
    def initialize(name, goal)
      raise GoalError, "Not a Goal: #{goal.inspect}" unless goal.is_a?(Goal)
      @goal = goal
      name  = name.to_sym  if name.is_a?(String)
      
      case name
        when Symbol
          @name   = name
          @values = []
        when Variable
          @name   = name.name
          @values = []
        when Value
          @name   = name.value
          @values = [name]
        else
          @name   = name.to_s
          @values = [Value.new(name, goal)]
      end
      
      @instantiations = []
      @goal.variable(self)
    end
    
    # Converts a Variable back to a Symbol.
    # @return [Symbol, nil] the name of the Variable.
    def to_sym
      @name&.to_sym
    end
    
    # @return [Symbol] the type of the Variable, which should be :variable.
    def type
      :variable
    end
    
    # @return [String] pretty representation.
    def inspect
      "#{@goal.myid}.#{@name.inspect}"
    end
    
    # @param visited [Array] used to prevent infinite recursion.
    # @param depth [Integer] the current level of indentation.
    # @param index [Object, nil] the index into this Variable that is instantiated.
    # @param self_index [Object, nil] the index where this Variable is instantiated.
    # @return [String] the inspect of the Variable showing instantiations using indentation.
    def inspect_with_instantiations(visited = [], depth = 0, index = nil, self_index = nil)
      return if visited.include?(self)
      
      index_str = index      && "[#{index.inspect}]"      || ''
      prefix    = self_index && "[#{self_index.inspect}]" || ''
      name      = "#{'  ' * depth}#{prefix}#{@goal.myid}.#{@name.inspect}#{index_str}"
      
      name = "#{name} = #{@values.map(&:inspect).join(',')}#{index_str}" if @values && !@values.empty? && @instantiations.empty?
      
      others = @instantiations.map{|instantiation|
        [
          instantiation.variable1.inspect_with_instantiations(visited + [self], depth + 1, instantiation.index1, instantiation.index2),
          instantiation.variable2.inspect_with_instantiations(visited + [self], depth + 1, instantiation.index2, instantiation.index1),
        ].compact
      }.reject(&:empty?)
      
      [
        name,
        *others,
      ].join("\n")
    end
    
    # @return [Object,self] returns the current value of the Variable based on its current instantiations.
    #   If there are no concrete instantiations, it returns itself, indicating no value.
    # @param visited [Array] prevents infinite recursion.
    def value(visited = [])
      return nil if visited.include?(self)
      visited = visited + [self]
      
      # -- Collect values --
      values = [*@values]
      
      @instantiations.each do |instantiation|
        values += instantiation.values_for(self, visited)
      end
     
      values.uniq!
     
      # -- Filter trivial values --
      values = [[nil]] if values == [[UNKNOWN_TAIL], [nil]] || values == [[nil], [UNKNOWN_TAIL]]
     
      values = values.reject{|value| value == UNKNOWN_TAIL }
     
      values_values = values.map{|value| value.value(visited) }.reject{|value| value == UNKNOWN_ARRAY }
      
      # -- Condense Values --
      result = if values_values.size > 1
        # -- Potentially Multiple Values Found --
        unifications = []
        if values_values.all?{|value| value.is_a?(Array) }
          # -- All Values Are Arrays --
          values = values.reject{|value| value == UNKNOWN_ARRAY } if values.size > 2 && values.include?(UNKNOWN_ARRAY)
          values_goals = values.map{|value|
            value.respond_to?(:goal) && value.goal || value.variables.map(&:goal).first || values.variables.map(&:goal).first
          }

          if values.size > 2
            merged, unifications = Porolog::unify_many_arrays(values, values_goals, visited)
          elsif values.size == 2
            no_variables = values.map(&:variables).flatten.empty?
            if no_variables
              left_value  = values[0].value.value
              right_value = values[1].value.value
              if left_value.last == UNKNOWN_TAIL && right_value.first == UNKNOWN_TAIL
                return [*left_value[0...-1], *right_value[1..-1]]
              elsif right_value.last == UNKNOWN_TAIL && left_value.first == UNKNOWN_TAIL
                return [*right_value[0...-1], *left_value[1..-1]]
              elsif left_value != right_value
                return nil
              end
            end
            merged, unifications = Porolog::unify_arrays(*values, *values_goals, visited)
          else
            # :nocov: NOT REACHED
            merged, unifications = values.first, []
            # :nocov:
          end
          
          merged.value(visited).to_a
        else
          # -- Not All Values Are Arrays --
          values.each_cons(2){|left,right|
            unification = Porolog::unify(left, right, @goal, @goal, visited)
            if unification && unifications
              unifications += unification
            else
              unifications = nil
            end
          }
          if unifications
            values.min_by{|value|
              case value
                when Porolog::Variable, Symbol                      then  2
                when Porolog::UNKNOWN_TAIL, Porolog::UNKNOWN_ARRAY  then  9
                else                                                      0
              end
            } || self
          else
            raise MultipleValuesError, "Multiple values detected for #{inspect}: #{values.inspect}"
          end
        end
      else
        # -- One (or None) Value Found --
        values.min_by{|value|
          case value
            when Variable, Symbol             then  2
            when UNKNOWN_TAIL, UNKNOWN_ARRAY  then  9
            else                              0
          end
        } || self
      end
      
      # -- Splat Tail --
      if result.is_a?(Array) && result.size == 1 && result.first.is_a?(Tail)
        result = result.first.value
      end
      
      result
    end
    
    # Instantiates Variable to another experssion.
    # @param other [Object] the other value (or object) being instantiated.
    # @param index_into_other [] the index into the other value.
    # @param index_into_self [] the index into this Variable.
    # @return [Porolog::Instantiation,nil] the instantiation made.
    # @example
    #   # To instantiate the third element of x to the second element of y,
    #   # x = [a,b,c,d,e]
    #   #          |
    #   # y =   [p,q,r,s]
    #     x = goal.variable(:x)
    #     y = goal.variable(:y)
    #     x.instantiate(y, 1, 2)
    # @example
    #   # To instantiate the tail of x to y,
    #     x.instantiate(y, nil, :tail)
    def instantiate(other, index_into_other = nil, index_into_self = nil)
      raise SelfReferentialError, "Cannot instantiate self-referential definition for #{(self.variables & other.variables).inspect}"  unless (self.variables & other.variables).empty?
      
      # -- Check Instantiation is Unifiable --
      unless self.value.is_a?(Variable) || other.value.is_a?(Variable)
        # -- Determine Other Goal --
        other_goal = nil
        other_goal = other.goal if other.respond_to?(:goal)
        other_goal ||= self.goal
        
        # -- Check Unification --
        unless Porolog::unify(self, other, self.goal, other_goal)
          self.goal.log << "Cannot unify: #{self.inspect} and #{other.inspect}"
          return nil
        end
      end
      
      # -- Create Instantiation --
      instantiation = Instantiation.new(self, index_into_self, other, index_into_other)
      
      # -- Create Reverse Assymetric Instantiations --
      if other.value.is_a?(Array) && other.value.last.is_a?(Tail)
        array = other.value
        if array.length == 2
          if array.first.is_a?(Variable)
            Instantiation.new(array.first, nil, self, :head)
          end
          if array.last.is_a?(Tail) && array.last.value.is_a?(Variable)
            Instantiation.new(array.last.value, nil, self, :tail)
          end
        end
      end
      
      # -- Return --
      instantiation
    end
    
    # Removes this Variable by removing all of its insantiations.
    # @return [Boolean] success.
    def remove
      @instantiations.dup.each(&:remove)
      @instantiations[0..-1] = []
      true
    end
    
    # Removes instantiations from another goal.
    # @param other_goal [Porolog::Goal] the Goal of which instantiations are to be removed.
    # @return [Boolean] success.
    def uninstantiate(other_goal)
      @instantiations.delete_if do |instantiation|
        instantiation.remove  if instantiation.other_goal_to(self) == other_goal
      end
      
      @values.delete_if{|value| value.goal == other_goal }
      true
    end
    
    # Indexes the value of the Variable.
    # @param index [Object] the index into the value.
    # @return [Object, nil] the value at the index in the value of the Variable.
    def [](index)
      value = self.value
      value = value.value if value.is_a?(Value)
      
      case value
        when Array
          case index
            when Integer
              value[index]
            when Symbol
              case index
                when :head
                  value[0]
                when :tail
                  value[1..-1]
                else
                  nil
              end
            else
              nil
          end
        else
          nil
      end
    end
    
    # @return [Array<Porolog::Variable>] the Variables in itself, which is just itself.
    def variables
      [self]
    end
    
    # Compares Variables.
    # @param other [Porolog::Variable] the other Variable.
    # @return [Boolean] whether the two Variables have the same name in the same Goal.
    def ==(other)
      other.is_a?(Variable) && @name == other.name && @goal == other.goal
    end
    
  end
  
end
