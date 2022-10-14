# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc 'Loads solidus_pay_tomorrow sample data'
    task solidus_pay_tomorrow: :environment do
      seed_file = Dir[SolidusPayTomorrow::Engine.root.join('db', 'seeds.rb')][0]
      return unless File.exist?(seed_file)

      puts "Seeding #{seed_file}..."
      load(seed_file)
    end
  end
end
