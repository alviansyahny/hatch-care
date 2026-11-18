import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://iot.walker880.my.id',
);
const storage = FlutterSecureStorage();
String? token;

Future<dynamic> api(String path, {Map<String, dynamic>? body}) async {
  final uri = Uri.parse('$baseUrl/api/$path');
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  final response =
      await (body == null
              ? http.get(uri, headers: headers)
              : http.post(uri, headers: headers, body: jsonEncode(body)))
          .timeout(const Duration(seconds: 20));
  final dynamic data = response.body.isEmpty ? null : jsonDecode(response.body);
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      data is Map
          ? (data['message'] ?? 'HTTP ${response.statusCode}')
          : 'HTTP ${response.statusCode}',
    );
  }
  return data;
}

class ConnectedApp extends StatefulWidget {
  const ConnectedApp({super.key});
  @override
  State<ConnectedApp> createState() => _ConnectedAppState();
}

class _ConnectedAppState extends State<ConnectedApp> {
  bool loading = true;
  @override
  void initState() {
    super.initState();
    restore();
  }

  Future<void> restore() async {
    try {
      token = await storage.read(key: 'token');
      if (token != null) await api('user');
    } catch (_) {
      token = null;
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) => loading
      ? const Scaffold(body: Center(child: CircularProgressIndicator()))
      : token == null
      ? AuthPage(onAuthenticated: () => setState(() {}))
      : HomePage(onLogout: () => setState(() {}));
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.onAuthenticated});
  final VoidCallback onAuthenticated;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      username = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  bool register = false, busy = false;
  @override
  void dispose() {
    name.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final result = await api(
        register ? 'register' : 'login',
        body: register
            ? {
                'name': name.text.trim(),
                'username': username.text.trim(),
                'email': email.text.trim(),
                'password': password.text,
              }
            : {'login': username.text.trim(), 'password': password.text},
      );
      final received = result['token'];
      if (received is! String || received.isEmpty) {
        throw Exception('Token tidak tersedia');
      }
      await storage.write(key: 'token', value: received);
      token = received;
      widget.onAuthenticated();
    } catch (e) {
      if (mounted) message(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget field(
    String label,
    TextEditingController controller, {
    bool secret = false,
  }) => TextFormField(
    controller: controller,
    obscureText: secret,
    decoration: InputDecoration(labelText: label),
    validator: (v) =>
        v == null || v.trim().isEmpty ? '$label wajib diisi' : null,
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(register ? 'Daftar HatchCare' : 'Masuk HatchCare'),
    ),
    body: Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (register) field('Nama', name),
                  field(
                    register ? 'Username' : 'Username atau email',
                    username,
                  ),
                  if (register) field('Email', email),
                  field('Kata sandi', password, secret: true),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: busy ? null : submit,
                    child: Text(
                      busy
                          ? 'Memproses...'
                          : register
                          ? 'Daftar'
                          : 'Masuk',
                    ),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() => register = !register),
                    child: Text(
                      register
                          ? 'Sudah punya akun? Masuk'
                          : 'Belum punya akun? Daftar',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void message(BuildContext context, Object error) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onLogout});
  final VoidCallback onLogout;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<dynamic> latest;
  Timer? refreshTimer;
  @override
  void initState() {
    super.initState();
    refresh();
    refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => refresh(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  void refresh() => setState(() => latest = api('incubator/latest'));
  Future<void> logout() async {
    try {
      await api('logout', body: {});
    } catch (e) {
      if (mounted) {
        message(context, e);
      }
      return;
    }
    await storage.delete(key: 'token');
    token = null;
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('HatchCare'),
      actions: [
        IconButton(
          tooltip: 'Perbarui',
          onPressed: refresh,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Keluar',
          onPressed: logout,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: FutureBuilder<dynamic>(
      future: latest,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Gagal memuat inkubator: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data as Map<String, dynamic>;
        final control = data['control'] as Map<String, dynamic>?;
        final photos = (data['history'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();
        String deviceState(dynamic value) => value == null
            ? 'Belum tersedia'
            : value == true
            ? 'Aktif'
            : 'Mati';
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Status inkubator: ${data['online'] == true ? 'Terhubung' : 'Tidak terhubung'}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Suhu: ${data['temperature'] ?? 'Belum tersedia'}${data['temperature'] == null ? '' : ' °C'}',
            ),
            Text(
              'Kelembapan: ${data['humidity'] ?? 'Belum tersedia'}${data['humidity'] == null ? '' : ' %'}',
            ),
            Text(
              'Pembaruan terakhir: ${data['last_updated'] ?? 'Belum tersedia'}',
            ),
            Text('Lampu perangkat: ${deviceState(data['lamp'])}'),
            Text('Perintah lampu: ${control?['lampMode'] ?? 'Belum tersedia'}'),
            Text('Motor perangkat: ${deviceState(data['motor'])}'),
            Text(
              'Perintah jeda motor: ${control?['motorPaused'] == null
                  ? 'Belum tersedia'
                  : control?['motorPaused'] == true
                  ? 'Dijeda'
                  : 'Berjalan otomatis'}',
            ),
            const Text(
              'Status perangkat berasal dari telemetri terakhir; perintah belum tentu sudah diterapkan.',
            ),
            const SizedBox(height: 16),
            Text(
              'Foto dan deteksi inkubator',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text(
              'Foto tersedia selama satu jam dan diperbarui otomatis.',
            ),
            if (photos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Belum ada foto inkubator. Ambil foto melalui pengaturan.',
                ),
              )
            else
              ...photos.map((photo) => IncubatorPhoto(photo: photo)),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan inkubator dan candling'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.egg_alt),
              title: const Text('Pemeriksaan candling dan riwayat'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CandlingPage()),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class IncubatorPhoto extends StatelessWidget {
  const IncubatorPhoto({super.key, required this.photo});
  final Map<String, dynamic> photo;

  @override
  Widget build(BuildContext context) {
    final detection = photo['detection'] as Map<String, dynamic>?;
    final detections = (detection?['detections'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final status = detection?['status'];
    final rawDate = photo['at'];
    final date = rawDate is String
        ? DateTime.tryParse(rawDate)?.toLocal()
        : null;
    final filename = photo['filename'];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date == null
                  ? 'Waktu foto tidak tersedia'
                  : 'Foto: ${date.toString().substring(0, 19)}',
            ),
            const SizedBox(height: 8),
            if (filename is String && filename.isNotEmpty)
              Image.network(
                '$baseUrl/api/incubator/photo/${Uri.encodeComponent(filename)}',
                headers: {if (token != null) 'Authorization': 'Bearer $token'},
                width: double.infinity,
                fit: BoxFit.contain,
                semanticLabel: 'Foto asli inkubator',
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 160,
                        child: Center(child: Text('Memuat foto...')),
                      ),
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 100,
                  child: Center(child: Text('Foto tidak dapat dimuat.')),
                ),
              )
            else
              const Text('Foto tidak tersedia.'),
            const SizedBox(height: 8),
            if (status == 'success') ...[
              Text('Total: ${detection?['total_eggs']} telur'),
              Text(
                'Utuh: ${detections.where((d) => (d['class'] as String?)?.toLowerCase() == 'utuh').length}',
              ),
              Text(
                'Retak: ${detections.where((d) => (d['class'] as String?)?.toLowerCase() == 'retak').length}',
              ),
              if (detections.isEmpty)
                const Text('Tidak ada telur yang terdeteksi pada foto ini.'),
              for (final item in detections)
                Text(
                  'Telur ${item['id'] ?? '-'}: ${item['class'] ?? 'Tidak diketahui'}${item['confidence'] is num ? ' (${((item['confidence'] as num) * 100).toStringAsFixed(1)}%)' : ''}',
                ),
            ] else if (status == 'pending')
              const Text('Deteksi YOLO sedang diproses.')
            else if (status == 'failed')
              const Text('Deteksi YOLO gagal. Foto asli tetap tersedia.')
            else
              const Text('Hasil deteksi untuk foto ini belum tersedia.'),
            if (detection?['motor_pause'] == 'publish_failed')
              const Text(
                'Perintah jeda motor gagal dikirim. Periksa perangkat.',
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final fields = <String, TextEditingController>{};
  final labels = {
    'exposure': 'Exposure (0-1200)',
    'gain': 'Gain (0-30)',
    'quality': 'Quality (4-15)',
    'settle_ms': 'Settle (100-3000 ms)',
    'tempMin': 'Suhu minimum (30-45 °C)',
    'tempMax': 'Suhu maksimum (30-45 °C)',
    'motorIntervalHours': 'Interval motor (1-24 jam)',
    'motorDurationSeconds': 'Durasi motor (1-180 detik)',
    'captureIntervalSeconds': 'Interval foto (15-3600 detik)',
  };
  String mode = 'auto';
  bool? motorPaused;
  bool loading = true, busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final results = await Future.wait([
        api('candling/settings'),
        api('incubator/control'),
      ]);
      final values = <String, dynamic>{
        'exposure': 500,
        'gain': 0,
        'quality': 4,
        'settle_ms': 350,
        ...results[0] as Map<String, dynamic>,
        ...results[1]['control'] as Map<String, dynamic>,
      };
      for (final key in labels.keys) {
        fields.putIfAbsent(key, () => TextEditingController()).text =
            '${values[key] ?? ''}';
      }
      mode = values['lampMode'] ?? 'auto';
      motorPaused = values['motorPaused'] is bool
          ? values['motorPaused']
          : null;
    } catch (e) {
      error = e.toString();
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> send(String path, Map<String, dynamic> data) async {
    setState(() => busy = true);
    try {
      final result = await api(path, body: data);
      if (data.containsKey('motorPaused')) {
        final control = result['control'];
        if (control is! Map || control['motorPaused'] != data['motorPaused']) {
          throw Exception('API tidak mendukung perintah jeda motor.');
        }
        if (mounted) setState(() => motorPaused = control['motorPaused']);
      }
      if (mounted) {
        message(context, result['message'] ?? 'Pengaturan tersimpan');
      }
    } catch (e) {
      if (mounted) message(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void save(bool candling) {
    final keys = candling ? labels.keys.take(4) : labels.keys.skip(4);
    final values = <String, dynamic>{};
    for (final key in keys) {
      final value = num.tryParse(fields[key]!.text);
      if (value == null ||
          (!(key == 'tempMin' || key == 'tempMax') &&
              value != value.roundToDouble())) {
        message(context, 'Nilai ${labels[key]} tidak valid');
        return;
      }
      values[key] = key == 'tempMin' || key == 'tempMax'
          ? value
          : value.toInt();
    }
    if (!candling) values['lampMode'] = mode;
    send(candling ? 'candling/settings' : 'incubator/control', values);
  }

  Widget inputs(Iterable<String> keys) => Column(
    children: keys
        .map(
          (key) => TextField(
            controller: fields[key],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: labels[key]),
          ),
        )
        .toList(),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pengaturan')),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gagal memuat: $error'),
                TextButton(onPressed: load, child: const Text('Coba lagi')),
              ],
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Candling', style: Theme.of(context).textTheme.titleLarge),
              inputs(labels.keys.take(4)),
              FilledButton(
                onPressed: busy ? null : () => save(true),
                child: const Text('Simpan candling'),
              ),
              const SizedBox(height: 24),
              Text('Inkubator', style: Theme.of(context).textTheme.titleLarge),
              DropdownButtonFormField<String>(
                initialValue: mode,
                decoration: const InputDecoration(labelText: 'Mode lampu'),
                items: const [
                  DropdownMenuItem(value: 'auto', child: Text('Otomatis')),
                  DropdownMenuItem(value: 'on', child: Text('Nyala')),
                  DropdownMenuItem(value: 'off', child: Text('Mati')),
                ],
                onChanged: (v) => setState(() => mode = v!),
              ),
              inputs(labels.keys.skip(4)),
              FilledButton(
                onPressed: busy ? null : () => save(false),
                child: const Text('Simpan inkubator'),
              ),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => send('incubator/control', {'triggerMotor': true}),
                child: const Text('Putar motor sekali'),
              ),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => send('incubator/control', {'triggerCapture': true}),
                child: const Text('Ambil foto inkubator'),
              ),
              OutlinedButton(
                onPressed: busy || motorPaused == null
                    ? null
                    : () => send('incubator/control', {
                        'motorPaused': !motorPaused!,
                      }),
                child: Text(
                  motorPaused == true ? 'Lanjutkan motor' : 'Jeda motor',
                ),
              ),
              if (motorPaused == null)
                const Text('Jeda motor belum didukung API inkubator.'),
            ],
          ),
  );
}

class CandlingPage extends StatefulWidget {
  const CandlingPage({super.key});
  @override
  State<CandlingPage> createState() => _CandlingPageState();
}

class _CandlingPageState extends State<CandlingPage> {
  late Future<dynamic> history;
  Map<String, dynamic>? job;
  bool busy = false;
  String status = '';
  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() => setState(() => history = api('egg/history'));
  Future<void> detail(dynamic id) async {
    try {
      final result = await api('egg/job/$id');
      if (mounted) setState(() => job = result);
    } catch (e) {
      if (mounted) message(context, e);
    }
  }

  Future<void> capture() async {
    setState(() {
      busy = true;
      status = 'Mengirim permintaan foto...';
    });
    try {
      final result = await api('egg/capture', body: {});
      final id = result['job'];
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        final current = await api('egg/job/$id');
        if (!mounted) return;
        setState(() => status = 'Status: ${current['status']}');
        if (current['status'] == 'done') {
          setState(() => job = current);
          refresh();
          return;
        }
        if (current['status'] == 'failed') {
          throw Exception('Pengambilan foto gagal');
        }
      }
      throw Exception('Waktu tunggu habis. Periksa riwayat nanti.');
    } catch (e) {
      if (mounted) message(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Candling'),
      actions: [
        IconButton(
          tooltip: 'Perbarui riwayat',
          onPressed: refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FilledButton(
          onPressed: busy ? null : capture,
          child: Text(busy ? 'Menunggu hasil...' : 'Ambil foto candling'),
        ),
        if (status.isNotEmpty) Text(status),
        if (job != null) ...[
          const SizedBox(height: 16),
          if (job!['url'] is String &&
              (job!['url'] as String).startsWith('data:'))
            Image.memory(
              base64Decode((job!['url'] as String).split(',').last),
              height: 220,
              errorBuilder: (_, _, _) =>
                  const Text('Foto tidak dapat ditampilkan'),
            ),
          Text(
            'Prediksi: ${job!['prediction_label'] ?? 'Belum tersedia'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (job!['confidence'] != null)
            Text('Keyakinan: ${job!['confidence']}'),
          if (job!['prediction_result'] is Map &&
              job!['prediction_result']['probabilitas'] != null)
            Text('Probabilitas: ${job!['prediction_result']['probabilitas']}'),
          if (job!['llm_analysis'] != null)
            Text('Analisis: ${job!['llm_analysis']}'),
        ],
        const Divider(height: 32),
        Text('Riwayat candling', style: Theme.of(context).textTheme.titleLarge),
        FutureBuilder<dynamic>(
          future: history,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Gagal memuat riwayat: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snapshot.data as List;
            if (list.isEmpty) {
              return const Text(
                'Belum ada pemeriksaan. Ambil foto untuk memulai.',
              );
            }
            return Column(
              children: list
                  .map(
                    (item) => ListTile(
                      title: Text(
                        'Pemeriksaan #${item['id']}: ${item['prediction_label'] ?? 'Belum ada prediksi'}',
                      ),
                      subtitle: Text('${item['at'] ?? ''}'),
                      onTap: () => detail(item['id']),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    ),
  );
}
