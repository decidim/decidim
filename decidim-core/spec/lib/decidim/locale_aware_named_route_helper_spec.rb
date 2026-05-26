# frozen_string_literal: true

require "spec_helper"

describe Decidim::LocaleAwareNamedRouteHelper do
  let(:organization) { create(:organization) }
  let(:static_page) { create(:static_page, organization:, slug: "help") }

  describe "Decidim::Core::Engine.routes.url_helpers" do
    subject(:url_helpers) { Decidim::Core::Engine.routes.url_helpers }

    it "uses the current locale for localized paths" do
      I18n.with_locale(:ca) do
        expect(url_helpers.new_user_registration_path).to eq("/ca/users/sign_up")
        expect(url_helpers.page_path(static_page)).to eq("/ca/pages/help")
      end
    end

    it "preserves an explicit locale override" do
      I18n.with_locale(:ca) do
        expect(url_helpers.new_user_registration_path(locale: :en)).to eq("/en/users/sign_up")
        expect(url_helpers.page_path(static_page, locale: :en)).to eq("/en/pages/help")
      end
    end
  end

  describe "Decidim::ParticipatoryProcesses::Engine.routes.url_helpers" do
    subject(:url_helpers) { Decidim::ParticipatoryProcesses::Engine.routes.url_helpers }

    it "uses the current locale for localized paths" do
      I18n.with_locale(:ca) do
        expect(url_helpers.participatory_processes_path).to eq("/ca/processes")
      end
    end

    it "preserves an explicit locale override" do
      I18n.with_locale(:ca) do
        expect(url_helpers.participatory_processes_path(locale: :en)).to eq("/en/processes")
      end
    end
  end
end
