# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  post 'api/orders/:order_number/pay_tomorrow', to: '/solidus_pay_tomorrow/api/create_order#create',
    as: 'create_api_pay_tomorrow_order'

  get 'pay_tomorrow/return', to: '/solidus_pay_tomorrow/order_application#success',
    as: 'pay_tomorrow_return'
  get 'pay_tomorrow/cancel', to: '/solidus_pay_tomorrow/order_application#cancel',
    as: 'pay_tomorrow_cancel'
  post 'pay_tomorrow/notify', to: '/solidus_pay_tomorrow/api/webhooks#notify',
    as: 'pay_tomorrow_notify'
end
