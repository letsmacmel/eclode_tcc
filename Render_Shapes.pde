void renderShapeLayer(PGraphics pg, float seedValue, float floatTime, float breathTime) {
  pg.beginDraw();
  pg.clear();
  pg.colorMode(HSB, 360, 100, 100, 100);

  float scaleBase = min(pg.width / baseWidth, pg.height / baseHeight);
  float localFlutuaX = map(noise(floatTime, 50), 0, 1, -32, 32);
  float localFlutuaY = map(noise(50, floatTime), 0, 1, -22, 22);

  if (appPage == 2) {
    desenharPanfleto(pg);
  } else if (appPage == 3) {
    desenharEstampaArtistica(pg, seedValue, breathTime, scaleBase);
  } else if (brandSystemEnabled && activeBrand != null) {
    activeBrand.render(pg, mutationParams, audioData, gestureData, seedValue, scaleBase);
  } else {
    desenharPlaceholderMarca(pg);
  }

  pg.endDraw();
}

void desenharEstampaArtistica(PGraphics pg, float seedValue, float breathTime, float scaleBase) {
  pg.pushStyle();
  pg.colorMode(RGB, 255, 255, 255, 255);
  pg.background(12, 12, 14);

  float safeLeft = mostrarBarra ? max(0, menuOffsetX + menuWidth) : 0;
  float safeRight = mostrarBarraPadroes ? min(pg.width, pg.width - painelPadraoWidth + painelPadraoOffsetX) : pg.width;
  float safeTop = uiHeaderHeight + uiTabsHeight + 18;
  float safeBottom = pg.height - 24;
  if (safeRight - safeLeft < pg.width * 0.38) {
    safeLeft = pg.width * 0.18;
    safeRight = pg.width * 0.82;
  }

  float areaW = max(180, safeRight - safeLeft);
  float areaH = max(180, safeBottom - safeTop);
  float x = safeLeft + areaW * 0.05;
  float y = safeTop + areaH * 0.05;
  float w = areaW * 0.90;
  float h = areaH * 0.90;
  if (estampaPreviewAtivo == 1) {
    float side = min(w, h) * 0.86;
    x = safeLeft + (areaW - side) * 0.5;
    y = safeTop + (areaH - side) * 0.5;
    w = side;
    h = side;
  } else if (estampaPreviewAtivo == 2) {
    float targetH = areaH * 0.92;
    float targetW = min(areaW * 0.72, targetH * 0.72);
    x = safeLeft + (areaW - targetW) * 0.5;
    y = safeTop + (areaH - targetH) * 0.5;
    w = targetW;
    h = targetH;
  } else if (estampaPreviewAtivo == 3) {
    float targetW = areaW * 0.94;
    float targetH = min(areaH * 0.62, targetW * 0.46);
    x = safeLeft + (areaW - targetW) * 0.5;
    y = safeTop + (areaH - targetH) * 0.5;
    w = targetW;
    h = targetH;
  }
  estampaRenderX = x;
  estampaRenderY = y;
  estampaRenderW = w;
  estampaRenderH = h;
  float cx = x + w * 0.5 + padraoRefX * scaleBase;
  float cy = y + h * 0.5 + padraoRefY * scaleBase;

  float energy = audioData != null ? constrain(audioData.energy + audioData.volume * 0.42, 0, 1.45) : 0;
  float bass = audioData != null ? constrain(audioData.bass * 1.35, 0, 1.6) : 0;
  float mid = audioData != null ? constrain(audioData.mid * 1.30, 0, 1.6) : 0;
  float treble = audioData != null ? constrain(audioData.treble * 1.30, 0, 1.7) : 0;
  float t = noiseDynamicTime * (0.36 + treble * 0.30) + seedValue * 0.17;

  int fundoEstampa = estampaUsarCoresMarca ? color(238, 235, 228) : estampaCorFundo;
  pg.noStroke();
  pg.fill(red(fundoEstampa), green(fundoEstampa), blue(fundoEstampa), alpha(fundoEstampa));
  pg.rect(x, y, w, h);

  MutableBrand brand = activeBrand;
  boolean temMarca = brand != null && brand.originalPoints != null && brand.originalPoints.size() > 2;
  PImage texture = estampaFoto != null ? estampaFoto : (temMarca ? brand.sourceImage : null);
  if (texture != null) texture.loadPixels();

  if (!temMarca && texture == null) {
    pg.fill(82);
    pg.textAlign(CENTER, CENTER);
    pg.textSize(constrain(pg.height * 0.023, 14, 22));
    pg.text("Carregue uma marca para gerar estampa", x + w * 0.5, y + h * 0.5);
    pg.popStyle();
    return;
  }

  pg.clip(round(x), round(y), round(w), round(h));

  int modo = constrain(formaPadraoAtiva, 0, estampaModoLabels.length - 1);
  int density = constrain(round(padraoQtdFormas), 3, 28);
  float tileBase = max(10, min(w, h) * constrain(padraoEscala, 0.10, 1.05) * 0.20);
  float diagonal = padraoDiagonal * scaleBase;
  float brandW = temMarca ? max(1, brand.maxX - brand.minX) : (texture != null ? texture.width : 100);
  float brandH = temMarca ? max(1, brand.maxY - brand.minY) : (texture != null ? texture.height : 100);
  float brandFit = min(w / brandW, h / brandH) * 0.78;
  float densityStep = max(1, temMarca ? brand.originalPoints.size() / max(80, density * 58) : 1);
  int corA = mutationParams != null ? mutationParams.primaryColor : color(20, 170, 142);
  int corB = mutationParams != null ? mutationParams.secondaryColor : color(244, 72, 92);
  if (!estampaUsarCoresMarca) {
    corA = estampaCorA;
    corB = estampaCorB;
  }
  float alphaA = constrain(alpha(corA) / 255.0, 0, 1);
  float alphaB = constrain(alpha(corB) / 255.0, 0, 1);
  float fundoR = red(fundoEstampa);
  float fundoG = green(fundoEstampa);
  float fundoB = blue(fundoEstampa);
  float ar = lerp(fundoR, red(corA), alphaA);
  float ag = lerp(fundoG, green(corA), alphaA);
  float ab = lerp(fundoB, blue(corA), alphaA);
  float br = lerp(fundoR, red(corB), alphaB);
  float bg = lerp(fundoG, green(corB), alphaB);
  float bb = lerp(fundoB, blue(corB), alphaB);
  if (ar + ag + ab < 18) {
    ar = 20; ag = 170; ab = 142;
  }
  if (br + bg + bb < 18) {
    br = 244; bg = 72; bb = 92;
  }

  desenharSistemaEstampaOrganica(pg, x, y, w, h, modo, density, scaleBase, seedValue, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca);

  pg.noClip();
  pg.noFill();
  pg.stroke(20, 20, 22, 72);
  pg.strokeWeight(1.1);
  pg.rect(x, y, w, h);
  pg.popStyle();
  if (modo >= 0) return;

  if (modo == 0) {
    int cols = constrain(round(w / max(54, padraoEspacoX * scaleBase * 0.55)) + density / 3, 3, 13);
    int rows = constrain(round(h / max(48, padraoEspacoY * scaleBase * 0.55)) + density / 3, 3, 13);
    float cellW = w / cols;
    float cellH = h / rows;
    for (int gy = 0; gy < rows; gy++) {
      for (int gx = 0; gx < cols; gx++) {
        float n = noise(gx * 0.33 + seedValue, gy * 0.33 + 9.0, t);
        float px = x + gx * cellW + cellW * 0.5 + (gy - rows * 0.5) * diagonal * 0.028 + (n - 0.5) * mid * 24 * scaleBase;
        float py = y + gy * cellH + cellH * 0.5 + sin(t * 3.0 + gx) * treble * 10 * scaleBase;
        float stampScale = min(cellW / brandW, cellH / brandH) * (0.72 + padraoEscala * 0.45 + bass * 0.10);
        pg.pushMatrix();
        pg.translate(px, py);
        pg.rotate((n - 0.5) * 0.22 + diagonal * 0.0004 + treble * 0.035);
        if (texture != null) {
          pg.imageMode(CENTER);
          pg.tint(255, 150 + energy * 55);
          pg.image(texture, 0, 0, brandW * stampScale, brandH * stampScale);
          pg.noTint();
        } else {
          desenharEstampaPontosMarca(pg, brand, 0, brand.originalPoints.size(), densityStep, stampScale, ar, ag, ab, br, bg, bb, 74 + energy * 50, t, bass, mid, treble);
        }
        pg.popMatrix();
      }
    }
  } else if (modo == 1) {
    pg.noStroke();
    if (temMarca) {
      int count = brand.originalPoints.size();
      int step = max(1, round(densityStep * 0.72));
      for (int i = 0; i < count; i += step) {
        PVector p = brand.originalPoints.get(i);
        float u = (p.x - brand.minX) / brandW;
        float v = (p.y - brand.minY) / brandH;
        float n = noise(u * 7.5, v * 7.5, t);
        float px = cx + (u - 0.5) * w * 0.86 + (v - 0.5) * diagonal * 0.18 + (n - 0.5) * mid * 20 * scaleBase;
        float py = cy + (v - 0.5) * h * 0.86 + sin(t * 5.0 + i * 0.04) * treble * 8 * scaleBase;
        float d = max(1.2, tileBase * 0.16 * (0.7 + bass * 1.4 + n * 0.7));
        if ((i / step) % 2 == 0) pg.fill(ar, ag, ab, 125 + energy * 72);
        else pg.fill(br, bg, bb, 100 + energy * 65);
        pg.ellipse(px, py, d, d);
      }
    } else if (texture != null) {
      desenharEstampaDeTexturaFallback(pg, texture, x, y, w, h, density, scaleBase, energy, bass, mid, treble, t, 1);
    }
  } else if (modo == 2) {
    if (temMarca) {
      int linhas = constrain(density * 2 + round(energy * 12), 10, 58);
      int count = brand.originalPoints.size();
      int step = max(1, round(densityStep));
      for (int j = 0; j < linhas; j++) {
        float offsetY = map(j, 0, max(1, linhas - 1), -h * 0.48, h * 0.48);
        pg.noFill();
        pg.beginShape();
        for (int i = j % step; i < count; i += step * max(1, linhas / 12)) {
          PVector p = brand.originalPoints.get(i);
          float u = (p.x - brand.minX) / brandW;
          float v = (p.y - brand.minY) / brandH;
          float n = noise(u * 6.0 + j * 0.12, v * 6.0, t);
          float px = cx + (u - 0.5) * w * 0.92 + (v - 0.5) * diagonal * 0.18;
          float py = cy + offsetY * 0.28 + (v - 0.5) * h * 0.38 + (n - 0.5) * (18 + mid * 42) * scaleBase;
          pg.stroke(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 70 + energy * 75);
          pg.strokeWeight(max(0.45, (0.7 + bass * 2.2) * scaleBase));
          pg.curveVertex(px, py);
        }
        pg.endShape();
      }
    } else if (texture != null) {
      desenharEstampaDeTexturaFallback(pg, texture, x, y, w, h, density, scaleBase, energy, bass, mid, treble, t, 2);
    }
  } else if (modo == 3) {
    int total = constrain(density * 5 + round(energy * 28), 24, 180);
    for (int i = 0; i < total; i++) {
      float u = temMarca ? (brand.originalPoints.get((i * 37) % brand.originalPoints.size()).x - brand.minX) / brandW : hash1D(i + seedValue, 13.0);
      float v = temMarca ? (brand.originalPoints.get((i * 37) % brand.originalPoints.size()).y - brand.minY) / brandH : hash1D(i + seedValue, 67.0);
      float n = noise(u * 4.0, v * 4.0, t);
      float dw = tileBase * (0.9 + n * 1.8 + bass * 0.7);
      float dh = tileBase * (0.7 + (1.0 - n) * 1.4 + mid * 0.7);
      float px = cx + (u - 0.5) * w * 0.96 + (v - 0.5) * diagonal * 0.35 + (n - 0.5) * mid * 30 * scaleBase;
      float py = cy + (v - 0.5) * h * 0.96 + sin(t * 3.3 + i) * treble * 12 * scaleBase;
      pg.pushMatrix();
      pg.translate(px, py);
      pg.rotate((n - 0.5) * 0.55 + diagonal * 0.0008);
      if (texture != null) {
        int sw = constrain(round(texture.width * (0.18 + n * 0.26)), 8, texture.width);
        int sh = constrain(round(texture.height * (0.18 + (1.0 - n) * 0.26)), 8, texture.height);
        int sx = constrain(round(u * texture.width) - sw / 2, 0, max(0, texture.width - sw));
        int sy = constrain(round(v * texture.height) - sh / 2, 0, max(0, texture.height - sh));
        pg.tint(255, 138 + energy * 86);
        pg.image(texture, -dw * 0.5, -dh * 0.5, dw, dh, sx, sy, sx + sw, sy + sh);
        pg.noTint();
      } else {
        pg.noStroke();
        pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 125 + energy * 78);
        pg.rectMode(CENTER);
        float corner = mutationParams != null ? max(0, tileBase * (0.18 - mutationParams.angularity * 0.12)) : tileBase * 0.12;
        pg.rect(0, 0, dw, dh, corner);
      }
      pg.popMatrix();
    }
  } else {
    int cols = constrain(density * 2 + round(energy * 10), 12, 72);
    int rows = constrain(round(cols * h / max(1, w)), 10, 66);
    float cellW = w / cols;
    float cellH = h / rows;
    pg.noStroke();
    for (int gy = 0; gy < rows; gy++) {
      for (int gx = 0; gx < cols; gx++) {
        float u = (gx + 0.5) / cols;
        float v = (gy + 0.5) / rows;
        float marca = temMarca ? estampaCampoMarca(brand, u, v, density) : 0.5;
        float n = noise(u * 7.0, v * 7.0, t);
        if (marca + n * 0.35 > 0.45 - energy * 0.12) {
          float px = x + gx * cellW + (v - 0.5) * diagonal * 0.045;
          float py = y + gy * cellH;
          pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 118 + energy * 92);
          pg.rect(px, py, cellW * (0.75 + marca + bass * 0.18), cellH * (0.75 + marca + mid * 0.16));
        }
      }
    }
  }

  pg.noClip();
  pg.noFill();
  pg.stroke(20, 20, 22, 72);
  pg.strokeWeight(1.1);
  pg.rect(x, y, w, h);
  pg.popStyle();
}

void desenharEstampaPontosMarca(PGraphics pg, MutableBrand brand, int startIdx, int endIdx, float stepSize, float scaleMarca, float ar, float ag, float ab, float br, float bg, float bb, float alphaBase, float t, float bass, float mid, float treble) {
  if (brand == null || brand.originalPoints == null || brand.originalPoints.size() == 0) return;
  float brandW = max(1, brand.maxX - brand.minX);
  float brandH = max(1, brand.maxY - brand.minY);
  int step = max(1, round(stepSize));
  int end = constrain(endIdx, 0, brand.originalPoints.size());
  pg.noStroke();
  for (int i = max(0, startIdx); i < end; i += step) {
    PVector p = brand.originalPoints.get(i);
    float px = (p.x - brand.center.x) * scaleMarca;
    float py = (p.y - brand.center.y) * scaleMarca;
    float u = (p.x - brand.minX) / brandW;
    float v = (p.y - brand.minY) / brandH;
    float n = noise(u * 8.0, v * 8.0, t);
    float d = max(0.8, (1.0 + bass * 2.1 + n * 1.4) * scaleMarca * 1.8);
    pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), alphaBase);
    pg.ellipse(px + (n - 0.5) * mid * 5.0 * scaleMarca, py + sin(t * 5.0 + i * 0.03) * treble * 3.0 * scaleMarca, d, d);
  }
}

void desenharSistemaEstampaOrganica(PGraphics pg, float x, float y, float w, float h, int modo, int density, float scaleBase, float seedValue, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  float contraste = 0.72 + constrain(padraoEscala, 0.12, 1.20) * 0.35;
  float baseStep = constrain((padraoEspacoX + padraoEspacoY) * 0.5 * scaleBase, 18, 190);
  float resposta = 0.65 + energy * 0.55;
  float cx = x + w * 0.5 + padraoRefX * scaleBase;
  float cy = y + h * 0.5 + padraoRefY * scaleBase;

  if (modo >= 0 && modo < 24) {
    desenharPadraoEditorialModular(pg, x, y, w, h, modo, density, baseStep, seedValue, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca);
    desenharGranulacaoEstampa(pg, x, y, w, h, density, seedValue, t);
    return;
  }

  if (modo == 0) {
    desenharPadraoOptico(pg, x, y, w, h, density, baseStep, t, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca);
  } else if (modo == 1) {
    desenharPadraoMetaball(pg, x, y, w, h, density, baseStep, t, bass, mid, treble, ar, ag, ab, br, bg, bb, contraste, brand, temMarca);
  } else if (modo == 2) {
    desenharPadraoPontilhista(pg, x, y, w, h, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca);
  } else if (modo == 3) {
    desenharPadraoFluxoHalftone(pg, x, y, w, h, density, baseStep, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca);
  } else if (modo == 4) {
    desenharPadraoCampoEmergente(pg, x, y, w, h, density, t, resposta, ar, ag, ab, br, bg, bb, brand, temMarca);
  } else if (modo == 5) {
    desenharPadraoEco(pg, x, y, w, h, density, baseStep, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca);
  } else if (modo == 6) {
    desenharPadraoPerlin(pg, x, y, w, h, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca);
  } else if (modo == 7) {
    desenharPadraoAreia(pg, x, y, w, h, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca);
  } else {
    desenharPadraoFios(pg, x, y, w, h, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca);
  }

  if (modo != 6) desenharGranulacaoEstampa(pg, x, y, w, h, density, seedValue, t);
}

void desenharPadraoEditorialModular(PGraphics pg, float x, float y, float w, float h, int modo, int density, float baseStep, float seedValue, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  int familia = modo / 3;
  int variante = modo % 3;
  float resposta = 0.75 + energy * 0.55;
  float dnaPeso = temMarca ? 0.46 : 0.24;

  if (familia == 0) {
    desenharEstampaGradeDigital(pg, x, y, w, h, variante, density, t, resposta, ar, ag, ab, br, bg, bb, brand, temMarca, dnaPeso);
  } else if (familia == 1) {
    desenharEstampaBarrasVerticais(pg, x, y, w, h, variante, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca, dnaPeso);
  } else if (familia == 2) {
    desenharEstampaOndasFluxo(pg, x, y, w, h, variante, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca, dnaPeso);
  } else if (familia == 3) {
    desenharEstampaInterferencia(pg, x, y, w, h, variante, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca, dnaPeso);
  } else if (familia == 4) {
    desenharEstampaGeometriaFragmentada(pg, x, y, w, h, variante, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca, dnaPeso);
  } else if (familia == 5) {
    desenharEstampaCampoDiagonal(pg, x, y, w, h, variante, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca, dnaPeso);
  } else if (familia == 6) {
    desenharEstampaExpansaoRuido(pg, x, y, w, h, variante, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca, dnaPeso);
  } else {
    desenharEstampaDadosLabirinto(pg, x, y, w, h, variante, density, t, energy, bass, mid, treble, ar, ag, ab, br, bg, bb, brand, temMarca, dnaPeso);
  }
}

float valorDnaEstampa(float u, float v, float t, MutableBrand brand, boolean temMarca, float peso) {
  float campo = campoOrganicoEstampa(u, v, t, brand, temMarca);
  float ritmo = noise(u * 7.0 + 4.0, v * 7.0 + 9.0, t);
  return constrain(lerp(ritmo, campo, peso), 0, 1);
}

void corEstampaStroke(PGraphics pg, float n, float a, float ar, float ag, float ab, float br, float bg, float bb) {
  pg.stroke(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), a);
}

void corEstampaFill(PGraphics pg, float n, float a, float ar, float ag, float ab, float br, float bg, float bb) {
  pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), a);
}

void desenharEstampaGradeDigital(PGraphics pg, float x, float y, float w, float h, int variante, int density, float t, float resposta, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca, float dnaPeso) {
  int cols = constrain(density * (variante == 0 ? 4 : 5), 22, 120);
  int rows = constrain(round(cols * h / max(1, w)), 18, 110);
  float cw = w / cols;
  float ch = h / rows;
  pg.noStroke();
  for (int gy = 0; gy < rows; gy++) {
    for (int gx = 0; gx < cols; gx++) {
      float u = (gx + 0.5) / cols;
      float v = (gy + 0.5) / rows;
      float n = valorDnaEstampa(u, v, t, brand, temMarca, dnaPeso);
      float grad = variante == 0 ? abs(u - 0.5) : (variante == 1 ? abs(v - 0.5) : abs((gx % 2) - (gy % 2)));
      float m = constrain((1.0 - grad * 1.55) * 0.44 + n * 0.72 + resposta * 0.08, 0, 1);
      if (m < 0.22 && variante != 2) continue;
      float inset = cw * (0.10 + (1.0 - m) * 0.34);
      corEstampaFill(pg, n, 50 + m * 165, ar, ag, ab, br, bg, bb);
      if (variante == 2) pg.rect(x + gx * cw + inset * 0.5, y + gy * ch + ch * 0.16, cw - inset, ch * (0.30 + m * 0.42));
      else pg.rect(x + gx * cw + inset, y + gy * ch + inset, max(0.7, cw - inset * 2), max(0.7, ch - inset * 2));
    }
  }
}

void desenharEstampaBarrasVerticais(PGraphics pg, float x, float y, float w, float h, int variante, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca, float dnaPeso) {
  int cols = constrain(density * 3 + 18, 28, 150);
  float gap = w / cols;
  pg.noStroke();
  for (int i = 0; i < cols; i++) {
    float u = (i + 0.5) / cols;
    float centerPull = 1.0 - abs(u - 0.5) * 1.85;
    float n = valorDnaEstampa(u, 0.5, t, brand, temMarca, dnaPeso);
    float wave = sin(u * PI * (variante == 1 ? 9.0 : 3.0) + t * 2.3) * (0.10 + mid * 0.06);
    float bw = gap * (0.18 + n * 0.72 + max(0, centerPull) * (variante == 0 ? 1.35 : 0.45) + bass * 0.20);
    float bh = h * (variante == 0 ? 1.0 : (0.22 + n * 0.72 + energy * 0.12));
    float yy = y + (h - bh) * (variante == 1 ? (0.50 + wave) : 0.5);
    float xx = x + i * gap + (variante == 2 ? sin(t * 2.0 + i * 0.34) * gap * 0.32 : 0);
    corEstampaFill(pg, n, 70 + n * 150, ar, ag, ab, br, bg, bb);
    pg.rect(xx + gap * 0.5 - bw * 0.5, yy, max(0.8, bw), bh);
  }
}

void desenharEstampaOndasFluxo(PGraphics pg, float x, float y, float w, float h, int variante, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca, float dnaPeso) {
  if (variante == 1) {
    desenharEstampaGradeDigital(pg, x, y, w, h, 0, density + 2, t, 0.9 + energy, ar, ag, ab, br, bg, bb, brand, temMarca, dnaPeso);
    return;
  }
  int linhas = constrain(density * 2 + 12, 28, 95);
  pg.noFill();
  pg.strokeCap(ROUND);
  for (int j = 0; j < linhas; j++) {
    float v = (j + 0.5) / linhas;
    float n0 = valorDnaEstampa(0.5, v, t, brand, temMarca, dnaPeso);
    corEstampaStroke(pg, n0, 54 + n0 * 125, ar, ag, ab, br, bg, bb);
    pg.strokeWeight(variante == 2 ? max(0.7, h / linhas * (0.40 + n0 * 1.20)) : max(0.35, h / linhas * 0.12));
    pg.beginShape();
    int pts = 90;
    for (int i = 0; i <= pts; i++) {
      float u = i / float(pts);
      float dna = valorDnaEstampa(u, v, t, brand, temMarca, dnaPeso);
      float amp = h * (variante == 2 ? 0.030 : 0.018) * (1.0 + mid + dna);
      float yy = y + v * h + sin(u * TWO_PI * (2.0 + dna * 3.0) + t * 2.2 + j * 0.25) * amp;
      yy += (noise(u * 4.0, v * 5.0, t) - 0.5) * amp * 1.4;
      pg.curveVertex(x + u * w, yy);
    }
    pg.endShape();
  }
}

void desenharEstampaInterferencia(PGraphics pg, float x, float y, float w, float h, int variante, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca, float dnaPeso) {
  int linhas = constrain(density * 5, 45, 180);
  pg.noFill();
  pg.strokeCap(SQUARE);
  for (int j = 0; j < linhas; j++) {
    float v = (j + 0.5) / linhas;
    float dna = valorDnaEstampa(0.5, v, t, brand, temMarca, dnaPeso);
    corEstampaStroke(pg, dna, 38 + dna * 150, ar, ag, ab, br, bg, bb);
    pg.strokeWeight(variante == 2 ? max(1.0, h / linhas * (1.2 + dna * 2.0)) : max(0.25, h / linhas * 0.18));
    pg.beginShape();
    int pts = 80;
    for (int i = 0; i <= pts; i++) {
      float u = i / float(pts);
      float local = valorDnaEstampa(u, v, t, brand, temMarca, dnaPeso);
      float center = exp(-sq((u - 0.5) * 4.0)) * (0.22 + local * 0.78);
      float yy = y + v * h + sin(u * PI * 8.0 + t * 2.0) * center * h * (0.010 + mid * 0.010);
      float xx = x + u * w + (variante == 1 ? sin(v * PI * 6.0 + t) * center * w * 0.018 : 0);
      pg.vertex(xx, yy);
    }
    pg.endShape();
  }
}

void desenharEstampaGeometriaFragmentada(PGraphics pg, float x, float y, float w, float h, int variante, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca, float dnaPeso) {
  int total = constrain(density * 7, 42, 210);
  pg.noStroke();
  for (int i = 0; i < total; i++) {
    float u = hash1D(i * 1.37 + variante, 17.0);
    float v = hash1D(i * 1.91 + variante, 41.0);
    float dna = valorDnaEstampa(u, v, t, brand, temMarca, dnaPeso);
    if (variante == 0 && hash1D(i, 73.0) > 0.42 + dna * 0.50) continue;
    float px = x + u * w;
    float py = y + v * h;
    float s = min(w, h) * (0.018 + dna * 0.060 + bass * 0.010);
    corEstampaFill(pg, dna, 56 + dna * 160, ar, ag, ab, br, bg, bb);
    pg.pushMatrix();
    pg.translate(px, py);
    pg.rotate((variante == 0 ? -QUARTER_PI : QUARTER_PI) + (noise(i * 0.2, t) - 0.5) * 0.5);
    if (variante == 2) {
      pg.triangle(-s, s, 0, -s * 1.2, s, s);
    } else {
      pg.quad(-s * 1.4, 0, 0, -s * 0.6, s * 1.4, 0, 0, s * 0.6);
    }
    pg.popMatrix();
  }
}

void desenharEstampaCampoDiagonal(PGraphics pg, float x, float y, float w, float h, int variante, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca, float dnaPeso) {
  int linhas = constrain(density * 3 + 12, 30, 130);
  pg.noFill();
  pg.strokeCap(SQUARE);
  for (int i = -linhas; i < linhas * 2; i++) {
    float u = i / float(linhas);
    float dna = valorDnaEstampa(fractEstampa(u * 0.37), 0.5, t, brand, temMarca, dnaPeso);
    corEstampaStroke(pg, dna, 50 + dna * 145, ar, ag, ab, br, bg, bb);
    pg.strokeWeight(variante == 1 ? max(1.0, w / linhas * 0.34) : max(0.35, w / linhas * (0.10 + dna * 0.28)));
    float shift = (noise(i * 0.11, t) - 0.5) * mid * 36;
    if (variante == 2) shift += sin(i * 0.55 + t * 2.2) * h * 0.035;
    pg.line(x + u * w + shift, y, x + (u - 0.55) * w - shift * 0.35, y + h);
  }
}

void desenharEstampaExpansaoRuido(PGraphics pg, float x, float y, float w, float h, int variante, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca, float dnaPeso) {
  int cols = constrain(density * 4, 26, 140);
  pg.noStroke();
  for (int i = 0; i < cols; i++) {
    float u = (i + 0.5) / cols;
    float dna = valorDnaEstampa(u, 0.5, t, brand, temMarca, dnaPeso);
    float bw = w / cols * (variante == 1 ? (0.25 + u * 2.5) : (0.18 + dna * 1.4));
    float total = variante == 0 ? constrain(density * 4, 28, 120) : 1;
    for (int j = 0; j < total; j++) {
      float v = total == 1 ? 0.5 : hash1D(i * 9.0 + j, 83.0);
      float local = valorDnaEstampa(u, v, t, brand, temMarca, dnaPeso);
      if (variante == 2 && hash1D(i * 7.0 + j, 113.0) > local + 0.22) continue;
      float bh = h * (variante == 0 ? (0.05 + local * 0.24) : 1.0);
      corEstampaFill(pg, local, 58 + local * 160, ar, ag, ab, br, bg, bb);
      pg.rect(x + u * w - bw * 0.5, y + v * h - bh * 0.5, max(0.8, bw), max(1.0, bh));
    }
  }
}

void desenharEstampaDadosLabirinto(PGraphics pg, float x, float y, float w, float h, int variante, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca, float dnaPeso) {
  int rows = constrain(density * 3, 24, 120);
  float rh = h / rows;
  pg.noStroke();
  if (variante == 2) {
    int cols = constrain(density * 3, 24, 120);
    float cw = w / cols;
    for (int gy = 0; gy < rows; gy++) {
      for (int gx = 0; gx < cols; gx++) {
        float u = (gx + 0.5) / cols;
        float v = (gy + 0.5) / rows;
        float dna = valorDnaEstampa(u, v, t, brand, temMarca, dnaPeso);
        if (hash1D(gx * 17 + gy * 31, 5.0) > 0.36 + dna * 0.38) continue;
        corEstampaFill(pg, dna, 54 + dna * 145, ar, ag, ab, br, bg, bb);
        if ((gx + gy) % 2 == 0) pg.rect(x + gx * cw, y + gy * rh + rh * 0.34, cw * (1.0 + dna * 0.8), max(1, rh * 0.32));
        else pg.rect(x + gx * cw + cw * 0.34, y + gy * rh, max(1, cw * 0.32), rh * (1.0 + dna * 0.8));
      }
    }
    return;
  }
  for (int j = 0; j < rows; j++) {
    float v = (j + 0.5) / rows;
    float dna = valorDnaEstampa(0.5, v, t, brand, temMarca, dnaPeso);
    int segs = constrain(round(4 + dna * 16 + density * 0.28), 4, 28);
    for (int s = 0; s < segs; s++) {
      float u = hash1D(j * 11.0 + s, 23.0);
      float len = w * (0.025 + hash1D(j * 13.0 + s, 61.0) * (variante == 0 ? 0.10 : 0.22));
      float hh = variante == 0 ? rh * (0.35 + dna) : rh * 0.28;
      corEstampaFill(pg, dna, 56 + dna * 160, ar, ag, ab, br, bg, bb);
      pg.rect(x + u * w, y + j * rh + rh * 0.5 - hh * 0.5, len, max(0.8, hh));
    }
  }
}

float fractEstampa(float v) {
  return v - floor(v);
}

