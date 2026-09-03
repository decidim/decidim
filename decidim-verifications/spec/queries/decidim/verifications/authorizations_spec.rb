# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::Authorizations do
  let(:name) { "some_method" }
  let(:user) { create(:user, organization:) }
  let(:user2) { create(:user, organization:) }
  let(:user3) { create(:user, organization:) }
  let(:organization) { create(:organization) }

  let!(:granted_for_user_and_method) do
    create(:authorization, :granted, name:, user:)
  end

  let!(:pending_for_other_user) do
    create(:authorization, :pending, name:, user: user2)
  end

  let!(:granted_for_other_user) do
    create(:authorization, :granted, name:, user: user3)
  end

  let!(:pending_for_other_method) do
    create(:authorization, :pending, user:)
  end

  let!(:granted_for_other_method) do
    create(:authorization, :granted, user:)
  end

  let!(:pending_for_other_user_and_method) do
    create(:authorization, :pending, user: user2)
  end

  let!(:granted_for_other_user_and_method) do
    create(:authorization, :granted, user: user3)
  end

  let!(:external_organization_authorization) do
    create(:authorization)
  end

  shared_examples_for "a correct usage of the query" do
    subject { described_class.new(**parameters).query }

    it { is_expected.to match_array(expectation) }
    it { is_expected.not_to include(external_organization_authorization) }
  end

  describe "no filtering" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user: nil, name: nil, granted: nil }
      end

      let(:expectation) do
        [
          granted_for_user_and_method,
          granted_for_other_user,
          pending_for_other_user,
          granted_for_other_method,
          pending_for_other_method,
          granted_for_other_user_and_method,
          pending_for_other_user_and_method
        ]
      end
    end
  end

  describe "granted only" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user: nil, name: nil, granted: true }
      end

      let(:expectation) do
        [
          granted_for_user_and_method,
          granted_for_other_user,
          granted_for_other_method,
          granted_for_other_user_and_method
        ]
      end
    end
  end

  describe "pending only" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user: nil, name: nil, granted: false }
      end

      let(:expectation) do
        [
          pending_for_other_user,
          pending_for_other_method,
          pending_for_other_user_and_method
        ]
      end
    end
  end

  describe "by method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user: nil, name:, granted: nil }
      end

      let(:expectation) do
        [
          granted_for_user_and_method,
          granted_for_other_user,
          pending_for_other_user
        ]
      end
    end
  end

  describe "granted by method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user: nil, name:, granted: true }
      end

      let(:expectation) do
        [granted_for_user_and_method, granted_for_other_user]
      end
    end
  end

  describe "pending by method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user: nil, name:, granted: false }
      end

      let(:expectation) do
        [pending_for_other_user]
      end
    end
  end

  describe "by user" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user:, name: nil, granted: nil }
      end

      let(:expectation) do
        [
          granted_for_user_and_method,
          granted_for_other_method,
          pending_for_other_method
        ]
      end
    end
  end

  describe "granted by user" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user:, name: nil, granted: true }
      end

      let(:expectation) do
        [granted_for_user_and_method, granted_for_other_method]
      end
    end
  end

  describe "pending by user" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user:, name: nil, granted: false }
      end

      let(:expectation) { [pending_for_other_method] }
    end
  end

  describe "by user and method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user:, name:, granted: nil }
      end

      let(:expectation) { [granted_for_user_and_method] }
    end
  end

  describe "granted by user and method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user:, name:, granted: true }
      end

      let(:expectation) { [granted_for_user_and_method] }
    end
  end

  describe "pending by user and method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { organization:, user:, name:, granted: false }
      end

      let(:expectation) { [] }
    end
  end

  describe "impersonated_only and before_date filters" do
    let(:other_name) { "other_method" }
    let(:managed_user) { create(:user, organization:, managed: true) }
    let(:user4) { create(:user, organization:) }
    let(:prev_week) { Time.zone.today.prev_week }
    let(:prev_month) { Time.zone.today.prev_month }

    let!(:granted_managed) { create(:authorization, :granted, name: other_name, user: managed_user, created_at: prev_week) }

    let!(:granted_old) { create(:authorization, :granted, name: other_name, user: user4, created_at: prev_month) }

    describe "impersonated_only" do
      it_behaves_like "a correct usage of the query" do
        let(:parameters) { { organization:, name: other_name, granted: true, impersonated_only: true } }

        let(:expectation) { [granted_managed] }
      end
    end

    describe "before_date" do
      it_behaves_like "a correct usage of the query" do
        let(:parameters) { { organization:, name: other_name, granted: true, before_date: prev_week } }

        let(:expectation) { [granted_old] }
      end
    end

    describe "impersonated_only and before_date combined" do
      it_behaves_like "a correct usage of the query" do
        let(:parameters) { { organization:, name: other_name, granted: true, impersonated_only: true, before_date: prev_week } }

        let(:expectation) { [] }
      end
    end

    describe "without the new filters" do
      it_behaves_like "a correct usage of the query" do
        let(:parameters) { { organization:, name: other_name, granted: true } }

        let(:expectation) { [granted_managed, granted_old] }
      end
    end
  end
end
