# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "capistrano/faster_webpacker_assets/version"

Gem::Specification.new do |gem|
  gem.name          = "capistrano-faster-webpacker-assets"
  gem.version       = Capistrano::FasterWebpackerAssets::VERSION
  gem.authors       = ["Nguyen Dac Truong"]
  gem.licenses      = ["MIT"]
  gem.email         = ["nd.truong1902@gmail.com"]
  gem.description   = <<-EOF.gsub(/^\s+/, '')
    Speeds up asset compilation by skipping the assets:precompile task if none of the assets were changed since last release.
    Support when use rails with webpacker
    Works *only* with Capistrano 3+.
    Based on https://coderwall.com/p/aridag
  EOF
  gem.summary       = "Speeds up asset compilation if none of the assets were changed since last release."
  gem.homepage      = "https://github.com/truongkma/capistrano-faster-webpacker-assets"

  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ["lib"]

  gem.add_dependency "capistrano", "~> 3.1"
  gem.add_development_dependency "rake"
end
