# frozen_string_literal: true

require "spec_helper"

module Decidim::Debates
  describe DebateGCell, type: :cell do
    controller Decidim::Debates::DebatesController

    subject { cell_html }

    let(:my_cell) { cell("decidim/debates/debate_g", debate) }
    let(:cell_html) { my_cell.call }
    let(:created_at) { 1.month.ago }
    let(:component) { create(:debates_component) }
    let!(:debate) { create(:debate, description: { en: "Description for test" }, component:, created_at:) }
    let(:model) { debate }
    let(:user) { create(:user, organization: debate.participatory_space.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when rendering" do
      it "renders the grid card" do
        expect(subject).to have_css("[id^='debates__debate']")
      end

      it "renders the description" do
        expect(subject).to have_content("Description for test")
      end

      it "renders the title" do
        expect(subject).to have_content(translated_attribute(model.title))
      end

      context "when the description has a link" do
        let!(:debate) { create(:debate, description:, component:, created_at:) }
        let(:description) { { en: "This is a description with a link to <a href='http://example.org'>example.org</a>" } }

        it "renders the description" do
          expect(subject).to have_content("This is a description with a link to example.org")
        end
      end
    end
  end
end
