# frozen_string_literal: true

require "spec_helper"

describe "Initiative signing", type: :system do
  let(:organization) { create(:organization, available_authorizations: authorizations) }
  let(:initiative) do
    create(:initiative, :published, organization:)
  end
  let(:confirmed_user) { create(:user, :confirmed, organization:) }
  let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }

  before do
    allow(Decidim::Initiatives)
      .to receive(:do_not_require_authorization)
      .and_return(true)
    switch_to_host(organization.host)
    login_as confirmed_user, scope: :user
  end

  context "when the user has not signed the initiative" do
    context "when online signatures are enabled for site" do
      context "when initative type only allows In-person signatures" do
        let(:initiative) { create(:initiative, :published, organization:, signature_type: "offline") }

        it "voting disabled message is shown" do
          visit decidim_initiatives.initiative_path(initiative)

          expect(page).to have_content("SIGNING DISABLED")
        end

        it "shows the offline supports received" do
          initiative.update(offline_votes: { initiative.scoped_type.scope.id.to_s => 1357, "total" => 1357 })

          visit decidim_initiatives.initiative_path(initiative)

          expect(page).to have_content("1357/1000\nSIGNATURES")
        end
      end
    end
  end

  context "when the user has signed the initiative and unsigns it" do
    context "when initiative type has unvotes disabled" do
      let(:initiatives_type) { create(:initiatives_type, :undo_online_signatures_disabled, organization:) }
      let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }
      let(:initiative) { create(:initiative, :published, organization:, scoped_type: scope) }

      it "unsigning initiative is disabled" do
        vote_initiative

        within ".view-side" do
          expect(page).to have_content(signature_text(1))
          expect(page).to have_button("Already signed", disabled: true)
          click_button "Already signed", disabled: true
          expect(page).to have_content(signature_text(1))
        end
      end
    end

    it "removes the signature" do
      vote_initiative

      within ".view-side" do
        expect(page).to have_content(signature_text(1))
        click_button "Already signed"
        expect(page).to have_content(signature_text(0))
      end
    end
  end

  context "when the initiative type has permissions to vote" do
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
        it "signin initiative is disabled", :slow do
          visit decidim_initiatives.initiative_path(initiative)

          within ".view-side" do
            expect(page).to have_content("VERIFY YOUR ACCOUNT")
          end
          click_button "Verify your account"
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
        initiative.votes.create(author: confirmed_user, scope: initiative.scope)
      end

      context "and is not verified" do
        it "unsigning initiative is disabled" do
          visit decidim_initiatives.initiative_path(initiative)

          within ".view-side" do
            expect(page).to have_content(signature_text(1))
            expect(page).to have_button("Already signed", disabled: true)
            click_button "Already signed", disabled: true
            expect(page).to have_content(signature_text(1))
          end
        end
      end
    end
  end

  context "when the initiative requires user extra fields collection to be signed" do
    let(:initiative) do
      create(:initiative, :published, :with_user_extra_fields_collection, organization:)
    end

    context "when the user has not signed the initiative yet and signs it" do
      context "when the personal data is filled" do
        before do
          create(
            :authorization,
            :granted,
            name: "dummy_authorization_handler",
            user: confirmed_user,
            unique_id: "012345678X",
            metadata: { document_number: "012345678X", postal_code: "01234", scope_id: initiative.scope.id }
          )
        end

        it "adds the signature" do
          vote_initiative
        end
      end

      context "when the personal daata is not filled" do
        it "doesn't allow voting" do
          visit decidim_initiatives.initiative_path(initiative)

          within ".view-side" do
            expect(page).to have_content(signature_text(0))
            click_on "Sign"
          end
          click_button "Continue"

          expect(page).to have_content "error"

          visit decidim_initiatives.initiative_path(initiative)

          within ".view-side" do
            expect(page).to have_content(signature_text(0))
            click_on "Sign"
          end
        end
      end
    end
  end

  def vote_initiative
    visit decidim_initiatives.initiative_path(initiative)

    within ".view-side" do
      expect(page).to have_content(signature_text(0))
      click_on "Sign"
    end

    if has_content?("Complete your data")
      fill_in :initiatives_vote_name_and_surname, with: confirmed_user.name
      fill_in :initiatives_vote_document_number, with: "012345678X"
      select 30.years.ago.year.to_s, from: :initiatives_vote_date_of_birth_1i
      select "January", from: :initiatives_vote_date_of_birth_2i
      select "1", from: :initiatives_vote_date_of_birth_3i
      fill_in :initiatives_vote_postal_code, with: "01234"

      click_button "Continue"

      expect(page).to have_content("initiative has been successfully signed")
      click_on "Back to initiative"
    end

    within ".view-side" do
      expect(page).to have_content(signature_text(1))
    end
  end

  def signature_text(number)
    return "1/#{initiative.supports_required}\nSIGNATURE" if number == 1

    "#{number}/#{initiative.supports_required}\nSIGNATURES"
  end
end
