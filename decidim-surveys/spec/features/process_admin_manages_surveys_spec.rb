# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages surveys", type: :feature do
  let(:manifest_name) { "surveys" }
  let!(:survey) { create :survey, feature: feature }

  include_context "feature process admin"

  it_behaves_like "edit surveys"
  it_behaves_like "export survey user answers"
  it_behaves_like "manage announcements"
end
