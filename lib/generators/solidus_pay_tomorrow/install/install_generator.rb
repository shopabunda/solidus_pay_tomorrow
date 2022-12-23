# frozen_string_literal: true

module SolidusPayTomorrow
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        template 'initializer.rb', 'config/initializers/solidus_pay_tomorrow.rb'
      end

      def mount_engine
        route "mount SolidusPayTomorrow::Engine, at: '/solidus_pay_tomorrow'"
      end

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/frontend/all.js',
          "//= require spree/frontend/solidus_pay_tomorrow\n"
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', " *= require spree/frontend/solidus_pay_tomorrow\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/solidus_pay_tomorrow\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=solidus_pay_tomorrow'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]')) # rubocop:disable Layout/LineLength
        if run_migrations
          run 'bin/rails db:migrate'
        else
          puts 'Skipping bin/rails db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end

      def populate_seed_data
        say_status :loading, 'load seed data'
        rake('db:seed:solidus_pay_tomorrow')
      end

      def add_pay_tomorrow_application_controller
        template(
          'solidus_pay_tomorrow_order_application_controller.rb',
          'app/controllers/solidus_pay_tomorrow/order_application_controller.rb'
        )
        template(
          'solidus_pay_tomorrow_api_webhooks_controller.rb',
          'app/controllers/solidus_pay_tomorrow/api/webhooks_controller.rb'
        )
      end
    end
  end
end
