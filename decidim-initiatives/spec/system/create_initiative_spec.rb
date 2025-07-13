# frozen_string_literal: true

require "spec_helper"

describe "Initiative" do
  let(:organization) { create(:organization, available_authorizations: authorizations) }
  let(:do_not_require_authorization) { true }
  let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
  let!(:authorized_user) { create(:user, :confirmed, organization:) }
  let!(:authorization) { create(:authorization, user: authorized_user) }
  let(:login) { true }
  let(:initiative_type_minimum_committee_members) { 2 }
  let(:signature_type) { "any" }
  let(:initiative_type_promoting_committee_enabled) { true }
  let(:initiative_type) do
    create(:initiatives_type, :attachments_enabled,
           organization:,
           minimum_committee_members: initiative_type_minimum_committee_members,
           promoting_committee_enabled: initiative_type_promoting_committee_enabled,
           signature_type:)
  end
  let!(:initiative_type_scope) { create(:initiatives_type_scope, type: initiative_type) }
  let!(:initiative_type_scope2) { create(:initiatives_type_scope, type: initiative_type) }
  let!(:other_initiative_type) { create(:initiatives_type, :attachments_enabled, organization:) }
  let!(:other_initiative_type_scope) { create(:initiatives_type_scope, type: other_initiative_type) }
  let(:third_initiative_type) { create(:initiatives_type, :attachments_enabled, organization:) }

  shared_examples "initiatives path redirection" do
    it "redirects to initiatives path" do
      accept_confirm do
        click_on("Send to technical validation")
      end

      expect(page).to have_current_path("/initiatives")
    end
  end

  before do
    switch_to_host(organization.host)
    login_as(authorized_user, scope: :user) if authorized_user && login
    visit decidim_initiatives.initiatives_path
    allow(Decidim::Initiatives.config).to receive(:do_not_require_authorization).and_return(do_not_require_authorization)
  end

  context "when user visits the initiatives wizard and is not logged in" do
    let(:login) { false }
    let(:do_not_require_authorization) { false }
    let(:signature_type) { "online" }

    context "when there is only one initiative type" do
      let!(:other_initiative_type) { nil }
      let!(:other_initiative_type_scope) { nil }

      [
        :select_initiative_type,
        :fill_data,
        :promotal_committee,
        :finish
      ].each do |step|
        it "redirects to the login page when landing on #{step}" do
          expect(Decidim::InitiativesType.count).to eq(1)
          visit decidim_initiatives.create_initiative_path(step)
          expect(page).to have_current_path("/users/sign_in")
        end
      end
    end

    context "when there are more initiative types" do
      [
        :select_initiative_type,
        :fill_data,
        :promotal_committee,
        :finish
      ].each do |step|
        it "redirects to the login page when landing on #{step}" do
          expect(Decidim::InitiativesType.count).to eq(2)
          visit decidim_initiatives.create_initiative_path(step)
          expect(page).to have_current_path("/users/sign_in")
        end
      end
    end
  end

  context "when user requests a page not having all the data required" do
    let(:do_not_require_authorization) { false }
    let(:signature_type) { "online" }

    context "when there is only one initiative type" do
      let!(:other_initiative_type) { nil }
      let!(:other_initiative_type_scope) { nil }

      [
        :select_initiative_type,
        :fill_data,
        :promotal_committee,
        :finish
      ].each do |step|
        it "redirects to the previous_form page when landing on #{step}" do
          expect(Decidim::InitiativesType.count).to eq(1)
          visit decidim_initiatives.create_initiative_path(step)
          expect(page).to have_current_path(decidim_initiatives.create_initiative_path(:fill_data))
        end
      end
    end

    context "when there are more initiative types" do
      [
        :fill_data,
        :promotal_committee,
        :finish
      ].each do |step|
        it "redirects to the select_initiative_type page when landing on #{step}" do
          expect(Decidim::InitiativesType.count).to eq(2)
          visit decidim_initiatives.create_initiative_path(step)
          expect(page).to have_current_path(decidim_initiatives.create_initiative_path(:select_initiative_type))
        end
      end
    end
  end

  describe "create initiative verification" do
    context "when there is just one initiative type" do
      let!(:other_initiative_type) { nil }
      let!(:other_initiative_type_scope) { nil }

      context "when the user is logged in" do
        context "and they do not need to be verified" do
          it "they are taken to the initiative form" do
            click_on "New initiative"
            expect(page).to have_content("Create a new initiative")
          end
        end

        context "and creation require a verification" do
          before do
            allow(Decidim::Initiatives.config).to receive(:do_not_require_authorization).and_return(false)
            visit decidim_initiatives.initiatives_path
          end

          context "and they are verified" do
            it "they are taken to the initiative form" do
              click_on "New initiative"
              expect(page).to have_content("Create a new initiative")
            end
          end

          context "and they are not verified" do
            let(:authorization) { nil }

            it "they need to verify" do
              click_on "New initiative"
              expect(page).to have_content("Authorization required")
            end

            it "they are redirected to the initiative form after verifying" do
              click_on "New initiative"
              click_on "View authorizations"
              click_on(text: /Example authorization/)
              fill_in "Document number", with: "123456789X"
              click_on "Send"
              expect(page).to have_content("Review the content of your initiative.")
            end
          end
        end

        context "and an authorization handler has been activated" do
          before do
            initiative_type.create_resource_permission(
              permissions: {
                "create" => {
                  "authorization_handlers" => {
                    "dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }
            )
            visit decidim_initiatives.initiatives_path
          end

          let(:authorization) { nil }

          it "they need to verify" do
            click_on "New initiative"
            expect(page).to have_content("We need to verify your identity")
          end

          it "they are authorized to create after verifying" do
            click_on "New initiative"
            fill_in "Document number", with: "123456789X"
            click_on "Send"
            expect(page).to have_content("Review the content of your initiative. ")
          end
        end
      end

      context "when they are not logged in" do
        let(:login) { false }

        it "they need to login in" do
          click_on "New initiative"
          expect(page).to have_content("Please log in")
        end

        context "when they do not need to be verified" do
          it "they are redirected to the initiative form after log in" do
            click_on "New initiative"
            within "#loginModal" do
              fill_in "Email", with: authorized_user.email
              fill_in "Password", with: "decidim123456789"
              click_on "Log in"
            end

            expect(page).to have_content("Create a new initiative")
          end
        end

        context "and creation require a verification" do
          before do
            allow(Decidim::Initiatives.config).to receive(:do_not_require_authorization).and_return(false)
          end

          context "and they are verified" do
            it "they are redirected to the initiative form after log in" do
              click_on "New initiative"
              within "#loginModal" do
                fill_in "Email", with: authorized_user.email
                fill_in "Password", with: "decidim123456789"
                click_on "Log in"
              end

              expect(page).to have_content("Create a new initiative")
            end
          end

          context "and they are not verified" do
            let(:authorization) { nil }

            it "they are shown an error" do
              click_on "New initiative"
              within "#loginModal" do
                fill_in "Email", with: authorized_user.email
                fill_in "Password", with: "decidim123456789"
                click_on "Log in"
              end

              expect(page).to have_content("You are not authorized to perform this action")
            end
          end
        end

        context "and an authorization handler has been activated" do
          before do
            initiative_type.create_resource_permission(
              permissions: {
                "create" => {
                  "authorization_handlers" => {
                    "dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }
            )
            visit decidim_initiatives.initiatives_path
          end

          let(:authorization) { nil }

          it "they are redirected to authorization form page" do
            click_on "New initiative"
            within "#loginModal" do
              fill_in "Email", with: authorized_user.email
              fill_in "Password", with: "decidim123456789"
              click_on "Log in"
            end

            expect(page).to have_content("We need to verify your identity")
            expect(page).to have_content("Verify with Example authorization")
          end
        end

        context "and more than one authorization handlers has been activated" do
          before do
            initiative_type.create_resource_permission(
              permissions: {
                "create" => {
                  "authorization_handlers" => {
                    "dummy_authorization_handler" => { "options" => {} },
                    "another_dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }
            )
            visit decidim_initiatives.initiatives_path
          end

          let(:authorization) { nil }

          it "they are redirected to pending onboarding authorizations page" do
            click_on "New initiative"
            within "#loginModal" do
              fill_in "Email", with: authorized_user.email
              fill_in "Password", with: "decidim123456789"
              click_on "Log in"
            end

            expect(page).to have_content("You are almost ready to create an initiative")
            expect(page).to have_css("a[data-verification]", count: 2)
          end
        end
      end
    end

    context "when there are multiples initiative type" do
      context "when the user is logged in" do
        context "and they do not need to be verified" do
          it "they are taken to the initiative form" do
            click_on "New initiative"
            expect(page).to have_content("Which initiative do you want to launch")
          end
        end

        context "and creation require a verification" do
          before do
            allow(Decidim::Initiatives.config).to receive(:do_not_require_authorization).and_return(false)
          end

          context "and they are verified" do
            it "they are taken to the initiative form" do
              click_on "New initiative"
              expect(page).to have_content("Which initiative do you want to launch")
            end
          end

          context "and they are not verified" do
            let(:authorization) { nil }

            it "they need to verify" do
              click_on "New initiative"
              expect(page).to have_css("a[data-dialog-open=not-authorized-modal]", visible: :all, count: 2)
            end

            it "they are redirected to the initiative form after verifying" do
              click_on "New initiative"
              within "#radio-accordion-#{initiative_type.id}" do
                click_on "Show more"
                click_on "Verify your account to promote this initiative", match: :first
              end
              click_on "View authorizations"
              click_on(text: /Example authorization/)
              fill_in "Document number", with: "123456789X"
              click_on "Send"
              expect(page).to have_content("Which initiative do you want to launch")
            end
          end
        end

        context "and an authorization handler has been activated on the first initiative type" do
          before do
            initiative_type.create_resource_permission(
              permissions: {
                "create" => {
                  "authorization_handlers" => {
                    "dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }
            )
            visit decidim_initiatives.initiatives_path
          end

          let(:authorization) { nil }

          it "they need to verify" do
            click_on "New initiative"
            within "#radio-accordion-#{initiative_type.id}" do
              click_on "Show more"
              click_on "Verify your account to promote this initiative", match: :first
            end
            expect(page).to have_content("We need to verify your identity")
          end

          it "they are authorized to create after verifying" do
            click_on "New initiative"
            within "#radio-accordion-#{initiative_type.id}" do
              click_on "Show more"
              click_on "Verify your account to promote this initiative", match: :first
            end
            fill_in "Document number", with: "123456789X"
            click_on "Send"
            expect(page).to have_content("Review the content of your initiative.")
          end
        end
      end

      context "when they are not logged in" do
        let(:login) { false }

        it "they need to login in" do
          click_on "New initiative"
          expect(page).to have_content("Please log in")
        end

        context "when they do not need to be verified" do
          it "they are redirected to the initiative form after log in" do
            click_on "New initiative"
            within "#loginModal" do
              fill_in "Email", with: authorized_user.email
              fill_in "Password", with: "decidim123456789"
              click_on "Log in"
            end

            expect(page).to have_content("Which initiative do you want to launch")
          end
        end

        context "and creation require a verification" do
          before do
            allow(Decidim::Initiatives.config).to receive(:do_not_require_authorization).and_return(false)
          end

          context "and they are verified" do
            it "they are redirected to the initiative form after log in" do
              click_on "New initiative"
              within "#loginModal" do
                fill_in "Email", with: authorized_user.email
                fill_in "Password", with: "decidim123456789"
                click_on "Log in"
              end

              expect(page).to have_content("Which initiative do you want to launch")
            end
          end

          context "and they are not verified" do
            let(:authorization) { nil }

            it "they are shown an error" do
              click_on "New initiative"
              within "#loginModal" do
                fill_in "Email", with: authorized_user.email
                fill_in "Password", with: "decidim123456789"
                click_on "Log in"
              end

              expect(page).to have_css("a[data-dialog-open=not-authorized-modal]", visible: :all, count: 2)
            end
          end
        end

        context "and an authorization handler has been activated" do
          before do
            initiative_type.create_resource_permission(
              permissions: {
                "create" => {
                  "authorization_handlers" => {
                    "dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }
            )
            visit decidim_initiatives.initiatives_path
          end

          let(:authorization) { nil }

          it "they are redirected to the initiative form after log in but need to verify" do
            click_on "New initiative"
            within "#loginModal" do
              fill_in "Email", with: authorized_user.email
              fill_in "Password", with: "decidim123456789"
              click_on "Log in"
            end

            expect(page).to have_content("Create a new initiative")
            within "#radio-accordion-#{initiative_type.id}" do
              click_on "Show more"
              click_on "Verify your account to promote this initiative", match: :first
            end
            expect(page).to have_content("We need to verify your identity")
          end
        end
      end
    end
  end

  context "when rich text editor is enabled for participants" do
    before do
      organization.update(rich_text_editor_in_public_views: true)
      click_on "New initiative"
      first("input.radio-accordion-radio").click
      click_on "Continue"
    end

    it_behaves_like "having a rich text editor", "new_initiative_form", "content"
  end

  describe "creating an initiative" do
    context "without validation" do
      before do
        click_on "New initiative"
      end

      context "and select initiative type" do
        it "offers contextual help" do
          within ".flash.secondary" do
            expect(page).to have_content("Initiatives are a means by which the participants can intervene so that the organization can undertake actions in defence of the general interest. Which initiative do you want to launch?")
          end
        end

        it "shows the available initiative types" do
          within "[data-content]" do
            expect(page).to have_content(translated(initiative_type.title, locale: :en))

            within "#radio-accordion-#{initiative_type.id}" do
              click_on "Show more"
              expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative_type.description, locale: :en), tags: []))
            end
          end
        end

        it "do not show initiative types without related scopes" do
          within "[data-content]" do
            expect(page).to have_no_content(translated(third_initiative_type.title, locale: :en))
            expect(page).to have_no_content(ActionView::Base.full_sanitizer.sanitize(translated(third_initiative_type.description, locale: :en), tags: []))
          end
        end
      end

      context "and fill basic data" do
        before do
          first("input.radio-accordion-radio").click
          click_on "Continue"
        end

        it "does not show the select input for initiative_type" do
          expect(page).to have_no_content("Type")
          expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
        end

        it "have fields for title and description" do
          expect(page).to have_xpath("//input[@id='initiative_title']")
          expect(page).to have_xpath("//textarea[@id='initiative_description']", visible: :all)
        end

        it "does not have status field" do
          expect(page).to have_no_xpath("//select[@id='initiative_state']")
        end

        it "offers contextual help" do
          within ".flash.secondary" do
            expect(page).to have_content("Review the content of your initiative.")
          end
        end
      end

      context "when there is only one initiative type" do
        let!(:other_initiative_type) { nil }
        let!(:other_initiative_type_scope) { nil }

        it "does not displays initiative types" do
          expect(page).to have_no_current_path(decidim_initiatives.create_initiative_path(id: :select_initiative_type))
        end

        it "does not display the 'choose' step" do
          within ".wizard-steps" do
            expect(page).to have_no_content("Choose")
          end
        end

        it "has a hidden field with the selected initiative type" do
          expect(page).to have_xpath("//input[@id='initiative_type_id']", visible: :all)
          expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
        end

        it "have fields for title and description" do
          expect(page).to have_xpath("//input[@id='initiative_title']")
          expect(page).to have_xpath("//textarea[@id='initiative_description']", visible: :all)
        end

        it "does not have status field" do
          expect(page).to have_no_xpath("//select[@id='initiative_state']")
        end

        it "offers contextual help" do
          within ".flash.secondary" do
            expect(page).to have_content("Review the content of your initiative.")
          end
        end
      end

      context "when create initiative" do
        let(:initiative) { build(:initiative) }

        context "when only one signature collection and scope are available" do
          let(:signature_type) { "offline" }
          let!(:other_initiative_type) { nil }
          let!(:other_initiative_type_scope) { nil }
          let(:initiative_type_scope2) { nil }
          let(:initiative_type) { create(:initiatives_type, organization:, minimum_committee_members: initiative_type_minimum_committee_members, signature_type:) }

          it "hides and automatically selects the values" do
            expect(page).to have_no_content("Signature collection type")
            expect(page).to have_no_content("Scope")
            expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
            expect(find(:xpath, "//input[@id='initiative_signature_type']", visible: :all).value).to eq("offline")
          end
        end

        context "when there is only one initiative type" do
          let!(:other_initiative_type) { nil }
          let!(:other_initiative_type_scope) { nil }

          before do
            fill_in "Title", with: translated(initiative.title, locale: :en)
            fill_in "initiative_description", with: translated(initiative.description, locale: :en)
            find_button("Continue").click
          end

          it "does not show select input for initiative_type" do
            expect(page).to have_no_content("Initiative type")
            expect(page).to have_no_css("#initiative_type_id")
          end

          it "has a hidden field with the selected initiative type" do
            expect(page).to have_xpath("//input[@id='initiative_type_id']", visible: :all)
            expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
          end
        end

        context "when there are several initiative types" do
          before do
            first("input.radio-accordion-radio").click
            click_on "Continue"
          end

          it "create view is shown" do
            expect(page).to have_content("Create")
          end

          it "offers contextual help" do
            within ".flash.secondary" do
              expect(page).to have_content("Review the content of your initiative. Is your title easy to understand? Is the objective of your initiative clear?")
              expect(page).to have_content("You have to choose the type of signature. In-person, online or a combination of both")
              expect(page).to have_content("Which is the geographic scope of the initiative?")
            end
          end

          it "does not show the select input for initiative_type" do
            expect(page).to have_no_content("Type")
            expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
          end

          it "shows input for signature collection type" do
            expect(page).to have_content("Signature collection type")
            expect(find(:xpath, "//select[@id='initiative_signature_type']", visible: :all).value).to eq(initiative_type.signature_type)
          end

          context "when only one signature collection and scope are available" do
            let(:initiative_type_scope2) { nil }
            let(:initiative_type) { create(:initiatives_type, organization:, minimum_committee_members: initiative_type_minimum_committee_members, signature_type: "offline") }

            it "hides and automatically selects the values" do
              expect(page).to have_no_content("Signature collection type")
              expect(page).to have_no_content("Scope")
              expect(find(:xpath, "//input[@id='initiative_type_id']", visible: :all).value).to eq(initiative_type.id.to_s)
              expect(find(:xpath, "//input[@id='initiative_signature_type']", visible: :all).value).to eq("offline")
            end
          end

          context "when the scope is not selected" do
            it "shows an error" do
              select("Online", from: "Signature collection type")
              find_button("Continue").click

              expect_blank_field_validation_message("#initiative_scope_id", type: :select)
            end
          end

          context "when the initiative type does not enable custom signature end date" do
            it "does not show the signature end date" do
              expect(page).to have_no_content("End of signature collection period")
            end
          end

          context "when the initiative type enables custom signature end date" do
            let(:signature_type) { "offline" }
            let(:initiative_type) { create(:initiatives_type, :custom_signature_end_date_enabled, organization:, minimum_committee_members: initiative_type_minimum_committee_members, signature_type:) }

            it "shows the signature end date" do
              expect(page).to have_content("End of signature collection period")
            end
          end

          context "when the initiative type does not enable area" do
            it "does not show the area" do
              expect(page).to have_no_content("Area")
            end
          end

          context "when the initiative type enables area" do
            let(:signature_type) { "offline" }
            let(:initiative_type) { create(:initiatives_type, :area_enabled, organization:, minimum_committee_members: initiative_type_minimum_committee_members, signature_type:) }

            it "shows the area" do
              expect(page).to have_content("Area")
            end
          end

          context "when rich text editor is enabled for participants" do
            before do
              expect(page).to have_content("Create")
              organization.update(rich_text_editor_in_public_views: true)

              visit current_path
            end

            it_behaves_like "having a rich text editor", "new_initiative_form", "content"
          end
        end
      end

      context "when there is a promoter committee" do
        let(:initiative) { build(:initiative, organization:, scoped_type: initiative_type_scope) }

        before do
          first("input.radio-accordion-radio").click
          click_on "Continue"

          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in "initiative_description", with: translated(initiative.description, locale: :en)
          select("Online", from: "Signature collection type")
          select(translated(initiative_type_scope&.scope&.name, locale: :en), from: "Scope")
          find_button("Continue").click
        end

        it "shows the promoter committee" do
          expect(page).to have_content("Promoters Committee")
        end

        it "offers contextual help" do
          within "[data-content]" do
            expect(page).to have_content("This type of citizen initiative requires a promoter committee composed of at least #{initiative_type_minimum_committee_members} members (certifiers). You must share the following link with the other people who are part of this initiative. When your contacts receive this link, they will have to follow the indicated steps.")
          end
        end

        it "contains a link to invite other users" do
          expect(page).to have_content("/committee_requests/new")
        end

        it "contains a button to continue with next step" do
          expect(page).to have_content("Send to technical validation")
        end

        context "when minimum committee size is zero" do
          let(:initiative_type_minimum_committee_members) { 0 }

          it "skips to next step" do
            within("#wizard-steps [data-active]") do
              expect(page).to have_no_content("Promoters Committee")
              expect(page).to have_content("Technical validation")
            end
          end
        end

        context "and it is disabled at the type scope" do
          let(:initiative_type) { create(:initiatives_type, organization:, promoting_committee_enabled: false, signature_type:) }

          it "skips the promoting committee settings" do
            expect(page).to have_no_content("Promoters Committee")
            expect(page).to have_content("Send to technical validation")
          end
        end
      end

      context "when finish" do
        let(:initiative) { build(:initiative) }
        let(:initiative_type_minimum_committee_members) { 0 }

        before do
          within "#radio-accordion-#{initiative_type.id}" do
            first("input.radio-accordion-radio").click
          end
          click_on "Continue"

          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in "initiative_description", with: translated(initiative.description, locale: :en)
          select("Online", from: "Signature collection type")
          select(translated(initiative_type_scope&.scope&.name, locale: :en), from: "Scope")
          dynamically_attach_file(:initiative_documents, Decidim::Dev.asset("Exampledocument.pdf"))
          dynamically_attach_file(:initiative_photos, Decidim::Dev.asset("avatar.jpg"))
          find_button("Continue").click
          expect(page).to have_content("Your initiative has been successfully created.")
        end

        it "saves the attachments" do
          expect(Decidim::Initiative.last.documents.count).to eq(1)
          expect(Decidim::Initiative.last.photos.count).to eq(1)
        end

        context "when minimum committee size is above zero" do
          before do
            find_link("Send to technical validation").click
            click_on "OK"
          end

          it "Offers contextual help" do
            expect(page).to have_content("The initiative has been sent to technical validation.")
          end
        end
      end

      context "when minimum committee size is zero" do
        let(:initiative) { build(:initiative, organization:, scoped_type: initiative_type_scope) }
        let(:initiative_type_minimum_committee_members) { 0 }
        let(:expected_message) { "You are going to send the initiative for an admin to review it and publish it. Once published you will not be able to edit it. Are you sure?" }

        before do
          first("input.radio-accordion-radio").click
          click_on "Continue"

          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in "initiative_description", with: translated(initiative.description, locale: :en)
          select("Online", from: "Signature collection type")
          select(translated(initiative_type_scope&.scope&.name, locale: :en), from: "Scope")
          find_button("Continue").click
        end

        it "displays a send to technical validation link" do
          expect(page).to have_link("Send to technical validation")
          expect(page).to have_css "a[data-confirm='#{expected_message}']"
        end

        it_behaves_like "initiatives path redirection"
      end

      context "when promoting committee is not enabled" do
        let(:initiative) { build(:initiative, organization:, scoped_type: initiative_type_scope) }
        let(:initiative_type_promoting_committee_enabled) { false }
        let(:initiative_type_minimum_committee_members) { 0 }
        let(:expected_message) { "You are going to send the initiative for an admin to review it and publish it. Once published you will not be able to edit it. Are you sure?" }

        before do
          first("input.radio-accordion-radio").click
          click_on "Continue"

          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in "initiative_description", with: translated(initiative.description, locale: :en)
          select("Online", from: "Signature collection type")
          select(translated(initiative_type_scope&.scope&.name, locale: :en), from: "Scope")
          find_button("Continue").click
        end

        it "displays a send to technical validation link" do
          expect(page).to have_link("Send to technical validation")
          expect(page).to have_css "a[data-confirm='#{expected_message}']"
        end

        it_behaves_like "initiatives path redirection"
      end
    end
  end
end
