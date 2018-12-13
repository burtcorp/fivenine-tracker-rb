require 'net/http'
require 'uri'
require 'securerandom'
require 'json'

module FiveNine
  class Tracker
    VERSION = '0.0.1'.freeze

    def initialize(entity_id, opts = {})
      @entity_id = entity_id
      @opts = opts
      raise ArgumentError, "Invalid device ID: #{@opts[:device_id]}" unless valid_id?(opts[:device_id])
      raise ArgumentError, "Invalid entity ID: #{entity_id}" unless valid_id?(entity_id)
    end

    def track_event(event_name, properties = {})
      query = {
        type: 'customevent',
        v: 1,
        sn: 1,
        ct: 0,
        e: @entity_id,
        ui: @opts[:device_id],
        av: "v#{VERSION}-rb",
        id: generator.call,
        nm: event_name,
        pv: JSON.dump(properties)
      }
      log_url_base = @opts[:log_url_base] || default_log_url_base
      uri = sprintf("%s?%s", log_url_base, URI.encode_www_form(query))
      http_client.get(URI(uri))
    end

    private

    DEFAULT_LOG_URL_BASE_FORMAT = 'https://%s.c.richmetrics.com/log'

    def valid_id?(id)
      id && id =~ /\A[A-Z0-9]{12}\Z/i
    end

    def http_client
      @http_client = @opts[:http_client] || Net::HTTP
    end

    def default_log_url_base
      sprintf(DEFAULT_LOG_URL_BASE_FORMAT, @entity_id.downcase)
    end

    def generator
      @generator ||= @opts[:id_generator] || IdGenerator.new
    end

    class IdGenerator
      def initialize(time=Time)
        @time = time
      end

      def call
        time_part = @time.now.to_i % 36 ** 6
        rand_part = rand(36 ** 6)
        full_id = time_part * 36 ** 6 + rand_part
        (full_id - full_id % 37).to_s(36).upcase.rjust(12, '0')
      end
    end
  end
end
