defmodule ExJenkinsTest do
  use ExUnit.Case
  import ExJenkins.JenkinsHelper
  doctest ExJenkins

  setup_all do
    start_jenkins()
    IO.write "Starting Poison..."
    {:ok, _} = Application.ensure_all_started(:httpoison)
    IO.puts "done"
    :ok
  end

  setup do
    IO.puts "Waiting for Jenkins..."
    :ready = wait_for_jenkins()
    IO.write "Starting ExJenkins..."
    {:ok, _} = Application.ensure_all_started(:ex_jenkins)
    IO.puts "...done"

    on_exit(fn ->
      stop_jenkins()
    end)
  end


  test "Jobs" do
    assert {:ok, []} == ExJenkins.Jobs.all
    assert {:ok, :created} == ExJenkins.Jobs.create("my-job", job_config_file())
    assert {:ok, {:started, "http://localhost:8080/queue/item/1/"}} == ExJenkins.Jobs.start("my-job")
  end

  defp job_config_file do
    "<?xml version='1.0' encoding='UTF-8'?>\n<project>\n  <description></description>\n  <keepDependencies>false</keepDependencies>\n  <properties/>\n  <scm class=\"hudson.scm.NullSCM\"/>\n  <canRoam>true</canRoam>\n  <disabled>false</disabled>\n  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>\n  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>\n  <triggers/>\n  <concurrentBuild>false</concurrentBuild>\n  <builders>\n    <hudson.tasks.Shell>\n      <command>echo &quot;hello&quot;</command>\n    </hudson.tasks.Shell>\n  </builders>\n  <publishers/>\n  <buildWrappers/>\n</project>"
  end

end
