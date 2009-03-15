Gem::Specification.new do |s|
  s.name = %q{currency}
  s.version = "0.7.0.1"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Asa Wilson", "David Palm"]
  s.date = %q{#{Date.today}}
  s.description = %q{Currency conversions for Ruby}
  s.email = ["acvwilson@gmail.com", "dvdplm@gmail.com"]
  s.extra_rdoc_files = ["ChangeLog", "COPYING.txt", "LICENSE.txt", "Manifest.txt", "README.txt", "Releases.txt", "TODO.txt"]
  s.files = ["COPYING.txt", "currency.gemspec", "examples/ex1.rb", "examples/xe1.rb", "lib/currency/active_record.rb", "lib/currency/config.rb", "lib/currency/core_extensions.rb", "lib/currency/currency/factory.rb", "lib/currency/currency.rb", "lib/currency/exception.rb", "lib/currency/exchange/rate/deriver.rb", "lib/currency/exchange/rate/source/base.rb", "lib/currency/exchange/rate/source/failover.rb", "lib/currency/exchange/rate/source/federal_reserve.rb", "lib/currency/exchange/rate/source/historical/rate.rb", "lib/currency/exchange/rate/source/historical/rate_loader.rb", "lib/currency/exchange/rate/source/historical/writer.rb", "lib/currency/exchange/rate/source/historical.rb", "lib/currency/exchange/rate/source/new_york_fed.rb", "lib/currency/exchange/rate/source/provider.rb", "lib/currency/exchange/rate/source/test.rb", "lib/currency/exchange/rate/source/the_financials.rb", "lib/currency/exchange/rate/source/timed_cache.rb", "lib/currency/exchange/rate/source/xe.rb", "lib/currency/exchange/rate/source.rb", "lib/currency/exchange/rate.rb", "lib/currency/exchange/time_quantitizer.rb", "lib/currency/exchange.rb", "lib/currency/formatter.rb", "lib/currency/macro.rb", "lib/currency/money.rb", "lib/currency/money_helper.rb", "lib/currency/parser.rb", "lib/currency.rb", "LICENSE.txt", "Manifest.txt", "README.txt", "Releases.txt", "spec/ar_spec_helper.rb", "spec/ar_simple_spec.rb", "spec/config_spec.rb", "spec/federal_reserve_spec.rb", "spec/formatter_spec.rb", "spec/historical_writer_spec.rb", "spec/macro_spec.rb", "spec/money_spec.rb", "spec/new_york_fed_spec.rb", "spec/parser_spec.rb", "spec/spec_helper.rb", "spec/time_quantitizer_spec.rb", "spec/timed_cache_spec.rb", "spec/xe_spec.rb", "TODO.txt"]
  s.has_rdoc = true
  s.homepage = %q{http://currency.rubyforge.org/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{#{s.name} #{s.version}}
end
