# frozen_string_literal: true

require "spec_helper"

describe "Member of assemblies", type: :system do
  let(:organization) { create(:organization) }
  let!(:assembly) { create(:assembly, organization:) }
  let!(:assembly_member) { create(:assembly_member, :with_user, assembly:) }

  before do
    switch_to_host(organization.host)
  end

  it "includes active assemblies to the homepage" do
    visit decidim.profile_path(assembly_member.user.nickname)

    within ".card__text--separated-mid-dot" do
      expect(page).to have_i18n_content(assembly.title)
    end
  end
end
