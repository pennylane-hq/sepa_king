# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SEPA::Transaction do
  describe :new do
    it 'has default for reference' do
      expect(SEPA::Transaction.new.reference).to eq('NOTPROVIDED')
    end

    it 'has default for requested_date' do
      expect(SEPA::Transaction.new.requested_date).to eq(Date.new(1999, 1, 1))
    end

    it 'has default for batch_booking' do
      expect(SEPA::Transaction.new.batch_booking).to be(true)
    end
  end

  describe 'Name' do
    it 'accepts valid value' do
      expect(SEPA::Transaction).to accept('Manfred Mustermann III.', 'Zahlemann & Söhne GbR', 'X' * 70, for: :name)
    end

    it 'does not accept invalid value' do
      expect(SEPA::Transaction).not_to accept(nil, '', 'X' * 71, for: :name)
    end
  end

  describe 'RequestedDate' do
    it 'accepts DateTime value' do
      expect(SEPA::Transaction).to accept(Date.today, for: :requested_date)
    end

    it 'accepts Time value' do
      expect(SEPA::Transaction).to accept(Time.now, for: :requested_date)
    end
  end

  describe 'Address' do
    context 'with address_line' do
      it 'accepts valid value' do
        expect(SEPA::Transaction).to accept(SEPA::DebtorAddress.new(
                                              country_code: 'CH',
                                              address_line1: 'Musterstrasse 123',
                                              address_line2: '1234 Musterstadt'
                                            ), for: :debtor_address)
      end

      it 'accepts valid value' do
        expect(SEPA::Transaction).to accept(SEPA::CreditorAddress.new(
                                              country_code: 'CH',
                                              address_line1: 'Musterstrasse 123',
                                              address_line2: '1234 Musterstadt'
                                            ), for: :creditor_address)
      end
    end

    context 'with individual address fields' do
      it 'accepts valid value' do
        expect(SEPA::Transaction).to accept(SEPA::DebtorAddress.new(
                                              country_code: 'CH',
                                              street_name: 'Mustergasse',
                                              building_number: '123',
                                              post_code: '1234',
                                              town_name: 'Musterstadt'
                                            ), for: :debtor_address)
      end

      it 'accepts valid value' do
        expect(SEPA::Transaction).to accept(SEPA::CreditorAddress.new(
                                              country_code: 'CH',
                                              street_name: 'Mustergasse',
                                              building_number: '123',
                                              post_code: '1234',
                                              town_name: 'Musterstadt'
                                            ), for: :creditor_address)
      end
    end

    it 'does not accept invalid value' do
      expect(SEPA::Transaction).not_to accept('', {}, for: :name)
    end
  end

  describe 'IBAN' do
    it 'accepts valid value' do
      expect(SEPA::Transaction).to accept('DE21500500009876543210', 'PL61109010140000071219812874', for: :iban)
    end

    it 'does not accept invalid value' do
      expect(SEPA::Transaction).not_to accept(nil, '', 'invalid', for: :iban)
    end
  end

  describe 'BIC' do
    it 'accepts valid value' do
      expect(SEPA::Transaction).to accept('DEUTDEFF', 'DEUTDEFF500', 'SPUEDE2UXXX', for: :bic)
    end

    it 'does not accept invalid value' do
      expect(SEPA::Transaction).not_to accept('', 'invalid', for: :bic)
    end
  end

  describe 'Amount' do
    it 'accepts valid value' do
      expect(SEPA::Transaction).to accept(0.01, 1, 100, 100.00, 99.99, 1_234_567_890.12, BigDecimal('10'), '42', '42.51', '42.512', 1.23456, for: :amount)
    end

    it 'does not accept invalid value' do
      expect(SEPA::Transaction).not_to accept(nil, 0, -3, 'xz', for: :amount)
    end
  end

  describe 'Reference' do
    it 'accepts valid value' do
      expect(SEPA::Transaction).to accept(nil, 'ABC-1234/78.0', 'X' * 35, for: :reference)
    end

    it 'does not accept invalid value' do
      expect(SEPA::Transaction).not_to accept('', 'X' * 36, for: :reference)
    end
  end

  describe 'Remittance information' do
    it 'allows valid value' do
      expect(SEPA::Transaction).to accept(nil, 'Bonus', 'X' * 140, for: :remittance_information)
    end

    it 'does not allow invalid value' do
      expect(SEPA::Transaction).not_to accept('', 'X' * 141, for: :remittance_information)
    end
  end

  describe 'Currency' do
    it 'allows valid values' do
      expect(SEPA::Transaction).to accept('EUR', 'CHF', 'SEK', for: :currency)
    end

    it 'does not allow invalid values' do
      expect(SEPA::Transaction).not_to accept('', 'EURO', 'ABCDEF', for: :currency)
    end
  end
end
