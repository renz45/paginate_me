# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "paginate_me/version"

Gem::Specification.new do |s|
  s.name        = "paginate_me"
  s.version     = PaginateMe::VERSION
  s.authors     = ["Adam Rensel"]
  s.email       = ["adamrensel@gmail.com"]
  s.homepage    = "https://github.com/renz45/paginate_me"
  s.summary     = %q{paginate_me is a simple pagination gem for Rails 3.1}
  s.description = %q{for more information, please visit the homepage or https://github.com/renz45/paginate_me for a full README}

  s.rubyforge_project = "paginate_me"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
