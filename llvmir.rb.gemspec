# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "llvmir"

Gem::Specification.new do |s|
  #s.name        = "llvmir.rb"
  s.name        = "llvmir"
  s.version     = LlvmIR::VERSION
  s.authors     = ["Ando Yasushi"]
  s.email       = ["andyjpn@gmail.com"]
  s.homepage    = "https://github.com/technohippy/llvmir.rb"
  s.summary     = %q{LLVM-IR}
  s.description = %q{LLVM-IR}

  #s.rubyforge_project = "llvmir.rb"
  s.rubyforge_project = "llvmir"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
