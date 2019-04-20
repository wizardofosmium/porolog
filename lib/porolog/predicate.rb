#
#   lib/porolog/predicate.rb      - Plain Old Ruby Objects Prolog Engine -- Predicate
#
#     Luis Esteban   2 May 2018
#       created
#

# Porolog::Predicate
#
#   A Porolog::Predicate corresponds to a Prolog predicate.
#   It contains rules (Porolog::Rule) and belongs to a Porolog::Scope.
#   When provided with arguments, it produces a Porolog::Arguments.
#

module Porolog
  
  class Predicate
    
    class PredicateError < PorologError   ; end
    class NameError      < PredicateError ; end
    
    attr_reader :name, :rules
    
    @@current_scope        = Scope[:default]
    @builtin_predicate_ids = {}
    
    def self.scope(scope_name = nil)
      if scope_name
        @@current_scope = Scope[scope_name] || Scope.new(scope_name)
      else
        @@current_scope
      end
    end
    
    def self.scope=(scope_name)
      if scope_name
        @@current_scope = Scope[scope_name] || Scope.new(scope_name)
      end
    end
    
    def self.reset
      scope(:default)
      @builtin_predicate_ids = {}
    end
    
    def self.[](name)
      @@current_scope[name]
    end
    
    reset
    
    def initialize(name, scope_name = Predicate.scope.name)
      @name  = name.to_sym
      @rules = []
      
      raise NameError.new("Cannot name a predicate 'predicate'") if @name == :predicate
      
      scope = Scope[scope_name] || Scope.new(scope_name)
      scope[@name] = self
    end
    
    def self.new(*args)
      name, _ = *args
      scope[name.to_sym] || super
    end
    
    def call(*args)
      Arguments.new(self,args)
    end
    
    def arguments(*args)
      Arguments.new(self,args)
    end
    
    def <<(rule)
      @rules << rule
    end
    
    def inspect
      lines = []
      
      if @rules.size == 1
        lines << "#{@name}:-#{@rules.first.inspect}"
      else
        lines << "#{@name}:-"
        @rules.each do |rule|
          lines << rule.inspect
        end
      end
        
      lines.join("\n")
    end
    
    def self.builtin(key)
      @builtin_predicate_ids[key] ||= 0
      @builtin_predicate_ids[key]  += 1
      
      self.new("_#{key}_#{@builtin_predicate_ids[key]}")
    end
    
  end

end
