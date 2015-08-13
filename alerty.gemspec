Gem::Specification.new do |gem|
  gem.name          = "alerty"
  gem.version       = '0.0.1'
  gem.author        = ['Naotoshi Seo']
  gem.email         = ['sonots@gmail.com']
  gem.homepage      = 'https://github.com/sonots/alerty'
  gem.summary       = "Send an alert if a given command failed"
  gem.description   = "Send an alert if a given command failed"
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'hashie'
  gem.add_runtime_dependency 'oneline_log_formatter'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-nav'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
end
