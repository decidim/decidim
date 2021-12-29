# frozen_string_literal: true

class FixProposalsData < ActiveRecord::Migration[5.2]
  def up
    reset_column_information

    PaperTrail.request(enabled: false) do
      Decidim::Proposals::Proposal.find_each do |proposal|
        next if proposal.title.is_a?(Hash) && proposal.body.is_a?(Hash)

        author = proposal.coauthorships.first.author

        locale = author.try(:locale).presence || author.try(:default_locale).presence || author.try(:organization).try(:default_locale).presence

        # rubocop:disable Rails/SkipsModelValidations
        values = {}
        values[:title] = { locale => proposal.title } unless proposal.title.is_a?(Hash)
        values[:body] = { locale => proposal.body } unless proposal.body.is_a?(Hash)

        proposal.update_columns(values)
        # rubocop:enable Rails/SkipsModelValidations
      end
    end

    reset_column_information
  end

  def down; end

  def reset_column_information
    Decidim::User.reset_column_information
    Decidim::Coauthorship.reset_column_information
    Decidim::Proposals::Proposal.reset_column_information
    Decidim::Organization.reset_column_information
  end
end
