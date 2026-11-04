# Original synthesized effects; no sampled game audio or external dependencies.
require 'fileutils'
root = ARGV.fetch(0)
overrides = ARGV[1] || File.expand_path('../LocalAssets/Audio/BGS', __dir__)
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
magnet = lambda do |t, _|
  # Midrange harmonics remain audible on small laptop speakers. The earlier
  # 110Hz fundamental was easily masked by map music and speaker roll-off.
  pulse = 0.8 + 0.2 * Math.cos(2 * Math::PI * 8 * t)
  pulse * (0.55 * Math.sin(2 * Math::PI * 330 * t) + 0.25 * Math.sin(2 * Math::PI * 660 * t) +
    0.2 * Math.sin(2 * Math::PI * 990 * t + 1.5 * Math.sin(2 * Math::PI * 16 * t)))
end
write.call('BGS', 'Arena Magnet', 1.0, &magnet)
# Original high-voltage corona buzz: mains harmonics plus a restrained, airy
# crackle. Quarter-Hz frequencies make every component loop exactly in 4 s.
noise_rng = Random.new(714)
tones = Array.new(24) { [noise_rng.rand(4800..20000)/4.0, noise_rng.rand*Math::PI*2] }
tesla = lambda do |t, _|
  cycle = 2*Math::PI*t
  # Keep the mains undertone, but put most energy above laptop speaker roll-off
  # and the bass of the map music so a live coil is clearly audible.
  hum = 0.12*Math.sin(cycle*100) + 0.32*Math.sin(cycle*450) +
        0.24*Math.sin(cycle*900) + 0.14*Math.sin(cycle*1350)
  fizz = tones.sum { |hz,phase| Math.sin(cycle*hz+phase) } * 0.022
  pulse = 0.65 + 0.35*(0.5+0.5*Math.cos(cycle*7.25))**6
  hum*(0.88+0.12*Math.cos(cycle*50)) + fizz*pulse
end
write.call('BGS', 'Arena Tesla Hum', 4.0, &tesla)
write.call('BGS', 'Arena Magnet Tesla', 4.0) do |t,duration|
  magnet.call(t,duration)*0.75 + tesla.call(t,duration)*(90.0/95)
end
rng = Random.new(922)
write.call('SE', 'Arena Coil Off', 0.65) do |t, duration|
  envelope = [t / 0.012, 1].min * (1 - t / duration)**2
  phase = 2 * Math::PI * (720 * t - 460 * t * t)
  envelope * (0.55 * Math.sin(phase) + 0.25 * Math.sin(phase * 2.03) + 0.2 * (rng.rand * 2 - 1))
end
# Personal recordings stay outside the distributable source tree. Install them
# after synthesis on every Prepare, so relaunching cannot erase the selection.
['Arena Tesla Hum', 'Arena Magnet Tesla'].each do |name|
  source = File.join(overrides, name + '.wav')
  FileUtils.cp(source, File.join(root, 'Audio/BGS', name + '.wav')) if File.file?(source)
end
