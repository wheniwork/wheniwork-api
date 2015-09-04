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
    expand_link = expand_link(selector)
    collapse_link = collapse_link(selector)
    output.gsub!('</pre>', "#{expand_link}#{collapse_link}</pre>")

    return output
  end

  private

  def verify_startend(code)
    needs_end = false

    output = ["For code:\n#{code}"]

    for token in code.split
      if token.include?("SECTION_START")
        output.push("Found SECTION_START")
        if needs_end
          raise "Unexpected SECTION_START in JSON block"
        end
        
        needs_end = true
        output.push("needs_end is now true")
      end

      if token.include?("SECTION_END")
        output.push("Found SECTION_END")
        if !needs_end
          raise "Unexpected SECTION_END in JSON block"
        end

        needs_end = false
        output.push("needs_end is now false")
      end
    end

    if needs_end
      raise "Missing SECTION_END in JSON block"
    end
  end

  def toggle_link(klass, selector, message)
    "<a class=\"#{klass}\" onclick=\"toggleSection('#{selector}')\">#{message}</a>"
  end

  def expand_link(selector, message = "Show more fields")
    toggle_link('expand-link', selector, message)
  end

  def collapse_link(selector, message = "Hide extra fields")
    toggle_link('collapse-link', selector, message)
  end
end
