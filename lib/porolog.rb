#
#   lib/porolog.rb      - Plain Old Ruby Objects Prolog Engine
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog

  # The most recent version of the Porolog gem.
  VERSION      = '0.0.4'
  # The most recent date of when the VERSION changed.
  VERSION_DATE = '2019-04-21'
  
  # A convenience method to create a Predicate, along with a method
  # that returns an Arguments based on the arguments provided to
  # the method.
  # @param names [Array<#to_sym>] names of the Predicates to create.
  # @return [Porolog::Predicate] Predicate created if only one name is provided
  # @return [Array<Porolog::Predicate>] Predicates created if multiple names are provided
  def predicate(*names)
    names = [names].flatten
    
    predicates = names.map{|name|
      method     = name.to_sym
      predicate  = Predicate.new(name)
      Object.class_eval{
        define_method(method){|*args|
          predicate.(*args)
        }
      }
      predicate
    }
    
    predicates.size > 1 && predicates || predicates.first
  end
  
end

require_relative 'porolog/error'
require_relative 'porolog/scope'
require_relative 'porolog/predicate'
require_relative 'porolog/arguments'
