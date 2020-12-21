# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateImport do
    describe "call" do
      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization: organization) }
      let(:component) { create(:component, participatory_space: participatory_space, manifest_name: "proposals") }
      let!(:category) { create(:category, participatory_space: participatory_space) }
      let(:file) do
        Rack::Test::UploadedFile.new(
          Decidim::Dev.test_file("import_proposals.csv", "text/csv"),
          "text/csv"
        )
      end

      let(:form) do
        Decidim::Admin::ImportForm.from_params(
          component: component,
          file: file,
          parser: Decidim::Proposals::ProposalParser
        ).with_context(
          current_organization: organization,
          component: component,
          current_user: user
        )
      end

      let(:command) { described_class.new(form) }

      describe "when the form is not valid" do
        let(:file) { nil }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end
      end
    end
  end
end
