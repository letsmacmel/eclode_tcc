class ImageMask {
  PImage texture;
  boolean[] active;
  boolean[] contour;
  int width = 0;
  int height = 0;
  int cropX = 0;
  int cropY = 0;

  ImageMask(PImage src) {
    build(src);
  }

  boolean build(PImage src) {
    if (src == null || src.width <= 0 || src.height <= 0) return false;
    src.loadPixels();

    boolean transparent = hasUsefulAlpha(src);
    float bgR = 255;
    float bgG = 255;
    float bgB = 255;
    if (!transparent) {
      int[] corners = {
        src.pixels[0],
        src.pixels[max(0, src.width - 1)],
        src.pixels[max(0, src.height - 1) * src.width],
        src.pixels[max(0, src.height - 1) * src.width + max(0, src.width - 1)]
      };
      bgR = 0;
      bgG = 0;
      bgB = 0;
      for (int i = 0; i < corners.length; i++) {
        bgR += (corners[i] >> 16) & 0xFF;
        bgG += (corners[i] >> 8) & 0xFF;
        bgB += corners[i] & 0xFF;
      }
      bgR /= corners.length;
      bgG /= corners.length;
      bgB /= corners.length;
    }

    boolean[] raw = new boolean[src.width * src.height];
    int minX = src.width;
    int minY = src.height;
    int maxX = -1;
    int maxY = -1;
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        boolean on = sourcePixelVisible(src, x, y, transparent, bgR, bgG, bgB);
        raw[y * src.width + x] = on;
        if (on) {
          minX = min(minX, x);
          minY = min(minY, y);
          maxX = max(maxX, x);
          maxY = max(maxY, y);
        }
      }
    }

    if (maxX < minX || maxY < minY) return false;
    int pad = max(6, round(max(src.width, src.height) * 0.018));
    minX = max(0, minX - pad);
    minY = max(0, minY - pad);
    maxX = min(src.width - 1, maxX + pad);
    maxY = min(src.height - 1, maxY + pad);

    cropX = minX;
    cropY = minY;
    width = max(1, maxX - minX + 1);
    height = max(1, maxY - minY + 1);
    texture = createImage(width, height, ARGB);
    active = new boolean[width * height];
    contour = new boolean[width * height];

    texture.loadPixels();
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int sx = x + cropX;
        int sy = y + cropY;
        boolean on = raw[sy * src.width + sx] && hasActiveNeighbors(raw, src.width, src.height, sx, sy, 2);
        active[y * width + x] = on;
        int c = src.pixels[sy * src.width + sx];
        int a = transparent ? ((c >>> 24) & 0xFF) : (on ? 255 : 0);
        if (!on) a = 0;
        texture.pixels[y * width + x] = (a << 24) | (c & 0x00FFFFFF);
      }
    }
    texture.updatePixels();
    buildContour();
    softenTextureAlpha();
    return true;
  }

  boolean hasUsefulAlpha(PImage img) {
    int step = max(1, floor(sqrt((img.width * img.height) / 900.0)));
    for (int y = 0; y < img.height; y += step) {
      for (int x = 0; x < img.width; x += step) {
        int a = (img.pixels[y * img.width + x] >>> 24) & 0xFF;
        if (a < 245) return true;
      }
    }
    return false;
  }

  boolean sourcePixelVisible(PImage img, int x, int y, boolean transparent, float bgR, float bgG, float bgB) {
    int c = img.pixels[y * img.width + x];
    int a = (c >>> 24) & 0xFF;
    if (a <= 20) return false;
    if (transparent) return a > 28;

    float r = (c >> 16) & 0xFF;
    float g = (c >> 8) & 0xFF;
    float b = c & 0xFF;
    float diff = dist(r, g, b, bgR, bgG, bgB);
    float bgLum = (bgR + bgG + bgB) / 3.0;
    float lum = (r + g + b) / 3.0;
    if (bgLum > 222 && lum > 238 && diff < 42) return false;
    return diff > 30;
  }

  boolean hasActiveNeighbors(boolean[] raw, int rw, int rh, int x, int y, int minNeighbors) {
    int count = 0;
    for (int yy = -1; yy <= 1; yy++) {
      for (int xx = -1; xx <= 1; xx++) {
        int nx = x + xx;
        int ny = y + yy;
        if (nx < 0 || ny < 0 || nx >= rw || ny >= rh) continue;
        if (raw[ny * rw + nx]) count++;
      }
    }
    return count >= minNeighbors;
  }

  void buildContour() {
    if (active == null || contour == null) return;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (!isActive(x, y)) {
          contour[y * width + x] = false;
          continue;
        }
        contour[y * width + x] = !isActive(x - 1, y) || !isActive(x + 1, y) || !isActive(x, y - 1) || !isActive(x, y + 1);
      }
    }
  }

  void softenTextureAlpha() {
    if (texture == null || active == null) return;
    texture.loadPixels();
    int[] smoothed = new int[texture.pixels.length];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int idx = y * width + x;
        int c = texture.pixels[idx];
        int a = (c >>> 24) & 0xFF;
        if (a == 0 && !nearActive(x, y, 1.5)) {
          smoothed[idx] = 0;
          continue;
        }
        int sum = 0;
        int count = 0;
        for (int yy = -1; yy <= 1; yy++) {
          for (int xx = -1; xx <= 1; xx++) {
            int nx = x + xx;
            int ny = y + yy;
            if (nx < 0 || ny < 0 || nx >= width || ny >= height) continue;
            sum += (texture.pixels[ny * width + nx] >>> 24) & 0xFF;
            count++;
          }
        }
        int aa = isContour(x, y) ? round(lerp(a, sum / float(max(1, count)), 0.42)) : a;
        smoothed[idx] = (constrain(aa, 0, 255) << 24) | (c & 0x00FFFFFF);
      }
    }
    arrayCopy(smoothed, texture.pixels);
    texture.updatePixels();
  }

  boolean isActive(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height || active == null) return false;
    return active[y * width + x];
  }

  boolean isContour(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height || contour == null) return false;
    return contour[y * width + x];
  }

  boolean sampleActive(float u, float v) {
    return isActive(round(u), round(v));
  }

  boolean sampleContour(float u, float v) {
    return isContour(round(u), round(v));
  }

  boolean nearActive(float u, float v, float radius) {
    int r = max(1, round(radius));
    for (int y = round(v) - r; y <= round(v) + r; y++) {
      for (int x = round(u) - r; x <= round(u) + r; x++) {
        if (isActive(x, y)) return true;
      }
    }
    return false;
  }
}

