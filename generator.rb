#!/usr/bin/env ruby

################################################################################
# default
################################################################################
@file = "hoge.txt"
@n = 10  # # words
@m = 26  # # aplphabets
@k = 3   # k
@l = 3   # parameter of Poisson
@flg_o = false

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
  opts.on("-f [string]", "file name"){ |f|
    @file = f
  }
  opts.on("-n [int]", "# words"){ |f|
    @n = f.to_i
  }
  opts.on("-m [int]", "# alphabets"){ |f|
    @m = f.to_i
  }
  opts.on("-k [int]", "k-leq-shiritori"){ |f|
    @k = f.to_i
  }
  opts.on("-l [int]", "Parameter of Poisson distribution"){ |f|
    @l = f.to_i
  }
  opts.on("-o", "Output with the collect order"){ |f|
    @flg_o = true
  }
  # parse
  opts.parse!(ARGV)
}

########################################
# factorial
########################################
def fact(n)
  n > 1 ? n*fact(n-1) : 1
end

########################################
# Array & String
########################################
class Array
  def choice
    at(rand(size))
  end
end
class String
  def tail(k)
    self[size-k...size]
  end
end

########################################
# Poisson distribution
########################################
class MyPoisson
  def initialize(l)
    @l = l
  end

  def sample
    k = 0
    s = 0
    r = rand

    begin
      s += (@l ** k) * (Math.exp(-@l)) / fact(k)
      break if r < s
      k += 1
    end while true

    k
  end
end

########################################
# Shiritori Generator
########################################
class MyGenerator
  #### new ####
  def initialize(n, m, k, l)
    # words
    @n = n

    # alphabets
    @m = m
    @al = []
    for i in 0..@m-1
      @al.push((97 + i).chr)
    end

    # k-leq-connection
    @k = k

    # Poisson distribution
    @l = l
    @po = MyPoisson.new(@l)
  end

  #### generate a word ####
  def generate_word(pre, n)
    str = pre.clone
    for i in 1..n
      str += @al.choice
    end
    str
  end

  #### generate words ####
  def generate
    w = generate_word("", @k + @po.sample)
    ws = [w]

    for i in 1..@n-1
      k = rand(@k) + 1
      pre = w.tail(k)
      w = generate_word(pre, @po.sample + 1)
      ws.push(w)
    end

    ws
  end

  #### export ####
  def export(file, flg)
    puts "output file = #{file}"
    puts "# words     = #{@n}"
    puts "# alphabets = #{@m}"
    puts "k           = #{@k}"
    puts "l           = #{@l}"

    ws = generate
    ws = ws.sort_by{ rand } if !flg

    open(file, "w") do |f|
      ws.each do |w|
        f.puts w
        puts w
      end
    end
  end
end

################################################################################
# main
################################################################################
MyGenerator.new(@n, @m, @k, @l).export(@file, @flg_o)
