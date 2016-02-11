require 'json'

class FakeRequest
  attr_reader :response

  def initialize(form_data)
    @form_data = form_data
    @response = {}
  end

  def build_request
    req = Net::HTTP::Post.new('/test')
    req.content_type = @form_data.content_type
    req.content_length = @form_data.size
    req.body_stream = @form_data

    req
  end

  def send!
    req = build_request
    http = Net::HTTP.new('localhost', 80)
    raw_response = http.request(req)
    @response = JSON.parse(raw_response.body)
  end

  def body
    @response['body']
  end

  def params
    @response['params']
  end

  def [](key)
    params[key]
  end
end
