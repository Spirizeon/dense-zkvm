import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/densezk_provider.dart';
import 'screens/home_screen.dart';
import 'screens/execute_flow_screen.dart';
import 'screens/witness_screen.dart';
import 'screens/prove_screen.dart';
import 'screens/poseidon_hash_screen.dart';
import 'screens/stress_test_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DenseZkMobileApp());
}

class DenseZkMobileApp extends StatefulWidget {
  const DenseZkMobileApp({super.key});

  @override
  State<DenseZkMobileApp> createState() => _DenseZkMobileAppState();
}

class _DenseZkMobileAppState extends State<DenseZkMobileApp> {
  late final DenseZkProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = DenseZkProvider();
    _provider.init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: MaterialApp(
        title: 'DenseZK',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/execute': (_) => const ExecuteFlowScreen(),
          '/witness': (_) => const WitnessScreen(),
          '/prove': (_) => const ProveScreen(),
          '/poseidon': (_) => const PoseidonHashScreen(),
          '/stress': (_) => const StressTestScreen(),
        },
      ),
    );
  }
}
