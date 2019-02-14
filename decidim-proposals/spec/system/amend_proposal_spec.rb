# frozen_string_literal: true

require "spec_helper"

describe "Amend Proposal", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposals) { create_list(:proposal, 3, component: component) }
  let!(:proposal) { Decidim::Proposals::Proposal.find_by(component: component) }
  let!(:emendation) { create(:proposal, component: component) }
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

      it "renders a link to Ammend it" do
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

          expect(page).to have_css(".new_amend", visible: true)
          expect(page).to have_content("CREATE YOUR AMENDMENT")
        end
      end

      context "and the amend form shows all the fields" do
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

      context "and the amend form is filled" do
        before do
          login_as user, scope: :user
          visit decidim.new_amend_path(amendable_gid: proposal.to_sgid.to_s)
          within ".new_amend" do
            fill_in "amend[emendation_fields][title]", with: "More sidewalks and less roads"
            fill_in "amend[emendation_fields][body]", with: "Cities need more people, not more cars"
            select user_group.name, from: :amend_user_group_id
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

          it "is shown the review the amendment form" do
            expect(page).to have_css(".edit_amend")
            expect(page).to have_content("REVIEW THE AMENDMENT")
            expect(page).to have_field("Title", with: emendation.title.to_s)
            expect(page).to have_field("Body", with: emendation.body.to_s)
            expect(page).to have_button("Accept amendment")
          end

          context "and the emendation is accepted" do
            before do
              within ".edit_amend" do
                click_button "Accept amendment"
              end
            end

            it "is shown the Success Callout" do
              expect(page).to have_css(".callout.success", text: "This emendation has been accepted successfully.")
            end

            it "is changed the state of the emendation" do
              expect(page).to have_css(".success", text: "Accepted")
            end
          end
        end

        context "when the user clicks on the reject button" do
          before do
            find("a[href='#{decidim.reject_amend_path(amendment)}']").click
          end

          it "is shown the Success Callout" do
            expect(page).to have_css(".callout.success", text: "The emendation has been rejected successfully")
          end

          it "is changed the state of the emendation" do
            expect(page).to have_css(".alert", text: "Rejected")
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
        end

        context "when the user clicks on the promote button" do
          before do
            find("a[href='#{decidim.promote_amend_path(emendation)}']").click
          end

          it "is shown the Success Callout" do
            expect(page).to have_content("Emendation promoted successfully")
          end

          context "when the user visits again the rejected emendation" do
            before do
              visit emendation_path
            end

            it "is NOT shown the promote button" do
              expect(page).not_to have_content("PROMOTE TO PROPOSAL")
            end
          end
        end
      end
    end
  end
end
