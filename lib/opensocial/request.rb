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
    
    attr_accessor :connection
    attr_accessor :guid, :selector, :pid
    
    attr_accessor :key
    
    def initialize(connection = nil, guid = nil, selector = nil, pid = nil)
      @connection = connection
      @guid = guid
      @selector = selector
      @pid = pid
    end
    
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
    
    def dispatch(uri, post_data = nil)
      http = Net::HTTP.new(uri.host) 
      
      if post_data
        req = Net::HTTP::Post.new(uri.request_uri)
        req.set_form_data(post_data)
      else
        req = Net::HTTP::Get.new(uri.request_uri)
      end
      
      if @connection.auth == Connection::AUTH_HMAC
        consumer = OAuth::Consumer.new(@connection.consumer_key,
                                       @connection.consumer_secret)
        req.oauth!(http, consumer, @connection.consumer_token,
                   :scheme => 'query_string')
      end
      
      if post_data
        resp = http.post(req.path, post_data)
        check_for_json_error!(resp)
      else
        resp = http.get(req.path)
        check_for_http_error!(resp)
      end
      
      return resp.body
    end
    
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
    attr_accessor :requests
    
    def initialize(connection, requests = {})
      @connection = connection
      
      @requests = requests
    end
    
    def add(requests = {})
      @requests.merge!(requests)
    end
    
    def send(unescape = true)
      if @requests.length == 0
        raise RequestException.new('RPC request requires a non-empty hash ' +
                                   'of requests in order to be sent.')
      end
      
      json = send_request(request_json, unescape)
    end
    
    def send_request(post_data, unescape)
      uri = @connection.service_uri(@connection.container[:rpc], nil, nil, nil)
      data = dispatch(uri, post_data)

      parse_response(data, unescape)
    end
    
    private
    
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
    
    def key_by_id(data)
      keyed_by_id = {}
      for entry in data
        keyed_by_id.merge!({entry['id'] => entry})
      end
      
      return keyed_by_id
    end
    
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