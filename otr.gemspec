
require "lib/otr"

spec = Gem::Specification.new do |s|
  s.name = "otr"
  s.version = OTR::VERSION
  s.author = "Stephen McDonald"
  s.email = "steve@jupo.org"
  s.homepage = "http://jupo.org"
  s.description = s.summary = "Combined GitHub and Bitbucket API."
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.add_dependency "rest-client"
  s.executables = [s.name]
  s.require_path = 'lib'
  s.files = %w(LICENSE README.rdoc) + Dir.glob("{lib,bin}/**/*")
end
