# frozen_string_literal: true

require "spec_helper"

describe "Initiative", type: :system do
  let(:organization) { create(:organization) }
  let(:authorized_user) { create(:user, :confirmed, organization: organization) }

  context "when access to functionality" do
    before do
      switch_to_host(organization.host)

      create(:authorization, user: authorized_user)
      login_as authorized_user, scope: :user

      visit decidim_initiatives.initiatives_path
    end

    it "Initiatives page contains a create initiative button" do
      expect(page).to have_content("New initiative")
    end
  end

  context "when creates an initiative" do
    before do
      switch_to_host(organization.host)

      create(:authorization, user: authorized_user)
      login_as authorized_user, scope: :user

      visit decidim_initiatives.initiatives_path
    end

    context "without validation" do
      let(:initiative_type) { create(:initiatives_type, organization: organization) }
      let!(:other_initiative_type) { create(:initiatives_type, organization: organization) }
      let!(:initiative_type_scope) { create(:initiatives_type_scope, type: initiative_type) }

      before do
        switch_to_host(organization.host)
        create(:authorization, user: authorized_user)
        login_as authorized_user, scope: :user

        visit decidim_initiatives.create_initiative_path(id: :select_initiative_type)
      end

      context "and select initiative type" do
        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("Citizen initiatives are a means by which the citizenship can intervene so that the City Council can undertake actions in defence of the general interest that are within fields of municipal jurisdiction. Which initiative do you want to launch?")
          end
        end

        it "Shows the available initiative types" do
          within "main" do
            expect(page).to have_content(translated(initiative_type.title, locale: :en))
            expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative_type.description, locale: :en), tags: []))
          end
        end

        it "Do not show initiative types without related scopes" do
          within "main" do
            expect(page).not_to have_content(translated(other_initiative_type.title, locale: :en))
            expect(page).not_to have_content(ActionView::Base.full_sanitizer.sanitize(translated(other_initiative_type.description, locale: :en), tags: []))
          end
        end
      end

      context "and fill basic data" do
        before do
          find_button("Choose").click
        end

        it "Has a hidden field with the selected initiative type" do
          expect(page).to have_xpath("//input[@id='initiative_type_id']", visible: false)
          expect(find(:xpath, "//input[@id='initiative_type_id']", visible: false).value).to eq(initiative_type.id.to_s)
        end

        it "Have fields for title and description" do
          expect(page).to have_xpath("//input[@id='initiative_title']")
          expect(page).to have_xpath("//input[@id='initiative_description']", visible: false)
        end

        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("What does the initiative consist of? Write down the title and description. We recommend a short and concise title and a description focused on the proposed solution.")
          end
        end
      end

      context "when Show similar initiatives" do
        let!(:initiative) { create(:initiative, organization: organization) }

        before do
          find_button("Choose").click
          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click
        end

        it "Similar initiatives view is shown" do
          expect(page).to have_content("COMPARE")
        end

        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("If any of the following initiatives is similar to yours we encourage you to support it. Your proposal will have more possibilities to get done.")
          end
        end

        it "Contains data about the similar initiative found" do
          expect(page).to have_content(translated(initiative.title, locale: :en))
          expect(page).to have_content(ActionView::Base.full_sanitizer.sanitize(translated(initiative.description, locale: :en), tags: []))
          expect(page).to have_content(translated(initiative.type.title, locale: :en))
          expect(page).to have_content(translated(initiative.scope.name, locale: :en))
          expect(page).to have_content(initiative.author_name)
        end
      end

      context "when Create initiative" do
        let(:initiative) { build(:initiative) }

        before do
          find_button("Choose").click
          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click
        end

        it "Create view is shown" do
          expect(page).to have_content("CREATE")
        end

        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("Revise the content of your initiative. Is your title easy to understand? Is the objective of your initiative clear?")
            expect(page).to have_content("You have to choose the type of signature. In-person, online or a combination of both")
            expect(page).to have_content("Which is the geographic scope of the initiative? City, district?")
          end
        end

        it "Information collected in previous steps is already filled" do
          expect(find(:xpath, "//input[@id='initiative_type_id']", visible: false).value).to eq(initiative_type.id.to_s)
          expect(find(:xpath, "//input[@id='initiative_title']").value).to eq(translated(initiative.title, locale: :en))
          expect(find(:xpath, "//input[@id='initiative_description']", visible: false).value).to eq(translated(initiative.description, locale: :en))
        end
      end

      context "when Promotal committee" do
        let(:initiative) { build(:initiative) }

        before do
          find_button("Choose").click

          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click

          select("OnLine", from: "Signature type")
          select(translated(initiative_type_scope.scope.name, locale: :en), from: "Scope")
          find_button("Continue").click
        end

        it "promotal committee view is shown" do
          expect(page).to have_content("PROMOTAL COMMITTEE")
        end

        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("Citizen initiatives require a Promoting Commission consisting of at least three people (attestors). You must share the following link with the other people that are part of this initiative. When your contacts receive this link they will have to follow the indicated steps.")
          end
        end

        it "Contains a link to invite other users" do
          expect(page).to have_content("/committee_requests/new")
        end

        it "Contains a button to continue with next step" do
          expect(page).to have_content("Continue")
        end
      end

      context "when Finish" do
        let(:initiative) { build(:initiative) }

        before do
          find_button("Choose").click

          fill_in "Title", with: translated(initiative.title, locale: :en)
          fill_in_editor "initiative_description", with: translated(initiative.description, locale: :en)
          find_button("Continue").click

          select("OnLine", from: "Signature type")
          select(translated(initiative_type_scope.scope.name, locale: :en), from: "Scope")
          find_button("Continue").click

          find_link("Continue").click
        end

        it "finish view is shown" do
          expect(page).to have_content("FINISH")
        end

        it "Offers contextual help" do
          within ".callout.secondary" do
            expect(page).to have_content("Congratulations! Your citizen initiative has been created successfully.")
          end
        end
      end
    end
  end
end
