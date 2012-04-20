require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")
require 'ghost/store/hosts_file_store'

require 'tmpdir'
require 'ostruct'

describe Ghost::Store::HostsFileStore do
  def write(content)
    File.open(file_path, 'w') { |f| f.write(content) }
  end

  def read
    File.read(file_path)
  end

  def no_write
    File.any_instance.stub(:reopen).with(anything, /[aw]/).and_raise("no writing!")
    File.any_instance.stub(:puts).and_raise("no writing!")
    File.any_instance.stub(:print).and_raise("no writing!")
    File.any_instance.stub(:write).and_raise("no writing!")
    File.any_instance.stub(:<<).and_raise("no writing!")
    File.any_instance.stub(:flush).and_raise("no writing!")
  end

  subject { store }

  let(:file_path) { File.join(Dir.tmpdir, "etc_hosts.#{Process.pid}.#{rand(9999)}") }
  let(:store)     { described_class.new(file_path) }
  let(:contents) do
    <<-EOF.gsub(/^\s+/,'')
    127.0.0.1 localhost localhost.localdomain
    EOF
  end

  before { write(contents) }

  it 'manages the default file of /etc/hosts when no file path is provided' do
    described_class.new.path.should == "/etc/hosts"
  end

  it 'manages the file at the provided path when given' do
    described_class.new('xyz').path.should == 'xyz'
  end

  describe "#all" do
    context 'with no ghost-managed hosts in the file' do
      it 'returns no hosts' do
        store.all.should == []
      end
    end

    context 'with some ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
        127.0.0.1 localhost localhost.localdomain
        # ghost start
        1.2.3.4 bjeanes.com
        2.3.4.5 my-app.com subdomain.my-app.com
        # ghost end
        EOF
      end

      it 'returns an array with one Ghost::Host per ghost-managed host in the hosts file' do
        store.all.should == [
          Ghost::Host.new('bjeanes.com', '1.2.3.4'),
          Ghost::Host.new('my-app.com', '2.3.4.5'),
          Ghost::Host.new('subdomain.my-app.com', '2.3.4.5')
        ]
      end

      it "shouldn't write to the file" do
        no_write
        store.all
      end
    end
  end

  describe "#find"

  describe "#add" do
    let(:host) { OpenStruct.new(:name => "google.com", :ip => "127.0.0.1") }

    context 'with no ghost-managed hosts in the file' do
      it 'returns true' do
        store.add(host).should be_true
      end

      it 'adds the new host between delimeters' do
        store.add(host)
        read.should == <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          127.0.0.1 google.com
          # ghost end
        EOF
      end
    end

    context 'with existing ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          192.168.1.1 github.com
          # ghost end
        EOF
      end

      context 'when adding to an existing IP' do
        before { host.stub(:ip => '192.168.1.1') }

        it 'adds to existing entry between tokens, listing host names in alphabetical order' do
          store.add(host)
          read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
            192.168.1.1 github.com google.com
            # ghost end
          EOF
        end

        it 'returns true' do
          store.add(host).should be_true
        end
      end

      context 'when adding a new IP' do
        it 'adds new entry between tokens, in numerical order' do
          store.add(host)
          read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
            127.0.0.1 google.com
            192.168.1.1 github.com
            # ghost end
          EOF
        end

        it 'returns true' do
          store.add(host).should be_true
        end
      end
    end
  end

  describe "#delete" do
    context 'with no ghost-managed hosts in the file' do
      let(:host) { OpenStruct.new(:name => "localhost", :ip => "127.0.0.1") }

      it 'returns false' do
        store.delete(host).should be_false
      end

      it 'has no effect' do
        store.delete(host)
        read.should == contents
      end
    end

    context 'with existing ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          127.0.0.1 google.com
          192.168.1.1 github.com
          # ghost end
        EOF
      end

      context 'when deleting one of the ghost entries' do
        let(:host) { OpenStruct.new(:name => "google.com") }

        it 'returns true' do
          store.delete(host).should be_true
        end

        it 'removes the host from the file' do
          store.delete(host)
          read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
            192.168.1.1 github.com
            # ghost end
          EOF
        end
      end

      context 'when trying to delete a non-ghost entry' do
        let(:host) { OpenStruct.new(:name => "localhost") }

        it 'returns false' do
          store.delete(host).should be_false
        end

        it 'has no effect' do
          store.delete(host)
          read.should == contents
        end
      end
    end
  end

  describe "#empty" do
    context 'with no ghost-managed hosts in the file' do
      it 'returns false' do
        store.empty.should be_false
      end

      it 'has no effect' do
        store.empty
        read.should == contents
      end
    end

    context 'with existing ghost-managed hosts in the file' do
      let(:contents) do
        <<-EOF.gsub(/^\s+/,'')
          127.0.0.1 localhost localhost.localdomain
          # ghost start
          127.0.0.1 google.com
          192.168.1.1 github.com
          # ghost end
        EOF
      end

      context 'when deleting one of the ghost entries' do
        it 'returns true' do
          store.empty.should be_true
        end

        it 'removes the host from the file' do
          store.empty
          read.should == <<-EOF.gsub(/^\s+/,'')
            127.0.0.1 localhost localhost.localdomain
            # ghost start
            # ghost end
          EOF
        end
      end
    end
  end
end
