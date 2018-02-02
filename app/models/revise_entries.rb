class ReviseEntries
  def call(entries)
    if in_parallel?
      revise_in_parallel(entries)
    else
      revise_in_sequence(entries)
    end
  end

  private

  def in_parallel?
    Rails.configuration.x.parallel_requests
  end

  def revise_in_parallel(entries)
    Parallel.map(filtered_entries(entries), in_processes: 8) do |entry|
      revise_entry(entry)
    end
  end

  def revise_in_sequence(entries)
    filtered_entries(entries).map do |entry|
      revise_entry(entry)
    end
  end
end
