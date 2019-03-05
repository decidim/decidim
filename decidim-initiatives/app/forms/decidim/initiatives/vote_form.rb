# frozen_string_literal: true

require "virtus/multiparams"

module Decidim
  module Initiatives
    # A form object used to collect the data for a new initiative.
    class VoteForm < Form
      include TranslatableAttributes
      include Virtus::Multiparams

      mimic :initiatives_vote

      attribute :name_and_surname, String
      attribute :document_number, String
      attribute :date_of_birth, Date

      attribute :postal_code, String
      attribute :encrypted_metadata, String
      attribute :hash_id, String

      attribute :initiative_id, Integer
      attribute :author_id, Integer
      attribute :group_id, Integer

      validates :name_and_surname, :document_number, :date_of_birth, :postal_code, presence: true, if: :required_personal_data?
      validates :encrypted_metadata, presence: true, if: :required_personal_data?
      validates :initiative_id, presence: true
      validates :author_id, presence: true

      validate :document_number_authorized, if: :required_personal_data?
      validate :document_number_uniqueness, if: :required_personal_data?
      validate :personal_data_consistent_with_metadata, if: :required_personal_data?

      def initiative
        @initiative ||= Decidim::Initiative.find_by(id: initiative_id)
      end

      delegate :scope, to: :initiative

      def metadata
        { name_and_surname: name_and_surname,
          document_number: document_number,
          date_of_birth: date_of_birth,
          postal_code: postal_code }
      end

      def encrypted_metadata
        @encrypted_metadata ||= encrypt_metadata
      end

      def hash_id
        Digest::MD5.hexdigest(
          "#{initiative_id}-#{document_number || author_id}-#{Rails.application.secrets.secret_key_base}"
        )
      end

      def decrypted_metadata
        return unless encrypted_metadata

        encryptor.decrypt(encrypted_metadata)
      end

      protected

      def required_personal_data?
        initiative_type&.collect_user_extra_fields?
      end

      def initiative_type
        @initiative_type ||= initiative&.scoped_type&.type
      end

      def encryptor
        @encryptor ||= DataEncryptor.new(secret: "personal user metadata")
      end

      def encrypt_metadata
        return unless required_personal_data?

        encryptor.encrypt(metadata)
      end

      def document_number_authorized
        return if initiative.document_number_authorization_handler.blank?

        errors.add(:document_number, :invalid) unless authorized? && authorization_handler && authorization.unique_id == authorization_handler.unique_id
      end

      def document_number_uniqueness
        errors.add(:document_number, :taken) if initiative.votes.where(hash_id: hash_id).exists?
      end

      def personal_data_consistent_with_metadata
        return if initiative.document_number_authorization_handler.blank?

        errors.add(:base, :invalid) unless authorized? &&
                                           authorization_handler &&
                                           authorization_handler_metadata_variations.any? { |variation| authorization.metadata.symbolize_keys == variation.symbolize_keys }
      end

      def author
        @author ||= current_organization.users.find_by(id: author_id)
      end

      def authorization
        return unless author && handler_name

        @authorization ||= Verifications::Authorizations.new(organization: author.organization, user: author, name: handler_name).first
      end

      def authorization_status
        return unless authorization

        Decidim::Verifications::Adapter.from_element(handler_name).authorize(authorization, {}, nil, nil)
      end

      def authorized?
        authorization_status&.first == :ok
      end

      def handler_name
        initiative.document_number_authorization_handler
      end

      def authorization_handler
        return unless document_number && handler_name

        @authorization_handler ||= Decidim::AuthorizationHandler.handler_for(handler_name,
                                                                             document_number: document_number,
                                                                             name_and_surname: name_and_surname,
                                                                             date_of_birth: date_of_birth,
                                                                             postal_code: postal_code,
                                                                             scope_id: scope&.id)
      end

      def authorization_handler_metadata_variations
        return [] unless authorization_handler && scope.present?

        scope.children.map do |child_scope|
          Decidim::AuthorizationHandler.handler_for(handler_name,
                                                    document_number: document_number,
                                                    name_and_surname: name_and_surname,
                                                    date_of_birth: date_of_birth,
                                                    postal_code: postal_code,
                                                    scope_id: child_scope&.id)
        end.unshift(authorization_handler).map(&:metadata)
      end
    end
  end
end
