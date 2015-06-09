json.array!(@raw_bibtex_entries) do |raw_bibtex_entry|
  json.extract! raw_bibtex_entry, :id
  json.url raw_bibtex_entry_url(raw_bibtex_entry, format: :json)
end
