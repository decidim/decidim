# frozen_string_literal: true

require "spec_helper"

describe Decidim::Api::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, :admin, :confirmed, admin_terms_accepted_at: 1.day.ago) }
  let(:blob) { create(:blob) }

  let(:context) do
    {
      current_user: user,
      blob: blob
    }
  end

  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is not admin" do
    let(:action) { { scope: :public, action: :create, subject: :blob } }

    it "raises a PermissionNotSetError" do
      expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
    end
  end

  context "when user is not present" do
    let(:user) { nil }
    let(:action) { { scope: :admin, action: :create, subject: :blob } }

    it "raises a PermissionNotSetError" do
      expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
    end
  end

  context "when user is not admin" do
    let(:user) { create(:user, :confirmed) }
    let(:action) { { scope: :admin, action: :create, subject: :blob } }

    it "raises a PermissionNotSetError" do
      expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
    end
  end

  context "when admin terms are not accepted" do
    let(:user) { create(:user, :admin, :confirmed, admin_terms_accepted_at: nil) }
    let(:action) { { scope: :admin, action: :create, subject: :blob } }

    it "raises a PermissionNotSetError" do
      expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
    end
  end

  context "when user is admin and terms are accepted" do
    context "and action is :create" do
      let(:action) { { scope: :admin, action: :create, subject: :blob } }

      it { is_expected.to be true }
    end

    context "and action is :update" do
      let(:action) { { scope: :admin, action: :update, subject: :blob } }

      context "when blob is present" do
        it { is_expected.to be true }
      end

      context "when blob is not present" do
        let(:context) { { current_user: user } }

        it "raises a PermissionNotSetError" do
          expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
        end
      end
    end

    context "and action is :destroy" do
      let(:action) { { scope: :admin, action: :destroy, subject: :blob } }

      context "when blob is present" do
        it { is_expected.to be true }
      end

      context "when blob is not present" do
        let(:context) { { current_user: user } }

        it "raises a PermissionNotSetError" do
          expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
        end
      end
    end

    context "and action is something else" do
      let(:action) { { scope: :admin, action: :foo, subject: :blob } }

      it "raises a PermissionNotSetError" do
        expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
      end
    end
  end
end
