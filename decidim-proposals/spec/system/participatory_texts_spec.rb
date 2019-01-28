# frozen_string_literal: true

require "spec_helper"

describe "Participatory texts", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  def should_have_proposal(selector, proposal)
    expect(page).to have_tag(selector, text: proposal.title)
    prop_block = page.find(selector)
    prop_block.hover
    expect(prop_block).to have_button("Follow")
    expect(prop_block).to have_link("Amend") if component.settings.amendments_enabled
    expect(prop_block).to have_link(proposal.emendations.count) if component.settings.amendments_enabled
    expect(prop_block).to have_link("Comment") if component.settings.comments_enabled
    expect(prop_block).to have_link(proposal.comments.count) if component.settings.comments_enabled
    expect(prop_block).to have_content(proposal.body) if proposal.participatory_text_level == "article"
    expect(prop_block).not_to have_content(proposal.body) if proposal.participatory_text_level != "article"
  end

  shared_examples_for "lists all the proposals ordered" do
    it "by position" do
      expect(component.settings.participatory_texts_enabled).to be true
      visit_component
      count = proposals.count
      expect(page).to have_css(".hover-section", count: count)
      should_have_proposal("#proposals div.hover-section:first-child", proposals.first)
      should_have_proposal("#proposals div.hover-section:nth-child(2)", proposals[1])
      should_have_proposal("#proposals div.hover-section:last-child", proposals.last)
    end

    context " when participatory text level is not article" do
      it "not renders the participatory text body" do
        proposal_section = proposals.first
        proposal_section.participatory_text_level = "section"
        proposal_section.save!
        visit_component
        should_have_proposal("#proposals div.hover-section:first-child", proposal_section)
      end
    end

    context "when participatory text level is article" do
      it "renders the proposal body" do
        proposal_article = proposals.last
        proposal_article.participatory_text_level = "article"
        proposal_article.save!
        visit_component
        should_have_proposal("#proposals div.hover-section:last-child", proposal_article)
      end
    end
  end

  context "when listing proposals in a participatory process as participatory texts" do
    context "when admin has not yet published a participatory text" do
      let!(:component) do
        create(:proposal_component,
               :with_participatory_texts_enabled,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      before do
        visit_component
      end

      it "renders an alternative title" do
        expect(page).to have_content("There are no participatory texts at the moment")
      end
    end

    context "when admin has published a participatory text" do
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

      context "when amendments are enabled" do
        let!(:component) do
          create(:proposal_component,
                 :with_amendments_and_participatory_texts_enabled,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        it_behaves_like "lists all the proposals ordered"
      end

      context "when amendments are disabled" do
        let(:component) do
          create(:proposal_component,
                 :with_participatory_texts_enabled,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        it_behaves_like "lists all the proposals ordered"
      end

      context "when comments are enabled" do
        let!(:component) do
          create(:proposal_component,
                 :with_participatory_texts_enabled,
                 :with_votes_enabled,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        it_behaves_like "lists all the proposals ordered"
      end

      context "when comments are disabled" do
        let(:component) do
          create(:proposal_component,
                 :with_comments_disabled,
                 :with_participatory_texts_enabled,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        it_behaves_like "lists all the proposals ordered"
      end
    end
  end
end
