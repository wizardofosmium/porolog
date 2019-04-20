#
#   lib/porolog/error.rb      - Plain Old Ruby Objects Prolog Engine -- Error
#
#     Luis Esteban   2 May 2018
#       created
#

module Porolog

  # Error class to enable rescuing or detecting any Porolog error.
  class PorologError < RuntimeError ; end

end
