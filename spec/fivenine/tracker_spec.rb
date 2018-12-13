require 'spec_helper'

class FakeClient
  def initialize(requests)
    @requests = requests
  end

  def get(uri)
    @requests << uri
  end
end

class FakeIdGenerator
  def call
    'GENGENGENGEN'
  end
end

module FiveNine
  describe Tracker do
    let :requests do
      []
    end

    let :entity_id do
      'FOOBARBAZQUX'
    end

    let :options do
      {
        http_client: FakeClient.new(requests),
        id_generator: FakeIdGenerator.new,
        device_id: 'DEVDEVDEVDEV'
      }
    end

    subject :tracker do
      described_class.new(entity_id, options)
    end

    describe '.new' do
      it 'complains when given an invalid device_id' do
        options[:device_id] = 'not12chars'
        expect { tracker }.to raise_error(/invalid device id/i)
      end

      it 'complains when given an invalid entity_id' do
        entity_id.replace('not12chars')
        expect { tracker }.to raise_error(/invalid entity ID/i)
      end
    end

    describe '#track_event' do
      context 'sends an HTTP request that' do
        it 'logs to <entity id>.c.richmetrics.com by default' do
          tracker.track_event('foo')
          expect(requests.size).to be(1)
          expect(requests.first.hostname).to eq('foobarbazqux.c.richmetrics.com')
          expect(requests.first.scheme).to eq('https')
        end

        it 'logs to a custom URL when the option is given' do
          options[:log_url_base] = 'http://log.5x9.io/receive'
          tracker.track_event('foo')
          expect(requests.size).to be(1)
          expect(requests.first.hostname).to eq('log.5x9.io')
          expect(requests.first.scheme).to eq('http')
          expect(requests.first.path).to eq('/receive')
        end

        it 'has type parameter equal to "customevent"' do
          tracker.track_event('foo')
          expect(requests.first.query).to match(/(^|&)type=customevent(&|$)/)
        end

        it 'has v parameter equal to "1"' do
          tracker.track_event('foo')
          expect(requests.first.query).to match(/(^|&)v=1(&|$)/)
        end

        it 'has an sn parameter equal to "1"' do
          tracker.track_event('foo')
          expect(requests.first.query).to match(/(^|&)sn=1(&|$)/)
        end

        it 'has an ct parameter equal to "0"' do
          tracker.track_event('foo')
          expect(requests.first.query).to match(/(^|&)ct=0(&|$)/)
        end

        it 'has an e parameter equal to the entity_id option' do
          tracker.track_event('foo')
          expect(requests.first.query).to match(/(^|&)e=FOOBARBAZQUX(&|$)/)
        end

        it 'has an ui parameter as given by the option device_id' do
          tracker.track_event('foo')
          expect(requests.first.query).to match(/(^|&)ui=DEVDEVDEVDEV(&|$)/)
        end

        it 'has an av parameter indicating the SDK version' do
          tracker.track_event('foo')
          expect(requests.first.query).to match(/(^|&)av=v#{FiveNine::Tracker::VERSION}-rb(&|$)/)
        end

        it 'has an id parameter generated by the random generator' do
          tracker.track_event('foo')
          expect(requests.first.query).to match(/(^|&)id=GENGENGENGEN(&|$)/)
        end

        it 'has an nm parameter equal to the given name' do
          tracker.track_event('my-event')
          expect(requests.first.query).to match(/(^|&)nm=my-event(&|$)/)
        end

        it 'has an pv parameter with JSON serialized event properties' do
          tracker.track_event('foo', foo: 'bar')
          expect(requests.first.query).to match(/(^|&)pv=%7B%22foo%22%3A%22bar%22%7D(&|$)/)
        end

        it 'has an pv parameter with JSON serialized empty hash when no properties are given' do
          tracker.track_event('foo')
          expect(requests.first.query).to match(/(^|&)pv=%7B%7D(&|$)/)
        end
      end
    end
  end

  describe Tracker::IdGenerator do
    let :now do
      1234567890
    end

    let :time do
      double(:time, now: now)
    end

    let :id_generator do
      described_class.new(time)
    end

    describe '#call' do
      it 'generates an id on the correct format' do
        id_generator.call.should =~ /^[0-9A-Z]{12}$/
      end

      it 'generates "unique" ids' do
        first_id = id_generator.call
        second_id = id_generator.call
        second_id.should_not == first_id
      end

      it 'bases first half of the id on current time' do
        id_generator.call[0,6].to_i(36).should be_between(now - 37, now)
      end

      it 'ensures the id is divisible by 37' do
        (id_generator.call.to_i(36) % 37).should be_zero
      end
    end
  end
end