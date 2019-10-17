# frozen_string_literal: true

RSpec.describe CKB::Types::Transaction do
  let(:transaction_h) do
    {
      "version": "0x0",
      "cell_deps": [
        {
          "out_point": {
            "tx_hash": "0xc12386705b5cbb312b693874f3edf45c43a274482e27b8df0fd80c8d3f5feb8b",
            "index": "0x0"
          },
          "dep_type": "dep_group"
        },
        {
          "out_point": {
            "tx_hash": "0x0fb4945d52baf91e0dee2a686cdd9d84cad95b566a1d7409b970ee0a0f364f60",
            "index": "0x2"
          },
          "dep_type": "code"
        }
      ],
      "header_deps": [],
      "inputs": [
        {
          "previous_output": {
            "tx_hash": "0x31f695263423a4b05045dd25ce6692bb55d7bba2965d8be16b036e138e72cc65",
            "index": "0x1"
          },
          "since": "0x0"
        }
      ],
      "outputs": [
        {
          "capacity": "0x174876e800",
          "lock": {
            "code_hash": "0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
            "args": "0x59a27ef3ba84f061517d13f42cf44ed020610061",
            "hash_type": "type"
          },
          "type": {
            "code_hash": "0xece45e0979030e2f8909f76258631c42333b1e906fd9701ec3600a464a90b8f6",
            "args": "0x",
            "hash_type": "data"
          }
        },
        {
          "capacity": "0x59e1416a5000",
          "lock": {
            "code_hash": "0x68d5438ac952d2f584abf879527946a537e82c7f3c1cbf6d8ebf9767437d8e88",
            "args": "0x59a27ef3ba84f061517d13f42cf44ed020610061",
            "hash_type": "type"
          },
          "type": nil
        }
      ],
      "outputs_data": ["0x1234", "0x"],
      "witnesses": [
        "0x82df73581bcd08cb9aa270128d15e79996229ce8ea9e4f985b49fbf36762c5c37936caf3ea3784ee326f60b8992924fcf496f9503c907982525a3436f01ab32900"
      ]
    }
  end

  let(:transaction) { CKB::Types::Transaction.from_h(transaction_h) }

  it "compute size" do
    expect(transaction.serialized_size_in_block).to eq 536
  end

  context "self.fee" do
    it "carry" do
      fee = CKB::Types::Transaction.fee(1035, 900)
      expect(fee).to eq 932
    end

    it "no carry" do
      fee = CKB::Types::Transaction.fee(1035, 1000)
      expect(fee).to eq 1035
    end
  end

  it "fee" do
    fee = transaction.fee(1000)
    expect(fee).to eq 536
  end

  context "TransactionSize" do
    it "eq tx.serialized_tx_fee" do
      size_without_witness =
        CKB::TransactionSize.base_size +
        CKB::TransactionSize.every_cell_dep * 2 +
        CKB::TransactionSize.every_input +
        transaction.outputs.map { |output| CKB::TransactionSize.every_output(output) }.reduce(:+) +
        transaction.outputs_data.map { |data| CKB::TransactionSize.every_outputs_data(data) }.reduce(:+)

      expect(size_without_witness + transaction.witnesses.map { |witness| CKB::TransactionSize.every_witness(witness) }.reduce(:+)).to eq transaction.serialized_size_in_block
      expect(size_without_witness + CKB::TransactionSize.every_secp_witness).to eq transaction.serialized_size_in_block
    end
  end
end