void desenharPadraoOptico(PGraphics pg, float x, float y, float w, float h, int density, float stepBase, float t, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  float step = constrain(stepBase * (0.74 - constrain(padraoEscala, 0.12, 1.2) * 0.22), 28, 130);
  float radius = step * (0.56 + bass * 0.10);
  int cols = ceil(w / step) + 4;
  int rows = ceil(h / (step * 0.86)) + 4;

  pg.noStroke();
  for (int gy = -2; gy < rows; gy++) {
    for (int gx = -2; gx < cols; gx++) {
      float ox = (gy % 2) * step * 0.5;
      float n = noise(gx * 0.21, gy * 0.21, t);
      float px = x + gx * step + ox + (n - 0.5) * mid * 10;
      float py = y + gy * step * 0.86 + sin(t * 2.0 + gx * 0.7) * treble * 4;
      float u = constrain((px - x) / max(1, w), 0, 1);
      float v = constrain((py - y) / max(1, h), 0, 1);
      float dna = temMarca ? estampaCampoMarca(brand, u, v, density) : campoOrganicoEstampa(u, v, t, brand, temMarca);
      float d = radius * 2.0 * (0.72 + n * 0.12 + dna * 0.32 + bass * 0.05);
      for (int k = 4; k >= 0; k--) {
        float a = map(k, 4, 0, 18, 210);
        float dd = d + k * step * 0.08;
        pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), a);
        pg.ellipse(px, py, dd, dd);
      }
    }
  }
}

void desenharPadraoMetaball(PGraphics pg, float x, float y, float w, float h, int density, float stepBase, float t, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, float contraste, MutableBrand brand, boolean temMarca) {
  int cols = constrain(round(w / max(30, stepBase * 0.62)), 8, 34);
  int rows = constrain(round(h / max(30, stepBase * 0.62)), 8, 34);
  float cellW = w / cols;
  float cellH = h / rows;

  pg.noStroke();
  for (int gy = -1; gy <= rows; gy++) {
    for (int gx = -1; gx <= cols; gx++) {
      float n = noise(gx * 0.34 + 4.0, gy * 0.34, t);
      float px = x + (gx + 0.5) * cellW + (n - 0.5) * cellW * 0.70;
      float py = y + (gy + 0.5) * cellH + sin(t * 2.4 + gx * 0.8) * cellH * 0.18 * treble;
      float u = constrain((px - x) / max(1, w), 0, 1);
      float v = constrain((py - y) / max(1, h), 0, 1);
      float dna = campoOrganicoEstampa(u, v, t, brand, temMarca);
      float d = min(cellW, cellH) * (0.48 + n * 1.18 + dna * 1.05 + bass * 0.42) * contraste;
      if (n > 0.72) d *= 1.7;
      pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 168 + bass * 62);
      pg.ellipse(px, py, d, d * (0.82 + mid * 0.22));
      if (n > 0.58) {
        pg.ellipse(px + cellW * 0.34, py + cellH * 0.12, d * 0.80, d * 0.66);
      }
      if (n < 0.24) {
        pg.fill(238, 235, 228, 190);
        pg.ellipse(px, py, d * 0.34, d * 0.28);
      }
    }
  }
}

void desenharPadraoPontilhista(PGraphics pg, float x, float y, float w, float h, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  int total = constrain(density * 340 + round(energy * 1600), 1800, 14000);
  pg.noStroke();
  for (int i = 0; i < total; i++) {
    float u = hash1D(i * 1.37 + floor(t * 5.0), 19.0);
    float v = hash1D(i * 1.91 + floor(t * 3.0), 47.0);
    float f = campoOrganicoEstampa(u, v, t, brand, temMarca);
    float edge = 1.0 - abs(f - 0.52) * 4.2;
    float chance = constrain(edge + noise(u * 18, v * 18, t) * 0.38 - 0.22, 0, 1);
    if (hash1D(i, 113.0) > chance) continue;
    float n = noise(u * 8.0, v * 8.0, t);
    float px = x + u * w + (n - 0.5) * mid * 9;
    float py = y + v * h + sin(t * 2.6 + i * 0.012) * treble * 2.5;
    float d = 0.9 + chance * (2.8 + bass * 2.0) + n * 1.2;
    pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 75 + chance * 150);
    pg.ellipse(px, py, d, d);
  }
}

void desenharPadraoFluxoHalftone(PGraphics pg, float x, float y, float w, float h, int density, float stepBase, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  int cols = constrain(round(w / max(8, stepBase * 0.20)), 28, 150);
  int rows = constrain(round(h / max(8, stepBase * 0.20)), 24, 130);
  float cellW = w / cols;
  float cellH = h / rows;
  pg.noStroke();
  for (int gy = 0; gy < rows; gy++) {
    for (int gx = 0; gx < cols; gx++) {
      float u = (gx + 0.5) / cols;
      float v = (gy + 0.5) / rows;
      float waveA = abs(v - (0.20 + 0.18 * sin(u * 8.0 + t * 1.7) + 0.18 * noise(u * 2.0, t)));
      float waveB = abs(v - (0.58 + 0.16 * sin(u * 11.0 - t * 1.2) + 0.12 * noise(u * 4.0, 8.0, t)));
      float waveC = abs(u - (0.52 + 0.20 * sin(v * 7.0 + t * 1.4)));
      float force = max(max(1.0 - waveA * 9.0, 1.0 - waveB * 10.5), 1.0 - waveC * 7.0);
      force = constrain(force + campoOrganicoEstampa(u, v, t, brand, temMarca) * 0.42 + noise(u * 16, v * 16, t) * 0.20, 0, 1);
      if (force < 0.08) continue;
      float n = noise(u * 9.0, v * 9.0, t);
      float d = min(cellW, cellH) * (0.45 + force * (3.2 + bass * 1.8));
      float px = x + gx * cellW + cellW * 0.5 + (n - 0.5) * mid * 4;
      float py = y + gy * cellH + cellH * 0.5 + sin(t * 3.0 + gx) * treble * 1.5;
      pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 65 + force * 172);
      pg.ellipse(px, py, d, d);
    }
  }
}

void desenharPadraoCampoEmergente(PGraphics pg, float x, float y, float w, float h, int density, float t, float resposta, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  int cols = constrain(density * 3, 18, 96);
  int rows = constrain(round(cols * h / max(1, w)), 16, 88);
  float cellW = w / cols;
  float cellH = h / rows;
  pg.noStroke();
  for (int gy = 0; gy < rows; gy++) {
    for (int gx = 0; gx < cols; gx++) {
      float u = (gx + 0.5) / cols;
      float v = (gy + 0.5) / rows;
      float campo = campoOrganicoEstampa(u, v, t, brand, temMarca);
      float n = noise(u * 11.0, v * 11.0, t);
      if (campo + n * 0.30 < 0.48) continue;
      float m = constrain((campo - 0.36) * 2.2, 0, 1);
      pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 75 + m * 145);
      pg.rect(x + gx * cellW, y + gy * cellH, cellW * (0.65 + m * resposta), cellH * (0.65 + m * resposta));
    }
  }
}

void desenharPadraoEco(PGraphics pg, float x, float y, float w, float h, int density, float stepBase, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  int rings = constrain(density + 6, 12, 44);
  float cx = x + w * 0.5 + padraoRefX * 0.16;
  float cy = y + h * 0.5 + padraoRefY * 0.16;
  pg.noFill();
  for (int r = 0; r < rings; r++) {
    float rr = map(r, 0, rings - 1, min(w, h) * 0.06, max(w, h) * 0.82);
    float n = noise(r * 0.19, t);
    pg.stroke(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 42 + energy * 70);
    pg.strokeWeight(max(0.35, (0.55 + bass * 1.8) * (1.0 - r / float(rings) * 0.35)));
    pg.beginShape();
    int pts = 160;
    for (int i = 0; i <= pts; i++) {
      float a = TWO_PI * i / pts;
      float wobble = noise(cos(a) * 1.7 + r * 0.1, sin(a) * 1.7, t) - 0.5;
      float uu = 0.5 + cos(a) * 0.34;
      float vv = 0.5 + sin(a) * 0.34;
      float dna = campoOrganicoEstampa(uu, vv, t, brand, temMarca);
      float rad = rr * (1.0 + wobble * (0.16 + mid * 0.14) + (dna - 0.5) * 0.10);
      pg.curveVertex(cx + cos(a) * rad + sin(a * 3.0 + t) * treble * 4, cy + sin(a) * rad);
    }
    pg.endShape();
  }
}

void desenharPadraoPerlin(PGraphics pg, float x, float y, float w, float h, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  int fios = constrain(density * 2, 20, 72);
  float fluxo = 0.84 + constrain(padraoEscala, 0.12, 1.2) * 1.65;
  pg.noFill();
  pg.strokeCap(ROUND);
  for (int i = 0; i < fios; i++) {
    float u = hash1D(i * 1.17, 13.0);
    float v = hash1D(i * 1.91, 29.0);
    if (temMarca && brand.originalPoints.size() > 0) {
      PVector bp = brand.originalPoints.get((i * 47) % brand.originalPoints.size());
      u = lerp(u, (bp.x - brand.minX) / max(1, brand.maxX - brand.minX), 0.62);
      v = lerp(v, (bp.y - brand.minY) / max(1, brand.maxY - brand.minY), 0.62);
    }
    float n = noise(u * 4.0, v * 4.0, t);
    float len = w * (0.34 + hash1D(i, 71.0) * 0.48) * fluxo;
    float angle = noise(u * 1.55 + 9.0, v * 1.55, t * 0.34) * TWO_PI * 1.05;
    float px = x + u * w + padraoRefX * 0.08;
    float py = y + v * h + padraoRefY * 0.08;

    pg.stroke(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 24);
    pg.strokeWeight(0.12);
    int pts = 26;
    float prevX = 0;
    float prevY = 0;
    for (int k = 0; k < pts; k++) {
      float kk = k / float(pts - 1);
      float bend = (noise(i * 0.12, kk * 1.4, t * 0.54) - 0.5) * 0.30;
      float localA = angle + bend + sin(kk * PI + t + i) * 0.025;
      float dist = (kk - 0.5) * len;
      float ox = cos(localA) * dist;
      float oy = sin(localA) * dist;
      float ripple = sin(kk * TWO_PI * 1.25 + t * 1.3 + i * 0.31) * 0.7;
      float sx = px + ox - sin(localA) * ripple;
      float sy = py + oy + cos(localA) * ripple;
      if (k > 0) pg.line(prevX, prevY, sx, sy);
      prevX = sx;
      prevY = sy;
    }
  }
}

void desenharPadraoAreia(PGraphics pg, float x, float y, float w, float h, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  int total = constrain(density * 560 + round(energy * 2200), 2500, 22000);
  pg.noStroke();
  for (int i = 0; i < total; i++) {
    float u = hash1D(i * 0.91 + floor(t * 2.0), 71.0);
    float v = hash1D(i * 1.23 + floor(t * 3.0), 97.0);
    float campo = campoOrganicoEstampa(u, v, t, brand, temMarca);
    float n = noise(u * 12.0, v * 12.0, t);
    if (hash1D(i, 131.0) > constrain(campo * 0.72 + n * 0.42 + 0.12, 0, 1)) continue;
    float px = x + u * w + (n - 0.5) * mid * 18;
    float py = y + v * h + sin(t * 4.0 + i * 0.013) * treble * 4;
    float d = 0.55 + hash1D(i, 173.0) * (1.8 + bass * 2.2);
    pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 38 + campo * 150);
    pg.ellipse(px, py, d, d);
  }
}

void desenharPadraoFios(PGraphics pg, float x, float y, float w, float h, int density, float t, float energy, float bass, float mid, float treble, float ar, float ag, float ab, float br, float bg, float bb, MutableBrand brand, boolean temMarca) {
  int fios = constrain(density * 4, 32, 180);
  pg.noFill();
  pg.strokeCap(ROUND);
  for (int i = 0; i < fios; i++) {
    float u = hash1D(i, 13.0);
    float v = hash1D(i, 29.0);
    if (temMarca && brand.originalPoints.size() > 0) {
      PVector bp = brand.originalPoints.get((i * 31) % brand.originalPoints.size());
      u = lerp(u, (bp.x - brand.minX) / max(1, brand.maxX - brand.minX), 0.48);
      v = lerp(v, (bp.y - brand.minY) / max(1, brand.maxY - brand.minY), 0.48);
    }
    float n = noise(u * 5.0, v * 5.0, t);
    pg.stroke(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), 42 + energy * 108);
    pg.strokeWeight(max(0.35, 0.55 + bass * 1.6 + n * 0.9));
    pg.beginShape();
    int pts = 12;
    for (int k = 0; k < pts; k++) {
      float kk = k / float(pts - 1);
      float px = x + (u + (kk - 0.5) * 0.32 + sin(t + i) * 0.04) * w;
      float py = y + (v + sin(kk * PI * 2.0 + n * 4.0 + t) * (0.04 + mid * 0.05)) * h;
      px += (noise(i * 0.2, kk * 2.0, t) - 0.5) * treble * 18;
      pg.curveVertex(px, py);
    }
    pg.endShape();
  }
}

float campoOrganicoEstampa(float u, float v, float t, MutableBrand brand, boolean temMarca) {
  float f = 0;
  for (int i = 0; i < 7; i++) {
    float ax = noise(i * 2.1 + 13.0, t * 0.22) * 1.18 - 0.09;
    float ay = noise(i * 3.4 + 31.0, t * 0.20) * 1.18 - 0.09;
    float dx = u - ax;
    float dy = v - ay;
    float r = 0.035 + noise(i * 1.7, t) * 0.085;
    f += r / max(0.006, dx * dx + dy * dy);
  }
  f = constrain(f * 0.075, 0, 1);
  if (temMarca) {
    f = lerp(f, estampaCampoMarca(brand, u, v, 12), 0.28);
  }
  return f;
}

void desenharGranulacaoEstampa(PGraphics pg, float x, float y, float w, float h, int density, float seedValue, float t) {
  int total = constrain(round(w * h / 900.0) + density * 40, 300, 2800);
  pg.noStroke();
  for (int i = 0; i < total; i++) {
    float u = hash1D(i + seedValue * 17.0, 211.0);
    float v = hash1D(i + seedValue * 23.0, 307.0);
    float a = 10 + hash1D(i, 409.0) * 26;
    if (i % 2 == 0) pg.fill(0, a);
    else pg.fill(255, a * 0.45);
    float s = 0.6 + hash1D(i, 509.0) * 1.4;
    pg.rect(x + u * w, y + v * h, s, s);
  }
}

float estampaCampoMarca(MutableBrand brand, float u, float v, int density) {
  if (brand == null || brand.originalPoints == null || brand.originalPoints.size() == 0) return 0;
  float best = 999;
  float brandW = max(1, brand.maxX - brand.minX);
  float brandH = max(1, brand.maxY - brand.minY);
  int step = max(1, brand.originalPoints.size() / max(60, density * 45));
  for (int i = 0; i < brand.originalPoints.size(); i += step) {
    PVector p = brand.originalPoints.get(i);
    float pu = (p.x - brand.minX) / brandW;
    float pv = (p.y - brand.minY) / brandH;
    float dx = u - pu;
    float dy = v - pv;
    float d = dx * dx + dy * dy;
    if (d < best) best = d;
  }
  return constrain(1.0 - sqrt(best) * 7.0, 0, 1);
}

void desenharEstampaDeTexturaFallback(PGraphics pg, PImage img, float x, float y, float w, float h, int density, float scaleBase, float energy, float bass, float mid, float treble, float t, int style) {
  if (img == null) return;
  img.loadPixels();
  int cols = constrain(density * 4 + round(energy * 14), 18, 120);
  int rows = constrain(round(cols * h / max(1, w)), 14, 110);
  float cellW = w / cols;
  float cellH = h / rows;
  pg.noStroke();
  for (int gy = 0; gy < rows; gy++) {
    for (int gx = 0; gx < cols; gx++) {
      float u = (gx + 0.5) / cols;
      float v = (gy + 0.5) / rows;
      int sx = constrain(round(u * img.width), 0, img.width - 1);
      int sy = constrain(round(v * img.height), 0, img.height - 1);
      int c = img.pixels[sy * img.width + sx];
      float bright = (red(c) + green(c) + blue(c)) / 3.0;
      float n = noise(u * 7.0, v * 7.0, t);
      float px = x + u * w + (n - 0.5) * mid * 12 * scaleBase;
      float py = y + v * h + sin(t * 4.0 + gx * 0.3) * treble * 5 * scaleBase;
      if (style == 1) {
        float d = min(cellW, cellH) * map(bright, 255, 0, 0.18, 1.15) * (0.8 + bass);
        pg.fill(red(c), green(c), blue(c), 120 + energy * 75);
        pg.ellipse(px, py, d, d);
      } else {
        pg.stroke(red(c), green(c), blue(c), 100 + energy * 70);
        pg.strokeWeight(max(0.4, map(bright, 255, 0, 0.5, 2.2 + bass) * scaleBase));
        pg.line(px - cellW * 0.45, py, px + cellW * 0.45, py + (n - 0.5) * cellH);
      }
    }
  }
}

void desenharPlaceholderMarca(PGraphics pg) {
  pg.pushStyle();
  pg.colorMode(RGB, 255);
  pg.noFill();
  pg.stroke(70);
  pg.strokeWeight(1);
  float w = min(pg.width, pg.height) * 0.28;
  pg.rectMode(CENTER);
  pg.rect(pg.width * 0.5, pg.height * 0.5, w * 1.7, w, 8);
  pg.fill(130);
  pg.textAlign(CENTER, CENTER);
  pg.textSize(constrain(pg.height * 0.025, 14, 22));
  pg.text("Carregue um SVG ou PNG", pg.width * 0.5, pg.height * 0.5);
  pg.popStyle();
}

void desenharPadraoEstampa(PGraphics pg, float seedValue, float breathTime, float scaleBase) {
  int totalFormas = constrain(round(padraoQtdFormas), 6, 12);
  int cols = (int) ceil(sqrt(totalFormas));
  int rows = (int) ceil(totalFormas / float(cols));
  float shapeScale = scaleBase * padraoEscala;
  float fade = constrain(map(intensidade, 0.02, 0.55, 0.30, 1.0), 0.25, 1.0);
  float centerX = pg.width * 0.5 + padraoRefX * scaleBase;
  float centerY = pg.height * 0.5 + padraoRefY * scaleBase;
  float halfCols = (cols - 1) * 0.5;
  float halfRows = (rows - 1) * 0.5;
  float diagonal = padraoDiagonal * scaleBase;

  for (int idx = 0; idx < totalFormas; idx++) {
    int gy = idx / cols;
    int gx = idx % cols;
    float offX = (gx - halfCols);
    float offY = (gy - halfRows);
    float x = offX * padraoEspacoX * scaleBase;
    float y = offY * padraoEspacoY * scaleBase;
    x += offY * diagonal;
    y += offX * diagonal * 0.45;
    float jitterX = sin(frameCount * 0.012 + idx * 0.71 + seedValue) * 4.0 * scaleBase;
    float jitterY = cos(frameCount * 0.010 + idx * 0.53 + seedValue * 0.8) * 4.0 * scaleBase;
    int forma = (formaPadraoAtiva == 0) ? ((gx + gy) % 4 + 1) : formaPadraoAtiva;
    float pulsoLocal = 0.90 + 0.12 * sin(frameCount * 0.05 + idx * 0.31 + breathTime);
    float alphaLocal = fade * (0.35 + 0.65 * pulsoLocal);

    pg.pushMatrix();
    pg.translate(centerX + x + jitterX, centerY + y + jitterY);
    pg.scale(shapeScale * pulsoLocal);
    desenharFormaPorIndice(pg, forma, seedValue + idx * 0.03, breathTime, alphaLocal);
    pg.popMatrix();
  }
}

void renderMutableBrand(PGraphics pg, MutableBrand brand, MutationParams params, AudioData audio, GestureData gesture, float seedValue, float scaleBase) {
  if (brand == null || (brand.sourceShape == null && brand.sourceImage == null) || params == null) return;
  if (audio == null) audio = new AudioData();
  if (gesture == null) gesture = new GestureData();

  float assetW = max(1, brand.maxX - brand.minX);
  float assetH = max(1, brand.maxY - brand.minY);
  float fit = min((pg.width * 0.62) / assetW, (pg.height * 0.54) / assetH);
  fit = constrain(fit, 0.04, 7.0);
  float driftX = map(noise(seedValue + 17.0, tempoFlutua), 0, 1, -18, 18) * scaleBase;
  float driftY = map(noise(tempoFlutua, seedValue + 31.0), 0, 1, -14, 14) * scaleBase;
  float gestureOffsetX = 0;
  float gestureOffsetY = 0;

  pg.pushMatrix();
  pg.translate(pg.width * 0.5 + driftX + gestureOffsetX, pg.height * 0.5 + driftY + gestureOffsetY);
  pg.rotate(brand.currentRotation);
  pg.scale(fit * brand.currentScale);

  if (params.mode == 0) {
    renderBrandNormalReactive(pg, brand, params, fit, audio);
    pg.popMatrix();
    return;
  }

  if (!brand.hasPointData && brand.sourceShape != null) {
    float refAlpha = params.mode == 2 ? 18 : 38 + audio.energy * 22;
    renderBrandReferenceShape(pg, brand, params, fit, refAlpha, audio);
  } else if (!brand.hasPointData && brand.sourceImage != null) {
    renderBrandRasterReference(pg, brand, params, fit, audio);
  }

  if (!brand.hasPointData) {
    renderBrandFallback(pg, brand, params, fit, audio);
  } else if (params.mode == 1) {
    renderBrandOrganicMass(pg, brand, params, fit, false, 18 + audio.bass * 16);
    renderBrandOrganicMass(pg, brand, params, fit, true, 86);
    renderBrandRasterStrokes(pg, brand, params, fit, true, 10 + audio.treble * 24);
  } else if (params.mode == 2) {
    renderBrandPointDots(pg, brand, params, fit, true, 92);
  } else if (params.mode == 3) {
    renderBrandRasterStrokes(pg, brand, params, fit, true, 88);
  } else if (params.mode == 4) {
    renderBrandParticles(pg, brand, params, fit, seedValue, audio);
  } else if (params.mode == 5) {
    renderBrandGrid(pg, brand, params, fit, audio);
  } else if (params.mode == 6) {
    renderBrandEcho(pg, brand, params, fit, audio);
  } else if (params.mode == 7) {
    renderBrandPerlinGossamer(pg, brand, params, fit, audio);
  } else if (params.mode == 8) {
    renderBrandSand(pg, brand, params, fit, audio);
  } else if (params.mode == 9) {
    renderBrandPlush(pg, brand, params, fit, audio);
  } else if (params.mode == 10) {
    renderBrandHairFibers(pg, brand, params, fit, audio);
  } else if (params.mode == 11) {
    renderBrandReactionDiffusion(pg, brand, params, fit, audio);
  } else {
    renderBrandPointDots(pg, brand, params, fit, true, 90);
  }

  pg.popMatrix();
}

void renderMutableBrandEmPonto(PGraphics pg, MutableBrand brand, MutationParams params, AudioData audio, GestureData gesture, float seedValue, float scaleBase, float centerX, float centerY, float fit) {
  if (brand == null || (brand.sourceShape == null && brand.sourceImage == null) || params == null) return;
  if (audio == null) audio = new AudioData();
  if (gesture == null) gesture = new GestureData();

  fit = constrain(fit, 0.04, 18.0);
  float driftX = map(noise(seedValue + 17.0, tempoFlutua), 0, 1, -18, 18) * scaleBase;
  float driftY = map(noise(tempoFlutua, seedValue + 31.0), 0, 1, -14, 14) * scaleBase;

  pg.pushMatrix();
  pg.translate(centerX + driftX, centerY + driftY);
  pg.rotate(brand.currentRotation);
  pg.scale(fit * brand.currentScale);

  if (params.mode == 0) {
    renderBrandNormalReactive(pg, brand, params, fit, audio);
    pg.popMatrix();
    return;
  }

  if (!brand.hasPointData && brand.sourceShape != null) {
    float refAlpha = params.mode == 2 ? 18 : 38 + audio.energy * 22;
    renderBrandReferenceShape(pg, brand, params, fit, refAlpha, audio);
  } else if (!brand.hasPointData && brand.sourceImage != null) {
    renderBrandRasterReference(pg, brand, params, fit, audio);
  }

  if (!brand.hasPointData) {
    renderBrandFallback(pg, brand, params, fit, audio);
  } else if (params.mode == 1) {
    renderBrandOrganicMass(pg, brand, params, fit, false, 18 + audio.bass * 16);
    renderBrandOrganicMass(pg, brand, params, fit, true, 86);
    renderBrandRasterStrokes(pg, brand, params, fit, true, 10 + audio.treble * 24);
  } else if (params.mode == 2) {
    renderBrandPointDots(pg, brand, params, fit, true, 92);
  } else if (params.mode == 3) {
    renderBrandRasterStrokes(pg, brand, params, fit, true, 88);
  } else if (params.mode == 4) {
    renderBrandParticles(pg, brand, params, fit, seedValue, audio);
  } else if (params.mode == 5) {
    renderBrandGrid(pg, brand, params, fit, audio);
  } else if (params.mode == 6) {
    renderBrandEcho(pg, brand, params, fit, audio);
  } else if (params.mode == 7) {
    renderBrandPerlinGossamer(pg, brand, params, fit, audio);
  } else if (params.mode == 8) {
    renderBrandSand(pg, brand, params, fit, audio);
  } else if (params.mode == 9) {
    renderBrandPlush(pg, brand, params, fit, audio);
  } else if (params.mode == 10) {
    renderBrandHairFibers(pg, brand, params, fit, audio);
  } else if (params.mode == 11) {
    renderBrandReactionDiffusion(pg, brand, params, fit, audio);
  } else {
    renderBrandPointDots(pg, brand, params, fit, true, 90);
  }

  pg.popMatrix();
}

void renderBrandOriginalClean(PGraphics pg, MutableBrand brand, MutationParams params, float fit) {
  renderBrandOriginalCleanAlpha(pg, brand, params, fit, 100);
}

void renderBrandOriginalCleanAlpha(PGraphics pg, MutableBrand brand, MutationParams params, float fit, float alphaPct) {
  if (brand == null) return;

  pg.pushStyle();
  if (brand.sourceImage != null) {
    pg.colorMode(RGB, 255, 255, 255, 255);
    pg.imageMode(CENTER);
    int c = corMarcaRender(params, false);
    pg.tint(red(c), green(c), blue(c), 255 * constrain(params.opacityAmount, 0, 1) * constrain(alphaPct, 0, 100) / 100.0);
    pg.image(brand.sourceImage, 0, 0);
    pg.noTint();
  } else if (brand.sourceShape != null) {
    pg.shapeMode(CORNER);
    brand.sourceShape.disableStyle();
    applyBrandColor(pg, params, alphaPct, true, false);
    pg.noStroke();
    pg.shape(brand.sourceShape, -brand.center.x, -brand.center.y);
    brand.sourceShape.enableStyle();
  } else if (brand.hasPointData) {
    renderBrandOriginalNormalSurface(pg, brand, params, fit, 68 * constrain(alphaPct, 0, 100) / 100.0);
  }
  pg.popStyle();
}

boolean renderBrandMaskDisplacement(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio, boolean gooey) {
  if (brand == null || brand.sourceImage == null || params == null) return false;
  PImage srcFull = brand.sourceImage;
  if (srcFull.width <= 1 || srcFull.height <= 1) return false;
  if (srcFull.pixels == null || srcFull.pixels.length == 0) srcFull.loadPixels();

  int maxSide = gooey ? 900 : 780;
  float down = min(1.0, maxSide / float(max(srcFull.width, srcFull.height)));
  int sw = max(8, round(srcFull.width * down));
  int sh = max(8, round(srcFull.height * down));
  PImage src = createImage(sw, sh, ARGB);
  src.copy(srcFull, 0, 0, srcFull.width, srcFull.height, 0, 0, sw, sh);
  src.loadPixels();

  PImage out = createImage(sw, sh, ARGB);
  out.loadPixels();

  float bass = audio != null ? constrain(audio.bass * 1.25 * params.bassInfluence, 0, 1.6) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.10 * params.midInfluence, 0, 1.4) : 0;
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.35, 0, 1.35) : 0;
  float t = noiseDynamicTime * (gooey ? 0.10 : 0.16) + energy * 0.04;
  float noiseScale = gooey ? 0.010 : 0.014;
  float maxOffset = (gooey ? 18.0 : 7.0) * down * (0.45 + energy * 0.55 + bass * 0.35);
  float surfacePull = gooey ? 1.0 : 0.62;

  int c = corMarcaRender(params, false);
  int rr = int(red(c));
  int gg = int(green(c));
  int bb = int(blue(c));
  float opacity = constrain(params.opacityAmount, 0, 1);

  for (int y = 0; y < sh; y++) {
    for (int x = 0; x < sw; x++) {
      float aHere = alphaSample(src, x, y) / 255.0;
      float gradX = alphaSample(src, x + 2, y) - alphaSample(src, x - 2, y);
      float gradY = alphaSample(src, x, y + 2) - alphaSample(src, x, y - 2);
      float gm = sqrt(gradX * gradX + gradY * gradY) / 255.0;
      float edge = smoothstepNormal(0.02, 0.32, gm);

      float n1 = noise(x * noiseScale + 12.0, y * noiseScale + 31.0, t);
      float n2 = noise(x * noiseScale * 0.55 + 73.0, y * noiseScale * 0.55 + 19.0, t * 0.70);
      float ang = (n1 * TWO_PI * 1.35) + (n2 - 0.5) * PI * 0.55;

      float nx = gradX;
      float ny = gradY;
      float nm = sqrt(nx * nx + ny * ny);
      if (nm > 0.001) {
        nx /= nm;
        ny /= nm;
      } else {
        nx = cos(ang);
        ny = sin(ang);
      }

      float wave = sin(t * 4.0 + x * 0.025 - y * 0.018) * 0.22;
      float amount = maxOffset * edge * (0.55 + n2 * 0.55 + wave);
      float tx = -ny;
      float ty = nx;
      float tangent = maxOffset * edge * (n1 - 0.5) * (gooey ? 0.26 : 0.16);

      float sx = x - nx * amount * surfacePull - tx * tangent;
      float sy = y - ny * amount * surfacePull - ty * tangent;
      int aa = int(constrain(alphaBilinear(src, sx, sy) * opacity, 0, 255));
      out.pixels[y * sw + x] = (aa << 24) | (rr << 16) | (gg << 8) | bb;
    }
  }
  out.updatePixels();

  if (gooey) {
    out.filter(BLUR, 0.55);
    out.loadPixels();
    for (int i = 0; i < out.pixels.length; i++) {
      int a = (out.pixels[i] >>> 24) & 0xFF;
      a = constrain(round(map(a, 18, 220, 0, 255)), 0, 255);
      out.pixels[i] = (a << 24) | (rr << 16) | (gg << 8) | bb;
    }
    out.updatePixels();
  }

  pg.pushStyle();
  pg.imageMode(CENTER);
  pg.image(out, 0, 0, srcFull.width, srcFull.height);
  pg.popStyle();
  return true;
}

float alphaSample(PImage img, int x, int y) {
  x = constrain(x, 0, img.width - 1);
  y = constrain(y, 0, img.height - 1);
  return (img.pixels[y * img.width + x] >>> 24) & 0xFF;
}

float alphaBilinear(PImage img, float x, float y) {
  x = constrain(x, 0, img.width - 1.001);
  y = constrain(y, 0, img.height - 1.001);
  int x0 = floor(x);
  int y0 = floor(y);
  int x1 = min(img.width - 1, x0 + 1);
  int y1 = min(img.height - 1, y0 + 1);
  float tx = x - x0;
  float ty = y - y0;
  float a00 = alphaSample(img, x0, y0);
  float a10 = alphaSample(img, x1, y0);
  float a01 = alphaSample(img, x0, y1);
  float a11 = alphaSample(img, x1, y1);
  return lerp(lerp(a00, a10, tx), lerp(a01, a11, tx), ty);
}

void renderBrandNormalReactive(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null) return;
  if (brand.meshLogo != null && brand.meshLogo.render(pg, params, 100)) return;
  if (renderBrandMaskDisplacement(pg, brand, params, fit, audio, false)) return;
  renderBrandOriginalClean(pg, brand, params, fit);
}

