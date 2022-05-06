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

          validates_upload :blob
          validates :file, presence: true

          def organization
            context.current_participatory_space&.organization
          end

          def blob
            @blob ||= file.blank? ? nil : ActiveStorage::Blob.find_signed(file)
          end
        end
      end
    end
  end
end
