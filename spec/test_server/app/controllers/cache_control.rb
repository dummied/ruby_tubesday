class CacheControl < Application
  def private
    headers['Cache-Control'] = 'private'
    update_counter
  end
  
  def no_cache
    headers['Cache-Control'] = 'no-cache'
    update_counter
  end
  
  def no_store
    headers['Cache-Control'] = 'no-store'
    update_counter
  end
  
  def must_revalidate
    headers['Cache-Control'] = 'must-revalidate'
    update_counter
  end
  
  def max_age
    headers['Cache-Control'] = 'public, max-age=5'
    update_counter
  end
  
  def s_maxage
    headers['Cache-Control'] = 'max-age=10, s-maxage=5'
    update_counter
  end
  
protected
  
  def update_counter
    @@counter ||= 0
    @@counter += 1
    @@counter.to_s
  end
end
