# porolog

<img src="https://repository-images.githubusercontent.com/131847563/b3754100-636a-11e9-995b-20d409b992c9" width="240" height="120" align="right" />

Plain Old Ruby Objects Prolog

[![Gem Version](https://badge.fury.io/rb/porolog.svg)](https://badge.fury.io/rb/porolog)
[![Build Status](https://travis-ci.com/wizardofosmium/porolog.svg?branch=master)](https://travis-ci.com/wizardofosmium/porolog)
[![Coverage](https://github.com/wizardofosmium/porolog/blob/master/coverage/badge.svg)](https://github.com/wizardofosmium/porolog)

## Introduction

`porolog` is a Prolog implementation using plain old Ruby objects with the aim that
logic queries can be called within a regular Ruby program.  The goal was not to
implement a Prolog interpreter that is just implement in Ruby, but rather that
a logic engine could be embedded in a larger program.

The need that this gem aims to meet is to have a Ruby program interact with a Prolog
program using native Ruby objects (POROs); hence the name Porolog.
The goal was to implement a minimal logic engine in the style of Prolog where
Ruby objects could be passed in and Ruby objects were passed back.

This version completes the minimal/generic logic engine along with some standard builtin predicates.
Custom builtin predicates can be easily added.

## Dependencies

The aim of `porolog` is to provide a logic engine with a minimal footprint.
The only extra dependency is Yard for documentation.

## Installation

```bash
gem install porolog
```

## Usage

`porolog` is used by:

* requiring the library within a Ruby program
* defining facts and rules
* solving goals

It is entirely possible to create a Ruby program that is effectively just a Prolog program.
The main purpose of Porolog though is to add declarative logic programming to Ruby and
allow hybrid programming, in the same way that Ruby allows hybrid programming in the
functional programming paradigm.

This then enables Ruby programs to be written spanning all the major programming paradigms:
- Imperative
- Functional
- Object Oriented
- Declarative Logic

### Basic Usage

Using `porolog` involves creating logic from facts and rules.
An example of the most basic usage, using just facts.

```ruby
require 'porolog'

prime = Porolog::Predicate.new :prime

prime.(2).fact!
prime.(3).fact!
prime.(5).fact!
prime.(7).fact!

solutions = prime.(:X).solve

solutions.each do |solution|
  puts "#{solution[:X]} is prime"
end
```

### Common Usage

Common usage is expected to be including Porolog in a class and encapsulating the engine defined.

```ruby
require 'porolog'

include Porolog

class Numbers

  Predicate.scope self
  predicate :prime, class_base: self

  prime(2).fact!
  prime(3).fact!
  prime(5).fact!
  prime(7).fact!

  def show_primes
    solutions = prime(:X).solve

    solutions.each do |solution|
      puts "#{solution[:X]} is prime"
    end
  end

  def primes
    prime(:X).solve_for(:X)
  end

end


numbers = Numbers.new
numbers.show_primes
puts numbers.primes.inspect
```

### Scope and Predicate Usage

A Predicate represents a Prolog predicate.  They form the basis for rules and queries.

The Scope class enables you to have multiple logic programs embedded in the same
Ruby program.  A Scope object defines a scope for the predicates of a logic programme.
This allows you to have different predicates with the same name.

```ruby
require 'porolog'

# -- Prime Numbers Predicate --
prime = prime1 = Porolog::Predicate.new :prime, :numbers

prime.(2).fact!
prime.(3).fact!
prime.(5).fact!
prime.(7).fact!
prime.(11).fact!

# -- Pump Predicate --
prime = prime2 = Porolog::Predicate.new :prime, :pumps

prime.('pump A').fact!
prime.('pump B').fact!
prime.('pump C').fact!
prime.('pump D').fact!

# -- Assertions --
assert_equal  [:default,:numbers,:pumps],     Scope.scopes
assert_equal  :prime,                         prime1.name
assert_equal  :prime,                         prime2.name

solutions = [
  { X:  2 },
  { X:  3 },
  { X:  5 },
  { X:  7 },
  { X: 11 },
]
assert_equal  solutions,  prime1.(:X).solve

solutions = [
  { X: 'pump A' },
  { X: 'pump B' },
  { X: 'pump C' },
  { X: 'pump D' },
]
assert_equal  solutions,  prime2.(:X).solve
```

### A Complete Example

This example shows:

* how to define facts,
* how to define rules,
* how to encapsulate predicates within a class,
* how to specify a cut,
* how to use builtin predicates, and
* how to initiate queries.

```ruby
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
```

### Porolog Wiki

See the Wiki for further details.
https://github.com/wizardofosmium/porolog/wiki

## Testing

```bash
rake test
```

or

```bash
rake core_ext_test
rake porolog_test
rake scope_test
rake predicate_test
rake arguments_test
rake rule_test
rake goal_test
rake variable_test
rake value_test
rake tail_test
rake instantiation_test
```

## Author

Luis Esteban MSc MTeach
