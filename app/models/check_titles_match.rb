class CheckTitlesMatch
  def call(given_title, fetched_title)
    !!(fetched_title =~ as_regexp(given_title))
  end

  private

  def as_regexp(term)
    ignoring_case(escaping(term))
  end

  def ignoring_case(term)
    Regexp.new(
      term,
      Regexp::IGNORECASE
    )
  end

  def escaping(term)
    Regexp.escape(term)
  end
end
