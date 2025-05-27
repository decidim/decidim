# frozen_string_literal: true

require "spec_helper"

describe "Preview assembly with share token" do
  let(:organization) { create(:organization) }
  let!(:participatory_space) { create(:assembly, organization:, published_at: nil) }
  let(:resource_path) { decidim_assemblies.assembly_path(participatory_space, locale: I18n.locale) }

  it_behaves_like "preview participatory space with a share_token"
end
