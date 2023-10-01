class ApplicationController < ActionController::API
  def render_jsonapi(object, serializer, status: :ok)
    render json: serializer.new(object).serializable_hash.to_json, status:
  end

  def ping
    render json: { status: 'ok' }, status: :ok
  end
end
