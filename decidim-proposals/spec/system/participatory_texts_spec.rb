# frozen_string_literal: true

require "spec_helper"

describe "Participatory texts", type: :system do
  include Decidim::SanitizeHelper
  include ActionView::Helpers::TextHelper

  include_context "with a component"
  let(:manifest_name) { "proposals" }

  def should_have_proposal(selector, proposal)
    expect(page).to have_tag(selector, text: proposal.title)
    prop_block = page.find(selector)
    prop_block.hover
    clean_proposal_body = strip_tags(proposal.body)

    expect(prop_block).to have_button("Follow")
    expect(prop_block).to have_link("Comment") if component.settings.comments_enabled
    expect(prop_block).to have_link(proposal.comments.count.to_s) if component.settings.comments_enabled
    expect(prop_block).to have_content(clean_proposal_body) if proposal.participatory_text_level == "article"
    expect(prop_block).not_to have_content(clean_proposal_body) if proposal.participatory_text_level != "article"
  end

  shared_examples_for "lists all the proposals ordered" do
    it "by position" do
      visit_component
      expect(page).to have_css(".hover-section", count: proposals.count)
      proposals.each_with_index do |proposal, index|
        should_have_proposal("#proposals div.hover-section:nth-child(#{index + 1})", proposal)
      end
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

      it "renders the participatory text title" do
        visit_component

        expect(page).to have_content(participatory_text.title)
      end

      context "with existing amendments" do
        let!(:proposals) { create_list(:proposal, 1, :published, component: component) }
        let!(:emendation_1) { create(:proposal, :published, component: component) }
        let!(:amendment_1) { create :amendment, amendable: proposals.first, emendation: emendation_1 }
        let!(:emendation_2) { create(:proposal, component: component) }
        let!(:amendment_2) { create(:amendment, amendable: proposals.first, emendation: emendation_2) }
        let(:active_step_id) { participatory_process.active_step.id }
        let(:amend_button) { page.find("a", text: "Amend", visible: false) }

        context "when amendments are enabled" do
          before do
            component.update!(settings: { participatory_texts_enabled: true, amendments_enabled: true })
          end

          it_behaves_like "lists all the proposals ordered"

          context "and amendment CREATION is enabled" do
            before do
              component.update!(step_settings: { active_step_id => { amendment_creation_enabled: true } })
              visit_component
            end

            it "shows the Amend button enabled" do
              expect(amend_button[:disabled]).to eq(nil)
            end
          end

          context "and amendment CREATION is disabled" do
            before do
              component.update!(step_settings: { active_step_id => { amendment_creation_enabled: false } })
              visit_component
            end

            it "shows the Amend button disabled" do
              expect(amend_button[:disabled]).to eq("true")
            end
          end

          context "and amendments VISIBILITY is set to 'all'" do
            before do
              component.update!(step_settings: { active_step_id => { amendments_visibility: "all" } })
            end

            context "when the user is logged in" do
              let(:user) { amendment_1.amender }

              before do
                login_as user, scope: :user
                visit_component
              end

              it "counts all amendments" do
                within "#proposals div.hover-section div.amend-buttons", visible: false do
                  expect(page).to have_link("2", visible: false)
                end
              end
            end

            context "when the user is NOT logged in" do
              before do
                visit_component
              end

              it "counts all amendments" do
                within "#proposals div.hover-section div.amend-buttons", visible: false do
                  expect(page).to have_link("2", visible: false)
                end
              end
            end
          end

          context "and amendments VISIBILITY is set to 'participants'" do
            before do
              component.update!(step_settings: { active_step_id => { amendments_visibility: "participants" } })
            end

            context "when the user is logged in" do
              let(:user) { amendment_1.amender }

              before do
                login_as user, scope: :user
                visit_component
              end

              it "counts only its own amendments" do
                within "#proposals div.hover-section div.amend-buttons", visible: false do
                  expect(page).to have_link("1", visible: false)
                end
              end
            end

            context "when the user is NOT logged in" do
              before do
                visit_component
              end

              it "does not count any amendments" do
                expect(page).not_to have_css("#proposals div.hover-section div.amend-buttons", visible: false)
              end
            end
          end
        end

        context "when amendments are DISabled" do
          before do
            component.update!(settings: { participatory_texts_enabled: true, amendments_enabled: false })
          end

          it_behaves_like "lists all the proposals ordered"

          context "and amendment CREATION is enabled" do
            before do
              component.update!(step_settings: { active_step_id => { amendment_creation_enabled: true } })
              visit_component
            end

            it "shows the Amend button disabled" do
              expect(amend_button[:disabled]).to eq("true")
            end
          end

          context "and amendment CREATION is disabled" do
            before do
              component.update!(step_settings: { active_step_id => { amendment_creation_enabled: false } })
              visit_component
            end

            it "shows the Amend button disabled" do
              expect(amend_button[:disabled]).to eq("true")
            end
          end

          context "and amendments VISIBILITY is set to 'all'" do
            before do
              component.update!(step_settings: { active_step_id => { amendments_visibility: "all" } })
            end

            context "when the user is logged in" do
              let(:user) { amendment_1.amender }

              before do
                login_as user, scope: :user
                visit_component
              end

              it "counts all amendments" do
                within "#proposals div.hover-section div.amend-buttons", visible: false do
                  expect(page).to have_link("2", visible: false)
                end
              end
            end

            context "when the user is NOT logged in" do
              before do
                visit_component
              end

              it "counts all amendments" do
                within "#proposals div.hover-section div.amend-buttons", visible: false do
                  expect(page).to have_link("2", visible: false)
                end
              end
            end
          end
        end

        context "and amendments VISIBILITY is set to 'participants'" do
          before do
            component.update!(step_settings: { active_step_id => { amendments_visibility: "participants" } })
          end

          context "when the user is logged in" do
            let(:user) { amendment_1.amender }

            before do
              login_as user, scope: :user
              visit_component
            end

            it "counts all amendments" do
              within "#proposals div.hover-section div.amend-buttons", visible: false do
                expect(page).to have_link("2", visible: false)
              end
            end
          end

          context "when the user is NOT logged in" do
            before do
              visit_component
            end

            it "counts all amendments" do
              within "#proposals div.hover-section div.amend-buttons", visible: false do
                expect(page).to have_link("2", visible: false)
              end
            end
          end
        end
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
