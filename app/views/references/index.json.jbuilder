json.array!(@references) do |reference|
  json.extract! reference, :id, :key, :title
  json.url reference_url(reference, format: :json)
end
