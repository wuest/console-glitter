$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'console-glitter'
  s.version = '0.3.0'

  s.description = 'Tools for building nice looking CLI applications'
  s.summary     = 'Tools for prettier CLI apps'
  s.authors     = ['Tina Wuest']
  s.email       = 'tina@wuest.me'
  s.homepage    = 'https://github.com/wuest/console-glitter'
  s.license     = 'MIT'
  s.files       = `git ls-files lib`.split("\n")

  s.add_development_dependency 'sorbet'
end
