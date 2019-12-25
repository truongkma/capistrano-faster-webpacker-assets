# Capistrano::FasterWebpackerAssets

This gem speeds up asset compilation by skipping the assets:precompile task if none of the assets were changed
since last release.
Support when use rails with webpacker.

Works *only* with Capistrano 3+.

### Installation

Add this to `Gemfile`:

    group :development do
      gem 'capistrano', '~> 3.1'
      gem 'capistrano-rails', '~> 1.1'
      gem 'capistrano-faster-webpacker-assets', '~> 1.0'
    end

And then:

    $ bundle install

### Setup and usage
Add this line to `Capfile`, after `require 'capistrano/rails/assets'`

    require 'capistrano/faster_assets'

Configure your asset depedencies in deploy.rb if you need to check additional paths (e.g. if you have some assets in YOUR_APP/engines/YOUR_ENGINE/app/assets). Default paths are:

    set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
    set :use_webpacker, true

If you don't use webpacker in your project. Please change to `set :use_webpacker, false`

### Bug reports and pull requests

...are very welcome!

### Thanks

[@athal7](https://github.com/athal7) - for the original idea and implementation. See https://coderwall.com/p/aridag for more details
