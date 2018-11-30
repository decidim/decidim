# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to amendable resources.
  module Amendable
    extend ActiveSupport::Concern

    included do
      has_many :amendments, as: :amendable, foreign_key: "decidim_amendable_id", foreign_type: "decidim_amendable_type", class_name: "Decidim::Amendment"

      # resource.emendations : resources that have amend the resource
      has_many :emendations, through: :amendments, source: :emendation, source_type: name, inverse_of: :emendations

      # resource.amenders :  users that have emendations for the resource
      has_many :amenders, through: :amendments, source: :amender

      # resource.amended : the original resource that was amended
      has_one :amended, as: :amendable, foreign_key: "decidim_emendation_id", foreign_type: "decidim_emendation_type", class_name: "Decidim::Amendment"
      has_one :amendable, through: :amended, source: :amendable, source_type: name
    end

    class_methods do
      attr_reader :amendable_options
      # Public: Configures amendable for this model.
      #
      # fields  - An `Array` of `symbols` specifying the fields that can be
      #           amended.
      # ignore  - An `Array` of `symbols` specifying the fields to be
      #           ignored from amendable when creating the related emendation,
      #           the :id is allways ignored.
      # reset   - The counters that should be reseted on the creation of the emmendation
      # form    - The form used for the validation and creation of the emmendation
      #
      # Returns nothing.
      def amendable(fields: nil, ignore: [], reset: nil, form: nil)
        @amendable_options = {}
        raise "You must provide a set of fields to amend" unless fields
        raise "You must provide a form class of the amendable" unless form
        @amendable_options[:fields] = fields
        @amendable_options[:ignore_fields] = ignore + [:id, :created_at, :updated_at]
        @amendable_options[:reset] = reset
        @amendable_options[:form] = form
      end
    end

    def fields
      self.class.amendable_options[:fields]
    end

    def ignore_fields
      self.class.amendable_options[:ignore_fields]
    end

    def form
      self.class.amendable_options[:form].constantize
    end

    def amendment
      return Decidim::Amendment.find_by(emendation: id) if emendation?
      Decidim::Amendment.find_by(amendable: id)
    end

    def emendation?
      true if amendable.present?
    end

    def amendable?
      return false if emendation?
      component.settings.amendments_enabled
    end

    def resource_state
      attributes["state"]
    end

    def emendation_state
      return resource_state if resource_state == "withdrawn"
      amendment.state if emendation?
    end

    def state
      return emendation_state if emendation?
      resource_state
    end
  end
end
