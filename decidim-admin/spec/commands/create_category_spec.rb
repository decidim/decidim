# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe CreateCategory, :db do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:participatory_process) { create :participatory_process, organization: organization }
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
            current_organization: organization,
            current_process: participatory_process
          )
        end
        let(:command) { described_class.new(form, participatory_process) }

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
            end.to_not change { Category.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new category" do
            expect do
              command.call
            end.to change { participatory_process.categories.count }.by(1)
          end
        end
      end
    end
  end
end
