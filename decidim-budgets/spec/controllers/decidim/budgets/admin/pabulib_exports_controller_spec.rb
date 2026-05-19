# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    module Admin
      describe BudgetsController do
        let(:current_user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:component) { create(:budgets_component) }
        let(:budget) { create(:budget, component:) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        describe "GET show" do
          it "returns the correct status code" do
            # TODO
          end
        end

        describe "POST create" do
          context "when the form is valid" do
            it "returns the correct status code" do
              # TODO
            end
          end

          context "when the form is invalid" do
            it "returns the correct status code" do
              # TODO
            end
          end
        end
      end
    end
  end
end
