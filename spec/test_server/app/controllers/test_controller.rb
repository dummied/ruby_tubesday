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
end
