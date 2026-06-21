import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/admin_screen.dart';
import 'screens/customize_screen.dart';
import 'screens/done_screen.dart';
import 'screens/home_screen.dart';
import 'screens/making_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/error_screen.dart';
import 'services/drink_provider.dart';
import 'theme/sd_theme.dart';
import 'widgets/festive_background.dart';

/// Raiz do app: tema, fundo festivo global ([FestiveBackground]) e o roteador
/// de telas por estado ([_ScreenRouter]).
class SmartDrinkApp extends StatelessWidget {
  const SmartDrinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Drink',
      debugShowCheckedModeBanner: false,
      theme: SDTheme.theme,
      // O gradiente festivo fica atrás de tudo; as telas usam Scaffold
      // transparente e "flutuam" sobre ele.
      home: const FestiveBackground(child: _ScreenRouter()),
    );
  }
}

/// Navegação por estado (enum) em vez de Navigator: adequada para kiosk —
/// não há botão "voltar" do sistema e o fluxo é um ciclo fechado.
class _ScreenRouter extends StatelessWidget {
  const _ScreenRouter();

  @override
  Widget build(BuildContext context) {
    final screen = context.watch<DrinkProvider>().currentScreen;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildScreen(screen),
    );
  }

  Widget _buildScreen(AppScreen screen) {
    switch (screen) {
      case AppScreen.home:
        return const HomeScreen(key: ValueKey('home'));
      case AppScreen.customize:
        return const CustomizeScreen(key: ValueKey('customize'));
      case AppScreen.payment:
        return const PaymentScreen(key: ValueKey('payment'));
      case AppScreen.making:
        return const MakingScreen(key: ValueKey('making'));
      case AppScreen.done:
        return const DoneScreen(key: ValueKey('done'));
      case AppScreen.error:
        return const ErrorScreen(key: ValueKey('error'));
      case AppScreen.admin:
        return const AdminScreen(key: ValueKey('admin'));
    }
  }
}
