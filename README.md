# 5x9 Tracker

## Setup

This is a tracker SDK library for 5x9. Add it to your `Gemfile`:

```bash
gem 'fivenine-tracker'
```

## Usage

```ruby
require 'fivenine/tracker'

tracker = FiveNine::Tracker.new(entity_id, device_id: device_id)
tracker.track_event('name', { foo: 'bar' })
```

Supply the `entity_id` that's been given to you. The `device_id` is a unique and persistent identifier for the current device, a 12 character alpha-numeric string.
