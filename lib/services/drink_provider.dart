/// Estado da aplicação (navegação, seleção e customização de drinks).
///
/// Responsabilidades:
///   - fluxo de telas do kiosk;
///   - montagem/validação do drink (preset ou personalizado);
///   - delegar a fabricação ao [MachineService];
///   - delegar persistência ao [DrinkRepository].
///
/// O provider NÃO monta frames do protocolo nem fala com transporte.
library;

import 'package:flutter/material.dart';

import '../data/drink_repository.dart';
import '../data/settings_repository.dart';
import '../models/drink_models.dart';
import 'machine_service.dart';

enum AppScreen { home, customize, payment, making, done, error, admin }

class DrinkProvider extends ChangeNotifier {
  final MachineService _machine;
  final DrinkRepository _repository;
  final SettingsRepository _settingsRepository;

  AppSettings _settings = AppSettings.defaults();

  DrinkProvider({
    required MachineService machine,
    required DrinkRepository repository,
    required SettingsRepository settingsRepository,
  })  : _machine = machine,
        _repository = repository,
        _settingsRepository = settingsRepository;

  /// Carrega estado persistido e níveis iniciais. Chamar uma vez no boot.
  Future<void> init() async {
    _settings = await _settingsRepository.load();
    _applySettings();
    _userDrinks
      ..clear()
      ..addAll(await _repository.loadUserDrinks());
    notifyListeners();
    await refreshLevels();
  }

  void _applySettings() {
    Calibration.msPerMl = _settings.msPerMl;
    Calibration.valveOpenMs = _settings.valveOpenMs;
    _settings.ingredientNames.forEach((reservoir, name) {
      final idx = defaultIngredients.indexWhere((i) => i.reservoir == reservoir);
      if (idx != -1) {
        final old = defaultIngredients[idx];
        defaultIngredients[idx] = Ingredient(
          reservoir: old.reservoir,
          name: name,
          color: old.color,
          icon: old.icon,
        );
      }
    });
  }

  Future<void> _persistSettings() => _settingsRepository.save(_settings);

  // ─── Estado de navegação ──────────────────────────────────
  AppScreen _currentScreen = AppScreen.home;
  AppScreen get currentScreen => _currentScreen;

  // ─── Drink selecionado ────────────────────────────────────
  DrinkPreset? _selectedPreset;
  DrinkPreset? get selectedPreset => _selectedPreset;

  // ─── Porções customizadas (modo personalizar) ─────────────
  List<DrinkPortion> _customPortions = [];
  List<DrinkPortion> get customPortions => _customPortions;

  bool _isCustomMode = false;
  bool get isCustomMode => _isCustomMode;

  // ─── Progresso de fabricação ──────────────────────────────
  double _makingProgress = 0;
  double get makingProgress => _makingProgress;

  String _commandString = '';
  String get commandString => _commandString;

  bool _isDispensing = false;
  bool get isDispensing => _isDispensing;

  // ─── Nível dos reservatórios ──────────────────────────────
  Map<int, int> get reservoirLevels => _machine.levels;

  Future<void> refreshLevels() async {
    await _machine.requestLevels();
    notifyListeners();
  }

  // ─── Drinks customizados (criados pelo owner) ─────────────
  final List<DrinkPreset> _userDrinks = [];
  List<DrinkPreset> get userDrinks => _userDrinks;
  List<DrinkPreset> get allDrinks => [...presetDrinks, ..._userDrinks];

  // ─── Getters calculados ───────────────────────────────────
  List<DrinkPortion> get activePortion =>
      _isCustomMode ? _customPortions : (_selectedPreset?.portions ?? []);

  int get totalMl => activePortion.fold(0, (s, p) => s + p.ml);
  int get totalTimeMs => activePortion.fold(0, (s, p) => s + p.timeMs);
  int get remainingMl => cupMl - totalMl;
  bool get isValid => totalMl > 0 && totalMl <= cupMl;


  // ─── Disponibilidade (estoque) ────────────────────────────

  int levelOf(int reservoir) => _machine.levels[reservoir] ?? 0;
  bool isReservoirEmpty(int reservoir) => levelOf(reservoir) <= 0;

