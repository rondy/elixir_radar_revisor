class IterateOverEntries
  def call(entries, &block)
    if in_parallel?
      revise_in_parallel(entries, &block)
    else
      revise_in_sequence(entries, &block)
    end
  end

  private

  def in_parallel?
    Rails.configuration.x.parallel_requests
  end

  def revise_in_parallel(entries, &block)
    Parallel.map(entries, in_processes: 8, &block)
  end

  def revise_in_sequence(entries, &block)
    entries.map(&block)
  end
end
