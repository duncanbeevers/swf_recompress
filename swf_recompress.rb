#!/usr/bin/env ruby
require 'tempfile'

require 'rubygems'
require 'ruby-debug'

module SWFRecompress
  ROOT    = File.dirname(__FILE__)
  TMP_DIR = File.join(ROOT, 'tmp')
  class Tempfile
    def self.open(temp_stem)
      FileUtils.mkdir_p(TMP_DIR)
      ext           = File.extname(temp_stem)
      temp_filename = Pathname.new(
          File.expand_path(File.join(TMP_DIR, '%s%s' % [ File.basename(temp_stem, ext), ext ]))
        ).relative_path_from(Pathname.new(Dir.pwd))
      begin
        File.open(temp_filename, 'w') do |f|
          yield(f)
        end
      ensure
        FileUtils.rm(temp_filename)
      end
    end
  end
  
  class SWFRecompressor
    attr_reader :data_filename, :data_zip_filename, :info_filename, :swf_filename, :output_filename
    def initialize(swf_filename, output_filename)
      raise "You must specify a swf file to recompress" unless File.exists?(swf_filename)
      @swf_filename    = swf_filename
      @output_filename = output_filename
    end
    
    def recompress!
      with_tempfiles do
        swf_extract
        kzip_data
        swf_inject
      end
    end
    
    private
    def swf_extract
      java('SWFExtract', swf_filename, data_filename, info_filename)
    end
    
    def swf_inject
      java('SWFInject', data_zip_filename, info_filename, output_filename)
    end
    
    def kzip_data
      kzip('-y', '-s0', data_zip_filename, data_filename)
    end
    
    def kzip(*args)
      execute('bin/kzip', *args)
    end
    
    def with_tempfiles
      Dir.chdir(ROOT) do
        with_temp_info_file do
          with_temp_data_file do
            with_temp_data_zip_file do
              yield
            end
          end
        end
      end
    end
    
    def with_temp_info_file
      Tempfile.open('INFO') do |f|
        f.close
        @info_filename = f.path
        yield
      end
    end
    
    def with_temp_data_file
      Tempfile.open('SWF_DATA') do |f|
        f.close
        @data_filename = f.path
        yield
      end
    end
    
    def with_temp_data_zip_file
      Tempfile.open('SWF_DATA.zip') do |f|
        f.close
        @data_zip_filename = f.path
        yield
      end
    end
    
    def java(*args)
      execute('java', '-classpath', 'src', *args)
    end
    
    def execute(*args)
      execution_string = args.map { |arg| '"%s"' % arg }.join(' ')
      `#{execution_string}`
    end
  end
  
  module ClassMethods
    def recompress(filename)
      expanded_filename = File.expand_path(filename)
      ext               = File.extname(expanded_filename)
      dirname           = File.dirname(expanded_filename)
      new_filename      = File.join(dirname, '%s%s%s' % [ File.basename(expanded_filename, ext), '_compressed', ext ])
      compressor        = SWFRecompressor.new(expanded_filename, new_filename)
      compressor.recompress!
    end
  end
  
  extend ClassMethods
end

SWFRecompress.recompress(ARGV[0])
