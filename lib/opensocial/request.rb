# Copyright (c) 2008 Google Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module OpenSocial #:nodoc:
  
  # Provides a wrapper for a single request to an OpenSocial endpoint, either
  # as a standalone request, or as a fragment of an RPC request.
  #
  # The Request class wraps an HTTP request to an OpenSocial endpoint for
  # social data. A Request may be used, directly, to access social resources
  # that may not be currently wrapped by Request's child classes. Used in this
  # was it gives near-raw access to social data. The Request class supplies
  # OAuth signing when the supplied connection contains appropriate
  # credentials.
  #
  
  
  class Request
    GET = '.get'
    
    # Defines the connection that will be used in the request.
    attr_accessor :connection
    
    # Defines the guid for the request.
    attr_accessor :guid
    
    # Defines the selector for the request.
    attr_accessor :selector
    
    # Defines the pid for the request.
    attr_accessor :pid
    
    # Defines the key used to lookup the request result in an RPC request.
    attr_accessor :key
    
    # Initializes a request using the optionally supplied connection, guid,
    # selector, and pid.
    def initialize(connection = nil, guid = nil, selector = nil, pid = nil)
      @connection = connection
      @guid = guid
      @selector = selector
      @pid = pid
    end
    
    # Generates a request given the service, guid, selector, and pid, to the
    # OpenSocial endpoint by constructing the service URI and dispatching the
    # request. When data is returned, it is parsed as JSON after being
    # optionally unescaped.
    def send_request(service, guid, selector = nil, pid = nil,
                     unescape = false)
      if !@connection
        raise RequestException.new('Request requires a valid connection.')
      end
      
      uri = @connection.service_uri(@connection.container[:rest] + service,
                                    guid, selector, pid)
      data = dispatch(uri)
      
      if unescape
        JSON.parse(data.os_unescape)
      else
        JSON.parse(data)
      end
    end
    
    private
    
    # Dispatches a request to a given URI with optional POST data. If a
    # request's connection has specified HMAC-SHA1 authentication, OAuth
    # parameters and signature are appended to the request.
    def dispatch(uri, post_data = nil)
      http = Net::HTTP.new(uri.host) 
      
      if post_data
        req = Net::HTTP::Post.new(uri.request_uri)
        req.set_form_data(post_data)
      else
        req = Net::HTTP::Get.new(uri.request_uri)
      end
      
      @connection.sign!(http, req)
      
      if post_data
        resp = http.post(req.path, post_data)
        check_for_json_error!(resp)
      else
        resp = http.get(req.path)
        check_for_http_error!(resp)
      end
      
      return resp.body
    end
    
    # Checks the response object's status code. If the response is is
    # unauthorized, an exception is raised.
    def check_for_http_error!(resp)
      if !resp.kind_of?(Net::HTTPSuccess)
        if resp.is_a?(Net::HTTPUnauthorized)
          raise AuthException.new('The request lacked proper authentication ' +
                                  'credentials to retrieve data.')
        else
          resp.value
        end
      end
    end
    
    # Checks the JSON response for a status code. If a code is present an
    # exception is raised.
    def check_for_json_error!(resp)
      json = JSON.parse(resp.body)
      if json.is_a?(Hash) && json.has_key?('code') && json.has_key?('message')
        rc = json['code']
        message = json['message']
        case rc
        when 401:
          raise AuthException.new('The request lacked proper authentication ' +
                                  'credentials to retrieve data.')
        else
          raise RequestException.new("The request returned an unsupported " +
                                     "status code: #{rc} #{message}.")
        end
      end
    end
  end
  
  # Provides a wrapper for a single RPC request to an OpenSocial endpoint,
  # composed of one or more individual requests.
  #
  # The RpcRequest class wraps an HTTP request to an OpenSocial endpoint for
  # social data. An RpcRequest is intended to be used as a container for one
  # or more Requests (or Fetch*Requests), but may also be used with a manually
  # constructed post body. The RpcRequest class uses OAuth signing inherited
  # from the Request class, when appropriate OAuth credentials are supplied.
  #
  
  
  class RpcRequest < Request
    
    # Defines the requests sent in the single RpcRequest. The requests are
    # stored a key/value pairs.
    attr_accessor :requests
    
    # Initializes an RpcRequest with the supplied connection and an optional
    # hash of requests.
    def initialize(connection, requests = {})
      @connection = connection
      
      @requests = requests
    end
    
    # Adds one or more requests to the RpcRequest. Expects a hash of key/value
    # pairs (key used to refernece the data when it returns => the Request).
    def add(requests = {})
      @requests.merge!(requests)
    end
    
    # Sends an RpcRequest to the OpenSocial endpoint by constructing JSON for
    # the POST body and delegating the request to send_request. If an
    # RpcRequest is sent with an empty list of requests, an exception is
    # thrown. The response JSON is optionally unescaped (defaulting to true).
    def send(unescape = true)
      if @requests.length == 0
        raise RequestException.new('RPC request requires a non-empty hash ' +
                                   'of requests in order to be sent.')
      end
      
      json = send_request(request_json, unescape)
    end
    
    # Sends an RpcRequest to the OpenSocial endpoint by constructing the
    # service URI and dispatching the request. This method is public so that
    # an arbitrary POST body can be constructed and sent. The response JSON is
    # optionally unescaped.
    def send_request(post_data, unescape)
      uri = @connection.service_uri(@connection.container[:rpc], nil, nil, nil)
      data = dispatch(uri, post_data)

      parse_response(data, unescape)
    end
    
    private
    
    # Parses the response JSON. First, the JSON is unescaped, when specified,
    # then for each element specified in @requests, the appropriate response
    # is selected from the larger JSON response. This element is then delegated
    # to the appropriate class to be turned into a native object (Person,
    # Activity, etc.)
    def parse_response(response, unescape)
      if unescape
        parsed = JSON.parse(response.os_unescape)
      else
        parsed = JSON.parse(response)
      end
      keyed_by_id = key_by_id(parsed)

      native_objects = {}
      @requests.each_pair do |key, request|
        native_object = request.parse_rpc_response(keyed_by_id[key.to_s])
        native_objects.merge!({key => native_object})
      end
      
      return native_objects
    end
    
    # Constructs a hash of the elements in data referencing each element
    # by its 'id' attribute.
    def key_by_id(data)
      keyed_by_id = {}
      for entry in data
        keyed_by_id.merge!({entry['id'] => entry})
      end
      
      return keyed_by_id
    end
    
    # Modifies each request in an outgoing RpcRequest so that its key is set
    # to the value specified when added to the RpcRequest.
    def request_json
      keyed_requests = []
      @requests.each_pair do |key, request|
        request.key = key
        keyed_requests << request
      end
      
      return keyed_requests.to_json
    end
  end
  
  # An exception thrown when a request cannot return data.
  #
  
  
  class RequestException < RuntimeError; end
  
  # An exception thrown when a request returns a 401 unauthorized status.
  #
  
  
  class AuthException < RuntimeError; end
end