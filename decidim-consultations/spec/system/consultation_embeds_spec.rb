# frozen_string_literal: true

require "spec_helper"

describe "Consultation embeds", type: :system do
  let(:resource) { create(:consultation) }
  let(:widget_path) { Decidim::EngineRouter.main_proxy(resource).consultation_consultation_widget_path }

  it_behaves_like "an embed resource", skip_space_checks: true, skip_link_checks: true
end