void renderBrandNormalVectorFluid(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  pg.pushStyle();
  renderBrandOriginalCleanAlpha(pg, brand, params, fit, 94);

  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.35, 0, 1.25) : 0;
  float bass = audio != null ? constrain(audio.bass * 1.25 * params.bassInfluence, 0, 1.5) : 0;
  float span = max(1, brand.span());
  float noiseScale = constrain(0.006 + params.noiseAmount * 0.0028, 0.005, 0.018);
  float displacementStrength = span * constrain(0.004 + energy * 0.006 + bass * 0.004, 0.003, 0.016);
  float maxOffset = span * constrain(0.006 + energy * 0.006, 0.004, 0.018);
  float t = noiseDynamicTime * (0.16 + params.transformSpeed * 0.030);

  pg.noFill();
  applyBrandColor(pg, params, 34 + energy * 20, false, false);
  pg.strokeWeight(constrain(0.70 + params.strokeAmount * 0.070 + bass * 0.14, 0.55, 1.35) / max(0.001, fit));
  pg.strokeJoin(ROUND);
  pg.strokeCap(ROUND);

  ArrayList<PVector> contour = new ArrayList<PVector>();
  for (int i = 0; i < brand.originalPoints.size(); i++) {
    boolean starts = brand.breakBefore != null && brand.breakBefore.size() > i && brand.breakBefore.get(i);
    if (starts && contour.size() > 3) {
      desenharContornoNormalFluido(pg, brand, contour, noiseScale, displacementStrength, maxOffset, t);
      contour.clear();
    }
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer <= 1) contour.add(brand.originalPoints.get(i).copy());
  }
  if (contour.size() > 3) desenharContornoNormalFluido(pg, brand, contour, noiseScale, displacementStrength, maxOffset, t);

  pg.popStyle();
}

void desenharContornoNormalFluido(PGraphics pg, MutableBrand brand, ArrayList<PVector> contour, float noiseScale, float displacementStrength, float maxOffset, float t) {
  ArrayList<PVector> dense = reamostrarContornoNormalAberto(contour, max(1.25, brand.span() * 0.006));
  for (int iter = 0; iter < 7; iter++) dense = suavizarContornoNormalAberto(dense);
  if (dense.size() < 4) return;

  int n = dense.size();
  ArrayList<PVector> deformed = new ArrayList<PVector>();
  for (int i = 0; i < n; i++) {
    PVector p = dense.get(i);
    PVector prev = dense.get(max(0, i - 1));
    PVector next = dense.get(min(n - 1, i + 1));
    PVector tangent = PVector.sub(next, prev);
    if (tangent.mag() < 0.001) tangent.set(1, 0);
    tangent.normalize();
    PVector normal = new PVector(-tangent.y, tangent.x);

    float nA = noise(p.x * noiseScale + 12.0, p.y * noiseScale + 31.0, t);
    float nB = noise(p.x * noiseScale * 0.55 + 72.0, p.y * noiseScale * 0.55 + 9.0, t * 0.72);
    float smoothN = map((nA + nB) * 0.5, 0, 1, -1, 1);
    float wave = sin(t * 2.4 + p.x * 0.005 - p.y * 0.003) * 0.16;
    float offset = constrain((smoothN * 0.48 + wave) * displacementStrength, -maxOffset, maxOffset);
    deformed.add(new PVector(p.x + normal.x * offset, p.y + normal.y * offset));
  }
  for (int iter = 0; iter < 5; iter++) deformed = suavizarContornoNormalAberto(deformed);

  pg.beginShape();
  for (int i = 0; i < deformed.size(); i++) {
    PVector p = deformed.get(i);
    pg.curveVertex(p.x - brand.center.x, p.y - brand.center.y);
  }
  pg.endShape();
}

ArrayList<PVector> reamostrarContornoNormalAberto(ArrayList<PVector> pts, float step) {
  ArrayList<PVector> out = new ArrayList<PVector>();
  if (pts == null || pts.size() == 0) return out;
  for (int i = 0; i < pts.size() - 1; i++) {
    PVector a = pts.get(i);
    PVector b = pts.get(i + 1);
    float d = max(0.001, PVector.dist(a, b));
    int cuts = max(1, ceil(d / max(0.001, step)));
    for (int k = 0; k < cuts; k++) {
      float tt = k / float(cuts);
      out.add(PVector.lerp(a, b, tt));
    }
  }
  out.add(pts.get(pts.size() - 1).copy());
  return out;
}

ArrayList<PVector> suavizarContornoNormalAberto(ArrayList<PVector> pts) {
  ArrayList<PVector> out = new ArrayList<PVector>();
  int n = pts.size();
  for (int i = 0; i < n; i++) {
    if (i == 0 || i == n - 1) {
      out.add(pts.get(i).copy());
      continue;
    }
    PVector a = pts.get(i - 1);
    PVector b = pts.get(i);
    PVector c = pts.get(i + 1);
    out.add(new PVector(a.x * 0.22 + b.x * 0.56 + c.x * 0.22, a.y * 0.22 + b.y * 0.56 + c.y * 0.22));
  }
  return out;
}

ArrayList<PVector> reamostrarContornoNormal(ArrayList<PVector> pts, float step) {
  ArrayList<PVector> out = new ArrayList<PVector>();
  if (pts == null || pts.size() == 0) return out;
  for (int i = 0; i < pts.size(); i++) {
    PVector a = pts.get(i);
    PVector b = pts.get((i + 1) % pts.size());
    float d = max(0.001, PVector.dist(a, b));
    int cuts = max(1, ceil(d / max(0.001, step)));
    for (int k = 0; k < cuts; k++) {
      float t = k / float(cuts);
      out.add(PVector.lerp(a, b, t));
    }
  }
  return out;
}

ArrayList<PVector> suavizarContornoNormal(ArrayList<PVector> pts) {
  ArrayList<PVector> out = new ArrayList<PVector>();
  int n = pts.size();
  for (int i = 0; i < n; i++) {
    PVector a = pts.get((i - 1 + n) % n);
    PVector b = pts.get(i);
    PVector c = pts.get((i + 1) % n);
    out.add(new PVector(a.x * 0.22 + b.x * 0.56 + c.x * 0.22, a.y * 0.22 + b.y * 0.56 + c.y * 0.22));
  }
  return out;
}

boolean renderBrandOriginalNormalWarp(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || brand.sourceImage == null || params == null) return false;
  PImage img = brand.sourceImage;
  if (img.width <= 1 || img.height <= 1) return false;
  if (img.pixels == null || img.pixels.length == 0) img.loadPixels();

  float unit = max(img.width, img.height) / 500.0;
  float volume = audio != null ? audio.volume : 0;
  float energy = audio != null ? audio.energy : 0;
  float bass = audio != null ? constrain(audio.bass * 1.35 * params.bassInfluence, 0, 1.8) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.25 * params.midInfluence, 0, 1.8) : 0;
  float treble = audio != null ? constrain(audio.treble * 1.1 * params.trebleInfluence, 0, 1.8) : 0;
  float drive = constrain(max(max(energy, volume * 0.62), max(bass * 0.50, max(mid * 0.42, treble * 0.30))) * params.intensity, 0, 1.8);
  float flowTime = noiseDynamicTime + drive * 0.10;

  int longCells = constrain(round(132 + params.complexity * 56 + params.solidness * 24), 120, 230);
  int cols;
  int rows;
  if (img.width >= img.height) {
    cols = longCells;
    rows = constrain(round(longCells * img.height / float(img.width)), 18, 120);
  } else {
    rows = longCells;
    cols = constrain(round(longCells * img.width / float(img.height)), 18, 120);
  }

  float alpha = 255 * constrain(params.opacityAmount, 0, 1);
  pg.pushStyle();
  pg.colorMode(RGB, 255, 255, 255, 255);
  pg.noStroke();
  pg.textureMode(IMAGE);
  int tintColor = corMarcaRender(params, false);
  pg.tint(red(tintColor), green(tintColor), blue(tintColor), alpha);

  for (int y = 0; y < rows; y++) {
    float v0 = map(y, 0, rows, 0, img.height);
    float v1 = map(y + 1, 0, rows, 0, img.height);
    pg.beginShape(QUADS);
    pg.texture(img);
    for (int x = 0; x < cols; x++) {
      float u0 = map(x, 0, cols, 0, img.width);
      float u1 = map(x + 1, 0, cols, 0, img.width);
      vertexNormalWarp(pg, brand, params, img, u0, v0, drive, bass, mid, treble, unit, flowTime, fit);
      vertexNormalWarp(pg, brand, params, img, u1, v0, drive, bass, mid, treble, unit, flowTime, fit);
      vertexNormalWarp(pg, brand, params, img, u1, v1, drive, bass, mid, treble, unit, flowTime, fit);
      vertexNormalWarp(pg, brand, params, img, u0, v1, drive, bass, mid, treble, unit, flowTime, fit);
    }
    pg.endShape();
  }

  pg.noTint();
  pg.popStyle();
  return true;
}

void vertexNormalWarp(PGraphics pg, MutableBrand brand, MutationParams params, PImage img, float u, float v, float drive, float bass, float mid, float treble, float unit, float flowTime, float fit) {
  PVector normal = normalFromImageAlpha(img, u, v);
  float ox = u - img.width * 0.5;
  float oy = v - img.height * 0.5;
  if (normal == null) {
    pg.vertex(ox, oy, u, v);
    return;
  }

  float localAlpha = alphaFromImage(img, round(u), round(v)) / 255.0;
  float edge = constrain(1.0 - abs(localAlpha - 0.50) * 2.0, 0, 1);
  float edgeOnly = smoothstepNormal(0.08, 0.88, edge);
  float noiseScale = constrain(0.007 + params.noiseAmount * 0.003, 0.005, 0.02);
  float nA = noise(u * noiseScale + 11.0, v * noiseScale + 23.0, flowTime * 0.34);
  float nB = noise(u * noiseScale + 13.0, v * noiseScale + 29.0, flowTime * 0.34);
  float nC = noise(u * noiseScale * 0.55 + 81.0, v * noiseScale * 0.55 + 19.0, flowTime * 0.22);
  float smoothNoise = map((nA + nB + nC) / 3.0, 0, 1, -1, 1);

  float displacementStrength = constrain(10.0 + drive * 9.5 + bass * 4.0 + mid * 2.0, 10.0, 25.0) / max(0.001, fit);
  float maxVertexOffset = constrain(12.0 + drive * 10.0 + bass * 4.0, 12.0, 30.0) / max(0.001, fit);
  float breath = sin(flowTime * 3.2 + u * 0.006 + v * 0.004) * 0.32;
  float organicWave = sin(flowTime * 2.1 + u * 0.003 - v * 0.005 + smoothNoise) * 0.22;
  float normalMove = constrain((smoothNoise * 0.82 + breath + organicWave) * displacementStrength * edgeOnly, -maxVertexOffset, maxVertexOffset);

  float tangentNoise = map(noise(u * noiseScale * 0.7 + 43.0, v * noiseScale * 0.7 + 71.0, flowTime * 0.18), 0, 1, -1, 1);
  float tangentMove = constrain(tangentNoise * displacementStrength * 0.28 * edgeOnly, -maxVertexOffset * 0.32, maxVertexOffset * 0.32);
  float tx = -normal.y;
  float ty = normal.x;

  float px = ox + normal.x * normalMove + tx * tangentMove;
  float py = oy + normal.y * normalMove + ty * tangentMove;
  pg.vertex(px, py, u, v);
}

float smoothstepNormal(float edge0, float edge1, float x) {
  float t = constrain((x - edge0) / max(0.0001, edge1 - edge0), 0, 1);
  return t * t * (3.0 - 2.0 * t);
}

PVector normalFromImageAlpha(PImage img, float u, float v) {
  int x = constrain(round(u), 1, img.width - 2);
  int y = constrain(round(v), 1, img.height - 2);
  int r = max(2, round(max(img.width, img.height) * 0.0035));
  float left = alphaFromImage(img, x - r, y);
  float right = alphaFromImage(img, x + r, y);
  float up = alphaFromImage(img, x, y - r);
  float down = alphaFromImage(img, x, y + r);
  PVector normal = new PVector(left - right, up - down);
  if (normal.mag() < 0.001) return null;
  normal.normalize();
  return normal;
}

float alphaFromImage(PImage img, int x, int y) {
  x = constrain(x, 0, img.width - 1);
  y = constrain(y, 0, img.height - 1);
  return (img.pixels[y * img.width + x] >>> 24) & 0xFF;
}

void renderBrandOriginalNormalSurface(PGraphics pg, MutableBrand brand, MutationParams params, float fit, float alpha) {
  if (brand == null || !brand.hasPointData) return;

  pg.pushStyle();
  pg.noFill();
  applyBrandColor(pg, params, alpha, false, false);
  float solid = constrain(params.solidness, 0, 1);
  float bass = audioData != null ? constrain(audioData.bass * 1.35 * params.bassInfluence, 0, 1.8) : 0;
  float mid = audioData != null ? constrain(audioData.mid * 1.25 * params.midInfluence, 0, 1.8) : 0;
  float treble = audioData != null ? constrain(audioData.treble * 1.1 * params.trebleInfluence, 0, 1.8) : 0;
  float stroke = max(0.45, (brand.currentStroke * 0.52 + bass * params.strokeAmount * 0.22 + treble * 0.45) / max(0.001, fit));
  pg.strokeWeight(stroke);

  ArrayList<PVector> pontos = brand.currentPoints;
  int stride = max(1, (int) ceil(pontos.size() / max(450, brand.maxRenderPoints * lerp(0.45, 0.90, solid))));
  for (int i = 0; i < pontos.size(); i += stride) {
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer == 2 && solid < 0.58 && i % 5 != 0) continue;

    PVector p = pontos.get(i);
    PVector o = brand.originalPoints.get(i);
    float dx = p.x - o.x;
    float dy = p.y - o.y;
    float moveMag = sqrt(dx * dx + dy * dy);
    if (moveMag < 0.05 && (bass + mid + treble) < 0.05) continue;

    float a = atan2(dy, dx);
    if (moveMag < 0.05) {
      a = noise(o.x * 0.012, o.y * 0.012, semente) * TWO_PI;
    }
    float len = max(0.8, (1.2 + moveMag * 0.18 + bass * 3.2 + mid * 1.8) / max(0.001, fit));
    if (layer == 0) len *= 1.25;
    if (layer == 2) len *= lerp(0.40, 0.85, solid);

    pg.line(p.x - brand.center.x - cos(a) * len, p.y - brand.center.y - sin(a) * len,
            p.x - brand.center.x + cos(a) * len, p.y - brand.center.y + sin(a) * len);
  }
  pg.popStyle();
}

void renderBrandOrganicMass(PGraphics pg, MutableBrand brand, MutationParams params, float fit, boolean currentSet, float alpha) {
  pg.pushStyle();
  pg.noStroke();
  applyBrandColor(pg, params, alpha, true, !currentSet);

  ArrayList<PVector> pontos = currentSet ? brand.currentPoints : brand.originalPoints;
  float solid = constrain(params.solidness, 0, 1);
  int stride = max(1, (int) ceil(pontos.size() / max(280, brand.maxRenderPoints * lerp(0.50, 1.18, solid))));
  float energy = audioData != null ? audioData.energy : 0;
  float bass = audioData != null ? constrain(audioData.bass * 1.35, 0, 1.4) : 0;
  float mid = audioData != null ? constrain(audioData.mid * 1.25, 0, 1.4) : 0;
  float treble = audioData != null ? constrain(audioData.treble * 1.1, 0, 1.4) : 0;
  float d = max(1.2, (3.4 + brand.currentStroke * 1.35 + bass * 5.2 + energy * 3.4 + solid * 2.6) / max(0.001, fit));

  for (int i = 0; i < pontos.size(); i += stride) {
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer == 2 && solid < 0.38 && i % 3 != 0) continue;
    if (layer == 1 && solid < 0.20 && i % 2 != 0) continue;
    PVector p = pontos.get(i);
    float a = noise(i * 0.071, semente * 0.9) * TWO_PI + mid * sin(semente * 5.0 + i * 0.03);
    float local = 0.78 + 0.34 * noise(i * 0.047, semente * 1.4);
    float layerBoost = layer == 0 ? 1.05 : (layer == 2 ? lerp(0.68, 1.30, solid) : 1.04);
    float stretch = (1.08 + mid * 0.82 + treble * 0.18 + solid * 0.20) * local * layerBoost;
    float squash = (0.82 + bass * 0.22 + solid * 0.16) * layerBoost;
    pg.pushMatrix();
    pg.translate(p.x - brand.center.x, p.y - brand.center.y);
    pg.rotate(a);
    pg.ellipse(0, 0, d * stretch, d * squash);
    pg.popMatrix();
  }
  pg.popStyle();
}

void renderBrandLiquid(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || !brand.hasPointData) return;

  pg.pushStyle();
  pg.noFill();
  pg.strokeCap(ROUND);
  float bass = audio != null ? constrain(audio.bass * 1.35 * params.bassInfluence, 0, 1.8) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.25 * params.midInfluence, 0, 1.8) : 0;
  float treble = audio != null ? constrain(audio.treble * 1.1 * params.trebleInfluence, 0, 1.8) : 0;
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.34, 0, 1.45) : 0;
  float span = max(1, brand.span());
  float t = noiseDynamicTime * (0.34 + params.transformSpeed * 0.12 + mid * 0.12);
  int seedCount = constrain(round(34 + params.complexity * 74 + energy * 38), 28, 150);
  int pointCount = max(1, brand.currentPoints.size());
  float stepLen = max(2.2, span * (0.010 + params.noiseAmount * 0.004 + mid * 0.004) / max(0.001, fit));
  float weightBase = max(0.22, (0.34 + bass * 0.42) / max(0.001, fit));

  renderBrandRasterStrokes(pg, brand, params, fit, true, 7 + energy * 10);

  for (int pass = 0; pass < 3; pass++) {
    boolean secondary = pass == 1;
    float passAlpha = pass == 0 ? 34 + energy * 22 : (pass == 1 ? 46 + mid * 34 : 22 + treble * 24);
    applyBrandColor(pg, params, passAlpha, false, secondary);
    pg.strokeWeight(weightBase * (pass == 0 ? 1.25 : (pass == 1 ? 0.75 : 0.42)));

    int lines = max(8, seedCount - pass * 16);
    for (int s = 0; s < lines; s++) {
      int idx = floor(hash1D(s * 37.0 + pass * 101.0 + floor(semente * 23.0), 44.0) * pointCount);
      PVector start = brand.currentPoints.get(idx);
      PVector origin = brand.originalPoints.get(idx);
      int layer = brand.pointLayer.size() > idx ? brand.pointLayer.get(idx) : 1;
      if (layer == 2 && params.solidness < 0.45 && s % 4 != 0) continue;

      float x = start.x - brand.center.x;
      float y = start.y - brand.center.y;
      float ox = origin.x - brand.center.x;
      float oy = origin.y - brand.center.y;
      int steps = constrain(round(8 + params.complexity * 14 + mid * 8 + energy * 5), 7, 30);
      pg.beginShape();
      for (int k = 0; k < steps; k++) {
        float n = noise((ox + x) * 0.006 + pass * 19.0, (oy + y) * 0.006 + 71.0, t + k * 0.018);
        float n2 = noise((ox + x) * 0.017 + 13.0, (oy + y) * 0.017 + pass * 23.0, t * 1.2);
        float angle = n * TWO_PI * (1.65 + params.noiseAmount * 0.36) + (n2 - 0.5) * PI * (0.75 + treble * 0.55);
        float breath = 0.78 + bass * 0.18 + sin(t * 5.0 + s * 0.31 + k * 0.18) * treble * 0.08;
        pg.curveVertex(x, y);
        x += cos(angle) * stepLen * breath;
        y += sin(angle) * stepLen * breath;
        if (x < -span * 0.72 || x > span * 0.72 || y < -span * 0.72 || y > span * 0.72) break;
      }
      pg.endShape();
    }
  }

  pg.popStyle();
}

void renderBrandPerlinGossamer(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || brand.originalPoints == null || brand.originalPoints.size() == 0) return;

  pg.pushStyle();
  pg.noFill();
  pg.strokeCap(ROUND);
  pg.strokeJoin(ROUND);

  float span = max(1, brand.span());
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.28, 0, 1.2) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.1, 0, 1.2) : 0;
  float t = noiseDynamicTime * (0.18 + params.transformSpeed * 0.035);

  float hairCount = constrain(120 + params.complexity * 360, 90, 520);
  float hairLength = span * constrain(0.075 + params.displacementAmount * 0.0018, 0.07, 0.22);
  float noiseScale = 0.0065 + params.noiseAmount * 0.0035;
  float hairWeight = constrain(0.22 + params.strokeAmount * 0.035, 0.2, 1.2) / max(0.001, fit);
  float lineAlpha = constrain(18 + params.opacityAmount * 30, 14, 42);
  int densityLimit = 3;
  float curlStrength = 1.15 + params.noiseAmount * 0.85 + mid * 0.22;
  float maxDrift = span * 0.050;

  float cell = max(10, span * 0.055);
  int cols = max(3, ceil(span * 1.25 / cell));
  int rows = cols;
  int[] densityGrid = new int[cols * rows];
  float gridOrigin = -span * 0.625;

  int pointCount = brand.originalPoints.size();
  int attempts = min(pointCount, int(hairCount * 5.0));
  int drawn = 0;

  applyBrandColor(pg, params, lineAlpha, false, false);
  pg.strokeWeight(hairWeight);

  for (int a = 0; a < attempts && drawn < hairCount; a++) {
    int idx = floor(hash1D(a * 37.17 + floor(semente * 11.0), 91.0) * pointCount);
    idx = constrain(idx, 0, pointCount - 1);
    int layer = brand.pointLayer.size() > idx ? brand.pointLayer.get(idx) : 1;
    if (layer == 2 && hash1D(idx, 17.0) > 0.18) continue;

    PVector origin = brand.originalPoints.get(idx);
    float sx = origin.x - brand.center.x;
    float sy = origin.y - brand.center.y;
    int gx = floor((sx - gridOrigin) / cell);
    int gy = floor((sy - gridOrigin) / cell);
    if (gx < 0 || gy < 0 || gx >= cols || gy >= rows) continue;
    int gi = gy * cols + gx;
    if (densityGrid[gi] >= densityLimit) continue;
    densityGrid[gi]++;

    float localLength = hairLength * (0.62 + hash1D(idx, 23.0) * 0.72);
    int steps = constrain(round(localLength / max(1.6, span * 0.010)), 8, 26);
    float stepLen = localLength / max(1, steps);
    float x = sx;
    float y = sy;
    float prevX = x;
    float prevY = y;
    float directionBias = hash1D(idx, 71.0) > 0.5 ? 1.0 : -1.0;

    for (int k = 0; k < steps; k++) {
      float nx = (x + brand.center.x) * noiseScale;
      float ny = (y + brand.center.y) * noiseScale;
      float n = noise(nx + 17.0, ny + 41.0, t + k * 0.018);
      float n2 = noise(nx * 2.1 + 83.0, ny * 2.1 + 9.0, t * 0.72);
      float angle = n * TWO_PI * curlStrength + (n2 - 0.5) * PI * 0.32;
      angle += directionBias * 0.22;
      x += cos(angle) * stepLen;
      y += sin(angle) * stepLen;

      if (dist(x, y, sx, sy) > maxDrift + localLength) break;
      if (!pontoPertoDaMarcaGossamer(brand, x + brand.center.x, y + brand.center.y, span * 0.040)) break;

      pg.line(prevX, prevY, x, y);
      prevX = x;
      prevY = y;
    }
    drawn++;
  }

  renderBrandGossamerMesh(pg, brand, params, fit, lineAlpha * 0.42, span);
  pg.popStyle();
}

void renderBrandGossamerMesh(PGraphics pg, MutableBrand brand, MutationParams params, float fit, float alphaLine, float span) {
  int pointCount = brand.originalPoints.size();
  int pointTarget = constrain(round(80 + params.complexity * 180), 60, 260);
  int stride = max(1, pointCount / pointTarget);
  float connectionDistance = span * constrain(0.040 + params.complexity * 0.018, 0.035, 0.075);
  float maxDisplacement = span * constrain(0.002 + params.noiseAmount * 0.003, 0.0015, 0.007);
  float noiseScale = 0.012 + params.noiseAmount * 0.003;
  float t = noiseDynamicTime * 0.12;

  applyBrandColor(pg, params, alphaLine, false, true);
  pg.strokeWeight(constrain(0.18 + params.strokeAmount * 0.018, 0.2, 0.8) / max(0.001, fit));

  for (int i = 0; i < pointCount; i += stride) {
    PVector a = brand.originalPoints.get(i);
    int layerA = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layerA == 2 && i % 4 != 0) continue;
    float ax = a.x - brand.center.x;
    float ay = a.y - brand.center.y;
    float na = noise(a.x * noiseScale, a.y * noiseScale, t) * TWO_PI;
    ax += cos(na) * maxDisplacement;
    ay += sin(na) * maxDisplacement;

    int links = 0;
    for (int j = i + stride; j < min(pointCount, i + stride * 18) && links < 2; j += stride) {
      PVector b = brand.originalPoints.get(j);
      if (brand.breakBefore.size() > j && brand.breakBefore.get(j) && PVector.dist(a, b) > connectionDistance * 0.55) continue;
      float d = PVector.dist(a, b);
      if (d <= 0.001 || d > connectionDistance) continue;
      float bx = b.x - brand.center.x;
      float by = b.y - brand.center.y;
      float nb = noise(b.x * noiseScale, b.y * noiseScale, t) * TWO_PI;
      bx += cos(nb) * maxDisplacement;
      by += sin(nb) * maxDisplacement;
      pg.line(ax, ay, bx, by);
      links++;
    }
  }
}

boolean pontoPertoDaMarcaGossamer(MutableBrand brand, float x, float y, float maxDist) {
  int total = brand.originalPoints.size();
  int stride = max(1, total / 120);
  float maxD2 = maxDist * maxDist;
  for (int i = 0; i < total; i += stride) {
    PVector p = brand.originalPoints.get(i);
    float dx = x - p.x;
    float dy = y - p.y;
    if (dx * dx + dy * dy <= maxD2) return true;
  }
  return false;
}

void renderBrandGoo(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null) return;
  if (renderBrandMaskDisplacement(pg, brand, params, fit, audio, true)) return;
  renderBrandOriginalClean(pg, brand, params, fit);
}

void renderBrandGooSoftSurface(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null) return;

  pg.pushStyle();
  pg.blendMode(BLEND);
  pg.noStroke();

  float bass = audio != null ? constrain(audio.bass * 1.35 * params.bassInfluence, 0, 1.7) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.12 * params.midInfluence, 0, 1.4) : 0;
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.28, 0, 1.3) : 0;
  float span = max(1, brand.span());
  float t = noiseDynamicTime * (0.12 + params.transformSpeed * 0.035);
  float blobStrength = span * constrain(0.030 + params.deformationAmount * 0.00034 + bass * 0.018 + energy * 0.012, 0.026, 0.095);
  float surfaceTension = 0.82;
  float noiseScale = constrain(0.005 + params.noiseAmount * 0.0025, 0.005, 0.014);
  float viscosity = 0.86;
  float maxDeformation = span * constrain(0.035 + bass * 0.020 + energy * 0.012, 0.030, 0.085);

  renderBrandGooBase(pg, brand, params, 68, 1.0 + bass * 0.020, false);
  renderBrandGooContours(pg, brand, params, fit, blobStrength, maxDeformation, noiseScale, viscosity, surfaceTension, t, 0);
  renderBrandGooContours(pg, brand, params, fit, blobStrength * 0.62, maxDeformation * 0.52, noiseScale * 0.76, viscosity, surfaceTension, t + 19.0, 1);
  renderBrandGooBase(pg, brand, params, 100, 1.0 + bass * 0.006, false);
  renderBrandGooBase(pg, brand, params, 30 + mid * 14, 1.0 + energy * 0.010, true);

  pg.popStyle();
}

void renderBrandGooBase(PGraphics pg, MutableBrand brand, MutationParams params, float alpha, float scaleValue, boolean secondary) {
  pg.pushMatrix();
  pg.scale(scaleValue);
  applyBrandColor(pg, params, alpha, true, secondary);
  pg.noStroke();
  if (brand.sourceShape != null) {
    brand.sourceShape.disableStyle();
    pg.shapeMode(CORNER);
    pg.shape(brand.sourceShape, -brand.center.x, -brand.center.y);
    brand.sourceShape.enableStyle();
  } else if (brand.sourceImage != null) {
    int c = corMarcaRender(params, secondary);
    pg.pushStyle();
    pg.colorMode(RGB, 255, 255, 255, 255);
    pg.imageMode(CENTER);
    pg.tint(red(c), green(c), blue(c), alpha * constrain(params.opacityAmount, 0, 1));
    pg.image(brand.sourceImage, 0, 0);
    pg.noTint();
    pg.popStyle();
  }
  pg.popMatrix();
}

void renderBrandGooContours(PGraphics pg, MutableBrand brand, MutationParams params, float fit, float blobStrength, float maxDeformation, float noiseScale, float viscosity, float surfaceTension, float t, int pass) {
  if (brand.originalPoints == null || brand.originalPoints.size() == 0) return;
  applyBrandColor(pg, params, pass == 0 ? 54 : 28, true, pass == 1);
  pg.noStroke();
  ArrayList<PVector> contour = new ArrayList<PVector>();
  for (int i = 0; i < brand.originalPoints.size(); i++) {
    boolean starts = brand.breakBefore != null && brand.breakBefore.size() > i && brand.breakBefore.get(i);
    if (starts && contour.size() > 3) {
      desenharContornoGosmaContinuo(pg, brand, contour, blobStrength, maxDeformation, noiseScale, viscosity, surfaceTension, t, pass);
      contour.clear();
    }
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer <= 1) contour.add(brand.originalPoints.get(i).copy());
  }
  if (contour.size() > 3) desenharContornoGosmaContinuo(pg, brand, contour, blobStrength, maxDeformation, noiseScale, viscosity, surfaceTension, t, pass);
}

void desenharContornoGosmaContinuo(PGraphics pg, MutableBrand brand, ArrayList<PVector> contour, float blobStrength, float maxDeformation, float noiseScale, float viscosity, float surfaceTension, float t, int pass) {
  ArrayList<PVector> dense = reamostrarContornoNormal(contour, max(1.8, brand.span() * 0.008));
  for (int iter = 0; iter < 7; iter++) dense = suavizarContornoNormal(dense);
  if (dense.size() < 4) return;

  pg.beginShape();
  int n = dense.size();
  for (int extra = -3; extra < n + 3; extra++) {
    int i = (extra + n) % n;
    PVector p = dense.get(i);
    PVector prev = dense.get((i - 1 + n) % n);
    PVector next = dense.get((i + 1) % n);
    PVector tangent = PVector.sub(next, prev);
    if (tangent.mag() < 0.001) tangent.set(1, 0);
    tangent.normalize();
    PVector normal = new PVector(-tangent.y, tangent.x);
    PVector outward = PVector.sub(p, brand.center);
    if (outward.mag() > 0.001 && normal.dot(outward) < 0) normal.mult(-1);

    float n1 = noise(p.x * noiseScale + pass * 17.0, p.y * noiseScale + 31.0, t * viscosity);
    float n2 = noise(p.x * noiseScale * 0.48 + 71.0, p.y * noiseScale * 0.48 + pass * 23.0, t * viscosity * 0.62);
    float surface = lerp(n1, n2, 1.0 - surfaceTension);
    float deformation = constrain((surface - 0.42) * maxDeformation, -maxDeformation * 0.35, maxDeformation);
    float pulse = sin(t * 2.4 + p.x * 0.006 - p.y * 0.004 + pass) * maxDeformation * 0.10;
    float offset = blobStrength * (0.44 + n1 * 0.36) + deformation + pulse;
    pg.curveVertex(p.x - brand.center.x + normal.x * offset, p.y - brand.center.y + normal.y * offset);
  }
  pg.endShape(CLOSE);
}

