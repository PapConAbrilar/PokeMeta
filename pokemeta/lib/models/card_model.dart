class CardModel {
  const CardModel({
    required this.name,
    required this.expansion,
    required this.rarity,
    required this.cardNumber,
    required this.hp,
    required this.type,
    required this.ability,
    required this.attack,
    required this.attackDamage,
    required this.attackDescription,
    required this.retreatCost,
    required this.weakness,
    required this.resistance,
    required this.regulationMark,
    this.imageUrl,
    this.copiesInActiveDeck = 2,
  });

  final String name;
  final String expansion;
  final String rarity;
  final String cardNumber;
  final int hp;
  final String type;
  final String ability;
  final String attack;
  final String attackDamage;
  final String attackDescription;
  final int retreatCost;
  final String weakness;
  final String resistance;
  final String regulationMark;
  final String? imageUrl;
  final int copiesInActiveDeck;

  factory CardModel.fromJson(Map<String, dynamic> json) {
    final attacksList = json['attacks'] as List<dynamic>?;
    final firstAttack = attacksList != null && attacksList.isNotEmpty
        ? attacksList.first as Map<String, dynamic>
        : null;

    final abilitiesList = json['abilities'] as List<dynamic>?;
    final firstAbility = abilitiesList != null && abilitiesList.isNotEmpty
        ? abilitiesList.first as Map<String, dynamic>
        : null;

    final weaknessesList = json['weaknesses'] as List<dynamic>?;
    final firstWeakness = weaknessesList != null && weaknessesList.isNotEmpty
        ? weaknessesList.first as Map<String, dynamic>
        : null;

    final resistancesList = json['resistances'] as List<dynamic>?;
    final firstResistance = resistancesList != null && resistancesList.isNotEmpty
        ? resistancesList.first as Map<String, dynamic>
        : null;

    final typesList = json['types'] as List<dynamic>?;
    final primaryType = typesList != null && typesList.isNotEmpty
        ? typesList.first.toString()
        : (json['type']?.toString() ?? 'Incolora');

    String? imgUrl;
    if (json['imageUrl'] != null) {
      imgUrl = json['imageUrl'].toString();
    } else if (json['image'] != null) {
      final raw = json['image'].toString();
      imgUrl = raw.endsWith('.webp') || raw.endsWith('.png') || raw.endsWith('.jpg')
          ? raw
          : '$raw/high.webp';
    }

    final localId = json['localId']?.toString() ?? json['id']?.toString() ?? '001';
    final setName = json['set'] is Map
        ? (json['set']['name']?.toString() ?? 'Desconocida')
        : (json['expansion']?.toString() ?? 'Desconocida');

    final hpVal = json['hp'];
    final parsedHp = hpVal is int
        ? hpVal
        : (int.tryParse(hpVal?.toString() ?? '') ?? 0);

    final retreatVal = json['retreat'];
    final parsedRetreat = retreatVal is int
        ? retreatVal
        : (int.tryParse(retreatVal?.toString() ?? '') ?? 0);

    return CardModel(
      name: json['name']?.toString() ?? 'Sin nombre',
      expansion: setName,
      rarity: json['rarity']?.toString() ?? 'Común',
      cardNumber: json['cardNumber']?.toString() ?? '${json['id'] ?? localId}',
      hp: parsedHp,
      type: primaryType,
      ability: firstAbility?['name']?.toString() ?? json['ability']?.toString() ?? 'Ninguna',
      attack: firstAttack?['name']?.toString() ?? json['attack']?.toString() ?? 'Ninguno',
      attackDamage: firstAttack?['damage']?.toString() ?? json['attackDamage']?.toString() ?? '—',
      attackDescription: firstAttack?['effect']?.toString() ?? json['attackDescription']?.toString() ?? '',
      retreatCost: parsedRetreat,
      weakness: firstWeakness != null
          ? '${firstWeakness['type']} ${firstWeakness['value'] ?? ''}'.trim()
          : (json['weakness']?.toString() ?? '—'),
      resistance: firstResistance != null
          ? '${firstResistance['type']} ${firstResistance['value'] ?? ''}'.trim()
          : (json['resistance']?.toString() ?? '—'),
      regulationMark: json['regulationMark']?.toString() ?? 'G',
      imageUrl: imgUrl,
    );
  }
}

const sampleCards = [
  CardModel(
    name: 'Charizard ex',
    expansion: 'Paldean Fates',
    rarity: 'Special Rare',
    cardNumber: 'SVP - 056/091',
    hp: 330,
    type: 'Fuego',
    ability: 'Infernal Reign',
    attack: 'Burning Darkness',
    attackDamage: '180+',
    attackDescription:
        'Este ataque hace 30 puntos de daño más por cada carta de Premio '
        'que haya tomado tu rival.',
    retreatCost: 3,
    weakness: 'Fuego ×2',
    resistance: '—',
    regulationMark: 'F',
    imageUrl: 'https://assets.tcgdex.net/es/sv/sv04.5/054/high.webp',
  ),
  CardModel(
    name: 'Greninja ex',
    expansion: 'Twilight Masquerade',
    rarity: 'Special Illustration Rare',
    cardNumber: 'TWM - 214/167',
    hp: 300,
    type: 'Agua',
    ability: 'Torrential Veil',
    attack: 'Mirage Barrage',
    attackDamage: '120',
    attackDescription: 'Inflige daño a dos Pokémon del rival.',
    retreatCost: 1,
    weakness: 'Rayo ×2',
    resistance: '—',
    regulationMark: 'H',
    imageUrl: 'https://assets.tcgdex.net/es/sv/sv06/106/high.webp',
  ),
  CardModel(
    name: 'Mew ex',
    expansion: 'Paldean Fates',
    rarity: 'Special Illustration Rare',
    cardNumber: 'PAF - 232/091',
    hp: 180,
    type: 'Psíquico',
    ability: 'Restart',
    attack: 'Genome Hacking',
    attackDamage: '—',
    attackDescription: 'Usa uno de los ataques del Pokémon Activo rival.',
    retreatCost: 1,
    weakness: 'Oscuridad ×2',
    resistance: 'Lucha −30',
    regulationMark: 'G',
    imageUrl: 'https://assets.tcgdex.net/es/sv/sv04.5/232/high.webp',
  ),
  CardModel(
    name: 'Frigibax',
    expansion: 'Paldea Evolved',
    rarity: 'Illustration Rare',
    cardNumber: 'PAL - 208/193',
    hp: 60,
    type: 'Agua',
    ability: 'Ninguna',
    attack: 'Placaje',
    attackDamage: '30',
    attackDescription: 'Un ataque sencillo de un Pokémon básico.',
    retreatCost: 1,
    weakness: 'Metal ×2',
    resistance: '—',
    regulationMark: 'G',
    imageUrl: 'https://assets.tcgdex.net/es/sv/sv02/057/high.webp',
  ),
];
