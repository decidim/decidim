# frozen_string_literal: true

require "spec_helper"

module Decidim::CollaborativeTexts
  describe Admin::UpdateDocument do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:collaborative_texts_component, participatory_space: participatory_process) }
    let(:collaborative_text_document) { create(:collaborative_text_document, component:) }

    describe "#call" do
      let(:params) { { title: "New Title", component: } }

      context "when the attributes are valid" do
        it "correctly updates the CollaborativeText" do
          command = described_class.new(collaborative_text_document, params)

          command.call

          expect(collaborative_text.reload.title).to eq("New Title")
        end
      end
    end
  end
end