void renderLiquidSoberSilhouette(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || brand.sourceImage == null) return;

  pg.pushStyle();
  pg.pushMatrix();
  pg.colorMode(RGB, 255, 255, 255, 255);
  pg.blendMode(BLEND);
  pg.imageMode(CENTER);

  float bass = audio != null ? constrain(audio.bass * 1.35, 0, 1.6) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.25, 0, 1.6) : 0;
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.28, 0, 1.2) : 0;
  float t = noiseDynamicTime * 0.55;
  float breathe = 1.0 + bass * params.scaleAmount * 0.10 + energy * 0.010;

  pg.scale(breathe);
  for (int pass = 0; pass < 3; pass++) {
    float a = t * (1.1 + pass * 0.23) + pass * TWO_PI / 3.0;
    float offset = (pass == 0 ? 0 : (0.65 + pass * 0.45 + mid * 1.2)) / max(0.001, fit);
    float ox = cos(a) * offset;
    float oy = sin(a * 0.87) * offset;
    float alpha = (pass == 0 ? 128 : (pass == 1 ? 48 : 26)) * params.opacityAmount;
    int c = corMarcaRender(params, pass != 0);
    pg.tint(red(c), green(c), blue(c), alpha);
    pg.image(brand.sourceImage, ox, oy);
  }

  pg.noTint();
  pg.popMatrix();
  pg.popStyle();
}

boolean renderLiquidContinuousSurface(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || brand.sourceImage == null) return false;
  PImage img = brand.sourceImage;
  if (img.width <= 1 || img.height <= 1) return false;
  if (img.pixels == null || img.pixels.length == 0) img.loadPixels();

  pg.pushStyle();
  pg.colorMode(RGB, 255, 255, 255, 255);
  float solid = constrain(params.solidness, 0, 1);
  float bass = audio != null ? constrain(audio.bass * 1.35, 0, 1.6) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.25, 0, 1.6) : 0;
  float treble = audio != null ? constrain(audio.treble * 1.1, 0, 1.6) : 0;
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.35, 0, 1.35) : 0;
  float t = noiseDynamicTime * 0.42 + energy * 0.12;
  float unit = max(img.width, img.height) / 500.0;
  int longCells = constrain(round(74 + params.complexity * 38 + solid * 18), 58, 136);
  int cols;
  int rows;
  if (img.width >= img.height) {
    cols = longCells;
    rows = constrain(round(longCells * img.height / float(img.width)), 16, 112);
  } else {
    rows = longCells;
    cols = constrain(round(longCells * img.width / float(img.height)), 16, 112);
  }

  pg.blendMode(BLEND);
  pg.noStroke();
  pg.textureMode(IMAGE);
  int surfaceColor = corMarcaRender(params, false);
  pg.tint(red(surfaceColor), green(surfaceColor), blue(surfaceColor), (150 + solid * 42) * params.opacityAmount);

  for (int y = 0; y < rows; y++) {
    float v0 = map(y, 0, rows, 0, img.height);
    float v1 = map(y + 1, 0, rows, 0, img.height);
    pg.beginShape(QUADS);
    pg.texture(img);
    for (int x = 0; x < cols; x++) {
      float u0 = map(x, 0, cols, 0, img.width);
      float u1 = map(x + 1, 0, cols, 0, img.width);
      vertexLiquidSurface(pg, img, u0, v0, params, bass, mid, treble, energy, unit, t);
      vertexLiquidSurface(pg, img, u1, v0, params, bass, mid, treble, energy, unit, t);
      vertexLiquidSurface(pg, img, u1, v1, params, bass, mid, treble, energy, unit, t);
      vertexLiquidSurface(pg, img, u0, v1, params, bass, mid, treble, energy, unit, t);
    }
    pg.endShape();
  }

  pg.noTint();
  pg.popStyle();
  return true;
}

void vertexLiquidSurface(PGraphics pg, PImage img, float u, float v, MutationParams params, float bass, float mid, float treble, float energy, float unit, float t) {
  PVector normal = normalFromImageAlpha(img, u, v);
  float ox = u - img.width * 0.5;
  float oy = v - img.height * 0.5;
  if (normal == null) {
    normal = new PVector(ox, oy);
    if (normal.mag() < 0.001) normal.set(1, 0);
    normal.normalize();
  }

  float alpha = alphaFromImage(img, round(u), round(v)) / 255.0;
  float edge = constrain(1.0 - abs(alpha - 0.50) * 2.0, 0, 1);
  float flowA = noise(u * 0.006 + 18.0, v * 0.005 + 42.0, t * 0.80);
  float flowB = noise(u * 0.014 + 61.0, v * 0.010 + 7.0, t * 1.16);
  float wave = sin(u * 0.010 + v * 0.006 + t * 5.2 + flowB * 1.2);
  float inflate = bass * params.strokeAmount * 2.6 * unit;
  float viscosity = mid * params.deformationAmount * 0.78 * unit * (flowA - 0.5);
  float fine = treble * params.visualNoiseAmount * 0.55 * unit * (flowB - 0.5);
  float move = (inflate + viscosity + fine + wave * mid * 0.85 * unit) * (0.18 + edge * 0.62 + alpha * 0.20) * constrain(params.intensity, 0, 2.0);
  float tangent = sin(t * 2.5 + u * 0.008 - v * 0.005) * mid * 0.45 * unit * edge;
  float tx = -normal.y;
  float ty = normal.x;
  pg.vertex(ox + normal.x * move + tx * tangent, oy + normal.y * move + ty * tangent, u, v);
}

void renderLiquidFlowLines(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  pg.pushStyle();
  pg.colorMode(RGB, 255, 255, 255, 255);
  pg.noFill();
  float bass = audio != null ? constrain(audio.bass * 1.35, 0, 1.6) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.25, 0, 1.6) : 0;
  int stride = max(1, (int) ceil(brand.currentPoints.size() / max(360, brand.maxRenderPoints * 0.28)));
  float alpha = (12 + bass * 10 + mid * 8) * params.opacityAmount;
  pg.stroke(84, 142, 164, alpha);
  pg.strokeWeight(max(0.22, (0.34 + bass * 0.34) / max(0.001, fit)));
  pg.strokeCap(ROUND);

  for (int i = 0; i < brand.currentPoints.size(); i += stride) {
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer == 2 && i % 8 != 0) continue;
    PVector p = brand.currentPoints.get(i);
    PVector o = brand.originalPoints.get(i);
    float dx = o.x - brand.center.x;
    float dy = o.y - brand.center.y;
    float a = atan2(dy, dx) + HALF_PI + sin(noiseDynamicTime * 2.2 + i * 0.029) * (0.12 + mid * 0.08);
    float len = max(0.45, (0.75 + mid * 1.55) / max(0.001, fit));
    pg.line(p.x - brand.center.x - cos(a) * len, p.y - brand.center.y - sin(a) * len,
            p.x - brand.center.x + cos(a) * len, p.y - brand.center.y + sin(a) * len);
  }
  pg.popStyle();
}

void renderBrandReferenceShape(PGraphics pg, MutableBrand brand, MutationParams params, float fit, float alpha, AudioData audio) {
  if (brand == null || brand.sourceShape == null) return;

  pg.pushStyle();
  pg.shapeMode(CORNER);
  brand.sourceShape.disableStyle();
  pg.noFill();
  applyBrandColor(pg, params, min(100, alpha + audio.energy * 26), false, false);
  pg.strokeWeight(max(0.7, (brand.currentStroke * 0.65) / max(0.001, fit)));
  pg.shape(brand.sourceShape, -brand.center.x, -brand.center.y);
  brand.sourceShape.enableStyle();
  pg.popStyle();
}

void renderBrandRasterReference(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || brand.sourceImage == null) return;

  pg.pushStyle();
  pg.pushMatrix();
  pg.colorMode(RGB, 255, 255, 255, 255);
  pg.imageMode(CENTER);
  float bassDrive = constrain(audio.bass * 1.35, 0, 1.4);
  float midDrive = constrain(audio.mid * 1.25, 0, 1.4);
  float trebleDrive = constrain(audio.treble * 1.1, 0, 1.4);
  float modePulse = 1.0;
  if (params.mode == 1) modePulse += (audio.volume + bassDrive) * params.scaleAmount * 1.35;
  if (params.mode == 4) modePulse += (audio.energy + bassDrive) * params.deformationAmount * 0.0024;
  if (params.mode == 10) modePulse += sin(semente * 14.0) * (audio.energy + midDrive) * 0.025;
  float jitterX = 0;
  float jitterY = 0;
  if (params.mode == 0 || params.mode == 3) {
    jitterX = sin(semente * 18.0) * midDrive * params.deformationAmount * 0.018 / max(0.001, fit);
    jitterY = cos(semente * 16.0) * trebleDrive * params.deformationAmount * 0.012 / max(0.001, fit);
  }
  pg.translate(jitterX, jitterY);
  pg.scale(modePulse);
  int c = corMarcaRender(params, false);
  pg.tint(red(c), green(c), blue(c), 175 + audio.energy * 80);
  pg.image(brand.sourceImage, 0, 0);
  pg.noTint();
  pg.popMatrix();
  pg.popStyle();
}

void applyBrandColor(PGraphics pg, MutationParams params, float alpha, boolean fillMode, boolean secondary) {
  int c = corMarcaRender(params, secondary);
  float baseS = saturation(c);
  float baseB = brightness(c);
  boolean corTravada = marcaPaletaTravada || baseS < 0.5 || baseB < 0.5 || baseB > 99.5;
  float h = corTravada ? hue(c) : (hue(c) + params.hueAmount + semente * params.hueAmount * 0.08) % 360;
  if (h < 0) h += 360;
  float s = corTravada ? baseS : constrain(baseS * params.saturationAmount, 0, 100);
  float b = baseB;
  float a = alpha * constrain(params.opacityAmount, 0, 1);
  if (fillMode) pg.fill(h, s, b, a);
  else pg.stroke(h, s, b, a);
}

int corMarcaRender(MutationParams params, boolean secondary) {
  if (params == null) return color(0, 0, 100, 100);
  if (marcaPaletaTravada && marcaPaletaCount > 0) {
    int selecionado = constrain(marcaPaletaSlotSelecionado, 0, max(0, marcaPaletaCount - 1));
    int idx = selecionado;
    if (secondary && marcaPaletaCount > 1) idx = (selecionado + 1) % marcaPaletaCount;
    return marcaPaletaCores[constrain(idx, 0, marcaPaletaCores.length - 1)];
  }
  return secondary ? params.secondaryColor : params.primaryColor;
}

void renderBrandFallback(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  pg.pushStyle();
  if (brand.sourceImage != null) {
    pg.colorMode(RGB, 255, 255, 255, 255);
    pg.imageMode(CENTER);
    int c = corMarcaRender(params, false);
    pg.tint(red(c), green(c), blue(c), 90 + audio.energy * 165);
    pg.image(brand.sourceImage, 0, 0);
    pg.noTint();
  } else {
    pg.shapeMode(CORNER);
    brand.sourceShape.disableStyle();
    pg.noFill();
    applyBrandColor(pg, params, 34 + audio.energy * 58, false, false);
    pg.strokeWeight(max(0.5, brand.currentStroke / max(0.001, fit)));
    pg.shape(brand.sourceShape, -brand.center.x, -brand.center.y);
    brand.sourceShape.enableStyle();
  }
  pg.popStyle();
}

void renderBrandConnected(PGraphics pg, MutableBrand brand, MutationParams params, float fit, boolean currentSet, float alpha, int styleMode) {
  if (brand.pointCloudOnly) {
    renderBrandPointDots(pg, brand, params, fit, currentSet, alpha);
    return;
  }
  if (brand.isRaster) {
    renderBrandRasterStrokes(pg, brand, params, fit, currentSet, alpha);
    return;
  }

  pg.pushStyle();
  pg.noFill();
  applyBrandColor(pg, params, alpha, false, !currentSet);
  pg.strokeWeight(max(0.45, brand.currentStroke / max(0.001, fit)));

  ArrayList<PVector> pontos = currentSet ? brand.currentPoints : brand.originalPoints;
  int stride = max(1, (int) ceil(pontos.size() / brand.maxRenderPoints));
  float solid = constrain(params.solidness, 0, 1);
  float breakDistance = brand.span() * 0.035;
  boolean desenhando = false;
  PVector previous = null;
  for (int i = 0; i < pontos.size(); i += stride) {
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer == 2 && solid < 0.50 && i % 4 != 0) continue;
    PVector p = pontos.get(i);
    boolean shouldBreak = brand.breakBefore.get(i) || !desenhando;
    if (!shouldBreak && previous != null && PVector.dist(previous, p) > breakDistance) {
      shouldBreak = true;
    }

    if (shouldBreak) {
      if (desenhando) pg.endShape();
      pg.beginShape();
      desenhando = true;
    }
    pg.vertex(p.x - brand.center.x, p.y - brand.center.y);
    previous = p;
  }
  if (desenhando) pg.endShape();
  pg.popStyle();
}

void renderBrandRasterStrokes(PGraphics pg, MutableBrand brand, MutationParams params, float fit, boolean currentSet, float alpha) {
  pg.pushStyle();
  pg.noFill();
  applyBrandColor(pg, params, alpha, false, !currentSet);
  pg.strokeWeight(max(0.35, brand.currentStroke / max(0.001, fit)));

  ArrayList<PVector> pontos = currentSet ? brand.currentPoints : brand.originalPoints;
  int stride = max(1, (int) ceil(pontos.size() / brand.maxRenderPoints));
  float solid = constrain(params.solidness, 0, 1);
  float energy = audioData != null ? audioData.energy : 0;
  float treble = audioData != null ? audioData.treble : 0;
  float bass = audioData != null ? constrain(audioData.bass * 1.35, 0, 1.4) : 0;
  float len = max(1.2, (2.4 + energy * 6.0 + bass * 7.0 + brand.currentStroke * 1.6) / max(0.001, fit));
  for (int i = 0; i < pontos.size(); i += stride) {
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer == 2 && solid < 0.50 && i % 4 != 0) continue;
    PVector p = pontos.get(i);
    float angle = noise(p.x * 0.015, p.y * 0.015, frameCount * 0.018) * TWO_PI;
    angle += sin(frameCount * 0.12 + i * 0.37) * treble * 1.15;
    float layerLen = layer == 0 ? 1.12 : (layer == 2 ? lerp(0.45, 1.0, solid) : 0.86);
    float dx = cos(angle) * len * layerLen;
    float dy = sin(angle) * len * layerLen;
    pg.line(p.x - brand.center.x - dx, p.y - brand.center.y - dy,
            p.x - brand.center.x + dx, p.y - brand.center.y + dy);
  }
  pg.popStyle();
}

void renderBrandPointDots(PGraphics pg, MutableBrand brand, MutationParams params, float fit, boolean currentSet, float alpha) {
  pg.pushStyle();
  pg.noStroke();
  applyBrandColor(pg, params, alpha, true, !currentSet);

  ArrayList<PVector> pontos = currentSet ? brand.currentPoints : brand.originalPoints;
  int stride = max(1, (int) ceil(pontos.size() / brand.maxRenderPoints));
  float energy = audioData != null ? audioData.energy : 0;
  float bass = audioData != null ? constrain(audioData.bass * 1.35, 0, 1.4) : 0;
  float treble = audioData != null ? constrain(audioData.treble * 1.1, 0, 1.4) : 0;
  float solid = constrain(params.solidness, 0, 1);
  float dot = max(0.9, (1.2 + brand.currentStroke * 0.85 + energy * 2.1 + bass * 2.8 + treble * 1.5) / max(0.001, fit));
  for (int i = 0; i < pontos.size(); i += stride) {
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer == 2 && solid < 0.42 && i % 4 != 0) continue;
    PVector p = pontos.get(i);
    float organicJitter = max(0.15, dot * 0.32);
    float jx = map(noise(i * 0.113, semente * 0.7), 0, 1, -organicJitter, organicJitter);
    float jy = map(noise(i * 0.097, 70.0 + semente * 0.7), 0, 1, -organicJitter, organicJitter);
    float layerPulse = layer == 0 ? 1.08 : (layer == 2 ? lerp(0.42, 1.08, solid) : 0.86);
    float pulse = (0.72 + 0.26 * noise(i * 0.041, semente * 1.2) + bass * 0.18 + treble * 0.08) * layerPulse;
    pg.ellipse(p.x - brand.center.x + jx, p.y - brand.center.y + jy, dot * pulse, dot * pulse);
  }
  pg.popStyle();
}

void renderBrandParticles(PGraphics pg, MutableBrand brand, MutationParams params, float fit, float seedValue, AudioData audio) {
  pg.pushStyle();
  pg.noStroke();
  float dot = max(1.4, (2.2 + audio.energy * 3.0 + audio.bass * 4.5 + audio.treble * 2.8) / max(0.001, fit));
  int stride = max(1, (int) ceil(brand.currentPoints.size() / brand.maxRenderPoints));
  float solid = constrain(params.solidness, 0, 1);
  for (int i = 0; i < brand.currentPoints.size(); i += stride) {
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer == 2 && solid < 0.32 && i % 5 != 0) continue;
    PVector p = brand.currentPoints.get(i);
    PVector o = brand.originalPoints.get(i);
    float vx = p.x - o.x;
    float vy = p.y - o.y;
    float pulse = 0.58 + 0.28 * sin(seedValue * 80.0 + i * 0.43) + audio.bass * 0.20 + audio.treble * 0.10;
    if (layer == 0) pulse *= 1.16;
    if (layer == 2) pulse *= lerp(0.48, 1.05, solid);
    applyBrandColor(pg, params, 28 + 72 * pulse, true, false);
    pg.ellipse(p.x - brand.center.x, p.y - brand.center.y, dot * pulse, dot * pulse);
    if (audio.energy > 0.05 && i % 3 == 0) {
      applyBrandColor(pg, params, 16 + audio.energy * 30, false, true);
      pg.strokeWeight(max(0.35, dot * 0.20));
      pg.line(p.x - brand.center.x, p.y - brand.center.y,
              p.x - brand.center.x - vx * 0.22, p.y - brand.center.y - vy * 0.22);
      pg.noStroke();
    }
  }
  pg.popStyle();
}

void renderBrandPlush(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || !brand.hasPointData) return;

  pg.pushStyle();
  float solid = constrain(params.solidness, 0, 1);
  float bass = audio != null ? constrain(audio.bass * 1.35 * params.bassInfluence, 0, 1.8) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.25 * params.midInfluence, 0, 1.8) : 0;
  float treble = audio != null ? constrain(audio.treble * 1.1 * params.trebleInfluence, 0, 1.8) : 0;
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.26, 0, 1.35) : 0;
  float t = noiseDynamicTime * 0.42;
  int stride = max(1, (int) ceil(brand.currentPoints.size() / max(1100, brand.maxRenderPoints * lerp(0.76, 1.45, solid))));
  float nap = max(0.72, (1.25 + bass * 1.2 + solid * 0.72) / max(0.001, fit));

  pg.noStroke();
  for (int pass = 0; pass < 3; pass++) {
    applyBrandColor(pg, params, pass == 0 ? 18 + energy * 12 : (pass == 1 ? 34 + bass * 14 : 24 + mid * 10), true, pass == 0);
    float sizeMul = pass == 0 ? 1.35 : (pass == 1 ? 0.82 : 0.48);
    for (int i = pass; i < brand.currentPoints.size(); i += stride) {
      int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
      if (layer == 2 && solid < 0.50 && i % 5 != 0) continue;
      PVector p = brand.currentPoints.get(i);
      PVector o = brand.originalPoints.get(i);
      float ox = o.x - brand.center.x;
      float oy = o.y - brand.center.y;
      float grain = noise(ox * 0.038 + 12.0, oy * 0.038 + 71.0, t + pass * 0.25);
      float d = nap * sizeMul * (0.65 + grain * 0.42);
      float a = atan2(oy, ox) + HALF_PI + (grain - 0.5) * 1.1;
      pg.pushMatrix();
      pg.translate(p.x - brand.center.x, p.y - brand.center.y);
      pg.rotate(a);
      pg.ellipse(0, 0, d * (2.4 + mid * 0.45), d * 0.55);
      pg.popMatrix();
    }
  }

  pg.noFill();
  pg.strokeCap(ROUND);
  int hairStride = max(1, (int) ceil(brand.currentPoints.size() / max(1350, brand.maxRenderPoints * lerp(0.90, 1.65, solid))));
  for (int pass = 0; pass < 3; pass++) {
    boolean secondary = pass == 1;
    applyBrandColor(pg, params, pass == 2 ? 42 + treble * 22 : 24 + mid * 18, false, secondary);
    pg.strokeWeight(max(0.28, (0.34 + pass * 0.10 + bass * 0.16) / max(0.001, fit)));
    for (int i = pass; i < brand.currentPoints.size(); i += hairStride) {
      int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
      if (layer == 2 && solid < 0.50 && i % 5 != 0) continue;
      PVector p = brand.currentPoints.get(i);
      PVector o = brand.originalPoints.get(i);
      float ox = o.x - brand.center.x;
      float oy = o.y - brand.center.y;
      float radial = atan2(oy, ox);
      float n = noise(ox * 0.026 + pass * 10.0, oy * 0.026 + 30.0, t * 0.88);
      float dir = radial + (n - 0.5) * 1.05 + sin(t * 4.0 + i * 0.017) * treble * 0.18;
      float len = max(1.1, (3.4 + bass * 3.4 + mid * 2.2 + n * 3.2) / max(0.001, fit));
      float x = p.x - brand.center.x;
      float y = p.y - brand.center.y;
      pg.line(x - cos(dir) * len * 0.20, y - sin(dir) * len * 0.20, x + cos(dir) * len, y + sin(dir) * len);
    }
  }
  pg.popStyle();
}

void renderBrandSoapBubbles(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || !brand.hasPointData) return;

  pg.pushStyle();
  pg.colorMode(RGB, 255, 255, 255, 255);
  pg.noFill();
  pg.strokeCap(ROUND);
  float solid = constrain(params.solidness, 0, 1);
  float bass = audio != null ? constrain(audio.bass * 1.35 * params.bassInfluence, 0, 1.8) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.25 * params.midInfluence, 0, 1.8) : 0;
  float treble = audio != null ? constrain(audio.treble * 1.1 * params.trebleInfluence, 0, 1.8) : 0;
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.34, 0, 1.4) : 0;
  float t = noiseDynamicTime * 0.72 + energy * 0.18;
  renderBrandConnected(pg, brand, params, fit, true, 34 + energy * 26, 0);

  int stride = max(1, (int) ceil(brand.currentPoints.size() / max(260, brand.maxRenderPoints * lerp(0.18, 0.42, solid))));
  float baseR = max(1.35, (2.4 + bass * 3.2 + solid * 1.2) / max(0.001, fit));
  int bubbleCounter = 0;

  for (int i = 0; i < brand.currentPoints.size(); i += stride) {
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer == 2 && solid < 0.48 && i % 5 != 0) continue;

    PVector p = brand.currentPoints.get(i);
    PVector o = brand.originalPoints.get(i);
    float ox = o.x - brand.center.x;
    float oy = o.y - brand.center.y;
    float n = noise(ox * 0.018 + 17.0, oy * 0.018 + 53.0, t);
    float gate = 0.46 + solid * 0.18 + energy * 0.14 + mid * 0.08;
    if (n < gate || hash1D(i, 301.0) > 0.62 + energy * 0.10) continue;

    bubbleCounter++;
    float popPhase = (t * 0.55 + hash1D(i, 99.0)) - floor(t * 0.55 + hash1D(i, 99.0));
    float overcrowd = constrain((bubbleCounter - 26) / 34.0 + energy * 0.34 + bass * 0.12, 0, 1.5);
    boolean popping = overcrowd > 0.58 && popPhase > 0.78;
    float r = baseR * (0.62 + n * 1.05 + mid * 0.18);
    float x = p.x - brand.center.x + (n - 0.5) * r * 0.7;
    float y = p.y - brand.center.y + sin(t * 3.0 + i * 0.05) * mid * r * 0.24;

    if (popping) {
      float burst = map(popPhase, 0.72, 1.0, 0.35, 1.65);
      pg.strokeWeight(max(0.25, (0.42 + treble * 0.24) / max(0.001, fit)));
      pg.stroke(190, 235, 255, (42 + treble * 42) * params.opacityAmount * (1.0 - min(1, burst * 0.45)));
      int shards = 5 + floor(hash1D(i, 44.0) * 4);
      for (int s = 0; s < shards; s++) {
        float a = TWO_PI * s / shards + hash1D(i + s, 13.0) * 0.45;
        float inner = r * 0.22 * burst;
        float outer = r * (0.70 + burst * 0.45);
        pg.line(x + cos(a) * inner, y + sin(a) * inner, x + cos(a) * outer, y + sin(a) * outer);
      }
      continue;
    }

    pg.strokeWeight(max(0.28, (0.48 + bass * 0.20) / max(0.001, fit)));
    pg.stroke(180, 230, 255, (36 + energy * 28) * params.opacityAmount);
    pg.ellipse(x, y, r * 2.0, r * (1.72 + n * 0.18));
    pg.stroke(255, 210, 245, (10 + treble * 18) * params.opacityAmount);
    pg.arc(x - r * 0.12, y - r * 0.16, r * 0.92, r * 0.56, -PI * 0.90, -PI * 0.16);
  }
  pg.popStyle();
}

void renderBrandHairFibers(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || !brand.hasPointData) return;

  pg.pushStyle();
  pg.noFill();
  pg.strokeCap(ROUND);

  float solid = constrain(params.solidness, 0, 1);
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.38, 0, 1.35) : 0;
  float bass = audio != null ? constrain(audio.bass * params.bassInfluence * 1.25, 0, 1.7) : 0;
  float mid = audio != null ? constrain(audio.mid * params.midInfluence * 1.35, 0, 1.8) : 0;
  float treble = audio != null ? constrain(audio.treble * params.trebleInfluence * 1.25, 0, 1.8) : 0;
  float t = noiseDynamicTime * (0.52 + params.transformSpeed * 0.18);
  float span = brand.span();
  float unit = span / 500.0;

  int targetFibers = (int) max(520, brand.maxRenderPoints * lerp(0.42, 1.75, constrain(energy + mid * 0.28, 0, 1)));
  int stride = max(1, (int) ceil(brand.currentPoints.size() / max(1, targetFibers)));
  float hairBase = max(0.55, (2.8 + params.complexity * 4.0 + mid * 7.5 + bass * 4.0) * unit / max(0.001, fit));
  float weightBase = max(0.18, (0.28 + bass * 0.18 + treble * 0.08) / max(0.001, fit));

  for (int pass = 0; pass < 3; pass++) {
    boolean secondary = pass == 1;
    float passAlpha = pass == 0 ? 14 + energy * 18 : (pass == 1 ? 30 + mid * 28 : 52 + treble * 28);
    applyBrandColor(pg, params, passAlpha, false, secondary);
    pg.strokeWeight(weightBase * (pass == 2 ? 0.72 : (pass == 1 ? 0.95 : 1.35)));

    for (int i = pass; i < brand.currentPoints.size(); i += stride) {
      int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
      if (layer == 2 && solid < 0.50 && i % 5 != 0) continue;

      PVector p = brand.currentPoints.get(i);
      PVector o = brand.originalPoints.get(i);
      PVector normal = brand.normalAproximadaDoPonto(i, o);
      PVector tangent = new PVector(-normal.y, normal.x);

      float ox = o.x - brand.center.x;
      float oy = o.y - brand.center.y;
      float n = noise(ox * 0.018 + pass * 11.0, oy * 0.018 + pass * 27.0, t + pass * 0.21);
      float cluster = noise(ox * 0.006 + 80.0, oy * 0.006 + 130.0, t * 0.33);
      float strand = hash1D(i + pass * 97.0, 18.0);
      float reveal = 0.22 + energy * 0.58 + mid * 0.20 + params.complexity * 0.20;
      float hotSpot = smoothstep(0.42, 0.86, cluster + energy * 0.18);
      if (n < 1.0 - reveal && hotSpot < 0.35 && strand > 0.18 + energy * 0.24) continue;

      float directionNoise = map(noise(ox * 0.012 + 3.0, oy * 0.012 + 9.0, t * 0.78 + pass), 0, 1, -1, 1);
      float angle = atan2(tangent.y, tangent.x) + directionNoise * (0.95 + mid * 0.55) + sin(t * 4.0 + i * 0.073) * treble * 0.26;
      float len = hairBase * (0.55 + strand * 1.45 + hotSpot * 1.35 + energy * 0.70);
      float rootShift = (hotSpot - 0.25) * (1.0 + bass * 1.4) * unit / max(0.001, fit);
      float px = p.x - brand.center.x + normal.x * rootShift;
      float py = p.y - brand.center.y + normal.y * rootShift;
      float curl = sin(t * 7.0 + i * 0.11 + pass) * len * (0.10 + treble * 0.12);
      applyBrandColor(pg, params, passAlpha * (0.42 + hotSpot * 0.95 + energy * 0.16), false, secondary);

      pg.line(px - cos(angle) * len * 0.44 + normal.x * curl,
              py - sin(angle) * len * 0.44 + normal.y * curl,
              px + cos(angle) * len * 0.56 - normal.x * curl,
              py + sin(angle) * len * 0.56 - normal.y * curl);

      if (hotSpot > 0.58 && pass == 2 && hash1D(i, 404.0) < 0.32 + energy * 0.24) {
        float len2 = len * (0.55 + hash1D(i, 405.0) * 0.55);
        float a2 = angle + map(hash1D(i, 406.0), 0, 1, -0.62, 0.62);
        applyBrandColor(pg, params, 34 + energy * 42, false, false);
        pg.strokeWeight(weightBase * 0.58);
        pg.line(px, py, px + cos(a2) * len2, py + sin(a2) * len2);
        applyBrandColor(pg, params, passAlpha, false, secondary);
        pg.strokeWeight(weightBase * 0.72);
      }
    }
  }

  renderBrandRasterStrokes(pg, brand, params, fit, true, 10 + energy * 22);
  pg.popStyle();
}

float smoothstep(float edge0, float edge1, float x) {
  float t = constrain((x - edge0) / max(0.0001, edge1 - edge0), 0, 1);
  return t * t * (3.0 - 2.0 * t);
}

