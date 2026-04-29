# frozen_string_literal: true

module SEPA
  class CreditTransfer < Message
    self.account_class = DebtorAccount
    self.transaction_class = CreditTransferTransaction
    self.xml_main_tag = 'CstmrCdtTrfInitn'
    self.known_schemas = [PAIN_001_001_03, PAIN_001_001_03_CH_02, PAIN_001_001_09, PAIN_001_003_03, PAIN_001_002_03]

    private

    # Find groups of transactions which share the same values of some attributes
    def transaction_group(transaction)
      { requested_date: transaction.requested_date,
        batch_booking: transaction.batch_booking,
        service_level: transaction.service_level,
        category_purpose: transaction.category_purpose }
    end

    def build_payment_informations(builder, schema_name)
      # Build a PmtInf block for every group of transactions
      grouped_transactions.each do |group, transactions|
        # All transactions with the same requested_date are placed into the same PmtInf block
        builder.PmtInf do
          builder.PmtInfId(payment_information_identification(group))
          builder.PmtMtd('TRF')
          builder.BtchBookg(group[:batch_booking])
          builder.NbOfTxs(transactions.length)
          builder.CtrlSum(format('%.2f', amount_total(transactions)))
          builder.PmtTpInf do
            if group[:service_level]
              builder.SvcLvl do
                builder.Cd(group[:service_level])
              end
            end
            if group[:category_purpose]
              builder.CtgyPurp do
                builder.Cd(group[:category_purpose])
              end
            end
          end
          if schema_name == PAIN_001_001_09
            builder.ReqdExctnDt do
              if group[:requested_date].is_a?(Time) || group[:requested_date].is_a?(DateTime)
                builder.DtTm(group[:requested_date].iso8601)
              else
                builder.Dt(group[:requested_date].iso8601)
              end
            end
          else
            builder.ReqdExctnDt(group[:requested_date].to_date.iso8601)
          end
          builder.Dbtr do
            builder.Nm(account.name)
          end
          builder.DbtrAcct do
            builder.Id do
              builder.IBAN(account.iban)
            end
          end
          builder.DbtrAgt do
            builder.FinInstnId do
              if account.bic
                if schema_name == PAIN_001_001_09
                  builder.BICFI(account.bic)
                else
                  builder.BIC(account.bic)
                end
              elsif schema_name != PAIN_001_001_03_CH_02
                builder.Othr do
                  builder.Id('NOTPROVIDED')
                end
              end
            end
          end
          builder.ChrgBr('SLEV') if group[:service_level]

          transactions.each do |transaction|
            build_transaction(builder, transaction, schema_name)
          end
        end
      end
    end

    def build_transaction(builder, transaction, schema_name)
      builder.CdtTrfTxInf do
        builder.PmtId do
          builder.InstrId(transaction.instruction) if transaction.instruction.present?
          builder.EndToEndId(transaction.reference)
        end
        builder.Amt do
          builder.InstdAmt(format('%.2f', transaction.amount), Ccy: transaction.currency)
        end
        if transaction.bic
          builder.CdtrAgt do
            builder.FinInstnId do
              if schema_name == PAIN_001_001_09
                builder.BICFI(transaction.bic)
              else
                builder.BIC(transaction.bic)
              end
            end
          end
        end
        builder.Cdtr do
          builder.Nm(transaction.name)
          if transaction.creditor_address
            builder.PstlAdr do
              # Only set the fields that are actually provided.
              # StrtNm, BldgNb, PstCd, TwnNm provide a structured address
              # separated into its individual fields.
              # AdrLine provides the address in free format text.
              # Both are currently allowed and the actual preference depends on the bank.
              # Also the fields that are required legally may vary depending on the country
              # or change over time.
              builder.StrtNm transaction.creditor_address.street_name if transaction.creditor_address.street_name

              builder.BldgNb transaction.creditor_address.building_number if transaction.creditor_address.building_number

              builder.PstCd transaction.creditor_address.post_code if transaction.creditor_address.post_code

              builder.TwnNm transaction.creditor_address.town_name if transaction.creditor_address.town_name

              builder.Ctry transaction.creditor_address.country_code if transaction.creditor_address.country_code

              builder.AdrLine transaction.creditor_address.address_line1 if transaction.creditor_address.address_line1

              builder.AdrLine transaction.creditor_address.address_line2 if transaction.creditor_address.address_line2
            end
          end
        end
        builder.CdtrAcct do
          builder.Id do
            builder.IBAN(transaction.iban)
          end
        end
        if transaction.remittance_information
          builder.RmtInf do
            builder.Ustrd(transaction.remittance_information)
          end
        end
      end
    end
  end
end
