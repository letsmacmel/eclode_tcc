class Filament {
  float angle;
  float lengthF;
  float thick;
  float curvAmt;
  float tipT;
  float baseT;
  float alpha;
  float z;
  int index;
  float t;

  Filament(float angle, float lengthF, float thick, float curvAmt, float tipT, float baseT, float alpha, float z, int index, float t) {
    this.angle = angle;
    this.lengthF = lengthF;
    this.thick = thick;
    this.curvAmt = curvAmt;
    this.tipT = tipT;
    this.baseT = baseT;
    this.alpha = alpha;
    this.z = z;
    this.index = index;
    this.t = t;
  }
}

class BassVeinLayer {
  float radius;
  float roughness;
  float thickness;
  float hue;
  float sat;
  float bri;
  float fillAlpha;
  float seedA;
  float seedB;

  BassVeinLayer(float radius, float roughness, float thickness, float hue, float sat, float bri, float fillAlpha, float seedA, float seedB) {
    this.radius = radius;
    this.roughness = roughness;
    this.thickness = thickness;
    this.hue = hue;
    this.sat = sat;
    this.bri = bri;
    this.fillAlpha = fillAlpha;
    this.seedA = seedA;
    this.seedB = seedB;
  }
}
