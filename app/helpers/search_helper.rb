module SearchHelper
  def search_form(path, label, id: nil)
    html_id = 'search_' + (id || label)
    form_tag(path, method: :get, 'data-turboform' => true) do
      concat label_tag(html_id, label.capitalize + ' :')
      concat ' '
      concat text_field_tag(:query, nil, id: html_id)
      concat ' '
      concat submit_tag('Search')
    end
  end
end
