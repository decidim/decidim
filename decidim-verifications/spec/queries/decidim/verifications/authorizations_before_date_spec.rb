# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::AuthorizationsBeforeDate do
  let(:name) { "some_method" }
  let(:user1) { create(:user, organization: organization) }
  let(:user2) { create(:user, organization: organization) }
  let(:user3) { create(:user, organization: organization) }
  let(:user4) { create(:user, organization: organization) }
  let(:user5) { create(:user, organization: organization) }
  let(:user6) { create(:user, organization: organization) }
  let(:user7) { create(:user, organization: organization) }
  let(:user8) { create(:user, organization: organization) }
  let(:user9) { create(:user, organization: organization, managed: true) }
  let(:organization) { create :organization }
  let(:now) { Time.zone.now }
  let(:prev_week) { Time.zone.today.prev_week }
  let(:prev_month) { Time.zone.today.prev_month }
  let(:prev_year) { Time.zone.today.prev_year }

  let!(:created_now) do
    create(:authorization, created_at: now, granted_at: nil, name: name, user: user1)
  end

  let!(:created_prev_week) do
    create(:authorization, created_at: prev_week, granted_at: nil, name: name, user: user2)
  end

  let!(:created_prev_month) do
    create(:authorization, created_at: prev_month, granted_at: nil, name: name, user: user3)
  end

  let!(:created_prev_year) do
    create(:authorization, created_at: prev_year, granted_at: nil, name: name, user: user4)
  end

  let!(:granted_now) do
    create(:authorization, created_at: prev_year, granted_at: now, name: name, user: user5)
  end

  let!(:granted_prev_week) do
    create(:authorization, created_at: prev_year, granted_at: prev_week, name: name, user: user6)
  end

  let!(:granted_prev_month) do
    create(:authorization, created_at: prev_year, granted_at: prev_month, name: name, user: user7)
  end

  let!(:granted_prev_year) do
    create(:authorization, created_at: prev_year, granted_at: prev_year, name: name, user: user8)
  end

  let!(:granted_managed) do
    create(:authorization, created_at: prev_year, granted_at: prev_year, name: "managed", user: user9)
  end

  let!(:external_organization_authorization) do
    create(:authorization)
  end

  shared_examples_for "a correct usage of the query" do
    subject { described_class.new(**parameters).query }

    it { is_expected.to match_array(expectation) }
    it { is_expected.not_to include(external_organization_authorization) }
  end

  describe "when no filtering" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: now }
      end

      let(:expectation) do
        [
          granted_now,
          granted_prev_week,
          granted_prev_month,
          granted_prev_year,
          granted_managed
        ]
      end
    end
  end

  describe "when granted only, no date" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: nil, granted: true }
      end

      let(:expectation) do
        [
          granted_now,
          granted_prev_week,
          granted_prev_month,
          granted_prev_year,
          granted_managed
        ]
      end
    end
  end

  describe "when granted only, prev_week date" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: prev_week, granted: true }
      end

      let(:expectation) do
        [
          granted_now,
          granted_prev_week,
          granted_prev_month,
          granted_prev_year,
          granted_managed
        ]
      end
    end
  end

  describe "when granted only, prev_month date" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: prev_month, granted: true }
      end

      let(:expectation) do
        [
          granted_now,
          granted_prev_week,
          granted_prev_month,
          granted_prev_year,
          granted_managed
        ]
      end
    end
  end

  describe "when granted only, prev_year date" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: prev_year, granted: true }
      end

      let(:expectation) do
        []
      end
    end
  end

  describe "when ungranted only, now date" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: now, granted: false }
      end

      let(:expectation) do
        [
          created_prev_week,
          created_prev_month,
          created_prev_year
        ]
      end
    end
  end

  describe "when ungranted only, prev_week date" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: prev_week, granted: false }
      end

      let(:expectation) do
        [
          created_prev_month,
          created_prev_year
        ]
      end
    end
  end

  describe "when ungranted only, prev_month date" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: prev_month, granted: false }
      end

      let(:expectation) do
        [
          created_prev_year
        ]
      end
    end
  end

  describe "when ungranted only, prev_year date" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: prev_year, granted: false }
      end

      let(:expectation) do
        []
      end
    end
  end

  describe "when granted only, impersonated only" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization: organization, date: prev_month, granted: true, impersonated_only: true }
      end

      let(:expectation) do
        [
          granted_managed
        ]
      end
    end
  end
end
