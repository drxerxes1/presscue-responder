import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainPageIndexProvider = StateProvider<int>((ref) => 0);

final toggleProvider = StateProvider<bool>((ref) => true);

final alignment1Provider = StateProvider<Alignment>((ref) => Alignment(0.0, 0.88));
final alignment2Provider = StateProvider<Alignment>((ref) => Alignment(0.0, 0.88));
final alignment3Provider = StateProvider<Alignment>((ref) => Alignment(0.0, 0.88));
final alignment4Provider = StateProvider<Alignment>((ref) => Alignment(0.0, 0.88));
