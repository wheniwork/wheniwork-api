require 'json'

class ApiObjects < Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super
    @objects = {}

    # Add helper functions to the App scope
    app.extend ApiAppMethods
  end
  module ApiAppMethods

  end
  helpers do
    def print_table(object, options={})
      html = ""

      if options[:header]
        html << "### #{options[:header].capitalize} Object\n"
      end

      html << "Parameter | Description\n"
      html << "--------- | -----------\n"
      object.each do |key, obj|
        html << "#{key} | <strong>#{obj['type']}</strong><br />#{obj['description']}\n"
      end
      return html
    end
    def print_json_as_php_array(object, options={})
      formatted = {}
      inc = (options[:include]||{}).inject({}) { |h,(k,v)| h[k] = {'show' => true, 'value' => v}; h }
      object.merge(inc).each do |key,obj|
        if !options[:minimal] || obj['show']
          formatted.merge!(key=>obj['value'])
        end
      end

      json_text = JSON.generate(formatted)
      return json_text.gsub(/\{(.*)\}/, 'array(\1)').gsub(/\:/, ' => ')
    end
    def print_json(object, options={})
      formatted = {}
      inc = (options[:include]||{}).inject({}) { |h,(k,v)| h[k] = {'show' => true, 'value' => v}; h }
      object.merge(inc).each do |key,obj|
        if !options[:minimal] || obj['show']
          formatted.merge!(key=>obj['value'])
        end
      end
      json = JSON.pretty_generate(formatted)
      return json
    end
  end
end

class String
  def indent (num = 2)
    s = " " * num
    lineone = lines.first

    i = lines.to_a[1..-1].join.gsub(/^/, s)

    "#{lineone}#{i}"
  end
end
