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
  
  describe "(content parsing)" do
    it "should automatically parse JSON" do
      @client.get('http://localhost:4000/test_controller/json').should be_a_kind_of(Hash)
    end
    
    it "should permit automatic parsing to be disabled" do
      @client.get('http://localhost:4000/test_controller/json', :raw => true).should be_a_kind_of(String)
    end
  end
  
  describe "(SSL)" do
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
  
  describe "(caching)" do
    it "should cache web pages" do
      i = @client.get('http://localhost:4000/cache_control/max_age')
      @client.get('http://localhost:4000/cache_control/max_age').should == i
    end
    
    it "should permit caching to be temporarily disabled" do
      i = @client.get('http://localhost:4000/cache_control/max_age')
      @client.get('http://localhost:4000/cache_control/max_age', :cache => false).should_not == i
    end
    
    describe "(Cache-Control header)" do
      before(:all) do
        Dir.mkdir('/tmp/ruby_tubesday_spec') rescue nil
      end
      
      before(:each) do
        @file_store_cache = ActiveSupport::Cache::FileStore.new('/tmp/ruby_tubesday_spec')
        @shared_client = RubyTubesday.new :cache => @file_store_cache
        @stored_client = @shared_client
      end
      
      after(:each) do
        @file_store_cache.delete_matched(/.*/)
      end
      
      it "should honor private" do
        i = @shared_client.get('http://localhost:4000/cache_control/private')
        @shared_client.get('http://localhost:4000/cache_control/private').should_not == i
      end
      
      it "should honor no-cache" do
        i = @client.get('http://localhost:4000/cache_control/no_cache')
        @client.get('http://localhost:4000/cache_control/no_cache').should_not == i
      end
      
      it "should honor no-store" do
        i = @stored_client.get('http://localhost:4000/cache_control/no_store')
        @stored_client.get('http://localhost:4000/cache_control/no_store').should_not == i
      end
      
      it "should honor must-revalidate" do
        i = @client.get('http://localhost:4000/cache_control/must_revalidate')
        @client.get('http://localhost:4000/cache_control/must_revalidate').should_not == i
      end
      
      it "should honor max-age" do
        i = @client.get('http://localhost:4000/cache_control/max_age')
        @client.get('http://localhost:4000/cache_control/max_age').should == i
        sleep 6
        @client.get('http://localhost:4000/cache_control/max_age').should_not == i
      end
      
      it "should honor s-maxage" do
        i = @shared_client.get('http://localhost:4000/cache_control/s_maxage')
        @shared_client.get('http://localhost:4000/cache_control/s_maxage').should == i
        sleep 6
        @shared_client.get('http://localhost:4000/cache_control/s_maxage').should_not == i
      end
    end
  end
  
  it "should support basic HTTP authentication" do
    raise 'test not written'
  end
end
