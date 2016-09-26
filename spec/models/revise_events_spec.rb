require 'rails_helper'

describe ReviseEvents do
  it 'revises event entries from Elixir Radar' do
    consistent_entry = {
      title: 'ElixirConf',
      url: 'http://elixirconf.com/',
      subtitle: 'Conference = (DOLAR)450; Conference + Training = (DOLAR)700. (expiration: August 22)\n            <br>',
      tag: 'event'
    }

    divergent_entry = {
      title: 'EmpEx -- Halloween Lightning Talks 2016',
      url: 'http://empex.co/',
      subtitle: 'Call for Proposals now open\n        <br>',
      tag: 'event'
    }

    entries = [consistent_entry, divergent_entry]

    revision_result = ReviseEvents.new.call(entries)

    expect(revision_result.size).to eq(2)

    consistent_result_entry = revision_result.first
    expect(consistent_result_entry[:entry_title]).to eq('ElixirConf')
    expect(consistent_result_entry[:divergences]).to be_empty

    divergent_result_entry = revision_result.last
    expect(divergent_result_entry[:entry_title]).to eq('EmpEx -- Halloween Lightning Talks 2016')
    expect(divergent_result_entry[:divergences]).to be_present
    expect(divergent_result_entry[:divergences].first[:reason]).to eq('page_title_does_not_match')
    expect(divergent_result_entry[:divergences].first[:details][:given_page_title]).to eq('EmpEx -- Halloween Lightning Talks 2016')
    expect(divergent_result_entry[:divergences].first[:details][:fetched_page_title]).to eq('Empire City Elixir Conf')
  end

  context 'when events are from Meetup.com' do
    it 'revises a event entry with consistent title' do
      entry = {
        title: 'Sarasota, FL',
        url: 'https://www.meetup.com/SarasotaSoftwareEngineers/events/232976666/',
        subtitle: 'Concurrent Programming with the Elixir ecosystem',
        description: 'Wednesday, August 31, 2016',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      consistent_result_entry = revision_result.first
      expect(consistent_result_entry[:entry_title]).to eq('Sarasota, FL')
      expect(consistent_result_entry[:divergences]).to be_empty
    end

    it 'revises a event entry with divergent title' do
      entry = {
        title: 'Indianapolis­, IN',
        url: 'http://www.meetup.com/indyelixir/events/233392329/',
        subtitle: 'Releasing Hex packages and neural networks',
        description: 'Tuesday, September 6, 2016',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Indianapolis­, IN')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('event_title_does_not_match')
      expect(divergent_result_entry[:divergences].first[:details][:given_event_title]).to eq('Releasing Hex packages and neural networks')
      expect(divergent_result_entry[:divergences].first[:details][:fetched_event_title]).to eq('Indy Elixir Monthly Meetup')
    end

    it 'revises an event entry with consistent event date (past event)' do
      entry = {
        title: 'Tucson, AZ',
        url: 'https://www.meetup.com/Tucson-Elixir-Meetup/events/233396783/',
        subtitle: 'Nerves - Embedded Elixir, ElixirConf Roundup',
        description: 'Wednesday, September 7, 2016',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Tucson, AZ')
      # TODO: Should we also assert how many divergences have been captured?
      expect(divergent_result_entry[:divergences]).to be_empty
    end

    it 'revises an event entry with divergent event date (past event)' do
      entry = {
        title: 'Tucson, AZ',
        url: 'https://www.meetup.com/Tucson-Elixir-Meetup/events/233396783/',
        subtitle: 'Nerves - Embedded Elixir, ElixirConf Roundup',
        description: 'Wednesday, September 6, 2016',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Tucson, AZ')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('event_date_does_not_match')
      expect(divergent_result_entry[:divergences].first[:details][:given_event_date]).to eq('Wednesday, September 6, 2016')
      expect(divergent_result_entry[:divergences].first[:details][:fetched_event_date]).to eq('September 7 · 7:00 PM')
    end

    it 'revises an event entry with consistent event date (few days ago)' do
      entry = {
        title: 'Lisbon, Portugal',
        url: 'http://www.meetup.com/lisbon-elixir/events/232868915/',
        subtitle: 'How are people using Elixir in their jobs?',
        description: 'Friday, September 16, 2016',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Lisbon, Portugal')
      expect(divergent_result_entry[:divergences]).to be_empty
    end

    it 'revises an event entry with divergent event date (few days ago)' do
      entry = {
        title: 'Lisbon, Portugal',
        url: 'http://www.meetup.com/lisbon-elixir/events/232868915/',
        subtitle: 'How are people using Elixir in their jobs?',
        description: 'Friday, September 20, 2016',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Lisbon, Portugal')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('event_date_does_not_match')
      expect(divergent_result_entry[:divergences].first[:details][:given_event_date]).to eq('Friday, September 20, 2016')
      expect(divergent_result_entry[:divergences].first[:details][:fetched_event_date]).to eq('4 days ago · 7:00 PM')
    end

    it 'revises an event entry with consistent event date (future event)' do
      entry = {
        title: 'Nashville, TN',
        url: 'https://www.meetup.com/nashville-software-beginners/events/233710900/',
        subtitle: 'Intro to Elixir and Phoenix',
        description: 'Thursday, September 22, 2016',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Nashville, TN')
      expect(divergent_result_entry[:divergences]).to be_empty
    end

    it 'revises an event entry with divergent event date (future event)' do
      entry = {
        title: 'Nashville, TN',
        url: 'https://www.meetup.com/nashville-software-beginners/events/233710900/',
        subtitle: 'Intro to Elixir and Phoenix',
        description: 'Thursday, September 21, 2016',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Nashville, TN')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('event_date_does_not_match')
      expect(divergent_result_entry[:divergences].first[:details][:given_event_date]).to eq('Thursday, September 21, 2016')
      expect(divergent_result_entry[:divergences].first[:details][:fetched_event_date]).to eq('Thursday, September 22, 2016 6:00 PM')
    end
  end

  context 'when accessing the entry url raises an error' do
    it 'revises a divergent event entry' do
      entry = {
        title: 'São Paulo, SP',
        url: 'https://sp.femug.com/t/femug-sp-34-plataformatec/865',
        subtitle: '',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('São Paulo, SP')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('connection_error')
      expect(divergent_result_entry[:divergences].first[:details][:error_message]).to eq('OpenSSL::SSL::SSLError: SSL_connect returned=1 errno=0 state=error: certificate verify failed')
    end

    it 'revises as a divergent entry from meetup.com' do
      entry = {
        title: 'Indianapolis­, IN',
        url: 'http://www.meetup.com/indyelixirr/events/233392329/',
        subtitle: 'Releasing Hex packages and neural networks',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Indianapolis­, IN')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('connection_error')
      expect(divergent_result_entry[:divergences].first[:details][:error_message]).to eq('Mechanize::ResponseCodeError: 404 => Net::HTTPNotFound for http://www.meetup.com/indyelixirr/events/233392329/ -- unhandled response')
    end
  end
end
