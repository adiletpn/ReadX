import '../core/utils/json.dart';

/// A badge an admin has granted to a user. Colours arrive as `#RRGGBB`
/// strings; the chip paints the text in `textColor` and the fill and border
/// from the same colour at 10 % and 30 % alpha.
class Badge {
  const Badge({
    required this.id,
    required this.name,
    required this.textColor,
    required this.bgColor,
  });

  final int id;
  final String name;

  /// `#RRGGBB` как их отдаёт сервер — разбор в цвет делает виджет чипа.
  final String textColor;
  final String bgColor;

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
        id: asInt(json['id']),
        name: asString(json['name']),
        textColor: asString(json['text_color'], fallback: '#FFFFFF'),
        bgColor: asString(json['bg_color'], fallback: '#0077FF'),
      );
}
