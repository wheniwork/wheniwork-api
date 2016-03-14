# 
# Custom renderer that lets us manipulate how code is outputted
# (and anything else we decide to implement!)
# 
# If any rendering problems come up, esp. related to images or
# links, check out the class linked below and try to duplicate
# what it does. Middleman uses a custom RedCarpet renderer by
# default, which apparently fixes a couple small issues.
# 
# https://github.com/middleman/middleman/blob/v3-stable/middleman-core/lib/middleman-core/renderers/redcarpet.rb#L51-L82
# 
class APIHtmlRenderer < ::Redcarpet::Render::HTML
  def initialize(options={})
    @local_options = options.dup
    @code_section_counter = 0
    @table_section_counter = 0
    @table_section_active = false
    @table_section_needs_spacer = false

    super
  end

  def block_code(code, language)
    return Middleman::Syntax::Highlighter.highlight(code, language) unless language == 'json' && (code.include?("SECTION_START") || code.include?("SECTION_END"))

    verify_startend(code)

    # -------------------------------------------------------
    # This lets us show/hide lines in code examples on the
    # right of the API docs. Currently it is only enabled for
    # JSON, but this could easily be changed in the future.
    # -------------------------------------------------------

    # Give each block of code a unique ID
    @code_section_counter += 1

    # Make sure "SECTION_START" or "SECTION_END" is the
    # only thing on that line to ensure that it colors
    # and replaces as expected
    code.gsub!(/^.*SECTION_START.*$/, "SECTION_START")
    code.gsub!(/^.*SECTION_END.*$/, "SECTION_END")

    # Attempt to remove invalid final commas, if present
    while commaIndex = code.index(/,\s*(SECTION_START|SECTION_END)?\s*(\}|\])/)
      code.slice!(commaIndex)
    end

    # Color the code and replace start/end tags with
    # actual HTML tags
    output = Middleman::Syntax::Highlighter.highlight(code, language)
    output.gsub!("<span class=\"err\">SECTION_START</span><span class=\"w\">\n", '<span class="hide-section"><span class="w">')
    output.gsub!("<span class=\"err\">SECTION_END</span><span class=\"w\">\n", '</span>')

    output.strip!

    # Give the code block its unique ID
    output.gsub!('<pre', "<pre id=\"code-collapse-#{@code_section_counter}\"")

    # Make and add show/hide links
    selector = "\#code-collapse-#{@code_section_counter}"
    expand_link = expand_code_link(selector)
    collapse_link = collapse_code_link(selector)
    output.gsub!('</pre>', "#{expand_link}#{collapse_link}</pre>")

    return output
  end

  def table(header, body)
    @table_section_counter += 1

    output = "";
    can_collapse = body.include?("<tr class=\"collapse\">")

    if can_collapse
      output << "<table id=\"table-collapse-#{@table_section_counter}\">"
    else
      output << "<table>"
    end

    if !header.strip.empty?
      output << "<thead>#{header}</thead>"
    end
    if !body.strip.empty?
      output << "<tbody>#{body}</tbody>"
    end

    output << "</table>"

    if can_collapse
      output << "<p class=\"collapse-links\">"
      output << expand_table_link("\#table-collapse-#{@table_section_counter}")
      output << collapse_table_link("\#table-collapse-#{@table_section_counter}")
      output << "</p>"
    end

    return output
  end
  
  def table_row(content)
    if content.include?("SECTION_START")
      if @table_section_active
        raise "Unexpected SECTION_START in table"
      end

      @table_section_active = true
      @table_section_needs_spacer = false
      return ""
    end
    if content.include?("SECTION_END")
      if !@table_section_active
        raise "Unexpected SECTION_END in table"
      end

      @table_section_active = false
      if @table_section_needs_spacer
        return "<tr class=\"spacer\"></tr>"
      else
        return ""
      end
    end

    if @table_section_active
      @table_section_needs_spacer = !@table_section_needs_spacer
      return "<tr class=\"collapse\">#{content}</tr>"
    else
      return "<tr>#{content}</tr>"
    end
  end

  private

  def verify_startend(code)
    needs_end = false

    for token in code.split
      if token.include?("SECTION_START")
        if needs_end
          raise "Unexpected SECTION_START in JSON block"
        end
        
        needs_end = true
      end

      if token.include?("SECTION_END")
        if !needs_end
          raise "Unexpected SECTION_END in JSON block"
        end

        needs_end = false
      end
    end

    if needs_end
      raise "Missing SECTION_END in JSON block"
    end
  end

  def toggle_code_link(klass, selector, message)
    "<a class=\"#{klass}\" onclick=\"toggleCodeSection('#{selector}')\">#{message}</a>"
  end

  def expand_code_link(selector, message = "Show hidden fields")
    toggle_code_link('expand-link', selector, message)
  end

  def collapse_code_link(selector, message = "Hide extra fields")
    toggle_code_link('collapse-link', selector, message)
  end

  def toggle_table_link(klass, selector, message)
    "<a href=\"#{selector}\" class=\"#{klass}\" onclick=\"toggleTable('#{selector}')\">#{message}</a>"
  end

  def expand_table_link(selector, message = "Show more parameters")
    toggle_table_link('expand-link', selector, message)
  end

  def collapse_table_link(selector, message = "Hide extra parameters")
    toggle_table_link('collapse-link', selector, message)
  end
end
