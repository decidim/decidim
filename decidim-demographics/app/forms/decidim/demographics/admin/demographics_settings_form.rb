# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      class DemographicsSettingsForm < Decidim::Form
        attribute :collect_data, Boolean
      end
    end
  end
end
