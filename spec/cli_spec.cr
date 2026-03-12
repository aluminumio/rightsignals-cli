require "./spec_helper"

describe "RightSignalsCLI" do
  it "prints version" do
    output = `crystal run src/main.cr -- version 2>&1`
    output.strip.should match(/\d+\.\d+\.\d+/)
  end

  it "prints help" do
    output = `crystal run src/main.cr -- help 2>&1`
    output.should contain("Usage: rightsignals")
    output.should contain("traces")
    output.should contain("issues")
    output.should contain("occurrences")
    output.should contain("events")
  end

  it "errors without token" do
    output = `RIGHTSIGNALS_TOKEN= crystal run src/main.cr -- traces 2>&1`
    output.should contain("no API token")
  end

  it "accepts -t flag before command" do
    output = `RIGHTSIGNALS_TOKEN= crystal run src/main.cr -- -t fake_token traces 2>&1`
    output.should_not contain("no API token")
  end

  it "accepts --token= before command" do
    output = `RIGHTSIGNALS_TOKEN= crystal run src/main.cr -- --token=fake_token traces 2>&1`
    output.should_not contain("no API token")
  end

  it "accepts -t flag after command" do
    output = `RIGHTSIGNALS_TOKEN= crystal run src/main.cr -- traces -t fake_token 2>&1`
    output.should_not contain("no API token")
  end

  it "shows issues:resolve and issues:reopen in help" do
    output = `crystal run src/main.cr -- help 2>&1`
    output.should contain("issues:resolve")
    output.should contain("issues:reopen")
  end

  it "shows filter flags in help" do
    output = `crystal run src/main.cr -- help 2>&1`
    output.should contain("--status")
    output.should contain("--service")
    output.should contain("--environment")
  end

  it "errors on issues:resolve without id" do
    output = `RIGHTSIGNALS_TOKEN=fake crystal run src/main.cr -- issues:resolve 2>&1`
    output.should contain("Usage: rightsignals issues:resolve")
  end

  it "errors on issues:reopen without id" do
    output = `RIGHTSIGNALS_TOKEN=fake crystal run src/main.cr -- issues:reopen 2>&1`
    output.should contain("Usage: rightsignals issues:reopen")
  end
end
