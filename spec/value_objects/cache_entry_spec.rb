require 'rails_helper'

describe CacheEntry do
  let(:now) { Time.current.utc }
  before do
    allow(described_class).to receive(:current_time).and_return(now)
  end


  describe 'a new entry' do
    let(:new_entry) { described_class.new(data: data, expire_after: expire_after) }
    let(:data) { }
    let(:expire_after) { }

    context 'given :data' do
      let(:data) { 'data' }
      it 'stores the :data' do
        expect(new_entry.data).to eq('data')
      end
    end
    context 'given no :data' do
      it 'has nil in the data attribute' do
        expect(new_entry.data).to be_nil
      end
    end
    context 'given :expire_after' do
      let(:expire_after) { 'expire_after' }
      it 'stores the :expire_after' do
        expect(new_entry.expire_after).to eq('expire_after')
      end
    end
    context 'given no :expire_after' do
      it 'uses the default_expire_after' do
        expect(new_entry.expire_after).to eq(new_entry.default_expire_after)
      end
    end
  end

  describe '#default_expire_after' do
    context 'given a ttl' do
      let(:ttl) { 55 }
      it 'is the current time plus the given ttl' do
        expect(subject.default_expire_after(ttl)).to eq(now + 55.seconds)
      end
    end
    context 'given no ttl' do
      before do
        allow(ENV).to receive(:[]).with('SERVICE_TOKEN_CACHE_TTL').and_return("17")
      end
      it 'uses the SERVICE_TOKEN_CACHE_TTL environment variable' do
        expect(subject.default_expire_after).to eq(now + 17.seconds)
      end
    end
  end

  describe '#expired?' do
    context 'when expire_after is less than the current time' do
      before do
        subject.expire_after = now - 1.second
      end
      it 'returns true' do
        expect(subject.expired?).to eq(true)
      end
    end
    context 'when expire_after is more than the current time' do
      before do
        subject.expire_after = now + 1.second
      end
      it 'returns true' do
        expect(subject.expired?).to eq(false)
      end
    end
  end

  describe '.serialize' do
    it 'returns a string' do
      expect(described_class.serialize('my data')).to be_a(String)
    end

    describe 'the returned string' do
      let(:returned_string) { described_class.serialize('my data') }

      context 'when parsed as JSON' do
        let(:returned_string_parsed_as_json) { JSON.parse(returned_string) }
        it 'is valid' do
          expect{ JSON.parse(returned_string) }.to_not raise_error
        end

        it 'has the given data' do
          expect(returned_string_parsed_as_json['data']).to eq('my data')
        end
      end
    end
  end

  describe '.deserialize' do

    context 'given valid JSON' do
      let(:json) { '{"data": "69ba765b88c9d0a52a1379328b5ae09f", "expire_after": "2018-09-25T11:46:11.844Z"}' }

      it 'returns a CacheEntry' do
        expect(described_class.deserialize(json)).to be_a(CacheEntry)
      end

      describe 'the returned CacheEntry' do
        let(:returned_cache_entry) { described_class.deserialize(json) }
        it 'has the data from the JSON' do
          expect(returned_cache_entry.data).to eq('69ba765b88c9d0a52a1379328b5ae09f')
        end
        it 'has the expire_after from the JSON' do
          expect(returned_cache_entry.expire_after).to eq('2018-09-25T11:46:11.844Z')
        end

      end
    end
  end

end
