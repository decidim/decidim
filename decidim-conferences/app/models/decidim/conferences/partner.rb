# frozen_string_literal: true

module Decidim
  module Conferences
    # It represents a partner of the conference
    class Partner < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      TYPES = %w(main_promotor collaborator).freeze

      belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference"
      validates :logo, file_size: { less_than_or_equal_to: ->(partner) { partner.maximum_avatar_size } }

      default_scope { order(partner_type: :desc, weight: :asc) }
      mount_uploader :logo, Decidim::Conferences::PartnerLogoUploader

      delegate :organization, to: :conference

      alias participatory_space conference

      def self.log_presenter_class_for(_log)
        Decidim::Conferences::AdminLog::PartnerPresenter
      end

      def maximum_avatar_size
        Decidim.organization_settings(organization).upload_maximum_file_size_avatar
      end
    end
  end
end