void renderBrandReactionDiffusion(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || !brand.hasPointData) return;

  pg.pushStyle();
  pg.colorMode(HSB, 360, 100, 100, 100);
  float bass = audio != null ? constrain(audio.bass * 1.35 * params.bassInfluence, 0, 1.8) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.25 * params.midInfluence, 0, 1.8) : 0;
  float treble = audio != null ? constrain(audio.treble * 1.1 * params.trebleInfluence, 0, 1.8) : 0;
  float volume = audio != null ? constrain(audio.volume, 0, 1.8) : 0;
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.38, 0, 1.45) : 0;
  prepararReactionDiffusion(brand, params);
  injetarSomReactionDiffusion(brand, volume, energy, bass, mid, treble);

  int steps = constrain(round(2 + params.transformSpeed * 2.0 + energy * 3.0), 2, 7);
  float feed = constrain(map(bass, 0, 1.8, 0.010, 0.080), 0.010, 0.080);
  float kill = constrain(map(mid, 0, 1.8, 0.030, 0.070), 0.030, 0.070);
  float dA = constrain(map(treble, 0, 1.8, 0.80, 1.50), 0.80, 1.50);
  float dB = constrain(map(treble, 0, 1.8, 0.30, 0.80), 0.30, 0.80);
  for (int s = 0; s < steps; s++) atualizarReactionDiffusion(feed, kill, dA, dB);

  float cellW = (rdMaxX - rdMinX) / max(1, rdCols);
  float cellH = (rdMaxY - rdMinY) / max(1, rdRows);

  renderBrandOriginalCleanAlpha(pg, brand, params, fit, 6 + energy * 5);

  pg.noStroke();
  pg.ellipseMode(CENTER);
  for (int x = 0; x < rdCols; x++) {
    for (int y = 0; y < rdRows; y++) {
      float mask = rdMask[x][y];
      if (mask < 0.035) continue;

      float c = constrain(rdA[x][y] - rdB[x][y], 0, 1);
      float bChem = rdB[x][y];
      float band = 1.0 - constrain(abs(c - 0.47) / (0.20 + mid * 0.05), 0, 1);
      float grain = 1.0 - constrain(abs(bChem - 0.34) / (0.18 + treble * 0.04), 0, 1);
      float mark = max(band, grain * 0.82);
      if (mark < 0.18) continue;

      applyBrandColor(pg, params, (18 + mark * 68 + energy * 22) * mask, true, bChem > 0.38);
      float px = rdMinX + x * cellW - brand.center.x;
      float py = rdMinY + y * cellH - brand.center.y;
      float d = max(0.7, min(cellW, cellH) * (0.36 + mark * 0.82 + bass * 0.12));
      if ((x + y) % 3 == 0 || mark > 0.62) {
        pg.ellipse(px + cellW * 0.5, py + cellH * 0.5, d, d);
      }
    }
  }

  pg.colorMode(HSB, 360, 100, 100, 100);
  pg.noFill();
  pg.strokeCap(ROUND);
  applyBrandColor(pg, params, 32 + energy * 34, false, false);
  pg.strokeWeight(max(0.28, (0.38 + bass * 0.42) / max(0.001, fit)));
  for (int y = 1; y < rdRows - 1; y += 3) {
    boolean drawing = false;
    for (int x = 1; x < rdCols - 1; x += 2) {
      if (rdMask[x][y] < 0.15) continue;
      float b = rdB[x][y];
      float c = constrain(rdA[x][y] - b, 0, 1);
      boolean lineCell = c > 0.36 && c < 0.58 && b > 0.12 && abs(rdB[x + 1][y] - rdB[x - 1][y]) + abs(rdB[x][y + 1] - rdB[x][y - 1]) > 0.018;
      if (!lineCell) {
        if (drawing) pg.endShape();
        drawing = false;
        continue;
      }
      float px = rdMinX + x * cellW - brand.center.x;
      float py = rdMinY + y * cellH - brand.center.y;
      if (!drawing) {
        pg.beginShape();
        drawing = true;
      }
      pg.curveVertex(px + cellW * 0.5, py + cellH * 0.5 + sin(x * 0.21 + noiseDynamicTime) * cellH * treble * 0.18);
    }
    if (drawing) pg.endShape();
  }

  pg.popStyle();
}

void prepararReactionDiffusion(MutableBrand brand, MutationParams params) {
  int signature = brand.originalPoints.size() * 31 + round(brand.minX * 3.0) + round(brand.minY * 5.0) + round(brand.maxX * 7.0) + round(brand.maxY * 11.0);
  float complexityKey = round(params.complexity * 10.0) / 10.0;
  if (rdA != null && rdBrandSignature == signature && abs(rdComplexityKey - complexityKey) < 0.01) return;

  float w = max(1, brand.maxX - brand.minX);
  float h = max(1, brand.maxY - brand.minY);
  float pad = max(w, h) * 0.08;
  rdMinX = brand.minX - pad;
  rdMinY = brand.minY - pad;
  rdMaxX = brand.maxX + pad;
  rdMaxY = brand.maxY + pad;

  int longSide = constrain(round(74 + params.complexity * 58), 64, 132);
  if (w >= h) {
    rdCols = longSide;
    rdRows = constrain(round(longSide * (rdMaxY - rdMinY) / max(1, rdMaxX - rdMinX)), 28, 132);
  } else {
    rdRows = longSide;
    rdCols = constrain(round(longSide * (rdMaxX - rdMinX) / max(1, rdMaxY - rdMinY)), 28, 132);
  }

  rdA = new float[rdCols][rdRows];
  rdB = new float[rdCols][rdRows];
  rdNextA = new float[rdCols][rdRows];
  rdNextB = new float[rdCols][rdRows];
  rdMask = new float[rdCols][rdRows];

  for (int x = 0; x < rdCols; x++) {
    for (int y = 0; y < rdRows; y++) {
      rdA[x][y] = 1;
      rdB[x][y] = 0;
      rdMask[x][y] = 0;
    }
  }

  int stride = max(1, brand.originalPoints.size() / 4200);
  for (int i = 0; i < brand.originalPoints.size(); i += stride) {
    PVector p = brand.originalPoints.get(i);
    int gx = constrain(round(map(p.x, rdMinX, rdMaxX, 0, rdCols - 1)), 1, rdCols - 2);
    int gy = constrain(round(map(p.y, rdMinY, rdMaxY, 0, rdRows - 1)), 1, rdRows - 2);
    pintarReactionCell(gx, gy, 2, 0.72, false);
    if (hash1D(i, 91.0) < 0.22 || i % (stride * 37) == 0) pintarReactionCell(gx, gy, 3, 1.0, true);
  }

  expandirMascaraReaction(4);
  rdBrandSignature = signature;
  rdComplexityKey = complexityKey;
}

void pintarReactionCell(int cx, int cy, int r, float amount, boolean seedB) {
  for (int x = cx - r; x <= cx + r; x++) {
    for (int y = cy - r; y <= cy + r; y++) {
      if (x < 1 || y < 1 || x >= rdCols - 1 || y >= rdRows - 1) continue;
      float d = dist(cx, cy, x, y);
      if (d > r + 0.1) continue;
      float falloff = constrain(1.0 - d / max(1, r + 0.1), 0, 1);
      rdMask[x][y] = max(rdMask[x][y], amount * (0.45 + falloff * 0.55));
      if (seedB) {
        rdB[x][y] = max(rdB[x][y], amount * (0.40 + falloff * 0.60));
        rdA[x][y] = min(rdA[x][y], 1.0 - rdB[x][y] * 0.35);
      }
    }
  }
}

void expandirMascaraReaction(int iterations) {
  for (int k = 0; k < iterations; k++) {
    float[][] temp = new float[rdCols][rdRows];
    for (int x = 1; x < rdCols - 1; x++) {
      for (int y = 1; y < rdRows - 1; y++) {
        float m = rdMask[x][y];
        m = max(m, rdMask[x + 1][y] * 0.78);
        m = max(m, rdMask[x - 1][y] * 0.78);
        m = max(m, rdMask[x][y + 1] * 0.78);
        m = max(m, rdMask[x][y - 1] * 0.78);
        m = max(m, rdMask[x + 1][y + 1] * 0.62);
        m = max(m, rdMask[x - 1][y - 1] * 0.62);
        m = max(m, rdMask[x + 1][y - 1] * 0.62);
        m = max(m, rdMask[x - 1][y + 1] * 0.62);
        temp[x][y] = constrain(m, 0, 1);
      }
    }
    rdMask = temp;
  }
}

void injetarSomReactionDiffusion(MutableBrand brand, float volume, float energy, float bass, float mid, float treble) {
  if (rdA == null || brand.originalPoints.size() == 0) return;
  int injections = constrain(round(6 + energy * 42 + bass * 12 + treble * 10), 4, 74);
  int radius = constrain(round(1 + bass * 2.2 + mid * 1.2), 1, 5);
  for (int s = 0; s < injections; s++) {
    int idx = floor(hash1D(frameCount * 0.37 + s * 19.0 + floor(semente * 17.0), 123.0) * brand.originalPoints.size());
    PVector p = brand.originalPoints.get(idx);
    int gx = constrain(round(map(p.x, rdMinX, rdMaxX, 0, rdCols - 1)), 1, rdCols - 2);
    int gy = constrain(round(map(p.y, rdMinY, rdMaxY, 0, rdRows - 1)), 1, rdRows - 2);
    pintarReactionCell(gx, gy, radius, 0.44 + energy * 0.50, true);
  }

  if (volume > 0.10 || energy > 0.18) {
    int impactos = constrain(round(1 + volume * 10 + bass * 3), 1, 18);
    for (int k = 0; k < impactos; k++) {
      int gx = constrain(floor(hash1D(frameCount * 1.73 + k * 31.0, 211.0) * rdCols), 1, rdCols - 2);
      int gy = constrain(floor(hash1D(frameCount * 1.37 + k * 47.0, 307.0) * rdRows), 1, rdRows - 2);
      if (rdMask[gx][gy] < 0.08) continue;
      pintarReactionCell(gx, gy, max(1, radius - 1), 0.72 + volume * 0.28, true);
    }
  }
}

void atualizarReactionDiffusion(float feed, float kill, float dA, float dB) {
  for (int x = 1; x < rdCols - 1; x++) {
    for (int y = 1; y < rdRows - 1; y++) {
      float mask = rdMask[x][y];
      if (mask < 0.02) {
        rdNextA[x][y] = 1;
        rdNextB[x][y] = 0;
        continue;
      }

      float cA = rdA[x][y];
      float cB = rdB[x][y];
      float reaction = cA * cB * cB;
      float nextA = cA + (dA * laplaceReaction(rdA, x, y) - reaction + feed * (1 - cA));
      float nextB = cB + (dB * laplaceReaction(rdB, x, y) + reaction - (kill + feed) * cB);
      rdNextA[x][y] = constrain(lerp(1.0, nextA, mask), 0, 1);
      rdNextB[x][y] = constrain(nextB * mask, 0, 1);
    }
  }

  float[][] swapA = rdA;
  rdA = rdNextA;
  rdNextA = swapA;
  float[][] swapB = rdB;
  rdB = rdNextB;
  rdNextB = swapB;
}

float laplaceReaction(float[][] grid, int x, int y) {
  float sum = 0;
  sum += grid[x][y] * -1.0;
  sum += grid[x + 1][y] * 0.2;
  sum += grid[x - 1][y] * 0.2;
  sum += grid[x][y + 1] * 0.2;
  sum += grid[x][y - 1] * 0.2;
  sum += grid[x - 1][y - 1] * 0.05;
  sum += grid[x - 1][y + 1] * 0.05;
  sum += grid[x + 1][y - 1] * 0.05;
  sum += grid[x + 1][y + 1] * 0.05;
  return sum;
}

void renderBrandSand(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  if (brand == null || !brand.hasPointData) return;

  pg.pushStyle();
  pg.noStroke();
  float solid = constrain(params.solidness, 0, 1);
  float bass = audio != null ? constrain(audio.bass * 1.35 * params.bassInfluence, 0, 1.8) : 0;
  float mid = audio != null ? constrain(audio.mid * 1.25 * params.midInfluence, 0, 1.8) : 0;
  float treble = audio != null ? constrain(audio.treble * 1.1 * params.trebleInfluence, 0, 1.8) : 0;
  float energy = audio != null ? constrain(audio.energy + audio.volume * 0.32, 0, 1.4) : 0;
  float drive = constrain(max(energy, max(bass * 0.55, max(mid * 0.42, treble * 0.24))) * params.intensity, 0, 1.8);
  float t = noiseDynamicTime * 0.72 + drive * 0.16;
  float unit = brand.span() / 500.0;
  float maxR = max(1, brand.span() * 0.54);
  int stride = max(1, (int) ceil(brand.currentPoints.size() / max(1300, brand.maxRenderPoints * lerp(0.85, 1.65, solid))));
  float grain = max(0.56, (0.88 + solid * 0.22) / max(0.001, fit));

  for (int pass = 0; pass < 3; pass++) {
    boolean secondary = pass == 1;
    float passAlpha = pass == 0 ? 34 + energy * 26 : (pass == 1 ? 56 + mid * 44 : 78 + bass * 36);
    float passScale = pass == 0 ? 0.62 : (pass == 1 ? 0.82 : 1.0);
    applyBrandColor(pg, params, passAlpha, true, secondary);

    for (int i = pass; i < brand.currentPoints.size(); i += stride) {
      int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
      if (layer == 2 && solid < 0.50 && i % 5 != 0) continue;

      PVector p = brand.currentPoints.get(i);
      PVector o = brand.originalPoints.get(i);
      float x = p.x - brand.center.x;
      float y = p.y - brand.center.y;
      float ox = o.x - brand.center.x;
      float oy = o.y - brand.center.y;
      float r = sqrt(ox * ox + oy * oy);
      float rn = constrain(r / maxR, 0, 1.8);
      float a = atan2(oy, ox);

      float cellular = noise(ox * 0.022 + cos(t) * 1.4, oy * 0.022 + sin(t * 0.86) * 1.4, t * 0.62);
      float cellular2 = noise(ox * 0.041 + 31.0, oy * 0.041 + 17.0, t * 0.91);
      float fissure = abs(cellular - 0.50);
      float ring = abs(sin(rn * (20.0 + bass * 6.0) - t * (4.0 + bass * 2.5)));
      float nucleus = 1.0 - constrain(rn / (0.18 + bass * 0.07), 0, 1);
      float halo = 1.0 - constrain(abs(rn - (0.30 + bass * 0.04 + sin(t * 2.0) * 0.025)) / 0.060, 0, 1);
      float ridge = 1.0 - constrain(fissure / (0.070 + mid * 0.025 + solid * 0.018), 0, 1);
      float keep = max(max(nucleus * 1.15, halo * 0.96), ridge * (0.82 + cellular2 * 0.24));

      if (keep < 0.22 && hash1D(i, 201.5) > keep + energy * 0.24) continue;
      if (pass == 0 && ridge < 0.45 && halo < 0.20) continue;

      float sinuous = sin(a * 5.0 + rn * 13.0 + t * 3.4 + cellular2 * 2.2);
      float drift = (cellular - 0.5) * params.displacementAmount * unit * drive * (1.8 + mid);
      float tangent = sinuous * params.noiseAmount * unit * drive * (0.45 + treble * 0.42);
      float gx = x + cos(a) * drift + cos(a + HALF_PI) * tangent;
      float gy = y + sin(a) * drift + sin(a + HALF_PI) * tangent;

      float alphaGate = constrain(keep * (0.72 + energy * 0.52), 0, 1);
      if (pass == 2) {
        applyBrandColor(pg, params, (72 + 64 * alphaGate) * params.opacityAmount, true, false);
      }

      float accumulation = constrain(max(max(nucleus * 1.18, halo), ridge * 0.92) + bass * 0.52 + mid * 0.22 + energy * 0.28, 0, 2.4);
      int molecules = 2 + min(10, floor(accumulation * (pass == 2 ? 4.8 : (pass == 1 ? 3.2 : 1.8))));
      if (layer == 0) molecules += 1 + floor(bass * 1.4);
      float cluster = max(grain * 0.55, (1.2 + accumulation * 5.0 + halo * 4.0 + nucleus * 3.6) / max(0.001, fit));

      for (int m = 0; m < molecules; m++) {
        float mh = hash1D(i * 13.0 + m * 7.0 + pass * 17.0, 44.0);
        float ma = mh * TWO_PI;
        float mr = sqrt(hash1D(i * 19.0 + m * 11.0 + pass, 78.0)) * cluster;
        float pullCenter = max(nucleus, halo) * 0.35;
        float jx = cos(ma) * mr * (1.0 - pullCenter);
        float jy = sin(ma) * mr * (0.70 + cellular2 * 0.45);
        float localSize = grain * passScale * (0.72 + hash1D(i + m * 31.0, 55.0) * 0.42);
        if (layer == 0) localSize *= 1.05;
        pg.ellipse(gx + jx, gy + jy, localSize, localSize * (0.78 + cellular2 * 0.26));
      }

      if ((ridge > 0.62 || halo > 0.55) && i % 7 == 0) {
        pg.strokeWeight(max(0.22, grain * 0.16));
        applyBrandColor(pg, params, 22 + alphaGate * 34, false, secondary);
        float len = grain * (2.0 + mid * 2.5 + halo * 2.0);
        float la = a + HALF_PI + sinuous * 0.38;
        pg.line(gx - cos(la) * len, gy - sin(la) * len, gx + cos(la) * len, gy + sin(la) * len);
        pg.noStroke();
        applyBrandColor(pg, params, passAlpha, true, secondary);
      }
    }
  }

  pg.popStyle();
}

void renderBrandWaveRibbons(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  pg.pushStyle();
  pg.noFill();
  float ribbonBudget = max(260, brand.maxRenderPoints * 0.35);
  int stride = max(1, (int) ceil(brand.currentPoints.size() / ribbonBudget));
  float lineAlpha = 26 + audio.mid * 58 + audio.energy * 22;
  float bandWeight = max(0.32, (1.2 + audio.bass * 4.2 + params.strokeAmount * 0.22) / max(0.001, fit));
  float brandHeight = max(1, brand.maxY - brand.minY);
  int ribbons = 18;
  for (int r = 0; r < ribbons; r++) {
    float yNorm = map(r, 0, ribbons - 1, brand.minY, brand.maxY);
    applyBrandColor(pg, params, lineAlpha * map(r, 0, ribbons - 1, 0.55, 1.0), false, r % 2 == 0);
    pg.strokeWeight(bandWeight * map(r, 0, ribbons - 1, 0.65, 1.2));
    pg.beginShape();
    boolean hasVertex = false;
    for (int i = 0; i < brand.currentPoints.size(); i += stride) {
      PVector original = brand.originalPoints.get(i);
      if (abs(original.y - yNorm) > brandHeight * 0.034) continue;
      PVector p = brand.currentPoints.get(i);
      float waveLift = sin((p.x + r * 19.0) * 0.018 + semente * 12.0) * audio.mid * 10.0 / max(0.001, fit);
      pg.curveVertex(p.x - brand.center.x, p.y - brand.center.y + waveLift);
      hasVertex = true;
    }
    if (hasVertex) pg.endShape();
  }
  pg.popStyle();
}

void renderBrandEcho(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  pg.pushStyle();
  for (int pass = 4; pass >= 0; pass--) {
    pg.pushMatrix();
    float pulse = pass * (2.4 + audio.bass * 10.5 + audio.mid * 4.0) / max(0.001, fit);
    float a = seementeEcho(pass);
    pg.translate(cos(a) * pulse, sin(a) * pulse);
    pg.scale(1.0 + pass * (0.010 + audio.energy * 0.018));
    renderBrandPointDots(pg, brand, params, fit, true, 16 + pass * 10 + audio.energy * 18);
    pg.popMatrix();
  }
  pg.popStyle();
}

float seementeEcho(int pass) {
  return semente * 7.5 + pass * 1.37 + sin(semente * 2.0 + pass) * 0.35;
}

void renderBrandSlices(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  pg.pushStyle();
  pg.noStroke();
  pg.rectMode(CENTER);
  int stride = max(1, (int) ceil(brand.currentPoints.size() / brand.maxRenderPoints));
  float sliceH = max(1.2, (2.2 + audio.bass * 6.2 + params.strokeAmount * 0.28) / max(0.001, fit));
  float sliceW = max(3.0, (7.0 + audio.mid * 24.0 + params.complexity * 8.0) / max(0.001, fit));
  float alpha = 32 + audio.energy * 68;
  for (int i = 0; i < brand.currentPoints.size(); i += stride) {
    PVector p = brand.currentPoints.get(i);
    PVector original = brand.originalPoints.get(i);
    int slice = floor(map(original.y, brand.minY, brand.maxY, 0, 22));
    if ((i + slice) % max(1, floor(5 - params.complexity * 3.0)) != 0) continue;
    applyBrandColor(pg, params, alpha, true, slice % 2 == 0);
    float breathe = 1.0 + sin(slice * 0.9 + semente * 15.0) * audio.treble * 0.45;
    pg.rect(p.x - brand.center.x, p.y - brand.center.y, sliceW * breathe, sliceH, sliceH * 0.45);
  }
  pg.popStyle();
}

void renderBrandMagneticField(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  renderBrandParticles(pg, brand, params, fit, semente, audio);
  renderBrandRasterStrokes(pg, brand, params, fit, true, 36 + audio.treble * 38);
}

void renderBrandFilaments(PGraphics pg, MutableBrand brand, MutationParams params, float fit, float seedValue, AudioData audio) {
  pg.pushStyle();
  pg.noFill();
  int stride = max(1, (int) ceil(brand.currentPoints.size() / brand.maxRenderPoints));
  int visibleCount = max(2, floor(brand.currentPoints.size() * constrain(0.16 + audio.energy * 0.84, 0.02, 1)));
  float breakDistance = brand.span() * 0.035;
  for (int pass = 0; pass < 2; pass++) {
    float phase = seedValue * 24.0 + pass * 1.7;
    applyBrandColor(pg, params, 30 + pass * 18, false, pass == 1);
    pg.strokeWeight(max(0.28, (0.55 + pass * 0.22 + audio.energy * 1.45 + audio.treble * 0.75) / max(0.001, fit)));
    boolean desenhando = false;
    PVector previous = null;
    for (int i = 0; i < visibleCount; i += stride) {
      PVector p = brand.currentPoints.get(i);
      if (brand.pointCloudOnly || brand.isRaster) {
        float dx = p.x - brand.center.x;
        float dy = p.y - brand.center.y;
        float a = atan2(dy, dx) + HALF_PI + sin(phase + i * 0.05) * (0.4 + audio.mid);
        float len = (3.5 + audio.mid * 9.0 + audio.treble * 5.0) / max(0.001, fit);
        pg.line(p.x - brand.center.x - cos(a) * len, p.y - brand.center.y - sin(a) * len,
                p.x - brand.center.x + cos(a) * len, p.y - brand.center.y + sin(a) * len);
        continue;
      }
      boolean shouldBreak = brand.breakBefore.get(i) || !desenhando;
      if (!shouldBreak && previous != null && PVector.dist(previous, p) > breakDistance) shouldBreak = true;
      if (shouldBreak) {
        if (desenhando) pg.endShape();
        pg.beginShape();
        desenhando = true;
      }
      float ox = sin(phase + i * 0.17) * audio.energy * 8.0 / max(0.001, fit);
      float oy = cos(phase + i * 0.21) * audio.energy * 8.0 / max(0.001, fit);
      pg.vertex(p.x - brand.center.x + ox, p.y - brand.center.y + oy);
      previous = p;
    }
    if (desenhando) pg.endShape();
  }
  pg.popStyle();
}

void renderBrandGrid(PGraphics pg, MutableBrand brand, MutationParams params, float fit, AudioData audio) {
  pg.pushStyle();
  pg.noStroke();
  float solid = constrain(params.solidness, 0, 1);
  int stride = max(1, (int) ceil(brand.currentPoints.size() / max(320, brand.maxRenderPoints * lerp(0.30, 0.55, solid))));
  float gridSnap = max(4.0, (8.0 + audio.bass * 10.0 + audio.mid * 3.0) / max(0.001, fit));
  float cell = gridSnap * (0.88 + audio.energy * 0.18);
  for (int i = 0; i < brand.currentPoints.size(); i += stride) {
    int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
    if (layer == 2 && solid < 0.45 && i % 3 != 0) continue;
    PVector p = brand.currentPoints.get(i);
    float gx = round((p.x - brand.center.x) / gridSnap) * gridSnap;
    float gy = round((p.y - brand.center.y) / gridSnap) * gridSnap;
    float cellId = floor(gx / gridSnap) * 37.0 + floor(gy / gridSnap) * 71.0;
    if (hash1D(cellId, 42.0) > 0.64 + params.complexity * 0.16 + solid * 0.18) continue;
    applyBrandColor(pg, params, 38 + audio.energy * 62, true, i % 3 == 0);
    pg.rectMode(CENTER);
    pg.pushMatrix();
    pg.translate(gx, gy);
    pg.rotate((noise(cellId * 0.03, semente) - 0.5) * audio.treble * 0.45);
    float layerScale = layer == 0 ? 1.08 : (layer == 2 ? lerp(0.58, 1.02, solid) : 0.88);
    float wide = cell * (0.92 + audio.mid * 0.35) * layerScale;
    float tall = cell * (0.92 + audio.bass * 0.34) * layerScale;
    pg.rect(0, 0, wide, tall, 1);
    pg.popMatrix();
  }
  pg.popStyle();
}

void desenharRepouso(PGraphics pg, float breathTime, float alphaScale) {
  if (modoCorGlobal != 3) {
    pg.pushStyle();
    pg.colorMode(RGB, 255, 255, 255, 255);
    float folego = sin(breathTime);
    float r = 68 + folego * 18;
    for (int i = 7; i >= 1; i--) {
      float rr = (r + i * 20) * 2;
      desenharStrokeMonocromatico(pg, 60 * alphaScale, map(i, 1, 7, 1.8, 0.7));
      pg.noFill();
      pg.ellipse(0, 0, rr, rr);
    }
    pg.popStyle();
    return;
  }

  float folego = sin(breathTime);
  float r = 68 + folego * 18;
  float satBase = saturacaoReativa(18);
  pg.noStroke();
  for (int i = 7; i >= 1; i--) {
    pg.fill(38, satBase, 88, map(i, 1, 7, 7, 1.2) * alphaScale);
    pg.ellipse(0, 0, (r + i * 20) * 2, (r + i * 20) * 2);
  }
  pg.fill(40, saturacaoReativa(8), 98, 60 * alphaScale);
  pg.ellipse(0, 0, r * 2, r * 2);
}

void desenharBassShape(PGraphics pg, float v, float alfa, float seedValue) {
  if (modoCorGlobal != 3) {
    pg.pushStyle();
    pg.colorMode(RGB, 255, 255, 255, 255);
    float energiaMono = constrain(v * 1.45 + intensidade * 0.75, 0, 1.8);
    atualizarEstadoVeiasBass(energiaMono);
    float pulsoMono = 0.98 + sin(faseFolego * 1.65 + frameCount * 0.016) * (0.025 + energiaMono * 0.02);

    int nMono = bassVeins.size();
    int startMono = max(0, nMono - 11);
    for (int i = startMono; i < nMono; i++) {
      BassVeinLayer camada = bassVeins.get(i);
      float age = map(i, startMono, max(nMono - 1, startMono + 1), 0.35, 1.0);
      float limiteRaioTela = min(baseWidth, baseHeight) * 0.47;
      float r = min(camada.radius * pulsoMono, limiteRaioTela);
      float rough = camada.roughness * (0.95 + energiaMono * 0.32);

      pg.noFill();
      desenharStrokeMonocromatico(pg, (28 + 54 * age) * alfa, camada.thickness * 0.72 + energiaMono * 0.42);
      traceOrganicLoop(pg, r, rough, camada.seedB + seedValue * 0.18, 0.88, 0.86);
    }
    pg.popStyle();
    return;
  }

  float energia = constrain(v * 1.45 + intensidade * 0.75, 0, 1.8);
  atualizarEstadoVeiasBass(energia);

  float pulso = 0.98 + sin(faseFolego * 1.65 + frameCount * 0.016) * (0.025 + energia * 0.02);
  float centroR = 62 * pulso;

  // Centro limpo, com leve preenchimento.
  pg.noStroke();
  pg.fill(98, saturacaoReativa(20), 74, 4.5 * alfa);
  traceOrganicLoop(pg, centroR, 6.5 + energia * 4.5, seedValue + 2.3, 0.88, 0.8);

  int n = bassVeins.size();
  int maxVisiveis = (alfa < 0.55) ? 8 : 12;
  int start = max(0, n - maxVisiveis);
  int step = (alfa < 0.35) ? 2 : 1;
  for (int i = start; i < n; i += step) {
    BassVeinLayer camada = bassVeins.get(i);
    float age = map(i, start, max(n - 1, start + 1), 0.28, 1.0);
    float limiteRaioTela = min(baseWidth, baseHeight) * 0.47;
    float r = min(camada.radius * pulso, limiteRaioTela);
    float rough = camada.roughness * (0.92 + energia * 0.42);
    float detail = (age > 0.65 && alfa > 0.55) ? 1.0 : 0.74;

    pg.noStroke();
    pg.fill(camada.hue, camada.sat, min(100, camada.bri + 12), camada.fillAlpha * age * alfa);
    traceOrganicLoop(pg, r, rough, camada.seedA + seedValue * 0.15, 0.88, detail);

    pg.noFill();
    pg.stroke(camada.hue, min(100, camada.sat + 8), max(0, camada.bri - 5), (20 + 45 * age) * alfa);
    pg.strokeWeight(camada.thickness + energia * 0.65);
    traceOrganicLoop(pg, r, rough, camada.seedB + seedValue * 0.18, 0.88, detail);
  }

  pg.noFill();
  pg.stroke(96, saturacaoReativa(44), 36 + energia * 18, 42 * alfa);
  pg.strokeWeight(2.1);
  traceOrganicLoop(pg, centroR, 4.8 + energia * 2.8, seedValue + 0.7, 0.88, 0.9);
}

void desenharMidShape(PGraphics pg, float v, float alfa, float seedValue) {
  if (modoCorGlobal != 3) {
    pg.pushStyle();
    pg.colorMode(RGB, 255, 255, 255, 255);
    int aneisMono = 9;
    for (int a = aneisMono; a >= 1; a--) {
      float escala = map(a, 1, aneisMono, 0.18, 1.0);
      pg.noFill();
      desenharStrokeMonocromatico(pg, map(a, 1, aneisMono, 84, 12) * alfa, map(a, 1, aneisMono, 2.3, 0.55));
      pg.beginShape();
      for (int i = 0; i <= 110; i++) {
        float ang = TWO_PI * i / 110;
        float n = noise(cos(ang) * 2.4 + a * 4.2 + seedValue * 0.5, sin(ang) * 2.4 + a * 4.2 + seedValue * 0.5);
        float raio = 150 * escala + map(n, 0, 1, -30, 30) * (0.26 + v * 1.2);
        pg.curveVertex(cos(ang) * raio, sin(ang) * raio);
      }
      pg.endShape(CLOSE);
    }
    pg.popStyle();
    return;
  }

  float sat = saturacaoReativa(map(intensidade, 0, 1, 48, 92));
  float bri = map(v, 0, 0.5, 42, 85);
  int aneis = 9;
  for (int a = aneis; a >= 1; a--) {
    float escala = map(a, 1, aneis, 0.18, 1.0);
    pg.stroke(map(a, 1, aneis, 200, 186), sat, bri, map(a, 1, aneis, 88, 12) * alfa);
    pg.strokeWeight(map(a, 1, aneis, 2.5, 0.5));
    pg.noFill();
    pg.beginShape();
    for (int i = 0; i <= 110; i++) {
      float ang = TWO_PI * i / 110;
      float n = noise(cos(ang) * 2.4 + a * 4.2 + seedValue * 0.5, sin(ang) * 2.4 + a * 4.2 + seedValue * 0.5);
      float raio = 150 * escala + map(n, 0, 1, -30, 30) * (0.28 + v * 1.5);
      pg.curveVertex(cos(ang) * raio, sin(ang) * raio);
    }
    pg.endShape(CLOSE);
  }
}

void atualizarEstadoVeiasBass(float energia) {
  if (bassStateUpdatedFrame == frameCount) return;
  bassStateUpdatedFrame = frameCount;

  if (bassVeins.size() == 0) {
    resetBassVeinsModel();
  }

  float drive = max(0, energia - 0.08);
  float ataque = drive - bassPrevDrive;
  bassSpawnEnergy = lerp(bassSpawnEnergy, drive, 0.35);
  int now = millis();
  int intervaloBase = (int) max(80, 240 - bassSpawnEnergy * 150);
  boolean somAtivo = bassSpawnEnergy > 0.02;
  boolean ataqueForte = ataque > 0.028;

  if ((somAtivo && now - bassLastSpawnMs > intervaloBase) || (ataqueForte && now - bassLastSpawnMs > 45)) {
    spawnBassVein(bassSpawnEnergy);
    bassLastSpawnMs = now;
  }
  bassPrevDrive = drive;
}

void resetBassVeinsModel() {
  bassVeins.clear();
  for (int i = 0; i < 4; i++) {
    spawnBassVein(0.12 + i * 0.03);
  }
  bassLastSpawnMs = millis();
  bassStateUpdatedFrame = -1;
  bassSpawnEnergy = 0;
  bassPrevDrive = 0;
}

