# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ActiveUsersCounter do
    let!(:organization) { create :organization }
    let!(:now) { Time.zone.now }
    let!(:last_day) { Time.zone.yesterday }
    let!(:last_week) { Time.zone.today.prev_week }
    let!(:last_month) { Time.zone.today.prev_month }

    # Participants
    let!(:participants_logins) do
      create_list(:user, 2, :confirmed, organization: organization, current_sign_in_at: last_month, last_sign_in_at: last_month)
      create_list(:user, 5, :confirmed, organization: organization, current_sign_in_at: last_week, last_sign_in_at: last_week)
      create_list(:user, 7, :confirmed, organization: organization, current_sign_in_at: now, last_sign_in_at: now)
    end
    # Admins
    let!(:admins_logins) do
      create_list(:user, 3, :admin, :confirmed, organization: organization, current_sign_in_at: last_month, last_sign_in_at: last_month)
      create_list(:user, 4, :admin, :confirmed, organization: organization, current_sign_in_at: last_week, last_sign_in_at: last_week)
      create_list(:user, 10, :admin, :confirmed, organization: organization, current_sign_in_at: now, last_sign_in_at: now)
    end

    describe "with bad query init values" do
      context "when executing query" do
        let(:parameters) do
          { organization: organization, date: nil, admin: nil }
        end

        it "returns 0 matches" do
          query = described_class.new(**parameters)

          expect(query.count).to eq(0)
        end
      end
    end

    describe "with good query init values" do
      context "when three different periods and two different user types" do
        let(:parameters_last_day_admin) do
          { organization: organization, date: last_day, admin: true }
        end
        let(:parameters_last_week_admin) do
          { organization: organization, date: last_week, admin: true }
        end
        let(:parameters_last_month_admin) do
          { organization: organization, date: last_month, admin: true }
        end
        let(:parameters_last_day_participants) do
          { organization: organization, date: last_day, admin: false }
        end
        let(:parameters_last_week_participants) do
          { organization: organization, date: last_week, admin: false }
        end
        let(:parameters_last_month_participants) do
          { organization: organization, date: last_month, admin: false }
        end

        let(:result) do
          {
            total_admins_last_day: described_class.new(**parameters_last_day_admin).query.count,
            total_admins_last_week: described_class.new(**parameters_last_week_admin).query.count,
            total_admins_last_month: described_class.new(**parameters_last_month_admin).query.count,
            total_participants_last_day: described_class.new(**parameters_last_day_participants).query.count,
            total_participants_last_week: described_class.new(**parameters_last_week_participants).query.count,
            total_participants_last_month: described_class.new(**parameters_last_month_participants).query.count
          }
        end

        it "counts complete 6 results, one for each period/user type" do
          expect(result.count).to eq(6)
        end

        it "counts total admins logged last 24 hours - 10" do
          expect(result[:total_admins_last_day]).to eq(10)
        end

        it "counts total admins logged last week - 14" do
          expect(result[:total_admins_last_week]).to eq(14)
        end

        it "counts total admins logged last month - 17" do
          expect(result[:total_admins_last_month]).to eq(17)
        end

        it "counts total participants logged last 24 hours - 7" do
          expect(result[:total_participants_last_day]).to eq(7)
        end

        it "counts total participants logged last week - 12" do
          expect(result[:total_participants_last_week]).to eq(12)
        end

        it "counts total participants logged last month - 14" do
          expect(result[:total_participants_last_month]).to eq(14)
        end
      end
    end
  end
end
