# frozen_string_literal: true

module Decidim
  module Conferences
    # It represents a partner of the conference
    class Partner < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::HasUploadValidations

      TYPES = %w(main_promotor collaborator).freeze

      belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference"

      default_scope { order(partner_type: :desc, weight: :asc) }

      validates_avatar :logo
      mount_uploader :logo, Decidim::Conferences::PartnerLogoUploader

      delegate :organization, to: :conference

      alias participatory_space conference

      def self.log_presenter_class_for(_log)
        Decidim::Conferences::AdminLog::PartnerPresenter
      end
    end
  end
end
