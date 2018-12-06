require 'sinatra/base'
require 'sprockets'
require 'uglifier'
require 'sass'
require 'sinatra/sprockets-helpers'
require './app'
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
class MyFeature < Middleman::Extension

  def manipulate_resource_list(resources)
    resources.each do |resource|
      # resource.destination_path.gsub!(/views\/.*/, " ")
    end

    resources
  end
end
::Middleman::Extensions.register(:my_feature, MyFeature)
activate :my_feature


configure :build do
  activate :minify_css
  activate :minify_javascript

  # Append a hash to asset urls (make sure to use the url helpers)
  activate :asset_hash

  activate :asset_host, :host => '//yutafujii.cloudfront.net'
end

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
  get "/views/index" do
    haml :index, "layout" => :post
  end
  get "/views/layouts/layout" do
    haml "layouts/layout"
  end
end


map "/sinatra" do
  run MySinatra
end
