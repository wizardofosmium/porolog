#
#   lib/porolog/predicate/builtin.rb      - Plain Old Ruby Objects Prolog Engine -- Builtin Predicates
#
#     Luis Esteban   29 July 2020
#       created
#

module Porolog
  
  class Predicate
    
    # The Porolog::Predicate::Builtin module is a collection of the implementations of the builtin predicates.
    # It is possible to define custom builtin predicates.  Each builtin requires a goal and a block,
    # and should return the result of
    #   block.call(goal) || false
    # if the predicate is deemed successful; otherwise, it should return false.
    #
    # @author Luis Esteban
    #
    module Builtin
      
      # Corresponds to the standard Prolog print predicate.
      # `print` could not be used because of the clash with the Ruby method.
      # It outputs all arguments.  If an argument is a variable,
      # then if it is instantiated, its value is output; otherwise its name is output.
      # If the value is an Array, its inspect is output instead.
      # Use:
      #   write('X = ', :X, ', Y = ', :Y, "\n")
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param args [Array<Object>] the arguments to be passed to the provided block.
      # @return [Boolean] whether the goal was satisfied.
      def write(goal, block, *args)
        args = args.map(&:value).map(&:value)
        args = args.map{|arg|
          arg.is_a?(Array) ? arg.inspect : arg
        }
        args = args.map{|arg|
          arg.type == :variable ? arg.to_sym.inspect : arg
        }
        $stdout.print args.join
        block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog print and nl predicate.
      # `print` could not be used because of the clash with the Ruby method.
      # It outputs all arguments and a new line.  If an argument is a variable,
      # then if it is instantiated, its value is output; otherwise its name is output.
      # If the value is an Array, its inspect is output instead.
      # Use:
      #   writenl('X = ', :X, ', Y = ', :Y)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param args [Array<Object>] the arguments to be passed to the provided block.
      # @return [Boolean] whether the goal was satisfied.
      def writenl(goal, block, *args)
        args = args.map(&:value).map(&:value)
        args = args.map{|arg|
          arg.is_a?(Array) ? arg.inspect : arg
        }
        args = args.map{|arg|
          arg.type == :variable ? arg.to_sym.inspect : arg
        }
        $stdout.puts args.join
        block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog nl predicate.
      # It outputs a newline.
      # Use:
      #   nl
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @return [Boolean] whether the goal was satisfied.
      def nl(goal, block)
        $stdout.puts
        block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog is predicate.
      # It instantiates a Variable with the result of the provided block.
      # Use:
      #   is(:Y, :X) {|x| x + 1 }
      #   is(:name, :first, :last) {|first, last| [first, last] }
      #   is(:name, :first, :last) {|first, last| "#{first} #{last}" }
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param variable [Porolog::Variable] the Variable to be instantiated.
      # @param args [Array<Object>] the arguments to be passed to the provided block.
      # @param is_block [Proc] the block provided in the Goal's Arguments.
      # @return [Boolean] whether the goal was satisfied.
      def is(goal, block, variable, *args, &is_block)
        raise NonVariableError, "#{variable.inspect} is not a variable" unless variable.type == :variable
        
        result = is_block.call(*args.map(&:value).map(&:value))
        
        result && !!variable.instantiate(result) && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog var predicate.
      # It is satisfied if the argument is an uninstantiated variable.
      # Use:
      #   var(:X)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param variable [Porolog::Variable,Object] the argument to be tested.
      # @return [Boolean] whether the goal was satisfied.
      def var(goal, block, variable)
        variable.value.value.type == :variable && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog nonvar predicate.
      # It is satisfied if the argument is not an uninstantiated variable.
      # Use:
      #   nonvar(:X)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param variable [Porolog::Variable,Object] the argument to be tested.
      # @return [Boolean] whether the goal was satisfied.
      def nonvar(goal, block, variable)
        variable.value.value.type != :variable && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog atom predicate.
      # It is satisfied if the argument is a String.
      # Use:
      #   atom(:X)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param variable [Porolog::Variable,Object] the argument to be tested.
      # @return [Boolean] whether the goal was satisfied.
      def atom(goal, block, variable)
        variable.value.value.is_a?(String) && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog atomic predicate.
      # It is satisfied if the argument is a String or an Integer.
      # Use:
      #   atomic(:X)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param variable [Porolog::Variable,Object] the argument to be tested.
      # @return [Boolean] whether the goal was satisfied.
      def atomic(goal, block, variable)
        variable.value.value.type == :atomic && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog integer predicate.
      # It is satisfied if the argument is an Integer.
      # Use:
      #   integer(:X)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param variable [Porolog::Variable,Object] the argument to be tested.
      # @return [Boolean] whether the goal was satisfied.
      def integer(goal, block, variable)
        variable.value.value.is_a?(Integer) && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog == predicate.
      # It is satisfied if:
      # - it is provided with two values (or instantiated Variables) that are equal, or
      # - it is provided with two uninstantiaed Variables that are bound to each other.
      # Variables are not instantiated; however, if they are uninstantiated, they are
      # temporarily instantiated to a unique value to see if they are bound in some way.
      # Use:
      #   eq(:X, :Y)
      #   eq(:name, ['Sam', 'Smith'])
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param x [Object] the left hand side of the equality.
      # @param y [Object] the right hand side of the equality.
      # @return [Boolean] whether the goal was satisfied.
      def eq(goal, block, x, y)
        x = x.value.value
        y = y.value.value
        
        case [x.type, y.type]
          when [:variable, :variable]
            equal = false
            temporary_instantiation = x.instantiate UNIQUE_VALUE
            if temporary_instantiation
              equal = y.value.value == UNIQUE_VALUE
              temporary_instantiation.remove
            end
            equal
          else
            x == y
        end && block.call(goal) || false
      end
      
      # Corresponds to a synthesis of the standard Prolog == and is predicates.
      # The left hand side (i.e. the first parameter) must be a variable.
      # It compares equality if the left hand side is instantiated;
      # otherwise, it instantiates the left hand side to the right hand side.
      # It is satisfied if:
      # - the values are equal, or
      # - the variable can successfully be instantiated to the right hand side.
      # Use:
      #   is_eq(:X, :Y)
      #   is_eq(:name, ['Sam', 'Smith'])
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param x [Porolog::Variable] the left hand side of the equality / assignment.
      # @param y [Object] the right hand side of the equality / assignment.
      # @return [Boolean] whether the goal was satisfied.
      def is_eq(goal, block, x, y)
        return false unless x.type == :variable
        return block.call(goal) if x.value.value == y.value.value
        
        !!x.instantiate(y) && block.call(goal) || false
      end
      
      # Allows a plain Ruby block to be executed as a goal.
      # It is assumed to be successful unless evaluates to :fail .
      # Use:
      #   ruby(:X, :Y, :Z) {|x, y, z| csv << [x, y, z] }
      #   ruby { $stdout.print '.' }
      #   ruby {
      #     $stdout.puts 'Forcing backtracking ...'
      #     :fail
      #   }
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param args [Array<Object>] the arguments to be passed to the provided block.
      # @param ruby_block [Proc] the block provided in the Goal's Arguments.
      # @return [Boolean] whether the goal was satisfied.
      def ruby(goal, block, *args, &ruby_block)
        (ruby_block.call(goal, *args.map(&:value).map(&:value)) != :fail) && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog != predicate.
      # It is satisfied if:
      # - it is provided with two values (or instantiated Variables) that are unequal, or
      # - it is provided with two uninstantiaed Variables that are not bound to each other.
      # Variables are not instantiated; however, if they are uninstantiated, they are
      # temporarily instantiated to a unique value to see if they are bound in some way.
      # Use:
      #   noteq(:X, :Y)
      #   noteq(:name, ['Sam', 'Smith'])
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param x [Object] the left hand side of the inequality.
      # @param y [Object] the right hand side of the inequality.
      # @return [Boolean] whether the goal was satisfied.
      def noteq(goal, block, x, y)
        x = x.value.value
        y = y.value.value
        
        case [x.type, y.type]
          when [:variable, :variable]
            equal = false
            temporary_instantiation = x.instantiate UNIQUE_VALUE
            if temporary_instantiation
              equal = y.value.value == x.value.value
              temporary_instantiation.remove
            end
            !equal
          else
            x != y
        end && block.call(goal) || false
      end
      
      # This does not really correspond to a standard Prolog predicate.
      # It implements a basic constraint mechanism.
      # The Variable is instantiated (if possible) to all possible values provide
      # except for all exclusions.
      # Further, the exclusions are checked for collective uniqueness.
      # Use:
      #   is_noteq(:digit, (0..9).to_a, :second_digit, :fifth_digit)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param variable [Porolog::Variable] the variable being instantiated.
      # @param all_values [Array<Object>] all possible values (i.e. the domain) of the variable.
      # @param exclusions [Array<Object>] mutually exclusive values (or variables), which the variable cannot be.
      # @return [Boolean] whether the goal was satisfied.
      def is_noteq(goal, block, variable, all_values, *exclusions)
        return false unless variable.type == :variable
        
        all_values = all_values.map(&:value).map(&:value)
        exclusions = exclusions.map(&:value).map(&:value)
        
        possible_values = goal[Porolog::anonymous]
        
        if exclusions.uniq.size == exclusions.size
          !!possible_values.instantiate(all_values - exclusions) && Predicate.call_builtin(:member, goal, block, variable, possible_values) || false
        else
          false
        end
      end
      
      # Corresponds to the standard Prolog < predicate.
      # It is satisfied if:
      # - it is provided with two values (or instantiated Variables) where the first is less than the second.
      # Variables are not instantiated.
      # Use:
      #   less(:X, :Y)
      #   less(:X, 3)
      #   less(9, :Y)
      #   less(:name, 'max')
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param x [Object] the left hand side of the inequality.
      # @param y [Object] the right hand side of the inequality.
      # @return [Boolean] whether the goal was satisfied.
      def less(goal, block, x, y)
        x = x.value.value
        y = y.value.value
        
        if [x.type, y.type].include?(:variable)
          false
        else
          x < y
        end && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog > predicate.
      # It is satisfied if:
      # - it is provided with two values (or instantiated Variables) where the first is greater than the second.
      # Variables are not instantiated.
      # Use:
      #   gtr(:X, :Y)
      #   gtr(:X, 3)
      #   gtr(9, :Y)
      #   gtr(:name, 'max')
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param x [Object] the left hand side of the inequality.
      # @param y [Object] the right hand side of the inequality.
      # @return [Boolean] whether the goal was satisfied.
      def gtr(goal, block, x, y)
        x = x.value.value
        y = y.value.value
        
        if [x.type, y.type].include?(:variable)
          false
        else
          x > y
        end && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog <= predicate.
      # It is satisfied if:
      # - it is provided with two values (or instantiated Variables) where the first is less than or equal to the second, or
      # - it is provided with two uninstantiaed Variables that are bound to each other.
      # Variables are not instantiated (except temporarily to test if they are bound).
      # Use:
      #   lesseq(:X, :Y)
      #   lesseq(:X, 3)
      #   lesseq(9, :Y)
      #   lesseq(:name, 'max')
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param x [Object] the left hand side of the inequality.
      # @param y [Object] the right hand side of the inequality.
      # @return [Boolean] whether the goal was satisfied.
      def lesseq(goal, block, x, y)
        x = x.value.value
        y = y.value.value
        
        case [x.type, y.type]
          when [:variable, :variable]
            equal = false
            temporary_instantiation = x.instantiate UNIQUE_VALUE
            if temporary_instantiation
              equal = y.value.value == UNIQUE_VALUE
              temporary_instantiation.remove
            end
            equal
          else
            if [x.type, y.type].include?(:variable)
              false
            else
              x <= y
            end
        end && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog >= predicate.
      # It is satisfied if:
      # - it is provided with two values (or instantiated Variables) where the first is greater than or equal to the second, or
      # - it is provided with two uninstantiaed Variables that are bound to each other.
      # Variables are not instantiated (except temporarily to test if they are bound).
      # Use:
      #   gtreq(:X, :Y)
      #   gtreq(:X, 3)
      #   gtreq(9, :Y)
      #   gtreq(:name, 'max')
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param x [Object] the left hand side of the inequality.
      # @param y [Object] the right hand side of the inequality.
      # @return [Boolean] whether the goal was satisfied.
      def gtreq(goal, block, x, y)
        x = x.value.value
        y = y.value.value
        
        case [x.type, y.type]
          when [:variable, :variable]
            equal = false
            temporary_instantiation = x.instantiate UNIQUE_VALUE
            if temporary_instantiation
              equal = y.value.value == UNIQUE_VALUE
              temporary_instantiation.remove
            end
            equal
          else
            if [x.type, y.type].include?(:variable)
              false
            else
              x >= y
            end
        end && block.call(goal) || false
      end
      
      # Corresponds to the standard Prolog length predicate.
      # It is satisfied if:
      # - it is provided with an Array and an Integer where the Integer corresponds to the length of the Array,
      # - it is provided with an Array and a Variable and the Variable is successfully instantiated to the length of the Array, or
      # - it is provided with a Variable and an Integer where the Variable is successfully instantiated to an of anonymous variables.
      # Use:
      #   length([1,2,3,4], 4)
      #   length([1,2,3,4], :Length)
      #   length(:L, 4)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param list [Array,Porolog::Variable] the list.
      # @param length [Integer,Porolog::Variable] the length of the list.
      # @return [Boolean] whether the goal was satisfied.
      def length(goal, block, list, length)
        list   = list.value.value
        length = length.value.value
        
        case [list.type, length.type]
          when [:array, :atomic]
            list.length == length
          when [:variable, :atomic]
            list.instantiate(Array.new(length){goal[Porolog::anonymous]})
          when [:array, :variable]
            length.instantiate(list.length)
          else
            false
        end && block.call(goal) || false
      end
      
      # Does not correspond to a standard Prolog predicate.
      # This is a convenience Predicate to allow efficient control of
      # iteration as well as range comparison.
      # Use:
      #   between(5, 0, 9)
      #   between(:N, 0, 9)
      #   between(:N, :Upper, :Lower)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param variable [String,Integer,Porolog::Variable] the intermediate value or variable.
      # @param lower [String,Integer] the lower bound of the iteration or range.
      # @param upper [String,Integer] the upper bound of the iteration or range.
      # @return [Boolean] whether the goal was satisfied.
      def between(goal, block, variable, lower, upper)
        variable = variable.value.value
        lower    = lower.value.value
        upper    = upper.value.value
        
        case [variable.type, lower.type, upper.type]
          when [:atomic, :atomic, :atomic]
            (lower..upper) === variable && block.call(goal) || false
            
          when [:atomic, :variable, :variable]
            satisfied = false
            lower_instantiation = lower.instantiate(variable)
            upper_instantiation = lower_instantiation && upper.instantiate(variable)
            upper_instantiation && block.call(goal) && (satisfied = true)
            upper_instantiation&.remove
            lower_instantiation&.remove
            satisfied
            
          when [:atomic, :atomic, :variable]
            satisfied = false
            if variable >= lower
              upper_instantiation = upper.instantiate(variable)
              upper_instantiation && block.call(goal) && (satisfied = true)
              upper_instantiation&.remove
            end
            satisfied
            
          when [:atomic, :variable, :atomic]
            satisfied = false
            if variable <= upper
              lower_instantiation = lower.instantiate(variable)
              lower_instantiation && block.call(goal) && (satisfied = true)
              lower_instantiation&.remove
            end
            satisfied
            
          when [:variable, :atomic, :atomic]
            satisfied = false
            (lower..upper).each do |i|
              instantiation = variable.instantiate(i)
              instantiation && block.call(goal) && (satisfied = true) || false
              instantiation&.remove
              return satisfied if goal.terminated?
            end
            satisfied
            
          else
            false
        end
      end
      
      # Corresponds to the standard Prolog member predicate.
      # This implements the usual operation of member but also
      # provides the ability to generate lists that contain the
      # provided element, even if the element is an uninstantiated variable.
      # Use:
      #   member(3, [1,2,3,4,5])
      #   member(['Chris','Smith'], [['Foo','Bar'],['Boo','Far'],['Chris','Smith']])
      #   member(:X, [1,2,3,4,5])
      #   member(:X, :Y)
      #   member(:X, :Y, 5)
      #   member(3, :Y, 10)
      #   member(['Chris','Smith'], :Names, 16)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param element [Object] the element to be found in the provided or generated list.
      # @param list [Array,Porolog::Variable] the provided or generated list that is to contain the element.
      # @param limit [Integer] the number of lists to generate.
      # @return [Boolean] whether the goal was satisfied.
      def member(goal, block, element, list, limit = 100)
        element_value = element.value.value
        list          = list.value.value
        
        case [element_value.type, list.type]
          when [:atomic, :array], [:array, :array]
            satisfied = false
            list.each do |i|
              unifications = Porolog::unify(element_value, i, goal)
              if unifications
                instantiations = Porolog::instantiate_unifications(unifications)
                if instantiations
                  block.call(goal) && (satisfied = true)
                  instantiations.each(&:remove)
                end
              end
              
              return satisfied if goal.terminated?
            end
            satisfied
          
          when [:variable, :array]
            satisfied = false
            list.each do |i|
              instantiation = element_value.instantiate(i)
              instantiation && block.call(goal) && (satisfied = true)
              instantiation&.remove
              return satisfied if goal.terminated?
              satisfied = true
            end
            satisfied
            
          when [:variable, :variable], [:atomic, :variable], [:array, :variable]
            satisfied = false
            limit.times do |i|
              instantiation = list.instantiate([*Array.new(i){goal[Porolog::anonymous]}, element, Porolog::UNKNOWN_TAIL])
              instantiation && block.call(goal) && (satisfied = true)
              instantiation&.remove
              return satisfied if goal.terminated?
            end
            satisfied
            
          else
            false
        end
      end
      
      # Corresponds to the standard Prolog append predicate.
      # This implements the usual operation of member but also
      # provides the ability instantiate uninstantiated arguments
      # as an instnatiation of the concatenation of the first two arguments.
      # Use:
      #   append([1,2,3], [4,5,6], [1,2,3,4,5,6])
      #   append([1,2,3], [4,5,6], :C)
      #   append([1,2,3], :B, [1,2,3,4,5,6])
      #   append(:A, [4,5,6], [1,2,3,4,5,6])
      #   append(:A, :B, [1,2,3,4,5,6])
      #   append([1,2,3], :B, :C)
      #   append(:A, [4,5,6], :C)
      #   append(:A, :B, :C)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param front [Array,Porolog::Variable] the front portion of the combined front_back argument.
      # @param back [Array,Porolog::Variable] the back portion of the combined front_back argument.
      # @param front_back [Array,Porolog::Variable] the combined argument of the front and back arguments.
      # @return [Boolean] whether the goal was satisfied.
      def append(goal, block, front, back, front_back)
        front       = front.value.value
        back        = back.value.value
        front_back  = front_back.value.value
        
        case [front.type, back.type, front_back.type]
          when [:array, :array, :array]
            satisfied = false
            if front.length + back.length == front_back.length
              unifications   = Porolog::unify(front + back, front_back, goal)
              instantiations = Porolog::instantiate_unifications(unifications) if unifications
              instantiations && block.call(goal) && (satisfied = true)
              instantiations&.each(&:remove)
            end
            satisfied
            
          when [:array, :array, :variable]
            satisfied = false
            unifications   = Porolog::unify(front + back, front_back, goal)
            instantiations = Porolog::instantiate_unifications(unifications) if unifications
            instantiations && block.call(goal) && (satisfied = true)
            instantiations&.each(&:remove)
            satisfied
            
          when [:array, :variable, :array]
            satisfied = false
            if front.length <= front_back.length
              expected_front = front_back[0...front.length]
              expected_back  = front_back[front.length..-1]
              
              unifications   = Porolog::unify(front, expected_front, goal)
              unifications  += Porolog::unify(back,  expected_back,  goal)     if unifications
              instantiations = Porolog::instantiate_unifications(unifications) if unifications
              instantiations && block.call(goal) && (satisfied = true)
              instantiations&.each(&:remove)
            end
            satisfied
            
          when [:variable, :array, :array]
            satisfied = false
            if back.length <= front_back.length
              expected_front = front_back[0...-back.length]
              expected_back  = front_back[-back.length..-1]
              
              unifications   = Porolog::unify(front, expected_front, goal)
              unifications  += Porolog::unify(back,  expected_back,  goal)     if unifications
              instantiations = Porolog::instantiate_unifications(unifications) if unifications
              instantiations && block.call(goal) && (satisfied = true)
              instantiations&.each(&:remove)
            end
            satisfied
            
          when [:variable, :variable, :array]
            satisfied = false
            (front_back.length + 1).times do |i|
              expected_front = front_back[0...i]
              expected_back  = front_back[i..-1]
              
              unifications   = Porolog::unify(front, expected_front, goal)
              unifications  += Porolog::unify(back,  expected_back,  goal)     if unifications
              instantiations = Porolog::instantiate_unifications(unifications) if unifications
              instantiations && block.call(goal) && (satisfied = true)
              instantiations&.each(&:remove)
              return satisfied if goal.terminated?
            end
            satisfied
            
          when [:array, :variable, :variable]
            satisfied = false
            unifications   = Porolog::unify(front / back, front_back, goal)
            instantiations = Porolog::instantiate_unifications(unifications) if unifications
            instantiations && block.call(goal) && (satisfied = true)
            instantiations&.each(&:remove)
            satisfied
            
          when [:variable, :array, :variable]
            satisfied = false
            instantiation_head = front_back.instantiate(front, nil, :flathead)
            instantiation_tail = front_back.instantiate(back,  nil, :flattail)
            instantiations = [instantiation_head, instantiation_tail].compact
            instantiations = nil if instantiations.empty?
            instantiations && block.call(goal) && (satisfied = true)
            instantiations&.each(&:remove)
            satisfied
            
          when [:variable, :variable, :variable]
            satisfied = false
            instantiation_head = front_back.instantiate(front, nil, :flathead)
            instantiation_tail = front_back.instantiate(back,  nil, :flattail)
            instantiations = [instantiation_head, instantiation_tail].compact
            instantiations = nil if instantiations.empty?
            instantiations && block.call(goal) && (satisfied = true)
            instantiations&.each(&:remove)
            satisfied
            
          else
            false
        end
      end
      
      # Corresponds to the standard Prolog permutation predicate.
      # It not only returns whether one list is a permutation of the other
      # but also can generate permutations.
      # Use:
      #   permutation([3,1,2,4], [1,2,3,4])
      #   permutation([3,:A,2,4], [1,2,3,4])
      #   permutation([3,1,2,4], [1,2,:C,4])
      #   permutation([3,1,:B,4], [1,2,:C,4])
      #   permutation([3,1,2,4], :Q)
      #   permutation(:P, [1,2,3,4])
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param list1 [Array,Porolog::Variable] the first list.
      # @param list2 [Array,Porolog::Variable] the second list.
      # @return [Boolean] whether the goal was satisfied.
      def permutation(goal, block, list1, list2)
        # TODO: Detect and deal with tails
        #   E.g. permutation([:H]/:T, [1,...])
        list1       = list1.value.value
        list2       = list2.value.value
        
        case [list1.type, list2.type]
          when [:array, :array]
            satisfied = false
            case [list1.variables.empty?, list2.variables.empty?]
              when [true, true]
                list1 = list1.sort_by(&:inspect)
                list2 = list2.sort_by(&:inspect)
                
                unifications   = Porolog::unify(list1, list2, goal)
                instantiations = Porolog::instantiate_unifications(unifications) if unifications
                instantiations && block.call(goal) && (satisfied = true)
                instantiations&.each(&:remove)
              
              when [false, true], [false, false]
                list2.permutation do |p|
                  unifications   = Porolog::unify(list1, p, goal)
                  instantiations = nil
                  instantiations = Porolog::instantiate_unifications(unifications) if unifications
                  instantiations && block.call(goal) && (satisfied = true)
                  instantiations&.each(&:remove)
                  return satisfied if goal.terminated?
                end
              
              when [true, false]
                list1.permutation do |p|
                  unifications   = Porolog::unify(list2, p, goal)
                  instantiations = nil
                  instantiations = Porolog::instantiate_unifications(unifications) if unifications
                  instantiations && block.call(goal) && (satisfied = true)
                  instantiations&.each(&:remove)
                  return satisfied if goal.terminated?
                end
            end
            satisfied
            
          when [:array, :variable]
            satisfied = false
            list1.permutation do |p|
              unifications   = Porolog::unify(p, list2, goal)
              instantiations = Porolog::instantiate_unifications(unifications) if unifications
              instantiations && block.call(goal) && (satisfied = true)
              instantiations&.each(&:remove)
              return satisfied if goal.terminated?
            end
            satisfied
            
          when [:variable, :array]
            satisfied = false
            list2.permutation do |p|
              unifications   = Porolog::unify(list1, p, goal)
              instantiations = nil
              instantiations = Porolog::instantiate_unifications(unifications) if unifications
              instantiations && block.call(goal) && (satisfied = true)
              instantiations&.each(&:remove)
              return satisfied if goal.terminated?
            end
            satisfied
            
          else
            false
        end
      end
      
      # Corresponds to the standard Prolog reverse predicate.
      # It returns whether the lists are a reversal of each other,
      # or otherwise generates a reversed list.
      # Use:
      #   reverse([1,2,3,4], [4,3,2,1])
      #   reverse([1,:A,3,4], [4,3,2,1])
      #   reverse([1,2,3,4], [4,:B,2,1])
      #   reverse([1,:A,3,4], [4,:B,2,1])
      #   reverse(:L, [4,3,2,1])
      #   reverse([1,2,3,4], :L)
      # @param goal [Porolog::Goal] the Goal to satisfy the Predicate.
      # @param block [Proc] the continuation of solving to call if this Predicate is satisfied.
      # @param list1 [Array,Porolog::Variable] the first list.
      # @param list2 [Array,Porolog::Variable] the second list.
      # @return [Boolean] whether the goal was satisfied.
      def reverse(goal, block, list1, list2)
        # TODO: Detect and deal with tails
        #   E.g. reverse([:H]/:T, [1,...])
        list1 = list1.value.value
        list2 = list2.value.value
        
        case [list1.type, list2.type]
          when [:array, :array], [:variable, :array]
            satisfied = false
            unifications   = Porolog::unify(list1, list2.reverse, goal)
            instantiations = Porolog::instantiate_unifications(unifications) if unifications
            instantiations && block.call(goal) && (satisfied = true)
            instantiations&.each(&:remove)
            satisfied
            
          when [:array, :variable]
            satisfied = false
            unifications   = Porolog::unify(list1.reverse, list2, goal)
            instantiations = Porolog::instantiate_unifications(unifications) if unifications
            instantiations && block.call(goal) && (satisfied = true)
            instantiations&.each(&:remove)
            satisfied
            
          else
            false
        end
      end
      
    end
  
  end
  
end
