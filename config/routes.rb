# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  post 'api/orders/:order_number/pay_tomorrow', to: '/solidus_pay_tomorrow/api/create_order#create',
    as: 'create_api_pay_tomorrow_order'
end
