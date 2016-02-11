require 'formdata/version'
require 'securerandom'
require 'tempfile'
require 'mkmf'
require 'net/http'

module FormData
  def self.new
    FormData.new
  end

  class FormData
    attr_reader :boundary

    def initialize
      @id = SecureRandom.hex(10).freeze

      @buffer = Tempfile.new(@id)
      @buffer.binmode

      @boundary = "----RubyFormBoundary#{@id}".freeze

      @finalized = false
    end

    def append(name, value = nil, opts = {})
      if name.is_a?(Hash)
        name.each { |n, v| append(n, v) }
        return
      end

      if value.respond_to?(:read)
        append_file(name, value, opts)
      else
        append_text(name, value)
      end
    end

    def content_type
      "multipart/form-data; boundary=#{@boundary}"
    end

    def size
      @finalized ? @buffer.size : @buffer.size + epilogue.size
    end
    alias length size

    def read(*args)
      finalize! unless @finalized
      @buffer.read(*args)
    end

    def eof?(*args)
      return false unless @finalized
      @buffer.eof?(*args)
    end

    def post_request(*args)
      req = Net::HTTP::Post.new(*args)
      req.content_type = content_type
      req.content_length = size
      req.body_stream = self

      req
    end

    private

    def append_text(name, text)
      write_boundary
      @buffer.write %(Content-Disposition: form-data; name="#{name}"\r\n\r\n)
      @buffer.write text.to_s
    end

    def append_file(name, file, opts = {})
      opts[:filename] ||= File.basename(file.path) if file.respond_to?(:path)

      if file.respond_to?(:path) && File.readable?(file.path)
        opts[:content_type] ||= guess_mime_type(file)
      end

      opts = {
        content_type: 'application/octet-stream',
        filename: 'unknown'
      }.merge(opts)

      write_boundary
      @buffer.write %(Content-Disposition: form-data; name="#{name}"; filename="#{opts[:filename]}"\r\n)
      @buffer.write %(Content-Type: #{opts[:content_type]}\r\n\r\n)

      chunk_size = 1024**2
      @buffer.write file.read(chunk_size) until file.eof?
      file.close
    end

    def write_boundary
      @buffer.write "\r\n" if size > 0
      @buffer.write "--#{@boundary}\r\n"
    end

    def epilogue
      "\r\n--#{@boundary}--\r\n"
    end

    def finalize!
      @buffer.write epilogue
      @buffer.rewind
      @finalized = true
    end

    def guess_mime_type(file)
      return unless find_executable0('file')

      content_type = nil
      IO.popen(['file', '--brief', '--mime-type', file.path]) do |m|
        content_type = m.read.strip
      end

      $?.exitstatus == 0 ? content_type : nil
    end
  end
end
