# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "DestroyCategory command" do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:user) { create(:user, organization: organization) }
        let(:category) { create(:category, participatory_space: participatory_space) }
        let(:command) { described_class.new(category, user) }

        describe "when the category is not present" do
          let(:category) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the category is not empty" do
          let!(:subcategory) { create :subcategory, parent: category }

          it "doesn't destroy the category" do
            expect do
              command.call
            end.not_to change(Category, :count)
          end
        end

        context "when the category is a subcategory" do
          let!(:parent_category) { create :category, participatory_space: participatory_space }

          before do
            category.parent = parent_category
          end

          it "destroy the category" do
            category
            expect do
              command.call
            end.to change(Category, :count).by(-1)
          end
        end

        describe "when the data is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "destroys the category in the process" do
            category
            expect do
              command.call
            end.to change(Category, :count).by(-1)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:delete, category, user)
              .and_call_original

            expect { command.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.action).to eq("delete")
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
