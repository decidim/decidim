# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImportCategoriesFromAnotherSpace do
      describe "call" do
        let!(:categories) { create_list(:category, 3) }
        let!(:category) { categories.first }

        let(:current_space) { create(:participatory_process, organization: category.participatory_space.organization) }
        let!(:current_user) { create(:user, :admin, organization: current_space.organization) }
        let!(:organization) { current_space.organization }
        let!(:form) do
          instance_double(
            ImportCategoriesForm,
            origin_participatory_space: category.participatory_space,
            current_participatory_space: current_space,
            valid?: valid
          )
        end

        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
          let(:valid) { false }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create the category" do
            expect do
              command.call
            end.to change(Category, :count).by(0)
          end
        end

        describe "when the form is valid" do
          let(:valid) { true }

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates the categories" do
            expect do
              command.call
            end.to change { Category.where(participatory_space: current_space).count }.by(1)
          end

          it "only imports wanted attributes" do
            command.call

            new_category = Category.where(participatory_space: current_space).last
            expect(new_category.name).to eq(category.name)
            expect(new_category.description).to eq(category.description)
            expect(new_category.parent).to eq(category.parent)
          end
        end
      end

      def project_localized(text)
        Decidim.available_locales.inject({}) do |result, locale|
          result.update(locale => text)
        end.with_indifferent_access
      end
    end
  end
end
