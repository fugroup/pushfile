module Pushfile
  module Data

    # Setup methods.
    # Currently ajax uploads, froala uploads and url uploads are supported.

    # Set up data
    def setup_data
      # Fetch the image into a tempfile, and store
      if @options[:url]
        url_upload

      elsif @options[:filename]
        ajax_upload

      # Do Froala or Dropzone file uploads
      elsif @options[:file] || @options[:datafile]
        file_upload
      end
    end

    # Ajax upload
    def ajax_upload
      filename = @options[:filename]
      type = @options[:mimetype] || mimetype(filename)
      file = @options[:tempfile] || "/tmp/upload-#{filename}"

      # Pass stream (typically request.body) to read chunks
      if @options[:stream]
        File.open(file, 'w') do |f|
          f.binmode
          while buffer = @options[:stream].read(51200)
            f << buffer
          end
        end
      end

      {:filename => filename, :tempfile => File.new(file), :type => type}
    end

    # File upload
    def file_upload
      o = @options[:file] || @options[:datafile]
      tmpfile, filename = o[:tempfile], o[:filename]
      type = o[:type] || mimetype(filename)

      {:filename => filename, :tempfile => tmpfile, :type => type}
    end

    # URL upload
    def url_upload
      url = @options[:url].strip

      content = RestClient.get(url) rescue nil

      file = Tempfile.new('tmp').tap do |file|
        file.binmode # must be in binary mode
        file.write(content)
        file.rewind
      end if content

      # Extract the file name from the URL
      filename = url.split('/').last

      # Mime type
      type = @options[:mimetype] || mimetype(filename)

      {:filename => filename, :type => type, :tempfile => file}
    end

    private

    # Get the mime type from a file name
    def mimetype(path)
      extension = File.basename(path).split('.')[-1]
      Rack::Mime.mime_type(".#{extension}")
    end

  end
end
