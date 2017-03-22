require 'oystercard'

describe Oystercard do

  let(:journey) { Journey.new }
  let(:station) {double :station}

  describe '#initialize' do
    it 'has a balance of 0' do
      expect(subject.balance).to eq 0
    end

    it 'has an empty journey history' do
      expect(subject.journeys).to eq []
    end
  end

  it 'adds money to the balance' do
    expect{ subject.top_up 10 }.to change{ subject.balance }.by 10
  end

  it "raises an error when maximum balance is exceeded" do
    maximum_balance = Oystercard::MAXIMUM_BALANCE
    subject.top_up(maximum_balance)
    expect{subject.top_up(1)}.to raise_error "Maximum balance of #{maximum_balance} exceeded"
  end

  describe '#in_journey?' do
    it 'is initially not in a journey' do
      expect(subject).not_to be_in_journey
    end
  end

  describe '#touch_in' do

    context 'success cases' do
      before do
        subject.top_up(5)
        subject.touch_in(station)
      end

      it 'can touch in' do
        expect(subject).to be_in_journey
      end

      it 'records the entry station' do
        expect(subject.entry_station).to eq station
      end
    end

    it 'checks minimum balance' do
      message = "Minimum £1 needed to touch in"
      expect{ subject.touch_in(station) }.to raise_error message
    end

  end

  describe '#touch_out' do

    context 'verifying entry and exit data' do
      before do
        subject.top_up(5)
        subject.touch_in(station)
        subject.touch_out(station)
      end
      it 'can touch out' do
        expect(subject).not_to be_in_journey
      end

      it 'resets entry station to nil' do
        expect(subject.entry_station).to be_nil
      end

      it 'records the exit station' do
        expect(subject.journeys).to include({station => station})
      end
    end

    it 'deducts minimum fare' do
      expect {subject.touch_out(station)}.to change{subject.balance}.by(-1)
    end

  end
end
