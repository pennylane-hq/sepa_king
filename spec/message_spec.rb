# frozen_string_literal: true

require 'spec_helper'

class DummyTransaction < SEPA::Transaction
  def valid?
    true
  end
end

class DummyMessage < SEPA::Message
  self.account_class = SEPA::Account
  self.transaction_class = DummyTransaction
end

RSpec.describe SEPA::Message do
  describe :amount_total do
    subject do
      message = DummyMessage.new
      message.add_transaction amount: 1.1
      message.add_transaction amount: 2.2
      message
    end

    it 'sums up all transactions' do
      expect(subject.amount_total).to eq(3.3)
    end

    it 'sums up selected transactions' do
      expect(subject.amount_total([subject.transactions[0]])).to eq(1.1)
    end
  end

  describe 'validation' do
    subject { DummyMessage.new }

    it 'fails with invalid account' do
      expect(subject).not_to be_valid
      expect(subject.errors_on(:account).size).to eq(2)
    end

    it 'fails without transactions' do
      expect(subject).not_to be_valid
      expect(subject.errors_on(:transactions).size).to eq(1)
    end
  end

  describe :message_identification do
    subject { DummyMessage.new }

    describe 'getter' do
      it 'returns prefixed random hex string' do
        expect(subject.message_identification).to match(%r{SEPA-KING/([a-f0-9]{2}){11}})
      end
    end

    describe 'setter' do
      it 'accepts valid ID' do
        valid_rails_global_id_string = 'gid://myMoneyApp/Payment/15108'
        time_based_string = Time.now.to_f.to_s
        [valid_rails_global_id_string,
         time_based_string].each do |valid_msgid|
          subject.message_identification = valid_msgid
          expect(subject.message_identification).to eq(valid_msgid)
        end
      end

      it 'denies invalid string' do
        underscore_string = 'my_MESSAGE_ID/123'
        blank_string = ''
        non_ascii_string = 'üöäß'
        too_long_string = '1' * 36

        [underscore_string,
         blank_string,
         non_ascii_string,
         too_long_string].each do |arg|
          expect do
            subject.message_identification = arg
          end.to raise_error(ArgumentError)
        end
      end

      it 'denies argument other than String' do
        [123,
         nil,
         :foo].each do |arg|
          expect do
            subject.message_identification = arg
          end.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe :creation_date_time do
    subject { DummyMessage.new }

    describe 'getter' do
      it 'returns Time.now.iso8601' do
        expect(subject.creation_date_time).to eq(Time.now.iso8601)
      end
    end

    describe 'setter' do
      it 'accepts date time strings' do
        ['2017-01-05T12:28:52', '2017-01-05T12:28:52Z', '2017-01-05 12:28:52', '2017-01-05T12:28:52+01:00'].each do |valid_dt|
          subject.creation_date_time = valid_dt
          expect(subject.creation_date_time).to eq(valid_dt)
        end
      end

      it 'denies invalid string' do
        ['an arbitrary string',
         ''].each do |arg|
          expect do
            subject.creation_date_time = arg
          end.to raise_error(ArgumentError)
        end
      end

      it 'denies argument other than String' do
        [123,
         nil,
         :foo].each do |arg|
          expect do
            subject.creation_date_time = arg
          end.to raise_error(ArgumentError)
        end
      end
    end
  end
end
