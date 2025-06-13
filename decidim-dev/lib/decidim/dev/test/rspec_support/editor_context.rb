# frozen_string_literal: true

shared_context "with editor content containing mentions" do
  let(:user) { create(:user, :confirmed, organization:) }
  let(:user2) { create(:user, :confirmed, organization:) }

  let(:html) do
    <<~HTML
      <p>Paragraph with some information</p>
      <p>Paragraph with a user mention #{user.to_global_id} and another user mention #{user2.to_global_id}</p>
    HTML
  end
  let(:editor_html) do
    <<~HTML
      <p>Paragraph with some information</p>
      <p>Paragraph with a user mention #{html_mention(user)} and another user mention #{html_mention(user2)}</p>
    HTML
  end

  def html_mention(mentionable)
    mention = "@#{mentionable.nickname}"
    label = "#{mention} (#{CGI.escapeHTML(mentionable.name)})"
    %(<span data-type="mention" data-id="#{mention}" data-label="#{label}">#{label}</span>)
  end
end
