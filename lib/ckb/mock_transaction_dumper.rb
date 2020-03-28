# frozen_string_literal: true

module CKB
  class MockTransactionDumper
    attr_reader :api, :transaction

    def initialize(api, transaction)
      @api = api
      @transaction = transaction
    end

    def dump
      mock_inputs = transaction.inputs.map do |input|
        tx = api.get_transaction(input.previous_output.tx_hash).transaction
        output = tx.outputs[input.previous_output.index]
        data = tx.outputs_data[input.previous_output.index]
        {
          input: input.to_h,
          output: output.to_h,
          data: data
        }
      end
      mock_cell_deps = transaction.cell_deps.map do |cell_dep|
        # TODO: add group cell dep support once we have molecule parser in
        # Ruby to parse group cell dep contents.
        raise "Group cell dep is not supported yet" unless cell_dep.dep_type == "code"
        cell_with_status = api.get_live_cell(cell_dep.out_point, true)
        unless cell_with_status && cell_with_status.cell
          raise "Cannot find cell dep: #{cell_dep.out_point}"
        end
        {
          cell_dep: cell_dep.to_h,
          output: cell_with_status.cell.output.to_h,
          data: cell_with_status.cell.data.content
        }
      end
      mock_headers = transaction.header_deps.map do |header_dep|
        header = api.get_header(header_dep)
        raise "Cannot find header: #{header_dep}" unless header
        header.to_h
      end
      {
        mock_info: {
          inputs: mock_inputs,
          cell_deps: mock_cell_deps,
          header_deps: mock_headers
        },
        tx: transaction.to_raw_transaction_h
      }
    end

    def write(file)
      File.write(file, JSON.pretty_generate(dump))
    end
  end
end
