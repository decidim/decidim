# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "DestroyCategory command" do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:category) { create(:category, participatory_space: participatory_space) }
        let(:command) { described_class.new(category) }

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
            end.not_to change { Category.count }
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
            end.to change { Category.count }.by(-1)
          end
        end
      end
    end
  end
end
