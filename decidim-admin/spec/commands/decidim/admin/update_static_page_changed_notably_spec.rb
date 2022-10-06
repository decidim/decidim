# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateStaticPage do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization:) }
      let(:user) { create :user, :admin, :confirmed, organization: }
      let(:form) do
        StaticPageForm.from_params(
          static_page: page.attributes.merge(
            content_en: Faker::Lorem.paragraph(sentence_count: 2),
            content_es: Faker::Lorem.paragraph(sentence_count: 2),
            content_ca: Faker::Lorem.paragraph(sentence_count: 2),
            changed_notably: true
          )
        ).with_context(
          current_organization: page.organization,
          current_user: user
        )
      end
      let(:command) { described_class.new(page, form) }

      describe "when the changed_notably is checked" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "traces the update", versioning: true do
          expect { command.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.where(resource_type: "Decidim::Organization").last
          expect(action_log.version).to be_present
          expect(action_log.action).to eq "update"
          expect(action_log.version.item_type).to eq "Decidim::Organization"
          expect(action_log.version.object_changes).to include "tos_version"
        end

        it "updates the the organization's terms-and-conditions version setting" do
          command.call
          organization.reload
          page.reload

          expect(page.updated_at).to eq(organization.tos_version)
        end
      end
    end
  end
end
