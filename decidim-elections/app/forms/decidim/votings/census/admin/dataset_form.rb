# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A form to temporaly upload csv census data
        class DatasetForm < Form
          include Decidim::HasUploadValidations

          mimic :dataset

          attribute :file, Decidim::Attributes::Blob

          validates :file, presence: true

          def organization
            context.current_participatory_space&.organization
          end
        end
      end
    end
  end
end
