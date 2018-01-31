require 'rails_helper'

describe ReviseEvents do
  it 'revises event entries from Elixir Radar' do
    consistent_entry = {
      title: 'ElixirConf',
      url: 'http://elixirconf.com/',
      description: 'ElixirConf™ US - Bellevue, WA, September 5-8, 2017.',
      tag: 'event'
    }

    divergent_entry = {
      title: 'EmpEx -- Halloween Lightning Talks 2016',
      url: 'http://empex.co/',
      description: 'Call for Proposals now open\n        <br>',
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
    expect(divergent_result_entry[:divergences].first[:details][:fetched_page_title]).to eq('EMPEX')
  end

  context 'when events are from Meetup.com' do
    it 'revises a event entry with consistent title' do
      entry = {
        title: "Let's talk Elixir",
        url: 'https://www.meetup.com/Baltimore-Elixir-and-Erlang-Meetup/events/246844011/',
        description: 'Wednesday, January 31, 2018 - Baltimore, MD, USA',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      consistent_result_entry = revision_result.first
      expect(consistent_result_entry[:entry_title]).to eq("Let's talk Elixir")
      expect(consistent_result_entry[:divergences]).to be_empty
    end

    it 'revises a event entry with divergent title' do
      entry = {
        title: 'Elixir PoA Tech Talks',
        url: 'https://www.meetup.com/Baltimore-Elixir-and-Erlang-Meetup/events/246844011/',
        description: 'Wednesday, January 31, 2018 - Baltimore, MD, USA',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Elixir PoA Tech Talks')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('event_title_does_not_match')
      expect(divergent_result_entry[:divergences].first[:details][:given_event_title]).to eq('Elixir PoA Tech Talks')
      expect(divergent_result_entry[:divergences].first[:details][:fetched_event_title]).to eq("Let's talk Elixir")
    end

    it 'revises a event entry with divergent date' do
      entry = {
        title: 'Under the Covers with Agents, Tasks, and Supervisors',
        url: 'https://www.meetup.com/KC-Elixir-Users-Group/events/246687381/',
        description: 'Thursday, February 10, 2018 - Merriam, KS, USA',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Under the Covers with Agents, Tasks, and Supervisors')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to include('event_description_does_not_match')
      expect(divergent_result_entry[:divergences].first[:details][:given_event_description]).to eq('Thursday, February 10, 2018 - Merriam, KS, USA')
      expect(divergent_result_entry[:divergences].first[:details][:fetched_event_description]).to eq('Thursday, February 1, 2018 - Merriam, KS, USA')
    end

    it 'revises a event entry with divergent location' do
      entry = {
        title: 'Think and design your Elixir systems for concurrency',
        url: 'https://www.meetup.com/Elixir-Lunch/events/246847199/',
        description: 'Thursday, February 1, 2018 - New York, NY, USA',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Think and design your Elixir systems for concurrency')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to include('event_description_does_not_match')
      expect(divergent_result_entry[:divergences].first[:details][:given_event_description]).to eq('Thursday, February 1, 2018 - New York, NY, USA')
      expect(divergent_result_entry[:divergences].first[:details][:fetched_event_description]).to eq('Thursday, February 1, 2018 - Lehi, UT, USA')
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
        title: 'Releasing Hex packages and neural networks',
        url: 'http://www.meetup.com/indyelixirr/events/233392329/',
        tag: 'event'
      }

      revision_result = ReviseEvents.new.call([entry])

      divergent_result_entry = revision_result.first
      expect(divergent_result_entry[:entry_title]).to eq('Releasing Hex packages and neural networks')
      expect(divergent_result_entry[:divergences]).to be_present
      expect(divergent_result_entry[:divergences].first[:reason]).to eq('connection_error')
      expect(divergent_result_entry[:divergences].first[:details][:error_message]).to include('Mechanize::ResponseCodeError: 404 => Net::HTTPNotFound')
    end
  end
end
