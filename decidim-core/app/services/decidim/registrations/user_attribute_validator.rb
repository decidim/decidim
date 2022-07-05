# frozen_string_literal: true

module Decidim
  module Registrations
    class UserAttributeValidator
      def initialize(attribute:, form:)
        @attribute = attribute
        @form = form
      end

      delegate :current_organization, to: :form
      attr_reader :attribute, :form

      def valid?
        @valid ||= begin
          form.validate
          # we don't validate the form but the attribute alone
          errors.blank?
        end
      end

      def input
        @input ||= form.public_send(attribute).to_s.dup if valid_attribute?
      end

      def errors
        @errors ||= valid_attribute? ? form.errors[attribute] : ["Invalid attribute"]
      end

      def error
        errors.flatten.join(". ") unless valid?
      end

      private

      def valid_attribute?
        %w(nickname email name password).include? attribute.to_s
      end

      def valid_suggestor?
        ["nickname"].include? attribute.to_s
      end

      def valid_users
        Decidim::UserBaseEntity.where(invitation_token: nil, organization: current_organization)
      end
    end
  end
end
