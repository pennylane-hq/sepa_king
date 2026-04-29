# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SEPA::IBANValidator do
  class Validatable
    include ActiveModel::Model

    attr_accessor :iban, :iban_the_terrible

    validates_with SEPA::IBANValidator, message: '%{value} seems wrong'
    validates_with SEPA::IBANValidator, field_name: :iban_the_terrible
  end

  it 'accepts valid IBAN' do
    expect(Validatable).to accept('DE21500500009876543210', 'DE87200500001234567890', for: %i[iban iban_the_terrible])
  end

  it 'does not accept an invalid IBAN' do
    expect(Validatable).not_to accept('', 'xxx',                     # Oviously no IBAN
                                      'DE22500500009876543210',      # wrong checksum
                                      'DE2150050000987654321',       # too short
                                      'de87200500001234567890',      # downcase characters
                                      'DE87 2005 0000 1234 5678 90', # spaces included
                                      for: %i[iban iban_the_terrible])
  end

  it 'customizes error message' do
    v = Validatable.new(iban: 'xxx')
    v.valid?
    expect(v.errors[:iban]).to eq(['xxx seems wrong'])
  end
end

RSpec.describe SEPA::BICValidator do
  class Validatable
    include ActiveModel::Model

    attr_accessor :bic, :custom_bic

    validates_with SEPA::BICValidator, message: '%{value} seems wrong'
    validates_with SEPA::BICValidator, field_name: :custom_bic
  end

  it 'accepts valid BICs' do
    expect(Validatable).to accept('DEUTDEDBDUE', 'DUSSDEDDXXX', for: %i[bic custom_bic])
  end

  it 'does not accept an invalid BIC' do
    expect(Validatable).not_to accept('', 'GENODE61HR', 'DEUTDEDBDUEDEUTDEDBDUE', for: %i[bic custom_bic])
  end

  it 'customizes error message' do
    v = Validatable.new(bic: 'xxx')
    v.valid?
    expect(v.errors[:bic]).to eq(['xxx seems wrong'])
  end
end

RSpec.describe SEPA::CreditorIdentifierValidator do
  class Validatable
    include ActiveModel::Model

    attr_accessor :creditor_identifier, :crid

    validates_with SEPA::CreditorIdentifierValidator, message: '%{value} seems wrong'
    validates_with SEPA::CreditorIdentifierValidator, field_name: :crid
  end

  it 'accepts valid creditor_identifier' do
    expect(Validatable).to accept(
      'DE98ZZZ09999999999',
      'CH0712300000012345',
      'SE97ZZZ1234567890',
      'PL97ZZZ0123456789',
      'NO97ZZZ123456785',
      'HU74111A12345676',
      'BG32ZZZ100064095',
      'AT12ZZZ00000000001',
      'FR12ZZZ123456',
      'NL97ZZZ123456780001',
      for: %i[creditor_identifier crid]
    )
  end

  it 'does not accept an invalid creditor_identifier' do
    expect(Validatable).not_to accept(
      '',
      'xxx',
      'DE98ZZZ099999999990',
      'DE98---09999999999',
      for: %i[creditor_identifier crid]
    )
  end

  it 'customizes error message' do
    v = Validatable.new(creditor_identifier: 'xxx')
    v.valid?
    expect(v.errors[:creditor_identifier]).to eq(['xxx seems wrong'])
  end
end

RSpec.describe SEPA::MandateIdentifierValidator do
  class Validatable
    include ActiveModel::Model

    attr_accessor :mandate_id, :mid

    validates_with SEPA::MandateIdentifierValidator, message: '%{value} seems wrong'
    validates_with SEPA::MandateIdentifierValidator, field_name: :mid
  end

  it 'accepts valid mandate_identifier' do
    expect(Validatable).to accept('XYZ-123', "+?/-:().,'", 'X' * 35, for: %i[mandate_id mid])
  end

  it 'does not accept an invalid mandate_identifier' do
    expect(Validatable).not_to accept(nil, '', 'X' * 36, '#/*', 'Ümläüt', for: %i[mandate_id mid])
  end

  it 'customizes error message' do
    v = Validatable.new(mandate_id: '*** 123')
    v.valid?
    expect(v.errors[:mandate_id]).to eq(['*** 123 seems wrong'])
  end
end
