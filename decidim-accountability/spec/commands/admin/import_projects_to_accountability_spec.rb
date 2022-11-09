# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::ImportProjectsToAccountability do
    describe "#call" do
      subject { command.call }
      let(:user) { create :user, organization: }
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:budget_component) { create(:component, manifest_name: "budgets", participatory_space:) }
      let(:current_component) { create(:component, manifest_name: "accountability", participatory_space:, published_at: accountability_component_published_at) }
      let(:accountability_component_published_at) { nil }
      let(:command) { described_class.new(form) }
      let(:form) do
        double(
          valid?: valid,
          current_component:,
          origin_component: budget_component,
          origin_component_id: budget_component.id,
          import_all_selected_projects: true,
          current_user: user
        )
      end

      context "when the form is not valid" do
        let(:valid) { false }

        it "is not valid" do
          expect { subject }.to broadcast(:invalid)
        end
      end

      context "when the form is valid" do
        let(:valid) { true }

        it "is not valid" do
          expect { subject }.to broadcast(:ok)
        end
      end
    end
  end
end
