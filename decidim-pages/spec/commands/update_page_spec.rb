# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pages
    module Admin
      describe UpdatePage, :db do
        let(:current_organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:feature) { create(:feature, manifest_name: "pages", participatory_process: participatory_process) }
        let(:page) { create(:page, feature: feature) }
        let(:form_params) do
          {
            "body" => page.body,
            "page" => {
              "commentable" => false
            }
          }
        end
        let(:form) do
          PageForm.from_params(
            form_params
          ).with_context(
            current_organization: current_organization
          )
        end
        let(:command) { described_class.new(form, page) }

        describe "when the form is invalid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the page" do
            expect(page).not_to receive(:update_attributes!)
            command.call
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new page with the same name as the feature" do
            expect(page).to receive(:update_attributes!)
            command.call
          end
        end
      end
    end
  end
end
