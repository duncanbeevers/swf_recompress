module SWFRecompress
  VERSION = "0.0.6"
  
  require 'fileutils'
  require 'pathname'
  require 'tempfile'
  
  ROOT       = File.join(File.dirname(__FILE__), '..')
  TMP_DIR    = Dir::tmpdir
  
  KZIP_HOST  = 'static.jonof.id.au'
  KZIP_MD5   = 'fdbf05e2bd12b16e899df0f3b6a3e87d'
  KZIP_PATH  = '/dl/kenutils/kzipmix-20091108-darwin.tar.gz'
  KZIP_ABOUT = <<-END_KZIP_ABOUT
  kzip by Ken Silverman: http://advsys.net/ken/utils.htm
  Mac OS X and Linux binaries maintained by Jonathan Fowler: http://www.jonof.id.au/
END_KZIP_ABOUT
  KZIP_INSTALL_TEXT = "  Install kzip binary to #{File.expand_path(File.join(ROOT, 'lib/kzip'))}"

  class Tempfile
    def self.open(temp_stem, write_mode = nil)
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
        File.open(temp_filename, write_mode || 'w') do |f|
          yield(f)
        end
      rescue => e
        raise "Error during Tempfile open #{e.message}"
      ensure
        FileUtils.rm(temp_filename)
        FileUtils.rm_rf(instance_tmp_dir)
      end
    end
  end
  
  class SWFRecompressor
    attr_reader :data_filename, :data_zip_filename, :info_filename, :swf_filename, :output_filename
    def initialize(swf_filename, output_filename)
      if !File.exists?(swf_filename)
        raise "The file #{swf_filename.inspect} does not exist"
      end
      @swf_filename    = swf_filename
      @output_filename = output_filename
    end
    
    def recompress!
      with_tempfiles do
        SWFRecompress.execute(swf_extract, kzip_data, swf_inject)
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
      kzip('-y', '-k0', data_zip_filename, data_filename)
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
      command('java', '-classpath', 'src', *args)
    end
    
    def kzip(*args)
      command('lib/kzip', *args)
    end
    
    def zip(*args)
      command('zip', *args)
    end
    
    def command(*args)
      SWFRecompress.command(*args)
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
    
    def recompress_to(filename, new_filename)
      expanded_filename = File.expand_path(filename)
      compressor        = SWFRecompressor.new(
        File.expand_path(filename),
        File.expand_path(new_filename))
      compressor.recompress!
    end
    
    def execute(*ramulons)
      execution = ramulons.join(' && ')
      results = ramulons.map { |command| `#{command} 2&> /dev/null` }
      puts results.join("\n")
      results
    end
    
    def command(*args)
      args.map { |arg| '"%s"' % arg }.join(' ')
    end
    
    def kzip_available?
      @kzip_available ||= File.exists?('lib/kzip') && KZIP_MD5 == kzip_md5('lib/kzip')
    end
    
    def kzip_md5(kzip_filename)
      require 'digest/md5'
      Digest::MD5.hexdigest(File.read(kzip_filename))
    end
    
    def acquire_kzip
      begin
        Tempfile.open('kzipmix.tar.gz', 'wb') do |f|
          begin
            download_kzipmix(f)
          rescue => e
            raise "There was an error downloading kzipmix"
          end
          extracted_kzip_filename = extract_kzipmix(f)
          if File.exists?(extracted_kzip_filename)
            extracted_kzip_md5 = kzip_md5(extracted_zip_filename)
            if KZIP_MD5 == extracted_kzip_md5
              FileUtils.cp(extracted_kzip_filename, File.expand_path(File.join(ROOT, 'lib/kzip')))
            else
              raise "The MD5 of the downloaded kzip #{extracted_kzip_md5} did not match the expected MD5 #{KZIP_MD5}"
            end
          else
            raise "Failed to extract kzip from the downloaded kzipmix archive"
          end
        end
      rescue => e
        raise "Unable to acquire kzip utility: #{e.message}\n#{KZIP_ABOUT}#{KZIP_INSTALL_TEXT}"
      end
    end
    
    private
    def download_kzipmix(f)
      require 'net/http'
      Net::HTTP.start(KZIP_HOST) do |http|
        f.write(http.get(KZIP_PATH).body)
        f.close
      end
    end
    
    def extract_kzipmix(f)
      fdir = Pathname.new(File.dirname(f.path))
      Dir.chdir(fdir) do
        execute(command('tar', 'xvzf', Pathname.new(f.path).relative_path_from(fdir), '--include', '*/kzip', '-s', '/.*kzip$/kzip/'))
      end
      File.join(File.dirname(f.path), 'kzip')
    end
  end
  
  extend ClassMethods
end
