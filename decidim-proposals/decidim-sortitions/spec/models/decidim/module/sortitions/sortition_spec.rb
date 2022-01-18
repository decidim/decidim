# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    describe Sortition do
      subject { sortition }

      let(:sortition) { build(:sortition) }

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      describe "seed" do
        it "is the multiplication of timestamp per dice value" do
          expect(sortition.seed).to eq(sortition.request_timestamp.to_i * sortition.dice)
        end
      end

      describe "similar_count" do
        let(:sortition) { create(:sortition) }
        let(:category) { create(:category, participatory_space: sortition.component.participatory_space) }

        before do
          Decidim::Categorization.create!(decidim_category_id: category.id, categorizable: sortition)
          sortition.reload
        end

        context "when first sortition" do
          it "is one" do
            expect(sortition.similar_count).to eq(1)
          end
        end

        context "when following sortitions" do
          let(:repetitions) { 2 }

          before do
            create_list(:sortition, repetitions,
                        component: sortition.component,
                        decidim_proposals_component: sortition.decidim_proposals_component,
                        target_items: sortition.target_items).each do |sortition|
              Decidim::Categorization.create!(decidim_category_id: category.id, categorizable: sortition)
            end

            create_list(:sortition, repetitions,
                        component: sortition.component,
                        decidim_proposals_component: sortition.decidim_proposals_component,
                        target_items: sortition.target_items)
          end

          it "Counts similar sortitions" do
            expect(sortition.similar_count).to eq(1 + repetitions)
          end
        end
      end

      describe "proposals" do
        it "returns a list of selected proposals" do
          expect(sortition.proposals).to eq(Decidim::Proposals::Proposal.where(id: sortition.selected_proposals))
        end
      end

      describe "cancelled" do
        it "is true when cancelled_on has value" do
          sortition = build(:sortition, cancelled_on: Time.now.utc)
          expect(sortition).to be_cancelled
        end

        it "is false when cancelled_on is nil" do
          sortition = build(:sortition, cancelled_on: nil)
          expect(sortition).not_to be_cancelled
        end
      end
    end
  end
end
