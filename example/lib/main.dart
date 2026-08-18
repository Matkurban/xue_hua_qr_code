import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:xue_hua_qr_code/xue_hua_qr_code.dart';

void main() {
  runApp(const XueHuaQrCodeExampleApp());
}

class XueHuaQrCodeExampleApp extends StatelessWidget {
  const XueHuaQrCodeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xue_hua_qr_code examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  static const _data = 'https://example.com/xue-hua-qr-code';
  static const _logoAsset = 'assets/logo/logo.png';

  int _tab = 0;
  Uint8List? _pngBytes;

  /// 每个标签页对应一种样式配置(基础 / 圆形 / 圆角 / 渐变 / Logo)。
  (QrStyle, QrLogo?) _configForTab() => switch (_tab) {
    // 基础用法:全部默认值。
    0 => (const QrStyle(), null),
    1 => (const QrStyle(shape: QrModuleShape.circle, color: Colors.blue), null),
    2 => (
      const QrStyle(
        shape: QrModuleShape.roundedSquare,
        color: Colors.green,
        moduleRadius: 0.4,
      ),
      null,
    ),
    3 => (
      const QrStyle(
        shape: QrModuleShape.roundedSquare,
        backgroundColor: Colors.black,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink, Colors.blue],
        ),
      ),
      null,
    ),
    // 进阶用法:带 Logo(纠错等级自动升为 high)。
    _ => (
      const QrStyle(shape: QrModuleShape.roundedSquare),
      const QrLogo(
        image: AssetImage(_logoAsset),
        scale: 0.22,
        padding: 6,
        borderRadius: 8,
      ),
    ),
  };

  Future<void> _exportPng() async {
    final (style, logo) = _configForTab();
    final bytes = await XueHuaQrCode.toPngBytes(
      _data,
      size: 512,
      style: style,
      logo: logo,
    );
    if (mounted) setState(() => _pngBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final (style, logo) = _configForTab();

    return Scaffold(
      appBar: AppBar(title: const Text('xue_hua_qr_code examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Basic')),
              ButtonSegment(value: 1, label: Text('Circle')),
              ButtonSegment(value: 2, label: Text('Rounded')),
              ButtonSegment(value: 3, label: Text('Gradient')),
              ButtonSegment(value: 4, label: Text('Logo')),
            ],
            selected: {_tab},
            onSelectionChanged: (value) {
              setState(() {
                _tab = value.first;
                _pngBytes = null;
              });
            },
          ),
          const SizedBox(height: 24),
          const Text('Live widget preview', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Center(
            child: XueHuaQrCode(
              value: _data,
              size: 240,
              style: style,
              logo: logo,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 48),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              onPressed: _exportPng,
              icon: const Icon(Icons.image),
              label: const Text('Export PNG (512px)'),
            ),
          ),
          const SizedBox(height: 16),
          if (_pngBytes != null)
            Center(child: Image.memory(_pngBytes!, width: 240, height: 240)),
        ],
      ),
    );
  }
}
