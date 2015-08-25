class Common < Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super
    @objects = {}

    # Add helper functions to the App scope
    app.extend CommonMethods
  end

  module CommonMethods
  end

  helpers do
    def aside(content, options={})
      asideClass = 'notice'
      if options[:class]
        asideClass = options[:class]
      end

      "<aside class=\"#{asideClass}\">#{@markdown.render(content)}</aside>"
    end
  end
end
