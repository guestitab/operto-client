module Operto
  # Including class must define FILTER_MAPPINGS (Hash), DATE_KEYS (Array<Symbol>), DEFAULT_SORT (String).
  module FilteredPagination
    FILTER_MAPPINGS = {}.freeze
    DATE_KEYS = [].freeze
    DEFAULT_SORT = ''.freeze

    private

    def validate_arguments!(attributes)
      argument! attributes: :invalid unless attributes.is_a?(Hash) && attributes.present? && attributes.values.none?(&:blank?)

      invalid_keys = attributes.keys - self.class::FILTER_MAPPINGS.keys
      argument! attributes: :invalid_keys if invalid_keys.any?
    end

    def build_query_params(attributes, skip, take)
      params = {
        per_page: take,
        page: skip.div(take) + 1,
        Sort: self.class::DEFAULT_SORT
      }

      attributes.each do |key, value|
        params[self.class::FILTER_MAPPINGS[key]] = format_attribute_value(key, value)
      end

      params
    end

    def format_attribute_value(key, value)
      self.class::DATE_KEYS.include?(key) ? value.strftime('%Y%m%d') : value
    end
  end
end
