# frozen_string_literal: true

module Decidim
  module Meetings
    # This class holds a Form to create/update meetings for Participants and UserGroups.
    class MeetingForm < Decidim::Form
      attribute :title, String
      attribute :description, String
      attribute :location, String
      attribute :location_hints, String

      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :start_time, Decidim::Attributes::TimeWithZone
      attribute :end_time, Decidim::Attributes::TimeWithZone
      attribute :decidim_scope_id, Integer
      attribute :decidim_category_id, Integer
      attribute :private_meeting, Boolean
      attribute :transparent, Boolean
      attribute :user_group_id, Integer

      validates :title, presence: true
      validates :description, presence: true
      validates :location, presence: true
      validates :address, presence: true
      validates :address, geocoding: true, if: -> { Decidim.geocoder.present? }
      validates :start_time, presence: true, date: { before: :end_time }
      validates :end_time, presence: true, date: { after: :start_time }

      validates :current_component, presence: true
      validates :category, presence: true, if: ->(form) { form.decidim_category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }
      validate :scope_belongs_to_participatory_space_scope

      delegate :categories, to: :current_component

      def map_model(model)
        self.decidim_category_id = model.categorization.decidim_category_id if model.categorization
        presenter = MeetingPresenter.new(model)
        self.title = presenter.title(all_locales: false)
        self.description = presenter.description(all_locales: false)
      end

      alias component current_component

      # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
      #
      # Returns a Decidim::Scope
      def scope
        @scope ||= @decidim_scope_id ? current_participatory_space.scopes.find_by(id: @decidim_scope_id) : current_participatory_space.scope
      end

      # Scope identifier
      #
      # Returns the scope identifier related to the meeting
      def decidim_scope_id
        @decidim_scope_id || scope&.id
      end

      def category
        return unless current_component

        @category ||= categories.find_by(id: decidim_category_id)
      end

      private

      def scope_belongs_to_participatory_space_scope
        errors.add(:decidim_scope_id, :invalid) if current_participatory_space.out_of_scope?(scope)
      end
    end
  end
end
