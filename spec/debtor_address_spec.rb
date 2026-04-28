# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SEPA::DebtorAddress do
  it 'initializes a new address' do
    expect(
      SEPA::DebtorAddress.new(country_code: 'CH',
                              address_line1: 'Mustergasse 123',
                              address_line2: '12345 Musterstadt')
    ).to be_valid
  end
end
