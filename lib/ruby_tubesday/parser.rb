class RubyTubesday::Parser
  def self.register(meth, *mime_types)
    mime_types.each do |type|
      @@parser_methods[type] = meth
    end
  end
  
  def self.parse(response)
  	content_type = response['Content-Type'].split(';').first
  	parser_method = @@parser_methods[content_type]
		if parser_method
			parser_method.call(response.body)
		else
			response.body
		end
  end
  
private
  
  @@parser_methods = {}
end

begin
	require 'rubygems'
	require 'json'
	RubyTubesday::Parser.register(JSON.method(:parse), 'application/json')
rescue LoadError
	# Fail silently.
end
