# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a form to report a missing trustee during the tally process.
      class ReportMissingTrusteeForm < ActionForm
        attribute :trustee_id, Integer

        validates :trustee_id, presence: true

        def trustee
          @trustee ||= Decidim::Elections::Trustee.find(trustee_id)
        end

        def main_button?
          false
        end
      end
    end
  end
end
