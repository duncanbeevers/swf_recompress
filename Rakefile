JAVA_SOURCE_FILES = FileList['src/*.java']
JAVA_CLASS_FILES = FileList['src/*.class']

task :default => :build_javas

task :build_javas => JAVA_CLASS_FILES do
  JAVA_SOURCE_FILES.each do |java_source_file|
    `javac #{java_source_file}`
  end
end
