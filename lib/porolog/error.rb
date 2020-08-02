#
#   lib/porolog/error.rb      - Plain Old Ruby Objects Prolog Engine -- Error
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog

  # Error class to enable rescuing or detecting any Porolog error.
  #
  # @author Luis Esteban
  #
  class PorologError < RuntimeError ; end
  
  # Error indicating that a Goal is needed but could not be found.
  class NoGoalError  < PorologError ; end
  
  # Error indicating that a Variable is needed but was not provided.
  class NonVariableError  < PorologError ; end

end
