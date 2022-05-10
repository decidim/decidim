# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "decidim/accountability/test/factories"
require "decidim/participatory_processes/test/factories"

module Decidim
  module Accountability
    describe ImportMailer, type: :mailer do
      let(:organization) { create :organization, available_locales: [:en] }
      let(:current_user) { create :user, organization: organization }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:current_component) { create :accountability_component, participatory_space: participatory_process, id: 16 }
      let!(:category) { create :category, id: 16, participatory_space: current_component.participatory_space }
      let!(:status6) { create :status, id: 6, component: current_component }
      let!(:status7) { create :status, id: 7, component: current_component }
      let!(:status8) { create :status, id: 8, component: current_component }
      let(:valid_csv) { File.read("spec/fixtures/valid_result.csv") }
      let(:invalid_csv) { File.read("spec/fixtures/invalid_result.csv") }

      context "with a valid CSV" do
        describe "import" do
          let(:importer) { Decidim::Accountability::ResultsCsvImporter.new(current_component, valid_csv, current_user) }
          let(:import_data) { importer.import! }
          let(:mail) { described_class.import(current_user, import_data) }

          it "email body informs no errors on process" do
            expect(mail.body).to include(I18n.t("decidim.accountability.import_mailer.import.success"))
          end
        end
      end

      context "with an invalid CSV" do
        describe "import" do
          let(:importer) { Decidim::Accountability::ResultsCsvImporter.new(current_component, invalid_csv, current_user) }
          let(:import_data) { importer.import! }
          let(:mail) { described_class.import(current_user, import_data) }

          it "email body informs of csv errors" do
            expect(mail.body).to include(I18n.t("decidim.accountability.import_mailer.import.errors_present"))
          end
        end
      end
    end
  end
end
