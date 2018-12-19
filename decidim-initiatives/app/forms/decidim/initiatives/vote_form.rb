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

      attribute :initiative_id, Integer
      attribute :author_id, Integer
      attribute :group_id, Integer
      attribute :type_id, Integer

      validates :name_and_surname, :document_number, :date_of_birth, :postal_code, presence: true, if: :required_personal_data?
      validates :initiative_id, presence: true
      validates :author_id, presence: true

      def initiative
        @initiative ||= Decidim::Initiative.find_by(id: initiative_id)
      end

      protected

      def required_personal_data?
        initiative_type&.collect_user_extra_fields?
      end

      def initiative_type
        @initiative_type ||= initiative&.scoped_type&.type
      end
    end
  end
end
