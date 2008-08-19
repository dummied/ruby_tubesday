require 'rubygems'
require 'spec'

$: << (File.dirname(__FILE__) + '/../lib')
require 'ruby_tubesday'

# Start up the test web server.
pwd = Dir.pwd
Dir.chdir(File.dirname(__FILE__) + '/test_server')
unless system('merb -d -e production')
  STDERR.puts 'The test server failed to start.'
  exit!(1)
end
Dir.chdir(pwd)

# Wait for the test server to start accepting connections.
test_server_is_up = false
60.times do
  client = RubyTubesday.new
  begin
    client.get('http://localhost:4000/test_controller/')
    test_server_is_up = true
    break
  rescue Errno::ECONNREFUSED
  end
  sleep 1
end

unless test_server_is_up
  STDERR.puts 'The test server failed to start.'
  exit!(1)
end

# Install an at_exit handler to shut down the test web server.
at_exit do
  pwd = Dir.pwd
  Dir.chdir(File.dirname(__FILE__) + '/test_server')
  system('merb -K all > /dev/null')
  Dir.chdir(pwd)
end
