module JsonSchemaConcern
  extend ActiveSupport::Concern

  private

  def health_schema
    {
      type: 'object',
      properties: {
        health: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            data: { type: 'string' },
            message: { type: 'string' },
            settings: {
              type: 'object',
              properties: {
                enabled: { type: 'boolean' },
                timeout: { 
                  type: 'integer', 
                  minimum: 1, 
                  maximum: 100 
                },
                retry_count: { 
                  type: 'integer', 
                  minimum: 0, 
                  maximum: 10 
                }
              },
              additionalProperties: false
            },
            metadata: {
              type: 'object',
              properties: {
                version: { 
                  type: 'string', 
                  pattern: '^\\d+\\.\\d+\\.\\d+$' 
                },
                created_at: { 
                  type: 'string', 
                  format: 'date-time' 
                },
                tags: { 
                  type: 'array', 
                  items: { type: 'string' } 
                }
              },
              additionalProperties: false
            },
            tags: { 
              type: 'array', 
              items: { type: 'string' } 
            },
            nested_data: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  value: { 
                    type: 'integer', 
                    minimum: 0 
                  },
                  sub_items: {
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
                },
                required: ['name', 'value'],
                additionalProperties: false
              }
            }
          },
          additionalProperties: false
        }
      },
      required: ['health']
    }
  end

  def validate_json_schema(data, schema)
    JSON::Validator.validate!(schema, data)
    true
  rescue JSON::Schema::ValidationError => e
    render_error(
      code: 'SCHEMA_VALIDATION_ERROR',
      message: 'JSON Schema validation failed',
      details: e.message,
      status: :bad_request
    )
    false
  end
end 