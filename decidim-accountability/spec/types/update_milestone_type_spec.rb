# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe UpdateMilestoneType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:current_component) { component }
    let(:component) { create(:accountability_component, organization: current_organization) }

    let(:root_klass) { ResultMutationType }
    let!(:result) { create(:result, component:) }
    let(:model) { result }
    let(:milestone) { create(:milestone, result:) }
    let(:entry_date) { "2025-01-01" }
    let(:title_en) { Faker::Lorem.sentence(word_count: 3) }
    let(:description_en) { Faker::Lorem.paragraph(sentence_count: 2) }
    let(:locale) { "en" }
    let(:attributes) do
      {
        title: { en: title_en },
        description: { en: description_en },
        entryDate: entry_date
      }
    end
    let(:variables) do
      {
        result_id: result.id,
        input: {
          id: milestone.id,
          attributes:
        }
      }
    end

    let(:query) do
      <<~GRAPHQL
        mutation($input: UpdateMilestoneInput!) {
          updateMilestone(input: $input) {
            id
            title {
              translation(locale: "#{locale}")
            }
            description {
              translation(locale: "#{locale}")
            }
            entryDate
            result { id }
          }
        }
      GRAPHQL
    end

    shared_examples "API updatable milestone" do
      it "assigns fields" do
        milestone = response["updateMilestone"]
        expect(milestone["id"]).to be_present
        expect(milestone["title"]["translation"]).to eq(title_en)
        expect(milestone["description"]["translation"]).to eq(description_en)
        expect(milestone["entryDate"]).to eq(entry_date)
      end

      context "when having invalid arguments" do
        context "when having invalid locale" do
          let(:variables) do
            {
              component_id: current_component.id,
              result_id: model.id,
              input: {
                id: milestone.id,
                attributes: {
                  title: { :en => title_en, "tlh" => "Foo bar" },
                  description: { en: description_en },
                  entryDate: entry_date
                }
              }
            }
          end

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::InvalidLocaleError, /Invalid locale provided/)
          end
        end

        context "when submitting entry_date as string" do
          let(:entry_date) { "foo" }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end

        context "when submitting invalid entry_date" do
          let(:entry_date) { "" }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end

        context "when submitting invalid title for budget" do
          let(:title_en) { "" }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
          end
        end
      end
    end

    it_behaves_like "admin API access checks", "API updatable milestone"
  end
end
