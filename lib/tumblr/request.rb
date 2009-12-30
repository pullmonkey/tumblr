class Tumblr
  class Request
    
    # a GET request to http://[YOURUSERNAME].tumblr.com/api/read
    def self.read(options = {})
      # enable authenticated reads for private posts
      if options.has_key?(:email) and options.has_key?(:password) 
        # if we have both email and password, then we need to do a POST thus authenticating
        # TODO but this does not work because of the Post::count method - if all posts are private 
        # then the total returned in count will always be 0 which means we will never get here.
        response = HTTParty.post("http://#{Tumblr::blog ||= 'staff'}.tumblr.com/api/read", :query => options)
      else
        response = HTTParty.get("http://#{Tumblr::blog ||= 'staff'}.tumblr.com/api/read", :query => options)
      end
      return response unless raise_errors(response)
    end
    
    # a POST request to http://www.tumblr.com/api/write
    def self.write(options = {})
      response = HTTParty.post('http://www.tumblr.com/api/write', :query => options)
      return(response) unless raise_errors(response)
    end
    
    # a POST request to http://www.tumblr.com/api/delete
    def self.delete(options = {})
      response = HTTParty.post('http://www.tumblr.com/api/delete', :query => options)
      return(response) unless raise_errors(response)
    end
    
    # a POST request to http://www.tumblr.com/api/authenticate
    def self.authenticate(email, password)
      HTTParty.post('http://www.tumblr.com/api/authenticate', :query => {:email => email, :password => password})
    end
    
    # raise tumblr response errors.
    def self.raise_errors(response)
      if(response.is_a?(Hash))
        message = "#{response[:code]}: #{response[:body]}"
        code = response[:code].to_i
      else
        message = "#{response.code}: #{response.body}"
        code = response.code.to_i
      end
      
      case code
        when 403
          raise(Forbidden.new, message)
        when 400
          raise(BadRequest.new, message)
        when 404
          raise(NotFound.new, message)
        when 201
          return false
      end        
    end
    
  end
end
