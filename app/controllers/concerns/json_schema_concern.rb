module JsonSchemaConcern
  extend ActiveSupport::Concern
  include ErrorMessagesConcern

  private

  def health_schema
    {
      type: 'object',
      properties: {
        health: build_health_properties
      },
      required: ['health']
    }
  end

  def build_health_properties
    {
      type: 'object',
      properties: {
        id: { type: 'string' },
        data: { type: 'string' },
        message: { type: 'string' },
        settings: build_settings_schema,
        metadata: build_metadata_schema,
        tags: { type: 'array', items: { type: 'string' } },
        nested_data: build_nested_data_schema
      },
      additionalProperties: false
    }
  end

  def build_settings_schema
    {
      type: 'object',
      properties: {
        enabled: { type: 'boolean' },
        timeout: { type: 'integer', minimum: 1, maximum: 100 },
        retry_count: { type: 'integer', minimum: 0, maximum: 10 }
      },
      additionalProperties: false
    }
  end

  def build_metadata_schema
    {
      type: 'object',
      properties: {
        version: { type: 'string', pattern: '^\\d+\\.\\d+\\.\\d+$' },
        created_at: { type: 'string', format: 'date-time' },
        tags: { type: 'array', items: { type: 'string' } }
      },
      additionalProperties: false
    }
  end

  def build_nested_data_schema
    {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          name: { type: 'string' },
          value: { type: 'integer', minimum: 0 },
          sub_items: build_sub_items_schema
        },
        required: ['name', 'value'],
        additionalProperties: false
      }
    }
  end

  def build_sub_items_schema
    {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'integer' },
          label: { type: 'string' }
        },
        required: ['id', 'label'],
        additionalProperties: false
      }
    }
  end

  def validate_json_schema(data, schema)
    JSON::Validator.validate!(schema, data)
    true
  rescue JSON::Schema::ValidationError => e
    error_config = get_error_message(:schema_validation)
    render_error(**error_config, details: e.message, status: :bad_request)
    false
  end
end 