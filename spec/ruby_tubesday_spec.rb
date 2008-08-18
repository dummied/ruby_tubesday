require (File.dirname(__FILE__) + '/spec_helper')

describe RubyTubesday do
  before(:each) do
    @client = RubyTubesday.new :ca_file => '/usr/share/curl/curl-ca-bundle.crt'
  end

  it "should fetch web pages" do
    @client.get('http://localhost:4000/test_controller/').should == 'Hello World'
  end
  
  it "should post forms" do
    raise 'test not written'
  end
  
  it "should follow redirects" do
    @client.get('http://localhost:4000/test_controller/redirect_once').should == 'Hello World'
  end
  
  it "should fail after too many redirects" do
    lambda {
      @client.get('http://localhost:4000/test_controller/redirect_forever')
    }.should raise_error(RubyTubesday::TooManyRedirects)
  end
  
  it "should automatically parse JSON" do
    @client.get('http://localhost:4000/test_controller/json').should be_a_kind_of(Hash)
  end
  
  it "should permit automatic parsing to be disabled" do
    @client.get('http://localhost:4000/test_controller/json', :raw => true).should be_a_kind_of(String)
  end
  
  it "should cache web pages" do
    i = @client.get('http://localhost:4000/test_controller/counter')
    @client.get('http://localhost:4000/test_controller/counter').should == i
  end
  
  it "should permit caching to be temporarily disabled" do
    i = @client.get('http://localhost:4000/test_controller/counter')
    @client.get('http://localhost:4000/test_controller/counter', :cache => false).should_not == i
  end
  
  it "should support SSL" do
    lambda { @client.get('https://jlex.org/account/login/') }.should_not raise_error
  end
  
  it "should verify SSL certificates" do
    lambda { @client.get('https://mail.danadanger.org/') }.should raise_error(OpenSSL::SSL::SSLError)
  end
  
  it "should permit SSL certificate verification to be temporarily disabled" do
    lambda { @client.get('https://mail.danadanger.org/', :verify_ssl => false) }.should_not raise_error
  end
end
