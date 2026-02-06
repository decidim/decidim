# frozen_string_literal: true

require "spec_helper"

describe "Preview initiative with share token" do
  let(:organization) { create(:organization) }
  let!(:participatory_space) { create(:initiative, :created, organization:) }
  let(:resource_path) { decidim_initiatives.initiative_path(participatory_space, locale: I18n.locale) }

  it_behaves_like "preview participatory space with a share_token"
end
