=begin
; ModuleID = 'Factorial'

define i32 @fac(i32 %n) {
entry:
  %test = icmp eq i32 %n, 1
  br i1 %test, label %result, label %recur

recur:                                            ; preds = %entry
  %n-1 = sub i32 %n, 1
  %"fac(n-1)" = call i32 @fac(i32 %n-1)
  %"n*fac(n-1)" = mul i32 %n, %"fac(n-1)"
  br label %result

result:                                           ; preds = %recur, %entry
  %fac = phi i32 [ 1, %entry ], [ %"n*fac(n-1)", %recur ]
  ret i32 %fac
}

fac(6) = 720
=end

require 'llvmir'

IR.module_id = 'Factorial'

IR.define_function 'fac', ['n'] do
  IR.define_block 'entry' do
    IR.locals['test'] = IR.icmp :eq, IR.locals['n'], 1
    IR.br IR.locals['test'], IR.blocks['result'], IR.blocks['recur']
  end

  IR.define_block 'recur' do
    IR.locals['n-1'] = IR.sub IR.locals['n'], 1
    IR.locals['fac(n-1)'] = IR.call IR.globals['fac'], [IR.locals['n-1']]
    IR.locals['n*fac(n-1)'] = IR.mul IR.locals['n'], IR.locals['fac(n-1)']
    IR.br IR.blocks['result']
  end

  IR.define_block 'result' do
    IR.locals['fac'] = IR.phi [1, 'entry'], [IR.locals['n*fac(n-1)'], 'recur']
    IR.ret IR.locals['fac']
  end
end

puts IR.globals['fac'][6]
