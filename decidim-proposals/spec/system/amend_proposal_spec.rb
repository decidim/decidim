# frozen_string_literal: true

require "spec_helper"

describe "Amend Proposal", versioning: true, type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposal) { create(:proposal, title: "Title", body: "One liner body",component: component) }
  let!(:emendation) { create(:proposal, body: "Amended One liner body", component: component) }
  let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation }
  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:user_group) { create(:user_group, :verified, organization: organization, users: [user]) }
  let(:emendation_path) { Decidim::ResourceLocatorPresenter.new(emendation).path }

  context "when amendments are not enabled" do
    it "doesn't show the amend proposal button" do
      visit_component

      click_link proposal.title
      expect(page).to have_no_link("Amend Proposal")
    end
  end

  context "when amendments are enabled" do
    let!(:component) do
      create(:proposal_component,
             :with_amendments_enabled,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    context "and visits an amendable proposal" do
      before do
        visit_component
        click_link proposal.title
      end

      it "renders a link to Amend it" do
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
        before do
          login_as user, scope: :user
          visit_component
          click_link proposal.title
        end

        it "is shown the amend form" do
          within ".card__amend-button", match: :first do
            click_link "Amend Proposal"
          end

          expect(page).to have_css(".new_amendment", visible: true)
          expect(page).to have_content("CREATE YOUR AMENDMENT")
        end
      end

      context "when creating an amendment" do
        before do
          login_as user, scope: :user
          visit decidim.new_amend_path(amendable_gid: proposal.to_sgid.to_s)
        end

        it "is shown the amend title field" do
          expect(page).to have_css(".field", text: "Title", visible: true)
        end
        it "is shown the amend body field" do
          expect(page).to have_css(".field", text: "Body", visible: true)
        end
        it "is shown the amend user group as field" do
          expect(page).to have_css(".field", text: "Amendment author", visible: true)
        end
        it "is shown the submit button" do
          expect(page).to have_button("Send amendment")
        end
      end

      context "when the form is filled correctly" do
        before do
          login_as user, scope: :user
          visit decidim.new_amend_path(amendable_gid: proposal.to_sgid.to_s)
          within ".new_amendment" do
            fill_in "amendment[emendation_params][title]", with: "More sidewalks and less roads"
            fill_in "amendment[emendation_params][body]", with: "Cities need more people, not more cars"
            select user_group.name, from: :amendment_user_group_id
          end
          click_button "Send amendment"
        end

        it "is shown the Success Callout" do
          expect(page).to have_css(".callout.success", text: "The amendment has been created successfully")
        end

        it "is shown the emendation in the amendments list" do
          emendation = Decidim::Proposals::Proposal.last

          expect(page).to have_content(emendation.title)
          expect(page).to have_content(emendation.body)
          expect(page).to have_css(".card__text--status", text: "EVALUATING")
        end
      end

      context "when the form is filled incorrectly" do
        before do
          login_as user, scope: :user
          visit decidim.new_amend_path(amendable_gid: proposal.to_sgid.to_s)
          within ".new_amendment" do
            fill_in "amendment[emendation_params][title]", with: "INVALID TITLE"
          end
          click_button "Send amendment"
        end

        it "is shown the Error Callout" do
          expect(page).to have_css(".callout.alert", text: "An error ocurred while creating the amendment")
        end

        it "is shown the error message" do
          expect(page).to have_css(".form-error.is-visible", text: "Title is using too many capital letters")
        end
      end
    end

    context "when viewing an amendment" do
      before do
        visit_component
        login_as user, scope: :user
        click_link emendation.title
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

    context "when the user is the author of the amendable proposal" do
      let(:user) { proposal.creator_author }

      before do
        visit_component
        login_as user, scope: :user
      end

      context "and visits an emendation to their proposal" do
        before do
          click_link emendation.title
        end

        it "is shown the accept and reject button" do
          expect(page).to have_css(".success", text: "ACCEPT")
          expect(page).to have_css(".alert", text: "REJECT")
        end

        context "when the user clicks on the accept button" do
          before do
            visit decidim.review_amend_path(amendment)
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

          it "is shown the review the amendment form" do
            expect(page).to have_css(".edit_amendment")
            expect(page).to have_content("REVIEW THE AMENDMENT")
            expect(page).to have_field("Title", with: emendation.title.to_s)
            expect(page).to have_field("Body", with: emendation.body.to_s)
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
              visit_component

              within "#proposal_#{emendation.id}" do
                expect(page).to have_css(".success", text: "ACCEPTED")
              end
            end
          end
        end

        context "when the user clicks on the reject button" do
          before do
            find("a[href='#{decidim.reject_amend_path(amendment)}']").click
          end

          it "is shown the Success Callout" do
            expect(page).to have_css(".callout.success", text: "The amendment has been successfully rejected")
          end

          it "is changed the state of the emendation" do
            visit_component

            within "#proposal_#{emendation.id}" do
              expect(page).to have_css(".alert", text: "REJECTED")
            end
          end
        end
      end
    end

    context "when the user is the author of the emendation" do
      let(:user) { emendation.creator_author }
      let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation, state: "rejected" }

      before do
        visit_component
        login_as user, scope: :user
      end

      context "and visits a rejected emendation" do
        before do
          click_link emendation.title
        end

        it "is shown the promote button" do
          expect(page).to have_content("PROMOTE TO PROPOSAL")
          expect(page).to have_content("You can promote this emendation and publish it as an independent proposal")
        end

        context "when the user clicks on the promote button" do
          before do
            find("a[href='#{decidim.promote_amend_path(amendment)}']").click
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
  end
end
