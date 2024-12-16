# frozen_string_literal: true

require "spec_helper"

describe "User updates meeting", type: :system do
  let(:form) do
    Decidim::Debates::DebateForm.from_params(
      title:,
      description:,
      taxonomizations:,
      id: debate.id
    ).with_context(
      current_organization: organization,
      current_participatory_space: participatory_space,
      current_component: component,
      current_user: author
    )
  end

  let(:command) { Decidim::Debates::UpdateDebate.new(form, debate) }

  include_examples "debates spam analysis" do
    let!(:debate) do
      create(:debate, author:, component:,
                      title: { en: "Some proposal that is not blocked" },
                      description: { en: "The body for the meeting." })
    end
  end
end
