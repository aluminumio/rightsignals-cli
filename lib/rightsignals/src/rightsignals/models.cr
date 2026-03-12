module RightSignals
  struct TraceSummary
    include JSON::Serializable
    property id : Int64
    property trace_id : String
    property service : String
    property environment : String?
    property release : String?
    property root_span : String?
    property duration : String?
    property span_count : Int32
    property started_at : String?
  end

  struct Span
    include JSON::Serializable
    property span_id : String
    property parent_span_id : String?
    property operation : String
    property kind : Int32?
    property status_code : Int32?
    property status_message : String?
    property duration : String?
    property duration_ns : Int64?
    property started_at : String?
    property ended_at : String?
    property attributes : JSON::Any?
    property events : JSON::Any?
    property error : Bool?
    property occurrences : Array(OccurrenceRef)?
  end

  struct OccurrenceRef
    include JSON::Serializable
    property id : Int64
    property exception_type : String
    property message : String?
  end

  struct TraceDetail
    include JSON::Serializable
    property id : Int64
    property trace_id : String
    property service : String
    property environment : String?
    property release : String?
    property root_span : String?
    property duration : String?
    property duration_ns : Int64?
    property started_at : String?
    property span_count : Int32
    property spans : Array(Span)
  end

  struct IssueSummary
    include JSON::Serializable
    property id : Int64
    property summary : String
    property exception_type : String
    property service : String
    property environment : String?
    property status : String
    property regressed : Bool
    property occurrence_count : Int32
    property first_release : String?
    property last_release : String?
    property first_seen_at : String?
    property last_seen_at : String?
  end

  struct RecentOccurrence
    include JSON::Serializable
    property id : Int64
    property exception_type : String
    property message : String?
    property release : String?
    property trace_id : Int64?
    property occurred_at : String?
  end

  struct IssueDetail
    include JSON::Serializable
    property id : Int64
    property summary : String
    property exception_type : String
    property service : String
    property environment : String?
    property status : String
    property regressed : Bool
    property occurrence_count : Int32
    property first_release : String?
    property last_release : String?
    property first_seen_at : String?
    property last_seen_at : String?
    property stack_trace : String?
    property recent_occurrences : Array(RecentOccurrence)
  end

  struct OccurrenceSummary
    include JSON::Serializable
    property id : Int64
    property exception_type : String
    property message : String?
    property service : String
    property environment : String?
    property release : String?
    property issue_id : Int64
    property issue_summary : String
    property trace_id : Int64?
    property occurred_at : String?
  end

  struct OccurrenceDetail
    include JSON::Serializable
    property id : Int64
    property exception_type : String
    property message : String?
    property service : String
    property environment : String?
    property release : String?
    property issue_id : Int64
    property issue_summary : String
    property trace_id : Int64?
    property occurred_at : String?
    property stack_trace : String?
    property attributes : JSON::Any?
    property span_id : String?
  end

  struct EventSummary
    include JSON::Serializable
    property id : Int64
    property event_name : String?
    property service : String
    property release : String?
    property user_email : String?
    property prompt_id : String?
    property session_id : String?
    property timestamp : String?
  end

  struct EventDetail
    include JSON::Serializable
    property id : Int64
    property event_name : String?
    property service : String
    property release : String?
    property user_email : String?
    property prompt_id : String?
    property session_id : String?
    property timestamp : String?
    property attributes : JSON::Any?
    property resource_attributes : JSON::Any?
    property body : JSON::Any?
    property raw_payload : JSON::Any?
  end
end
