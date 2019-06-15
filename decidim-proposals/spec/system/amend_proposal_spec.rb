# frozen_string_literal: true

require "spec_helper"

describe "Amend Proposal", versioning: true, type: :system do
  let!(:component) { create(:proposal_component) }
  let!(:proposal) { create(:proposal, title: "Long enough title", body: "One liner body", component: component) }
  let!(:emendation) { create(:proposal, title: "Amended Long enough title", body: "Amended One liner body", component: component) }
  let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation, amender: emendation.creator_author }
  let(:emendation_path) { Decidim::ResourceLocatorPresenter.new(emendation).path }
  let(:proposal_path) { Decidim::ResourceLocatorPresenter.new(proposal).path }

  def update_component_step_setting(component, step_setting_name, value)
    component.update!(
      step_settings: {
        component.participatory_space.active_step.id => {
          step_setting_name => value
        }
      }
    )
  end

  before do
    switch_to_host(component.organization.host)
  end

  context "with existing amendments" do
    context "when visiting an amended proposal" do
      before do
        visit proposal_path
      end

      it "is shown the amendments list" do
        expect(page).to have_css("#amendments", text: "AMENDMENTS")
        within ".amendment-list" do
          expect(page).to have_content(emendation.title)
        end
      end

      it "is shown the amenders list" do
        expect(page).to have_content("AMENDED BY")
        within ".amender-list" do
          expect(page).to have_content(emendation.creator_author.name)
        end
      end
    end

    context "when visiting an amendment to a proposal" do
      before do
        visit emendation_path
      end

      it "shows the changed attributes" do
        expect(page).to have_content("Amendment to \"#{proposal.title}\"")

        within ".diff-for-title" do
          expect(page).to have_content("TITLE")

          within ".diff > ul > .del" do
            expect(page).to have_content(proposal.title)
          end

          within ".diff > ul > .ins" do
            expect(page).to have_content(emendation.title)
          end
        end

        within ".diff-for-body" do
          expect(page).to have_content("BODY")

          within ".diff > ul > .del" do
            expect(page).to have_content(proposal.body)
          end

          within ".diff > ul > .ins" do
            expect(page).to have_content(emendation.body)
          end
        end
      end
    end
  end

  context "with amendments NOT enabled" do
    before do
      component.update!(settings: { amendments_enabled: false })
    end

    context "when amendment CREATION is enabled" do
      before do
        update_component_step_setting(component, :amendment_creation_enabled, true)
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
        update_component_step_setting(component, :amendment_reaction_enabled, true)
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
        update_component_step_setting(component, :amendment_promotion_enabled, true)
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
  end

  context "with amendments enabled" do
    before do
      component.update!(settings: { amendments_enabled: true })
    end

    context "when amendment CREATION is enabled" do
      before do
        update_component_step_setting(component, :amendment_creation_enabled, true)
      end

      context "and visits an amendable proposal" do
        before do
          visit proposal_path
        end

        it "is shown a link to Amend it" do
          expect(page).to have_link("Amend Proposal")
        end

        context "when the user is not logged in and clicks" do
          it "is shown the login modal" do
            within ".card__amend-button", match: :first do
              click_link "Amend Proposal"
            end

            expect(page).to have_css("#loginModal", visible: true)
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
            expect(page).to have_css(".new_amendment", visible: true)
            expect(page).to have_content("CREATE YOUR AMENDMENT")
            expect(page).to have_css(".field", text: "Title", visible: true)
            expect(page).to have_css(".field", text: "Body", visible: true)
            expect(page).to have_css(".field", text: "Amendment author", visible: true)
            expect(page).to have_button("Send amendment")
          end

          context "when the form is filled correctly" do
            before do
              within ".new_amendment" do
                fill_in "amendment[emendation_params][title]", with: "More sidewalks and less roads"
                fill_in "amendment[emendation_params][body]", with: "Cities need more people, not more cars"
                select user_group.name, from: :amendment_user_group_id # Optional
              end
              click_button "Send amendment"
            end

            it "is shown the Success Callout" do
              expect(page).to have_css(".callout.success", text: "The amendment has been created successfully")
            end
          end

          context "when the form is filled incorrectly" do
            before do
              within ".new_amendment" do
                fill_in "amendment[emendation_params][title]", with: "INVALID TITLE"
              end
              click_button "Send amendment"
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
        update_component_step_setting(component, :amendment_creation_enabled, false)
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
        update_component_step_setting(component, :amendment_reaction_enabled, true)
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
            click_link "Accept"
          end

          it "shows the changed attributes" do
            within ".diff-for-title" do
              expect(page).to have_content("TITLE")

              within ".diff > ul > .del" do
                expect(page).to have_content(proposal.title)
              end

              within ".diff > ul > .ins" do
                expect(page).to have_content(emendation.title)
              end
            end

            within ".diff-for-body" do
              expect(page).to have_content("BODY")

              within ".diff > ul > .del" do
                expect(page).to have_content(proposal.body)
              end

              within ".diff > ul > .ins" do
                expect(page).to have_content(emendation.body)
              end
            end
          end

          it "is shown the amendment review form" do
            expect(page).to have_css(".edit_amendment")
            expect(page).to have_content("REVIEW THE AMENDMENT")
            expect(page).to have_field("Title", with: emendation.title)
            expect(page).to have_field("Body", with: emendation.body)
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
              expect(page).to have_css(".success", text: "This amendment for the proposal #{emendation.title} has been accepted")
            end
          end
        end

        context "when the user clicks on the reject button" do
          before do
            click_link "Reject"
          end

          it "is shown the Success Callout" do
            expect(page).to have_css(".callout.success", text: "The amendment has been successfully rejected")
          end

          it "is changed the state of the emendation" do
            expect(page).to have_css(".alert", text: "This amendment for the proposal #{proposal.title} was rejected")
          end
        end
      end
    end

    context "when amendment REACTION is NOT enabled" do
      before do
        update_component_step_setting(component, :amendment_reaction_enabled, false)
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
        update_component_step_setting(component, :amendment_promotion_enabled, true)
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
            expect(accept_alert).to eq("Are you sure you want to promote this emendation?")
          end

          it "is shown the Success Callout when the alert text is accepted" do
            page.driver.browser.switch_to.alert.accept
            expect(page).to have_content("The amendment has been successfully published as a new proposal")
          end

          context "when the user visits again the rejected emendation" do
            before do
              page.driver.browser.switch_to.alert.accept
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
        update_component_step_setting(component, :amendment_promotion_enabled, false)
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
  end
end
