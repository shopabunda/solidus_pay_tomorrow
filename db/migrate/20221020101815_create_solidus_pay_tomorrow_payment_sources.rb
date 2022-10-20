class CreateSolidusPayTomorrowPaymentSources < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_pay_tomorrow_payment_sources do |t|
      t.string :application_token
      t.references :payment_method, index: true

      t.timestamps
    end
  end
end