class MeshNode {
  PVector original;
  PVector position;
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  float u;
  float v;
  boolean boundary;

  MeshNode(float x, float y, float u, float v, boolean boundary) {
    original = new PVector(x, y);
    position = new PVector(x, y);
    this.u = u;
    this.v = v;
    this.boundary = boundary;
  }

  void reset() {
    position.set(original);
    velocity.set(0, 0);
    acceleration.set(0, 0);
  }
}

class MeshSpring {
  int a;
  int b;
  float restLength;
  float stiffness;

  MeshSpring(int a, int b, float restLength, float stiffness) {
    this.a = a;
    this.b = b;
    this.restLength = restLength;
    this.stiffness = stiffness;
  }
}

class MeshTriangle {
  int a;
  int b;
  int c;

  MeshTriangle(int a, int b, int c) {
    this.a = a;
    this.b = b;
    this.c = c;
  }
}

class MeshLogo {
  ImageMask mask;
  PImage texture;
  ArrayList<MeshNode> nodes = new ArrayList<MeshNode>();
  ArrayList<MeshSpring> springs = new ArrayList<MeshSpring>();
  ArrayList<MeshTriangle> triangles = new ArrayList<MeshTriangle>();
  int cols = 0;
  int rows = 0;
  int[] nodeIndex;
  float cell = 1;
  float smoothBass = 0;
  float smoothMid = 0;
  float smoothTreble = 0;
  float smoothEnergy = 0;

  MeshLogo(PImage img) {
    rebuild(img);
  }

