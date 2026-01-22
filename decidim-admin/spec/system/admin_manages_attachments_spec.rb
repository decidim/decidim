# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe "Admin manages attachments" do
    let(:organization) { create(:organization) }
    let!(:user) do
      create(
        :user,
        :confirmed,
        :admin,
        organization:
      )
    end
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:attachment) { create(:attachment, attached_to: participatory_process) }

    let(:form) do
      instance_double(
        AttachmentForm,
        title: {
          en: "An image",
          ca: "Una imatge",
          es: "Una imagen"
        },
        description: {
          en: "A city",
          ca: "Una ciutat",
          es: "Una ciudad"
        },
        file:,
        link: nil,
        attachment_collection: nil,
        current_user: user,
        weight: 2
      )
    end
    let(:file) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
    end

    context "when managing attachments" do
      it "can update an attachment" do
        within "#attachments" do
          within "tr", text: translated(attachment.title) do
            find("button[data-controller='dropdown']").click
            click_on "Edit"
          end
        end

        within ".edit_attachment" do
          fill_in_i18n(
            :attachment_title,
            "#attachment-title-tabs",
            en: "This is a nice photo",
            es: "Una foto muy guay",
            ca: "Aquesta foto és ben xula"
          )

          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "#attachments table" do
          expect(page).to have_text("This is a nice photo")
        end
      end
    end
  end
end