  /// Drink pode ser servido? (nenhum reservatório usado está vazio)
  bool isDrinkAvailable(DrinkPreset drink) => drink.portions
      .where((p) => p.ml > 0)
      .every((p) => !isReservoirEmpty(p.reservoir));

  /// O drink ativo (preset ou personalizado) pode ser servido?
  bool get activeAvailable => activePortion
      .where((p) => p.ml > 0)
      .every((p) => !isReservoirEmpty(p.reservoir));

  /// Reservatórios vazios usados pelo drink ativo (para mensagens).
  List<Ingredient> get missingIngredients => activePortion
      .where((p) => p.ml > 0 && isReservoirEmpty(p.reservoir))
      .map((p) => ingredientFor(p.reservoir))
      .toList();

  // ─── Pagamento (simulado nesta versão) ────────────────────

  int get drinkPriceCents => _settings.drinkPriceCents;

  AppScreen _screenBeforePayment = AppScreen.home;

  /// Vai para a tela de pagamento (chamada pelos botões "Fazer drink").
  void goToPayment() {
    if (!isValid || !activeAvailable || _isDispensing) return;
    _screenBeforePayment = _currentScreen;
    _currentScreen = AppScreen.payment;
    notifyListeners();
  }

  void cancelPayment() {
    _currentScreen = _screenBeforePayment;
    notifyListeners();
  }

  /// Pagamento aprovado (simulação) — inicia o preparo.
  Future<void> confirmPayment() => makeDrink();

  // ─── Erro de preparo ──────────────────────────────────────

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _simulateNextFailure = false;
  bool get simulateNextFailure => _simulateNextFailure;
  void toggleSimulateFailure() {
    _simulateNextFailure = !_simulateNextFailure;
    notifyListeners();
  }

  /// Usuário reconheceu o erro: volta ao início.
  void acknowledgeError() => goHome();

  // ─── Estatísticas de operação ─────────────────────────────

  int get drinksServed => _settings.drinksServed;
  Map<int, int> get mlServedByReservoir => _settings.mlServedByReservoir;

  Future<void> resetStats() async {
    _settings.drinksServed = 0;
    _settings.mlServedByReservoir =
        {for (int i = 1; i <= numReservoirs; i++) i: 0};
    notifyListeners();
    await _persistSettings();
  }

  Future<void> _recordServed(List<DrinkPortion> portions) async {
    _settings.drinksServed += 1;
    for (final p in portions) {
      _settings.mlServedByReservoir[p.reservoir] =
          (_settings.mlServedByReservoir[p.reservoir] ?? 0) + p.ml;
    }
    await _persistSettings();
  }

  // ─── Configurações (painel admin) ─────────────────────────

  String get adminPin => _settings.adminPin;

  Future<void> setDrinkPriceCents(int cents) async {
    _settings.drinkPriceCents = cents.clamp(0, 1000000);
    notifyListeners();
    await _persistSettings();
  }

  Future<void> setCalibration({int? msPerMlValue, int? valveOpenMsValue}) async {
    if (msPerMlValue != null) {
      _settings.msPerMl = msPerMlValue.clamp(1, 1000);
    }
    if (valveOpenMsValue != null) {
      _settings.valveOpenMs = valveOpenMsValue.clamp(0, 5000);
    }
    Calibration.msPerMl = _settings.msPerMl;
    Calibration.valveOpenMs = _settings.valveOpenMs;
    notifyListeners();
    await _persistSettings();
  }

  Future<void> renameIngredient(int reservoir, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final idx = defaultIngredients.indexWhere((i) => i.reservoir == reservoir);
    if (idx == -1) return;
    final old = defaultIngredients[idx];
    defaultIngredients[idx] = Ingredient(
      reservoir: old.reservoir,
      name: trimmed,
      color: old.color,
      icon: old.icon,
    );
    _settings.ingredientNames[reservoir] = trimmed;
    notifyListeners();
    await _persistSettings();
  }

  /// Reabastece um reservatório (simulado nesta versão).
  Future<void> refillReservoir(int reservoir) async {
    await _machine.refill(reservoir);
    notifyListeners();
  }

  // ─── Ações ────────────────────────────────────────────────

  void selectPreset(DrinkPreset preset) {
    _selectedPreset = preset;
    _isCustomMode = false;
    _customPortions = preset.portions
        .map((p) => DrinkPortion(reservoir: p.reservoir, ml: p.ml))
        .toList();
    notifyListeners();
  }

