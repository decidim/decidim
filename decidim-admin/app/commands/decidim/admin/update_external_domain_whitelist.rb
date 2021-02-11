# frozen_string_literal: true

module Decidim
  module Admin
    class UpdateExternalDomainWhitelist < Rectify::Command
      attr_reader :form

      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        save_domains!

        broadcast(:ok)
      end

      private

      def save_domains!
        current_organization.external_domain_whitelist = form.external_domains.filter_map do |domain|
          domain.url unless domain.deleted
        end.flatten

        current_organization.save!
      end
    end
  end
end
