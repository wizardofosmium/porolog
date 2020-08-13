#
#   lib/porolog/core_ext.rb      - Plain Old Ruby Objects Prolog Engine -- Core Extensions
#
#     Luis Esteban   2 May 2018
#       created
#
# @author Luis Esteban
# Extends Core Ruy Classes
#

# In Porolog, Objects represent atomic values.
class Object
  
  # A convenience method for testing/debugging.
  # @return [String] the equivalent of inspect.
  def myid
    inspect
  end
  
  # @return [Array] embedded variables (for an Object, should be none).
  def variables
    []
  end
  
  # @return [Symbol] the type of the object (for an Object, should be :atomic)
  def type
    :atomic
  end
  
  # @return [Object] the value of the object, which is itself.
  def value(*)
    self
  end
  
  # @param other [Object] the Object which is to be the tail
  # @return [Array] an Array with the Object being the head and the other Object being the tail.
  # @example
  #   'head' / ['body', 'foot']   # ==> ['head', 'body', 'foot']
  #   7.tail(:t)                  # ==> [7, *:t]
  def tail(other)
    [self]/other
  end
  
  # Syntactic sugar to look like Prolog's [H|T]
  alias / :tail
  
  # @return [Boolean] whether the Object is an Array with a head and a tail (for an Object, should be false).
  def headtail?
    false
  end
  
end


# In Porolog, Symbols represent Variables.
class Symbol
  
  # A convenience method for testing/debugging.
  # @return [String] the equivalent of inspect.
  def myid
    inspect
  end
  
  # @return [Array] embedded variables (for a Symbol, should be itself).
  def variables
    [self]
  end
  
  # @return [Symbol] the type of the object (for a Symbol, should be :variable)
  def type
    :variable
  end
  
  # @param other [Object] the Object which is to be the tail
  # @return [Array] an Array with the Object being the head and the other Object being the tail.
  def /(other)
    [self]/other
  end
  
end


# In Porolog, Arrays are the equivalent of lists.
class Array
  
  # @return [Array] embedded variables.
  def variables
    map(&:variables).flatten
  end
  
  # @return [Array] the values of its elements.
  def value(visited = [])
    return self if visited.include?(self)
    visited = visited + [self]
    flat_map{|element|
      if element.is_a?(Porolog::Tail)
        tail = element.value(visited)
        if tail.is_a?(Array)
          tail
        elsif tail.is_a?(Porolog::Variable) || tail.is_a?(Porolog::Value)
          tail = tail.value(visited)
          if tail.is_a?(Array)
            tail
          elsif tail.is_a?(Porolog::Variable) || tail.is_a?(Porolog::Value)
            tail = tail.goal.variablise(tail.value(visited))
            if tail.is_a?(Array)
              tail
            else
              [element]
            end
          else
            [element]
          end
        else
          [element]
        end
      else
        [element.value(visited)]
      end
    }
  end
  
  # Removes Porolog processing objects.
  # @return [Array] the values of its elements with variables replaced by nil and Tails replaced by UNKNOWN_TAIL.
  def clean
    value.map{|element|
      if element.is_a?(Array)
        element.clean
      elsif element.is_a?(Porolog::Tail)
        Porolog::UNKNOWN_TAIL
      elsif element.is_a?(Porolog::Variable)
        nil
      else
        element.value
      end
    }
  end
  
  # @return [Symbol] the type of the object (for an Array, should be :array)
  def type
    :array
  end
  
  # @param other [Object] the Object which is to be the tail
  # @return [Array] an Array with the Object being the head and the other Object being the tail.
  def /(other)
    if other.is_a?(Porolog::Variable) || other.is_a?(Symbol)
      self + [Porolog::Tail.new(other)]
    else
      self + [*other]
    end
  end
  
  # @param head_size [Integer] specifies the size of the head
  # @return [Object] the head of the Array
  def head(head_size = 1)
    if head_size == 1
      if first == Porolog::UNKNOWN_TAIL
        nil
      else
        first
      end
    else
      self[0...head_size]
    end
  end
  
  # @param head_size [Integer] specifies the size of the head
  # @return [Object] the tail of the Array
  def tail(head_size = 1)
    if last == Porolog::UNKNOWN_TAIL
      [*self[head_size..-2], Porolog::UNKNOWN_TAIL]
    else
      [*self[head_size..-1]]
    end
  end
  
  # @return [Boolean] whether the Object is an Array with a head and a tail.
  def headtail?
    length == 2 && (last.is_a?(Porolog::Tail) || last == Porolog::UNKNOWN_TAIL)
  end
  
  # @return [Porolog::Goal] the goal that is most likely to be the goal for this array.
  def goal
    map{|element| element.goal if element.respond_to?(:goal) }.flatten.find{|goal| goal.is_a?(Porolog::Goal) }
  end
  
end
