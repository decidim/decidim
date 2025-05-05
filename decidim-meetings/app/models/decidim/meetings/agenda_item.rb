# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a AgendaItem in the Decidim::Meetings component. It stores a
    # title, description and duration to render inside meeting.
    class AgendaItem < Meetings::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource

      translatable_fields :title, :description

      belongs_to :agenda, foreign_key: "decidim_agenda_id", class_name: "Decidim::Meetings::Agenda"

      has_many :agenda_item_children, foreign_key: "parent_id", class_name: "Decidim::Meetings::AgendaItem", inverse_of: :parent, dependent: :destroy
      belongs_to :parent, class_name: "Decidim::Meetings::AgendaItem", inverse_of: :agenda_item_children, optional: true

      default_scope { order(:position) }

      def self.first_class
        where(parent_id: nil)
      end

      def parent?
        return true unless parent_id
      end

      def self.agenda_item_children
        where.not(parent_id: nil)
      end

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::AgendaItemPresenter
      end

      # Returns the presenter for this model
      def presenter
        Decidim::Meetings::AgendaItemPresenter.new(self)
      end
    end
  end
end
