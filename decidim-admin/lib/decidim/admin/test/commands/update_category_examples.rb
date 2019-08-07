# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "UpdateCategory command" do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:category) { create(:category, participatory_space: participatory_space) }
        let(:form_params) do
          {
            "category" => {
              "name_en" => "New title",
              "name_es" => "Title",
              "name_ca" => "Title",
              "description_en" => "Description",
              "description_es" => "Description",
              "description_ca" => "Description"
            }
          }
        end
        let(:form) do
          CategoryForm.from_params(
            form_params,
            current_participatory_space: participatory_space
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(category, form) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the category" do
            command.call
            category.reload

            expect(translated(category.name)).not_to eq("New title")
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the category in the process" do
            command.call
            category.reload

            expect(translated(category.name)).to eq("New title")
          end
        end
      end
    end
  end
end
