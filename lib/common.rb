require 'json'

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

    def json(options={})
      indent = options[:indent] || 2

      content = capture do yield end
      output = ""

      formattedJSON = JSON.pretty_generate(JSON.parse(content), indent: ' ' * indent)

      output << "```json\n"
      output << formattedJSON
      output << "\n```"

      concat output
    end

    def param(name, type=nil, options={})
      content = capture do yield end

      output = "#{name} | "
      if (type)
        output << "<strong>#{type}</strong><br />"
      end
      output << content

      concat output
    end
    
  end
end