void spawnBassVein(float energia) {
  float baseRadius = 62;
  float maxRadius = min(baseWidth, baseHeight) * 0.45;
  float span = max(120, maxRadius - baseRadius);
  float prevRadius = bassVeins.size() > 0 ? bassVeins.get(bassVeins.size() - 1).radius : baseRadius;
  float growth = random(10, 18) + energia * 16;
  float roughness = random(4, 10) + energia * 8;
  float thickness = random(1.8, 4.6) + energia * 1.4;
  float hue = 102 + random(-8, 8);
  float sat = saturacaoReativa(random(34, 52) + energia * 20);
  float bri = random(24, 42) + energia * 8;
  float fillAlpha = random(1.8, 5.0) + energia * 3.0;
  float seedA = random(1000);
  float seedB = random(1000);
  float cyclePos = (prevRadius - baseRadius + growth) % span;
  if (cyclePos < 0) cyclePos += span;
  float nextRadius = baseRadius + cyclePos;

  bassVeins.add(new BassVeinLayer(nextRadius, roughness, thickness, hue, sat, bri, fillAlpha, seedA, seedB));
  if (bassVeins.size() > 14) bassVeins.remove(0);
}

void traceOrganicLoop(PGraphics pg, float radius, float roughness, float seed, float squeezeY, float detail) {
  int points = (int) lerp(68, 112, constrain(detail, 0.4, 1.0));
  pg.beginShape();
  for (int i = -2; i <= points + 2; i++) {
    int idx = (i + points) % points;
    float a = TWO_PI * idx / points;
    float waveA = sin(a * 2.1 + filTick * 0.020 + seed * 1.3) * roughness * 0.25;
    float waveB = cos(a * 3.9 - filTick * 0.015 + seed * 0.8) * roughness * 0.18;
    float waveC = sin(a * 7.2 + idx * 0.035 + seed * 2.4) * roughness * 0.12;
    float micro = sin(idx * 0.21 + seed * 3.7 + filTick * 0.007) * roughness * 0.09;
    float rr = radius + waveA + waveB + waveC + micro;
    pg.curveVertex(cos(a) * rr, sin(a) * rr * squeezeY);
  }
  pg.endShape(CLOSE);
}

void desenharTrebleShape(PGraphics pg, float v, float alfa, float seedValue) {
  if (modoCorGlobal != 3) {
    pg.pushStyle();
    pg.colorMode(RGB, 255, 255, 255, 255);
    float loudMono = constrain(v * 1.22 + trebleImpact * 2.10 + intensidade * 0.82, 0, 3.2);
    float targetMono = constrain(0.28 + loudMono * 0.38, 0.2, 1.0);
    if (loudMono > 0.20) filHoldTimer = 2.4;
    if (loudMono > 0.24) filExplosion = max(filExplosion, 1.0);
    filHoldTimer = max(0, filHoldTimer - (1.0 / max(frameRate, 1)));
    filExplosion = max(0, filExplosion - 0.032);
    if (filHoldTimer > 0) targetMono = max(targetMono, 0.34);
    filDisplay = lerp(filDisplay, targetMono, (targetMono > filDisplay) ? 0.24 : 0.03);

    float growthMono = 0.72 + filDisplay * 0.75 + filExplosion * 0.55;
    float progMono = constrain(filDisplay, 0.18, 1.0);
    float localR = 165 * growthMono;
    drawFilamentBlobMono(pg, 0, 0, localR, progMono, alfa, 0);
    pg.popStyle();
    return;
  }

  float loud = constrain(v * 1.22 + trebleImpact * 2.10 + intensidade * 0.82, 0, 3.2);
  float target = constrain(0.28 + loud * 0.38, 0.2, 1.0);
  if (loud > 0.20) filHoldTimer = 2.4;
  if (loud > 0.24) filExplosion = max(filExplosion, 1.0);
  filHoldTimer = max(0, filHoldTimer - (1.0 / max(frameRate, 1)));
  filExplosion = max(0, filExplosion - 0.032);
  if (filHoldTimer > 0) target = max(target, 0.34);
  filDisplay = lerp(filDisplay, target, (target > filDisplay) ? 0.24 : 0.03);

  float growth = 0.72 + filDisplay * 0.75 + filExplosion * 0.55;
  float prog = constrain(filDisplay, 0.18, 1.0);

  int instancias = 1;
  float spread = 138 * growth;

  pg.pushStyle();
  pg.colorMode(RGB, 255);
  for (int i = 0; i < instancias; i++) {
    float ox = 0;
    float oy = 0;
    if (instancias == 2) {
      ox = (i == 0 ? -1 : 1) * spread * 0.55;
    } else if (instancias == 3) {
      ox = (i - 1) * spread * 0.52;
      oy = abs(i - 1) * spread * 0.08;
    } else if (instancias >= 4) {
      ox = (i % 2 == 0 ? -1 : 1) * spread * 0.48;
      oy = (i < 2 ? -1 : 1) * spread * 0.22;
    }

    float localR = 165 * growth * (1.0 - i * 0.06);
    float localCore = 36 * growth;
    drawFilamentBlob(pg, ox, oy, localR, localCore, prog, alfa, i * 37.0);
  }

  if (filExplosion > 0.02) {
    int rays = 24;
    float boom = (70 + filExplosion * 310) * (0.45 + prog);
    for (int r = 0; r < rays; r++) {
      float a = TWO_PI * r / rays + sin(filTick * 0.03 + r * 0.37) * 0.08;
      float inner = 10 + filExplosion * 24;
      float outer = boom * (0.72 + 0.28 * hash1D(r, 91));
      pg.stroke(255, 125, 40, (45 + filExplosion * 140) * alfa);
      pg.strokeWeight(1.1 + filExplosion * 2.3);
      pg.line(cos(a) * inner, sin(a) * inner, cos(a) * outer, sin(a) * outer);
    }
  }
  pg.popStyle();
}

void desenharPresenceShape(PGraphics pg, float v, float alfa, float seedValue) {
  if (modoCorGlobal != 3) {
    pg.pushStyle();
    pg.colorMode(RGB, 255, 255, 255, 255);
    float energiaMono = constrain(v * 1.45 + intensidade * 0.65, 0, 1.9);
    float tMono = frameCount * 0.022 + seedValue * 2.0;
    float minDim = min(baseWidth, baseHeight);
    float[] layerScale = { 0.38, 0.34, 0.31, 0.28, 0.245, 0.215, 0.185, 0.155 };
    float[] layerSeed = { 0.0, 1.7, 3.3, 5.1, 2.4, 4.8, 6.2, 1.1 };

    for (int i = 0; i < layerScale.length; i++) {
      float radius = minDim * layerScale[i] * (0.82 + energiaMono * 0.18);
      float a = (20 + i * 6) * (0.70 + energiaMono * 0.35) * alfa;
      pg.noFill();
      desenharStrokeMonocromatico(pg, a, 0.8 + i * 0.12 + energiaMono * 0.2);
      desenharFormaAquarelaVento(pg, 0, 0, radius, layerSeed[i] + seedValue, tMono, energiaMono);
    }
    pg.popStyle();
    return;
  }

  pg.pushStyle();
  pg.colorMode(HSB, 360, 100, 100, 100);

  float energia = constrain(v * 1.45 + intensidade * 0.65, 0, 1.9);
  float t = frameCount * 0.022 + seedValue * 2.0;
  float minDim = min(baseWidth, baseHeight);

  float[] layerScale = { 0.38, 0.34, 0.31, 0.28, 0.245, 0.215, 0.185, 0.155 };
  float[] layerSeed  = { 0.0, 1.7, 3.3, 5.1, 2.4, 4.8, 6.2, 1.1 };
  float[] layerHue   = { 48, 42, 54, 38, 50, 45, 56, 43 };
  float[] layerSat   = { 86, 78, 64, 92, 72, 88, 58, 82 };
  float[] layerBri   = { 96, 90, 100, 82, 92, 86, 98, 94 };
  float[] layerAlpha = { 15, 13, 14, 11, 15, 10, 13, 16 };

  for (int i = layerScale.length - 1; i >= 0; i--) {
    float radius = minDim * layerScale[i] * (0.82 + energia * 0.18);
    float alpha = layerAlpha[i] * (0.70 + energia * 0.45) * alfa;
    desenharCamadaAquarelaVento(pg, radius, layerSeed[i] + seedValue, layerHue[i], layerSat[i], layerBri[i], alpha, t, energia);
  }

  float pulse = 0.75 + 0.2 * sin(t * 1.1);
  pg.noStroke();
  for (int i = 5; i >= 1; i--) {
    float rr = minDim * 0.035 * i * (0.75 + energia * 0.18);
    pg.fill(48, 34, 100, pulse * alfa * map(i, 1, 5, 22, 3));
    pg.ellipse(0, 0, rr * 2.0, rr * 2.0);
  }

  pg.popStyle();
}

void desenharCamadaAquarelaVento(PGraphics pg, float radius, float seed, float hue, float sat, float bri, float alpha, float t, float energia) {
  float driftX = sin(t * 0.38 + seed) * baseWidth * 0.045 + sin(t * 0.19 + seed * 1.7) * baseWidth * 0.022;
  float driftY = cos(t * 0.29 + seed * 0.8) * baseHeight * 0.035 + cos(t * 0.15 + seed * 2.1) * baseHeight * 0.018;
  float breathe = 1.0 + 0.06 * sin(t * 0.7 + seed) + 0.03 * sin(t * 1.3 + seed * 0.6);

  for (int pass = 0; pass < 4; pass++) {
    float jx = sin(t * 1.1 + pass * 2.4 + seed) * radius * 0.04 * (0.8 + energia * 0.4);
    float jy = cos(t * 0.9 + pass * 1.9 + seed) * radius * 0.04 * (0.8 + energia * 0.4);
    float ox = driftX + jx;
    float oy = driftY + jy;

    pg.noStroke();
    pg.fill(hue, sat * 0.72, min(100, bri + 8), alpha * 0.28);
    desenharFormaAquarelaVento(pg, ox, oy, radius * breathe * 0.72, seed + pass * 0.37, t, energia);

    pg.fill(hue, sat, bri, alpha * 0.62);
    desenharFormaAquarelaVento(pg, ox, oy, radius * breathe, seed + pass * 0.53, t, energia);

    pg.noFill();
    pg.stroke(hue, min(100, sat + 8), max(0, bri - 8), alpha * 0.78);
    pg.strokeWeight(0.9 + pass * 0.28 + energia * 0.25);
    desenharFormaAquarelaVento(pg, ox, oy, radius * breathe * 1.02, seed + pass * 0.71, t, energia);
  }
}

void desenharFormaAquarelaVento(PGraphics pg, float ox, float oy, float radius, float seed, float t, float energia) {
  int pts = 132;
  pg.beginShape();
  for (int i = 0; i <= pts; i++) {
    float ang = (i / float(pts)) * TWO_PI;
    float lobe = pow(abs(cos(2 * ang)), 0.5);
    float w1 = sin(ang * 5 + t * 1.4 + seed) * 0.08;
    float w2 = cos(ang * 9 + t * 1.0 + seed * 1.3) * 0.05;
    float w3 = sin(ang * 14 + t * 0.7 + seed * 0.7) * 0.03;
    float w4 = cos(ang * 3 + t * 1.8 + seed * 2.0) * 0.06;
    float rad = radius * lobe * (1.0 + (w1 + w2 + w3 + w4) * (0.85 + energia * 0.35));
    float x = ox + cos(ang) * rad;
    float y = oy + sin(ang) * rad;
    pg.vertex(x, y);
  }
  pg.endShape(CLOSE);
}

void drawYellowPetal(PGraphics pg, float ang, float len, int c, float a, boolean glowLayer) {
  pg.pushMatrix();
  pg.rotate(ang);
  pg.noStroke();
  int alpha = (int) constrain(a, 0, 255);
  int r = (c >> 16) & 0xFF;
  int g = (c >> 8) & 0xFF;
  int b = c & 0xFF;

  if (glowLayer) {
    pg.fill(r, g, b, alpha * 0.45);
    pg.beginShape();
    pg.vertex(0, 0);
    pg.bezierVertex(len * 0.30, -len * 0.36, len * 0.66, -len * 0.92, 0, -len * 1.05);
    pg.bezierVertex(-len * 0.66, -len * 0.92, -len * 0.30, -len * 0.36, 0, 0);
    pg.endShape(CLOSE);
  }

  pg.fill(r, g, b, alpha);
  pg.beginShape();
  pg.vertex(0, 0);
  pg.bezierVertex(len * 0.24, -len * 0.30, len * 0.58, -len * 0.86, 0, -len);
  pg.bezierVertex(-len * 0.58, -len * 0.86, -len * 0.24, -len * 0.30, 0, 0);
  pg.endShape(CLOSE);
  pg.popMatrix();
}

void desenharNoiseShape(PGraphics pg, float v, float alfa) {
  pg.noStroke();
  for (int c = 15; c >= 1; c--) {
    float r = map(c, 1, 15, 10, 180) * (0.5 + v);
    pg.fill(255, 20 * alfa * (1.0 / c));
    pg.ellipse(0, 0, r, r);
  }
}

float saturacaoReativa(float satBase) {
  float fator = constrain(map(intensidade, 0, 1, 0.08, 1.0), 0.08, 1.0);
  return constrain(satBase * fator, 0, 100);
}

void drawFilamentBlob(PGraphics pg, float ox, float oy, float baseR, float coreR, float prog, float alphaScale, float seedOffset) {
  for (Filament f : filamentsModel) {
    if (f.z < 0) drawFilamentSegment(pg, f, ox, oy, baseR, prog, alphaScale, seedOffset);
  }

  drawFilamentCore(pg, ox, oy, coreR, prog, alphaScale, seedOffset);

  for (Filament f : filamentsModel) {
    if (f.z >= 0) drawFilamentSegment(pg, f, ox, oy, baseR, prog, alphaScale, seedOffset);
  }
}

void drawFilamentBlobMono(PGraphics pg, float ox, float oy, float baseR, float prog, float alphaScale, float seedOffset) {
  for (Filament f : filamentsModel) {
    if (f.z < 0) drawFilamentSegmentMono(pg, f, ox, oy, baseR, prog, alphaScale, seedOffset);
  }
  for (Filament f : filamentsModel) {
    if (f.z >= 0) drawFilamentSegmentMono(pg, f, ox, oy, baseR, prog, alphaScale, seedOffset);
  }
}

void drawFilamentSegment(PGraphics pg, Filament f, float ox, float oy, float baseR, float prog, float alphaScale, float seedOffset) {
  float len = baseR * f.lengthF * prog;
  if (len < 2) return;

  int steps = 28;
  float[] px = new float[steps + 1];
  float[] py = new float[steps + 1];

  float x = ox;
  float y = oy;
  float dir = f.angle;
  float sl = len / steps;
  float bendPerStep = f.curvAmt / steps;
  float breathe = sin(filTick * 0.031 + (f.index + seedOffset) * 0.17) * 0.008 * prog;

  for (int s = 0; s <= steps; s++) {
    px[s] = x;
    py[s] = y;
    dir += bendPerStep + breathe;
    x += cos(dir) * sl;
    y += sin(dir) * sl;
  }

  for (int s = 0; s < steps; s++) {
    float frac = s / float(steps);
    float colorT = lerp(f.baseT, f.tipT, frac);
    int c = redAt(colorT);
    float depthAlpha = f.alpha * (0.55 + (f.z + 1.0) * 0.225) * alphaScale;
    float segThick = f.thick * (1.0 - frac * 0.55) * 1.35 + 0.9;

    pg.stroke((c >> 16) & 0xFF, (c >> 8) & 0xFF, c & 0xFF, depthAlpha * prog * 255.0);
    pg.strokeWeight(segThick);
    pg.strokeCap(ROUND);
    pg.line(px[s], py[s], px[s + 1], py[s + 1]);
  }

  int tipC = redAt(min(1.0, f.tipT + 0.12));
  pg.noStroke();
  pg.fill((tipC >> 16) & 0xFF, (tipC >> 8) & 0xFF, tipC & 0xFF, f.alpha * prog * 0.95 * alphaScale * 255.0);
  pg.ellipse(px[steps], py[steps], f.thick * 3.4, f.thick * 3.4);
}

void drawFilamentSegmentMono(PGraphics pg, Filament f, float ox, float oy, float baseR, float prog, float alphaScale, float seedOffset) {
  float len = baseR * f.lengthF * prog;
  if (len < 2) return;

  int steps = 28;
  float[] px = new float[steps + 1];
  float[] py = new float[steps + 1];

  float x = ox;
  float y = oy;
  float dir = f.angle;
  float sl = len / steps;
  float bendPerStep = f.curvAmt / steps;
  float breathe = sin(filTick * 0.031 + (f.index + seedOffset) * 0.17) * 0.008 * prog;

  for (int s = 0; s <= steps; s++) {
    px[s] = x;
    py[s] = y;
    dir += bendPerStep + breathe;
    x += cos(dir) * sl;
    y += sin(dir) * sl;
  }

  for (int s = 0; s < steps; s++) {
    float frac = s / float(steps);
    float depthAlpha = f.alpha * (0.55 + (f.z + 1.0) * 0.225) * alphaScale;
    float segThick = f.thick * (1.0 - frac * 0.55) * 1.10 + 0.45;
    desenharStrokeMonocromatico(pg, depthAlpha * prog * 255.0, segThick);
    pg.line(px[s], py[s], px[s + 1], py[s + 1]);
  }
}

void drawFilamentCore(PGraphics pg, float ox, float oy, float coreR, float prog, float alphaScale, float seedOffset) {
  float r = coreR * prog;
  pg.noStroke();

  pg.fill(15, 2, 1, 0.28 * prog * alphaScale * 255.0);
  pg.ellipse(ox, oy, r * 3.6, r * 3.6);

  pg.fill(22, 4, 2, 0.45 * prog * alphaScale * 255.0);
  pg.ellipse(ox, oy, r * 2.8, r * 2.8);

  pg.fill(10, 1, 1, 0.75 * prog * alphaScale * 255.0);
  pg.ellipse(ox, oy, r * 2.0, r * 2.0);

  pg.fill(6, 0, 0, 0.90 * prog * alphaScale * 255.0);
  pg.ellipse(ox, oy, r * 1.1, r * 1.1);

  pg.noStroke();
  for (int i = 0; i < 18; i++) {
    float a = hash1D(i + seedOffset, 77) * TWO_PI;
    float rr = lerp(r * 0.15, r * 0.8, hash1D(i + seedOffset, 89));
    float n = sin(filTick * 0.02 + i * 0.37 + seedOffset) * 0.5 + 0.5;
    float xx = ox + cos(a) * rr + map(n, 0, 1, -r * 0.06, r * 0.06);
    float yy = oy + sin(a) * rr + map(n, 0, 1, -r * 0.06, r * 0.06);
    pg.fill(255, 160, 100, 14 * alphaScale);
    pg.ellipse(xx, yy, r * 0.24, r * 0.24);
  }
}

float hash1D(float n, float s) {
  float x = sin(n * 127.1 + s * 311.7) * 43758.5453;
  return x - floor(x);
}

float smoothNoise1D(float t, float s) {
  float i = floor(t);
  float f = t - i;
  float u = f * f * (3.0 - 2.0 * f);
  return lerp(hash1D(i, s), hash1D(i + 1.0, s), u);
}

int redAt(float t) {
  t = constrain(t, 0, 1);
  int n = redPaletteHex.length - 1;
  float scaled = t * n;
  int i = min(floor(scaled), n - 1);
  float f = scaled - i;
  int c1 = redPaletteHex[i];
  int c2 = redPaletteHex[i + 1];
  int r = (int) lerp((c1 >> 16) & 0xFF, (c2 >> 16) & 0xFF, f);
  int g = (int) lerp((c1 >> 8) & 0xFF, (c2 >> 8) & 0xFF, f);
  int b = (int) lerp(c1 & 0xFF, c2 & 0xFF, f);
  return 0xFF000000 | (r << 16) | (g << 8) | b;
}

void atualizarEstado() {
  if (modoFormaManual > 0) {
    tempoSemAtivacao = 0;
    emHold = false;
    timerHold = 0;
    ultimaForma = modoFormaManual;
    if (formaAtiva != modoFormaManual) {
      formaAnterior = formaAtiva;
      formaAtiva = modoFormaManual;
      transicaoForma = 0;
      alfaDissolve = 0;
    }
    transicaoForma = min(1, transicaoForma + velTransicao);
    alfaDissolve = min(255, alfaDissolve + velDissolve);
    return;
  }

  float total = sBass * pB + sMid * pM + sTreble * pT + sPresence * pP;
  int formaDesejada = formaAtiva;
  float dt = 1.0 / max(frameRate, 1);
  tempoSemAtivacao = (total < 0.05) ? (tempoSemAtivacao + dt) : 0;

  if (total < 0.05) {
    timerHold += dt;
    if (emHold && timerHold > duracaoHold) {
      emHold = false;
      formaDesejada = 0;
    }
  } else {
    timerHold = 0;
    emHold = false;
    // RUIDO desativado: forma 5 removida da selecao automatica.
    float[] vals = { sBass * pB, sMid * pM, sTreble * pT, sPresence * pP };
    float maxV = 0;
    int ganho = formaAtiva;
    for (int i = 0; i < vals.length; i++) {
      if (vals[i] > maxV) {
        maxV = vals[i];
        ganho = i + 1;
      }
    }
    if (maxV > 0.05) formaDesejada = ganho;
    if (formaDesejada != 0) ultimaForma = formaDesejada;
  }

  if (total < 0.05 && ultimaForma != 0 && formaDesejada == 0 && timerHold < duracaoHold) {
    formaDesejada = ultimaForma;
    emHold = true;
  }

  if (tempoSemAtivacao >= limiteInatividade) {
    formaDesejada = 0;
    emHold = false;
    ultimaForma = 0;
  }

  if (formaDesejada != formaAtiva) {
    formaAnterior = formaAtiva;
    formaAtiva = formaDesejada;
    transicaoForma = 0;
    alfaDissolve = 0;
  }

  transicaoForma = min(1, transicaoForma + velTransicao);
  alfaDissolve = min(255, alfaDissolve + velDissolve);
}

void desenharFormaAtiva(PGraphics pg, float seedValue, float breathTime) {
  if (modoFormaManual == 0 && tempoSemAtivacao >= limiteInatividade) return;

  if (modoLinhaReativos) {
    desenharLinhaReativos(pg, seedValue, breathTime, 1.0);
    return;
  }

  float alfa = alfaDissolve / 255.0;

  if (transicaoForma < 1.0 && formaAnterior != formaAtiva) {
    desenharFormaPorIndice(pg, formaAnterior, seedValue, breathTime, alfa * (1.0 - transicaoForma));
    desenharFormaPorIndice(pg, formaAtiva, seedValue, breathTime, alfa * transicaoForma);
    return;
  }

  desenharFormaPorIndice(pg, formaAtiva, seedValue, breathTime, alfa);
}

void desenharLinhaReativos(PGraphics pg, float seedValue, float breathTime, float alphaScale) {
  // RUIDO desativado: exibimos apenas 4 formas na palavra.
  int[] formas = { 1, 2, 3, 4 };
  float espacamento = espacamentoPalavra;

  for (int i = 0; i < formas.length; i++) {
    int forma = formas[i];
    float energia = valorForma(forma);
    float ganho = constrain(map(energia, 0.05, 0.45, 0.12, 1.0), 0.12, 1.0);
    float escalaLocal = 0.33 + ganho * 0.16;
    float alphaLocal = alphaScale * (0.2 + ganho * 0.8);

    pg.pushMatrix();
    pg.translate((i - 1.5) * espacamento, 0);
    pg.scale(escalaLocal);
    desenharFormaPorIndice(pg, forma, seedValue, breathTime, alphaLocal);
    pg.popMatrix();
  }
}

void desenharMarcaSVGReativa(PGraphics pg, float breathTime) {
  if (!mostrarTipografiaPalavra) return;

  PImage img1 = marcaRaster;
  PImage img1b = marcaRaster1b;
  PImage img2 = marcaRaster2;
  PImage img2b = marcaRaster2b;
  if (img1 == null && img1b == null && img2 == null && img2b == null) return;

  float energiaMedia = (valorForma(1) + valorForma(2) + valorForma(3) + valorForma(4)) / 4.0;
  float ganho = constrain(map(energiaMedia, 0.05, 0.45, 0.2, 1.0), 0.2, 1.0);
  float baseY = modoLinhaReativos ? (typoOffsetY + typoWordOffsetExtra) : typoOffsetY;
  float y = baseY;

  float escalaBase = (typoSize / 26.0) * (modoLinhaReativos ? 1.65 : 1.0);
  float escalaPulso = escalaBase * (0.97 + ganho * 0.08);
  float alvoW = (modoLinhaReativos ? typoBaseWidthWord : typoBaseWidthSolo) * escalaPulso;

  pg.pushStyle();
  pg.imageMode(CENTER);

  boolean parTipo1 = (tipografiaVarianteAtiva == 0 && img1 != null && img1b != null);
  boolean parTipo2 = (tipografiaVarianteAtiva == 1 && img2 != null && img2b != null);

  if (parTipo1 || parTipo2) {
    PImage esquerda = parTipo1 ? img1 : img2;
    PImage direita = parTipo1 ? img1b : img2b;
    float w2 = alvoW * 0.62;
    float w3 = alvoW * 0.62;
    float h2 = w2 / ratioImagem(esquerda);
    float h3 = w3 / ratioImagem(direita);
    float gap = typoParGap;
    float total = w2 + w3 + gap;
    float x2 = -total * 0.5 + w2 * 0.5 + typoParXOffset;
    float x3 = x2 + w2 * 0.5 + gap + w3 * 0.5;
    float y2Local = parTipo2 ? 0 : (typoParYOffset * 0.5);
    float y3Local = parTipo2 ? typoVar2YOffsetA : (-typoParYOffset * 0.5);

    // Centro da marca no ponto de conexao entre as duas partes.
    float edgeRightLeft = x2 + w2 * 0.5;
    float edgeLeftRight = x3 - w3 * 0.5;
    float connX = (edgeRightLeft + edgeLeftRight) * 0.5;
    float connY = (y2Local + y3Local) * 0.5;

    desenharMarcaImagem(pg, esquerda, x2 - connX, y + y2Local - connY, w2, h2);
    desenharMarcaImagem(pg, direita, x3 - connX, y + y3Local - connY, w3, h3);
  } else {
    PImage ativa = null;
    if (tipografiaVarianteAtiva == 0) ativa = (img1 != null) ? img1 : img1b;
    if (tipografiaVarianteAtiva == 1) ativa = (img2 != null) ? img2 : img1;
    if (ativa == null) ativa = (img2 != null) ? img2 : ((img2b != null) ? img2b : img1b);
    if (ativa != null) {
      float h = alvoW / ratioImagem(ativa);
      desenharMarcaImagem(pg, ativa, 0, y, alvoW, h);
    }
  }

  pg.popStyle();
}

void desenharMarcaImagem(PGraphics pg, PImage img, float cx, float cy, float w, float h) {
  desenharMarcaImagemTint(pg, img, cx, cy, w, h, 255, 255, 255, typoMainAlpha * 2.55);
}

float ratioImagem(PImage img) {
  if (img == null) return 3.0;
  return max(0.1, img.width / float(max(1, img.height)));
}

PImage fotoEditorialPanfleto() {
  PImage frame = frameMidiaPanfletoAtual();
  if (frame != null && frame.width > 0 && frame.height > 0) return frame;
  if (panfletoFoto != null && panfletoFoto.width > 0 && panfletoFoto.height > 0) return panfletoFoto;
  if (estampaFoto != null && estampaFoto.width > 0 && estampaFoto.height > 0) return estampaFoto;
  return null;
}

void desenharFotoObjetoCircular(PGraphics pg, PImage img, float cx, float cy, float diam, float alpha) {
  if (diam <= 2) return;

  if (img == null || img.width <= 0 || img.height <= 0) {
    pg.pushStyle();
    pg.noFill();
    pg.stroke(255, 255, 255, alpha * 0.45);
    pg.strokeWeight(max(0.7, diam * 0.006));
    pg.ellipse(cx, cy, diam, diam);
    pg.popStyle();
    return;
  }

  int s = max(8, round(diam));
  PGraphics obj = createGraphics(s, s, P2D);
  obj.beginDraw();
  obj.clear();
  obj.imageMode(CENTER);
  float sc = max(s / float(img.width), s / float(img.height));
  obj.image(img, s * 0.5, s * 0.5, img.width * sc, img.height * sc);
  obj.endDraw();

  PGraphics maskPg = createGraphics(s, s);
  maskPg.beginDraw();
  maskPg.background(0);
  maskPg.noStroke();
  maskPg.fill(255);
  maskPg.ellipse(s * 0.5, s * 0.5, s, s);
  maskPg.endDraw();

  PImage out = obj.get();
  out.mask(maskPg.get());
  pg.pushStyle();
  pg.tint(255, alpha);
  pg.imageMode(CENTER);
  pg.image(out, cx, cy);
  pg.noTint();
  pg.popStyle();
}

void desenharFotoObjetoForma(PGraphics pg, PImage img, float cx, float cy, float w, float h, int forma, float alpha) {
  if (w <= 2 || h <= 2) return;
  if (forma == 5 || forma == 6) {
    desenharFotoObjetoMarcaPanfleto(pg, img, cx, cy, w, h, alpha, forma == 6);
    return;
  }
  if (forma == 0) {
    desenharFotoObjetoCircular(pg, img, cx, cy, min(w, h), alpha);
    return;
  }
  if (forma == 4) {
    desenharFotoObjetoRetangular(pg, img, cx - w * 0.5, cy - h * 0.5, w, h, alpha, 8);
    return;
  }

  if (img == null || img.width <= 0 || img.height <= 0) {
    pg.pushStyle();
    pg.noFill();
    pg.stroke(255, 255, 255, alpha * 0.45);
    pg.strokeWeight(max(0.7, min(w, h) * 0.006));
    desenharContornoFormaObjeto(pg, cx, cy, w, h, forma);
    pg.popStyle();
    return;
  }

  int sw = max(8, round(w));
  int sh = max(8, round(h));
  PGraphics obj = createGraphics(sw, sh, P2D);
  obj.beginDraw();
  obj.clear();
  obj.imageMode(CENTER);
  float sc = max(sw / float(img.width), sh / float(img.height));
  obj.image(img, sw * 0.5, sh * 0.5, img.width * sc, img.height * sc);
  obj.endDraw();

  PGraphics maskPg = createGraphics(sw, sh);
  maskPg.beginDraw();
  maskPg.background(0);
  maskPg.noStroke();
  maskPg.fill(255);
  desenharMascaraFormaObjeto(maskPg, sw * 0.5, sh * 0.5, sw, sh, forma);
  maskPg.endDraw();

  PImage out = obj.get();
  out.mask(maskPg.get());
  pg.pushStyle();
  pg.tint(255, alpha);
  pg.imageMode(CENTER);
  pg.image(out, cx, cy);
  pg.noTint();
  pg.popStyle();
}

void desenharFotoObjetoMarcaPanfleto(PGraphics pg, PImage img, float cx, float cy, float w, float h, float alpha, boolean reativo) {
  if (activeBrand == null || activeBrand.sourceImage == null || activeBrand.sourceImage.width <= 0 || activeBrand.sourceImage.height <= 0) {
    desenharFotoObjetoCircular(pg, img, cx, cy, min(w, h), alpha);
    return;
  }

  PImage maskImg = activeBrand.sourceImage;
  int sw = max(8, round(w));
  int sh = max(8, round(h));
  PGraphics obj = createGraphics(sw, sh, P2D);
  obj.beginDraw();
  obj.clear();
  obj.imageMode(CENTER);
  if (img != null && img.width > 0 && img.height > 0) {
    float sc = max(sw / float(img.width), sh / float(img.height));
    obj.image(img, sw * 0.5, sh * 0.5, img.width * sc, img.height * sc);
  } else {
    obj.background(255, 255, 255, 160);
  }
  obj.endDraw();

  PGraphics maskPg = createGraphics(sw, sh, P2D);
  maskPg.beginDraw();
  maskPg.clear();
  maskPg.imageMode(CENTER);
  float maskSc = min(sw / float(maskImg.width), sh / float(maskImg.height));
  maskPg.tint(255);
  maskPg.image(maskImg, sw * 0.5, sh * 0.5, maskImg.width * maskSc, maskImg.height * maskSc);
  maskPg.noTint();
  maskPg.endDraw();

  PImage out = obj.get();
  out.mask(maskPg.get());
  pg.pushStyle();
  pg.tint(255, alpha);
  pg.imageMode(CENTER);
  pg.image(out, cx, cy);
  pg.noTint();
  if (reativo) {
    desenharMarcaAoVivoNoPanfleto(pg, activeBrand, cx, cy, w * 0.96);
  }
  pg.popStyle();
}

