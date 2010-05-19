require 'lib/swf_recompress'
require 'rake/gempackagetask'

JAVA_SOURCE_FILES = FileList['src/*.java']
JAVA_CLASS_FILES = FileList['src/*.class']

desc "Build Java class files"
task :build_javas => JAVA_CLASS_FILES do
  JAVA_SOURCE_FILES.each do |java_source_file|
    `javac #{java_source_file}`
  end
end

spec = Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.summary      = "Recompress a swf file with more aggressive DEFLATE settings"
  s.name         = 'swf_recompress'
  s.version      = SWFRecompress::VERSION
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files        = FileList["lib/**/*", "src/**/*", "bin/**/*"].exclude(/\.gitignore/)
  s.description  = "Recompress a swf file with more aggressive DEFLATE settings"
  s.homepage     = "http://github.com/duncanbeevers/swf_recompress"
  s.author       = "Duncan Beevers"
  s.email        = "duncan@dweebd.com"
  s.add_bindir('bin')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
