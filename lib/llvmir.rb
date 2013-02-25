class LlvmIR
  VERSION = '0.0'

  class UnreachableException < StandardError; end

  attr_accessor :module_id, :globals, :locals, :blocks, :stack
  alias g globals
  alias l locals
  alias b blocks

  def initialize
    setup_globals
    @contexts = []
    push_context
  end

  def push_context local_hash={}
    @contexts.push stack:[], locals:local_hash, blocks:{}
  end

  def pop_context
    @contexts.pop
  end

  def stack
    @contexts.last[:stack]
  end

  def locals
    @contexts.last[:locals]
  end

  def blocks
    @contexts.last[:blocks]
  end

  def define_function name, args=[], &block
    self.globals[name] = ->(*ary) {
      self.push_context Hash[*args.zip(ary).flatten]
      block.call(*ary)
      self.invoke_first_block
      self.pop_context
      self.ret
    }
  end

  def define_block name, &block
    self.blocks[name] = ->{
      self.stack.push name
      ret = block.call self
      self.stack.pop
      ret
    }
  end

  def invoke_first_block
    self.blocks.first.last.call unless self.blocks.empty?
  end

  # TODO
  def align val
    val
  end

  def pointer scope, name
    scope = self.send(scope) if [:locals, :globals].include? scope
    Pointer.new scope, name
  end
  alias ptr pointer

  # Primitive Types

  def undef
    nil
  end

  (1..64).each do |i|
    eval <<-EOS 
      def i#{i} *args
        if args.empty?
          :i#{i}
        else
          args.first
        end
      end
    EOS
  end

  # Terminator Instructions

  def ret *val
    case val.size
    when 0
      @ret
    when 1
      @ret = val.first
    else
      raise ArgumentError.new
    end
  end

  def br cond_or_dest, true_label=nil, false_label=nil
    if true_label.nil?
      dest = cond_or_dest.is_a?(Proc) ? cond_or_dest : self.blocks[cond_or_dest]
      dest.call
    else
      cond = cond_or_dest
      iftrue = true_label.is_a?(Proc) ? true_label : self.blocks[true_label]
      iffalse = false_label.is_a?(Proc) ? false_label : self.blocks[false_label]
      (cond ? iftrue : iffalse).call
    end
  end

  def switch value, default_dest, val_dest_pairs={}
    found = false
    val_dest_pairs.each do |val, dest|
      if val == value
        found = true
        dest.call
      end
    end
    default_dest.call unless found
  end

  # TODO
  def indirectbr addr, *dests
    raise 'not implemented yet'
  end

  # TODO
  def invoke
    raise 'not implemented yet'
  end

  # TODO
  def resume
    raise 'not implemented yet'
  end

  def unreachable
    raise UnreachableException
  end

  # Binary Operations

  def add *ops
    op2 = ops.pop
    op1 = ops.pop
    # TODO: ops may has nuw or nsw.
    op1 + op2
  end
  alias fadd add

  def sub *ops
    op2 = ops.pop
    op1 = ops.pop
    # TODO: ops may has nuw or nsw.
    op1 - op2
  end
  alias fsub sub

  def mul *ops
    op2 = ops.pop
    op1 = ops.pop
    # TODO: ops may has nuw or nsw.
    op1 * op2
  end
  alias fmul mul

  def udiv *ops
    op2 = ops.pop
    op1 = ops.pop
    # TODO: ops may has exact
    op1 / op2
  end
  alias sdiv udiv
  alias fdiv udiv

  def urem op1, op2
    op1 % op2
  end
  alias srem urem
  alias frem urem

  # Bitwise Binary Operations

  def shl *ops
    op2 = ops.pop
    op1 = ops.pop
    # TODO: ops may has nuw or nsw
    op1 << op2
  end

  def lshr *ops
    op2 = ops.pop
    op1 = ops.pop
    # TODO: ops may has exact
    op1 >> op2
  end

  # Vector Operations

  # Aggregate Operations

  # Memory Access and Addressing Operations

  def alloca type
    case type.to_s
    when /^i\d+$/
      0
    else
      nil
    end
  end

  # TODO
  def load pointer, align=nil
    pointer.value
  end

  # TODO
  def store val, pointer, align=nil
    pointer.value = val
  end

  # TODO
  def getelementptr *args
    case args.first
    when :inbounds, :outbounds
      args[1]
    else
      args.first
    end
  end

  # Conversion Operations

  # TODO
  def bitcast hash # bitcast i32 0 to i32
    hash.keys.first
  end

  # Other Operations

  # TODO
  def icmp type, src, dst
    case type
    when :eq
      src == dst
    else
      nil
    end
  end

  def phi(*cases)
    cases.each do |val, label|
      if self.stack[-2] == label
        return val
      end
    end
  end

  def call *args
    args.first.call *args[1]
  end

private

  def setup_globals
    @globals = {
      'puts' => ->(str) {
        puts str
      }
    }
  end

  class Pointer
    attr_accessor :scope, :name

    def initialize scope=nil, name=nil
      @scope, @name = scope, name
    end

    def value= val
      @scope[@name] = val
    end

    def value
      @scope[@name]
    end
  end
end

IR = LlvmIR.new
