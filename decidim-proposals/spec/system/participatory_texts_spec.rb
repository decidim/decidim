# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  def should_have_proposal(selector, proposal)
    expect(page).to have_tag(selector, text: proposal.title)
    prop_block = page.find(selector)
    prop_block.hover
    expect(prop_block).to have_link("Sign in")
    expect(prop_block).to have_link("Comment")
    expect(prop_block).to have_button("Vote") if component.step_settings[participatory_process.active_step.id.to_s].votes_enabled?
    expect(prop_block).to have_link("Endorse")
  end

  shared_examples_for "lists all the proposals ordered" do
    it "by position" do
      expect(component.settings.participatory_texts_enabled?).to be true
      visit_component
      count = proposals.count
      expect(page).to have_css(".hover-section", count: count)
      should_have_proposal("#proposals div.hover-section:first-child", proposals.first)
      should_have_proposal("#proposals div.hover-section:nth-child(2)", proposals[1])
      should_have_proposal("#proposals div.hover-section:last-child", proposals.last)
    end
  end

  context "when listing proposals in a participatory process as participatory texts" do
    context "when admin has not yet imported a participatory text" do
      let!(:component) do
        create(:proposal_component,
               :with_participatory_texts_enabled,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      before do
        visit_component
      end

      it "renders an empty title" do
        within ".heading2" do
          expect(page).to have_content("")
        end
      end
    end

    context "when admin has imported a participatory text" do
      let!(:participatory_text) { create :participatory_text, component: component }
      let!(:proposals) { create_list(:proposal, 3, :published, component: component) }
      let!(:component) do
        create(:proposal_component,
               :with_participatory_texts_enabled,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      before do
        visit_component
      end

      it "renders the participatory text title" do
        expect(page).to have_content(participatory_text.title)
      end

      context "when voting is enabled" do
        let!(:component) do
          create(:proposal_component,
                 :with_participatory_texts_enabled,
                 :with_votes_enabled,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        it_behaves_like "lists all the proposals ordered"
      end

      context "when voting is disabled" do
        let(:component) do
          create(:proposal_component,
                 :with_votes_disabled,
                 :with_participatory_texts_enabled,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        it_behaves_like "lists all the proposals ordered"
      end
    end
  end
end
