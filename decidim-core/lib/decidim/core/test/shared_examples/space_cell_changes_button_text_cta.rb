# frozen_string_literal: true

require "spec_helper"

shared_examples_for "space cell changes button text CTA" do
  describe "within the card footer" do
    context "when it has no components" do
      it "renders 'More info' in the CTA button text" do
        expect(subject).to have_selector(".card__footer--spaces .card__button", text: "More info")
      end
    end

    context "when it has a component" do
      context "and it is not published" do
        let!(:component) { create(:component, :unpublished, manifest_name: "dummy", participatory_space: model) }

        it "renders 'More info' in the CTA button text" do
          expect(subject).to have_selector(".card__footer--spaces .card__button", text: "More info")
        end
      end

      context "and it is published" do
        let!(:component) { create(:component, :published, manifest_name: "dummy", participatory_space: model) }

        it "renders 'Take part' in the CTA button text" do
          expect(subject).to have_selector(".card__footer--spaces .card__button", text: "Take part")
        end
      end
    end
  end
end
