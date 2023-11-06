# frozen_string_literal: true

module Decidim
  class LogReferenceGenerator
    def initialize(request)
      @request = request
    end

    def generate_reference
      tags_array = generate_tags(Rails.configuration.log_tags)
      tags_array.collect { |tag| "[#{tag}] " }.join if tags_array
    end

    private

    attr_reader :request

    def generate_tags(tags)
      tags&.collect do |tag|
        case tag
        when Proc
          tag.call(request)
        when Symbol
          request.send(tag)
        else
          tag
        end
      end
    end
  end
end
