lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'expiring_asset_links/version'
require 'date'

Gem::Specification.new do |s|
  s.name    = 'expiring_asset_links'
  s.version = ExpiringAssetLinks::Version.string
  s.date    = Date.today

  s.summary     = 'CarrierWave FOG Expiring Asset Links'
  s.description = 'Handles storing and generating CarrierWave FOG expiring asset link stored in string and text attributes of ActiveRecord objects'
  s.license     = 'MIT'

  s.author   = 'chaunce'
  s.email    = 'chaunce.slc@gmail.com'
  s.homepage = 'http://github.com/chaunce/expiring_asset_links'

  s.has_rdoc = false
  s.rdoc_options = ['--line-numbers', '--inline-source', '--main', 'README.rdoc']

  s.require_paths = ['lib']
  
  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency('carrierwave')
  s.add_dependency('fog')
  s.add_dependency('rails')
  s.add_development_dependency('sqlite3')
end
