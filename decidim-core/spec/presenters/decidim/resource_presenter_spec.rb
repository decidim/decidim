# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourcePresenter, type: :helper do
    let(:organization) { create(:organization) }
    let(:resource) { create(:dummy_resource, component: create(:component, manifest_name: "dummy", organization:)) }

    subject { described_class.new(resource) }

    describe "#editor_locales" do
      let(:hashtag) { create(:hashtag, organization:) }
      let(:hashtag2) { create(:hashtag, organization:) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:user2) { create(:user, :confirmed, organization:) }

      let(:data) { html }
      let(:html) do
        <<~HTML
          <p>Paragraph with a hashtag #{hashtag.to_global_id} and another hashtag #{hashtag2.to_global_id}</p>
          <p>Paragraph with a user mention #{user.to_global_id} and another user mention #{user2.to_global_id}</p>
        HTML
      end
      let(:editor_html) do
        <<~HTML
          <p>Paragraph with a hashtag #{html_hashtag(hashtag)} and another hashtag #{html_hashtag(hashtag2)}</p>
          <p>Paragraph with a user mention #{html_mention(user)} and another user mention #{html_mention(user2)}</p>
        HTML
      end

      it "converts the hashtags and mentions to WYSIWYG editor ready elements" do
        expect(subject.editor_locales(data, false)).to eq(editor_html)
      end

      context "when modifying all locales" do
        let(:data) { { en: html, es: html } }

        it "converts the hashtags and mentions to WYSIWYG editor ready elements" do
          expect(subject.editor_locales(data, true)).to eq(en: editor_html, es: editor_html)
        end
      end

      def html_hashtag(hashtag)
        %(<span data-type="hashtag" data-label="##{hashtag.name}">##{hashtag.name}</span>)
      end

      def html_mention(mentionable)
        mention = "@#{mentionable.nickname}"
        label = "#{mention} (#{CGI.escapeHTML(mentionable.name)})"
        %(<span data-type="mention" data-id="#{mention}" data-label="#{label}">#{label}</span>)
      end
    end
  end
end
