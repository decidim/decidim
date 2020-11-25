# frozen_string_literal: true

module Decidim
  module Demographics
    # This class holds a Form to create/update meetings for Participants and UserGroups.
    class DemographicsForm < Decidim::Form
      mimic :demographic

      attribute :gender, String
      attribute :age, String
      attribute :nationalities, String
      attribute :other_nationalities, String
      attribute :residences, String
      attribute :other_residences, String
      attribute :living_condition, String
      attribute :current_occupations, String
      attribute :education_age_stop, String
      attribute :other_ocupations, String
      attribute :attended_before, String
      attribute :newsletter_sign_in, String

      validates_presence_of :gender, :age, :nationalities

      def self.from_params(params, additional_params = {})
        %w(nationalities residences occupations).each do |o|
          params["demographic"][o] = params["demographic"][o]&.reject(&:empty?)&.compact
        end
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
