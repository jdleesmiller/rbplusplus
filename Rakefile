require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/sshpublisher'

PROJECT_NAME = "rb++"
RBPLUSPLUS_VERSION = "0.1"

task :default => :test

# We test this way because of what this library does.
# The tests wrap and load C++ wrapper code constantly.
# When running all the tests at once, we very quickly run 
# into problems where Rice crashes because 
# a given C++ class is already wrapped. So we need to run the
# tests individually
desc "Run the tests"
task :test do
  FileList["test/*_test.rb"].each do |file|
    ruby file
  end
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include("README", "lib/**/*.rb")
  rd.rdoc_files.exclude("**/jamis.rb")
  rd.template = File.expand_path(File.dirname(__FILE__) + "/lib/jamis.rb")
  rd.options << '--line-numbers' << '--inline-source'
end

RUBYFORGE_USERNAME = "jameskilton"
PROJECT_WEB_PATH = "/var/www/gforge-projects/rbplusplus"

desc "Update the website" 
task :upload_web => :rdoc  do |t|
  unless File.directory?("publish")
    mkdir "publish"
    mkdir "publish/rbplusplus"
  end
  sh "svn export --force website publish/"
  sh "cp -r html/* publish/rbplusplus/"
	Rake::SshDirPublisher.new("#{RUBYFORGE_USERNAME}@rubyforge.org", PROJECT_WEB_PATH, "publish").upload
  rm_rf "publish"
end

spec = Gem::Specification.new do |s|
  s.name = "rbplusplus"
  s.version = RBPLUSPLUS_VERSION
  s.summary = 'Ruby library to generate Rice wrapper code'
  s.homepage = 'http://rbplusplus.rubyforge.org/rbplusplus'
  s.rubyforge_project = "rbplusplus"
  s.author = 'Jason Roelofs'
  s.email = 'jameskilton@gmail.com'

  s.description = <<-END
Rb++ combines the powerful query interface of rbgccxml and the Rice library to 
make Ruby wrapping extensions easier to write than ever.
  END

  patterns = [
    'TODO',
    'Rakefile',
    'lib/**/*.rb',
  ]

  s.files = patterns.map {|p| Dir.glob(p) }.flatten

  s.test_files = [Dir.glob('test/**/*.rb'), Dir.glob('test/headers/**/*')].flatten

  s.require_paths = ['lib']
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end