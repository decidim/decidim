# frozen_string_literal: true

require "spec_helper"

describe Decidim::AdminLog::UserPresenter, type: :helper do
  context "when action is officialize" do
    include_examples "present admin log entry" do
      let(:admin_log_resource) { organization }
      let(:action) { "officialize" }
    end
  end

  context "when action is block" do
    include_examples "present admin log entry" do
      let(:admin_log_resource) { organization }
      let(:action) { "block" }
    end

    include_examples "present admin log entry" do
      let(:admin_log_resource) { create(:user, :blocked, organization:) }
      let(:admin_log_extra_data) { { resource: { title: "John Doe" } } }
      let(:action) { "block" }

      describe "#present" do
        subject { presenter.present }

        it "presents the blocked user's name prior to blocking" do
          expect(subject).not_to include("Blocked user")
          expect(subject).to include(admin_log_extra_data[:resource][:title])
        end
      end
    end
  end

  context "when actions are performed on deleted user" do
    include_examples "present admin log entry" do
      let(:admin_log_resource) { create(:user, :deleted, organization:) }
      let(:user) { create(:user, :deleted, organization:) }
      let(:admin_log_extra_data) { { resource: { title: "John Doe" } } }
      let(:action) { "block" }

      describe "#present" do
        subject { presenter.present }

        it "presents the blocked user's name prior to blocking" do
          expect(subject).not_to include("Blocked user")
          expect(subject).to include(user.name)
        end
      end
    end

    include_examples "present admin log entry" do
      let(:admin_log_resource) { create(:user, :blocked, :deleted, organization:) }
      let(:user) { create(:user, :deleted, organization:) }
      let(:admin_log_extra_data) { { resource: { title: "John Doe" } } }
      let(:action) { "unblock" }

      describe "#present" do
        subject { presenter.present }

        it "presents the unblocked user's name" do
          within ".logs__log__explanation" do
            expect(subject).to include("unblocked user")
            expect(subject).to include(admin_log_extra_data[:resource][:title])
          end
        end
      end
    end

    include_examples "present admin log entry" do
      let(:admin_log_resource) { create(:user, :deleted, organization:) }
      let(:user) { create(:user, :deleted, organization:) }
      let(:action) { "unreport" }

      describe "#present" do
        subject { presenter.present }

        it "presents the unreport user's name" do
          within ".logs__log__content" do
            expect(subject).to include("unreported user")
            expect(subject).to include(I18n.t("decidim.profile.deleted"))
          end
        end
      end
    end
  end

  context "when action is bulk_block" do
    include_examples "present admin log entry" do
      let(:admin_log_resource) { organization }
      let(:action) { "bulk_block" }
    end

    include_examples "present admin log entry" do
      let(:admin_log_resource) { create(:user, :blocked, organization:) }
      let(:action) { "bulk_block" }

      describe "#present" do
        subject { presenter.present }

        it "presents a message showing the admin_name and the amount of blocked user" do
          expect(subject).to include(user.name)
          expect(subject).to have_content("#{user.name} blocked 0 users")
        end
      end
    end
  end
end