  void goToCustomize() {
    if (_customPortions.isEmpty) {
      _customPortions = [const DrinkPortion(reservoir: 1, ml: 0)];
    }
    _isCustomMode = true;
    _currentScreen = AppScreen.customize;
    notifyListeners();
  }

  void goToCustomizeFromPreset() {
    _isCustomMode = true;
    _currentScreen = AppScreen.customize;
    notifyListeners();
  }

  void startCustomDrink() {
    _selectedPreset = null;
    _isCustomMode = true;
    _customPortions = [];
    _currentScreen = AppScreen.customize;
    notifyListeners();
  }

  void addIngredient(int reservoir) {
    if (_customPortions.any((p) => p.reservoir == reservoir)) return;
    if (_customPortions.length >= numReservoirs) return;
    _customPortions.add(DrinkPortion(reservoir: reservoir, ml: 0));
    notifyListeners();
  }

  void removeIngredient(int reservoir) {
    _customPortions.removeWhere((p) => p.reservoir == reservoir);
    notifyListeners();
  }

  void updatePortionMl(int reservoir, int ml) {
    final idx = _customPortions.indexWhere((p) => p.reservoir == reservoir);
    if (idx == -1) return;

    final othersTotal = _customPortions
        .where((p) => p.reservoir != reservoir)
        .fold(0, (s, p) => s + p.ml);
    final maxForThis = cupMl - othersTotal;
    final clamped = ml.clamp(0, maxForThis);

    _customPortions[idx] = DrinkPortion(reservoir: reservoir, ml: clamped);
    notifyListeners();
  }

  // ─── Gerenciar drinks salvos ──────────────────────────────

  Future<void> saveDrink({
    required String name,
    required String description,
    required List<DrinkPortion> portions,
  }) async {
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _userDrinks.add(DrinkPreset(
      id: id,
      name: name,
      emoji: '🍸',
      description: description,
      portions: List.of(portions),
    ));
    notifyListeners();
    await _repository.saveUserDrinks(_userDrinks);
  }

  Future<void> deleteDrink(String id) async {
    _userDrinks.removeWhere((d) => d.id == id);
    notifyListeners();
    await _repository.saveUserDrinks(_userDrinks);
  }

  // ─── Fazer o drink ────────────────────────────────────────

  Future<void> makeDrink() async {
    if (!isValid || _isDispensing) return;

    _isDispensing = true;
    _makingProgress = 0;
    _commandString = _machine.commandFor(activePortion);
    _currentScreen = AppScreen.making;
    notifyListeners();

    try {
      await _machine.dispense(
        activePortion,
        onProgress: (p) {
          _makingProgress = p;
          notifyListeners();
        },
      );
      _currentScreen = AppScreen.done;
    } catch (_) {
      // TODO(ux): tela de erro dedicada ("verifique a máquina").
      _currentScreen = AppScreen.home;
    } finally {
      _isDispensing = false;
      notifyListeners();
    }

    // Estoque mudou: atualizar níveis em segundo plano.
    refreshLevels();
  }

  /// Aciona uma válvula isolada para teste/calibragem (painel admin).
  /// Retorna o frame enviado, para exibição.
  Future<String> testValve(int reservoir, int ml) async {
    final portions = [DrinkPortion(reservoir: reservoir, ml: ml)];
    final cmd = _machine.commandFor(portions);
    await _machine.dispense(portions);
    refreshLevels();
    return cmd;
  }

  void goHome() {
    _currentScreen = AppScreen.home;
    _errorMessage = '';
    _selectedPreset = null;
    _isCustomMode = false;
    _customPortions = [];
    _commandString = '';
    _makingProgress = 0;
    notifyListeners();
  }

  void goToAdmin() {
    _currentScreen = AppScreen.admin;
    notifyListeners();
  }

  void goBack() {
    if (_currentScreen == AppScreen.customize ||
        _currentScreen == AppScreen.admin) {
      _currentScreen = AppScreen.home;
    }
    notifyListeners();
  }
}

/// Falha reportada (ou simulada) durante o preparo de um drink.
class MachineFailure implements Exception {
  final String message;
  MachineFailure(this.message);
}
