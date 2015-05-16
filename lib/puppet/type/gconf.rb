module Puppet
  newtype(:gconf) do
    @doc = 'Manages a key-value pair within the GConf repository. The key is
      set to be the value of $namevar. The key name (either short or long),
      the value and the type of the value are required.

      Be aware, gconftool-2 is pretty slow and this type suffers from it.'

    # This hash provides a mapping of short, easy-to-use names for common keys
    # that will be set within GConf
    @@gc_keys = {
      'screensaver_enabled'   => '/apps/gnome-screensaver/idle_activation_enabled',
      'screensaver_timeout'   => '/apps/gnome-screensaver/idle_delay',
      'screensaver_lock'      => '/apps/gnome-screensaver/lock_enabled',
      'banner_message_text'   => '/apps/gdm/simple-greeter/banner_message_text',
      'banner_message_enable' => '/apps/gdm/simple-greeter/banner_message_enable',
      'disable_user_list'     => '/apps/gdm/simple-greeter/disable_user_list'
    }

    # This hash provides a set of precompiled matches for common gconf types.
    @@res_types = {
      :bool   => Regexp.new(/^(true|false)$/),
      :int    => Regexp.new(/^\d+$/),
      :float  => Regexp.new(/^\d+(\.\d+)?$/),
      :string => Regexp.new(/./)
    }

    ensurable

    newparam(:key, :namevar => true) do
      desc 'The short or complete name of the key in the GConf key-value pair.'

      validate do |value|
        if not value[0].chr.eql?('/') and not @@gc_keys.keys.include?(value)
          raise(Puppet::Error, "Gconf: Unknown GConf key '#{value}'")
        end
      end

      munge do |value|
        @@gc_keys[value] or value
      end
    end

    newparam(:list_type) do
      desc "If 'value' is a list, what type of list it is."
      newvalues(:string,:bool,:int,:float)
    end

    newparam(:car_type) do
      desc "If 'value' is a pair, what type the first value is."
      newvalues(:string,:bool,:int,:float)

      validate do |value|
        resource[:list_type] and raise(Puppet::Error,"You cannot set both 'list_type' and 'car_type'")
      end
    end

    newparam(:cdr_type) do
      desc "If 'value' is a pair, what type the second value is."
      newvalues(:string,:bool,:int,:float)
        
      validate do |value|
        resource[:list_type] and raise(Puppet::Error,"You cannot set both 'list_type' and 'cdr_type'")
      end
    end

    newparam(:force, :boolean => true) do
      desc "Don't check the schemas to see if this is a valid target, just set it."
      newvalues(:true,:false)

      defaultto :false
    end

    newparam(:recurse, :boolean => true) do
      desc "When ensuring 'absent', recursively unset entries."
      newvalues(:true,:false)

      defaultto :false
    end

    newparam(:schema) do
      desc 'The config-source of the GConf key.'
      newvalues(:defaults, :mandatory, :system)
      defaultto :defaults
    end

    newparam(:type) do
      desc 'The type of the value, such as int or bool.'
      newvalues(:int, :bool, :string, :float, :list, :pair)
    end

    newparam(:source) do
      desc "The source of the content of value. If set to 'var', the literal
        value found will be used, which is the normal case.

        If set to 'file', then the contents of the file will be read and used
        as the content of the value.

        NOTE: 'file' is only valid for type 'string'"

      newvalues(:var, :file)
      defaultto :var

      validate do |value|
        if value == :file and not resource[:type] == :string then
          raise(Puppet::Error, "'source' cannot be 'file' if 'type' is not 'string'")
        end
      end
    end

    newparam(:clean_source) do
      desc "Allows the user to choose a pre-configured method for cleaning up
        the 'value' targeted by 'source'.

        Only works with 'type' 'string' and TODO

        Available Methods:
          - gui
            - Takes a multi-line input and makes all single-return lines into a
              single segment. Preserves empty lines.

              Example:
                'foo bar\\nbaz moo' => 'foo bar baz moo'
                'foo bar\\n\\nbaz moo' => 'foo bar\\n\\nbaz moo'

          - strip
            - Strips off all leading and trailing whitespace from all lines.

          - lstrip
            - Strips off all leading whitespace from all lines.

          - rstrip
            - Strips off all trailing whitespace from all lines."

      newvalues(:none, :gui, :strip, :lstrip, :rstrip)
      defaultto :none
    end

    newproperty(:value, :array_matching => 'all') do
      desc "The value of the GConf key-value pair. If you point this at a file,
        it WILL be read into memory!

        Accepts an array, but 'list_type' or 'car_type' and 'cdr_type' must be
        set.

        If 'car_type' and 'cdr_type' are set, then the array can only have two
        values ['<car>','<cdr>']."

      def retrieve
        # Have to do munging here since it relies on the 'type' parameter.
        if resource[:source].eql?(:file) then
          src_file = resource[:value].first
          if not File.readable?(src_file) then
            raise(Puppet::Error, "Unable to read file '#{src_file}'")
          else
            @should = Array(File.open(src_file).read.strip)
          end
        end

        # Munge @should to match whatever :clean_source says
        case resource[:clean_source]
        when :gui
          Puppet.debug("Running gui clean.")
          @should = Array(@should.compact.join.gsub(/(\w)\n(\w)/){ "#{$1} #{$2}" }).map{|x| x == "\n" and x = x or x = x.lstrip}
        when :strip
          Puppet.debug("Running strip.")
          @should.map{|x| x.strip }
        when :lstrip
          Puppet.debug("Running lstrip.")
          @should.map{|x| x.lstrip }
        when :rstrip
          Puppet.debug("Running rstrip.")
          @should.map{|x| x.rstrip }
        else
          Puppet.debug("Not cleaning source material.")
        end

        case resource[:type]
        when :pair
          @should = Array("(#{@should.join(',')})")
        when :list
          @should = Array("[#{@should.join(',')}]")
        end

        return provider.retrieve
      end

      def insync?(is)
        is == @should.to_s
      end

      def sync
        provider.sync
      end
    end

    # Autorequires
    autorequire(:file) do
      to_req = []
      if self[:source] == :file then
        to_req << "File[#{self[:value]}]"
      end

      to_req
    end

    # Global Validation
    validate do
      self[:ensure] == :absent and break

      required_params = [
        :value,
        :type
      ]

      required_params.each do |param|
        self[param] or raise(Puppet::Error, "Gconf: Missing required parameter: #{param}")
      end

      case self[:type]
      when :pair
          self[:car_type].nil? or self[:cdr_type].nil? and raise(Puppet::Error,"You must specify both 'cdr_type' and 'car_type' for type 'pair'")
      when :list
          self[:list_type].nil? and raise(Puppet::Error,"You must specify 'list_type' for type 'list'")
      end

      # This is the validation for the 'value' property but properties get parsed before parameters so we're doing it here.
      value = self[:value]
      # Pairs must have exactly two items.
      self[:type] == 'pair' and Array(value).length != 2 and raise(Puppet::Error,"Pairs must have two items")

      # Now, check that everything actually makes sense.
      err_msg = nil

      r_type = self[:type]
      case r_type
      when :int, :bool, :float, :string
        !@@res_types[r_type].match("#{value.first}") and err_msg = "#{value.first.inspect} is not type '#{r_type}"

      when :list
        value.each do |val|
          !@@res_types[self[:list_type].to_sym].match(val) and err_msg = "'#{val}' is not type '#{self[:list_type]}'"and break
        end

      when :pair
        [:car_type,:cdr_type].each_with_index do |c_type,i|
          !@@res_types[self[c_type]].match(value[i]) and err_msg = "'#{value[i]}' is not type '#{self[c_type]}'" and break
        end
      else
        # Should never get here
        raise(Puppet::Error,"Unknown resource type '#{r_type}'")
      end

      err_msg and raise(Puppet::Error,err_msg)
    end
  end
end
