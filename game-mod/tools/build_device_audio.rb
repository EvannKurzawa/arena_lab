# Original synthesized effects; no sampled game audio or external dependencies.
require 'fileutils'
root = ARGV.fetch(0)
rate = 22050
write = lambda do |folder, name, duration, &sample|
  path = File.join(root, 'Audio', folder)
  FileUtils.mkdir_p(path)
  count = (rate * duration).to_i
  data = Array.new(count) { |i| (sample.call(i.to_f / rate, duration) * 12000).clamp(-32767, 32767).to_i }.pack('s<*')
  header = 'RIFF' + [36 + data.bytesize].pack('V') + 'WAVEfmt ' +
    [16, 1, 1, rate, rate * 2, 2, 16].pack('VvvVVvv') + 'data' + [data.bytesize].pack('V')
  File.binwrite(File.join(path, name + '.wav'), header + data)
end
# Integer cycles over a one-second buffer give a seamless, gently pulsing hum.
write.call('BGS', 'Arena Magnet', 1.0) do |t, _|
  # Midrange harmonics remain audible on small laptop speakers. The earlier
  # 110Hz fundamental was easily masked by map music and speaker roll-off.
  pulse = 0.8 + 0.2 * Math.cos(2 * Math::PI * 8 * t)
  pulse * (0.55 * Math.sin(2 * Math::PI * 330 * t) + 0.25 * Math.sin(2 * Math::PI * 660 * t) +
    0.2 * Math.sin(2 * Math::PI * 990 * t + 1.5 * Math.sin(2 * Math::PI * 16 * t)))
end
rng = Random.new(922)
write.call('SE', 'Arena Coil Off', 0.65) do |t, duration|
  envelope = [t / 0.012, 1].min * (1 - t / duration)**2
  phase = 2 * Math::PI * (720 * t - 460 * t * t)
  envelope * (0.55 * Math.sin(phase) + 0.25 * Math.sin(phase * 2.03) + 0.2 * (rng.rand * 2 - 1))
end
