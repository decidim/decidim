# frozen_string_literal: true

module Decidim
  # This class represents an abstract social network to be used for sharing URLs
  # Serves as a replacement for our usage of the social-share-button gem
  class SocialShareServiceManifest
    include Decidim::AttributeObject::Model
    include ActiveModel::Validations

    attribute :name, String
    attribute :icon, String
    attribute :share_uri, String
    attribute :optional_params, Array

    validates :name, presence: true
    validates :icon, presence: true
    validates :share_uri, presence: true, format: { with: /%{url}/ }

    # Format a given URL to be shareable
    # All the services gives us a controller that accepts different get parameters. As this
    # parameters are used in an URL we need to escape them
    #
    # @param title [String] the title of the resource that we want to share
    # @param args [Hash] all the parameters that will be added on the url
    # @return [String]
    def formatted_share_uri(title, args)
      formatted_args = escape_args(args)
      format(full_share_uri(formatted_args.keys), title: url_escape(title), **formatted_args)
    end

    # Path of the icon file
    #
    # @return [String]
    def icon_path
      ActionController::Base.helpers.asset_pack_path("media/images/#{icon}")
    end

    private

    # Add optional parameters to a share_uri
    # This is initially developed for Twitter, as they allow sending a Hashtag and Via as parameters
    #
    # @param keys [Array<Symbol>] all the parameters that this service support
    # @return [String] the share uri with the parameters and optional parameters
    def full_share_uri(keys)
      return share_uri if optional_params.empty?

      share_uri + (optional_params.map(&:to_sym) & keys).map { |k| "&#{k}=%{#{k}}" }.join
    end

    # Escape the values of a hash so it has characters compatible with URLs
    #
    # @param args [Hash] the hash with the values to be escaped
    # @return [Hash]
    def escape_args(args)
      args.compact.transform_values { |v| url_escape(v) }
    end

    # Escape a string so it has characters compatible with URLs
    #
    # @param string [String]  the string to be escaped
    # @return [String]
    def url_escape(string)
      CGI.escape(string)
    end
  end
end
