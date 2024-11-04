require_relative 'spec_helper'
require_relative '../lib/request'

describe 'Request' do

    describe 'Simple get-request' do
    
        it 'parses the http method' do
            @request = Request.new(File.read('./spec/example_requests/get-index.request.txt'))
            _(@request.method).must_equal :get
        end

        it 'parses the resource' do
            @request = Request.new(File.read('./spec/example_requests/get-index.request.txt'))
            _(@request.resource).must_equal "/"
        end

        it 'parses the http method' do
            @request = Request.new(File.read('./spec/example_requests/post-login.request.txt'))
            _(@request.method).must_equal :post
        end

        it 'parses the http version' do
            @request = Request.new(File.read('./spec/example_requests/get-index.request.txt'))
            _(@request.version).must_equal "HTTP/1.1"
        end

        it 'parses the http header' do
            @request = Request.new(File.read('./spec/example_requests/get-index.request.txt'))
            headers = {'Host' => 'developer.mozilla.org', 'Accept-Language' => 'fr'}
            _(@request.headers).must_equal headers
        end

        it 'parses the params for get' do
            @request = Request.new(File.read('./spec/example_requests/get-fruits-with-filter.request.txt'))
            params = {"type" => "bananas", "minrating" => "4"}
            _(@request.params).must_equal params
        end

        it 'parses the params for post' do
            @request = Request.new(File.read('./spec/example_requests/post-login.request.txt'))
            params = {"username" => "grillkorv", "password" => "verys3cret!"}
            _(@request.params).must_equal params
        end

        it 'handles post request with empty body' do
            @request = Request.new(File.read('./spec/example_requests/post-empty-body.request.txt'))
            _(@request.params).must_equal({})
        end


    end


end