# frozen_string_literal: true

require "spec_helper"

module Decidim::Debates
  describe DebatePresenter, type: :helper do
    let(:debate) { create :debate, component: debate_component }
    let(:user) { create :user, :admin, organization: }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:debates_component) { create(:debates_component, participatory_space: participatory_process) }

    let(:presented_debate) { described_class.new(debate) }

    describe "description" do
      let(:description1) do
        Decidim::ContentProcessor.parse_with_processor(:hashtag, "Description #description", current_organization: organization).rewrite
      end
      let(:description2) do
        Decidim::ContentProcessor.parse_with_processor(:hashtag, "Description in Spanish #description", current_organization: organization).rewrite
      end
      let(:debate) do
        create(
          :debate,
          component: debates_component,
          description: {
            en: description1,
            machine_translations: {
              es: description2
            }
          }
        )
      end

      it "parses hashtags in machine translations" do
        expect(debate.description["en"]).to match(/gid:/)
        expect(debate.description["machine_translations"]["es"]).to match(/gid:/)

        presented_description = presented_debate.description(all_locales: true)
        expect(presented_description["en"]).to eq("Description #description")
        expect(presented_description["machine_translations"]["es"]).to eq("Description in Spanish #description")
      end
    end
  end
end
