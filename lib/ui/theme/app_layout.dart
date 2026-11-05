// Layout controls geometry; the selected color palette remains independent.
// Nombres que ve el usuario (ARB: layoutMacos / layoutMaterial / layoutFlat):
//   ios      → "Estilo macOS" (superficies translúcidas con desenfoque, esquinas redondas)
//   material → "Material"
//   minimal  → "Plano" (superficies sólidas, contornos finos, sin sombras)
// Los identificadores se conservan para no invalidar el diseño ya guardado.
enum AppLayoutId { ios, material, minimal }

class AppLayouts {
  AppLayouts._();

  static const defaultId = AppLayoutId.ios;
  static const selectable = [
    AppLayoutId.ios,
    AppLayoutId.material,
    AppLayoutId.minimal,
  ];
  static AppLayoutId _current = defaultId;
  static AppLayoutId get current => _current;

  // Both layouts use the shared desktop control interfaces.
  static bool get isMaterial => _current != AppLayoutId.ios;
  static bool get isMinimal => _current == AppLayoutId.minimal;
  static void apply(AppLayoutId id) => _current = id;

  static AppLayoutId parse(String? name) {
    // Migrate the retired layout preference without changing other settings.
    if (name == 'clay') return AppLayoutId.minimal;
    for (final layout in AppLayoutId.values) {
      if (layout.name == name) return layout;
    }
    return defaultId;
  }
}