#
#   Rakefile    - Porolog Rakefile
#
#     2 May 2018
#

require 'rake/testtask'
require 'yard'


# -- Run All Tests Task --
Rake::TestTask.new do |task|
  task.libs    << 'test'
  task.pattern  = 'test/porolog/*_test.rb'
end

# -- Create Separate Test Tasks --
Dir['test/porolog/*_test.rb'].each do |test_file|
  name = File.basename(test_file, '.rb')
  Rake::TestTask.new(name) do |task|
    task.verbose    = true
    task.options    = '--verbose'
    task.libs      << 'test'
    task.pattern    = test_file
    task.warning    = nil
  end
end

# -- Documentation Task --
YARD::Rake::YardocTask.new('doc') do |task|
  task.stats_options = ['--list-undoc']
end

# -- Tasks --
task default: :test

desc 'Help'
task :help do
  puts <<-EOF
    Porolog is a Ruby library.
    See README.md for more information.
    See doc/index.html for documentation.
    Run
      rake -T
    for other tasks.
  EOF
end
