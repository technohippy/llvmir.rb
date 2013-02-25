=begin
@.str = private constant [13 x i8] c"Hello World!\00", align 1 ;

define i32 @main() ssp {
entry:
  %retval = alloca i32
  %0 = alloca i32
  %"alloca point" = bitcast i32 0 to i32
  %1 = call i32 @puts(i8* getelementptr inbounds ([13 x i8]* @.str, i64 0, i64 0))
  store i32 0, i32* %0, align 4
  %2 = load i32* %0, align 4
  store i32 %2, i32* %retval, align 4
  br label %return
return:
  %retval1 = load i32* %retval
  ret i32 %retval1
}

declare i32 @puts(i8*)
=end

require 'llvmir'

IR.globals['.str'] = 'Hello World!'
IR.define_function 'main' do
  IR.define_block 'entry' do
    IR.locals['retval'] = IR.alloca IR.i32
    IR.locals['0'] = IR.alloca IR.i32
    IR.locals['alloca point'] = IR.bitcast IR.i32(0) => IR.i32
    IR.locals['1'] = IR.call IR.globals['puts'], [IR.getelementptr(:inbounds, IR.globals['.str'], 0, 0)]
    IR.store IR.i32(0), IR.pointer(IR.locals, '0'), IR.align(4)
    IR.locals['2'] = IR.load IR.pointer(IR.locals, '0'), IR.align(4)
    IR.store IR.i32(IR.locals['2']), IR.pointer(IR.locals, 'retval'), IR.align(4)
    IR.br IR.blocks['return']
  end

  IR.define_block 'return' do
    IR.locals['retval1'] = IR.load IR.pointer(IR.locals, 'retval')
    IR.ret IR.i32(IR.locals['retval1'])
  end
end

puts IR.globals['main'][]
