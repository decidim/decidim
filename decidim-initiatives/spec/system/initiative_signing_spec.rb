# frozen_string_literal: true

require "spec_helper"

describe "Initiative signing" do
  let(:organization) { create(:organization, available_authorizations: authorizations) }
  let(:initiative) do
    create(:initiative, organization:)
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
      context "when initiative type only allows In-person signatures" do
        let(:initiative) { create(:initiative, organization:, signature_type: "offline") }

        it "voting disabled message is shown" do
          visit decidim_initiatives.initiative_path(initiative)

          expect(page).to have_content("Signing disabled")
        end

        it "shows the offline supports received" do
          initiative.update(offline_votes: { initiative.scoped_type.scope.id.to_s => 1357, "total" => 1357 })

          visit decidim_initiatives.initiative_path(initiative)

          expect(page).to have_content("1357 1000\nSignatures")
        end
      end
    end
  end

  context "when the user has signed the initiative and unsigns it" do
    context "when initiative type has unvotes disabled" do
      let(:initiatives_type) { create(:initiatives_type, :undo_online_signatures_disabled, organization:) }
      let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }
      let(:initiative) { create(:initiative, organization:, scoped_type: scope) }

      it "unsigning initiative is disabled" do
        vote_initiative

        within ".initiative__aside" do
          expect(page).to have_content(signature_text(1))
          expect(page).to have_button("Already signed", disabled: true)
          click_on("Already signed", disabled: true)
          expect(page).to have_content(signature_text(1))
        end
      end
    end

    it "removes the signature" do
      vote_initiative

      within ".initiative__aside" do
        expect(page).to have_content(signature_text(1))
        click_on("Already signed")
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

          within ".initiative__aside" do
            expect(page).to have_content("Sign")
            click_on "Sign"
          end

          expect(page).to have_content("You are almost ready to sign on the #{translated_attribute(initiative.title)} initiative")
          expect(page).to have_css("a[data-verification]", count: 2)
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

          within ".initiative__aside" do
            expect(page).to have_content(signature_text(1))
            expect(page).to have_button("Already signed", disabled: true)
            click_on("Already signed", disabled: true)
            expect(page).to have_content(signature_text(1))
          end
        end
      end
    end
  end

  context "when the initiative requires user extra fields collection to be signed" do
    let(:initiative) do
      create(:initiative, :with_user_extra_fields_collection, organization:)
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

      context "when the personal data is not filled" do
        it "does not allow voting" do
          visit decidim_initiatives.initiative_path(initiative)

          within ".initiative__aside" do
            expect(page).to have_content(signature_text(0))
            click_on "Sign"
          end
          click_on "Validate your data"

          expect(page).to have_content "error"

          visit decidim_initiatives.initiative_path(initiative)

          within ".initiative__aside" do
            expect(page).to have_content(signature_text(0))
            click_on "Sign"
          end
        end
      end
    end
  end

  def vote_initiative
    visit decidim_initiatives.initiative_path(initiative)

    within ".initiative__aside" do
      expect(page).to have_content(signature_text(0))
      click_on "Sign"
    end

    if has_content?("Verify with Dummy Signature Handler")
      fill_in :dummy_signature_handler_name_and_surname, with: confirmed_user.name
      select "Identification number", from: :dummy_signature_handler_document_type
      fill_in :dummy_signature_handler_document_number, with: "012345678X"
      fill_in_datepicker :dummy_signature_handler_date_of_birth_date, with: 30.years.ago.strftime("01/01/%Y")
      fill_in :dummy_signature_handler_postal_code, with: "01234"
      select translated_attribute(initiative.scope.name), from: :dummy_signature_handler_scope_id

      click_on "Validate your data"

      expect(page).to have_content("initiative has been successfully signed")
      click_on "Back to initiative"
    end

    within ".initiative__aside" do
      expect(page).to have_content(signature_text(1))
    end
  end

  def signature_text(number)
    return "1 #{initiative.supports_required}\nSignature" if number == 1

    "#{number} #{initiative.supports_required}\nSignatures"
  end
end
