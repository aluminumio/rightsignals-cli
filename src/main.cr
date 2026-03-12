require "rightsignals"
require "option_parser"
require "json"

module RightSignalsCLI
  VERSION = "0.3.1"

  struct Config
    property base_url : String
    property token : String

    def initialize
      @base_url = ENV.fetch("RIGHTSIGNALS_URL", "https://app.rightsignals.com")
      @token = ENV.fetch("RIGHTSIGNALS_TOKEN", "")
    end
  end

  def self.run(args = ARGV)
    config = Config.new
    json_output = false
    limit : Int32? = nil
    status : String? = nil
    service : String? = nil
    environment : String? = nil

    parser = OptionParser.new do |p|
      p.on("-j", "--json", "Output raw JSON") { json_output = true }
      p.on("-l LIMIT", "--limit=LIMIT", "Max results") { |v| limit = v.to_i }
      p.on("-s STATUS", "--status=STATUS", "Filter by status") { |v| status = v }
      p.on("--service=ID", "Filter by service ID") { |v| service = v }
      p.on("-e ENV", "--environment=ENV", "Filter by environment") { |v| environment = v }
      p.on("-u URL", "--url=URL", "API base URL") { |v| config.base_url = v }
      p.on("-t TOKEN", "--token=TOKEN", "API token") { |v| config.token = v }
      p.on("-v", "--version", "Show version") { puts VERSION; exit }
      p.on("-h", "--help", "Show help") { print_help; exit }
      p.unknown_args { }
    end
    parser.parse(args)

    positional = args.reject { |a| a.starts_with?("-") }
    command = positional[0]? || "help"
    id = positional[1]?.try(&.to_i64?)

    if command == "version"
      puts VERSION
      return
    end
    if command == "help"
      print_help
      return
    end

    if config.token.empty?
      STDERR.puts "Error: no API token. Set RIGHTSIGNALS_TOKEN or pass --token"
      exit 1
    end

    client = RightSignals::Client.new(base_url: config.base_url, token: config.token)

    sid = service.try(&.to_i64?)

    case command
    when "traces"
      if id
        trace = client.get_trace(id)
        json_output ? puts(trace.to_json) : print_trace(trace)
      else
        traces = client.list_traces(service_id: sid, environment: environment, limit: limit)
        json_output ? puts(traces.to_json) : print_traces(traces)
      end
    when "issues"
      if id
        issue = client.get_issue(id)
        json_output ? puts(issue.to_json) : print_issue(issue)
      else
        issues = client.list_issues(service_id: sid, environment: environment, status: status, limit: limit)
        json_output ? puts(issues.to_json) : print_issues(issues)
      end
    when "occurrences"
      if id
        occ = client.get_occurrence(id)
        json_output ? puts(occ.to_json) : print_occurrence(occ)
      else
        occs = client.list_occurrences(service_id: sid, environment: environment, limit: limit)
        json_output ? puts(occs.to_json) : print_occurrences(occs)
      end
    when "events"
      if id
        event = client.get_event(id)
        json_output ? puts(event.to_json) : print_event(event)
      else
        events = client.list_events(service_id: sid, limit: limit)
        json_output ? puts(events.to_json) : print_events(events)
      end
    when "issues:resolve"
      if id
        issue = client.resolve_issue(id)
        puts "Resolved issue ##{id}: #{issue.summary}"
      else
        STDERR.puts "Usage: rightsignals issues:resolve <issue-id>"
        exit 1
      end
    when "issues:reopen"
      if id
        issue = client.reopen_issue(id)
        puts "Reopened issue ##{id}: #{issue.summary}"
      else
        STDERR.puts "Usage: rightsignals issues:reopen <issue-id>"
        exit 1
      end
    else
      STDERR.puts "Unknown command: #{command}"
      print_help
      exit 1
    end
  rescue ex : RightSignals::AuthError
    STDERR.puts "Auth error: #{ex.message}"
    exit 1
  rescue ex : RightSignals::NotFoundError
    STDERR.puts "Not found: #{ex.message}"
    exit 1
  rescue ex : RightSignals::Error
    STDERR.puts "API error: #{ex.message}"
    exit 1
  end

  def self.print_help
    puts <<-HELP
    rightsignals v#{VERSION}

    Usage: rightsignals <command> [id] [options]

    Commands:
      traces [id]       List traces or show one
      issues [id]       List issues or show one
      occurrences [id]  List occurrences or show one
      events [id]       List events or show one
      issues:resolve <id>   Resolve an issue
      issues:reopen <id>    Reopen an issue
      version           Show version
      help              Show this help

    Options:
      -j, --json              Output raw JSON
      -l, --limit=N           Max results (default: 25)
      -s, --status=STATUS     Filter by status (open/resolved)
          --service=ID        Filter by service ID
      -e, --environment=ENV   Filter by environment
      -u, --url=URL           API base URL (or RIGHTSIGNALS_URL env)
      -t, --token=TOKEN       API token (or RIGHTSIGNALS_TOKEN env)
      -v, --version           Show version
      -h, --help              Show help
    HELP
  end

  def self.print_traces(traces : Array(RightSignals::TraceSummary))
    return puts "No traces." if traces.empty?
    puts "%-30s %-14s %-16s %6s %10s  %s" % ["ROOT SPAN", "TRACE ID", "SERVICE", "SPANS", "DURATION", "WHEN"]
    traces.each do |t|
      puts "%-30s %-14s %-16s %6d %10s  %s" % [
        truncate(t.root_span || "unknown", 30), t.trace_id[0, 12],
        truncate(t.service, 16), t.span_count, t.duration || "n/a", t.started_at || "n/a",
      ]
    end
  end

  def self.print_trace(t : RightSignals::TraceDetail)
    puts "Trace: #{t.trace_id}"
    puts "Service: #{t.service}  Environment: #{t.environment || "n/a"}  Release: #{t.release || "n/a"}"
    puts "Duration: #{t.duration || "n/a"}  Spans: #{t.span_count}"
    puts ""
    t.spans.each do |s|
      err = s.error ? " [ERROR]" : ""
      puts "  #{s.operation}  (#{s.span_id})  #{s.duration || "n/a"}#{err}"
    end
  end

  def self.print_issues(issues : Array(RightSignals::IssueSummary))
    return puts "No issues." if issues.empty?
    puts "%-6s %-8s %-40s %-16s %5s  %s" % ["ID", "STATUS", "SUMMARY", "SERVICE", "COUNT", "LAST SEEN"]
    issues.each do |i|
      puts "%-6d %-8s %-40s %-16s %5d  %s" % [
        i.id, i.status, truncate(i.summary, 40), truncate(i.service, 16),
        i.occurrence_count, i.last_seen_at || "n/a",
      ]
    end
  end

  def self.print_issue(i : RightSignals::IssueDetail)
    puts "Issue ##{i.id}: #{i.summary}"
    puts "Status: #{i.status}  Service: #{i.service}  Environment: #{i.environment || "n/a"}"
    puts "Occurrences: #{i.occurrence_count}  Regressed: #{i.regressed}"
    puts "First: #{i.first_seen_at || "n/a"}  Last: #{i.last_seen_at || "n/a"}"
    if st = i.stack_trace
      puts "\nStack trace:\n#{st}"
    end
    if i.recent_occurrences.size > 0
      puts "\nRecent occurrences:"
      i.recent_occurrences.each do |o|
        puts "  ##{o.id} #{o.exception_type}: #{o.message || "n/a"} (#{o.occurred_at || "n/a"})"
      end
    end
  end

  def self.print_occurrences(occs : Array(RightSignals::OccurrenceSummary))
    return puts "No occurrences." if occs.empty?
    puts "%-6s %-24s %-40s %-16s  %s" % ["ID", "EXCEPTION", "MESSAGE", "SERVICE", "WHEN"]
    occs.each do |o|
      puts "%-6d %-24s %-40s %-16s  %s" % [
        o.id, truncate(o.exception_type, 24), truncate(o.message || "", 40),
        truncate(o.service, 16), o.occurred_at || "n/a",
      ]
    end
  end

  def self.print_occurrence(o : RightSignals::OccurrenceDetail)
    puts "Occurrence ##{o.id}: #{o.exception_type}"
    puts "Message: #{o.message || "n/a"}"
    puts "Service: #{o.service}  Environment: #{o.environment || "n/a"}  Release: #{o.release || "n/a"}"
    if st = o.stack_trace
      puts "\nStack trace:\n#{st}"
    end
  end

  def self.print_events(events : Array(RightSignals::EventSummary))
    return puts "No events." if events.empty?
    puts "%-6s %-20s %-16s %-24s  %s" % ["ID", "EVENT", "SERVICE", "USER", "WHEN"]
    events.each do |e|
      puts "%-6d %-20s %-16s %-24s  %s" % [
        e.id, truncate(e.event_name || "unnamed", 20), truncate(e.service, 16),
        truncate(e.user_email || "n/a", 24), e.timestamp || "n/a",
      ]
    end
  end

  def self.print_event(e : RightSignals::EventDetail)
    puts "Event ##{e.id}: #{e.event_name || "unnamed"}"
    puts "Service: #{e.service}  Release: #{e.release || "n/a"}"
    puts "User: #{e.user_email || "n/a"}  Prompt: #{e.prompt_id || "n/a"}"
    if attrs = e.attributes
      puts "\nAttributes:\n#{attrs.to_pretty_json}"
    end
  end

  private def self.truncate(s : String, max : Int32) : String
    s.size > max ? s[0, max - 1] + "…" : s
  end
end

RightSignalsCLI.run
