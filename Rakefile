require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/sshpublisher'

PROJECT_NAME = "rb++"
RBPLUSPLUS_VERSION = "1.0.1"

task :default => :test

# We test this way because of what this library does.
# The tests wrap and load C++ wrapper code constantly.
# When running all the tests at once, we very quickly run 
# into problems where Rice crashes because 
# a given C++ class is already wrapped, or glibc doesn't like our 
# unorthodox handling of it's pieces. So we need to run the
# tests individually
desc "Run the tests"
task :test do
  require 'rbconfig'
  FileList["test/*_test.rb"].each do |file|
    # To allow multiple ruby installs (like a multiruby test suite), I need to get
    # the exact ruby binary that's linked to the ruby running the Rakefile. Just saying
    # "ruby" will find the system's installed ruby and be worthless
    ruby = File.join(Config::CONFIG["bindir"], Config::CONFIG["RUBY_INSTALL_NAME"])
    sh "#{ruby} -Itest #{file}"
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

namespace :web do
  desc "Build website"
  task :build => :rdoc do |t|
    unless File.directory?("publish")
      mkdir "publish"
    end

    sh "jekyll --pygment website publish/"
    sh "cp -r html/* publish/rbplusplus/"
  end

  desc "Update the website" 
  task :upload => "web:build"  do |t|
    Rake::SshDirPublisher.new("#{RUBYFORGE_USERNAME}@rubyforge.org", PROJECT_WEB_PATH, "publish").upload
  end

  desc "Clean up generated website files" 
  task :clean do
    rm_rf "publish"
  end
end

spec = Gem::Specification.new do |s|
  s.name = "rbplusplus"
  s.version = RBPLUSPLUS_VERSION
  s.summary = 'Ruby library to generate Rice wrapper code'
  s.homepage = 'http://rbplusplus.rubyforge.org'
  s.rubyforge_project = "rbplusplus"
  s.author = 'Jason Roelofs'
  s.email = 'jameskilton@gmail.com'

  s.description = <<-END
Rb++ combines the powerful query interface of rbgccxml and the Rice library to 
make Ruby wrapping extensions of C++ libraries easier to write than ever.
  END

  s.add_dependency "rbgccxml", "~> 1.0"
  s.add_dependency "rice", "~> 1.4.0"

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
end