void desenharMascaraFormaObjeto(PGraphics pg, float cx, float cy, float w, float h, int forma) {
  if (forma == 5 || forma == 6) {
    pg.rect(cx - w * 0.5, cy - h * 0.5, w, h, 8);
  } else if (forma == 1) {
    pg.ellipse(cx, cy, w, h * 0.72);
  } else if (forma == 2) {
    float s = min(w, h);
    pg.rect(cx - s * 0.5, cy - s * 0.5, s, s, 2);
  } else if (forma == 3) {
    pg.beginShape();
    pg.vertex(cx, cy - h * 0.5);
    pg.vertex(cx + w * 0.5, cy);
    pg.vertex(cx, cy + h * 0.5);
    pg.vertex(cx - w * 0.5, cy);
    pg.endShape(CLOSE);
  } else {
    pg.rect(cx - w * 0.5, cy - h * 0.5, w, h, 8);
  }
}

void desenharContornoFormaObjeto(PGraphics pg, float cx, float cy, float w, float h, int forma) {
  if (forma == 5 || forma == 6) {
    pg.rect(cx - w * 0.5, cy - h * 0.5, w, h, 8);
  } else if (forma == 1) {
    pg.ellipse(cx, cy, w, h * 0.72);
  } else if (forma == 2) {
    float s = min(w, h);
    pg.rect(cx - s * 0.5, cy - s * 0.5, s, s, 2);
  } else if (forma == 3) {
    pg.beginShape();
    pg.vertex(cx, cy - h * 0.5);
    pg.vertex(cx + w * 0.5, cy);
    pg.vertex(cx, cy + h * 0.5);
    pg.vertex(cx - w * 0.5, cy);
    pg.endShape(CLOSE);
  } else {
    pg.rect(cx - w * 0.5, cy - h * 0.5, w, h, 8);
  }
}

void desenharFotoObjetoRetangular(PGraphics pg, PImage img, float x, float y, float w, float h, float alpha, float raio) {
  if (w <= 2 || h <= 2) return;
  pg.pushStyle();
  if (img != null && img.width > 0 && img.height > 0) {
    pg.tint(255, alpha);
    desenharImagemCover(pg, img, x, y, w, h);
    pg.noTint();
  } else {
    pg.noFill();
    pg.stroke(255, 255, 255, alpha * 0.45);
    pg.strokeWeight(max(0.8, min(w, h) * 0.006));
    pg.rect(x, y, w, h, raio);
  }
  pg.popStyle();
}

void desenharFotoFundoPanfleto(PGraphics pg, PImage img, float x, float y, float w, float h) {
  if (img == null || img.width <= 0 || img.height <= 0) return;

  pg.pushStyle();
  pg.clip(round(x), round(y), round(w), round(h));
  pg.noTint();
  pg.imageMode(CENTER);
  float scale = max(w / img.width, h / img.height);
  pg.image(img, x + w * 0.5, y + h * 0.5, img.width * scale, img.height * scale);
  pg.noClip();
  pg.popStyle();
}

void desenharObjetosFotoEditorial(PGraphics pg, float x, float y, float w, float h, int layout, int bgR, int bgG, int bgB) {
  PImage img = fotoEditorialPanfleto();
  pg.pushStyle();
  pg.colorMode(RGB, 255);
  int qtd = constrain(panfletoObjetoQuantidade, 1, 6);
  int forma = constrain(panfletoObjetoForma, 0, panfletoObjetoFormaLabels.length - 1);

  if (layout == 0) {
    float d = w * 0.21;
    float cy = y + h * 0.80;
    for (int i = 0; i < qtd; i++) {
      float u = qtd == 1 ? 0.5 : map(i, 0, qtd - 1, 0.18, 0.82);
      desenharFotoObjetoForma(pg, img, x + w * u, cy + sin(i * 1.7) * h * 0.018, d, d * (forma == 4 ? 0.72 : 1.0), forma, 232);
    }
  } else if (layout == 1) {
    for (int i = 0; i < qtd; i++) {
      float sc = 1.0 - i * 0.10;
      float px = x + w * (0.70 + (i - (qtd - 1) * 0.5) * 0.055);
      float py = y + h * (0.48 + sin(i * 1.3) * 0.045);
      desenharFotoObjetoForma(pg, img, px, py, w * 0.62 * sc, w * 0.62 * sc * (forma == 4 ? 0.72 : 1.0), forma, 235 - i * 12);
    }
  } else if (layout == 2) {
    for (int i = 0; i < qtd; i++) {
      float u = qtd == 1 ? 0.54 : map(i, 0, qtd - 1, 0.24, 0.84);
      float d = w * (0.82 - i * 0.045);
      desenharFotoObjetoForma(pg, img, x + w * u, y + h * (0.98 + sin(i) * 0.035), d, d * (forma == 4 ? 0.66 : 1.0), forma, 238 - i * 10);
    }
  } else if (layout == 3) {
    for (int i = 0; i < qtd; i++) {
      float px = x + w * (0.25 + (i % 3) * 0.20);
      float py = y + h * (0.38 + (i / 3) * 0.23 + sin(i * 1.1) * 0.035);
      float ow = w * (0.30 + (i % 2) * 0.08);
      float oh = h * (0.20 + ((i + 1) % 2) * 0.10);
      desenharFotoObjetoForma(pg, img, px, py, ow, oh, forma == 0 ? 4 : forma, 225 - i * 10);
    }
    pg.fill(bgR, bgG, bgB, 38);
    pg.rect(x + w * 0.50, y + h * 0.40, w * 0.16, h * 0.42);
  }

  pg.popStyle();
}

void desenharTituloVerticalPanfleto(PGraphics pg, String txt, float x, float y, float size, int r, int g, int b) {
  String conteudo = normalizarTextoPanfleto(txt);
  if (conteudo.length() == 0) return;
  pg.pushMatrix();
  pg.translate(x, y);
  pg.rotate(-HALF_PI);
  pg.fill(r, g, b, 245);
  pg.textFont(fontHelvBold);
  pg.textAlign(CENTER, CENTER);
  pg.textSize(size);
  pg.text(conteudo.toUpperCase(), 0, 0);
  pg.popMatrix();
}

void desenharTextosLayoutEditorial(PGraphics pg, float x, float y, float w, float h, float cx, float cy, float escalaPosY, float escalaConteudo, int txR, int txG, int txB, float tituloSize, float subtituloSize, float rodapeSize) {
  float offsetX = panfletoTextoGrupoX * escalaPosY;
  float offsetY = panfletoTextoGrupoY * escalaPosY;
  float titleMove = panfletoTituloY * escalaPosY * 0.50;
  float subMove = panfletoSubtituloY * escalaPosY * 0.50;
  float footMove = panfletoRodapeY * escalaPosY * 0.50;
  float titleX = panfletoTituloX * escalaPosY * 0.50;
  float subX = panfletoSubtituloX * escalaPosY * 0.50;
  float footX = panfletoRodapeX * escalaPosY * 0.50;
  int layout = panfletoLayoutAtivo;

  pg.fill(txR, txG, txB, 255);

  if (layout == 0) {
    float textoX = x + offsetX;
    pg.textFont(fontHelvBold);
    pg.textSize(tituloSize * 1.12);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[0], textoX + titleX, w, y, h, y + h * 0.33 + offsetY + titleMove, 1, h * 0.34);
    pg.textFont(fontHelv);
    pg.textSize(subtituloSize * 0.74);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[1], textoX + subX, w, y, h, y + h * 0.57 + offsetY + subMove, 1, h * 0.20);
    pg.textSize(rodapeSize * 0.78);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[2], textoX + footX, w, y, h, y + h * 0.93 + offsetY + footMove, 1, h * 0.10);
  } else if (layout == 1) {
    desenharTituloVerticalPanfleto(pg, panfletoTextoValores[0], x + w * 0.12 + offsetX + titleX, y + h * 0.52 + offsetY + titleMove, tituloSize * 1.55, txR, txG, txB);
    pg.textFont(fontHelv);
    pg.textSize(subtituloSize * 0.74);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[1], x + w * 0.46 + offsetX + subX, w * 0.42, y, h, y + h * 0.24 + offsetY + subMove, 0, h * 0.20);
    pg.textSize(rodapeSize * 0.84);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[2], x + w * 0.18 + offsetX + footX, w * 0.36, y, h, y + h * 0.80 + offsetY + footMove, 0, h * 0.16);
  } else if (layout == 2) {
    pg.textFont(fontHelvBold);
    pg.textSize(tituloSize * 1.08);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[0], x + offsetX + titleX, w * 0.86, y, h, y + h * 0.16 + offsetY + titleMove, 0, h * 0.23);
    pg.textFont(fontHelv);
    pg.textSize(subtituloSize * 0.66);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[1], x + w * 0.08 + offsetX + subX, w * 0.38, y, h, y + h * 0.47 + offsetY + subMove, 0, h * 0.22);
    pg.textSize(rodapeSize * 0.74);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[2], x + w * 0.54 + offsetX + footX, w * 0.34, y, h, y + h * 0.49 + offsetY + footMove, 0, h * 0.22);
  } else if (layout == 3) {
    pg.textFont(fontHelvBold);
    pg.textSize(tituloSize * 0.94);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[0], x + offsetX + titleX, w, y, h, y + h * 0.16 + offsetY + titleMove, 1, h * 0.24);
    pg.textFont(fontHelv);
    pg.textSize(subtituloSize * 0.66);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[1], x + w * 0.10 + offsetX + subX, w * 0.38, y, h, y + h * 0.77 + offsetY + subMove, 0, h * 0.18);
    pg.textSize(rodapeSize * 0.72);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[2], x + w * 0.58 + offsetX + footX, w * 0.32, y, h, y + h * 0.76 + offsetY + footMove, 2, h * 0.18);
  } else {
    pg.textFont(fontHelvBold);
    pg.textSize(tituloSize * 0.92);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[0], x + offsetX + titleX, w, y, h, y + h * 0.17 + offsetY + titleMove, 1, h * 0.22);
    pg.textFont(fontHelv);
    pg.textSize(subtituloSize * 0.72);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[1], x + w * 0.10 + offsetX + subX, w * 0.42, y, h, y + h * 0.78 + offsetY + subMove, 0, h * 0.16);
    pg.textSize(rodapeSize * 0.76);
    desenharTextoAlinhadoPanfleto(pg, panfletoTextoValores[2], x + w * 0.50 + offsetX + footX, w * 0.40, y, h, y + h * 0.78 + offsetY + footMove, 2, h * 0.16);
  }

  for (int i = 0; i < panfletoTextoExtraCount; i++) {
    String txt = panfletoTextoValores[6 + i];
    float extraSize = lerNumeroCampoPanfleto(10 + i, 18, 6, 180) * escalaConteudo;
    float ex = x + w * 0.50 + offsetX + panfletoExtraTextoX[i] * escalaPosY * 0.50;
    float ey = y + h * (0.22 + i * 0.10) + offsetY + panfletoExtraTextoY[i] * escalaPosY * 0.50;
    pg.textFont(fontHelv);
    pg.textSize(extraSize);
    desenharTextoAlinhadoPanfleto(pg, txt, ex - w * 0.24, w * 0.48, y, h, ey, 1, h * 0.12);
  }
}

void desenharPanfleto(PGraphics pg) {
  float ratio = ratioFormatoPanfleto();

  float safeLeft = exportandoPanfletoLimpo ? 0 : (mostrarBarra ? max(0, menuOffsetX + menuWidth) : 0);
  float safeRight = exportandoPanfletoLimpo ? pg.width : (mostrarBarraPadroes ? min(pg.width, pg.width - painelPadraoWidth + painelPadraoOffsetX) : pg.width);
  float safeTop = exportandoPanfletoLimpo ? 0 : min(pg.height - 80, uiHeaderHeight + uiTabsHeight + 18);
  float safeBottom = exportandoPanfletoLimpo ? pg.height : pg.height - 22;
  if (safeRight - safeLeft < pg.width * 0.38) {
    safeLeft = pg.width * 0.20;
    safeRight = pg.width * 0.80;
  }

  float areaW = max(160, safeRight - safeLeft);
  float areaH = max(180, safeBottom - safeTop);
  float maxW = areaW * (exportandoPanfletoLimpo ? 1.0 : 0.84);
  float maxH = areaH * (exportandoPanfletoLimpo ? 1.0 : 0.92);
  float w = maxW;
  float h = w / ratio;
  if (h > maxH) {
    h = maxH;
    w = h * ratio;
  }

  float x = safeLeft + (areaW - w) * 0.5;
  float y = safeTop + (areaH - h) * 0.5;
  panfletoRenderX = x;
  panfletoRenderY = y;
  panfletoRenderW = w;
  panfletoRenderH = h;
  float cx = x + w * 0.5;
  float cy = y + h * 0.5;
  float escalaResponsiva = constrain(min(w / 413.0, h / 584.0), 0.42, 1.65);
  float redimReflexivo = 1.0 + panfletoTemaPulse * 0.04;
  float escalaConteudo = escalaResponsiva * redimReflexivo;
  float escalaPosY = escalaResponsiva;
  float raioPanfleto = exportandoPanfletoLimpo ? 0 : 16;

  int[] tema = temaPanfletoAtual();
  int bgR = tema[0];
  int bgG = tema[1];
  int bgB = tema[2];
  int txR = tema[3];
  int txG = tema[4];
  int txB = tema[5];
  int overlayAlpha = tema[6];
  int[] corTexto = corTextoPanfletoAtual(txR, txG, txB);
  txR = corTexto[0];
  txG = corTexto[1];
  txB = corTexto[2];

  float tituloSize = lerNumeroCampoPanfleto(3, 62, 8, 260) * escalaConteudo;
  float subtituloSize = lerNumeroCampoPanfleto(4, 28, 8, 220) * escalaConteudo;
  float rodapeSize = lerNumeroCampoPanfleto(5, 16, 8, 180) * escalaConteudo;

  pg.pushStyle();
  pg.colorMode(RGB, 255);
  pg.noStroke();
  if (!exportandoPanfletoLimpo) {
    pg.fill(0, 0, 0, 86);
    pg.rect(x + 10, y + 12, w, h, 18);
  }

  pg.fill(bgR, bgG, bgB);
  pg.rect(x, y, w, h, raioPanfleto);
  if (panfletoLayoutAtivo == 4 && fotoEditorialPanfleto() != null) {
    desenharFotoFundoPanfleto(pg, fotoEditorialPanfleto(), x, y, w, h);
    pg.fill(bgR, bgG, bgB, 8);
    pg.rect(x, y, w, h, raioPanfleto);
  }
  if (panfletoLayoutAtivo != 4) {
    desenharObjetosFotoEditorial(pg, x, y, w, h, panfletoLayoutAtivo, bgR, bgG, bgB);
  }

  if (panfletoEstampaAtiva) {
    desenharEstampaNoPanfleto(pg, x, y, w, h, escalaConteudo, txR, txG, txB);
  }

  pg.noFill();
  pg.stroke(255, 255, 255, 36);
  pg.strokeWeight(1.2);
  if (!exportandoPanfletoLimpo) {
    pg.rect(x, y, w, h, raioPanfleto);
  }

  pg.clip(round(x), round(y), round(w), round(h));

  pg.fill(txR, txG, txB, 255);
  pg.textAlign(CENTER, CENTER);

  float marcaW = w * 0.52 * constrain(panfletoMarcaEscala, 0.18, 9.00);
  float marcaBaseCx = centroAlinhadoItemPanfleto(x, w, marcaW, panfletoMarcaAlign);
  float marcaCx = constrain(marcaBaseCx + panfletoMarcaX * escalaPosY, x + w * 0.08, x + w * 0.92);
  float marcaCy = constrain(cy + panfletoMarcaY * escalaPosY, y + h * 0.16, y + h * 0.84);

  // Camada de simbolo pausada temporariamente. Mantive o codigo abaixo comentado
  // porque essa parte vai voltar depois com uma logica propria de camada.
  // if (panfletoMostrarSimbolo) {
  //   float baseSymX = marcaCx + panfletoSimboloX * escalaPosY;
  //   float baseSymY = marcaCy + panfletoSimboloY * escalaPosY;
  //   if (panfletoSimboloAcima) {
  //     baseSymY -= w * 0.20;
  //   }
  //   desenharSimboloPanfleto(pg, baseSymX, baseSymY, w * 0.26 * panfletoSimboloEscala * escalaConteudo);
  // }

  float marcaEditorialAlpha = panfletoLayoutAtivo == 4 ? 112 : 62;
  desenharMarcaNoPanfleto(pg, marcaCx, marcaCy, marcaW * (panfletoLayoutAtivo == 4 ? 0.78 : 0.42), txR, txG, txB, marcaEditorialAlpha);

  if (panfletoLogoExtraAtiva && activeBrand != null) {
    float extraW = w * 0.42 * constrain(panfletoLogoExtraEscala, 0.08, 4.0);
    float extraCx = constrain(cx + panfletoLogoExtraX * escalaPosY, x - w * 0.35, x + w * 1.35);
    float extraCy = constrain(cy + panfletoLogoExtraY * escalaPosY, y - h * 0.35, y + h * 1.35);
    desenharMarcaAoVivoNoPanfleto(pg, activeBrand, extraCx, extraCy, extraW);
  }

  if (panfletoMostrarTextos) {
    desenharTextosLayoutEditorial(pg, x, y, w, h, cx, cy, escalaPosY, escalaConteudo, txR, txG, txB, tituloSize, subtituloSize, rodapeSize);
  }
  pg.noClip();
  pg.popStyle();
}

void desenharEstampaNoPanfleto(PGraphics pg, float px, float py, float pw, float ph, float escalaConteudo, int txR, int txG, int txB) {
  MutableBrand brand = activeBrand;
  boolean temMarca = brand != null && brand.originalPoints != null && brand.originalPoints.size() > 2;
  PImage textura = estampaFoto != null ? estampaFoto : (temMarca ? brand.sourceImage : null);
  if (!temMarca && textura == null) return;

  if (existeMascaraOrganicaAtiva()) {
    desenharMascarasOrganicasPanfleto(pg, px, py, pw, ph, escalaConteudo, txR, txG, txB, brand, textura);
    return;
  }

  float energy = audioData != null ? constrain(audioData.energy + audioData.volume * 0.35, 0, 1.35) : 0;
  float bass = audioData != null ? constrain(audioData.bass * 1.25, 0, 1.6) : 0;
  float mid = audioData != null ? constrain(audioData.mid * 1.25, 0, 1.6) : 0;
  float treble = audioData != null ? constrain(audioData.treble * 1.35, 0, 1.8) : 0;
  float alpha = constrain(panfletoEstampaIntensidade * 185.0 * (0.65 + energy * 0.28), 0, 168);
  float ax = px;
  float ay = py;
  float aw = pw;
  float ah = ph;

  if (panfletoEstampaAplicacao == 1 || panfletoEstampaAplicacao == 2) {
    aw = pw * constrain(panfletoEstampaW, 0.08, 1.0);
    ah = ph * constrain(panfletoEstampaH, 0.08, 1.0);
    ax = px + pw * 0.5 + panfletoEstampaX * pw - aw * 0.5;
    ay = py + ph * 0.5 + panfletoEstampaY * ph - ah * 0.5;
  } else if (panfletoEstampaAplicacao == 3) {
    aw = pw * 0.90;
    ah = ph * 0.90;
    ax = px + pw * 0.05;
    ay = py + ph * 0.05;
  }

  ax = constrain(ax, px, px + pw - 4);
  ay = constrain(ay, py, py + ph - 4);
  aw = constrain(aw, 4, px + pw - ax);
  ah = constrain(ah, 4, py + ph - ay);

  pg.pushStyle();
  if (panfletoEstampaBlend == 1) pg.blendMode(MULTIPLY);
  else if (panfletoEstampaBlend == 2) pg.blendMode(SCREEN);
  else if (panfletoEstampaBlend == 3) pg.blendMode(SCREEN);
  else pg.blendMode(BLEND);
  pg.clip(round(ax), round(ay), round(aw), round(ah));

  int corA = mutationParams != null ? mutationParams.primaryColor : color(txR, txG, txB);
  int corB = mutationParams != null ? mutationParams.secondaryColor : UI_GREEN;
  float ar = red(corA), ag = green(corA), ab = blue(corA);
  float br = red(corB), bg = green(corB), bb = blue(corB);
  if (ar + ag + ab < 16) {
    ar = txR; ag = txG; ab = txB;
  }
  if (br + bg + bb < 16) {
    br = 33; bg = 150; bb = 243;
  }
  boolean fundoEscuro = (txR + txG + txB) > 520;
  if (fundoEscuro) {
    ar = 32;
    ag = 210;
    ab = 184;
    br = 244;
    bg = 82;
    bb = 146;
  }

  int modo = constrain(formaPadraoAtiva, 0, estampaModoLabels.length - 1);
  float rep = constrain(panfletoEstampaRepeticao, 0.4, 4.0);
  float tileW = max(68 * escalaConteudo, aw / max(1.0, rep * 1.65));
  float tileH = max(68 * escalaConteudo, ah / max(1.0, rep * 1.85));
  int cols = constrain(ceil(aw / tileW) + 1, 1, 9);
  int rows = constrain(ceil(ah / tileH) + 1, 1, 10);
  float t = noiseDynamicTime * (0.42 + treble * 0.25) + semente * 0.13;

  for (int gy = -1; gy < rows; gy++) {
    for (int gx = -1; gx < cols; gx++) {
      float u = (gx + 0.5) / max(1, cols - 1);
      float v = (gy + 0.5) / max(1, rows - 1);
      float cx = ax + gx * tileW + tileW * 0.5;
      float cy = ay + gy * tileH + tileH * 0.5;
      float n = noise(gx * 0.37 + t, gy * 0.37 + 19.0, t);
      cx += (n - 0.5) * mid * 26 * escalaConteudo;
      cy += sin(t * 3.2 + gx * 0.8 + gy) * treble * 8 * escalaConteudo;
      if (!pontoDentroMascaraEstampa(cx, cy, ax, ay, aw, ah, u, v, n)) continue;

      pg.pushMatrix();
      pg.translate(cx, cy);
      pg.rotate((n - 0.5) * (0.18 + treble * 0.06));
      if (modo == 0 && temMarca) {
        desenharModuloCampoEstampa(pg, brand, tileW, tileH, panfletoEstampaEscala * 0.92, ar, ag, ab, br, bg, bb, alpha * 0.78, t, bass, mid);
      } else if (modo == 1 && temMarca) {
        desenharModuloContornoEstampa(pg, brand, tileW, tileH, panfletoEstampaEscala, ar, ag, ab, br, bg, bb, alpha, t, bass, mid, treble);
      } else if (modo == 2 && temMarca) {
        desenharModuloRitmoEstampa(pg, brand, tileW, tileH, panfletoEstampaEscala, ar, ag, ab, br, bg, bb, alpha, t, bass, mid, treble);
      } else if (modo == 3) {
        desenharModuloRecorteEstampa(pg, textura, tileW, tileH, panfletoEstampaEscala, ar, ag, ab, alpha, n);
      } else if (temMarca) {
        desenharModuloCampoEstampa(pg, brand, tileW, tileH, panfletoEstampaEscala, ar, ag, ab, br, bg, bb, alpha, t, bass, mid);
      } else {
        desenharModuloRecorteEstampa(pg, textura, tileW, tileH, panfletoEstampaEscala, ar, ag, ab, alpha, n);
      }
      pg.popMatrix();
    }
  }

  pg.noClip();
  pg.blendMode(BLEND);
  pg.popStyle();
}

void desenharConflitoBitmapPanfleto(PGraphics pg, float x, float y, float w, float h, float escalaConteudo) {
  float energy = audioData != null ? constrain(audioData.energy + audioData.volume * 0.35, 0, 1.25) : 0;
  float bass = audioData != null ? constrain(audioData.bass * 1.25, 0, 1.55) : 0;
  float mid = audioData != null ? constrain(audioData.mid * 1.20, 0, 1.45) : 0;
  float treble = audioData != null ? constrain(audioData.treble * 1.35, 0, 1.65) : 0;
  float cx = x + w * 0.50;
  float cy = y + h * 0.50;
  float blobW = w * (0.64 + bass * 0.035);
  float blobH = h * (0.47 + mid * 0.035);
  float step = max(3.2, min(w, h) * 0.010 * (1.08 - min(0.45, energy * 0.24)));
  float t = noiseDynamicTime * 0.36 + semente * 0.12;

  pg.pushStyle();
  pg.noStroke();

  for (int layer = 0; layer < 4; layer++) {
    float ox = (layer - 1.5) * w * 0.018;
    float oy = sin(t + layer) * h * 0.010;
    int lr = layer == 0 ? 27 : (layer == 1 ? 26 : (layer == 2 ? 242 : 250));
    int lg = layer == 0 ? 180 : (layer == 1 ? 48 : (layer == 2 ? 208 : 74));
    int lb = layer == 0 ? 170 : (layer == 1 ? 64 : (layer == 2 ? 62 : 148));
    float alpha = layer == 3 ? 72 : 116;
    float dotMul = layer == 3 ? 0.62 : 0.92;

    for (float yy = -blobH * 0.56; yy <= blobH * 0.56; yy += step) {
      for (float xx = -blobW * 0.56; xx <= blobW * 0.56; xx += step) {
        float nx = xx / max(1, blobW * 0.5);
        float ny = yy / max(1, blobH * 0.5);
        float d = sqrt(nx * nx + ny * ny);
        float angle = atan2(ny, nx);
        float edge = 0.82 + noise(cos(angle) * 1.7 + layer, sin(angle) * 1.7 + layer, t) * 0.38;
        float holes = noise(xx * 0.018 + layer * 7.0, yy * 0.018 + 11.0, t * 0.6);
        if (d > edge || holes > 0.72 + layer * 0.018) continue;

        float local = noise(xx * 0.045 + layer, yy * 0.045, t + layer * 0.31);
        float px = cx + xx + ox + (local - 0.5) * mid * 8 * escalaConteudo;
        float py = cy + yy + oy + sin(t * 4.0 + xx * 0.018) * treble * 3.5 * escalaConteudo;
        float dot = step * dotMul * (0.46 + local * 0.95 + bass * 0.18);
        pg.fill(lr, lg, lb, alpha * (0.55 + local * 0.55));
        pg.rect(px, py, dot, dot);
      }
    }
  }

  if (activeBrand != null && activeBrand.originalPoints.size() > 2) {
    pg.pushMatrix();
    pg.translate(cx, cy);
    pg.rotate(sin(t) * 0.04);
    desenharMarcaMutavelNoPanfleto(pg, activeBrand, 0, 0, w * 0.32 * (0.92 + energy * 0.05), 18, 18, 22, 58 + energy * 38);
    pg.popMatrix();
  }

  pg.fill(22, 22, 25, 205);
  pg.textFont(fontHelv);
  pg.textAlign(LEFT, TOP);
  pg.textSize(max(7, 8.5 * escalaConteudo));
  pg.text("001. CLEAN PATHS, FULLY EDITABLE AND SCALABLE", x + w * 0.075, y + h * 0.145);
  pg.text("002. COLORFUL DITHER-STYLE VECTOR TEXTURES", x + w * 0.075, y + h * 0.165);
  pg.text("003. COMPATIBLE WITH LIVE SOUND INPUT", x + w * 0.075, y + h * 0.185);

  pg.textAlign(RIGHT, TOP);
  pg.text("YOUR IMAGE, YOUR RULES: RESIZE, RESHAPE, RECOLOR", x + w * 0.92, y + h * 0.055);
  pg.text("BUILT TO ADAPT", x + w * 0.92, y + h * 0.076);

  pg.noFill();
  pg.stroke(18, 18, 20, 135);
  pg.strokeWeight(max(0.8, escalaConteudo));
  pg.rect(x + w * 0.72, y + h * 0.765, w * 0.20, h * 0.12);
  pg.noStroke();
  pg.fill(18, 18, 20, 210);
  pg.textFont(fontHelvBold);
  pg.textAlign(CENTER, CENTER);
  pg.textSize(max(46, h * 0.095));
  pg.text("144", x + w * 0.82, y + h * 0.825);

  pg.popStyle();
}

boolean existeMascaraOrganicaAtiva() {
  for (int i = 0; i < panfletoMascaraAtiva.length; i++) {
    if (panfletoMascaraAtiva[i]) return true;
  }
  return false;
}

void desenharMascarasOrganicasPanfleto(PGraphics pg, float px, float py, float pw, float ph, float escalaConteudo, int txR, int txG, int txB, MutableBrand brand, PImage textura) {
  float energy = audioData != null ? constrain(audioData.energy + audioData.volume * 0.36, 0, 1.35) : 0;
  float bass = audioData != null ? constrain(audioData.bass * 1.25, 0, 1.65) : 0;
  float mid = audioData != null ? constrain(audioData.mid * 1.20, 0, 1.55) : 0;
  float treble = audioData != null ? constrain(audioData.treble * 1.35, 0, 1.75) : 0;
  float t = noiseDynamicTime * (0.35 + treble * 0.22) + semente * 0.10;
  int corA = mutationParams != null ? mutationParams.primaryColor : color(txR, txG, txB);
  int corB = mutationParams != null ? mutationParams.secondaryColor : UI_GREEN;
  float ar = red(corA), ag = green(corA), ab = blue(corA);
  float br = red(corB), bg = green(corB), bb = blue(corB);
  if (ar + ag + ab < 16) {
    ar = txR; ag = txG; ab = txB;
  }
  if (br + bg + bb < 16) {
    br = 33; bg = 150; bb = 243;
  }
  boolean fundoEscuro = (txR + txG + txB) < 270;
  if (fundoEscuro) {
    ar = 30; ag = 220; ab = 188;
    br = 245; bg = 88; bb = 152;
  }

  pg.pushStyle();
  pg.blendMode(fundoEscuro ? SCREEN : BLEND);
  pg.rectMode(CENTER);
  pg.clip(round(px), round(py), round(pw), round(ph));

  for (int m = 0; m < panfletoMascaraAtiva.length; m++) {
    if (!panfletoMascaraAtiva[m]) continue;
    float reatividade = panfletoMascaraSom[m];
    float cx = px + pw * (0.5 + panfletoMascaraX[m]);
    float cy = py + ph * (0.5 + panfletoMascaraY[m]);
    float mw = pw * panfletoMascaraW[m] * (1.0 + bass * 0.08 * reatividade);
    float mh = ph * panfletoMascaraH[m] * (1.0 + bass * 0.10 * reatividade);
    float rot = panfletoMascaraRot[m] + sin(t + m) * 0.035 * reatividade;
    float step = max(5.2, min(pw, ph) * 0.017 / max(0.60, panfletoMascaraEspessura[m]));
    float alpha = constrain((118 + panfletoEstampaIntensidade * 168) * (0.92 + energy * 0.30) * (0.82 + panfletoMascaraEspessura[m] * 0.36), 135, 255);

    for (float yy = -mh * 0.62; yy <= mh * 0.62; yy += step) {
      for (float xx = -mw * 0.62; xx <= mw * 0.62; xx += step) {
        float rx = cos(rot) * xx - sin(rot) * yy;
        float ry = sin(rot) * xx + cos(rot) * yy;
        float sx = cx + rx;
        float sy = cy + ry;
        float nx = xx / max(1, mw * 0.5);
        float ny = yy / max(1, mh * 0.5);
        float localNoise = noise(nx * 2.4 + m * 5.0, ny * 2.4 + 9.0, t);
        if (!pontoDentroMascaraOrganica(nx, ny, localNoise, panfletoMascaraFluxo[m], panfletoMascaraCurvatura[m], panfletoMascaraEspessura[m], mid * reatividade, treble * reatividade, t)) continue;
        desenharConteudoMascaraOrganica(pg, sx, sy, nx, ny, step, m, panfletoMascaraConteudo[m], brand, textura, ar, ag, ab, br, bg, bb, alpha, localNoise, t, bass, mid, treble);
      }
    }

    pg.noFill();
    pg.stroke(lerp(ar, br, 0.45), lerp(ag, bg, 0.45), lerp(ab, bb, 0.45), alpha * 0.70);
    pg.strokeWeight(max(0.75, escalaConteudo * (0.95 + bass * 0.85)));
    pg.beginShape();
    int vertices = 96;
    for (int i = 0; i <= vertices; i++) {
      float a = TWO_PI * i / vertices;
      float radius = 1.0 + (noise(cos(a) * 2.0 + m, sin(a) * 2.0 + m, t) - 0.5) * panfletoMascaraCurvatura[m] * 0.42;
      float bx = cos(a) * mw * 0.5 * radius;
      float by = sin(a) * mh * 0.5 * radius;
      if (panfletoMascaraFluxo[m] == 1) by *= 0.42 + panfletoMascaraEspessura[m] * 0.52;
      if (panfletoMascaraFluxo[m] == 2) bx += sin(by * 0.035 + t * 3.0) * mw * 0.08 * panfletoMascaraCurvatura[m];
      float vx = cx + cos(rot) * bx - sin(rot) * by;
      float vy = cy + sin(rot) * bx + cos(rot) * by;
      pg.curveVertex(vx, vy);
    }
    pg.endShape();
  }

  pg.noClip();
  pg.blendMode(BLEND);
  pg.popStyle();
}

