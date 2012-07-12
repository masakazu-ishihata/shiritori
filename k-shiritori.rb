#!/usr/bin/env ruby

################################################################################
# default
################################################################################
@file = "hoge.txt"
@k = 3

################################################################################
# Arguments
################################################################################
require "optparse"
OptionParser.new { |opts|
  # options
  opts.on("-h","--help","Show this message") {
    puts opts
    exit
  }
  opts.on("-f [INPUT]", "file name"){ |f|
    @file = f
  }
  opts.on("-k [int]", "k-leq-shiritori"){ |f|
    @k = f.to_i
  }
  # parse
  opts.parse!(ARGV)
}

################################################################################
# functions
################################################################################
#### connectable ####
def k_leq_connectable(w, u, k)
  for i in 1..k
    return i if k_connectable(w, u, i) == 1
  end
  return 0
end

def k_connectable(w, u, k)
  return 0 if w.size < k || u.size < k
  tail = w.tail(k)
  head = u.head(k)
  return 1 if head.index(tail) != nil
  return 0
end

################################################################################
# classes
################################################################################
#### arry ####
class Array
  def head(k)
    self[0..k-1]
  end
  def tail(k)
    self[size-k...size]
  end
end

#### string ####
class String
  def head(k)
    self[0..k-1]
  end
  def tail(k)
    self[size-k...size]
  end
end

########################################
#### longest path ####
########################################
class MyLongestPath
  #### new ####
  def initialize(file, k)
    @k = k
    @ws = open(file).read.split("\n")
    @n = @ws.size

    @adj = Array.new(@n){ |i| Array.new(@n){ |j| 0 }}
    for s in 0..@n-1
      for t in 0..@n-1
        next if s == t
        @adj[s][t] = k_leq_connectable(@ws[s], @ws[t], @k)
      end
    end
  end

  #### hamiltonian ####
  def get_longestpath
    sols = Array.new(@n){ |i| [i] } # solutions (candidates)
    lsol = nil                      # longest path

    # get longest path
    while (sol = sols.pop) != nil # depth first
      lsol = sol if lsol == nil || lsol.size < sol.size # is the current longest path
      break if sol.size == @n # is the longest path

      # add child solutions to sols
      s = sol.tail(1)[0] # the last node
      for t in 0..@n-1
        sols.push(sol + [t]) if @adj[s][t] > 0 && sol.index(t) == nil
      end
    end

    # show
    lsol.each do |i|
      printf("%s\n", @ws[i])
    end
  end
end

########################################
# hamiltonian
########################################
class MyHamiltonian
  def initialize(file, k)
    @k = k
    @ws = open(file).read.split(/\n/)
    @n = @ws.size
    @adj = Array.new(@n){ |i| Array.new(@n){ |j| 0 }}  # adjacency matrix
    @ham = Hash.new(nil) # ham[s, w] = nil:unknown, []:no path, [s, t, w-t]: s -> ham[t, w-t]

    ordering  # heuristic ordering
    init      # init adj & ham
  end

  #### ordering ####
  def ordering
    # out degree
    @od = Hash.new(0)
    for s in 0..@n-1
      for t in 0..@n-1
        next if s == t
        w = @ws[s]
        u = @ws[t]
        @od[w] += 1 if k_leq_connectable(w, u, @k) > 0
      end
    end

    # sort
    @ws.sort!{|w, u| @od[w] <=> @od[u]} # ascending order
  end

  #### init ####
  def init
    @ham.clear
    for s in 0..@n-1
      for t in 0..@n-1
        next if s == t
        @adj[s][t] = k_leq_connectable(@ws[s], @ws[t], @k)
        @ham[[s, [t]]] = [s, t, []] if @adj[s][t] > 0
      end
    end
  end

  #### reachability : [s, w] is reachable := \forall t \in w, there exists a directed path s -> t ####
  def rec(s, w)
    return 0 if w == [] # definition

    ss = [s]      # reachable nodes
    ts = w.clone  # unknown nodes

    while (s = ss.shift)
      h = nil
      while ts.size > 0
        break if h == ts[0]

        t = ts.shift
        if @adj[s][t] > 0
          ss.push(t)
          h = nil
        else
          h = t if h == nil
          ts.push(t)
        end
      end
    end

    return 1 if ts.size == 0
    return 0
  end

  #### ham(s, w) : a sub-hamiltonian from s for a sub-nodeset w ####
  def ham(s, w)
    key = [s, w]
    return @ham[key] if @ham[key] != nil      # avoid the same computation
    return (@ham[key] = []) if rec(s, w) == 0 # skip if unreachable

    # recursion
    w.each do |t|
      u = w - [t]
      return (@ham[key] = [s, t, u]) if @adj[s][t] > 0 && ham(t, u) != []
    end

    return (@ham[key] = []) # no hamiltonian
  end

  #### hamiltonian ####
  def get_hamiltonian
    w = Array.new(@n){ |i| i } # subset of nodes

    # get hamiltonian path
    for s in 0..@n-1
      break if (h = ham(s, w - [s])) != []
    end

    # show result
    while h != []
      s = h[0]
      t = h[1]
      u = h[2]
      puts "#{@ws[s]}"
      if u == []
        puts "#{@ws[t]}"
        h = []
      else
        h = ham(t, u)
      end
    end
  end
end

################################################################################
# main
################################################################################
puts "<-- Hamiltonian -->"
g = MyHamiltonian.new(@file, @k)
g.get_hamiltonian

puts "<-- Longest path -->"
g = MyLongestPath.new(@file, @k)
g.get_longestpath
