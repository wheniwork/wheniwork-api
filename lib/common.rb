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

    # Creates an aside with markdown formatting. Because of stupid problems
    # with ERB, this cannot be echoed normally, and handles output itself instead.
    # So you have to call it with <%= this syntax %>, instead of <% this %>.
    def aside(options={})
      # ERB is terrible, so we have to "capture" the
      # contents of the block we just passed in.
      # http://apidock.com/rails/ActionView/Helpers/CaptureHelper/capture
      content = capture do yield end

      asideClass = 'notice'
      if options[:class]
        asideClass = options[:class]
      end

      concat "<aside class=\"#{asideClass}\">#{@markdown.render(content)}</aside>"
    end
    
  end
end
