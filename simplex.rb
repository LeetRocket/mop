require 'matrix'

class Simplex
  
  def initialize(a, b, c, x, jb, v=true)
    @A = a
    @m = @A.row_size
    @n = @A.column_size
    @b = b
    @c = c
    @x = x
    @J = (0...@n).to_a
    @Jb = jb
    @Jn = @J - @Jb
    @Ab = base(@A, @Jb)
    @B = @Ab.inv
    
    @v = v
  end
  
  def iteration
    for i in 1...200
      puts "\n----------\nIteration #{i}\n----------\n"
      puts "cost = #{(@c.covector * @x)[0]}\n\n"
      
      f1
      if f2
        puts 'optimal plan found'
        puts "x = #{@x.inspect}"
        puts "Jb = #{@Jb.inspect}"
        puts "cost = #{(@c.covector * @x)[0]}"
        return @x
      end
      if f3
        puts 'function is not limited'
        return nil
      end
      f4
      f5
      f6
    end
  end
  
  def f1
    puts "\n>> Phase 1" if @v
    puts "Jb = #{@Jb.inspect}"
    puts "B = #{@B.inspect}"
    puts "x = #{@x.inspect}"
    @cb = base(@c.covector, @Jb)
    @u = @cb * @B
    puts "u' = #{@u.inspect}" if @v
    
    @d = []
    for j in @Jn
      @d[j] = (@u * @A.column(j))[0] - @c[j]
      puts "^[#{j}] = #{@d[j]}" if @v
    end
  end
  
  def f2
    puts "\n>> Phase 2"
    v = true
    d_min = 0
    for j in @Jn
      v &&= @d[j] >= 0 
      if @d[j] < d_min
        @j0 = j
      end
    end
    puts "Not optimal" unless v
    return v
  end
  
  def f3
    puts "\n>> Phase 3"
    puts "j0 = #{@j0}"
    puts "^[j0] = #{@d[@j0]}"
    @z = @B * @A.column(@j0)
    v = true
    @s = 0
    @t0 = 99999999999999
    @z.to_a.each_with_index { |z, i|
      v &&= z <= 0
      if z > 0
        t0 = @x[@Jb[i]] / z
        # puts "candidate x#{@Jb[i]}/z#{i} #{t0}"
        if t0 < @t0
          @t0 = t0
          @s = i
        end
      end
    }
    puts "function is limited" unless v

    return v
  end
  
  def f4
    puts "\n>> Phase 4"
    puts "theta0 = #{@t0}"
    puts "s = #{@s}"
  end
  
  def f5
    puts "\n>> Phase 5"
    x = []
    @J.each do |j|
      if @j0 == j
        x[j] = @t0
      elsif @Jn.include? j
        x[j] = 0.0
      else
        x[j] = @x[j] - @t0*@z[@Jb.index j]
      end
    end
    @x = Vector.elements x
    puts "new x = #{@x.inspect}"
    @Jb.delete_at @s
    @Jb.push @j0
    @Jb.sort!
    puts "new Jb = Jb \\ js U j0 = #{@Jb.inspect}"
    @Jn = @J - @Jb
  end
  
  def f6
    puts "\n>> Phase 6"
    @B = base(@A, @Jb).inv
    puts "new B = #{@B}"
  end
  
  def base(mx, jb)
    cols = []
    mx.column_vectors.each_with_index { |c, i|
      cols.push c if jb.include? i
    }
    return Matrix.columns cols
  end
end

# c = Vector.elements [6.0, 5.0, 9.0, 0.0, 0.0, 0.0]
# b = Vector.elements [25.0, 20.0, 18.0]
# x = Vector.elements([0.0, 0.0, 0.0] + b.to_a)
# jb = [3, 4, 5]
# 
# a = Matrix[
#     [5.0, 2.0, 3.0, 1.0, 0.0, 0.0],
#     [1.0, 6.0, 2.0, 0.0, 1.0, 0.0],
#     [4.0, 0.0, 3.0, 0.0, 0.0, 1.0]
#   ]

 # c = Vector.elements [ 4.0,  3.0,  2.0,  1.0,  2.0,  3.0,  4.0]
 # b = Vector.elements [ 5.0,  7.0,  9.0,  9.0]
 # x = Vector.elements [ 5.0,  2.0,  2.0,  0.0,  0.0,  0.0,  0.0]
 # a = Matrix[
 #      [ 1.0,  0.0,  0.0,  0.0,  2.0,  3.0, -1.0],
 #      [ 1.0,  1.0,  0.0,  0.0,  3.0,  4.0, -1.0],
 #      [ 1.0,  1.0,  1.0,  0.0,  5.0, -1.0,  2.0],
 #      [ 1.0,  1.0,  1.0,  1.0, -1.0,  2.0,  4.0]
 #   ]
 # jb = [0, 1, 2, 3]
 
 a = Matrix[
             [2.0, 1.0,  0.0, -3.0,  6.0, 0.0],
             [0.0, 1.0,  0.0,  4.0, -2.0, 2.0],
             [1.0, 1.0, -6.0, -5.0, -6.0, 10.0]
           ]
 x = Vector.elements [ 3.0, 12.0, 0.0, 0.0, 0.0, 0.0]
 b = Vector.elements [18.0, 12.0, 9.0]
 c = Vector.elements [2.0, -3.0, 0.0, 5.0, -6.0, 10.0]
 jb = [0, 1, 2]
  
s = Simplex.new a, b, c, x, jb
s.iteration
