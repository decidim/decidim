# frozen_string_literal: true

module Decidim
  module Demographics
    # This class holds a Form to create/update meetings for Participants and UserGroups.
    class DemographicsForm < Decidim::Form
      mimic :demographic
      attribute :gender, String
      attribute :age, String
      attribute :nationalities, String
      attribute :postal_code, String
      attribute :background, String

      validates_presence_of :gender, :age, :nationalities
      validates :postal_code, format: { with: /\A[0-9]*\z/ }

      def map_model(model)
        Hash[(model.data || [])].map do |k, v|
          self[k.to_sym] = Decidim::AttributeEncryptor.decrypt(v)
        end
      end
    end
  end
end