  boolean rebuild(PImage img) {
    mask = new ImageMask(img);
    if (mask == null || mask.texture == null || mask.width <= 0 || mask.height <= 0) return false;
    texture = mask.texture;
    nodes.clear();
    springs.clear();
    triangles.clear();

    int longCells = constrain(round(max(mask.width, mask.height) / 5.2), 110, 360);
    if (mask.width >= mask.height) {
      cols = longCells;
      rows = constrain(round(longCells * mask.height / float(mask.width)), 12, 170);
    } else {
      rows = longCells;
      cols = constrain(round(longCells * mask.width / float(mask.height)), 12, 170);
    }
    cell = max(mask.width / float(max(1, cols)), mask.height / float(max(1, rows)));
    nodeIndex = new int[(cols + 1) * (rows + 1)];
    for (int i = 0; i < nodeIndex.length; i++) nodeIndex[i] = -1;

    for (int gy = 0; gy <= rows; gy++) {
      for (int gx = 0; gx <= cols; gx++) {
        float u = map(gx, 0, cols, 0, mask.width - 1);
        float v = map(gy, 0, rows, 0, mask.height - 1);
        if (!mask.sampleActive(u, v) && !nearActive(u, v, cell * 0.85)) continue;
        boolean boundary = mask.sampleContour(u, v) || nearContour(u, v, cell * 0.90);
        float x = u - mask.width * 0.5;
        float y = v - mask.height * 0.5;
        nodeIndex[gridIndex(gx, gy)] = nodes.size();
        nodes.add(new MeshNode(x, y, u, v, boundary));
      }
    }

    for (int gy = 0; gy <= rows; gy++) {
      for (int gx = 0; gx <= cols; gx++) {
        int n = nodeAt(gx, gy);
        if (n < 0) continue;
        addSpringIfPossible(n, nodeAt(gx + 1, gy), 0.90);
        addSpringIfPossible(n, nodeAt(gx, gy + 1), 0.90);
        addSpringIfPossible(n, nodeAt(gx + 1, gy + 1), 0.52);
        addSpringIfPossible(n, nodeAt(gx - 1, gy + 1), 0.52);
      }
    }

    for (int gy = 0; gy < rows; gy++) {
      for (int gx = 0; gx < cols; gx++) {
        int a = nodeAt(gx, gy);
        int b = nodeAt(gx + 1, gy);
        int c = nodeAt(gx + 1, gy + 1);
        int d = nodeAt(gx, gy + 1);
        float cu = map(gx + 0.5, 0, cols, 0, mask.width - 1);
        float cv = map(gy + 0.5, 0, rows, 0, mask.height - 1);
        if (!cellHasVisibleShape(cu, cv, cell * 0.72)) continue;
        if (a >= 0 && b >= 0 && c >= 0) triangles.add(new MeshTriangle(a, b, c));
        if (a >= 0 && c >= 0 && d >= 0) triangles.add(new MeshTriangle(a, c, d));
      }
    }
    return nodes.size() > 3 && triangles.size() > 0;
  }

  int gridIndex(int gx, int gy) {
    return gy * (cols + 1) + gx;
  }

  int nodeAt(int gx, int gy) {
    if (gx < 0 || gy < 0 || gx > cols || gy > rows || nodeIndex == null) return -1;
    return nodeIndex[gridIndex(gx, gy)];
  }

  void addSpringIfPossible(int a, int b, float stiffness) {
    if (a < 0 || b < 0 || a == b) return;
    MeshNode na = nodes.get(a);
    MeshNode nb = nodes.get(b);
    float rest = PVector.dist(na.original, nb.original);
    if (rest > cell * 1.62) return;
    float midU = (na.u + nb.u) * 0.5;
    float midV = (na.v + nb.v) * 0.5;
    if (!mask.sampleActive(midU, midV) && !mask.nearActive(midU, midV, cell * 0.22)) return;
    springs.add(new MeshSpring(a, b, rest, stiffness));
  }

  boolean nearActive(float u, float v, float radius) {
    int r = max(1, round(radius));
    for (int y = round(v) - r; y <= round(v) + r; y += max(1, r / 2)) {
      for (int x = round(u) - r; x <= round(u) + r; x += max(1, r / 2)) {
        if (mask.isActive(x, y)) return true;
      }
    }
    return false;
  }

  boolean nearContour(float u, float v, float radius) {
    int r = max(1, round(radius));
    for (int y = round(v) - r; y <= round(v) + r; y += max(1, r / 2)) {
      for (int x = round(u) - r; x <= round(u) + r; x += max(1, r / 2)) {
        if (mask.isContour(x, y)) return true;
      }
    }
    return false;
  }

  boolean cellHasVisibleShape(float u, float v, float radius) {
    int r = max(1, round(radius));
    int step = max(1, r / 3);
    for (int y = round(v) - r; y <= round(v) + r; y += step) {
      for (int x = round(u) - r; x <= round(u) + r; x += step) {
        if (mask.isActive(x, y)) return true;
      }
    }
    return false;
  }

