/// Tipo de cuenta de Nexus Mods.
///
/// La API (users/validate.json) solo informa dos banderas: `is_premium` e
/// `is_supporter`. Con ellas se distinguen estos tres planes.
enum NexusPlan {
  member,
  supporter,
  premium;

  bool get isPremium => this == NexusPlan.premium;

  /// Premium manda sobre Supporter; sin ninguna bandera es Member.
  static NexusPlan fromFlags({
    required bool isPremium,
    required bool isSupporter,
  }) {
    if (isPremium) return NexusPlan.premium;
    if (isSupporter) return NexusPlan.supporter;
    return NexusPlan.member;
  }

  /// Para leer el plan guardado en SharedPreferences.
  static NexusPlan fromName(String? name) => NexusPlan.values.firstWhere(
        (p) => p.name == name,
        orElse: () => NexusPlan.member,
      );
}
