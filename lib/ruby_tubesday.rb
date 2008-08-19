require 'uri'
require 'cgi'
require 'net/https'
require 'rubygems'
require 'activesupport'

class RubyTubesday
	class TooManyRedirects < Exception; end
	
	def initialize(options = {})
		@default_options = {
			:raw           => false,
			:cache         => ActiveSupport::Cache::MemoryStore.new,
			:params        => {},
			:max_redirects => 5,
			:ca_file       => (File.dirname(__FILE__) + '/../ca-bundle.crt'),
			:verify_ssl    => true,
			:username      => nil,
			:password      => nil
		}
		@default_options = normalize_options(options)
	end
	
	def get(url, options = {})
		options = normalize_options(options)
		url = URI.parse(url)
		
		url_params = CGI.parse(url.query || '')
		params = url_params.merge(options[:params])
		query_string = ''
		unless params.empty?
			params.each do |key, values|
				values = [values] unless values.is_a?(Array)
				values.each do |value|
					query_string += "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}&"
				end
			end
			query_string.chop!
			url.query = query_string
			query_string = "?#{query_string}"
		end
		request = Net::HTTP::Get.new(url.path + query_string)
		
		process_request(request, url, options)
	end
	
	def post(url, options = {})
		options = normalize_options(options)
		url = URI.parse(url)
		
		request = Net::HTTP::Post.new(url.path)
		request.set_form_data(options[:params])
		
		process_request(request, url, options)
	end
  
protected
	
	def normalize_options(options)
		normalized_options = {
			:raw           => options.delete(:raw),
			:cache         => options.delete(:cache),
			:params        => options.delete(:params)        || @default_options[:params],
	    :max_redirects => options.delete(:max_redirects) || @default_options[:max_redirects],
	    :ca_file       => options.delete(:ca_file)       || @default_options[:ca_file],
	    :verify_ssl    => options.delete(:verify_ssl),
	    :username      => options.delete(:username)      || @default_options[:username],
	    :password      => options.delete(:password)      || @default_options[:password]
	  }
	  
    normalized_options[:raw]        = @default_options[:raw]        if normalized_options[:raw].nil?
    normalized_options[:cache]      = @default_options[:cache]      if normalized_options[:cache].nil?
    normalized_options[:verify_ssl] = @default_options[:verify_ssl] if normalized_options[:verify_ssl].nil?
    
    unless options.empty?
      raise ArgumentError, "unrecognized keys: `#{options.keys.join('\', `')}'"
    end
    
    normalized_options
	end
	
	def process_request(request, url, options)
		response = nil
		cache_policy_options = CachePolicy.options_for_cache(options[:cache]) || {}
		
		if request.is_a?(Net::HTTP::Get) && options[:cache] && options[:cache].read(url.to_s)
			response = Marshal.load(options[:cache].read(url.to_s))
			response_age = Time.now - Time.parse(response['Last-Modified'] || response['Date'])
			cache_policy = CachePolicy.new(response['Cache-Control'], cache_policy_options)
			if cache_policy.fetch_action(response_age)
				response = nil
			end
		end
		
		if response.nil?
			redirects_left = options[:max_redirects]
			
			while !response.is_a?(Net::HTTPSuccess)
				if options[:username] && options[:password]
					request.basic_auth options[:username], options[:password]
				end
				client = Net::HTTP.new(url.host, url.port)
				if (client.use_ssl = url.is_a?(URI::HTTPS))
					client.verify_mode = options[:verify_ssl] ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
					client.ca_file = options[:ca_file]
				end
				response = client.start { |w| w.request(request) }
				
				if response.is_a?(Net::HTTPRedirection)
					raise(TooManyRedirects) if redirects_left < 1
					url = URI.parse(response['Location'])
					request = Net::HTTP::Get.new(url.path)
					redirects_left -= 1
				elsif !response.is_a?(Net::HTTPSuccess)
					response.error!
				end
			end
			
			if request.is_a?(Net::HTTP::Get) && options[:cache]
				cache_policy = CachePolicy.new(response['Cache-Control'], cache_policy_options)
				if cache_policy.may_cache?
					options[:cache].write(url.to_s, Marshal.dump(response))
				end
			end
		end
    
    if options[:raw]
	    response.body
	  else
	  	RubyTubesday::Parser.parse(response)
	  end
  end
end

require 'ruby_tubesday/parser'
require 'ruby_tubesday/cache_policy'
