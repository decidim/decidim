# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Describes one second-factor method.
    class MethodManifest
      include ActiveModel::Model
      include Decidim::AttributeObject::Model

      attribute :name, String
      attribute :authenticator_class_name, String
      attribute :form_class_name, String, default: "Decidim::TwoFactor::OtpCodeForm"
      attribute :setup_partial, String
      attribute :challenge_partial, String
      attribute :engine, Rails::Engine, **{}
      attribute :admin_engine, Rails::Engine, **{}
      attribute :icon, String

      validates :name, :authenticator_class_name, presence: true

      def authenticator_class = authenticator_class_name.constantize

      def form_class = form_class_name.constantize

      # Partials are looked up by the method name unless the manifest says otherwise.
      def setup_partial = super || "decidim/two_factor/setup/#{name}"

      def challenge_partial = super || "decidim/two_factor/challenge/#{name}"
    end
  end
end
