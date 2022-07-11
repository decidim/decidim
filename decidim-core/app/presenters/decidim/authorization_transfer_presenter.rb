# frozen_string_literal: true

module Decidim
  #
  # Decorator for authorization transfer.
  #
  class AuthorizationTransferPresenter < SimpleDelegator
    # Simplifies the informational hash returned by the `#information` for the
    # display in the user interface. Returns a hash containing the record types
    # (their class names as strings) as its keys and the translated amount of
    # the records as its values.
    #
    # The record names are always in plural format for maximum language
    # compatibility, as otherwise we would have to specify the translatable
    # strings for all records in singular and plural formats.
    #
    # @example Format of the returned hash
    #   {
    #      "Decidim::Foo" => "Foos: 123",
    #      "Decidim::Bar" => "Bars: 456"
    #   }
    #
    # @return [Hash<String, String>] The translated resource counts with the
    #   resource type as its keys and the translated text with the record count
    #   as its values.
    def translated_record_counts
      resources = information.map do |type, info|
        resource_class = info[:class]
        name = resource_class.model_name

        [type, "#{name.human(count: 2)}: #{info[:count]}"]
      end

      resources.sort_by { |v| v[1] }.to_h
    end

    # Returns an array of the translated record counts containing only the
    # texts to be displayed for the user.
    #
    # @return [Array<String>] The translated records names with their coutns.
    def translated_record_texts
      translated_record_counts.values
    end

    # Generates a HTML list of the record counts with the translated.
    #
    # @return [String] An HTML formatted list of the record names with their
    #   counts.
    def records_list_html
      items = translated_record_texts.map do |description|
        "<li>#{CGI.escapeHTML(description)}</li>"
      end

      "<ul>#{items.join}</ul>".html_safe
    end
  end
end
