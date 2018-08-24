# frozen-string_literal: true

module Decidim::Amendable
  class AmendmentCreatedEvent < Decidim::Events::SimpleEvent
    # include Decidim::Events::AuthorEvent
    i18n_attributes :amendable_path, :amendable_type, :amendable_title, :emendation_path, :emendation_author_nickname, :emendation_author_path
    def amendable_title
      @amendable_title ||= amendable_resource.title
    end

    def amendable_type
      @amendable_type ||= I18n.t(amendable_resource.class.model_name.i18n_key, scope: "activerecord.models", count: 1).downcase
    end

    def amendable_path
      @amendable_path ||= Decidim::ResourceLocatorPresenter.new(amendable_resource).path
    end

    def emendation_author
      @emendation_author ||= begin
        if emendation_resource.is_a?(Decidim::Coauthorable)
          Decidim::UserPresenter.new(emendation_resource.creator_author)
        else
          Decidim::UserPresenter.new(emendation_resource.author)
        end
      end
    end

    def emendation_author_nickname
      @emendation_author_nickname ||= emendation_author.nickname
    end

    def emendation_author_path
      @emendation_author_path ||= emendation_author.profile_path
    end

    def emendation_path
      @emendation_path ||= Decidim::ResourceLocatorPresenter.new(emendation_resource).path
    end

    private

    def amendment_resource
      @amendment_resource ||= Decidim::Amendment.find extra[:amendment_id]
    end

    def amendable_resource
      resource
    end

    def emendation_resource
      @emendation_resource ||= amendment_resource.emendation
    end
  end
end
