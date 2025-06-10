# frozen_string_literal: true

shared_context "with editor content containing mentions" do
  let(:user) { create(:user, :confirmed, organization:) }
  let(:user2) { create(:user, :confirmed, organization:) }

  def html_mention(mentionable)
    mention = "@#{mentionable.nickname}"
    label = "#{mention} (#{CGI.escapeHTML(mentionable.name)})"
    %(<span data-type="mention" data-id="#{mention}" data-label="#{label}">#{label}</span>)
  end
end
