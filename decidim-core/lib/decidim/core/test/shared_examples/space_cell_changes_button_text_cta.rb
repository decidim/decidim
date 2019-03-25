# frozen_string_literal: true

require "spec_helper"

shared_examples_for "space cell changes button text CTA" do
  describe "within the card footer" do
    context "when it has no components" do
      it "renders 'More Info' in the CTA button text" do
        within ".card--conference .card__footer--spaces .card_button" do
          expect(cell_html).to have_content("More info")
        end
      end
    end

    context "when it has a component" do
      let(:published_at) { nil }
      let(:component) { create(:component, participatory_space: model, published_at: published_at) }

      context "and it is not published" do
        it "renders 'More Info' in the CTA button text" do
          within ".card--conference .card__footer--spaces .card_button" do
            expect(cell_html).to have_content("More info")
          end
        end
      end

      context "and it is published" do
        let(:published_at) { Time.current }

        it "renders 'Participate' in the CTA button text" do
          within ".card--conference .card__footer--spaces .card_button" do
            expect(cell_html).to have_content("Participate")
          end
        end
      end
    end
  end
end
