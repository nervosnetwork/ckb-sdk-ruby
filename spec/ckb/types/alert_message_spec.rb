RSpec.describe CKB::Types::AlertMessage do
  let(:alert_message_h) do
    {
      "id": "0x2a",
      "message": "An example alert message!",
      "notice_until": "0x24bcca57c00",
      "priority": "0x1"
  }
  end

  let(:alert_message) { CKB::Types::AlertMessage.from_h(alert_message_h) }

  it "from h" do
    expect(alert_message).to be_a(CKB::Types::AlertMessage)
    expect(alert_message.message).to eq alert_message_h[:message]
    %i(id notice_until priority).each do |key|
      expect(alert_message.public_send(key)).to eq alert_message_h[key].hex
    end
  end

  it "to_h" do
    expect(
      alert_message.to_h
    ).to eq (alert_message_h)
  end
end
