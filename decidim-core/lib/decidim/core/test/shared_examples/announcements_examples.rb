# -*- coding: utf-8 -*-
# frozen_string_literal: true

RSpec.shared_examples "manage announcements" do
  it "customize an general announcement for the feature" do
    visit edit_feature_path(current_feature)

    expect(page).to have_content("wtf")
  end
end
