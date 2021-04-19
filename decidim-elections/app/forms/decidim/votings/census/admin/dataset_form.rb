# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A form to temporaly upload csv census data
        class DatasetForm < Form
          mimic :dataset

          attribute :file

          validates :file, presence: true
        end
      end
    end
  end
end
