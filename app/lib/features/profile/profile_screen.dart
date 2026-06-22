import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('关于'),
            subtitle: Text('时间管理手账 v1.0.0\n提升执行力 · 养成专注 · 规范作息'),
          ),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('数据存储'),
            subtitle: Text('所有数据保存在本机，MVP 阶段不上云'),
          ),
        ],
      ),
    );
  }
}
