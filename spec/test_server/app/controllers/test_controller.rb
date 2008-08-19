class TestController < Application
  def index
    'Hello World'
  end
  
  def redirect_once
    redirect 'http://localhost:4000/test_controller/'
  end
  
  def redirect_forever
    redirect 'http://localhost:4000/test_controller/redirect_forever'
  end
  
  def json
    headers['Content-Type'] = 'application/json'
    '{"hello":"world"}'
  end
  
  def api_key
    params[:api_key]
  end
  
  def post
    raise('unsupported method') unless request.method == :post
    params[:narf]
  end
  
  def basic_auth
    basic_authentication('Ruby Tubesday Specs') do |username, password|
      username == 'narf' && password == 'blat'
    end
    'something secret'
  end
end
