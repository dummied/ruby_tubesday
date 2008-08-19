Gem::Specification.new do |spec|
	spec.name = 'ruby_tubesday'
	spec.version = '1.0'
	spec.summary = 'Full-featured HTTP client library.'
	spec.author = 'DanaDanger'
	spec.homepage = 'http://github.com/DanaDanger/ruby_tubesday'
	spec.has_rdoc = true
	spec.files = Dir.glob('lib/**/*.rb', 'ca-bundle.crt')
	spec.add_dependency('activesupport', '>=2.1')
end
