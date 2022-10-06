# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateStaticPage do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:page) { create(:static_page, organization:) }
      let(:user) { create :user, :admin, :confirmed, organization: }
      let(:form) do
        StaticPageForm.from_params(
          static_page: page.attributes.merge(slug: "new-slug", allow_public_access: true)
        ).with_context(
          current_organization: page.organization,
          current_user: user
        )
      end
      let(:command) { described_class.new(page, form) }

      describe "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't update the page" do
          command.call
          page.reload

          expect(page.slug).not_to eq("new_slug")
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "traces the update", versioning: true do
          expect(Decidim.traceability)
            .to receive(:update!)
            .with(Decidim::StaticPage, user, hash_including(:title, :slug, :content))
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "update"
        end

        it "updates the page in the organization" do
          command.call
          page.reload

          expect(page.slug).to eq("new-slug")
          expect(page.allow_public_access).to be(true)
        end
      end
    end
  end
end
