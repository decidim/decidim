# frozen_string_literal: true

require "spec_helper"

describe "Admin manages surveys", type: :system do
  let(:manifest_name) { "surveys" }
  let!(:survey) { create :survey, component: component }

  include_context "when managing a component as an admin"

  it_behaves_like "edit surveys"
  it_behaves_like "export survey user answers"
  it_behaves_like "manage announcements"
end
