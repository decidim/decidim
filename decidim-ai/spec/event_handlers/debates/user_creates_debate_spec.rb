# frozen_string_literal: true

require "spec_helper"

describe "User creates debate", type: :system do
  let(:form) do
    double(
      invalid?: false,
      title:,
      description:,
      user_group_id: nil,
      scope:,
      category:,
      current_user: author,
      current_component: component,
      current_organization: organization
    )
  end
  let(:command) { Decidim::Debates::CreateDebate.new(form) }

  include_examples "debates spam analysis"
end
