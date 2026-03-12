require "./spec_helper"

describe RightSignals::TraceSummary do
  it "deserializes from JSON" do
    json = %|{"id":1,"trace_id":"abc123","service":"my-svc","environment":"production","release":"1.0","root_span":"GET /users","duration":"1.5s","span_count":5,"started_at":"2026-03-11T10:00:00Z"}|
    trace = RightSignals::TraceSummary.from_json(json)
    trace.id.should eq 1
    trace.trace_id.should eq "abc123"
    trace.service.should eq "my-svc"
    trace.span_count.should eq 5
  end

  it "handles nil optional fields" do
    json = %|{"id":1,"trace_id":"abc","service":"svc","span_count":1}|
    trace = RightSignals::TraceSummary.from_json(json)
    trace.environment.should be_nil
    trace.release.should be_nil
  end
end

describe RightSignals::IssueSummary do
  it "deserializes from JSON" do
    json = %|{"id":2,"summary":"RuntimeError: boom","exception_type":"RuntimeError","service":"svc","environment":"prod","status":"open","regressed":false,"occurrence_count":3,"first_release":"1.0","last_release":"1.1","first_seen_at":"2026-03-10T10:00:00Z","last_seen_at":"2026-03-11T10:00:00Z"}|
    issue = RightSignals::IssueSummary.from_json(json)
    issue.id.should eq 2
    issue.exception_type.should eq "RuntimeError"
    issue.status.should eq "open"
    issue.regressed.should eq false
    issue.occurrence_count.should eq 3
  end
end

describe RightSignals::IssueDetail do
  it "deserializes with stack trace and occurrences" do
    json = %|{"id":2,"summary":"RuntimeError","exception_type":"RuntimeError","service":"svc","status":"open","regressed":false,"occurrence_count":1,"stack_trace":"app.rb:42","recent_occurrences":[{"id":10,"exception_type":"RuntimeError","message":"boom","occurred_at":"2026-03-11T10:00:00Z"}]}|
    issue = RightSignals::IssueDetail.from_json(json)
    issue.stack_trace.should eq "app.rb:42"
    issue.recent_occurrences.size.should eq 1
    issue.recent_occurrences[0].message.should eq "boom"
  end
end

describe RightSignals::TraceDetail do
  it "deserializes with spans" do
    json = %|{"id":1,"trace_id":"abc","service":"svc","span_count":1,"spans":[{"span_id":"s1","operation":"GET /","kind":2,"status_code":1,"duration":"50ms","started_at":"2026-03-11T10:00:00Z"}]}|
    trace = RightSignals::TraceDetail.from_json(json)
    trace.spans.size.should eq 1
    trace.spans[0].operation.should eq "GET /"
  end
end

describe RightSignals::EventSummary do
  it "deserializes from JSON" do
    json = %|{"id":5,"event_name":"api_request","service":"cowork","release":"1.0","user_email":"test@example.com","prompt_id":"abc-123","session_id":"sess-1","timestamp":"2026-03-11T10:00:00Z"}|
    event = RightSignals::EventSummary.from_json(json)
    event.event_name.should eq "api_request"
    event.user_email.should eq "test@example.com"
  end
end

describe RightSignals::Client do
  it "initializes with defaults" do
    client = RightSignals::Client.new
    client.base_url.should eq "https://app.rightsignals.com"
    client.token.should eq ""
  end

  it "accepts custom base_url and token" do
    client = RightSignals::Client.new(base_url: "http://localhost:3000", token: "rsg_test")
    client.base_url.should eq "http://localhost:3000"
    client.token.should eq "rsg_test"
  end
end
