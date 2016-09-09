module ApplicationHelper
  def present_divergence_reason(reason)
    {
      'page_title_does_not_match' => 'Título da página não confere',
    }[reason] || ''
  end

  def present_divergence_detail(field)
    {
      fetched_page_title: 'Título da página obtido'
    }[field] || ''
  end
end
