# frozen_string_literal: true

shared_examples "manage impersonations examples" do
  include ActiveSupport::Testing::TimeHelpers

  let(:organization) { create(:organization, available_authorizations:) }
  let(:available_authorizations) { ["dummy_authorization_handler"] }
  let(:document_number) { "123456789X" }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the organization does not have any authorization available" do
    let(:available_authorizations) { [] }

    it "the managed users page displays a warning and creation is disabled" do
      navigate_to_impersonations_page

      expect(page).to have_content("You need at least one authorization enabled for this organization.")
    end
  end

  shared_examples_for "creating a managed user" do
    let(:name) { "Rigoberto" }

    before do
      navigate_to_impersonations_page

      click_on "Manage new participant"

      fill_in_the_impersonation_form(document_number, name:)
    end

    it "shows a success message" do
      expect(page).to have_content("successfully")
    end

    context "when no name is provided" do
      let(:name) { "" }

      it "shows a validation error message" do
        expect(page).to have_no_content("successfully")
        expect(page).to have_content("There are errors on the form")
      end
    end

    context "when authorization data is invalid" do
      let(:document_number) { "123456789Y" }

      it "shows the errors in the form" do
        expect(page).to have_css("label", text: "Document number*\nRequired field\nis invalid")
      end
    end

    it_behaves_like "impersonating a user" do
      let(:impersonated_user) { Decidim::User.managed.last }
    end
  end

  shared_examples_for "impersonating a user" do
    it "can impersonate the user filling in the correct authorization" do
      expect(page).to have_content("You are managing the participant #{impersonated_user.name}")
      expect(page).to have_content("Your session will expire in #{Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES} minutes")
    end

    context "when performing an authorized action" do
      let(:available_authorizations) do
        %w(dummy_authorization_handler another_dummy_authorization_handler)
      end

      let(:participatory_space) do
        create(:participatory_process, organization:)
      end

      let(:component) do
        create(
          :component,
          participatory_space:,
          permissions: {
            "foo" => {
              "authorization_handlers" => {
                authorization_handler => {}
              }
            }
          }
        )
      end

      let(:dummy_resource) { create(:dummy_resource, component:) }

      before do
        visit resource_locator(dummy_resource).path
        click_on "Foo"
      end

      context "and the action allowed by the handler used to impersonate" do
        let(:authorization_handler) { "dummy_authorization_handler" }

        it "grants access" do
          expect(page).to have_current_path(/foo/)
        end
      end

      context "and the action not allowed by the handler used to impersonate", :slow do
        let(:authorization_handler) { "another_dummy_authorization_handler" }

        it "redirects to the authorization form" do
          expect(page).to have_content("We need to verify your identity")
          expect(page).to have_content("Verify with Another example authorization")
        end
      end
    end

    it "closes the current session and check the logs" do
      click_on "Close session"

      expect(page).to have_content("successfully")

      check_impersonation_logs
    end

    it "spends all the session time and is redirected automatically" do
      simulate_session_expiration

      visit decidim.root_path

      expect(page).to have_content("expired")

      check_impersonation_logs
    end

    it "redirects normally when session expires while reload" do
      expect(Decidim::Admin::ExpireImpersonationJob).to have_been_enqueued.with(impersonated_user, user)
      travel Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes / 2
      visit current_path
      travel (Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes / 2) + 1.second
      visit current_path
      expect(page).to have_content("expired")

      within "tr", text: impersonated_user.name do
        find("button[data-component='dropdown']").click
        expect(page).to have_link("Impersonate")
      end
    end

    it "can impersonate again after an impersonation session expiration" do
      simulate_session_expiration

      navigate_to_impersonations_page

      within "tr", text: impersonated_user.name do
        find("button[data-component='dropdown']").click
        expect(page).to have_link("Impersonate")
      end
    end
  end

  context "when a single authorization handler enabled" do
    it_behaves_like "creating a managed user"

    it "does not offer authorization handler selection" do
      navigate_to_impersonations_page
      click_on "Manage new participant"

      expect(page).to have_no_select("Authorization method")
    end
  end

  context "when more than one authorization handler enabled" do
    let(:available_authorizations) do
      %w(dummy_authorization_handler another_dummy_authorization_handler)
    end

    it_behaves_like "creating a managed user"

    it "allows selecting the preferred authorization handler" do
      navigate_to_impersonations_page

      click_on "Manage new participant"
      expect(page).to have_select("Authorization method")
      expect(page).to have_field("Document number").and have_no_field("Passport number")

      select "Another example authorization", from: "Authorization method"
      expect(page).to have_no_field("Document number").and have_field("Passport number")
    end
  end

  describe "impersonation" do
    let!(:impersonated_user) do
      create(:user, managed:, name: "Rigoberto", organization:)
    end

    context "when impersonating a previously authorized user" do
      let!(:authorization) { create(:authorization, user: impersonated_user, name: "dummy_authorization_handler") }

      let(:managed) { false }

      before do
        impersonate(impersonated_user, reason: "Because yes")
      end

      it_behaves_like "impersonating a user"
    end

    context "when impersonating a never authorized user" do
      let(:reason) { nil }

      before do
        impersonate(impersonated_user, reason:)
      end

      context "and it is a managed user" do
        let(:managed) { true }

        it_behaves_like "impersonating a user"
      end

      context "and its a regular user" do
        let(:managed) { false }

        context "and no reason is provided" do
          it "prevents submissions and shows an error" do
            expect(page).to have_content("You need to provide a reason when managing a non-managed participant")
          end
        end

        context "and a reason is provided" do
          let(:reason) do
            "We are on a meeting and want to do a collaborative session in the pope's name."
          end

          it_behaves_like "impersonating a user"

          it "saves the reason in the impersonation logs" do
            click_on "Close session"
            expect(page).to have_content("successfully")

            check_impersonation_logs
            expect(page).to have_content("We are on a meeting and want to do a collaborative session in the pope's name.")
          end
        end
      end
    end
  end

  context "when a managed user already exists" do
    let!(:managed_user) { create(:user, :managed, name: "Rigoberto", organization:) }
    let!(:authorization) { create(:authorization, user: managed_user, name: "dummy_authorization_handler", unique_id: "123456789X") }

    it_behaves_like "creating a managed user"

    it "can promote users inviting them to the application" do
      navigate_to_impersonations_page

      within "tr", text: managed_user.name do
        find("button[data-component='dropdown']").click
        click_on "Promote"
      end

      within ".item__edit form" do
        fill_in :managed_user_promotion_email, with: "foo@example.org"
      end

      perform_enqueued_jobs { click_on "Promote" }

      expect(page).to have_content("successfully")
      expect(page).to have_content(managed_user.name)

      logout :user

      visit last_email_link

      within "form.new_user" do
        fill_in :invitation_user_password, with: "decidim123456789"
        check :invitation_user_tos_agreement
        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")
      within_user_menu do
        click_on "My public profile"
      end

      expect(page).to have_content(managed_user.name)

      relogin_as user

      navigate_to_impersonations_page

      within "tr", text: managed_user.name do
        find("button[data-component='dropdown']").click
        expect(page).to have_no_link("Promote")
      end
    end
  end

  describe "verifications conflicts" do
    context "when have verifications conflicts in current organization" do
      let(:managed_user) { create(:user, :managed, organization:) }
      let(:current_user) { create(:user, name: "Rigoberto", organization:) }
      let!(:conflict) { create(:conflict, current_user:, managed_user:) }

      it "show only verifications of current organization" do
        navigate_to_impersonations_page
        within_admin_sidebar_menu do
          click_on "Verification conflicts"
        end

        expect(page).to have_content("Rigoberto")
      end
    end

    context "when have verifications conflicts in other organization" do
      let(:other_organization) { create(:organization, available_authorizations:) }
      let(:current_user) { create(:user, name: "Rigoberto", organization: other_organization) }
      let(:managed_user) { create(:user, :managed, organization: other_organization) }
      let!(:conflict) { create(:conflict, current_user:, managed_user:) }

      it "show only verifications of current organization" do
        navigate_to_impersonations_page
        within_admin_sidebar_menu do
          click_on "Verification conflicts"
        end

        expect(page).to have_no_content("Rigoberto")
      end
    end
  end

  private

  def fill_in_the_impersonation_form(document_number, name: nil, reason: nil)
    within "form.new_impersonation" do
      fill_in(:impersonate_user_name, with: name) if name
      fill_in(:impersonate_user_reason, with: reason) if reason
      fill_in :impersonate_user_authorization_document_number, with: document_number
      fill_in :impersonate_user_authorization_postal_code, with: "08224"
      fill_in_datepicker :impersonate_user_authorization_birthday_date, with: Time.new.utc.strftime("%d/%m/%Y")
    end

    within "[data-content]" do
      expect(page).to have_css("*[type=submit]", count: 1)

      click_on "Impersonate"
    end
  end

  def impersonate(user, reason: nil)
    navigate_to_impersonations_page

    within "tr", text: user.name do
      find("button[data-component='dropdown']").click
      click_on "Impersonate"
    end

    fill_in_the_impersonation_form("123456789X", reason:)
  end

  def simulate_session_expiration
    expect(Decidim::Admin::ExpireImpersonationJob).to have_been_enqueued.with(impersonated_user, user)
    session_time = Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes
    first_travel_time = session_time.even? ? session_time / 2 : (session_time / 2) + 1
    travel first_travel_time
    # Simulates as if the user were doing something during a impersonated session to prevent a timeout warning popup
    visit current_path
    travel session_time / 2
    Decidim::Admin::ExpireImpersonationJob.perform_now(impersonated_user, user)
  end

  def check_impersonation_logs
    within "tr", text: impersonated_user.name do
      find("button[data-component='dropdown']").click
      click_on "View logs"
    end

    expect(page).to have_css("tbody tr", count: 1)
  end
end
