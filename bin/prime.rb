#!/usr/bin/env ruby
#
#   bin/prime.rb   - Executable
#
#     Luis Esteban  2 August 2020
#       created
#

require 'porolog'

include Porolog

class Numbers

  Predicate.scope self
  builtin   :gtr, :is, :noteq, :between,  class_base: self
  predicate :prime, :search_prime,        class_base: self

  prime(2).fact!
  prime(3).fact!
  prime(:X) << [
    between(:X, 4, 100),
    is(:X_mod_2, :X) {|x| x % 2 },
    noteq(:X_mod_2, 0),
    :CUT,
    search_prime(:X, 3),
  ]

  search_prime(:X, :N) << [
    is(:N_squared, :N) {|n| n ** 2 },
    gtr(:N_squared, :X),
    :CUT
  ]

  search_prime(:X, :N) << [
    is(:X_mod_N, :X, :N) {|x,n| x % n },
    noteq(:X_mod_N, 0),
    is(:M, :N) {|n| n + 2 },
    :CUT,
    search_prime(:X, :M),
  ]

  def show_primes
    solutions = prime(:X).solve

    solutions.each do |solution|
      puts "#{solution[:X]} is prime"
    end
  end

  def primes
    Numbers.prime(:X).solve_for(:X)
  end
  
  def self.kind(number)
    prime(number).valid? ? 'prime' : 'not prime'
  end
  
  def initialize(number)
    @number = number
  end
  
  def kind
    prime(@number).valid? ? :prime : :not_prime
  end

end


numbers = Numbers.new 23
numbers.show_primes
puts numbers.primes.inspect

puts Numbers.prime(3).valid?.inspect

puts ARGV.inspect
ARGV.map(&:to_i).each do |arg|
  puts "#{arg.inspect} is #{Numbers.kind(arg)}"
  number = Numbers.new arg
  puts number.kind.inspect
end
