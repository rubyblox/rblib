## rspec for PebblApp::Support::Files

## the library to test
require 'pebbl_app/support/files'

describe PebblApp::Support::Files do

  it "parses filenames in shortname" do
    using = PebblApp::Support
    expect(using::Files.shortname("/etc/login.conf")).to be == "login"
    expect(using::Files.shortname(".login.conf")).to be  == ".login"
    expect(using::Files.shortname(".bashrc")) .to be  == ".bashrc"
    expect(using::Files.shortname(".")).to be  == "."
    expect(using::Files.shortname("..")).to be  == ".."
    expect(using::Files.shortname("/")).to be  == ""
    expect(using::Files.shortname("/a/b/")).to be  == "b"
    expect(using::Files.shortname("/b/.c/")).to be  == ".c"
    expect(using::Files.shortname(".files.d")).to be  == ".files"
    expect(using::Files.shortname(".a.b.c.d.e.f")).to be  == ".a.b.c.d.e"
    expect(using::Files.shortname("m.n.o")).to be  == "m.n"
  end

  it "provides the temporary file to a block in mktmp" do
    described_class.mktmp do |f|
      expect(f).to_not be nil
    end
  end

  it "deletes the temporary file after a block in mktmp" do
    file = nil
    described_class.mktmp do |f|
      file = f.path
      expect(File.exists?(f.path)).to be true
    end
    expect(File.exists?(file)).to_not be true
  end

  it "returns the value from a block in mktmp" do
    expect(described_class.mktmp do |f|
             1
           end).to be == 1
  end

  it "uses TMPDIR under mktmp" do
    ## TMPDIR will have been configured for the testing environment,
    ## within spec_helper.rb
    tmpdir_re = Regexp.new("^" + ENV['TMPDIR'])
    described_class.mktmp do |f|
      if !(f.path.match?(tmpdir_re))
        RSpec::Expectations.fail_with(
          "File pathname does not match TMPDIR: %p / %p" % [
            f.path, ENV['TMPDIR']
          ])
      end
    end
  end

  it "provides the temporary dir to a block in mktmp_dir" do
    described_class.mktmp_dir do |dir|
      expect(dir).to_not be nil
    end
  end


  it "deletes the temporary dir after a block in mktmp_dir" do
    dir = nil
    described_class.mktmp_dir do |d|
      dir = d
      expect(Dir.exists?(d)).to be true
    end
    expect(Dir.exists?(dir)).to_not be true
  end

  it "returns the value from a block in mktmp_dir" do
    expect(described_class.mktmp_dir do |f|
             1
           end).to be == 1
  end

  it "uses TMPDIR under mktmp_dir" do
    ## TMPDIR will have been configured for the testing environment,
    ## within spec_helper.rb
    tmpdir_re = Regexp.new("^" + ENV['TMPDIR'])
    described_class.mktmp_dir do |dir|
      if !(dir.match?(tmpdir_re))
        RSpec::Expectations.fail_with(
          "Temporary dir does not match TMPDIR: %p / %p" % [
            dir, ENV['TMPDIR']
          ])
      end
    end
  end

end
