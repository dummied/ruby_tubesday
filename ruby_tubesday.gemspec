Gem::Specification.new do |spec|
	spec.name = 'ruby_tubesday'
	spec.version = '0.3.1'
	spec.summary = 'Full-featured HTTP client library.'
	spec.author = 'Dana Contreras'
	spec.homepage = 'http://github.com/dummied/ruby_tubesday'
	spec.has_rdoc = true
	spec.files = [
		'lib/ruby_tubesday.rb',
		'lib/ruby_tubesday/cache_policy.rb',
		'lib/ruby_tubesday/parser.rb',
		'ca-bundle.crt'
	]
	spec.add_dependency('activesupport', '>=2.1')
end
