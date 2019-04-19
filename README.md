# porolog

Plain Old Ruby Objects Prolog

## Introduction

porolog is a Prolog implementation using plain old Ruby objects with the aim that
logic queries can be called within a regular Ruby program.  The goal was not to
implement a Prolog interpreter that is just implement in Ruby, but rather that
a logic engine could be embedded in a larger program.

The goal was to implement a minimal logic engine in the style of Prolog where
Ruby objects could be passed in and Ruby objects were passed back.

## Installation

  gem install porolog

## Usage

### Basic Usage

  require 'porolog'

  prime = Predicate.new :prime

  prime.(2).fact!
  prime.(3).fact!
  prime.(5).fact!
  prime.(7).fact!

  solutions = prime.(:X).solve

  solutions.each do |solution|
    puts "#{solution[:X]} is prime"
  end


### Common Usage

  require 'porolog'

  include Porolog

  predicate :prime

  prime(2).fact!
  prime(3).fact!
  prime(5).fact!
  prime(7).fact!

  solutions = prime(:X).solve

  solutions.each do |solution|
    puts "#{solution[:X]} is prime"
  end

### Scope Usage

The Scope class enables you to have multiple logic programs embedded in the same
Ruby program.  A Scope object defines a scope for the predicates of a logic programme.

  require 'porolog'

  # -- Prime Numbers Predicate --
  prime = prime1 = Predicate.new :prime, :numbers

  prime.(2).fact!
  prime.(3).fact!
  prime.(5).fact!
  prime.(7).fact!
  prime.(11).fact!

  # -- Pump Predicate --
  prime = prime2 = Predicate.new :prime, :pumps

  prime.('pump A').fact!
  prime.('pump B').fact!
  prime.('pump C').fact!
  prime.('pump D').fact!

  assert_equal        [:default,:numbers,:pumps],     Scope.scopes

  assert_scope        Scope[:default],  :default, []
  assert_scope        Scope[:numbers],  :first,   [prime1]
  assert_scope        Scope[:pumps],    :second,  [prime2]

  assert_equal        :prime,     prime1.name
  assert_equal        :prime,     prime2.name

  solutions = [
    { X:  2 },
    { X:  3 },
    { X:  5 },
    { X:  7 },
    { X: 11 },
  ]
  assert_equal        solutions,                prime1.(:X).solve

  solutions = [
    { X: 'pump A' },
    { X: 'pump B' },
    { X: 'pump C' },
    { X: 'pump D' },
  ]
  assert_equal        solutions,                prime2.(:X).solve


## Testing

  rake test

or

  rake scope_test

## Author

Luis Esteban MSc MTeach
