# frozen_string_literal: true

module Decidim
  module Demographics
    # This class holds a Form to create/update meetings for Participants and UserGroups.
    class DemographicsForm < Decidim::Form
      mimic :demographic

      attribute :gender, String
      attribute :age, String
      attribute :nationalities, String
      attribute :other_nationalities, Text
      attribute :residences String
      attribute :other_residences, Text
      attribute :living_conditions, String
      attribute :current_occupation, String
      attribute :eductation_age_stop, String
      attribute :attended_eu_event, String
      attribute :newsletter_subscribe, Boolean

      validates_presence_of :gender, :age, :nationalities
      validates :postal_code, format: { with: /\A[0-9]*\z/ }

      def self.from_params(params, additional_params = {})
        params["demographic"]["nationalities"] = params["demographic"]["nationalities"]&.reject(&:empty?)&.compact
        params["demographic"]["residences"] = params["demographic"]["residences"]&.reject(&:empty?)&.compact
        super
      end

      def map_model(model)
        Hash[(model.data || [])].map do |k, v|
          self[k.to_sym] = v
        end
      end
    end
  end
end
