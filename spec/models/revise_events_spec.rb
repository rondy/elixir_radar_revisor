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
    expect(divergent_result_entry[:divergences].first[:details][:fetched_page_title]).to eq('Empire City Elixir Conf')
  end
end
