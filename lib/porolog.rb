#
#   lib/porolog.rb      - Plain Old Ruby Objects Prolog Engine
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog

  VERSION      = '0.0.2'
  VERSION_DATE = '2019-04-20'
  
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
