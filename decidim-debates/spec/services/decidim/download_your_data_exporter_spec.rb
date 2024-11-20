# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DownloadYourDataExporter do
    subject { DownloadYourDataExporter.new(user, "download-your-data", "CSV") }

    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }

    describe "#readme" do
      context "when the user has activity" do
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:debates_component) { create(:debates_component, participatory_space:) }

        let!(:debate) { create(:debate, component: debates_component, author: user) }

        it "does not have any missing translation" do
          subject.send(:data_and_attachments_for_user) # to create the data and get the help definitions
          data = subject.send(:readme)

          expect(data).not_to include("Translation missing")
        end
      end
    end
  end
end
