# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # Original: https://github.com/neighborland/anchored/
    # A renderer that converts URLs to links and strips attributes in anchors.
    #
    # Examples:
    # `<a href="http://urls.net" onmouseover="alert('hello')">URLs</a>`
    # Gets rendered as:
    # `<a href="https://decidim.org" target="_blank" rel="noopener">https://decidim.org</a>`
    # And:
    # `<a href="javascript:document.cookies">click me</a>`
    # Gets rendered as:
    # `click me`
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class LinkRenderer < BaseRenderer
      # @return [String] the content ready to display (contains HTML)
      def render(options = {})
        return content unless content.is_a?(String)

        options = { target: "_blank", rel: "nofollow noopener noreferrer ugc" }.merge(options)
        auto_link(content, options)
      end

      def auto_link(text, options = {}, &block)
        return "" if text.to_s.empty?

        auto_link_urls(text, options, &block)
      end

      # remove_target_if_local("http://same.com/x", "same.com", target: "_blank")
      # => <a href="http://same.com/x">http://same.com/x</a>
      #
      # remove_target_if_local("http://same.com/x", "different.com", target: "_blank")
      # => <a href="http://same.com/x" target="_blank">http://same.com/x</a>
      #
      # modifies options in place
      def remove_target_if_local(href, domain, options)
        return unless options[:target]

        options.delete(:target) if href.include?("//#{domain}")
      end

      private

      AUTO_LINK_RE = %r{(?: ((?:ftp|http|https):)// | www\. )[^\s<\u00A0"]+}ix

      # # regexps for determining context, used high-volume
      AUTO_LINK_CRE = [/<[^>]+$/, /^[^>]*>/, /<a\b.*?>/i, %r{</a>}i].freeze

      PUNCTUATION_RE = %r{[^\p{Word}/=&]$}

      BRACKETS = { "]" => "[", ")" => "(", "}" => "{" }.freeze

      # Turns all urls into clickable links.  If a block is given, each url
      # is yielded and the result is used as the link text.
      def auto_link_urls(text, options = {})
        # to_str is for SafeBuffer objects (text marked html_safe)
        text.to_str.gsub(AUTO_LINK_RE) do
          match = Regexp.last_match
          href = match[0]
          scheme = match[1]
          punctuation = []

          if auto_linked?(match)
            # do not change string; URL is already linked
            href
          else
            # don't include trailing punctuation character as part of the URL
            while href.sub!(PUNCTUATION_RE, "")
              punctuation.push Regexp.last_match(0)
              if (opening = BRACKETS[punctuation.last]) && href.scan(opening).size > href.scan(punctuation.last).size
                href << punctuation.pop
                break
              end
            end

            link_text = block_given? ? yield(href) : href
            href = "http://#{href}" unless scheme

            # content_tag(:a, link_text, html.merge(href: href)) + punctuation.reverse.join('')
            anchor_tag(href, link_text, options) + punctuation.reverse.join
          end
        end
      end

      # Detects already linked context or position in the middle of a tag
      # Note: this changes the current Regexp
      def auto_linked?(match)
        left = match.pre_match
        right = match.post_match
        (left =~ AUTO_LINK_CRE[0] && right =~ AUTO_LINK_CRE[1]) ||
          (left.rindex(AUTO_LINK_CRE[2]) && Regexp.last_match.post_match !~ AUTO_LINK_CRE[3])
      end

      def anchor_attrs(options)
        options.map { |k, v| %(#{k}="#{v}") }.unshift("").join(" ")
      end

      def anchor_tag(href, text, options)
        options = options.dup
        if (domain = options.delete(:domain))
          remove_target_if_local href, domain, options
        end
        %(<a href="#{href}"#{anchor_attrs(options)}>#{text}</a>)
      end
    end
  end
end
