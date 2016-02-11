require 'spec_helper'
require 'net/http'
require 'fileutils'
require 'support/fake_server'
require 'support/fake_request'

describe FormData do
  before(:each) do
    stub_request(:any, %r(localhost\/test\z)).to_rack(FakeServer)
  end

  it 'has a version number' do
    expect(FormData::VERSION).not_to be nil
  end

  describe '.new' do
    it 'returns new FormData' do
      f = FormData.new
      expect(f).to be_a(FormData::FormData)
    end
  end

  describe '.content_type' do
    it 'returns correct content type' do
      f = FormData.new

      expect(f.content_type).to match(%r(\Amultipart\/form-data;\s*boundary=))
    end

    it 'includes correct boundary value' do
      f = FormData.new
      boundary_from_content_type = f.content_type.match(/boundary=(.*)/)[1]

      expect(boundary_from_content_type).to eq(f.boundary)
    end
  end

  describe '.append' do
    it 'adds a value' do
      f = FormData.new
      f.append('test', 'test-value')

      r = FakeRequest.new(f)
      r.send!
      expect(r['test']).to eq('test-value')
    end

    it 'adds a file' do
      file = @example_files['text.txt']
      f = FormData.new
      f.append('file', file)

      r = FakeRequest.new(f)
      r.send!

      e = FileUtils.compare_file(file.path, r['file']['path'])
      expect(e).to eq(true)
    end

    it 'adds a file and guesses the content type' do
      file = @example_files['image.jpg']

      f = FormData.new
      f.append('file', file)

      r = FakeRequest.new(f)
      r.send!

      expect(r['file']['content_type']).to match(/\Aimage\/jpe?g\z/)
    end

    it 'adds a file with custom options' do
      file = @example_files['image.jpg']

      f = FormData.new
      f.append('file', file, {
        content_type: 'image/png',
        filename: 'test.png'
      })

      r = FakeRequest.new(f)
      r.send!

      expect(r['file']['content_type']).to eq('image/png')
      expect(r['file']['filename']).to eq('test.png')
    end

    it 'adds a file from an object responding to read' do
      file = StringIO.new('test')
      f = FormData.new
      f.append('file', file)

      r = FakeRequest.new(f)
      r.send!

      expect(File.read(r['file']['path'])).to eq('test')
    end

    it 'adds a file and closes it' do
      file = @example_files['image.jpg']
      f = FormData.new
      f.append('file', file)

      expect(file).to be_closed
    end

    it 'adds multiple values and files from hash' do
      image = @example_files['image.jpg']
      text = @example_files['text.txt']

      f = FormData.new
      f.append(
        image: image,
        text: text,
        test: 'value'
      )

      r = FakeRequest.new(f)
      r.send!

      expect(r.params.length).to eq(3)
      expect(r['image']['filename']).to eq('image.jpg')
      expect(r['text']['filename']).to eq('text.txt')
      expect(r['test']).to eq('value')
    end
  end

  describe '.read' do
    it 'reads buffer' do
      f = FormData.new
      f.append('test', 'value')

      expect(f.read).to match(Regexp.escape(f.boundary))
    end

    it 'ensures finalization of form data' do
      f = FormData.new
      f.append('test', 'value')

      last_line = f.read.each_line.to_a.last
      expect(last_line.strip).to eq('--' + f.boundary + '--')
    end
  end

  describe '.eof?' do
    it 'returns true if eof' do
      f = FormData.new
      f.append('test', 'value')
      f.read

      expect(f.eof?).to be(true)
    end

    it 'returns false unless eof' do
      f = FormData.new
      f.append('test', 'value')

      expect(f.eof?).to be(false)

      f.read(1)

      expect(f.eof?).to be(false)
    end
  end

  describe '.size' do
    it 'returns the content size in bytes' do
      f = FormData.new
      f.append('test', 'value')

      returned_size = f.size
      measured_size = f.read.size

      expect(returned_size).to eq(measured_size)
    end

    it 'returns the correct size' do
      f = FormData.new
      f.append('test', 'value')

      r = FakeRequest.new(f)
      r.send!
      expect(r.body.size).to eq(f.size)
    end

    it 'has an alias named length' do
      f = FormData.new
      f.append('test', 'value')

      expect(f.length).to eq(f.size)
    end
  end

  describe '.post_request' do
    it 'is compatible with net/http' do
      f = FormData.new
      f.append('test', 'value')

      http = Net::HTTP.new('localhost', 80)
      r = JSON.parse http.request(f.post_request('/test')).body

      expect(r['params']['test']).to eq('value')
    end
  end
end
