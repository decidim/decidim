# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:query) do
    %(
      query {
        organization {
          name { translation(locale: "#{locale}") }
          stats {
            key
            name { translation(locale: "#{locale}") }
            value
            description {
              translations {
                text
                locale
              }
            }
          }
        }
      }
    )
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "has name" do
      expect(response["organization"]["name"]["translation"]).to eq(translated(current_organization.name))
    end

    it "displays the admin in the stats" do
      expect(response["organization"]["stats"].select { |hash| hash["key"] == "users_count" })
        .to eq([{
                 "key" => "users_count",
                 "name" => { "translation" => "Participants" },
                 "value" => 1,
                 "description" => {
                   "translations" => [
                     { "locale" => "en", "text" => "The total number of users who have signed up and confirmed their account via email." },
                     { "locale" => "ca", "text" => "El nombre total d'usuàries que s'han registrat i confirmat el vostre compte per correu electrònic." },
                     { "locale" => "es", "text" => "El número total de usuarias que se han registrado y confirmado su cuenta por correo electrónico." }
                   ]
                 }
               }])
    end

    TRANSLATION_MAP = {
      "users_count" => "Participants"
    }.freeze

    %w(users_count)
      .each do |stat|
      it "displays the stat for #{stat}" do
        stats = response["organization"]["stats"].select { |hash| hash["key"] == stat }

        stats.each { |s| s.delete("description") }

        expected_stat = {
          "key" => stat,
          "name" => { "translation" => TRANSLATION_MAP.fetch(stat, stat.capitalize.tr("_", " ")) },
          "value" => stats.first["value"]
        }

        expect(stats).to eq([expected_stat])
      end
    end
  end
end
