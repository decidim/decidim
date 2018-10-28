# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Organization do
    subject(:organization) { build(:organization) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::OrganizationPresenter
    end

    describe "has an association for scopes" do
      subject(:organization_scopes) { organization.scopes }

      let(:scopes) { create_list(:scope, 2, organization: organization) }

      it { is_expected.to contain_exactly(*scopes) }
    end

    describe "has an association for scope types" do
      subject(:organization_scopes_types) { organization.scope_types }

      let(:scope_types) { create_list(:scope_type, 2, organization: organization) }

      it { is_expected.to contain_exactly(*scope_types) }
    end

    describe "validations" do
      it "default locale should be included in available locales" do
        subject.available_locales = [:ca, :es]
        subject.default_locale = :en
        expect(subject).not_to be_valid
      end
    end
  end
end
