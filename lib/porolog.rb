#
#   lib/porolog.rb      - Plain Old Ruby Objects Prolog Engine
#
#     Luis Esteban   2 May 2018
#       created
#

#
# @author Luis Esteban
#
module Porolog

  # The most recent version of the Porolog gem.
  VERSION      = '0.0.8'.freeze
  # The most recent date of when the VERSION changed.
  VERSION_DATE = '2020-07-06'.freeze
  
  # Represents an unknown tail of a list.
  UNKNOWN_TAIL = Object.new
  
  # Defines pretty version of an unknown tail.
  def UNKNOWN_TAIL.inspect
    '...'
  end
  
  # Specifies that the unknown tail is a list.
  def UNKNOWN_TAIL.type
    :array
  end
  
  UNKNOWN_TAIL.freeze
  
  # Represents a list where all elements are unknown.
  UNKNOWN_ARRAY = [UNKNOWN_TAIL].freeze
  
  # A convenience method to create a Predicate, along with a method
  # that returns an Arguments based on the arguments provided to
  # the method.
  # @param names [Array<#to_sym>] names of the Predicates to create.
  # @return [Porolog::Predicate] Predicate created if only one name is provided
  # @return [Array<Porolog::Predicate>] Predicates created if multiple names are provided
  # @example
  #     predicate :combobulator
  #     combobulator(:x,:y)       # --> Porolog::Arguments
  def predicate(*names)
    names = [names].flatten
    
    predicates = names.map{|name|
      method     = name.to_sym
      predicate  = Predicate.new(name)
      Object.class_eval{
        remove_method(method) if public_method_defined?(method)
        define_method(method){|*args|
          predicate.(*args)
        }
      }
      predicate
    }
    
    predicates.size > 1 && predicates || predicates.first
  end
  
  # Unify the Arguments of a Goal and a sub-Goal.
  # @param goal [Porolog::Goal] a Goal to solve a Predicate for specific Arguments.
  # @param subgoal [Porolog::Goal] a sub-Goal to solve the Goal following the Rules of the Predicate.
  # @return [Boolean] whether the Goals can be unified.
  def unify_goals(goal, subgoal)
    if goal.arguments.predicate == subgoal.arguments.predicate
      unifications = unify(goal.arguments.arguments, subgoal.arguments.arguments, goal, subgoal)
      if unifications
        instantiate_unifications(unifications)
      else
        msg = "Could not unify goals: #{goal.arguments.arguments.inspect} !~ #{subgoal.arguments.arguments.inspect}"
        goal.log << msg
        subgoal.log << msg
        false
      end
    else
      msg = "Cannot unify goals because they are for different predicates: #{goal.arguments.predicate.name.inspect} and #{subgoal.arguments.predicate.name.inspect}"
      goal.log << msg
      subgoal.log << msg
      false
    end
  end
  
  # Instantiates the unifications from an attempt to unify.
  # @param unifications [Array] unifications to instantiate.
  # @return [Boolean] whether the instantiations could be made.
  def instantiate_unifications(unifications)
    # -- Gather Unifications --
    goals_variables = {}
    
    return_false = false
    unifications.each do |unification|
      left, right, left_goal, right_goal = unification
      
      goals_variables[left_goal]       ||= {}
      goals_variables[left_goal][left] ||= []
      goals_variables[left_goal][left] << [right_goal,right]
      
      return_false = true if goals_variables[left_goal][left].map(&:last).reject{|value|
        value.is_a?(Variable) || value.is_a?(Symbol)
      }.uniq.size > 1
      
      return false if return_false
    end
    
    # -- Make Instantiations --
    instantiations = []
    consistent     = true
    
    goals_variables.each do |goal,variables|
      variables.each do |name,others|
        others.each do |other_goal,other|
          instantiation = goal.instantiate(name, other, other_goal)
          if instantiation
            instantiations << instantiation
          else
            consistent = false
          end
        end
      end
    end
    
    # -- Revert if inconsistent --
    instantiations.each(&:remove) unless consistent
    
    consistent
  end
  
  # Attempt to unify two entities of two goals.
  # @param left [Object] left hand side entity.
  # @param right [Object] right hand side entity.
  # @param left_goal [Porolog::Goal] goal of left hand side entity.
  # @param right_goal [Porolog::Goal] goal of right hand side entity.
  # @param visited [Array] prevents infinite recursion.
  # @return [Array] an Array of unifications when the left hand side can be unified with the right hand.
  # @return [nil] nil if they cannot be unified.
  def unify(left, right, left_goal, right_goal = left_goal, visited = [])
    right_goal ||= left_goal
    goals     = [left_goal, right_goal].uniq
    signature = [left.type, right.type]
    
    # -- Nil is Uninstantiated (can always unify) --
    return [] unless left && right
    
    # -- Set HeadTail Goals --
    case signature
      when [:atomic, :atomic]
        if left == right
          []
        else
          msg = "Cannot unify because #{left.inspect} != #{right.inspect} (atomic != atomic)"
          goals.each{|goal| goal.log << msg }
          nil
        end
      
      when [:array, :array]
        _merged, unifications = unify_arrays(left, right, left_goal, right_goal, visited)
        if unifications
          unifications
        else
          msg = "Cannot unify because #{left.inspect} != #{right.inspect} (array != array)"
          goals.each{|goal| goal.log << msg }
          nil
        end
      
      when [:variable, :atomic]
        left_value  = left_goal.value_of(left, nil, visited)
        right_value = right
        if left_value == right_value || left_value.is_a?(Variable) || left_value.nil?
          [[left, right, left_goal, right_goal]]
        else
          msg = "Cannot unify because #{left_value.inspect} != #{right_value.inspect} (variable != atomic)"
          goals.each{|goal| goal.log << msg }
          nil
        end
      
      when [:atomic, :variable]
        left_value  = left
        right_value = right_goal.value_of(right, nil, visited)
        if left == right_value || right_value.is_a?(Variable) || right_value.nil?
          [[right,left,right_goal,left_goal]]
        else
          msg = "Cannot unify because #{left_value.inspect} != #{right_value.inspect} (atomic != variable)"
          goals.each{|goal| goal.log << msg }
          nil
        end
      
      when [:variable, :variable]
        left_value  = left_goal.value_of(left, nil, visited)
        right_value = right_goal.value_of(right, nil, visited)
        if left_value == right_value || left_value.is_a?(Variable) || right_value.is_a?(Variable) || left_value.nil? || right_value.nil?
          [[left, right, left_goal, right_goal]]
        else
          msg = "Cannot unify because #{left_value.inspect} != #{right_value.inspect} (variable != variable)"
          goals.each{|goal| goal.log << msg }
          nil
        end
      
      when [:variable, :array]
        left_value  = left_goal.value_of(left, nil, visited)
        right_value = right
        if left_value == right_value || left_value.is_a?(Variable) || left_value == UNKNOWN_ARRAY || left_value.nil?
          [[left, right, left_goal, right_goal]]
        elsif left_value.type == :array
          _merged, unifications = unify_arrays(left_value, right, left_goal, right_goal, visited)
          if unifications
            unifications
          else
            msg = "Cannot unify because #{left_value.inspect} != #{right.inspect} (variable/array != array)"
            goals.each{|goal| goal.log << msg }
            nil
          end
        else
          msg = "Cannot unify because #{left_value.inspect} != #{right_value.inspect} (variable != array)"
          goals.each{|goal| goal.log << msg }
          nil
        end
      
      when [:array, :variable]
        left_value  = left
        right_value = right_goal.value_of(right, nil, visited)
        if left_value == right_value || right_value.is_a?(Variable) || right_value == UNKNOWN_ARRAY || right_value.nil?
          [[right, left, right_goal, left_goal]]
        elsif right_value.type == :array
          _merged, unifications = unify_arrays(left, right_value, left_goal, right_goal, visited)
          if unifications
            unifications
          else
            msg = "Cannot unify because #{left.inspect} != #{right_value.inspect} (variable/array != array)"
            goals.each{|goal| goal.log << msg }
            nil
          end
        else
          msg = "Cannot unify because #{left_value.inspect} != #{right_value.inspect} (array != variable)"
          goals.each{|goal| goal.log << msg }
          nil
        end
      
      when [:array,:atomic], [:atomic,:array]
        msg = "Cannot unify #{left.inspect} with #{right.inspect}"
        goals.each{|goal| goal.log << msg }
        nil
      
      else
        # :nocov:
        raise UnknownUnificationSignature, "UNKNOWN UNIFICATION SIGNATURE: #{signature.inspect}"
        # :nocov:
    end
  end
  
  # Attempt to unify two Arrays.
  # @param left [Array] left hand side Array.
  # @param right [Array] right hand side Array.
  # @param left_goal [Porolog::Goal] goal of left hand side Array.
  # @param right_goal [Porolog::Goal] goal of right hand side Array.
  # @param visited [Array] prevents infinite recursion.
  # @return [Array<Array, Array>] the merged Array and the unifications to be instantiated.
  # @return [nil] if the Arrays cannot be unified.
  def unify_arrays(left, right, left_goal, right_goal = left_goal, visited = [])
    arrays        = [left,       right]
    arrays_goals  = [left_goal,  right_goal]
    arrays_values = arrays.map(&:value)
    
    # -- Trivial Unifications --
    return [left_goal. variablise(left), []] if right == UNKNOWN_ARRAY
    return [right_goal.variablise(right),[]] if left  == UNKNOWN_ARRAY
    
    # -- Validate Arrays --
    unless arrays_values.all?{|array| array.is_a?(Array) || array == UNKNOWN_TAIL }
      msg = "Cannot unify a non-array with an array: #{left.inspect} with #{right.inspect}"
      arrays_goals.uniq.each{|goal| goal.log  << msg }
      return nil
    end
    
    # -- Count Tails --
    number_of_arrays = arrays.size
    number_of_tails  = arrays.count{|array| has_tail?(array) }
    
    # -- Handle Tails --
    if number_of_tails == 0
      unify_arrays_with_no_tails(arrays, arrays_goals, visited)
    elsif number_of_tails == number_of_arrays
      unify_arrays_with_all_tails(arrays, arrays_goals, visited)
    else
      unify_arrays_with_some_tails(arrays, arrays_goals, visited)
    end
  end
  
  # Attempt to unify multiple Arrays.
  # @param arrays [Array<Array>] the Arrays to be unified.
  # @param arrays_goals [Array<Porolog::Goal>] the Goals of the Arrays.
  # @param visited [Array] prevents infinite recursion.
  # @return [Array<Array, Array>] the merged Array and the unifications to be instantiated.
  # @return [nil] if the Arrays cannot be unified.
  def unify_many_arrays(arrays, arrays_goals, visited = [])
    arrays_values = arrays.map{|array| expand_splat(array) }.map{|array| array.is_a?(Array) ? array.map{|element| element.value } : array.value }
    
    unless arrays_values.all?{|array_values| [:array,:variable].include?(array_values.type) }
      msg = "Cannot unify: #{arrays.map(&:inspect).join(' with ')}"
      arrays_goals.uniq.each{|goal| goal.log << msg }
      return nil
    end
    
    # TODO: Fix
    if arrays_values.size == 2 && arrays_values.any?{|array| array == UNKNOWN_ARRAY }
      merged = arrays_values.reject{|array| array == UNKNOWN_ARRAY }.first
      return [merged,[]]
    end
    
    number_of_arrays = arrays.size
    number_of_tails  = arrays.count{|array| has_tail?(array) }
    
    if number_of_tails == 0
      unify_arrays_with_no_tails(arrays, arrays_goals, visited)
    elsif number_of_tails == number_of_arrays
      unify_arrays_with_all_tails(arrays, arrays_goals, visited)
    else
      unify_arrays_with_some_tails(arrays, arrays_goals, visited)
    end
  end
  
  # @return [Boolean] whether the provided value has a Tail.
  # @param value [Object] the provided value.
  def has_tail?(value, apply_value = true)
    value = value.value if value.respond_to?(:value) && apply_value
    
    if value.is_a?(Array)
      value.last == UNKNOWN_TAIL || value.last.is_a?(Tail)
    else
      false
    end
  end
  
  # Expands a superfluous splat.
  # @param array [Array] the given Array.
  # @return [Array] the given Array with any superfluous splats expanded.
  def expand_splat(array)
    array = array.first.value if array.is_a?(Array) && array.length == 1 && array.first.is_a?(Tail)
    
    if array.is_a?(Array) && array.last.is_a?(Tail) && array.last.value.is_a?(Array)
      array = [*array[0...-1], *array.last.value]
    end
    
    if array.is_a?(Array)
      array = array.map{|element|
        expand_splat(element)
      }
    end
    
    array
  end
  
  # Unifies Arrays where no Array has a Tail.
  # @param arrays [Array<Array>] the Arrays to be unified.
  # @param arrays_goals [Array<Porolog::Goal>] the Goals of the Arrays to be unified.
  # @param visited [Array] prevents infinite recursion.
  # @return [Array<Array, Array>] the merged Array and the unifications to be instantiated.
  # @return [nil] if the Arrays cannot be unified.
  def unify_arrays_with_no_tails(arrays, arrays_goals, visited)
    # -- Validate Arrays --
    if arrays.any?{|array| has_tail?(array) }
      msg = "Wrong unification method called: no_tails but one or more of #{arrays.inspect} has a tail"
      arrays_goals.uniq.each do |goal|
        goal.log << msg
      end
      return nil
    end
    
    # -- Trivial Unifications --
    return [[],[]] if arrays.empty?
    
    # -- Ensure Arrays elements have Goals --
    arrays_values = arrays.dup
    arrays_goals  = arrays_goals.dup
    
    arrays.each_with_index do |array, index|
      if array.is_a?(Value)
        arrays_goals[index] ||= array.goal
        arrays_values[index]  = array.value
      end
      
      if arrays_goals[index].nil?
        value_with_goal = array.find{|element| element.respond_to?(:goal) }
        arrays_goals[index] = value_with_goal.goal if value_with_goal && value_with_goal.goal
      end
      
      if arrays_goals[index].nil?
        raise NoGoalError, "Array #{array.inspect} has no goal for unification"
      end
      
      arrays_values[index] = expand_splat(arrays_values[index])
    end
    
    # -- Check whether all arrays are an Array --
    unless arrays_values.all?{|array| array.is_a?(Array) }
      merged, unifications = unify_many_arrays(arrays.map{|array| [array] }, arrays_goals, visited)
      return [merged] + [unifications]
    end
    
    arrays_variables = arrays_goals.zip(arrays)
    
    # -- Remap Arrays so that they are variablised and valuised with their Goals --
    new_arrays = []
    arrays_variables.each do |goal,variables|
      new_array = variables.map{|variable|
        value = goal.value_of(variable, nil, visited).value
        value = variable if value == UNKNOWN_TAIL || value == UNKNOWN_ARRAY
        
        if value.type == :variable
          value = goal.variable(value)
        elsif value.is_a?(Array)
          value = value.map{|element|
            if element.type == :variable
              goal.variable(element)
            elsif element.is_a?(Value)
              element
            elsif element.is_a?(Tail)
              element
            else
              goal.value(element)
            end
          }
        elsif !value.is_a?(Value)
          value = goal.value(value)
        end
        value
      }
      new_arrays << new_array
    end
    arrays = new_arrays
    
    # -- Unify All Elements --
    sizes = arrays.map(&:length).uniq
    if sizes.size <= 1
      # -- Arrays are the same length --
      zipped       = arrays[0].zip(*arrays[1..-1]).map(&:uniq).map(&:compact).uniq
      unifications = []
      merged       = []
      
      # TODO: Change these names
      zipped.each_with_index{|values_to_unify, index|
        values_to_unify_values = values_to_unify.map{|value|
          value_value = value.value
          if value_value == UNKNOWN_TAIL || value_value == UNKNOWN_ARRAY
            value
          else
            value_value
          end
        }.compact.uniq
        
        if values_to_unify_values.size <= 1
          # -- One Value --
          value = values_to_unify_values.first
          if value.type == :variable
            merged << nil
          else
            merged << value.value
          end
        else
          if values_to_unify_values.all?{|value| value.is_a?(Array) }
            submerged, subunifications = unify_many_arrays(values_to_unify_values, arrays_goals)
            if subunifications
              merged << submerged
              unifications += subunifications
            else
              msg = "Cannot unify: #{values_to_unify_values.map(&:inspect).join(' with ')}"
              arrays_goals.uniq.each{|goal| goal.log << msg }
              return nil
            end
          elsif values_to_unify.variables.empty?
            # -- Incompatible Values --
            incompatible_values = values_to_unify.map(&:value)
            msg = "Cannot unify incompatible values: #{incompatible_values.compact.map(&:inspect).join(' with ')}"
            arrays_goals.uniq.each{|goal| goal.log << msg }
            return nil
          else
            # -- Potentially Compatible Values/Variables --
            nonvariables = values_to_unify.map(&:value).compact.reject{|value| value.type == :variable }
            
            values_to_unify.reject{|value| value.value.nil? }.combination(2).each do |vl, vr|
              subunifications = unify(vl, vr, vl.goal, vr.goal, visited)
              if subunifications
                unifications += subunifications
              else
                msg = "Cannot unify: #{vl.inspect} with #{vr.inspect}"
                [vl.goal, vr.goal].uniq.each{|goal| goal.log << msg }
                return nil
              end
            end
            
            if nonvariables.size > 1
              subgoals = arrays_goals.dup
              nonvariables.each_with_index do |nonvariable, index|
                if nonvariable.respond_to?(:goal)
                  subgoal = nonvariable.goal
                  subgoals[index] = subgoal if subgoal
                end
              end
              subgoals = subgoals[0...nonvariables.size]
              merged_nonvariables, _nonvariable_unifications = unify_many_arrays(nonvariables, subgoals, visited)
            else
              merged_nonvariables      = nonvariables
            end
            
            merged_value = merged_nonvariables
            merged_value = [nonvariables.first.value] if merged_value.nil? || merged_value == []
            merged += merged_value
          end
        end
      }
      
      [merged, unifications]
    else
      # -- Arrays are different lengths --
      msg = "Cannot unify arrays of different lengths: #{arrays_values.map(&:inspect).join(' with ')}"
      arrays_goals.uniq.each{|goal| goal.log << msg }
      nil
    end
  end
  
  # Unifies Arrays where each Array has a Tail.
  # @param arrays [Array<Array>] the Arrays to be unified.
  # @param arrays_goals [Array<Porolog::Goal>] the Goals of the Arrays to be unified.
  # @param visited [Array] prevents infinite recursion.
  # @return [Array<Array, Array>] the merged Array and the unifications to be instantiated.
  # @return [nil] if the Arrays cannot be unified.
  def unify_arrays_with_all_tails(arrays, arrays_goals, visited)
    unifications = []
    merged       = []
    
    # -- All tails --
    signature = arrays.map(&:headtail?)
    arrays = arrays.map{|array|
      expand_splat(array.headtail? ? array : array.value)
    }
    signature = arrays.map(&:headtail?)
    
    # -- Unify Embedded Arrays --
    if arrays.any?{|array| array.type == :variable }
      unifications = unify(*arrays[0...2], *arrays_goals[0...2], visited)
      if unifications
        merged = arrays.reject{|value| value.type == :variable }.first || nil
        return [merged, unifications]
      else
        msg = "Cannot unify embedded arrays: #{arrays[0...2].map(&:value).map(&:inspect).join(' with ')}"
        arrays_goals.uniq.each do |goal|
          goal.log << msg
        end
        return nil
      end
    end
    
    signature = arrays.map(&:headtail?)
    unifications = []
    merged       = []
    
    if signature.all?
      merged, unifications = unify_headtail_with_headtail(arrays, arrays_goals, visited)
    elsif signature.map(&:!).all?
      merged, unifications = unify_tail_with_tail(arrays, arrays_goals, visited)
    else
      merged, unifications = unify_headtail_with_tail(arrays, arrays_goals, visited)
    end
    
    if unifications
      return [merged, unifications]
    else
      return nil
    end
  end
  
  # Unifies Arrays where each Array is not a Head/Tail array.
  # @param arrays [Array<Array>] the Arrays to be unified.
  # @param arrays_goals [Array<Porolog::Goal>] the Goals of the Arrays to be unified.
  # @param visited [Array] prevents infinite recursion.
  # @return [Array<Array, Array>] the merged Array and the unifications to be instantiated.
  # @return [nil] if the Arrays cannot be unified.
  def unify_tail_with_tail(arrays, arrays_goals, visited)
    # -- Validate Arrays --
    unless arrays.map(&:headtail?).map(&:!).all?
      msg = "Wrong method called to unify #{arrays.inspect}"
      arrays_goals.uniq.each do |goal|
        goal.log << msg
      end
      return nil
    end
    
    # -- Variablise Arrays --
    arrays = arrays_goals.zip(arrays).map do |goal, array|
      goal.variablise(array)
    end
    
    # == [1,2,3]/:tail ~~ [1,2,3]/:tail ==
    # -- Extract Elements --
    merged       = []
    unifications = []
    
    arrays = arrays.sort_by{|array| -array.length }
    
    arrays[0].zip(*arrays[1..-1]).each_with_index do |values,index|
      if values.any?{|value| value.is_a?(Tail) }
        # -- Unify Remaining Values and Tails --
        tails = arrays.map{|array| expand_splat(array[index..-1]) }
        merged_tails = []
        tails.combination(2).each do |pair|
          next if pair.compact.size < 2
          if pair.any?{|tail| tail == UNKNOWN_ARRAY }
            merged_tails += pair.reject{|tail| tail == UNKNOWN_ARRAY }
            next
          end
          first_goal = nil
          last_goal  = nil
          first_goal = pair.first.goal if pair.first.respond_to?(:goal)
          last_goal  = pair.last.goal  if pair.last.respond_to?(:goal)
          m,u = unify_arrays(first_goal.variablise([pair.first]), last_goal.variablise([pair.last]), first_goal, last_goal, visited)
          unless m
            return nil
          end
          m[-1] = UNKNOWN_TAIL if m[-1] == nil
          merged_tails += m
          unifications += u
        end
        merged_tails.uniq!
        merged_tails_unifications = []
        # TODO: Fix [first_goal] * arrays.size
        if merged_tails.size > 1
          merged_tails, merged_tails_unifications = unify_many_arrays(merged_tails, [arrays_goals.first] * arrays.size, visited)
        end
        merged       += merged_tails.flatten(1)
        unifications += merged_tails_unifications - unifications
        break
      else
        # -- Unify Values at Index --
        merged_value = []
        values.combination(2).each do |pair|
          if pair.any?(&:nil?)
            merged_value += pair.compact
            next
          end
          first_goal = nil
          last_goal  = nil
          first_goal = pair.first.goal if pair.first.respond_to?(:goal)
          last_goal  = pair.last.goal  if pair.last.respond_to?(:goal)
          
          m,u = unify_arrays([pair.first], [pair.last], first_goal, last_goal, visited)
          if m.nil?
            [first_goal, last_goal].uniq.each do |goal|
              goal.log << "Cannot unify #{pair.first.inspect} with #{pair.last.inspect}"
            end
            return nil
          end
          merged_value += m
          unifications += u
        end
        merged << merged_value.compact.uniq.first || nil
      end
    end
    
    [merged, unifications]
  end
  
  # Unifies Arrays where the Arrays are a mixture of Head/Tail and non-Head/Tail arrays.
  # @param arrays [Array<Array>] the Arrays to be unified.
  # @param arrays_goals [Array<Porolog::Goal>] the Goals of the Arrays to be unified.
  # @param visited [Array] prevents infinite recursion.
  # @return [Array<Array, Array>] the merged Array and the unifications to be instantiated.
  # @return [nil] if the Arrays cannot be unified.
  def unify_headtail_with_tail(arrays, arrays_goals, visited)
    # -- Validate Arrays --
    unless arrays.all?{|array| has_tail?(array, false) }
      msg = "Wrong method called to unify #{arrays.inspect}"
      arrays_goals.uniq.each do |goal|
        goal.log << msg
      end
      return nil
    end
    
    merged       = []
    unifications = []
    
    # -- Variablise Arrays --
    arrays = arrays_goals.zip(arrays).map do |goal, array|
      goal.variablise(array)
    end
    
    # -- Determine the fixed length (if any) --
    fixed_length = nil
    arrays.each do |array|
      unless has_tail?(array)
        array_length = array.value.size
        fixed_length ||= array_length
        unless fixed_length == array_length
          array.goal.log << "Cannot unify #{array.value.inspect} because it has a different length from #{fixed_length}"
          return nil
        end
      end
    end
    
    # -- Partition Arrays --
    headtail_arrays, tail_arrays = arrays.partition(&:headtail?)
    
    # -- Unify All HeadTail Arrays --
    if headtail_arrays.size > 1
      headtail_goals = headtail_arrays.map{|array| array.goal }
      merged_headtails, headtail_unifications = unify_headtail_with_headtail(headtail_arrays, headtail_goals, visited)
      unless merged_headtails
        msg = "Could not unify headtail arrays: #{headtail_arrays.map(&:value).map(&:inspect).join(' with ')}"
        headtail_goals.uniq.each do |goal|
          goal.log << msg
        end
        return nil
      end
      unifications += headtail_unifications
      
      if merged_headtails.length > merged.length
        merged += [[]] * (merged_headtails.length - merged.length)
      end
      
      # TODO: Remove flatten
      merged = merged.zip(merged_headtails).map(&:flatten)
    end
    
    # -- Unify All Tail Arrays --
    if tail_arrays.size > 1
      tail_goals = tail_arrays.map{|array| array.goal }
      merged_tails, tail_unifications = unify_tail_with_tail(tail_arrays, tail_goals, visited)
      return nil unless merged_tails
      unifications += tail_unifications
      
      if merged_tails.length > merged.length
        merged += [[]] * (merged_tails.length - merged.length)
      end
      
      # TODO: Remove flatten
      merged = merged.zip(merged_tails).map(&:flatten).map{|merge_values|
        merge_values.map{|value|
          if value == UNKNOWN_TAIL
            nil
          else
            value
          end
        }
      }.map(&:compact)
    end
    
    # -- Combine HeadTail Arrays and Tail Arrays --
    headtail_arrays.product(tail_arrays).each do |pair|
      # == :head/:tail ~~ [1,2,3]/:tail ==
      # -- Extract Elements --
      left       = expand_splat(pair.first)
      left_head  = left.head
      left_tail  = left.tail
      
      right      = expand_splat(pair.last)
      right_head = right.head
      right_tail = right.tail
      
      # -- Expand Tail --
      left_tail  = expand_splat(left_tail)
      right_tail = expand_splat(right_tail)
      
      # -- Determine Goals --
      left_goal  = pair.first.goal
      right_goal = pair.last.goal
      
      # -- Unify Heads --
      head_unifications = unify(left_head, right_head, left_goal, right_goal, visited)
      if head_unifications.nil?
        msg = "Cannot unify heads: #{left_head.inspect} with #{right_head.inspect}"
        left_goal.log  << msg
        right_goal.log << msg unless right_goal == left_goal
        return nil
      end
      unifications += head_unifications
      
      # -- Unify Tails --
      tail_unifications = unify(left_tail, right_tail, left_goal, right_goal, visited)
      if tail_unifications.nil?
        msg = "Cannot unify tails: #{left_tail.inspect} with #{right_tail.inspect}"
        left_goal.log  << msg
        right_goal.log << msg unless right_goal == left_goal
        return nil
      end
      unifications += tail_unifications
      
      # -- Determine Merged and Unifications --
      left_reassembled  = [left_head,  *left_tail ]
      right_reassembled = [right_head, *right_tail]
      max_length = [left_reassembled.length, right_reassembled.length].max
      
      if max_length > merged.length
        merged += [[]] * (max_length - merged.length)
      end
      
      merged = merged.zip(left_reassembled ).map(&:flatten)
      merged = merged.zip(right_reassembled).map(&:flatten)
    end
    
    merged = merged.value
    merged = merged.map(&:value)
    
    # TODO: Cleanup names
    # TODO: Flatten out tails
    #   E.g.  [nil, [2, 3], ...] should be [nil, 2, 3, ...]
    is_tails = []
    merged = merged.value.map{|elements|
      sorted_elements = elements.reject{|element|
        element.is_a?(Variable)
      }.uniq.compact.sort_by{|element|
        case element.type
          when :atomic
            0
          when :array
            if [UNKNOWN_TAIL, UNKNOWN_ARRAY].include?(element)
              3
            else
              1
            end
          else
            # :nocov:
            # There are only 3 types and variables have already been filtered.
            2
            # :nocov:
        end
      }
      
      is_tails << sorted_elements.any?{|element| element.is_a?(Tail) || element == UNKNOWN_TAIL }
      
      merged_value = sorted_elements.first
      
      if merged_value.is_a?(Tail) && merged_value.value.is_a?(Variable)
        UNKNOWN_TAIL
      else
        merged_value
      end
    }
    merged[0...-1] = merged[0...-1].map{|value|
      if value == UNKNOWN_TAIL
        nil
      else
        value
      end
    }
    
    merged = merged.map{|value|
      if is_tails.shift
        value
      else
        [value]
      end
    }
    merged = merged.flatten(1)
    merged = merged[0...fixed_length] if fixed_length
    
    [merged, unifications]
  end
  
  # Unifies Arrays where each Array is a Head/Tail array.
  # @param arrays [Array<Array>] the Arrays to be unified.
  # @param arrays_goals [Array<Porolog::Goal>] the Goals of the Arrays to be unified.
  # @param visited [Array] prevents infinite recursion.
  # @return [Array<Array, Array>] the merged Array and the unifications to be instantiated.
  # @return [nil] if the Arrays cannot be unified.
  def unify_headtail_with_headtail(arrays, arrays_goals, visited)
    unless arrays.all?(&:headtail?)
      msg = "Wrong method called to unify #{arrays.inspect}"
      arrays_goals.uniq.each do |goal|
        goal.log << msg
      end
      return nil
    end
    
    unifications = []
    
    arrays.combination(2).each do |pair|
      # -- Collect Goals --
      pair_goals = pair.map{|array| arrays_goals[arrays.index(array)] }
      
      # -- Unify Heads --
      heads = pair.map(&:first)
      subunifications = unify(*heads, *pair_goals, visited)
      if subunifications
        unifications += subunifications
      else
        unifications = nil
        msg = "Cannot unify headtail heads: #{heads.map(&:inspect).join(' with ').inspect}"
        pair_goals.uniq.each do |goal|
          goal.log  << msg
        end

        return nil
      end
      
      # -- Unify Tails --
      tails = pair.map(&:last).map{|tail| tail.value(visited) }
      subunifications = unify(*tails, *pair_goals, visited)
      if subunifications
        unifications += subunifications
      else
        unifications = nil
        msg = "Cannot unify headtail tails: #{tails.map(&:inspect).join(' with ')}"
        pair_goals.uniq.each do |goal|
          goal.log  << msg
        end

        return nil
      end
    end
    
    # -- Determine Merged --
    merged = [
      arrays.map(&:first).map{|head| head.value(visited) }.reject{|head| head.type == :variable }.first,
      *arrays.map(&:last).map{|tail| tail.value(visited) }.reject{|tail| tail.type == :variable || tail == UNKNOWN_TAIL }.first || UNKNOWN_TAIL,
    ]
    
    [merged, unifications]
  end
  
  # Unifies Arrays where Arrays with a Tail are unified with Arrays without a Tail.
  # @param arrays [Array<Array>] the Arrays to be unified.
  # @param arrays_goals [Array<Porolog::Goal>] the Goals of the Arrays to be unified.
  # @param visited [Array] prevents infinite recursion.
  # @return [Array<Array, Array>] the merged Array and the unifications to be instantiated.
  # @return [nil] if the Arrays cannot be unified.
  def unify_arrays_with_some_tails(arrays, arrays_goals, visited)
    # -- Variablise Arrays --
    arrays = arrays_goals.zip(arrays).map{|goal,array|
      if goal.nil?
        goal = array.goal        if array.is_a?(Value)
        if goal.nil? && array.is_a?(Array)
          v = array.find{|element| element.respond_to?(:goal) }
          goal = v && v.goal
        end
      end
      goal = arrays_goals.compact.last if goal.nil?
      raise NoGoalError, "#{array.inspect} has no associated goal!  Cannot variablise!" if goal.nil? || !goal.is_a?(Goal)
      goal.variablise(array)
    }
    
    # -- Some unknown tails --
    tailed_arrays, finite_arrays = arrays.partition{|array| has_tail?(array) }
    
    finite_sizes = finite_arrays.reject{|finite_array| finite_array.type == :variable }.map(&:size).uniq
    
    unless finite_sizes.size == 1
      msg = "Cannot unify different sizes of arrays: #{arrays.map(&:inspect).join(' with ')}"
      arrays_goals.uniq.each do |goal|
        goal.log << msg
      end
      return nil
    end
    
    exact_size = finite_sizes.first
    
    tails         = tailed_arrays.map{|array| [array[0...-1].size,array.last,arrays_goals[arrays.index(array)]] }
    tailed_arrays = tailed_arrays.map{|array| array[0...-1] }
    
    # -- Fail --
    #   [nil,nil,nil,nil,...]
    #   [1,  2,  3]
    min_tailed_size = tailed_arrays.map(&:size).max
    
    if min_tailed_size > exact_size
      msg = "Cannot unify enough elements: #{arrays.map(&:inspect).join(' with ')}"
      arrays_goals.uniq.each do |goal|
        goal.log << msg
      end
      return nil
    end
    
    # -- Succeed --
    #   [nil,nil,...]
    #   [1,  2,  3]
    arrays = tailed_arrays + finite_arrays
    
    zip_arrays = arrays.map{|array|
      if array.is_a?(Value) && array.value.is_a?(Array)
        array.value.map{|v|
          if v.type == :variable
            array.goal.variable(v)
          else
            array.goal.value(v)
          end
        }
      elsif array.type == :variable
        array.goal.value_of(array)
      else
        array
      end
    }.select{|array| array.is_a?(Array) }
    
    zipped       = ([nil] * exact_size).zip(*zip_arrays).map(&:uniq).map(&:compact)
    merged       = []
    unifications = []
    
    zipped.each{|zipped_values|
      values = zipped_values
      value = values.reject{|v| v.value(visited).nil? }.compact.uniq
      value_values = value.map(&:value).compact.uniq
      if value_values.size <= 1
        m = value.first.value
        m = nil if m.type == :variable
        merged << m
      else
        if values.variables.empty?
          msg = "Cannot unify enough elements: #{values.map(&:inspect).join(' with ')}"
          arrays_goals.uniq.each do |goal|
            goal.log << msg
          end
          return nil
        else
          _variables, nonvariables = values.reject{|v| v.value.nil? }.partition{|element| element.type == :variable }
          if nonvariables.value.uniq.size <= 1
            m = nonvariables.first.value
            m = nil if m.type == :variable
            merged << m
            
            value.combination(2).each do |vl, vr|
              if vl.type == :variable
                unifications << [vl, vr, vl.goal, vr.goal]
              elsif vr.type == :variable
                unifications << [vr, vl, vr.goal, vl.goal]
              end
            end
          else
            msg = "Cannot unify non-variables: #{nonvariables.value.uniq.map(&:inspect).join(' with ')}"
            arrays_goals.uniq.each do |goal|
              goal.log << msg
            end
            return nil
          end
        end
      end
    }
    
    tails.each do |head_size,tail,goal|
      next if tail == UNKNOWN_TAIL
      merged_goals = arrays_goals - [goal] + [goal]
      unifications << [tail.value(visited).value(visited), merged[head_size..-1], goal, merged_goals.compact.first]
    end
    
    [merged, unifications]
  end
  
end

require_relative 'porolog/error'
require_relative 'porolog/core_ext'
require_relative 'porolog/scope'
require_relative 'porolog/predicate'
require_relative 'porolog/arguments'
require_relative 'porolog/rule'
require_relative 'porolog/goal'
require_relative 'porolog/variable'
require_relative 'porolog/value'
require_relative 'porolog/instantiation'
require_relative 'porolog/tail'
