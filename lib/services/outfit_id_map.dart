// GENERADO a partir de Nanosuit_codigos.xlsx + mapa_stellar_blade.txt (FModel).
// Clave = carpeta de Art/Character/PC (minúsculas). Los nombres coinciden con
// stellarBladeOutfits (outfit_data.dart), que es lo que guarda replacesOutfits.

class OutfitEntry {
  /// Nombre de archivo (sin extensión, minúsculas) que identifica este traje.
  final String stem;
  final String name;
  /// true = traje 'base' de la carpeta (el que se asigna si solo se toca la carpeta).
  final bool isDefault;
  const OutfitEntry(this.stem, this.name, {this.isDefault = false});
}

const Map<String, List<OutfitEntry>> kOutfitFolders = {
  'ch_p_eve_02': [
    OutfitEntry('ch_p_eve_02', 'Daily Biker', isDefault: true),
    OutfitEntry('ch_p_eve_02_typeb', 'FourSeconds Biker'),
  ],
  'ch_p_eve_04': [
    OutfitEntry('ch_p_eve_04', 'Daily Denim', isDefault: true),
    OutfitEntry('ch_p_eve_04_typeb', 'FourSeconds Denim'),
  ],
  'ch_p_eve_05': [
    OutfitEntry('ch_p_eve_05', 'Daily Sailor', isDefault: true),
    OutfitEntry('ch_p_eve_05_typeb', 'Comfort Sailor'),
  ],
  'ch_p_eve_06': [
    OutfitEntry('ch_p_eve_06', 'Black Wave', isDefault: true),
    OutfitEntry('ch_p_eve_06_typeb', 'Wild Wave'),
  ],
  'ch_p_eve_07': [
    OutfitEntry('ch_p_eve_07', 'Punk Top', isDefault: true),
    OutfitEntry('ch_p_eve_07_type_b', 'Punk Style'),
  ],
  'ch_p_eve_08': [
    OutfitEntry('ch_p_eve_08', 'Planet Diving Suit (6th)', isDefault: true),
    OutfitEntry('ch_p_eve_08_type_b_orangered', 'Planet Diving Suit (6th) V2'),
    OutfitEntry('ch_p_eve_08_typec', 'Planet Diving Suit (6th) V3'),
  ],
  'ch_p_eve_09': [
    OutfitEntry('ch_p_eve_09', 'Planet Diving Suit (7th)', isDefault: true),
    OutfitEntry('ch_p_eve_09_typeb', 'Planet Diving Suit (7th) V2'),
    OutfitEntry('ch_p_eve_09_typec', 'Planet Diving Suit (7th) V3'),
  ],
  'ch_p_eve_09_v02': [
    OutfitEntry('ch_p_eve_09_v02', 'Planet Diving Protection Suit (7th)', isDefault: true),
    OutfitEntry('ch_p_eve_09_v02_typeb', 'Planet Diving Protection Suit (7th) V2'),
  ],
  'ch_p_eve_10': [
    OutfitEntry('ch_p_eve_10', 'Planet Diving Suit (Captain)', isDefault: true),
  ],
  'ch_p_eve_11': [
    OutfitEntry('ch_p_eve_11', 'Raven Suit', isDefault: true),
  ],
  'ch_p_eve_14': [
    OutfitEntry('ch_p_eve_14', 'Planet Diving Suit (3rd)', isDefault: true),
    OutfitEntry('ch_p_eve_14_typeb', 'Planet Diving Suit (3rd) V2'),
    OutfitEntry('ch_p_eve_14_1', 'Prototype Planet Diving Suit'),
    OutfitEntry('ch_p_eve_14_1_typeb', 'Prototype Planet Diving Suit V2'),
  ],
  'ch_p_eve_15': [
    OutfitEntry('ch_p_eve_15_v02', 'Orca Engineer', isDefault: true),
    OutfitEntry('ch_p_eve_15_v02_typeb', 'Orca Techie'),
  ],
  'ch_p_eve_16': [
    OutfitEntry('ch_p_eve_16', 'Black Kunoichi', isDefault: true),
    OutfitEntry('ch_p_eve_16_typeb', 'White Kunoichi'),
  ],
  'ch_p_eve_17': [
    OutfitEntry('ch_p_eve_17', 'Sporty Yellow', isDefault: true),
    OutfitEntry('ch_p_eve_17_typeb', 'Sporty Energy'),
  ],
  'ch_p_eve_18': [
    OutfitEntry('ch_p_eve_18', 'Daily Mascot', isDefault: true),
    OutfitEntry('ch_p_eve_18_typeb', 'Comfort Mascot'),
  ],
  'ch_p_eve_19': [
    OutfitEntry('ch_p_eve_19', 'Cybernetic Bondage', isDefault: true),
    OutfitEntry('ch_p_eve_19_typeb', 'Autonetic Bondage'),
  ],
  'ch_p_eve_20': [
    OutfitEntry('ch_p_eve_20', 'Black Rose', isDefault: true),
    OutfitEntry('ch_p_eve_20_typeb', 'La Vie en Rose'),
    OutfitEntry('ch_p_eve_20_typec', 'Angelic Rose'),
  ],
  'ch_p_eve_21': [
    OutfitEntry('ch_p_eve_21', 'Sky Ace', isDefault: true),
    OutfitEntry('ch_p_eve_21_typeb', 'Air Ace'),
  ],
  'ch_p_eve_22': [
    OutfitEntry('ch_p_eve_22', 'White Full Dress', isDefault: true),
  ],
  'ch_p_eve_23': [
    OutfitEntry('ch_p_eve_23', 'Black Full Dress', isDefault: true),
  ],
  'ch_p_eve_24': [
    OutfitEntry('ch_p_eve_24', 'Wasteland Adventurer', isDefault: true),
    OutfitEntry('ch_p_eve_24_typeb', 'Wasteland Explorer'),
  ],
  'ch_p_eve_25': [
    OutfitEntry('ch_p_eve_25', 'Motivation', isDefault: true),
    OutfitEntry('ch_p_eve_25_typeb', 'Resonance'),
  ],
  'ch_p_eve_26': [
    OutfitEntry('ch_p_eve_26', 'Red Passion', isDefault: true),
    OutfitEntry('ch_p_eve_26_typeb', 'Emerald Passion'),
  ],
  'ch_p_eve_27': [
    OutfitEntry('ch_p_eve_27', 'Ocean Maid', isDefault: true),
    OutfitEntry('ch_p_eve_27_typeb', 'Tidal Maid'),
  ],
  'ch_p_eve_28': [
    OutfitEntry('ch_p_eve_28', 'Holiday Rabbit', isDefault: true),
    OutfitEntry('ch_p_eve_28_typeb', 'Holiday Bunny'),
  ],
  'ch_p_eve_29': [
    OutfitEntry('ch_p_eve_29', 'Keyhole Suit', isDefault: true),
    OutfitEntry('ch_p_eve_29_typeb', 'Stargazer Suit'),
    OutfitEntry('ch_p_eve_29_typec', 'Keyhole Dress'),
  ],
  'ch_p_eve_30': [
    OutfitEntry('ch_p_eve_30', 'Planet Diving Suit (2nd)', isDefault: true),
    OutfitEntry('ch_p_eve_30_typeb', 'Planet Diving Suit (2nd) V2'),
  ],
  'ch_p_eve_31': [
    OutfitEntry('ch_p_eve_31', 'Cybernetic Dress', isDefault: true),
    OutfitEntry('ch_p_eve_31_typeb', 'Cybernetic Suit'),
  ],
  'ch_p_eve_32': [
    OutfitEntry('ch_p_eve_32', 'Daily Knitted Dress', isDefault: true),
    OutfitEntry('ch_p_eve_32_typeb', 'Comfort Knitted Dress'),
  ],
  'ch_p_eve_33': [
    OutfitEntry('ch_p_eve_33', 'Peony', isDefault: true),
    OutfitEntry('ch_p_eve_33_body_02', 'Hydrangea'),
  ],
  'ch_p_eve_34': [
    OutfitEntry('ch_p_eve_34', 'Moutan Peony', isDefault: true),
    OutfitEntry('ch_p_eve_34_body_02', 'Black Lotus'),
  ],
  'ch_p_eve_35': [
    OutfitEntry('ch_p_eve_35', 'Black Pearl', isDefault: true),
    OutfitEntry('ch_p_eve_35_typeb', 'Red Pearl'),
  ],
  'ch_p_eve_36': [
    OutfitEntry('ch_p_eve_36', 'Junk Mechanic', isDefault: true),
    OutfitEntry('ch_p_eve_36_typeb', 'Junk Engineer'),
  ],
  'ch_p_eve_37': [
    OutfitEntry('ch_p_eve_37', 'Office Style', isDefault: true),
    OutfitEntry('ch_p_eve_37_typeb', 'Crew Style'),
  ],
  'ch_p_eve_39': [
    OutfitEntry('ch_p_eve_39', 'Daily Force', isDefault: true),
    OutfitEntry('ch_p_eve_39_typeb', 'Comfort Force'),
  ],
  'ch_p_eve_40': [
    OutfitEntry('ch_p_eve_40', 'Cyber Magician', isDefault: true),
    OutfitEntry('ch_p_eve_40_typeb', 'Cyber Trickster'),
    OutfitEntry('ch_p_eve_40_typec', 'Cyber Illusionist'),
  ],
  'ch_p_eve_41': [
    OutfitEntry('ch_p_eve_41', 'Racer\'s High', isDefault: true),
    OutfitEntry('ch_p_eve_41_typeb', 'Speeder\'s High'),
  ],
  'ch_p_eve_42': [
    OutfitEntry('ch_p_eve_42', 'Orca Exploration Suit', isDefault: true),
    OutfitEntry('ch_p_eve_42_typeb', 'Orca Pathfinder'),
  ],
  'ch_p_eve_43': [
    OutfitEntry('ch_p_eve_43', 'Blue Monsoon', isDefault: true),
    OutfitEntry('ch_p_eve_43_typeb', 'White Monsoon'),
  ],
  'ch_p_eve_45': [
    OutfitEntry('ch_p_eve_45', 'Fluffy Bear', isDefault: true),
    OutfitEntry('ch_p_eve_45_typeb', 'Pink Bear'),
  ],
  'ch_p_eve_46': [
    OutfitEntry('ch_p_eve_46', 'Silver Kunoichi', isDefault: true),
    OutfitEntry('ch_p_eve_46_typeb', 'Shadow Kunoichi'),
  ],
  'ch_p_eve_47': [
    OutfitEntry('ch_p_eve_47', 'Cyber Bunny', isDefault: true),
  ],
  'ch_p_eve_48': [
    OutfitEntry('ch_p_eve_48', 'Ocean String', isDefault: true),
  ],
  'ch_p_eve_49': [
    OutfitEntry('ch_p_eve_49', 'White Pearl', isDefault: true),
    OutfitEntry('ch_p_eve_49_typeb', 'Aqua Pearl'),
  ],
  'ch_p_eve_50': [
    OutfitEntry('ch_p_eve_50', 'FourSeconds Everyday Wear', isDefault: true),
    OutfitEntry('ch_p_eve_50_typeb', 'FourSeconds Essential Wear'),
  ],
  'ch_p_eve_51': [
    OutfitEntry('ch_p_eve_51', 'FourSeconds Destroyed Denim', isDefault: true),
  ],
  'ch_p_eve_52': [
    OutfitEntry('ch_p_eve_52', 'FourSeconds Black Denim', isDefault: true),
    OutfitEntry('ch_p_eve_52_typeb', 'FourSeconds Striped Denim'),
  ],
  'ch_p_eve_53': [
    OutfitEntry('ch_p_eve_53', 'Ultimate Bunny', isDefault: true),
    OutfitEntry('ch_p_eve_53_typeb', 'Extreme Bunny'),
  ],
  'ch_p_eve_54': [
    OutfitEntry('ch_p_eve_54', 'Neurocircuit Bondage', isDefault: true),
  ],
  'ch_p_eve_55': [
    OutfitEntry('ch_p_eve_55', 'Prototype Neurolink Suit', isDefault: true),
    OutfitEntry('ch_p_eve_55_typeb', 'Prototype Sensate Suit'),
  ],
  'ch_p_eve_56': [
    OutfitEntry('ch_p_eve_56', 'Neurolink Suit', isDefault: true),
  ],
  'ch_p_eve_57': [
    OutfitEntry('ch_p_eve_57', 'Neurolink Skin', isDefault: true),
    OutfitEntry('ch_p_eve_57_typeb', 'Sensate Skin'),
  ],
  'ch_p_eve_58': [
    OutfitEntry('ch_p_eve_58', 'War Aegis', isDefault: true),
  ],
  'ch_p_eve_59': [
    OutfitEntry('ch_p_eve_59', 'War Dress', isDefault: true),
    OutfitEntry('ch_p_eve_59_typeb', 'War Suit'),
  ],
  'ch_p_eve_60': [
    OutfitEntry('ch_p_eve_60', 'Midsummer Redhood', isDefault: true),
  ],
  'ch_p_eve_61': [
    OutfitEntry('ch_p_eve_61', 'Midsummer Alice', isDefault: true),
  ],
  'ch_p_eve_62': [
    OutfitEntry('ch_p_eve_62', 'Wave Oblique Monokini', isDefault: true),
  ],
  'ch_p_eve_63': [
    OutfitEntry('ch_p_eve_63', 'Wave Diver Bikini', isDefault: true),
  ],
  'ch_p_eve_christmas_01': [
    OutfitEntry('ch_p_eve_christmas_01', 'Santa Dress', isDefault: true),
  ],
  'ch_p_eve_dx': [
    OutfitEntry('ch_p_eve_dx', 'Photogenic', isDefault: true),
    OutfitEntry('ch_p_eve_dx_typeb', 'Telegenic'),
  ],
  'ch_p_eve_innersuit': [
    OutfitEntry('ch_p_eve_innersuit', 'Skin Suit', isDefault: true),
  ],
  'ch_p_eve_nier_01': [
    OutfitEntry('ch_p_eve_nier_01', 'YoRHa No.2 Type B Uniform', isDefault: true),
  ],
  'ch_p_eve_nier_02': [
    OutfitEntry('ch_p_eve_nier_02', 'YoRHa Uniform 1', isDefault: true),
  ],
  'ch_p_eve_nier_03': [
    OutfitEntry('ch_p_eve_nier_03', 'YoRHa Unofficial Ceremonial Attire', isDefault: true),
  ],
  'ch_p_eve_nier_04': [
    OutfitEntry('ch_p_eve_nier_04', 'YoRHa Type A No.2 Uniform', isDefault: true),
  ],
  'ch_p_eve_nikke_01': [
    OutfitEntry('ch_p_eve_nikke_01', 'Wandering Swordfighter Outfit', isDefault: true),
  ],
  'ch_p_eve_nikke_02': [
    OutfitEntry('ch_p_eve_nikke_02', 'Elegant Dress', isDefault: true),
  ],
  'ch_p_eve_nikke_03': [
    OutfitEntry('ch_p_eve_nikke_03', 'Elysion Combat Uniform', isDefault: true),
  ],
  'ch_p_eve_nikke_04': [
    OutfitEntry('ch_p_eve_nikke_04', 'Never Look Back', isDefault: true),
  ],
  'ch_p_eve_nikke_05': [
    OutfitEntry('ch_p_eve_nikke_05', 'Missing Link', isDefault: true),
  ],
  'ch_p_eve_nikke_06': [
    OutfitEntry('ch_p_eve_nikke_06', 'Cooling Suit', isDefault: true),
  ],
  'ch_p_eve_onemillion_01': [
    OutfitEntry('ch_p_eve_onemillion_01', 'Crimson Wings', isDefault: true),
  ],
  'ch_p_eve_royalguard_01': [
    OutfitEntry('ch_p_eve_royalguard_01', 'Royal Guard Suit', isDefault: true),
  ],
};