# @return [String] the path to the fixture file
def fixture_path(filename)
  File.expand_path("../../fixtures/#{filename}", __FILE__)
end

# @return [String] the content of a fixture file
def fixture(filename)
  IO.read(fixture_path(filename))
end
