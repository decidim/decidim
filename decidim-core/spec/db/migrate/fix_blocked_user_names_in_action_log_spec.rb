# frozen_string_literal: true

require "spec_helper"

describe "FixBlockedUserNamesInActionLog", type: :migration do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed) }
  let(:users) { create_list(:user, 4, :blocked, organization:) }

  let(:user_logs_extra) { {} }
  let!(:dummy_logs) { create_list(:action_log, 10, organization:) }
  let!(:user_logs) do
    users.map do |u|
      create(
        :action_log,
        organization:,
        resource: u,
        resource_type: u.class.name,
        action: "block",
        user: admin,
        extra_data: user_logs_extra
      )
    end
  end

  shared_examples "working migration" do |direction|
    subject { migration.migrate(direction) }

    context "when there are no matching log entries" do
      let!(:user_logs) { [] }

      it "does not change any log entries" do
        expect { subject }.not_to(change { Decidim::ActionLog.order(:id).pluck(:extra) })
      end
    end

    context "when there are matching log entries" do
      let(:user_logs_extra) do
        if direction == :up
          {}
        else
          { resource: { title: "User name" } }
        end
      end

      it "updates the entries that match" do
        matching_before = Decidim::ActionLog.where(resource_type: "Decidim::User").order(:id).pluck(:extra)
        not_matching_before = Decidim::ActionLog.where.not(resource_type: "Decidim::User").order(:id).pluck(:extra)

        expect { subject }.not_to change(Decidim::ActionLog, :count)

        expect(matching_before).not_to eq(
          Decidim::ActionLog.where(resource_type: "Decidim::User").order(:id).pluck(:extra)
        )
        expect(not_matching_before).to eq(
          Decidim::ActionLog.where.not(resource_type: "Decidim::User").order(:id).pluck(:extra)
        )
      end

      it "updates the correct resource titles" do
        subject

        block_logs = Decidim::ActionLog.where(resource_type: "Decidim::User", action: "block").to_h do |log|
          [log.resource_id, log.extra["resource"]["title"]]
        end
        expected_logs = users.to_h do |user|
          if direction == :up
            [user.id, user.extended_data["user_name"]]
          else
            [user.id, "Blocked user"]
          end
        end
        expect(block_logs).to match(expected_logs)
      end

      context "with the user's extended data being empty" do
        before do
          users.each do |u|
            # rubocop:disable Rails/SkipsModelValidations
            u.update_columns(
              name: generate(:name),
              extended_data: nil
            )
            # rubocop:enable Rails/SkipsModelValidations
          end
        end

        it "updates the log entries with the expected user names" do
          subject

          block_logs = Decidim::ActionLog.where(resource_type: "Decidim::User", action: "block").to_h do |log|
            [log.resource_id, log.extra["resource"]["title"]]
          end
          expected_logs = users.to_h do |user|
            if direction == :up
              [user.id, user.name]
            else
              [user.id, "Blocked user"]
            end
          end
          expect(block_logs).to match(expected_logs)
        end
      end
    end
  end

  describe "#migrate :up" do
    it_behaves_like "working migration", :up
  end

  describe "#migrate :down" do
    it_behaves_like "working migration", :down
  end
end
