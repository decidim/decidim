# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A form to temporaly upload csv census data
        class DatasetForm < Form
          include Decidim::HasUploadValidations
          mimic :dataset

          attribute :file

          validates :file, presence: true
          validates :file, passthru: { to: Decidim::Votings::Census::Dataset }

          alias organization current_organization
        end
      end
    end
  end
end
