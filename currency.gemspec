Gem::Specification.new do |s|
  s.name = %q{currency}
  s.version = "0.5.0"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Asa Wilson"]
  s.date = %q{2008-11-14}
  s.description = %q{Currency conversions for Ruby}
  s.email = ["acvwilson@gmail.com"]
  s.extra_rdoc_files = ['ChangeLog', *Dir.glob(File.join(File.dirname(__FILE__), '*.txt')).map {|f| f[2..-1]}]
  s.files = [*Dir.glob(File.join(File.dirname(__FILE__), '**/*.*')).map {|f| f[2..-1]}]
  s.has_rdoc = true
  s.homepage = %q{http://currency.rubyforge.org/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{currency}
  s.rubygems_version = %q{0.4.11}
  s.summary = %q{currency 0.5.0}
end