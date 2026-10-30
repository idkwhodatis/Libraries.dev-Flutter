enum OrbState {
  working,
  searching,
  solving,
  listening,
  connecting,
  weaving,
  composing,
  breathing,
  shaping,
}

enum OrbTheme { auto, dark, light }

typedef ModeOpts = Map<String, double>;

typedef Vec2 = ({double x, double y});
typedef Vec3 = ({double x, double y, double z});

class Dot {
  Dot({
    required this.x,
    required this.y,
    required this.z,
    required this.r,
    required this.white,
    this.a,
  });

  double x;
  double y;
  double z;
  double r;
  double white;
  double? a;
}

class Line {
  Line({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.white,
    required this.w,
    this.a,
  });

  double x1;
  double y1;
  double x2;
  double y2;
  double white;
  double w;
  double? a;
}

class OrbFrame {
  const OrbFrame(this.dots, this.lines);

  final List<Dot> dots;
  final List<Line> lines;
}

class OrbTint {
  const OrbTint(this.r, this.g, this.b);

  final int r;
  final int g;
  final int b;
}

class OrbInk {
  const OrbInk(this.r, this.g, this.b, this.a);

  final int r;
  final int g;
  final int b;
  final double a;
}
