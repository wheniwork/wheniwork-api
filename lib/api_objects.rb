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
        html << make_param(key, obj['description'], obj['type'], newline: true)
      end
      return html
    end

    def print_json_as_php_array(object, options={})
      formatted = {}
      inc = (options[:include] || {}).inject({}) do |hash, (key, value)|
        hash[key] = {'value' => value, 'show' => true}
        hash
      end
      object.merge(inc).each do |key, obj|
        if options[:verbose] || obj['show']
          formatted.merge!(key => obj['value'])
        end
      end

      json_text = JSON.pretty_generate(formatted)
      return json_text.gsub(/\{(.*)\}/m, 'array(\1)').gsub(/\:/, ' =>')
    end
    
    # Prints a JSON object formatted like those in objects.json. The valid
    # options are:
    #
    # :include::  Any fields you wish to include in the result which are not in
    #             the original object. Each will have 'show' set to true.
    # :exclude::  The names of any fields you wish to exclude from the result.
    #             This sets 'show' to false for each field.
    # :collapse:: Collapses any fields in the result for which 'show' is false.
    #             If true, any fields for which 'show' is false will be
    #             collapsed instead of removed entirely from the output.
    #             Defaults to true.
    # :verbose::  Will show all keys in the result, uncollapsed. Overrules the
    #             :collapse and :exclude options.
    def print_json(object, options={})
      unless options.has_key?(:collapse)
        options[:collapse] = true
      end

      included_fields = (options[:include] || {}).inject({}) do |hash, (key, value)|
        hash[key] = {'value' => value, 'show' => true}
        hash
      end

      formatted = {}
      collapse_active = false
      object.merge(included_fields).each do |key, field|
        if options[:collapse] && !options[:verbose]
          should_hide_field = !field['show'] || (!options[:exclude].nil? && options[:exclude].include?(key))
          if should_hide_field && !collapse_active
            collapse_active = true
            formatted.merge!("SECTION_START_before_#{key}" => true)
          elsif !should_hide_field && collapse_active
            collapse_active = false
            formatted.merge!("SECTION_END_before_#{key}" => true)
          end
        end

        if options[:verbose] || options[:collapse] || !should_hide_field
          if field['value'].is_a? Hash
            field_json = print_json(field['value'], {
              :collapse => options[:collapse],
              :verbose => options[:verbose],
            })
            formatted.merge!(key => JSON.parse(field_json))
          else
            formatted.merge!(key => field['value'])
          end
        end
      end

      if options[:collapse] && collapse_active
        formatted.merge!('SECTION_END_at_end' => true)
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
