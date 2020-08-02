#
#   test/samples_test.rb     - Test Suite for Porolog::Predicate
#
#     Luis Esteban      13 July 2020
#       created
#

require_relative 'test_helper'

describe 'Porolog' do
  
  before(:all) do
    reset
  end
  
  it 'implements delete first predicate' do
    predicate :delete
    
    delete(:X, [:X]/:T, :T).fact!

    assert_solutions  delete(9, [1,2,3,4], [2,3,4]), []
    assert_solutions  delete(1, [1,2,3,4], [2,3,4]), [{}]

    assert_solutions  delete(:Removed, [1,2,3,4], [2,3,4]),   [{ Removed: 1 }]
    assert_solutions  delete(1, :Original, [2,3,4]),          [{ Original: [1,2,3,4] }]
    assert_solutions  delete(1, [1,2,3,4], :Result),          [{ Result: [2,3,4] }]
    assert_solutions  delete(1, [:First,2,3,4], [2,3,4]),     [{ First: 1 }]
    assert_solutions  delete(1, [1,:Second,3,4], [2,3,4]),    [{ Second: 2 }]
    assert_solutions  delete(1, [1,2,:Third,4], [2,3,4]),     [{ Third: 3 }]
    assert_solutions  delete(1, [1,2,3,4], [:Second,3,4]),    [{ Second: 2 }]
    assert_solutions  delete(1, [1,2,3,4], [:A, :B, :C]),     [{ A: 2, B: 3, C: 4 }]
    assert_solutions  delete(1, [:A,2,3,:D], [:B,3,4]),       [{ A: 1, B: 2, D: 4 }]
  end
  
  it 'implements the delete predicate' do
    builtin :write
    predicate :delete
    
    delete(:X, [:X]/:T, :T).fact!
    delete(:X, [:H]/:T, [:H]/:NT) << [
      delete(:X, :T, :NT),
    ]
    
    assert_solutions  delete(1, [1,2,3,4], [1,2,4]),  [], goals: 9
    assert_solutions  delete(3, [1,2,3,4], [1,2,4]),  [{}]
    assert_solutions  delete(4, [1,2,3,4], [1,2,3]),  [{}]
    assert_solutions  delete(4, [1,2,3,4], [1,2,:X]), [{ X: 3 }]
    
    assert_solutions  delete(:Removed, [1,2,3,4], [1,2,4]), [
      { Removed: 3 }
    ]

    assert_solutions  delete(:Removed, [1,2,3,4], [1,2,3]), [
      { Removed: 4 }
    ]

    assert_solutions  delete(3, :Original, [1,2,4]), [
      { Original: [3, 1, 2, 4] },
      { Original: [1, 3, 2, 4] },
      { Original: [1, 2, 3, 4] },
      { Original: [1, 2, 4, 3] },
    ]

    assert_solutions  delete(:X, [1,2,3,4], :L), [
      { X: 1, L: [2, 3, 4] },
      { X: 2, L: [1, 3, 4] },
      { X: 3, L: [1, 2, 4] },
      { X: 4, L: [1, 2, 3] },
    ]

    assert_solutions  delete(:X, [1,2,3,4], [:A,:B,:C]), [
      { X: 1, A: 2, B: 3, C: 4 },
      { X: 2, A: 1, B: 3, C: 4 },
      { X: 3, A: 1, B: 2, C: 4 },
      { X: 4, A: 1, B: 2, C: 3 },
    ]
  end
  
  it 'implements the permutation predicate' do
    warn name
    predicate :delete, :permutation
    
    permutation([],[]).fact!
    permutation(:List, [:H]/:Permutation) << [
      delete(:H, :List, :Rest),
      permutation(:Rest, :Permutation)
    ]

    delete(:X, [:X]/:T, :T).fact!
    delete(:X, [:H]/:T, [:H]/:NT) << [
      delete(:X, :T, :NT),
    ]
    
    assert_solutions  permutation([1,2,3,4], [1,2,3,4]), [{}]
    assert_solutions  permutation([3,2,1,4], [1,2,3,4]), [{}]
    assert_solutions  permutation([3,2,:A,4], [1,2,3,4]), [
      { A: 1 }
    ]
    assert_solutions  permutation([3,2,:A,:B], [1,2,3,4]), [
      { A: 1, B: 4 },
      { A: 4, B: 1 },
    ]
    assert_solutions  permutation([3,2,:A,4], [1,2,:C,4]), [
      { A: 1, C: 3 }
    ]
    assert_solutions  permutation([2,3,1], :L), [
      { L: [2, 3, 1] },
      { L: [2, 1, 3] },
      { L: [3, 2, 1] },
      { L: [3, 1, 2] },
      { L: [1, 2, 3] },
      { L: [1, 3, 2] }
    ]
  end
  
  it 'solves the Einstein / Zebra riddle' do
    warn name
    builtin :is, :member, :is_noteq
    predicate :same, :not_same, :left, :beside, :houses

    same(:X,:X).fact!

    not_same(:X,:X).cut_falicy!
    not_same(:X,:Y).fact!

    (1..5).to_a.each_cons(2) do |left, right|
      left(left,right).fact!
      beside(left,right).fact!
      beside(right,left).fact!
    end

    HOUSES  = [1,       2,          3,        4,          5         ]

    PEOPLE  = [:Brit,   :Dane,      :Swede,   :German,    :Norwegian]
    SMOKES  = [:Blend,  :Pallmall,  :Dunhill, :Winfield,  :Rothmans ]
    PETS    = [:Dog,    :Cats,      :Fish,    :Birds,     :Horses   ]
    COLOURS = [:Red,    :Blue,      :Green,   :White,     :Yellow   ]
    DRINKS  = [:Tea,    :Beer,      :Milk,    :Water,     :Coffee   ]

    FISH_INDEX = PETS.index(:Fish)

    houses(:People, :Smokes, :Pets, :Colours, :Drinks) << [
      same(:Milk, 3),                             # 8.  The man living in the house right in the center drinks milk.
      same(:Norwegian, 1),                        # 9.  The Norwegian lives in the first house.
      left(:Green, :White),                       # 4.  The green house is on the left of the white house.
      beside(:Norwegian, :Blue),                  # 14. The Norwegian lives next to the blue house.
      not_same(:Blue, :White),
      beside(:Blend, :Water),                     # 15. The man who smokes Blend has a neighbour who drinks water.
      not_same(:Milk, :Water),
      beside(:Horses, :Dunhill),                  # 11. The man who keeps horses lives next to the man who smokes Dunhill.
      same(:Yellow, :Dunhill),                    # 7.  The owner of the yellow house smokes Dunhill.
      same(:Green, :Coffee),                      # 5.  The green house owner drinks coffee.
      not_same(:Milk, :Coffee),
      not_same(:Water, :Coffee),
      is_noteq(:Red, HOUSES, :Green, :White, :Blue, :Yellow),
      same(:Brit, :Red),                          # 1.  The Brit lives in a red house.
      not_same(:Brit, :Norwegian),
      beside(:Blend, :Cats),                      # 10. The man who smokes Blend lives next to the one who keeps cats.
      not_same(:Horses, :Cats),
      is_noteq(:Tea, HOUSES, :Coffee, :Milk, :Water),
      same(:Dane, :Tea),                          # 3.  The Dane drinks tea.
      is_noteq(:Beer, HOUSES, :Tea, :Coffee, :Milk, :Water),
      same(:Winfield, :Beer),                     # 12. The owner who smokes Winfield drinks beer.
      is_noteq(:German, HOUSES, :Norwegian, :Dane, :Brit),
      is_noteq(:Swede, HOUSES, :German, :Norwegian, :Dane, :Brit),
      same(:Swede, :Dog),                         # 2.  The Swede keeps a dog.
      is_noteq(:Pallmall, HOUSES, :Dunhill, :Blend, :Winfield),
      is_noteq(:Rothmans, HOUSES, :Pallmall, :Dunhill, :Blend, :Winfield),
      same(:Pallmall, :Birds),                    # 6.  The person who smokes Pall Mall keeps birds.
      same(:German, :Rothmans),                   # 13. The German smokes Rothmans.
      is_noteq(:Fish, HOUSES, :Dog, :Birds, :Cats, :Horses),
      
      same(:People,   PEOPLE),
      same(:Smokes,   SMOKES),
      same(:Pets,     PETS),
      same(:Colours,  COLOURS),
      same(:Drinks,   DRINKS),
    ]

    solutions = assert_solutions  houses(:People, :Smokes, :Pets, :Colours, :Drinks), [
      {
        People:   [3, 2, 5, 4, 1],
        Smokes:   [2, 3, 1, 5, 4],
        Pets:     [5, 1, 4, 3, 2],
        Colours:  [3, 2, 4, 5, 1],
        Drinks:   [2, 5, 3, 1, 4]
      }
    ], goals: 1873
    
    solution = solutions.first
    
    assert_equal  :German,    PEOPLE[solution[:People].index(solution[:Pets][FISH_INDEX])]
    
    def house_details(solution, h)
      [
        PEOPLE[solution[:People].index(h)],
        SMOKES[solution[:Smokes].index(h)],
        PETS[solution[:Pets].index(h)],
        COLOURS[solution[:Colours].index(h)],
        DRINKS[solution[:Drinks].index(h)]
      ]
    end
    
    assert_equal  [:Norwegian,  :Dunhill,   :Cats,    :Yellow,  :Water ], house_details(solution, 1)
    assert_equal  [:Dane,       :Blend,     :Horses,  :Blue,    :Tea   ], house_details(solution, 2)
    assert_equal  [:Brit,       :Pallmall,  :Birds,   :Red,     :Milk  ], house_details(solution, 3)
    assert_equal  [:German,     :Rothmans,  :Fish,    :Green,   :Coffee], house_details(solution, 4)
    assert_equal  [:Swede,      :Winfield,  :Dog,     :White,   :Beer  ], house_details(solution, 5)
  end
  
  it 'instantiates lists using member and length builtin predicates' do
    builtin :member, :length
    predicate :lists

    lists(:L) << [
      member(:N,[1,2,3,4,5]),
      length(:L, :N),
      member(:N, :L)
    ]

    assert_solutions  lists(:L), [
      { L: [1] },
      { L: [2, nil] },
      { L: [nil, 2] },
      { L: [3, nil, nil] },
      { L: [nil, 3, nil] },
      { L: [nil, nil, 3] },
      { L: [4, nil, nil, nil] },
      { L: [nil, 4, nil, nil] },
      { L: [nil, nil, 4, nil] },
      { L: [nil, nil, nil, 4] },
      { L: [5, nil, nil, nil, nil] },
      { L: [nil, 5, nil, nil, nil] },
      { L: [nil, nil, 5, nil, nil] },
      { L: [nil, nil, nil, 5, nil] },
      { L: [nil, nil, nil, nil, 5] },
    ], goals: 13
  end
  
  it 'implements a prime number search' do
    builtin   :gtr, :is, :noteq, :between
    predicate :prime, :search_prime

    prime(2).fact!
    prime(3).fact!
    prime(:X) << [
      between(:X, 4, 20000),
      is(:X_mod_2, :X){|x| x % 2 },
      noteq(:X_mod_2, 0),
      search_prime(:X, 3),
    ]

    search_prime(:X, :N) << [
      is(:N_squared, :N){|n| n ** 2 },
      gtr(:N_squared, :X),
      :CUT
    ]

    search_prime(:X, :N) << [
      is(:X_mod_N, :X, :N){|x,n| x % n },
      noteq(:X_mod_N, 0),
      is(:M, :N){|n| n + 2 },
      :CUT,
      search_prime(:X, :M),
    ]
    
    known_primes = [
      2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97,
      101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199,
      211, 223, 227, 229
    ]
    
    assert_equal    known_primes,     prime(:number).solve_for(:number, max_solutions: 50)
    assert_equal    3016,             Goal.goal_count
  end
    
end
