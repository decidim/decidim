# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A form to temporaly upload csv census data
        class DatasetForm < Form
          mimic :dataset

          attribute :file, Decidim::Attributes::Blob

          validates :file, presence: true, file_content_type: { allow: ["text/csv"] }

          def organization
            context.current_participatory_space&.organization
          end
        end
      end
    end
  end
end
