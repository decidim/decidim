# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Census
      module Admin
        describe ExportAccessCodesJob do
          let(:dataset) { create :dataset, :codes_generated, :with_access_code_data }
          let!(:user) { create(:user, :admin, organization: dataset.voting.organization) }

          it "sends an email with the result of the export" do
            perform_enqueued_jobs do
              ExportAccessCodesJob.perform_now(dataset, user)
            end

            email = last_email
            expect(email.subject).to include("The export of the voting access codes")
            expect(email.body.encoded).to match("Click the next link to download the access codes data")
          end
        end
      end
    end
  end
end