  void reset() {
    for (int i = 0; i < nodes.size(); i++) nodes.get(i).reset();
  }

  void update(AudioData audio, MutationParams params) {
    if (nodes.size() == 0 || params == null) return;
    float bass = audio != null ? constrain(audio.bass * params.bassInfluence, 0, 1.8) : 0;
    float mid = audio != null ? constrain(audio.mid * params.midInfluence, 0, 1.8) : 0;
    float treble = audio != null ? constrain(audio.treble * params.trebleInfluence, 0, 1.8) : 0;
    float energy = audio != null ? constrain(audio.energy + audio.volume * 0.30, 0, 1.6) : 0;
    smoothBass = lerp(smoothBass, bass, 0.10);
    smoothMid = lerp(smoothMid, mid, 0.12);
    smoothTreble = lerp(smoothTreble, treble, 0.18);
    smoothEnergy = lerp(smoothEnergy, energy, 0.10);

    float span = max(mask.width, mask.height);
    float unit = span / 500.0;
    float t = noiseDynamicTime * (0.16 + params.transformSpeed * 0.04);
    float returnK = 0.085 + params.returnSpeed * 0.95;
    float damping = constrain(0.80 - smoothEnergy * 0.018, 0.74, 0.84);
    float springK = 0.070 + params.solidness * 0.095;
    float forceScale = params.deformationAmount * unit * constrain(params.intensity, 0, 2.0);
    float maxOffset = span * constrain(0.014 + params.displacementAmount * 0.00032 + smoothBass * 0.008, 0.012, 0.060);
    boolean modoOriginal = params.mode == 0;
    boolean modoExpande = params.mode == 12;
    boolean modoEncolhe = params.mode == 13;
    boolean modoMalha = params.mode == 14;
    if (modoOriginal) {
      forceScale = 0;
      maxOffset = span * 0.004;
    } else if (modoExpande) {
      maxOffset = span * constrain(0.026 + smoothBass * 0.018 + smoothEnergy * 0.010, 0.020, 0.082);
    } else if (modoEncolhe) {
      maxOffset = span * constrain(0.020 + smoothBass * 0.014 + smoothEnergy * 0.008, 0.016, 0.065);
    } else if (modoMalha) {
      maxOffset = span * constrain(0.012 + params.displacementAmount * 0.00018 + smoothMid * 0.006, 0.010, 0.040);
    }

    for (int i = 0; i < nodes.size(); i++) {
      MeshNode n = nodes.get(i);
      n.acceleration.set(0, 0);
      PVector home = PVector.sub(n.original, n.position);
      float symbolMix = symbolInfluence(n);
      float textMix = 1.0 - symbolMix;
      float returnWeight = lerp(2.45, 1.12, symbolMix) * (n.boundary ? lerp(1.86, 1.18, symbolMix) : 1.0);
      n.acceleration.add(PVector.mult(home, returnK * returnWeight));

      PVector radial = n.original.copy();
      if (radial.mag() < 0.001) radial.set(1, 0);
      radial.normalize();
      float forceWeight = lerp(0.34, 1.10, symbolMix);
      float boundaryBoost = n.boundary ? lerp(0.58, 1.12, symbolMix) : lerp(0.42, 0.82, symbolMix);
      float flowA = noise(n.u * 0.0038 + 11.0, n.v * 0.0038 + 37.0, t);
      float flowB = noise(n.u * 0.0090 + 71.0, n.v * 0.0090 + 5.0, t * 0.64);
      float angle = flowA * TWO_PI * (0.72 + params.noiseAmount * 0.30);
      float wave = sin(t * 3.2 + n.u * 0.011 - n.v * 0.008 + flowB * TWO_PI);
      float localGate = 0.55 + 0.45 * noise(n.u * 0.0025 + 91.0, n.v * 0.0025 + 17.0, t * 0.32);
      float bassPush = smoothBass * forceScale * 0.0045 * lerp(0.18, 1.0, symbolMix);
      float midWave = smoothMid * forceScale * 0.0130 * wave * forceWeight * localGate;
      float trebleShake = smoothTreble * params.visualNoiseAmount * unit * (n.boundary ? lerp(0.42, 1.10, symbolMix) : 0.30) * sin(t * 24.0 + i * 0.29);

      if (modoOriginal) {
        bassPush = 0;
        midWave = 0;
        trebleShake = 0;
      } else if (modoExpande) {
        float textGrow = n.boundary ? 1.85 : 0.48;
        float textBoost = lerp(1.42, 1.0, symbolMix);
        bassPush = smoothBass * forceScale * 0.026 * textBoost * textGrow;
        midWave = smoothMid * forceScale * 0.0038 * wave * lerp(0.20, 0.55, symbolMix);
        trebleShake *= 0.35;
      } else if (modoEncolhe) {
        float textShrink = n.boundary ? 1.42 : 0.42;
        float textBoost = lerp(1.28, 0.92, symbolMix);
        bassPush = -smoothBass * forceScale * 0.020 * textBoost * textShrink;
        midWave = smoothMid * forceScale * 0.0028 * wave * lerp(0.16, 0.42, symbolMix);
        trebleShake *= 0.18;
      } else if (modoMalha) {
        bassPush *= 0.18;
        midWave *= lerp(0.28, 0.76, symbolMix);
        trebleShake *= lerp(0.12, 0.48, symbolMix);
      }

      n.acceleration.x += radial.x * bassPush + cos(angle) * midWave + trebleShake * 0.18 * boundaryBoost;
      n.acceleration.y += radial.y * bassPush + sin(angle) * midWave + trebleShake * 0.13 * boundaryBoost;
    }

    for (int i = 0; i < springs.size(); i++) {
      MeshSpring s = springs.get(i);
      MeshNode a = nodes.get(s.a);
      MeshNode b = nodes.get(s.b);
      PVector delta = PVector.sub(b.position, a.position);
      float len = max(0.001, delta.mag());
      float stretch = len - s.restLength;
      delta.normalize();
      PVector f = PVector.mult(delta, stretch * springK * s.stiffness);
      a.acceleration.add(f);
      b.acceleration.sub(f);
    }

    for (int i = 0; i < nodes.size(); i++) {
      MeshNode n = nodes.get(i);
      n.velocity.add(n.acceleration);
      n.velocity.mult(damping);
      n.position.add(n.velocity);
      PVector offset = PVector.sub(n.position, n.original);
      float mag = offset.mag();
      float symbolMix = symbolInfluence(n);
      float nodeMaxOffset = maxOffset * lerp(0.42, 1.0, symbolMix) * (n.boundary ? lerp(0.74, 1.0, symbolMix) : 1.0);
      if (mag > nodeMaxOffset) {
        offset.normalize();
        offset.mult(nodeMaxOffset);
        n.position.set(PVector.add(n.original, offset));
        n.velocity.mult(0.24);
      }
    }
  }

