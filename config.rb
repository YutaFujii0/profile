require 'sinatra/base'
require 'sprockets'
require 'uglifier'
require 'sass'
require 'sinatra/sprockets-helpers'
require_relative 'app'

# To be checked if these part is necessary
# ===========================================
require "rack/codehighlighter"
require "pygments"
use ::Rack::Codehighlighter,
  :pygments,
  :element => "pre>code",
  :pattern => /\A:::([-_+\w]+)\s*\n/,
  :markdown => true
# ===========================================

# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end
# comment out(use later to solve sprockets problem)
# activate :sprockets do |c|
#   c.imported_asset_path = File.expand_path("../source/assets", __FILE__)
#   puts c
# end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

# helpers do
#   def some_helper
#     'Helping'
#   end
# end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end

class MySinatra < Sinatra::Base
  register Sinatra::Sprockets::Helpers
  set :sprockets ,Sprockets::Environment.new
  set :assets_prefix, '/assets'
  set :digest_assets, true
  set :views, [ File.expand_path("../source/views/", __FILE__),File.expand_path("../source/views/layouts", __FILE__) ]
  set :public_folder, File.expand_path("../source", __FILE__)

  configure do
    sprockets.append_path "source/assets/javascripts"
    sprockets.append_path "source/assets/stylesheets"
    sprockets.js_compressor  = :uglify
    sprockets.css_compressor = :scss

    configure_sprockets_helpers do |helpers|
      helpers.asset_host = 'some-bucket.s3.amazon.com'
    end
  end

  helpers do
    def find_template(views, name, engine, &block)
      Array(views).each { |v| super(v, name, engine, &block) }
    end
  end
  get "/" do
    haml :index, "layouts/layout" => :post
  end

  # just for the 'middelman build' code, no other purpose
  get "/views/index" do
    haml :index, "layout" => :post
  end
  get "/views/layouts/layout" do
    haml "layouts/layout"
  end
end

# need this code to run sinatra with the terminal code 'middleman server'
map "/" do
  run MySinatra
end
