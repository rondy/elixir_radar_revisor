require 'rails_helper'

describe CheckTitlesMatch do
  it 'returns true when both titles have the same terms' do
    given = 'Elm and Elixir in the real world'
    fetched = 'Elm and Elixir in the real world'

    expect(CheckTitlesMatch.new.call(given, fetched)).to eq(true)
  end

  it 'returns true when there is any special-regexp character' do
    given = 'Elm + Elixir in the real world'
    fetched = 'Elm + Elixir in the real world'

    expect(CheckTitlesMatch.new.call(given, fetched)).to eq(true)
  end

  it 'returns true when fetched title has more text besides the similar part' do
    given = 'The Pursuit of Instant Pushes'
    fetched = 'The Pursuit of Instant Pushes - Football Addicts Tech Blog'

    expect(CheckTitlesMatch.new.call(given, fetched)).to eq(true)
  end

  it 'returns true when there are differences regarding text case' do
    given = 'Passwordless login with Phoenix'
    fetched = 'Passwordless login with phoenix'

    expect(CheckTitlesMatch.new.call(given, fetched)).to eq(true)
  end

  it 'returns false when given titles are different' do
    given = 'Scheduling Your Kubernetes Pods With Elixir'
    fetched = 'Preemptive scheduling of Erlang NIFs'

    expect(CheckTitlesMatch.new.call(given, fetched)).to eq(false)
  end
end
