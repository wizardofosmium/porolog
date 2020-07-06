#
#   force_head.rb     - Crude mergetool to force HEAD and remove master
#
#     Luis Esteban    7 July 2020
#       created
#

FILENAME = 'index.html'

copy = true

File.open("new_#{FILENAME}",'w') do |output|
  File.readlines(FILENAME).each do |line|
    case line
      when "=======\n"
        copy = false
      when ">>>>>>> master\n"
        copy = true
      else
        if copy
          output.puts line
        end
    end
  end
end
