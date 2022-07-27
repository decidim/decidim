# frozen_string_literal: true

require "spec_helper"

describe "Amend Proposal", versioning: true, type: :system do
  let!(:participatory_space) { create(:participatory_process, :with_steps) }
  let!(:component) { create(:proposal_component, participatory_space:) }
  let!(:proposal) { create(:proposal, title: { en: "Long enough title" }, component:) }
  let!(:emendation) { create(:proposal, title: { en: "Amended Long enough title" }, component:) }
  let!(:amendment) { create :amendment, amendable: proposal, emendation: }
  let(:proposal_title) { translated(proposal.title) }
  let(:emendation_title) { translated(emendation.title) }
  let(:emendation_body) { translated(emendation.body) }

  let(:active_step_id) { participatory_space.active_step.id }
  let(:emendation_path) { Decidim::ResourceLocatorPresenter.new(emendation).path }
  let(:proposal_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

  before do
    switch_to_host(component.organization.host)
  end

  context "when visiting an amended proposal" do
    before do
      visit proposal_path
    end

    it "is shown the amendments list" do
      expect(page).to have_css("#amendments", text: "AMENDMENTS")
      within ".amendment-list" do
        expect(page).to have_content(emendation_title)
      end
    end

    it "is shown the amenders list" do
      expect(page).to have_content("AMENDED BY")
      within ".amender-list" do
        expect(page).to have_content(emendation.creator_author.name)
      end
    end
  end

  context "with amendments NOT enabled" do
    before do
      component.update!(settings: { amendments_enabled: false })
    end

    context "when amendment CREATION is enabled" do
      before do
        component.update!(step_settings: { active_step_id => { amendment_creation_enabled: true } })
      end

      context "and visits an amendable proposal" do
        before do
          visit proposal_path
        end

        it "is NOT shown a link to Amend it" do
          expect(page).not_to have_link("Amend Proposal")
        end
      end
    end

    context "when amendment REACTION is enabled" do
      before do
        component.update!(step_settings: { active_step_id => { amendment_reaction_enabled: true } })
      end

      context "and the proposal author visits an emendation to their proposal" do
        let(:user) { proposal.creator_author }

        before do
          login_as user, scope: :user
          visit emendation_path
        end

        it "is NOT shown the accept and reject button" do
          expect(page).not_to have_css(".success", text: "ACCEPT")
          expect(page).not_to have_css(".alert", text: "REJECT")
        end
      end
    end

    context "when amendment PROMOTION is enabled" do
      before do
        component.update!(step_settings: { active_step_id => { amendment_promotion_enabled: true } })
      end

      context "and the author of a rejected emendation visits their emendation" do
        let(:user) { emendation.creator_author }

        before do
          amendment.update(state: "rejected")
          login_as user, scope: :user
          visit emendation_path
        end

        it "is NOT shown the promote button" do
          expect(page).not_to have_content("PROMOTE TO PROPOSAL")
          expect(page).not_to have_content("You can promote this emendation and publish it as an independent proposal")
        end
      end
    end

    context "when amendments VISIBILITY is set to 'participants'" do
      before do
        component.update!(step_settings: { active_step_id => { amendments_visibility: "participants" } })
      end

      context "when the user is logged in" do
        before do
          login_as user, scope: :user
          visit proposal_path
        end

        context "and visit an amendable proposal that they have amended" do
          let(:user) { emendation.creator_author }

          it "is shown the emendation from other user in the amendments list" do
            within ".amendment-list" do
              expect(page).to have_content(emendation_title)
            end
          end

          it "is shown the other user in the amenders list" do
            within ".amender-list" do
              expect(page).to have_content(emendation.creator_author.name)
            end
          end
        end

        context "and visit an amendable proposal that they have NOT amended" do
          let!(:user) { create :user, :confirmed, organization: component.organization }

          it "is shown the emendation from other users in the amendments list" do
            within ".amendment-list" do
              expect(page).to have_content(emendation_title)
            end
          end

          it "is shown other users in the amenders list" do
            within ".amender-list" do
              expect(page).to have_content(emendation.creator_author.name)
            end
          end
        end
      end

      context "when the user is NOT logged in" do
        before do
          visit proposal_path
        end

        context "and visit an amendable proposal" do
          it "is shown the emendation from other users in the amendments list" do
            within ".amendment-list" do
              expect(page).to have_content(emendation_title)
            end
          end

          it "is shown other users in the amenders list" do
            within ".amender-list" do
              expect(page).to have_content(emendation.creator_author.name)
            end
          end
        end
      end
    end
  end

  context "with amendments enabled" do
    before do
      component.update!(settings: { amendments_enabled: true })
    end

    context "when amendment CREATION is enabled" do
      before do
        component.update!(step_settings: { active_step_id => { amendment_creation_enabled: true } })
      end

      context "and visits an amendable proposal from a private yet transparent space" do
        let!(:participatory_space) { create(:assembly, :private, :transparent) }
        let(:active_step_id) { "default_step" }

        before do
          visit proposal_path
        end

        it "is NOT shown a link to Amend it" do
          expect(page).not_to have_link("Amend Proposal")
        end

        context "when a private user is logged in" do
          let!(:user) { create :user, :confirmed, organization: component.organization }

          before do
            participatory_space.update(users: [user])
            login_as user, scope: :user
            visit proposal_path
          end

          it "is shown a link to Amend it" do
            expect(page).to have_link("Amend Proposal")
          end
        end
      end

      context "and visits an amendable proposal" do
        before do
          visit proposal_path
        end

        it "is shown a link to Amend it" do
          expect(page).to have_link("Amend Proposal")
        end

        context "when the user is not logged in and clicks" do
          before do
            click_link "Amend Proposal"
          end

          it "is shown the login modal" do
            expect(page).to have_css("#loginModal", visible: :visible)
          end
        end

        context "when the user is logged in and clicks" do
          let!(:user) { create :user, :confirmed, organization: component.organization }
          let!(:user_group) { create(:user_group, :verified, organization: user.organization, users: [user]) }

          before do
            login_as user, scope: :user
            visit proposal_path
            click_link "Amend Proposal"
          end

          it "is shown the amendment create form" do
            expect(page).to have_css(".new_amendment", visible: :visible)
            expect(page).to have_content("Create your amendment")
            expect(page).to have_css(".field", text: "Title", visible: :visible)
            expect(page).to have_css(".field", text: "Body", visible: :visible)
            expect(page).to have_css(".field", text: "Amendment author", visible: :visible)
            expect(page).to have_button("Create")
          end

          context "when the form is filled correctly" do
            before do
              within ".new_amendment" do
                fill_in "amendment[emendation_params][title]", with: "More sidewalks and less roads"
                fill_in "amendment[emendation_params][body]", with: "Cities need more people, not more cars"
                select user_group.name, from: :amendment_user_group_id # Optional
              end
              click_button "Create"
            end

            it "is shown the Success Callout" do
              expect(page).to have_css(".callout.success")
            end
          end

          context "when the form is filled incorrectly" do
            before do
              within ".new_amendment" do
                fill_in "amendment[emendation_params][title]", with: "INVALID TITLE"
              end
              click_button "Create"
            end

            it "is shown the Error Callout" do
              expect(page).to have_css(".callout.alert", text: "An error ocurred while creating the amendment")
            end

            it "is shown the field error message" do
              expect(page).to have_css(".form-error.is-visible", text: "Title is using too many capital letters")
            end
          end
        end
      end
    end

    context "when amendment CREATION is NOT enabled" do
      before do
        component.update!(step_settings: { active_step_id => { amendment_creation_enabled: false } })
      end

      context "and visits an amendable proposal" do
        before do
          visit proposal_path
        end

        it "is NOT shown a link to Amend it" do
          expect(page).not_to have_link("Amend Proposal")
        end
      end
    end

    context "when amendment REACTION is enabled" do
      before do
        component.update!(step_settings: { active_step_id => { amendment_reaction_enabled: true } })
      end

      context "and the proposal author visits an emendation to their proposal" do
        let(:user) { proposal.creator_author }

        before do
          login_as user, scope: :user
          visit emendation_path
        end

        it "is shown the accept and reject button" do
          expect(page).to have_css(".success", text: "ACCEPT")
          expect(page).to have_css(".alert", text: "REJECT")
        end

        context "when the user clicks on the accept button" do
          before do
            # For some reason, the reject button click can fail unless the page
            # is first scrolled to the amend button...?
            # Got the idea from:
            # https://stackoverflow.com/a/39103252
            page.scroll_to(find(".card__amend-button"))
            click_link "Accept"
          end

          it "is shown the amendment review form" do
            expect(page).to have_css(".edit_amendment")
            expect(page).to have_content("REVIEW THE AMENDMENT")
            expect(page).to have_field("Title", with: emendation_title)
            expect(page).to have_field("Body", with: emendation_body)
            expect(page).to have_button("Accept amendment")
          end

          context "and the emendation is accepted" do
            before do
              within ".edit_amendment" do
                click_button "Accept amendment"
              end
            end

            it "is shown the Success Callout" do
              expect(page).to have_css(".callout.success", text: "The amendment has been accepted successfully.")
            end

            it "is changed the state of the emendation" do
              expect(page).to have_css(".success", text: "This amendment for the proposal #{emendation_title} has been accepted")
            end
          end
        end

        context "when the user clicks on the reject button" do
          before do
            # For some reason, the reject button click can fail unless the page
            # is first scrolled to the amend button...?
            # Got the idea from:
            # https://stackoverflow.com/a/39103252
            page.scroll_to(find(".card__amend-button"))
            click_link "Reject"
          end

          it "is shown the Success Callout" do
            expect(page).to have_css(".callout.success", text: "The amendment has been successfully rejected")
          end

          it "is changed the state of the emendation" do
            expect(page).to have_css(".callout.alert", text: "This amendment for the proposal #{proposal_title} was rejected")
          end
        end
      end
    end

    context "when amendment REACTION is NOT enabled" do
      before do
        component.update!(step_settings: { active_step_id => { amendment_reaction_enabled: false } })
      end

      context "and the proposal author visits an emendation to their proposal" do
        let(:user) { proposal.creator_author }

        before do
          login_as user, scope: :user
          visit emendation_path
        end

        it "is NOT shown the accept and reject button" do
          expect(page).not_to have_css(".success", text: "ACCEPT")
          expect(page).not_to have_css(".alert", text: "REJECT")
        end
      end
    end

    context "when amendment PROMOTION is enabled" do
      before do
        component.update!(step_settings: { active_step_id => { amendment_promotion_enabled: true } })
      end

      context "and the author of a rejected emendation visits their emendation" do
        let(:user) { emendation.creator_author }

        before do
          amendment.update(state: "rejected")
          login_as user, scope: :user
          visit emendation_path
        end

        it "is shown the promote button" do
          expect(page).to have_content("PROMOTE TO PROPOSAL")
          expect(page).to have_content("You can promote this emendation and publish it as an independent proposal")
        end

        context "when the user clicks on the promote button" do
          before do
            click_link "Promote"
          end

          it "is shown the alert text" do
            expect(accept_confirm).to eq("Are you sure you want to promote this emendation?")
          end

          it "is shown the Success Callout when the alert text is accepted" do
            accept_confirm
            expect(page).to have_content("The amendment has been successfully published as a new proposal")
          end

          context "when the user visits again the rejected emendation" do
            before do
              accept_confirm
              visit emendation_path
            end

            it "is NOT shown the promote button" do
              expect(page).not_to have_content("PROMOTE TO PROPOSAL")
              expect(page).not_to have_content("You can promote this emendation and publish it as an independent proposal")
            end
          end
        end
      end
    end

    context "when amendment PROMOTION is NOT enabled" do
      before do
        component.update!(step_settings: { active_step_id => { amendment_promotion_enabled: false } })
      end

      context "and the author of a rejected emendation visits their emendation" do
        let(:user) { emendation.creator_author }

        before do
          amendment.update(state: "rejected")
          login_as user, scope: :user
          visit emendation_path
        end

        it "is NOT shown the promote button" do
          expect(page).not_to have_content("PROMOTE TO PROPOSAL")
          expect(page).not_to have_content("You can promote this emendation and publish it as an independent proposal")
        end
      end
    end

    context "when amendments VISIBILITY is set to 'participants'" do
      before do
        component.update!(step_settings: { active_step_id => { amendments_visibility: "participants" } })
      end

      context "when the user is logged in" do
        before do
          login_as user, scope: :user
          visit proposal_path
        end

        context "and visit an amendable proposal that they have amended" do
          let(:user) { emendation.creator_author }

          it "is shown the emendation in the amendments list" do
            within ".amendment-list" do
              expect(page).to have_content(emendation_title)
            end
          end

          it "is shown the user in the amenders list" do
            within ".amender-list" do
              expect(page).to have_content(user.name)
            end
          end
        end

        context "and visit an amendable proposal that they have NOT amended" do
          let!(:user) { create :user, :confirmed, organization: component.organization }

          it "is NOT shown the amendments list" do
            expect(page).not_to have_css(".amendment-list")
          end

          it "is NOT shown the amenders list" do
            expect(page).not_to have_css(".amender-list")
          end
        end
      end

      context "when the user is NOT logged in" do
        before do
          visit proposal_path
        end

        context "and visit an amendable proposal" do
          it "is NOT shown the amendments list" do
            expect(page).not_to have_css(".amendment-list")
          end

          it "is NOT shown the amenders list" do
            expect(page).not_to have_css(".amender-list")
          end
        end
      end
    end

    context "when amendments VISIBILITY is set to 'all'" do
      before do
        component.update!(step_settings: { active_step_id => { amendments_visibility: "all" } })
      end

      context "when the user is logged in" do
        before do
          login_as user, scope: :user
          visit proposal_path
        end

        context "and visit an amendable proposal that they have amended" do
          let(:user) { emendation.creator_author }

          it "is shown the emendation from other user in the amendments list" do
            within ".amendment-list" do
              expect(page).to have_content(emendation_title)
            end
          end

          it "is shown the other user in the amenders list" do
            within ".amender-list" do
              expect(page).to have_content(emendation.creator_author.name)
            end
          end
        end

        context "and visit an amendable proposal that they have NOT amended" do
          let!(:user) { create :user, :confirmed, organization: component.organization }

          it "is shown the emendation from other users in the amendments list" do
            within ".amendment-list" do
              expect(page).to have_content(emendation_title)
            end
          end

          it "is shown other users in the amenders list" do
            within ".amender-list" do
              expect(page).to have_content(emendation.creator_author.name)
            end
          end
        end
      end

      context "when the user is NOT logged in" do
        before do
          visit proposal_path
        end

        context "and visit an amendable proposal" do
          it "is shown the emendation from other users in the amendments list" do
            within ".amendment-list" do
              expect(page).to have_content(emendation_title)
            end
          end

          it "is shown other users in the amenders list" do
            within ".amender-list" do
              expect(page).to have_content(emendation.creator_author.name)
            end
          end
        end
      end
    end
  end
end
