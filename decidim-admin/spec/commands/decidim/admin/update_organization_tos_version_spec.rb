# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateOrganizationTosVersion do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:tos_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization:) }
      let(:other_page) { create(:static_page, slug: "other-page", organization:) }
      let(:user) { create(:user, organization:) }

      describe "when the page is not the terms-and-conditions page" do
        let(:form) do
          StaticPageForm.from_params(
            static_page: other_page.attributes.merge(
              content_en: Faker::Lorem.paragraph(sentence_count: 2),
              content_es: Faker::Lorem.paragraph(sentence_count: 2),
              content_ca: Faker::Lorem.paragraph(sentence_count: 2),
              changed_notably: true
            )
          ).with_context(
            current_organization: other_page.organization,
            current_user: user
          )
        end

        let(:command) { described_class.new(organization, other_page, form) }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't update the organization's terms-and-conditions updated at setting" do
          previous_tos_version = organization.tos_version.strftime("%F %T.%L")
          command.call
          organization.reload

          expect(previous_tos_version).to eq(organization.tos_version.strftime("%F %T.%L"))
        end
      end

      describe "when the page is the terms-and-conditions page" do
        let(:form) do
          StaticPageForm.from_params(
            static_page: tos_page.attributes.merge(
              content_en: Faker::Lorem.paragraph(sentence_count: 2),
              content_es: Faker::Lorem.paragraph(sentence_count: 2),
              content_ca: Faker::Lorem.paragraph(sentence_count: 2),
              changed_notably: true
            )
          ).with_context(
            current_organization: tos_page.organization,
            current_user: user
          )
        end

        let(:command) { described_class.new(organization, tos_page, form) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "traces the update", versioning: true do
          expect(Decidim.traceability)
            .to receive(:update!)
            .with(organization, user, hash_including(:tos_version))
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.action).to eq "update"
        end

        it "updates the the organization's terms-and-conditions updated at setting" do
          command.call
          tos_page.reload
          organization.reload

          expect(tos_page.updated_at).to eq(organization.tos_version)
        end
      end
    end
  end
end
