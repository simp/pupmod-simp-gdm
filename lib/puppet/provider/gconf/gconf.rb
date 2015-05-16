Puppet::Type.type(:gconf).provide(:ruby) do
  require 'shellwords'

  def lookup(schema, key)
    if resource[:force] == :false then
      # Lookup a value. Throw away any garbage from gconftool-2.
      schema_args = "--direct --config-source xml:readonly:/etc/gconf/gconf.xml.defaults --get '/schemas#{key}'"

      # Cheking the schema
      cmd = "/usr/bin/gconftool-2 #{schema_args} 2>&1"
      Puppet.debug("Running lookup: #{cmd}")
      if %x{#{cmd}} !~ /Type:/ then
        raise(Puppet::Error,"Gconf: Could not find '#{key}' in the gconf schemas.")
      end
    end
      
    args = "--direct --config-source 'xml:readonly:/etc/gconf/gconf.xml.#{schema}' --get '#{key}'"
      cmd = "/usr/bin/gconftool-2 #{args} 2>&1"
      Puppet.debug("Running lookup2: #{cmd}")
    return %x{#{cmd}}.strip.split("\n").delete_if{|x| x.include?('(gconftool-2:')}.join("\n")
  end

  def create
    # This is just a stub since setting the value automatically creates it.
  end

  def destroy
    # This un-sets a value (or set of values if 'recurse' is 'true').

    cmd = '/usr/bin/gconftool-2 ' +
          '--direct ' +
          '--config-source ' +
          "'xml:readwrite:/etc/gconf/gconf.xml.#{resource[:schema]}' "

    if resource[:recurse] == :true then
      cmd += '--recursive-unset '
    else
      cmd += '--unset '
    end

    cmd +=  "-- '#{resource[:key]}' 2>&1"

    Puppet.debug("Running destroy: #{cmd}")
    old_umask = File.umask(022)
    output = %x{#{cmd}}
    File.umask(old_umask)
    if not $?.success? then
      raise(Puppet::Error,"Could not unset #{resource[:key]}: #{output}")
    end
  end

  def exists?
    if self.retrieve.nil? then
      if resource[:recurse] == :true then
        cmd = '/usr/bin/gconftool-2 ' +
              '--direct ' +
              '--config-source ' +
              "'xml:readonly:/etc/gconf/gconf.xml.#{resource[:schema]}' " +
              '--recursive-list ' +
              "-- '#{resource[:key]}' 2>&1"

        # Recursively find any items below this entry with a right hand side
        # value return 'true' if we have one.
        rhs = []
        Puppet.debug("Running exists?: #{cmd}")
        %x{#{cmd}}.each_line do |line|
          x,y = line.split('=')
          y and !y.empty? and rhs << y
        end

        if !rhs.empty? then
          return true
        end
      end
    else
      return true
    end

    return false
  end

  def valid_value?(value)
    if  value.nil? or
        value.empty? or
        value.include?('No value set for') or
        value.strip == "[]" or
        value.strip == "()"
    then
      return false
    end

    return true
  end

  def retrieve
    value = lookup(resource[:schema], resource[:key])
    
    self.valid_value?(value) and return value

    return ''
  end

  def sync
    args = "--direct --config-source 'xml:readwrite:/etc/gconf/gconf.xml.#{resource[:schema]}' --type #{resource[:type]}"

    args += case resource[:type]
    when :list
      " --list-type=#{resource[:list_type]}"
    when :pair
      " --car-type=#{resource[:car_type]} --cdr-type=#{resource[:cdr_type]}"
    else
      ''
    end

    args += " --set -- #{resource[:key]} '#{resource[:value]}'"

    cmd = "/usr/bin/gconftool-2 #{args} 2>&1"
    Puppet.debug("Running Sync: #{cmd}")
    old_umask = File.umask(022)
    output = %x{#{cmd}}
    File.umask(old_umask)
    if not $?.success? then
      raise(Puppet::Error,"Gconf: Command: /usr/bin/gconftool-2 #{args} 2>&1 failed: Error: #{output.chomp.split("\n").last}")
    end
  end
end
