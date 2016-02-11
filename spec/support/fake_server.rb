require 'sinatra/base'
require 'json'

class FakeServer < Sinatra::Base
  post '/test' do
    has_files = false
    params.each do |name, value|
      next unless value.is_a?(Hash)

      file = value[:tempfile]
      filename = value[:filename]

      path = File.expand_path("../tmp/#{filename}", File.dirname(__FILE__))
      File.open(path, 'wb') do |f|
        f.write file.read(1024**2) unless file.eof?
      end

      params[name] = {
        filename: filename,
        content_type: value[:type],
        path: path
      }
      has_files = true
    end

    status 200

    content_type :json
    JSON.dump(
      headers: {
        content_type: request.env['CONTENT_TYPE'],
        content_length: request.env['HTTP_CONTENT_LENGTH'].to_i
      },
      body: has_files ? nil : request.body.read,
      params: params
    )
  end
end
