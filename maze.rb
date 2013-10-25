#!/usr/local/bin/ruby

# ########################################
# CMSC 330 - Project 1
# Name: Yuxue Mei
# ########################################

#-----------------------------------------------------------
# FUNCTION DECLARATIONS
#-----------------------------------------------------------

$closedCell = 0
$up = 0
$down = 0
$left = 0
$right = 0
$table = Hash.new("coordinates of whole table")
$pathsTable = Hash.new("cost of every single path")
$result = []
$tag = true
$invalid = []

#------------------------------------------------------------
# parse standard maze files
# if the file is not in the specified format, print invalid
# the path line can contain " and can have more than one
# file on the same line for the path line
# print standard maze files in simple file format

  def parse(file)
    line = file.gets
    if line == nil then return end
    counter = 0
    increase = 0
    
    # read 1st line, must be maze header, check if valid
    if line !~ /^maze:\s([\d]+)\s([\d]+):([\d]+)\s->\s([\d]+):([\d]+)$/
      if $tag
        $invalid[increase] = "invalid maze"
        increase = increase + 1
        $tag = false
      end
      $invalid[increase] = line
      increase = increase + 1
    else
      $result[counter] = "#{$1} #{$2} #{$3} #{$4} #{$5}"
      counter = counter + 1
    end

    # read additional lines
    while line = file.gets do
      x_y = '(\d),(\d)'
      direc = '([u|d|l|r]*)'
      mass = '([0-9]*).([0-9]*)'
      mass_s = '([0-9]*).([0-9]*)'
      total = mass_s + ',' + mass_s + ',' + mass_s + ',' + mass_s
      sum = Regexp.new('^' + x_y + ':\s' + direc + '\s' + total + '$')
      
      # begins with "path", must be path specification
      if line =~ /^"[^:\s]+:\([\d]+,[\d]+\)/
        line_o = line.split(/","/)
        
        i = 0
        while i < line_o.size
          if line_o[i] !~ /^"/
            line_o[i] = "\"#{line_o[i]}"
          end
          
          if line_o[i] !~ /"$/
            line_o[i] = "#{line_o[i]}\""
          end
          i = i + 1
        end
        
        i = 0
        while i < line_o.size
            if line_o[i] =~ /^"([^:\s]+):\(([\d]+),([\d]+)\),(([udlr],)*[udlr])"$/
            a = String.new("#{$1}")
            b = String.new("#{$2}")
            c = String.new("#{$3}")
            d = String.new("#{$4}")
            d.delete! ","
            
            j = 0
            while j < a.size
              if a[j] == 92 && a[j + 1] == 34
                a[j] = ""
              end
              j = j + 1
            end
            
            $result[counter] = "path #{a} #{b} #{c} #{d}"
            counter = counter + 1
          else
            if $tag
              $invalid[increase] = "invalid maze"
              increase = increase + 1
              $tag = false
            end
            $invalid[increase] = line
            increase = increase + 1
            i = line_o.size
          end
          i = i + 1
          
        end
        
      # otherwise must be cell specification (since maze spec must be valid)
      elsif line =~ /^([\d]+),([\d]+):\s*$/
        $result[counter] = "#{$1} #{$2}"
        counter = counter + 1
      elsif line =~ /^([\d]+),([\d]+): ([udlr]) ([0-9]+).([0-9]+)$/
        $result[counter] =  "#{$1} #{$2} #{$3} #{$4}.#{$5}"
        counter = counter + 1
      elsif line =~ /^([\d]+),([\d]+): ([udlr][udlr]) ([0-9]+).([0-9]+),([0-9]+).([0-9]+)$/
        $result[counter] =  "#{$1} #{$2} #{$3} #{$4}.#{$5} #{$6}.#{$7}"
        counter = counter + 1
      elsif line =~ /^([\d]+),([\d]+): ([udlr][udlr][udlr]) ([0-9]+).([0-9]+),([0-9]+).([0-9]+),([0-9]+).([0-9]+)$/
        $result[counter] =  "#{$1} #{$2} #{$3} #{$4}.#{$5} #{$6}.#{$7} #{$8}.#{$9}"
        counter = counter + 1
      elsif line =~ /^([\d]+),([\d]+): ([udlr][udlr][udlr][udlr]) ([0-9]+).([0-9]+),([0-9]+).([0-9]+),([0-9]+).([0-9]+),([0-9]+).([0-9]+)$/
        $result[counter] =  "#{$1} #{$2} #{$3} #{$4}.#{$5} #{$6}.#{$7} #{$8}.#{$9} #{$10}.#{$11}"
        counter = counter + 1
      else
        if $tag
          $invalid[increase] = "invalid maze"
          increase = increase + 1
          $tag = false
        end
        $invalid[increase] = line
        increase = increase + 1
      end
    end
    
    if $tag
      $result.collect{|i| puts i}
    else
      $invalid.collect{|i| puts i}
    end
  end
 
 #------------------------------------------------------------
 # rank paths by cost
 # such that given a path file, the paths specified in the file
 # must be followed in order to add up all of the weights
 # print out the order from least to most cost paths
 
  def path(file)
    p, name, x, y, ds = $path.split(/\s/)
    ds = ds.split(//)
    x = Integer(x)
    y = Integer(y)
    sum = 0.0
    
    i = 0
    while i < ds.length
      value = $table["#{x} #{y}"]
      value = value.to_s
      direction, weight = value.split(/\s/,2)
      index = direction.index(ds[i])
      
      direction = direction.split(/\s/)
      weight = weight.split(/\s/)
      weight.collect!{|j| j.to_f}
      
      case ds[i]
        when "u"
          y = y - 1
        when "d"
          y = y + 1
        when "l"
          x = x - 1
        when "r"
          x = x + 1
        end
      sum = sum + weight[index]
      $pathsTable[name] = sum
      i = i + 1
    end
  end 
  
  def path_helper(file)
    sorted = $pathsTable.sort {|a,b| a[1]<=>b[1]} 
    # combine the output into a single formatted string
    i = 0
    while i < sorted.size - 1
      $string = $string + "#{sorted[i][0]}, "
      $string.chomp!
      i = i + 1
    end
    if sorted[i] != nil
      $string = $string + sorted[i][0]
    end
  end
  
#-----------------------------------------------------------
# the following is a parser that reads in a simpler version
# of the maze files.  Use it to get started writing the rest
# of the assignment, if you like.  You can feel free to move
# or modify this function however you like in working on your
# assignment. Thanks so much for this file!

def read_and_print_simple_file(file, name2)
  line = file.gets
  if line == nil then return end

  # read 1st line, must be maze header
  sz, $sx, $sy, $ex, $ey = line.split(/\s/)
  $size = Integer(sz)
  
  $string = ""
  # read additional lines
  while line = file.gets do
    # begins with "path", must be path specification
    if line[0...4] == "path"
       $path = line
       p, name, x, y, ds = line.split(/\s/)
       
       # call the path method to calculate the path weight
       if name2 == "path"
         path(file)
       end
       
    # otherwise must be cell specification (since maze spec must be valid)
    else
       x, y, ds, w = line.split(/\s/,4)
       
       #put all of the coordinates into table whereas:
       # key = coordinate; value = directions and weight
       $table["#{x} #{y}"] = ["#{ds} #{w}"]
       
       #keep track of open cells
       u = ds.scan(/(u)/)
       $up =  $up + u.size
       d = ds.scan(/(d)/)
       $down = $down + d.size
       l = ds.scan(/(l)/)
       $left = $left + l.size
       r = ds.scan(/(r)/)
       $right = $right + r.size
       
       ws = w.split(/\s/)
       
       #keep track of closed cells
       if ws.size == 0
         $closedCell = $closedCell + 1;
       end
       
    end
  end
end

  #-----------------------------------------------------------
  # decide if the maze is solvable using DFS algorithm
  # sometimes the paths might not be specified in the file
  # output true if solvable or false if not
  
  def solve(file)
    x, y = Integer($sx), Integer($sy)
    visited = []
    discovered = []
    value = $table["#{x} #{y}"]
    value = value.to_s
    direction, weight = value.split(/\s/,2)
    discovered.push("#{x} #{y}")
    
    while discovered.size != 0
      current = discovered.pop
      x, y = current.split(/\s/)
      x = Integer(x)
      y = Integer(y)
      value = $table[current]
      value = value.to_s
      direction, weight = value.split(/\s/,2)
      
      if visited.include?(current) == false
        visited.push(current)
        direction = direction.split(//)
        
        i = 0
        while i < direction.size
          case direction[i]
            when "u"
              y = y - 1
              if visited.include?("#{x} #{y}") == false
                discovered.push("#{x} #{y}")
                if "#{x} #{y}" == "#{$ex} #{$ey}"
                  result = true
                end
              end
              y = y + 1
            when "d"
              y = y + 1
              if visited.include?("#{x} #{y}") == false
                discovered.push("#{x} #{y}")
                if "#{x} #{y}" == "#{$ex} #{$ey}"
                  result = true
                end
              end
              y = y - 1
            when "l"
              x = x - 1
              if visited.include?("#{x} #{y}") == false
                discovered.push("#{x} #{y}")
                if "#{x} #{y}" == "#{$ex} #{$ey}"
                  result = true
                end
              end
              x = x + 1
            when "r"
              x = x + 1
              if visited.include?("#{x} #{y}") == false
                discovered.push("#{x} #{y}")
                if "#{x} #{y}" == "#{$ex} #{$ey}"
                  result = true
                end
              end
              x = x - 1
            end
            i = i + 1
        end
      end
    end
    puts discovered
    if result == true
      puts result
    else
      puts false
    end
  end
  
  #------------------------------------------------------------
  # pretty-print maze so that it is easier to read
  # - or | represent walls, + represent junction of walls
  # s represent start, e reprensents end

  def print_file(file)
    i, j= 0, 0
    x, y = 0, -1
    while i < $size * 2 + 1
      while j < $size * 2 + 1
        if i == 0
          if j % 2 == 0
            print "+"
          else
            print "-"
          end
        else
          value = $table["#{x} #{y}"]
          value = value.to_s
          direction, weight = value.split(/\s/,2)
          if i % 2 == 0
            if j % 2 == 0
              if j != 0 && j != 1 then x = x + 1 end
              print "+"
            else
              if direction.include? "d"
                print " "
              else
                print "-"
              end
            end
          else
           if j % 2 == 0
             if j != 0 && j != 1 then x = x + 1 end
             if j == 0
               print "|"
             else
               if direction.include? "r"
                 print " "
               else
                 print "|"
               end
             end
           else
             if Integer($sx) == x && Integer($sy) == y
               print "s"
             else 
               if Integer($ex) == x && Integer($ey) == y
                 print "e"
               else
                 print " "
             end
           end
         end
        end
          
        end
        j = j + 1
      end
      if i % 2 == 0 then y = y + 1 end
      print "\n"
      i = i + 1
      x = 0
      j = 0
    end
  end

#------------------------------------------------------------
# count the sum of all of the closed walls
# count the sum of all of the open walls
# calculate and output depend on the parameter choice

  def open_closed(choice)
    if choice == "open"
     puts "u: #{$up}, d: #{$down}, l: #{$left}, r: #{$right}"
   end
    if choice == "closed"
      puts "#{$closedCell}"
    end
  end
  
#-----------------------------------------------------------
# EXECUTABLE CODE
#-----------------------------------------------------------

#----------------------------------
# check # of command line arguments

if ARGV.length < 2
  fail "usage: maze.rb <command> <filename>" 
end

command = ARGV[0]
file = ARGV[1]
maze_file = open(file)

#----------------------------------
# perform command

case command

  when "parse"
    parse(maze_file)

  when "closed"
    read_and_print_simple_file(maze_file, "none")
    open_closed("closed")

  when "open"
    read_and_print_simple_file(maze_file, "none")
    open_closed("open")
  
  when "paths"
    read_and_print_simple_file(maze_file, "path")
    path_helper(maze_file)
    if $path == nil then puts "None" end
    if $path != nil then puts $string end
    
  when "print"
    read_and_print_simple_file(maze_file, "none")
    print_file(maze_file)
    
  when "solve"
    read_and_print_simple_file(maze_file, "none")
    solve(maze_file)
  
  else
    fail "Invalid command"

end
