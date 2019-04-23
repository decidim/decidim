# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to amendable resources.
  module Amendable
    extend ActiveSupport::Concern

    included do
      has_many :amendments,
               as: :amendable,
               foreign_key: "decidim_amendable_id",
               foreign_type: "decidim_amendable_type",
               class_name: "Decidim::Amendment"

      # resource.emendations : resources that have amend the resource
      has_many :emendations,
               through: :amendments,
               source: :emendation,
               source_type: name,
               inverse_of: :emendations

      # resource.amenders :  users that have emendations for the resource
      has_many :amenders,
               through: :amendments,
               source: :amender

      has_one :amended,
              as: :amendable,
              foreign_key: "decidim_emendation_id",
              foreign_type: "decidim_emendation_type",
              class_name: "Decidim::Amendment"

      # resource.amendable : the original resource that was amended
      has_one :amendable, through: :amended, source: :amendable, source_type: name

      scope :only_amendables, -> { where.not(id: joins(:amendable)) }
      scope :only_emendations, -> { where(id: joins(:amendable)) }
    end

    class_methods do
      attr_reader :amendable_options
      # Public: Configures amendable for this model.
      #
      # fields  - An `Array` of `symbols` specifying the fields that can be amended
      # form    - The form used for the validation and creation of the emendation
      #
      # Returns nothing.
      def amendable(fields: nil, form: nil)
        raise "You must provide a set of fields to amend" unless fields
        raise "You must provide a form class of the amendable" unless form

        @amendable_options = { fields: fields, form: form }
      end
    end

    def amendable_fields
      self.class.amendable_options[:fields]
    end

    def amendable_form
      self.class.amendable_options[:form].constantize
    end

    def amendable_type
      resource_manifest.model_class_name
    end

    def amendment
      associated_resource = emendation? ? :emendation : :amendable

      Decidim::Amendment.find_by(associated_resource => id)
    end

    def emendation?
      amendable.present?
    end

    def amendable?
      amendable.blank?
    end

    def resource_state
      attributes["state"]
    end

    def emendation_state
      return resource_state if resource_state == "withdrawn"

      amendment.state
    end

    def state
      return emendation_state if emendation?

      resource_state
    end
  end
end
