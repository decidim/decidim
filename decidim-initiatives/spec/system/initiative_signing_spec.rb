# frozen_string_literal: true

require "spec_helper"

describe "Initiative signing", type: :system do
  let(:organization) { create(:organization, available_authorizations: authorizations) }
  let(:initiative) do
    create(:initiative, :published, organization: organization)
  end
  let(:confirmed_user) { create(:user, :confirmed, organization: organization) }
  let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }

  before do
    allow(Decidim::Initiatives)
      .to receive(:do_not_require_authorization)
      .and_return(true)
    switch_to_host(organization.host)
    login_as confirmed_user, scope: :user
  end

  context "when the user has not signed the initiative yet and signs it" do
    context "when the user has a verified user group" do
      let!(:user_group) { create :user_group, :verified, users: [confirmed_user], organization: confirmed_user.organization }

      it "votes as a user group" do
        vote_initiative(user_name: user_group.name)
      end

      it "votes as themselves" do
        vote_initiative(user_name: confirmed_user.name)
      end
    end

    it "adds the signature" do
      vote_initiative
    end
  end

  context "when the user has signed the initiative and unsigns it" do
    context "when the user has a verified user group" do
      let!(:user_group) { create :user_group, :verified, users: [confirmed_user], organization: confirmed_user.organization }

      it "removes the signature" do
        vote_initiative(user_name: user_group.name)

        click_button user_group.name

        within ".view-side" do
          expect(page).to have_content("0\nSIGNATURE")
        end
      end
    end

    it "removes the signature" do
      vote_initiative

      within ".view-side" do
        expect(page).to have_content("1\nSIGNATURE")
        click_button "Sign"
        expect(page).to have_content("0\nSIGNATURE")
      end
    end
  end

  context "when the initiative type has permissions to vote" do
    context "when the user doesn't have a user group" do
      before do
        initiative.type.create_resource_permission(
          permissions: {
            "vote" => {
              "authorization_handlers" => {
                "dummy_authorization_handler" => { "options" => {} },
                "another_dummy_authorization_handler" => { "options" => {} }
              }
            }
          }
        )
      end

      context "and has not signed the initiative yet" do
        context "and is not verified" do
          it "signin initiative is disabled" do
            visit decidim_initiatives.initiative_path(initiative)

            within ".view-side" do
              expect(page).to have_content("SIGNING DISABLED")
              expect(page).to have_content("VERIFY YOUR IDENTITY")
            end
            click_button "Verify your identity"
            expect(page).to have_content("Authorization required")
          end
        end

        context "and is verified" do
          before do
            create(:authorization, name: "dummy_authorization_handler", user: confirmed_user, granted_at: 2.seconds.ago)
            create(:authorization, name: "another_dummy_authorization_handler", user: confirmed_user, granted_at: 2.seconds.ago)
          end

          it "votes as themselves" do
            vote_initiative
          end
        end
      end

      context "and has signed the initiative" do
        before do
          initiative.votes.create(author: confirmed_user)
        end

        context "and is not verified" do
          it "unsigning initiative is disabled" do
            visit decidim_initiatives.initiative_path(initiative)

            within ".view-side" do
              expect(page).to have_content("SIGNING DISABLED")
              expect(page).to have_content("VERIFY YOUR IDENTITY")
            end
            click_button "Verify your identity"
            expect(page).to have_content("Authorization required")
          end
        end
      end
    end

    context "when the user has a verified user group" do
      let!(:user_group) { create :user_group, :verified, users: [confirmed_user], organization: confirmed_user.organization }

      before do
        initiative.type.create_resource_permission(
          permissions: {
            "vote" => {
              "authorization_handlers" => {
                "dummy_authorization_handler" => { "options" => {} },
                "another_dummy_authorization_handler" => { "options" => {} }
              }
            }
          }
        )
      end

      context "and has not signed the initiative yet" do
        context "when the user is not verified" do
          it "signing initiative requires authorization for vote" do
            visit decidim_initiatives.initiative_path(initiative)

            within ".view-side" do
              expect(page).to have_content("0\nSIGNATURE")
              expect(page).to have_content("SIGNING DISABLED")
            end
            click_button "Verify your identity"
            expect(page).to have_content("Authorization required")
          end
        end

        context "and is verified" do
          before do
            create(:authorization, name: "dummy_authorization_handler", user: confirmed_user, granted_at: 2.seconds.ago)
            create(:authorization, name: "another_dummy_authorization_handler", user: confirmed_user, granted_at: 2.seconds.ago)
          end

          it "votes as themselves" do
            vote_initiative(user_name: confirmed_user.name)
          end

          it "votes as a user group" do
            vote_initiative(user_name: user_group.name)
          end
        end
      end

      context "and has signed the initiative" do
        before do
          create :initiative_user_vote, initiative: initiative, author: confirmed_user
        end

        context "and is not verified" do
          it "unsigning initiative is disabled" do
            visit decidim_initiatives.initiative_path(initiative)

            within ".view-side" do
              expect(page).to have_content("SIGNING DISABLED")
              expect(page).to have_content("VERIFY YOUR IDENTITY")
            end
            click_button "Verify your identity"
            expect(page).to have_content("Authorization required")
          end
        end
      end
    end
  end

  context "when the initiative requires user extra fields collection to be signed" do
    let(:initiative) do
      create(:initiative, :published, :with_user_extra_fields_collection, organization: organization)
    end

    context "when the user has not signed the initiative yet and signs it" do
      context "when the user has a verified user group" do
        let!(:user_group) { create :user_group, :verified, users: [confirmed_user], organization: confirmed_user.organization }

        it "votes as a user group" do
          vote_initiative(user_name: user_group.name)
        end

        it "votes as themselves" do
          vote_initiative(user_name: confirmed_user.name)
        end
      end

      it "adds the signature" do
        vote_initiative
      end

      it "vote is forbidden unless personal data is filled" do
        visit decidim_initiatives.initiative_path(initiative)

        within ".view-side" do
          expect(page).to have_content("0\nSIGNATURE")
          click_on "Sign"
        end
        click_button "Continue"

        expect(page).to have_content "error"

        visit decidim_initiatives.initiative_path(initiative)
        within ".view-side" do
          expect(page).to have_content("0\nSIGNATURE")
          click_on "Sign"
        end
      end
    end
  end

  def vote_initiative(user_name: nil)
    visit decidim_initiatives.initiative_path(initiative)

    within ".view-side" do
      expect(page).to have_content("0\nSIGNATURE")
      click_on "Sign"
    end

    if user_name.present?
      within "#user-identities" do
        click_on user_name
      end
    end

    if has_content?("Complete your data")
      fill_in :initiatives_vote_name_and_surname, with: confirmed_user.name
      fill_in :initiatives_vote_document_number, with: "012345678A"
      fill_in :initiatives_vote_date_of_birth, with: 30.years.ago
      fill_in :initiatives_vote_postal_code, with: "01234"

      click_button "Continue"
    end

    within ".view-side" do
      expect(page).to have_content("1\nSIGNATURE")
    end
  end
end
