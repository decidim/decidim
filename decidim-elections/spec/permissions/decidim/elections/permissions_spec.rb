# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: component.organization) }
  let(:component) { create(:elections_component) }
  let(:election) { create(:election, component:) }
  let(:context) do
    {
      current_component: component,
      election:
    }
  end
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :election }
    end

    it_behaves_like "delegates permissions to", Decidim::Elections::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :election }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a election" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when accessing an election" do
    let(:action) do
      { scope: :public, action: :read, subject: :election }
    end

    it_behaves_like "permission is not set"
    context "when election is published" do
      let(:election) { create(:election, :published, component:) }

      it { is_expected.to be true }
    end
  end

  context "when creating a vote" do
    let(:action) do
      { scope: :public, action: :create, subject: :vote }
    end

    it_behaves_like "permission is not set"

    context "when election is published" do
      let(:election) { create(:election, :published, component:) }

      it_behaves_like "permission is not set"
    end

    context "when election is ongoing and published" do
      let(:election) { create(:election, :published, :ongoing, component:) }

      it { is_expected.to be true }
    end
  end

  context "when creating or reading a census_check" do
    let(:action) do
      { scope: :public, action: :create, subject: :census_check }
    end

    it_behaves_like "permission is not set"

    context "when election is not published" do
      let(:election) { create(:election, :scheduled, :with_token_csv_census, component:) }

      it_behaves_like "permission is not set"

      context "when user is admin" do
        let(:user) { create(:user, :admin, organization: component.organization) }

        it { is_expected.to be true }
      end
    end

    context "when election is published and scheduled" do
      let(:election) { create(:election, :published, :scheduled, :with_token_csv_census, component:) }

      context "when allow_census_check_before_start is false" do
        before do
          election.update!(allow_census_check_before_start: false)
        end

        it_behaves_like "permission is not set"
      end

      context "when allow_census_check_before_start is true" do
        before do
          election.update!(allow_census_check_before_start: true)
        end

        it { is_expected.to be true }
      end
    end

    context "when election is published but census is not ready" do
      let(:election) { create(:election, :published, :scheduled, component:, allow_census_check_before_start: true) }

      it_behaves_like "permission is not set"
    end

    context "when reading census_check" do
      let(:action) do
        { scope: :public, action: :read, subject: :census_check }
      end

      context "when election is scheduled with census ready and checkbox enabled" do
        let(:election) { create(:election, :published, :scheduled, :with_token_csv_census, component:, allow_census_check_before_start: true) }

        it { is_expected.to be true }
      end
    end
  end
end
