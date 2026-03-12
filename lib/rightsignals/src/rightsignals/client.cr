module RightSignals
  class Error < Exception; end
  class AuthError < Error; end
  class NotFoundError < Error; end

  class Client
    property base_url : String
    property token : String

    def initialize(@base_url : String = "https://app.rightsignals.com", @token : String = "")
    end

    def list_traces(service_id : Int64? = nil, environment : String? = nil, limit : Int32? = nil) : Array(TraceSummary)
      params = URI::Params.new
      params["service_id"] = service_id.to_s if service_id
      params["environment"] = environment if environment
      params["limit"] = limit.to_s if limit
      Array(TraceSummary).from_json(get("/api/v1/traces", params))
    end

    def get_trace(id : Int64) : TraceDetail
      TraceDetail.from_json(get("/api/v1/traces/#{id}"))
    end

    def list_issues(service_id : Int64? = nil, environment : String? = nil, status : String? = nil, limit : Int32? = nil) : Array(IssueSummary)
      params = URI::Params.new
      params["service_id"] = service_id.to_s if service_id
      params["environment"] = environment if environment
      params["status"] = status if status
      params["limit"] = limit.to_s if limit
      Array(IssueSummary).from_json(get("/api/v1/issues", params))
    end

    def get_issue(id : Int64) : IssueDetail
      IssueDetail.from_json(get("/api/v1/issues/#{id}"))
    end

    def list_occurrences(service_id : Int64? = nil, environment : String? = nil, exception_type : String? = nil, limit : Int32? = nil) : Array(OccurrenceSummary)
      params = URI::Params.new
      params["service_id"] = service_id.to_s if service_id
      params["environment"] = environment if environment
      params["exception_type"] = exception_type if exception_type
      params["limit"] = limit.to_s if limit
      Array(OccurrenceSummary).from_json(get("/api/v1/occurrences", params))
    end

    def get_occurrence(id : Int64) : OccurrenceDetail
      OccurrenceDetail.from_json(get("/api/v1/occurrences/#{id}"))
    end

    def list_events(service_id : Int64? = nil, prompt_id : String? = nil, user_email : String? = nil, limit : Int32? = nil) : Array(EventSummary)
      params = URI::Params.new
      params["service_id"] = service_id.to_s if service_id
      params["prompt_id"] = prompt_id if prompt_id
      params["user_email"] = user_email if user_email
      params["limit"] = limit.to_s if limit
      Array(EventSummary).from_json(get("/api/v1/events", params))
    end

    def get_event(id : Int64) : EventDetail
      EventDetail.from_json(get("/api/v1/events/#{id}"))
    end

    private def get(path : String, params : URI::Params = URI::Params.new) : String
      uri = URI.parse(base_url)
      uri.path = path
      uri.query = params.to_s unless params.empty?

      response = HTTP::Client.get(uri, headers: auth_headers)
      handle_response(response)
    end

    private def auth_headers : HTTP::Headers
      HTTP::Headers{"Authorization" => "Bearer #{token}", "Accept" => "application/json"}
    end

    private def handle_response(response : HTTP::Client::Response) : String
      case response.status_code
      when 200 then response.body
      when 401 then raise AuthError.new("Unauthorized — check your API token")
      when 404 then raise NotFoundError.new("Not found")
      else          raise Error.new("HTTP #{response.status_code}: #{response.body}")
      end
    end
  end
end
