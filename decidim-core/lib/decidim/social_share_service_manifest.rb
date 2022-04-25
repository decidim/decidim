# frozen_string_literal: true

module Decidim
  # This class represents an abstract social network.
  class SocialShareServiceManifest
    include Decidim::AttributeObject::Model
    include ActiveModel::Validations

    attribute :name, String
    attribute :icon, String
    attribute :share_uri, String

    validates :name, presence: true
    validates :icon, presence: true
    validates :share_uri, presence: true, format: { with: /%{url}/ }

    def formatted_share_uri(title, **args)
      format(share_uri, title: url_escape(title), **escape_args(args))
    end

    def icon_path
      ActionController::Base.helpers.asset_pack_path("media/images/#{icon}")
    end

    private

    def escape_args(args)
      args.reject { |_k, v| v.nil? }.transform_values { |v| url_escape(v) }
    end

    def url_escape(string)
      CGI.escape(string)
    end
  end
end
