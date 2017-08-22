# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    shared_examples_for "CreateCategory command" do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:form_params) do
          {
            "category" => {
              "name_en" => Decidim::Faker::Localized.paragraph(3),
              "name_es" => Decidim::Faker::Localized.paragraph(3),
              "name_ca" => Decidim::Faker::Localized.paragraph(3),
              "description_en" => Decidim::Faker::Localized.paragraph(3),
              "description_es" => Decidim::Faker::Localized.paragraph(3),
              "description_ca" => Decidim::Faker::Localized.paragraph(3)
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
        let(:command) { described_class.new(form, participatory_space) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a category" do
            expect do
              command.call
            end.not_to change { Category.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new category" do
            expect do
              command.call
            end.to change { participatory_space.categories.count }.by(1)
          end
        end
      end
    end
  end
end
