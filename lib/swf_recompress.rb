module SWFRecompress
  require 'fileutils'
  require 'pathname'
  
  ROOT    = File.dirname(__FILE__)
  TMP_DIR = File.join(ROOT, 'tmp')
  class Tempfile
    def self.open(temp_stem)
      begin
        instance_tmp_dir = nil
        begin
          instance_tmp_dir = File.join(TMP_DIR, rand(1_000_000).to_s)
        end until !File.exists?(instance_tmp_dir)
        FileUtils.mkdir_p(instance_tmp_dir)
        ext           = File.extname(temp_stem)
        temp_filename = Pathname.new(
            File.expand_path(File.join(instance_tmp_dir, '%s%s' % [ File.basename(temp_stem, ext), ext ]))
          ).relative_path_from(Pathname.new(Dir.pwd))
        File.open(temp_filename, 'w') do |f|
          yield(f)
        end
      rescue => e
        puts "Error: #{e}"
      ensure
        FileUtils.rm(temp_filename)
        FileUtils.rmdir(instance_tmp_dir)
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
        execute_commands(swf_extract, kzip_data, swf_inject)
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
      kzip('-y', '-k0', '-v', data_zip_filename, data_filename)
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
    
    def kzip(*args)
      execute('bin/kzip', *args)
    end
    
    def zip(*args)
      execute('zip', *args)
    end
    
    def execute(*args)
      args.map { |arg| '"%s"' % arg }.join(' ')
    end
    
    def execute_commands(*commands)
      execution = commands.join(' && ')
      commands.each do |command|
        puts "executing: #{command}"
        puts `#{command}`
      end
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
