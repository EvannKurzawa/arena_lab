# Three 200x200 byte grids plus placements exceed PEMK's 64 KiB envelope.
# Keep a bounded 256 KiB allowance; the 16 MiB body/frame cap is unchanged.
[('PEMK::Config' if defined?(PEMK::Config)),
 ('PEMK::Wire' if defined?(PEMK::Wire))].compact.each do |name|
  target = name.split('::').inject(Object) { |scope, part| scope.const_get(part) }
  next unless target.const_defined?(:ENVELOPE_MAX)
  target.send(:remove_const, :ENVELOPE_MAX)
  target.const_set(:ENVELOPE_MAX, 256 << 10)
end
