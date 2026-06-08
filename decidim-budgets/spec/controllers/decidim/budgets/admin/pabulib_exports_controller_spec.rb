# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    module Admin
      describe PabulibExportsController do
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
            get :show, params: { budget_id: budget.id }

            expect(response).to have_http_status(:ok)
          end
        end

        describe "POST create" do
          context "when the form is valid" do
            let!(:order) do
              create(:order, :with_projects, user: current_user, budget:).tap do |ord|
                ord.update!(checked_out_at: Time.zone.today)
              end
            end
            let(:export_params) do
              {
                description: "City PB voting",
                country: "Finland",
                unit: "Southern region",
                instance: "2026",
                vote_type: "approval",
                rule: "greedy",
                min_length: 1,
                max_length: 5
              }
            end

            it "returns the correct status code" do
              post :create, params: { budget_id: budget.id, pabulib_export: export_params }

              expect(response).to have_http_status(:ok)

              expect(response.content_type).to eq("text/csv; charset=utf-8")
              expect(response.headers["Content-Disposition"]).to match(/\Aattachment; filename="decidim-budget-#{budget.id}-results-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}.pb"\z/)
              expect(response.headers["Cache-Control"]).to eq("no-cache, no-store")
              expect(Time.zone.parse(response.headers["Last-Modified"])).to be_between(2.seconds.ago, Time.current)
            end

            context "with no orders" do
              let!(:order) { nil }

              it "returns the correct status code" do
                post :create, params: { budget_id: budget.id }

                expect(response).to have_http_status(:unprocessable_content)
                expect(response.content_type).to eq("text/html; charset=utf-8")
                expect(flash[:alert]).not_to be_empty
              end
            end
          end

          context "when the form is invalid" do
            before do
              form_builder = double
              allow(controller).to receive(:form).with(PabulibExportForm).and_return(form_builder)
              allow(form_builder).to receive(:from_params) do |params|
                PabulibExportForm.from_params(params).tap do |form|
                  allow(form).to receive(:valid?).and_return(false)
                end
              end
            end

            it "returns the correct status code" do
              post :create, params: { budget_id: budget.id }

              expect(response).to have_http_status(:unprocessable_content)
              expect(response.content_type).to eq("text/html; charset=utf-8")
              expect(flash[:alert]).not_to be_empty
            end
          end
        end
      end
    end
  end
end
