# frozen_string_literal: true

module HtmlBeautifier
  class HtmlParser < Parser
    # Quoted attribute values are matched as a whole so that a > inside them
    # does not terminate the tag: <button data-action="click->hello#greet">.
    # Quotes are excluded from the catch-all so that they can only be consumed
    # in pairs, which stops a tag from swallowing the markup that follows it.
    ELEMENT_CONTENT = %r{ (?:<%.*?%>|"[^"]*"|'[^']*'|[^>"'])* }mx

    HTML_VOID_ELEMENTS = %r{(?:
      area | base | br | col | command | embed | hr | img | input | keygen |
      link | meta | param | source | track | wbr
    )}mix

    HTML_BLOCK_ELEMENTS = %r{(?:
      address | article | aside | audio | blockquote | canvas | dd | details |
      dialog | dir | div | dl | dt | fieldset | figcaption | figure | footer |
      form | h1 | h2 | h3 | h4 | h5 | h6 | header | hgroup | li | hr | main |
      menu | nav | noframes | noscript | ol | p | pre | search | section |
      summary | table | tbody | td | tfoot | th | thead | tr | ul | video
    )}mix

    MAPPINGS = [
      [%r{(<%-?=?)(.*?)(-?%>)}m,                               :embed],
      [%r{<!--\[.*?\]>}m,                                      :open_ie_cc],
      [%r{<!\[.*?\]-->}m,                                      :close_ie_cc],
      [%r{<!--.*?-->}m,                                        :standalone_element],
      [%r{<!.*?>}m,                                            :standalone_element],
      [%r{<o:.*?/>},                                           :standalone_element],
      [%r{<o:.*?>}m,                                           :open_element],
      [%r{</o:.*?>}m,                                          :close_element],
      [%r{(<script#{ELEMENT_CONTENT}>)(.*?)(</script>)}mi,     :foreign_block],
      [%r{(<style#{ELEMENT_CONTENT}>)(.*?)(</style>)}mi,       :foreign_block],
      [%r{(<pre#{ELEMENT_CONTENT}>)(.*?)(</pre>)}mi,           :preformatted_block],
      [%r{(<textarea#{ELEMENT_CONTENT}>)(.*?)(</textarea>)}mi, :preformatted_block],
      [%r{<#{HTML_VOID_ELEMENTS}(?:\s#{ELEMENT_CONTENT})?/?>}m, :standalone_element],
      [%r{</#{HTML_BLOCK_ELEMENTS}>}m,                          :close_block_element],
      [%r{<#{HTML_BLOCK_ELEMENTS}(?:\s#{ELEMENT_CONTENT})?>}m,  :open_block_element],
      [%r{</#{ELEMENT_CONTENT}>}m,                              :close_element],
      # A tag must start with a name character; anything else is text, which
      # keeps "5 < 6" from swallowing the markup that follows it. The closing
      # bracket is checked with a lookbehind rather than by consuming the
      # preceding character, which ELEMENT_CONTENT cannot give back when the
      # tag ends on a quoted value.
      [%r{<[\w!]#{ELEMENT_CONTENT}(?<!/)>}m,                    :open_element],
      [%r{<[\w-]+(?:\s#{ELEMENT_CONTENT})?/>}m,                 :standalone_element],
      [%r{(\s*\r?\n\s*)+}m,                                     :new_lines],
      [%r{[^<\n]+},                                             :text],
      # Fallback: a < that opens no tag is content, not a parse error
      [%r{<},                                                   :text],
    ].freeze

    def initialize
      super do |p|
        MAPPINGS.each do |regexp, method|
          p.map regexp, method
        end
      end
    end
  end
end
