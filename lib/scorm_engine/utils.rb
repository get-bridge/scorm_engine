require "cgi"

module ScormEngine
  module Utils
    #
    #
    #
    def self.sanitized_text(text)
      text = text.to_s.encode("utf-8", invalid: :replace, undef: :replace)
      CGI.unescape_html(text).
        gsub(/<.*?>/, "").
        strip.
        gsub(/\s+/, " ")
    end
  end
end
