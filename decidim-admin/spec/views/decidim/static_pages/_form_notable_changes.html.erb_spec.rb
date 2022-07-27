# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "decidim/admin/static_pages/_form_notable_changes" do
    subject { render }

    let(:form) do
      Decidim::FormBuilder.new(
        :static_page,
        Decidim::Admin::StaticPageForm.new(slug:),
        view,
        {}
      )
    end
    let(:action) do
      Decidim::PermissionAction.new(scope: :admin, action: :update_notable_changes, subject: :static_page)
    end
    let(:permissions_class) do
      Decidim::Admin::Permissions.new(build(:user, :admin), action, static_page: form.object)
    end

    before do
      view.extend Decidim::NeedsPermission
      allow(view).to receive(:form).and_return(form)
      allow(view).to receive(:allowed_to?).and_return(allowed?)
      allow(view).to receive(:permissions_class).and_return(permissions_class)
    end

    context "with a default static page" do
      let(:slug) { Decidim::StaticPage::DEFAULT_PAGES.without("terms-and-conditions").sample }
      let(:allowed?) { false }

      it { is_expected.to eq("") }
    end

    context "with the TOS static page" do
      let(:slug) { "terms-and-conditions" }
      let(:allowed?) { true }

      it { is_expected.to include("changed_notably") }
    end

    context "with a normal static page" do
      let(:slug) { "foo" }
      let(:allowed?) { false }

      it { is_expected.to eq("") }
    end
  end
end
