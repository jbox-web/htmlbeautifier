# frozen_string_literal: true

require "htmlbeautifier/parser"

module HtmlBeautifier
  class HtmlParser < Parser
    ELEMENT_CONTENT = %r{ (?:<%.*?%>|[^>])* }mx

    HTML_VOID_ELEMENTS = %r{(?:
      area | base | br | col | command | embed | hr | img | input | keygen |
      link | meta | param | source | track | wbr
    )}mix

    HTML_BLOCK_ELEMENTS = %r{(?:
      address | article | aside | audio | blockquote | canvas | dd | details |
      dir | div | dl | dt | fieldset | figcaption | figure | footer | form |
      h1 | h2 | h3 | h4 | h5 | h6 | header | hr | li | menu | noframes |
      noscript | ol | p | pre | section | table | tbody | td | tfoot | th |
      thead | tr | ul | video
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
      [%r{<#{HTML_VOID_ELEMENTS}(?: #{ELEMENT_CONTENT})?/?>}m, :standalone_element],
      [%r{</#{HTML_BLOCK_ELEMENTS}>}m,                         :close_block_element],
      [%r{<#{HTML_BLOCK_ELEMENTS}(?: #{ELEMENT_CONTENT})?>}m,  :open_block_element],
      [%r{</#{ELEMENT_CONTENT}>}m,                             :close_element],
      [%r{<#{ELEMENT_CONTENT}[^/]>}m,                          :open_element],
      [%r{<[\w-]+(?: #{ELEMENT_CONTENT})?/>}m,                 :standalone_element],
      [%r{(\s*\r?\n\s*)+}m,                                    :new_lines],
      [%r{[^<\n]+},                                            :text],
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