  float symbolInfluence(MeshNode n) {
    if (mask == null || mask.width <= 1) return 0.5;
    float split = mask.width * 0.37;
    float fade = mask.width * 0.08;
    return constrain(1.0 - smoothstepMesh(split - fade, split + fade, n.u), 0, 1);
  }

  float smoothstepMesh(float edge0, float edge1, float x) {
    float tt = constrain((x - edge0) / max(0.0001, edge1 - edge0), 0, 1);
    return tt * tt * (3.0 - 2.0 * tt);
  }

  boolean render(PGraphics pg, MutationParams params, float alphaPct) {
    if (texture == null || triangles.size() == 0) return false;
    pg.pushStyle();
    pg.colorMode(RGB, 255, 255, 255, 255);
    pg.noStroke();
    pg.textureMode(IMAGE);
    int c = corMarcaRenderAjustada(params, false, alphaPct);
    pg.tint(canalR(c), canalG(c), canalB(c), canalA(c));
    pg.beginShape(TRIANGLES);
    pg.texture(texture);
    for (int i = 0; i < triangles.size(); i++) {
      MeshTriangle tri = triangles.get(i);
      textureVertex(pg, nodes.get(tri.a));
      textureVertex(pg, nodes.get(tri.b));
      textureVertex(pg, nodes.get(tri.c));
    }
    pg.endShape();
    pg.noTint();
    pg.popStyle();
    return true;
  }

  void textureVertex(PGraphics pg, MeshNode n) {
    pg.vertex(n.position.x, n.position.y, n.u, n.v);
  }
}
