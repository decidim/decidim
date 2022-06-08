# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches mentions of Resources in content.
    #
    # @see BaseParser Examples of how to use a content parser
    class ResourceParser < BaseParser
      # Matches a URL
      URL_REGEX_SCHEME = '(?:http(s)?:\/\/)'
      URL_REGEX_CONTENT = '[\w.-]+[\w\-\._~:\/?#\[\]@!\$&\'\(\)\*\+,;=.]+'
      URL_REGEX_END_CHAR = '[\d]'
      # Matches a mentioned resource ID (~(d)+ expression)
      ID_REGEX = /~(\d+)/

      # Replaces found mentions matching an existing
      # Resource with a global id for that Resource. Other mentions found that doesn't
      # match an existing Resource are returned as they are.
      #
      # @return [String] the content with the valid mentions replaced by a global id.
      def rewrite
        rewrited_content = parse_for_urls(content)
        parse_for_ids(rewrited_content)
      end

      private

      def parse_for_urls(content)
        content.gsub(url_regex) do |match|
          resource = resource_from_url_match(match)
          if resource
            update_metadata(resource)
            resource.to_global_id
          else
            match
          end
        end
      end

      def parse_for_ids(content)
        content.gsub(ID_REGEX) do |match|
          resource = resource_from_id_match(Regexp.last_match(1))
          if resource
            update_metadata(resource)
            resource.to_global_id
          else
            match
          end
        end
      end

      def resource_from_url_match(match)
        uri = URI.parse(match)
        return if uri.path.blank?
        return unless find_organization(uri.host)

        resource_id = uri.path.split("/").last
        find_resource_by_id(resource_id)
      rescue URI::InvalidURIError
        Rails.logger.error("#{e.message}=>#{e.backtrace}")
        nil
      end

      def resource_from_id_match(match)
        resource_id = match
        find_resource_by_id(resource_id)
      end

      def find_resource_by_id(id)
        if id.present?
          spaces = Decidim.participatory_space_manifests.flat_map do |manifest|
            manifest.participatory_spaces.call(context[:current_organization]).public_spaces
          end
          components = Component.where(participatory_space: spaces).published
          model_class.constantize.where(component: components).find_by(id: id)
        end
      end

      def find_organization(uri_host)
        current_organization = context[:current_organization]
        (current_organization.host == uri_host) || current_organization.secondary_hosts.include?(uri_host)
      end

      def url_regex
        raise "Not implemented"
      end

      def model_class
        raise "Not implemented"
      end

      def update_metadata(resource)
        # code to update metadata - needs to be overwritten
      end
    end
  end
end
