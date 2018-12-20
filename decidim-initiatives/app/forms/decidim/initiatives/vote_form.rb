# frozen_string_literal: true

module Decidim
  module Initiatives
    # A form object used to collect the data for a new initiative.
    class VoteForm < Form
      include TranslatableAttributes

      mimic :initiatives_vote

      attribute :name_and_surname, String
      attribute :document_number, String
      attribute :date_of_birth, Decidim::Attributes::LocalizedDate
      attribute :postal_code, String
      attribute :encrypted_metadata, String

      attribute :initiative_id, Integer
      attribute :author_id, Integer
      attribute :group_id, Integer
      attribute :type_id, Integer

      validates :name_and_surname, :document_number, :date_of_birth, :postal_code, presence: true, if: :required_personal_data?
      validates :encrypted_metadata, presence: true, if: :required_personal_data?
      validates :initiative_id, presence: true
      validates :author_id, presence: true

      def initiative
        @initiative ||= Decidim::Initiative.find_by(id: initiative_id)
      end

      def metadata
        { name_and_surname: name_and_surname,
          document_number: document_number,
          date_of_birth: date_of_birth,
          postal_code: postal_code }
      end

      def encrypted_metadata
        @encrypted_metadata ||= encrypt_metadata
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
    end
  end
end
