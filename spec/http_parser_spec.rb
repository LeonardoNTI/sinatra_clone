require_relative 'spec_helper'
require_relative '../lib/request'

describe 'Request' do
  def assert_request_parses(file, expected_value, type)
    @request = Request.new(File.read(file))

    # Centralized assertion logic without excess branching
    result = case type
             when :method
               @request.method
             when :resource
               @request.resource
             when :version
               @request.version
             when :headers
               @request.headers
             when :params
               @request.params
             end

    # Assert that the result matches the expected value
    _(result).must_equal expected_value
  end

  describe 'Simple get-request' do
    it 'parses the http method' do
      assert_request_parses('./spec/example_requests/get-index.request.txt', :get, :method)
    end

    it 'parses the resource' do
      assert_request_parses('./spec/example_requests/get-index.request.txt', '/', :resource)
    end

    it 'parses the http method for post request' do
      assert_request_parses('./spec/example_requests/post-login.request.txt', :post, :method)
    end

    it 'parses the http version' do
      assert_request_parses('./spec/example_requests/get-index.request.txt', 'HTTP/1.1', :version)
    end

    it 'parses the http header' do
      headers = {'Host' => 'developer.mozilla.org', 'Accept-Language' => 'fr'}
      assert_request_parses('./spec/example_requests/get-index.request.txt', headers, :headers)
    end

    it 'parses the params for get' do
      params = {"type" => "bananas", "minrating" => "4"}
      assert_request_parses('./spec/example_requests/get-fruits-with-filter.request.txt', params, :params)
    end

    it 'parses the params for post' do
      params = {"username" => "grillkorv", "password" => "verys3cret!"}
      assert_request_parses('./spec/example_requests/post-login.request.txt', params, :params)
    end

    it 'handles post request with empty body' do
      @request = Request.new(File.read('./spec/example_requests/post-empty-body.request.txt'))
      _(@request.params).must_equal({})
    end
  end
end
