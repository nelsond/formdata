# FormData [![Build Status](https://travis-ci.org/nelsond/formdata.svg?branch=master)](https://travis-ci.org/nelsond/formdata)

Ruby gem to generate data in the same format as "multipart/form-data".
The gem is heavily inspired by the [JavaScript FormData API](https://developer.mozilla.org/en/docs/Web/API/FormData).
 
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'formdata'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install formdata

## Example usage

```ruby
require 'formdata'
require 'stringio'
require 'net/http'

# create form data
f = FormData.new

# append some text values...
f.append('name', 'Richard')
f.append('surname', 'Feynman')

# ...and some files...
f.append('avatar-file', File.open('some/file.jpg'))
f.append('cv-file', File.open('some/file.pdf'), {
  :content_type => 'application/pdf',
  :filename => 'cv.pdf'
})
f.append('text-file', StringIO.new('test'), {
  :content_tyoe => 'text/plain',
  :filename => 'text.txt'
})

# ...or multiple values from a hash
f.append({
    'street' => '1200 E California Blvd',
    'city' => 'Pasadena',
    'zip' => '91125',
    'state' => 'CA',
    'map-file' => File.open('some/file.pdf')
})

# create a new net/http request
req = Net::HTTP::Post.new('/test')
req.content_type = f.content_type
req.content_length = f.size
req.body_stream = f

# send the request
http = Net::HTTP.new('localhost', 80)
http.request(req) # => ...response

# or use the request constructor
req = f.post_request('/test')
http = Net::HTTP.new('localhost', 80)
http.request(req) # => ...response
```

## Supported Ruby versions

This library requires a Ruby version >= 1.9.2 and is tested against the
following versions:

- Ruby 1.9.2
- Ruby 1.9.3
- Ruby 2.0.0
- Ruby 2.1.8
- Ruby 2.2.4
- Ruby 2.3.0
