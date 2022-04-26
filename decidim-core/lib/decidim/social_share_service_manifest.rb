# frozen_string_literal: true

module Decidim
  # This class represents an abstract social network.
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

    def formatted_share_uri(title, **args)
      format(full_share_uri(args.keys), title: url_escape(title), **escape_args(args))
    end

    def icon_path
      ActionController::Base.helpers.asset_pack_path("media/images/#{icon}")
    end

    private

    def full_share_uri(keys)
      return share_uri if optional_params.empty?

      share_uri + (optional_params.map(&:to_sym) & keys).map { |k| "&#{k}=%{#{k}}" }.join
    end

    def escape_args(args)
      args.reject { |_k, v| v.nil? }.transform_values { |v| url_escape(v) }
    end

    def url_escape(string)
      CGI.escape(string)
    end
  end
end