boolean pontoDentroMascaraOrganica(float nx, float ny, float n, int fluxo, float curvatura, float espessura, float mid, float treble, float t) {
  if (fluxo == 1) {
    float wave = sin(nx * PI * (1.8 + curvatura * 3.2) + t * 2.2) * 0.20 * curvatura;
    return abs(ny - wave) < (0.18 + espessura * 0.42 + mid * 0.10) && abs(nx) < 1.05 + n * 0.16;
  }
  if (fluxo == 2) {
    float ribbon = sin(ny * PI * 2.2 + t * 2.0) * 0.18 * curvatura;
    float d = abs(nx + ribbon);
    return d < (0.22 + espessura * 0.36 + mid * 0.10) && abs(ny) < 1.05 + treble * 0.08;
  }
  float angle = atan2(ny, nx);
  float d = sqrt(nx * nx + ny * ny);
  float edge = 0.78 + n * curvatura * 0.34 + sin(angle * 3.0 + t) * curvatura * 0.08;
  return d < edge * (0.62 + espessura * 0.52 + mid * 0.06);
}

void desenharConteudoMascaraOrganica(PGraphics pg, float x, float y, float nx, float ny, float step, int maskIdx, int conteudo, MutableBrand brand, PImage textura, float ar, float ag, float ab, float br, float bg, float bb, float alpha, float n, float t, float bass, float mid, float treble) {
  float pulse = 0.78 + bass * 0.26 + mid * 0.18 + sin(t * 3.2 + nx * 9.0 + maskIdx) * treble * 0.10;
  float hueMix = noise(nx * 4.8 + maskIdx * 11.0, ny * 4.8 + 17.0, t * 0.45);
  float cr = lerp(ar, br, hueMix);
  float cg = lerp(ag, bg, hueMix);
  float cb = lerp(ab, bb, hueMix);
  float yr = 248;
  float yg = 216;
  float yb = 64;

  pg.noStroke();
  pg.fill(cr, cg, cb, alpha * 0.22);
  pg.ellipse(x, y, step * (3.0 + bass * 1.0) * pulse, step * (2.55 + mid * 0.8) * pulse);

  if (conteudo == 4) {
    float cell = step * (1.25 + bass * 0.55);
    float snapX = round(x / cell) * cell;
    float snapY = round(y / cell) * cell;
    float gate = noise(nx * 7.0 + maskIdx * 2.0, ny * 7.0 + 40.0, t);
    pg.noFill();
    pg.stroke(cr, cg, cb, alpha * (0.58 + gate * 0.36));
    pg.strokeWeight(max(0.65, step * (0.11 + bass * 0.06)));
    pg.rectMode(CENTER);
    pg.rect(snapX, snapY, cell * (0.92 + mid * 0.32), cell * (0.92 + bass * 0.28), 1);
    if (gate > 0.62) {
      pg.stroke(yr, yg, yb, alpha * 0.70);
      pg.line(snapX - cell * 0.42, snapY, snapX + cell * 0.42, snapY);
      pg.line(snapX, snapY - cell * 0.42, snapX, snapY + cell * 0.42);
    }
    return;
  }

  if (conteudo == 5) {
    float cell = step * (1.05 + bass * 0.30);
    float angle = (maskIdx % 2 == 0 ? 0.0 : HALF_PI * 0.5) + sin(t + nx * 3.0) * 0.28 * mid;
    float len = step * (3.2 + mid * 2.8 + n * 1.2);
    pg.noFill();
    pg.stroke(cr, cg, cb, alpha * 0.92);
    pg.strokeWeight(max(0.55, step * (0.12 + bass * 0.09)));
    pg.line(x - cos(angle) * len, y - sin(angle) * len, x + cos(angle) * len, y + sin(angle) * len);
    pg.stroke(yr, yg, yb, alpha * (0.34 + treble * 0.30));
    pg.strokeWeight(max(0.35, step * 0.065));
    pg.line(x - sin(angle) * cell, y + cos(angle) * cell, x + sin(angle) * cell, y - cos(angle) * cell);
    return;
  }

  if (conteudo == 6) {
    float cell = step * (1.45 + bass * 0.50);
    float gx = round(x / cell) * cell;
    float gy = round(y / cell) * cell;
    float block = cell * (0.68 + n * 0.52 + mid * 0.22);
    pg.noStroke();
    pg.fill(cr, cg, cb, alpha * 0.98);
    pg.rectMode(CENTER);
    pg.rect(gx, gy, block, block, 0);
    if (n > 0.66 || treble > 0.55) {
      pg.fill(yr, yg, yb, alpha * 0.78);
      pg.rect(gx + block * 0.32, gy - block * 0.32, block * 0.42, block * 0.42, 0);
    }
    return;
  }

  if (conteudo == 1) {
    pg.stroke(cr, cg, cb, alpha * 0.96);
    pg.strokeWeight(max(1.0, step * 0.46 * (0.88 + bass * 0.75)));
    float len = step * (2.35 + mid * 2.6 + n * 1.3);
    float ang = sin(nx * 4.0 + maskIdx) * 0.45 + cos(ny * 5.0 + t) * 0.25;
    pg.line(x - cos(ang) * len, y - sin(ang) * len,
            x + cos(ang) * len, y + sin(ang) * len + sin(t * 5.0 + nx * 8.0) * step * treble);
    if (n > 0.62) {
      pg.stroke(yr, yg, yb, alpha * 0.74);
      pg.strokeWeight(max(0.65, step * 0.22));
      pg.line(x - sin(ang) * len * 0.45, y + cos(ang) * len * 0.45,
              x + sin(ang) * len * 0.45, y - cos(ang) * len * 0.45);
    }
    return;
  }
  if (conteudo == 2 && textura != null && textura.width > 0 && textura.height > 0) {
    textura.loadPixels();
    int sx = constrain(round(map(nx, -1, 1, 0, textura.width - 1)), 0, textura.width - 1);
    int sy = constrain(round(map(ny, -1, 1, 0, textura.height - 1)), 0, textura.height - 1);
    int c = textura.pixels[sy * textura.width + sx];
    float sr = max(red(c), cr * 0.68);
    float sg = max(green(c), cg * 0.68);
    float sb = max(blue(c), cb * 0.68);
    float d = step * (1.85 + bass * 0.75 + n * 1.35);
    pg.noStroke();
    pg.fill(sr, sg, sb, alpha);
    pg.rect(x, y, d * 1.40, d * 0.92);
    if (n > 0.55) {
      pg.fill(yr, yg, yb, alpha * 0.72);
      pg.rect(x + d * 0.26, y - d * 0.16, d * 0.48, d * 0.32);
    }
    return;
  }
  if (conteudo == 3 && brand != null && brand.originalPoints.size() > 2) {
    int idx = constrain(floor(abs(noise(nx * 4.0 + maskIdx, ny * 4.0, t) * brand.originalPoints.size())), 0, brand.originalPoints.size() - 1);
    PVector p = brand.originalPoints.get(idx);
    float u = (p.x - brand.minX) / max(1, brand.maxX - brand.minX);
    float d = step * (1.65 + bass * 1.10 + noise(u * 5.0, t) * 1.25);
    pg.noStroke();
    pg.fill(lerp(ar, br, u), lerp(ag, bg, u), lerp(ab, bb, u), alpha * 0.92);
    pg.ellipse(x, y, d * 1.15, d);
    pg.fill(yr, yg, yb, alpha * 0.62);
    pg.ellipse(x + d * 0.22, y - d * 0.18, d * 0.38, d * 0.34);
    return;
  }
  float d = step * (1.85 + n * 2.20 + bass * 0.78);
  pg.noStroke();
  pg.fill(cr, cg, cb, alpha);
  pg.rect(x, y, d * 1.18, d * 0.98);
  if (n > 0.52) {
    pg.fill(yr, yg, yb, alpha * 0.78);
    pg.ellipse(x + d * 0.22, y - d * 0.18, d * 0.42, d * 0.42);
  }
}

boolean pontoDentroMascaraEstampa(float x, float y, float ax, float ay, float aw, float ah, float u, float v, float n) {
  if (panfletoEstampaAplicacao != 2) return true;
  if (panfletoEstampaMascara == 0) return true;
  float cx = ax + aw * 0.5;
  float cy = ay + ah * 0.5;
  float nx = (x - cx) / max(1, aw * 0.5);
  float ny = (y - cy) / max(1, ah * 0.5);
  float d = nx * nx + ny * ny;
  if (panfletoEstampaMascara == 1) return d <= 1.0;
  float limite = 0.72 + n * 0.38 + sin((u + v) * TWO_PI * 2.0 + noiseDynamicTime) * 0.10;
  return d <= limite;
}

void desenharModuloContornoEstampa(PGraphics pg, MutableBrand brand, float tileW, float tileH, float sc, float ar, float ag, float ab, float br, float bg, float bb, float alpha, float t, float bass, float mid, float treble) {
  if (brand == null || brand.originalPoints.size() == 0) return;
  float brandW = max(1, brand.maxX - brand.minX);
  float fit = min(tileW / brandW, tileH / max(1, brand.maxY - brand.minY)) * sc;
  int step = max(1, brand.originalPoints.size() / 150);
  pg.noFill();
  pg.strokeWeight(max(0.45, (0.9 + bass * 1.6) / max(0.001, fit)));
  pg.beginShape();
  for (int i = 0; i < brand.originalPoints.size(); i += step) {
    PVector p = brand.originalPoints.get(i);
    float u = (p.x - brand.minX) / brandW;
    float n = noise(u * 6.0, i * 0.01, t);
    pg.stroke(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), alpha);
    pg.curveVertex((p.x - brand.center.x) * fit + (n - 0.5) * mid * 8, (p.y - brand.center.y) * fit + sin(t * 4.0 + i * 0.04) * treble * 4);
  }
  pg.endShape();
}

void desenharModuloRitmoEstampa(PGraphics pg, MutableBrand brand, float tileW, float tileH, float sc, float ar, float ag, float ab, float br, float bg, float bb, float alpha, float t, float bass, float mid, float treble) {
  if (brand == null || brand.originalPoints.size() == 0) return;
  float brandW = max(1, brand.maxX - brand.minX);
  float brandH = max(1, brand.maxY - brand.minY);
  int step = max(1, brand.originalPoints.size() / 90);
  pg.noFill();
  for (int i = 0; i < brand.originalPoints.size(); i += step) {
    PVector p = brand.originalPoints.get(i);
    float u = (p.x - brand.minX) / brandW;
    float v = (p.y - brand.minY) / brandH;
    float n = noise(u * 8.0, v * 8.0, t);
    float x = (u - 0.5) * tileW * sc;
    float y = (v - 0.5) * tileH * sc;
    float len = tileW * 0.10 * sc * (0.7 + mid + n);
    pg.stroke(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), alpha * 0.86);
    pg.strokeWeight(max(0.45, 0.8 + bass * 1.8));
    pg.line(x - len, y, x + len, y + sin(t * 5.0 + i) * treble * 6);
  }
}

void desenharModuloRecorteEstampa(PGraphics pg, PImage img, float tileW, float tileH, float sc, float ar, float ag, float ab, float alpha, float n) {
  pg.rectMode(CENTER);
  if (img != null && img.width > 0 && img.height > 0) {
    img.loadPixels();
    float rw = tileW * sc * (0.42 + n * 0.48);
    float rh = tileH * sc * (0.32 + (1 - n) * 0.42);
    int sw = constrain(round(img.width * (0.18 + n * 0.25)), 8, img.width);
    int sh = constrain(round(img.height * (0.18 + (1 - n) * 0.25)), 8, img.height);
    int sx = constrain(round(n * img.width) - sw / 2, 0, max(0, img.width - sw));
    int sy = constrain(round((1 - n) * img.height) - sh / 2, 0, max(0, img.height - sh));
    pg.tint(255, alpha);
    pg.image(img, -rw * 0.5, -rh * 0.5, rw, rh, sx, sy, sx + sw, sy + sh);
    pg.noTint();
  } else {
    pg.noStroke();
    pg.fill(ar, ag, ab, alpha * 0.78);
    pg.rect(0, 0, tileW * sc * (0.28 + n), tileH * sc * (0.18 + n * 0.6), 2);
  }
}

void desenharModuloCampoEstampa(PGraphics pg, MutableBrand brand, float tileW, float tileH, float sc, float ar, float ag, float ab, float br, float bg, float bb, float alpha, float t, float bass, float mid) {
  int cols = 8;
  int rows = 10;
  pg.noStroke();
  for (int gy = 0; gy < rows; gy++) {
    for (int gx = 0; gx < cols; gx++) {
      float u = (gx + 0.5) / cols;
      float v = (gy + 0.5) / rows;
      float campo = estampaCampoMarca(brand, u, v, 12);
      float n = noise(u * 6.0, v * 6.0, t);
      if (campo + n * 0.22 < 0.28) continue;
      pg.fill(lerp(ar, br, n), lerp(ag, bg, n), lerp(ab, bb, n), alpha * (0.45 + campo * 0.65));
      float cw = tileW * sc / cols;
      float ch = tileH * sc / rows;
      pg.rect((u - 0.5) * tileW * sc, (v - 0.5) * tileH * sc, cw * (0.6 + campo + bass * 0.2), ch * (0.6 + campo + mid * 0.2));
    }
  }
}

int[] temaPanfletoAtual() {
  int bg = corFundoPanfletoAtual();
  int r = int(red(bg));
  int g = int(green(bg));
  int b = int(blue(bg));
  boolean escuro = (r * 0.299 + g * 0.587 + b * 0.114) < 138;
  return new int[] { r, g, b, escuro ? 247 : 18, escuro ? 247 : 18, escuro ? 250 : 22, escuro ? 104 : 34 };
}

int[] corTextoPanfletoAtual(int temaR, int temaG, int temaB) {
  if (panfletoTextoCorModo < 0 || panfletoTextoCorModo >= panfletoTextoCorLabels.length) panfletoTextoCorModo = 0;
  if (panfletoTextoCorModo == 1) return new int[] { 8, 8, 10 };
  if (panfletoTextoCorModo == 2) return new int[] { 248, 248, 244 };
  if (panfletoTextoCorModo == 3) return new int[] { 232, 221, 194 };
  return new int[] { temaR, temaG, temaB };
}

void desenharImagemCover(PGraphics pg, PImage img, float x, float y, float w, float h) {
  if (img == null || img.width <= 0 || img.height <= 0) return;

  pg.pushStyle();
  pg.clip(round(x), round(y), round(w), round(h));
  pg.imageMode(CENTER);

  float scale = max(w / img.width, h / img.height);
  float iw = img.width * scale;
  float ih = img.height * scale;
  pg.image(img, x + w * 0.5, y + h * 0.5, iw, ih);

  pg.noClip();
  pg.popStyle();
}

float lerNumeroCampoPanfleto(int idx, float fallback, float mn, float mx) {
  if (idx < 0 || idx >= panfletoTextoValores.length) return fallback;
  String txt = panfletoTextoValores[idx];
  if (txt == null) return fallback;
  txt = trim(txt).replace(',', '.');
  if (txt.length() == 0 || txt.equals("-") || txt.equals(".") || txt.equals("-.")) return fallback;

  try {
    float val = Float.parseFloat(txt);
    return constrain(val, mn, mx);
  } catch (Exception e) {
    return fallback;
  }
}

void desenharMarcaNoPanfleto(PGraphics pg, float cx, float cy, float alvoW, int tr, int tg, int tb, float alpha) {
  if (brandSystemEnabled && activeBrand != null) {
    desenharMarcaAoVivoNoPanfleto(pg, activeBrand, cx, cy, alvoW);
    return;
  }

  PImage img1 = marcaRaster;
  PImage img1b = marcaRaster1b;
  PImage img2 = marcaRaster2;
  PImage img2b = marcaRaster2b;

  if (img1 == null && img1b == null && img2 == null && img2b == null) return;
  pg.imageMode(CENTER);

  boolean parTipo1 = (tipografiaVarianteAtiva == 0 && img1 != null && img1b != null);
  boolean parTipo2 = (tipografiaVarianteAtiva == 1 && img2 != null && img2b != null);

  if (parTipo1 || parTipo2) {
    PImage esquerda = parTipo1 ? img1 : img2;
    PImage direita = parTipo1 ? img1b : img2b;
    float w2 = alvoW * 0.62;
    float w3 = alvoW * 0.62;
    float h2 = w2 / ratioImagem(esquerda);
    float h3 = w3 / ratioImagem(direita);
    float gap = typoParGap;
    float total = w2 + w3 + gap;
    float x2 = -total * 0.5 + w2 * 0.5 + typoParXOffset;
    float x3 = x2 + w2 * 0.5 + gap + w3 * 0.5;
    float y2Local = parTipo2 ? 0 : (typoParYOffset * 0.5);
    float y3Local = parTipo2 ? typoVar2YOffsetA : (-typoParYOffset * 0.5);
    float connX = ((x2 + w2 * 0.5) + (x3 - w3 * 0.5)) * 0.5;
    float connY = (y2Local + y3Local) * 0.5;

    desenharMarcaImagemOriginalPanfleto(pg, esquerda, cx + x2 - connX, cy + y2Local - connY, w2, h2);
    desenharMarcaImagemOriginalPanfleto(pg, direita, cx + x3 - connX, cy + y3Local - connY, w3, h3);
  } else {
    PImage ativa = null;
    if (tipografiaVarianteAtiva == 0) ativa = (img1 != null) ? img1 : img1b;
    if (tipografiaVarianteAtiva == 1) ativa = (img2 != null) ? img2 : img1;
    if (ativa == null) ativa = (img2 != null) ? img2 : ((img2b != null) ? img2b : img1b);
    if (ativa != null) {
      float h = alvoW / ratioImagem(ativa);
      desenharMarcaImagemOriginalPanfleto(pg, ativa, cx, cy, alvoW, h);
    }
  }
}

void desenharMarcaAoVivoNoPanfleto(PGraphics pg, MutableBrand brand, float cx, float cy, float alvoW) {
  if (brand == null || mutationParams == null || alvoW <= 0) return;

  float assetW = max(1, brand.maxX - brand.minX);
  float fit = alvoW / assetW;

  pg.pushStyle();
  pg.colorMode(HSB, 360, 100, 100, 100);
  pg.noTint();
  renderMutableBrandEmPonto(pg, brand, mutationParams, audioData, gestureData, semente, 1.0, cx, cy, fit);
  pg.popStyle();
}

void desenharMarcaImagemOriginalPanfleto(PGraphics pg, PImage img, float cx, float cy, float w, float h) {
  if (img == null) return;
  pg.pushStyle();
  pg.colorMode(RGB, 255, 255, 255, 255);
  pg.imageMode(CENTER);
  pg.noTint();
  pg.image(img, cx, cy, w, h);
  pg.popStyle();
}

void desenharMarcaMutavelNoPanfleto(PGraphics pg, MutableBrand brand, float cx, float cy, float alvoW, int tr, int tg, int tb, float alpha) {
  if (brand == null) return;

  float assetW = max(1, brand.maxX - brand.minX);
  float fit = alvoW / assetW;
  float localAlpha = constrain(alpha * (0.55 + (audioData != null ? audioData.energy * 0.45 : 0)), 0, 255);

  pg.pushStyle();
  pg.pushMatrix();
  pg.colorMode(RGB, 255, 255, 255, 255);
  pg.translate(cx, cy);
  pg.rotate(brand.currentRotation * 0.35);
  pg.scale(fit * brand.currentScale);

  int modoMarca = mutationParams != null ? mutationParams.mode : 0;

  if (modoMarca == 0 && mutationParams != null && renderBrandOriginalNormalWarp(pg, brand, mutationParams, fit, audioData)) {
    pg.popMatrix();
    pg.popStyle();
    return;
  }

  if (brand.sourceShape != null && modoMarca == 0) {
    brand.sourceShape.disableStyle();
    pg.shapeMode(CORNER);
    pg.noFill();
    pg.stroke(tr, tg, tb, min(255, localAlpha));
    pg.strokeWeight(max(0.55, brand.currentStroke / max(0.001, fit)));
    pg.shape(brand.sourceShape, -brand.center.x, -brand.center.y);
    brand.sourceShape.enableStyle();
  }

  if (brand.hasPointData) {
    ArrayList<PVector> pontos = brand.currentPoints;
    int stride = max(1, (int) ceil(pontos.size() / brand.maxRenderPoints));
    float breakDistance = brand.span() * 0.14;
    float dot = max(0.85, 1.6 / max(0.001, fit));
    float solid = mutationParams != null ? constrain(mutationParams.solidness, 0, 1) : 0.65;

    if (modoMarca == 1 || modoMarca == 8) {
      pg.noStroke();
      pg.fill(tr, tg, tb, localAlpha);
      float blob = max(dot * 1.4, (modoMarca == 8 ? 4.2 : 3.0) / max(0.001, fit));
      for (int i = 0; i < pontos.size(); i += stride) {
        int layer = brand.pointLayer.size() > i ? brand.pointLayer.get(i) : 1;
        if (layer == 2 && solid < 0.40 && i % 4 != 0) continue;
        PVector p = pontos.get(i);
        float scaleLayer = layer == 0 ? 0.82 : (layer == 2 ? lerp(0.50, 1.2, solid) : 1.0);
        float pulse = 1.0 + (audioData != null ? audioData.bass * 0.55 : 0);
        pg.ellipse(p.x - brand.center.x, p.y - brand.center.y, blob * scaleLayer * pulse, blob * scaleLayer * (0.78 + solid * 0.35));
      }
    } else if (modoMarca == 3) {
      pg.noFill();
      pg.stroke(tr, tg, tb, localAlpha);
      pg.strokeWeight(max(0.45, brand.currentStroke / max(0.001, fit)));
      for (int i = 0; i < pontos.size(); i += stride) {
        PVector p = pontos.get(i);
        float a = noise(p.x * 0.014, p.y * 0.014, semente) * TWO_PI;
        float len = max(1.0, 2.8 / max(0.001, fit));
        pg.line(p.x - brand.center.x - cos(a) * len, p.y - brand.center.y - sin(a) * len,
                p.x - brand.center.x + cos(a) * len, p.y - brand.center.y + sin(a) * len);
      }
    } else if (modoMarca == 5) {
      pg.noStroke();
      pg.fill(tr, tg, tb, localAlpha);
      float cell = max(1.8, 4.0 / max(0.001, fit));
      float snap = cell * 1.35;
      for (int i = 0; i < pontos.size(); i += stride) {
        PVector p = pontos.get(i);
        float gx = round((p.x - brand.center.x) / snap) * snap;
        float gy = round((p.y - brand.center.y) / snap) * snap;
        pg.rectMode(CENTER);
        pg.rect(gx, gy, cell, cell, 1);
      }
    } else if (brand.isRaster || brand.pointCloudOnly || modoMarca == 2 || modoMarca == 4 || modoMarca == 6 || modoMarca == 7) {
      pg.noStroke();
      pg.fill(tr, tg, tb, localAlpha);
      for (int i = 0; i < pontos.size(); i += stride) {
        PVector p = pontos.get(i);
        pg.ellipse(p.x - brand.center.x, p.y - brand.center.y, dot, dot);
      }
    } else {
      pg.noFill();
      pg.stroke(tr, tg, tb, localAlpha);
      pg.strokeWeight(max(0.45, brand.currentStroke / max(0.001, fit)));
      boolean desenhando = false;
      PVector previous = null;
      for (int i = 0; i < pontos.size(); i += stride) {
        PVector p = pontos.get(i);
        boolean shouldBreak = brand.breakBefore.get(i) || !desenhando;
        if (!shouldBreak && previous != null && PVector.dist(previous, p) > breakDistance) {
          shouldBreak = true;
        }
        if (shouldBreak) {
          if (desenhando) pg.endShape();
          pg.beginShape();
          desenhando = true;
        }
        pg.vertex(p.x - brand.center.x, p.y - brand.center.y);
        previous = p;
      }
      if (desenhando) pg.endShape();
    }
  } else if (brand.sourceImage != null) {
    pg.imageMode(CENTER);
    pg.tint(tr, tg, tb, localAlpha);
    pg.image(brand.sourceImage, 0, 0);
    pg.noTint();
  }

  pg.popMatrix();
  pg.popStyle();
}

void desenharMarcaImagemTint(PGraphics pg, PImage img, float cx, float cy, float w, float h, int tr, int tg, int tb, float alpha) {
  if (img == null) return;
  float a = constrain(alpha, 0, 255);
  pg.pushStyle();
  pg.colorMode(RGB, 255, 255, 255, 255);
  if (modoCorGlobal == 3) {
    pg.tint(tr, tg, tb, a);
    pg.image(img, cx, cy, w, h);
    pg.noTint();
    pg.popStyle();
    return;
  }

  PImage outline = obterImagemOutlineMarca(img);

  if (modoCorGlobal == 0) {
    // PRETO: mantem o corpo da tipografia e aplica preto.
    pg.tint(0, 0, 0, a);
    pg.image(img, cx, cy, w, h);
    // Leve reforco de contorno para nao "sumir" em fundos muito escuros.
    if (outline != null) {
      pg.tint(255, 255, 255, a * 0.16);
      pg.image(outline, cx, cy, w * 1.012, h * 1.012);
    }
    pg.noTint();
    pg.popStyle();
    return;
  }

  if (modoCorGlobal == 1) {
    // BRANCO: mantem o corpo da tipografia e aplica branco.
    pg.tint(255, 255, 255, a);
    pg.image(img, cx, cy, w, h);
    // Leve reforco escuro para manter legibilidade em fundo claro.
    if (outline != null) {
      pg.tint(0, 0, 0, a * 0.14);
      pg.image(outline, cx, cy, w * 1.01, h * 1.01);
    }
    pg.noTint();
    pg.popStyle();
    return;
  }

  // P&B: base preta com corpo branco por cima (alto contraste).
  pg.tint(0, 0, 0, a);
  pg.image(img, cx, cy, w * 1.02, h * 1.02);
  pg.tint(255, 255, 255, a);
  pg.image(img, cx, cy, w, h);
  if (outline != null) {
    pg.tint(0, 0, 0, a * 0.78);
    pg.image(outline, cx, cy, w * 1.024, h * 1.024);
    pg.tint(255, 255, 255, a);
    pg.image(outline, cx, cy, w, h);
  }
  pg.noTint();
  pg.popStyle();
}

PImage obterImagemOutlineMarca(PImage img) {
  if (img == null) return null;
  if (img == marcaRaster) return marcaRasterOutline;
  if (img == marcaRaster1b) return marcaRaster1bOutline;
  if (img == marcaRaster2) return marcaRaster2Outline;
  if (img == marcaRaster2b) return marcaRaster2bOutline;
  if (img == marcaRaster3) return marcaRaster3Outline;
  return null;
}

void desenharTextoAlinhadoPanfleto(PGraphics pg, String txt, float panfletoX, float panfletoW, float panfletoY, float panfletoH, float y, int alinhamento, float boxH) {
  float margem = panfletoW * 0.09;
  String conteudo = normalizarTextoPanfleto(txt);
  float largura = panfletoW - margem * 2.0;
  float boxSeguro = min(boxH, panfletoH * 0.34);
  float topo = y - boxSeguro * 0.5;
  float boxX = panfletoX + margem;

  if (alinhamento == 0) {
    pg.textAlign(LEFT, TOP);
    pg.text(conteudo, boxX, topo, largura, boxSeguro);
    return;
  }
  if (alinhamento == 2) {
    pg.textAlign(RIGHT, TOP);
    pg.text(conteudo, boxX, topo, largura, boxSeguro);
    return;
  }

  pg.textAlign(CENTER, TOP);
  pg.text(conteudo, boxX, topo, largura, boxSeguro);
}

String normalizarTextoPanfleto(String txt) {
  if (txt == null) return "";
  String t = txt;
  t = t.replace("\\n", "\n");
  t = t.replace("|", "\n");
  return t;
}

float centroAlinhadoItemPanfleto(float panfletoX, float panfletoW, float itemW, int alinhamento) {
  float margem = panfletoW * 0.09;
  if (alinhamento == 0) return panfletoX + margem + itemW * 0.5;
  if (alinhamento == 2) return panfletoX + panfletoW - margem - itemW * 0.5;
  return panfletoX + panfletoW * 0.5;
}

void desenharStrokeMonocromatico(PGraphics pg, float alpha, float peso) {
  float a = constrain(alpha, 0, 255);
  float w = max(0.4, peso);
  pg.strokeWeight(w);
  pg.strokeCap(ROUND);
  if (modoCorGlobal == 0) {
    pg.stroke(0, 0, 0, a);
  } else if (modoCorGlobal == 1) {
    pg.stroke(255, 255, 255, a);
  } else {
    pg.stroke(255, 255, 255, a);
  }
}

void desenharSimboloPanfleto(PGraphics pg, float cx, float cy, float scalePx) {
  int forma = (formaAtiva != 0) ? formaAtiva : max(1, ultimaForma);
  float alpha = constrain(map(intensidade, 0, 1, 0.45, 1.0), 0.35, 1.0);

  pg.pushMatrix();
  pg.pushStyle();
  pg.translate(cx, cy);
  pg.colorMode(HSB, 360, 100, 100, 100);
  pg.scale(scalePx / 220.0);
  desenharFormaPorIndice(pg, forma, semente + 0.37, faseFolego, alpha);
  pg.popStyle();
  pg.popMatrix();
}

void desenharFormaPorIndice(PGraphics pg, int forma, float seedValue, float breathTime, float alphaScale) {
  float v = valorForma(forma);
  switch (forma) {
    case 0:
      desenharRepouso(pg, breathTime, alphaScale);
      break;
    case 1:
      desenharBassShape(pg, v, alphaScale, seedValue);
      break;
    case 2:
      desenharMidShape(pg, v, alphaScale, seedValue);
      break;
    case 3:
      desenharTrebleShape(pg, v, alphaScale, seedValue);
      break;
    case 4:
      desenharPresenceShape(pg, v, alphaScale, seedValue);
      break;
    case 5:
      // RUIDO desativado: forma 5 mantida apenas para compatibilidade.
      break;
  }
}

float valorForma(int s) {
  switch (s) {
    case 1:
      return max(sBass, 0.05);
    case 2:
      return max(sMid, 0.05);
    case 3:
      return max(sTreble, 0.05);
    case 4:
      return max(sPresence, 0.05);
    case 5:
      // RUIDO desativado.
      return 0.05;
    default:
      return 0.05;
  }
}
