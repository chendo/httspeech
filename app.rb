require 'bundler'
Bundler.require
require 'tempfile'
require 'open3'

configure do
  set :server, :puma
  set :environment, :production
  set :port, ENV.fetch("PORT", 4567).to_i
end

class SpeechRenderError < StandardError; end

def say(text, voice: nil)
  f = Tempfile.new
  puts "Rendering '#{text}' with voice #{voice || 'default'}"
  path = "#{f.path}.mp4"
  cmd = ["say", "--file-format", "mp4f", "-o", path]
  cmd += ["-v", voice] if voice
  cmd << text
  Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thr|
    err = stderr.read
    if err.length > 0
      raise SpeechRenderError.new(err)
    end
  end
  data = File.read(path)
  f.unlink
  FileUtils.rm(path)
  data
end

get %r|/([^/]+)/?([^.]+)?\.mp4?$| do |text, voice|
  range = request.env['HTTP_RANGE']
  begin
    data = say(URI.decode_www_form_component(text), **{voice: voice}.reject { |_, v| v.nil? })
    if range
      start, finish = range.split('bytes=', 2).last.split('-', 2).map(&:to_i)
      if finish.zero?
        finish = data.length
      end
      status 206
      data[start, finish - start]
    else
      data
    end
  rescue SpeechRenderError => e
    status 500
    e.to_s
  end
end
