require "lib/api_objects"
::Middleman::Extensions.register(:api_objects, ApiObjects)

activate :api_objects

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :fonts_dir, 'fonts'

set :markdown_engine, :redcarpet

set :markdown, 
      :fenced_code_blocks => true, 
      :smartypants => true, 
      :disable_indented_code_blocks => true, 
      :prettify => true, 
      :tables => true, 
      :with_toc_data => true, 
      :no_intra_emphasis => true

# Activate the syntax highlighter
activate :syntax

require "lib/code_colors"

# Settings for the main page
page "*" do
  @api_prefix = "https://api.wheniwork.com"
  @wiw_key = "iworksoharditsnotfunny"
  @wiw_token = "ilovemyboss"
end


# This is needed for Github pages, since they're hosted on a subdomain
activate :relative_assets
set :relative_links, true

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

