# frozen_string_literal: true

module Decidim
  class ProfileMemberOfCell < Decidim::ViewModel
    include Decidim::Core::Engine.routes.url_helpers

    def members
      @members ||= Decidim::ParticipatorySpace::Member.where(user:)
                                                      .includes(:participatory_space)
                                                      .published
                                                      .select { |m| m.participatory_space.present? && m.participatory_space.published? }
                                                      .sort_by { |m| translated_attribute(m.participatory_space.title) }
    end

    def show
      return unless members.any?

      render
    end

    private

    def user
      model
    end

    def grouped_members
      @grouped_members ||= members.group_by(&:participatory_space_type)
    end

    def sorted_types
      @sorted_types ||= grouped_members.keys.sort_by { |k| k.split("::").last.downcase }
    end
  end
end
