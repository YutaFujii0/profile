require 'sinatra/base'

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
