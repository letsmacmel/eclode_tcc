void carregarMarcaSVG() {
  marcaSVG = null;
  marcaRaster = null;
  marcaRaster1b = null;
  marcaRaster2 = null;
  marcaRaster2b = null;
  marcaRaster3 = null;
  marcaRasterOutline = null;
  marcaRaster1bOutline = null;
  marcaRaster2Outline = null;
  marcaRaster2bOutline = null;
  marcaRaster3Outline = null;

  marcaRaster = carregarRasterBranca(caminhoMarcaPNG, new String[] { "logo.png", "brand.png", "sample.png" });
  marcaRaster1b = carregarRasterBranca(caminhoMarcaPNG1B, new String[] { "logo_alt.png", "brand_alt.png" });
  marcaRaster2 = carregarRasterBranca(caminhoMarcaPNG2, new String[] { "logo_2.png", "brand_2.png" });
  marcaRaster2b = carregarRasterBranca(caminhoMarcaPNG2B, new String[] { "logo_2b.png", "brand_2b.png" });
  marcaRaster3 = carregarRasterBranca(caminhoMarcaPNG3, new String[] { "logo_3.png", "brand_3.png" });

  if (marcaRaster != null) {
    atualizarOutlinesMarca();
    String msg = "Tipografias: T1A " + (marcaRaster != null ? "OK" : "X") +
      ", T1B " + (marcaRaster1b != null ? "OK" : "X") +
      ", T2A " + (marcaRaster2 != null ? "OK" : "X") +
      ", T2B " + (marcaRaster2b != null ? "OK" : "X");
    mostrarStatus(msg);
    return;
  }

  File arquivoAbsoluto = new File(caminhoMarcaSVG);
  if (caminhoMarcaSVG != null && caminhoMarcaSVG.length() > 0 && arquivoAbsoluto.exists()) {
    marcaSVG = carregarShapeComPrecisao(caminhoMarcaSVG);
  } else {
    String caminhoLocal = sketchPath("logo.svg");
    File arquivoLocal = new File(caminhoLocal);
    if (arquivoLocal.exists()) {
      marcaSVG = carregarShapeComPrecisao(caminhoLocal);
    }
  }

  if (marcaSVG == null && marcaRaster2 == null && marcaRaster3 == null) {
    mostrarStatus("Carregue uma marca SVG, PNG ou JPG");
    return;
  }

  if (marcaSVG != null) {
    construirMarcaRaster();
    atualizarOutlinesMarca();
  }
}

void construirMarcaRaster() {
  if (marcaSVG == null) return;

  float ratio = 3.0;
  if (marcaSVG.width > 1 && marcaSVG.height > 1) ratio = marcaSVG.width / max(1, marcaSVG.height);
  int rw = 1800;
  int rh = (int) (rw / ratio);
  PGraphics rasterPg = createGraphics(rw, rh, P2D);
  rasterPg.smooth(8);
  rasterPg.beginDraw();
  rasterPg.clear();
  rasterPg.shapeMode(CENTER);

  marcaSVG.disableStyle();
  rasterPg.noFill();
  rasterPg.stroke(255, 255, 255, 255);
  rasterPg.strokeWeight(1.8);
  rasterPg.shape(marcaSVG, rw * 0.5, rh * 0.5, rw * 0.94, rh * 0.94);
  marcaSVG.enableStyle();

  rasterPg.endDraw();
  marcaRaster = rasterPg.get();
  normalizarMarcaRasterBranca(marcaRaster);
}

PImage carregarRasterBranca(String caminhoAbsoluto, String[] fallbackLocais) {
  PImage img = null;
  File arquivoAbsoluto = new File(caminhoAbsoluto);
  if (caminhoAbsoluto != null && caminhoAbsoluto.length() > 0 && arquivoAbsoluto.exists()) {
    img = tentarCarregarImagem(caminhoAbsoluto);
  }

  if (img == null && fallbackLocais != null) {
    for (int i = 0; i < fallbackLocais.length; i++) {
      String caminhoLocal = sketchPath(fallbackLocais[i]);
      File arquivoLocal = new File(caminhoLocal);
      if (arquivoLocal.exists()) {
        img = tentarCarregarImagem(caminhoLocal);
        if (img != null) break;
      }
    }
  }

  // Fallback extra: procura nome do arquivo no Downloads do usuario.
  if (img == null && caminhoAbsoluto != null && caminhoAbsoluto.length() > 0) {
    String nomeArquivo = new File(caminhoAbsoluto).getName();
    File downloads = new File(System.getProperty("user.home"), "Downloads");
    File candidato = new File(downloads, nomeArquivo);
    if (candidato.exists()) {
      img = tentarCarregarImagem(candidato.getAbsolutePath());
    }
  }

  if (img != null) {
    normalizarMarcaRasterBranca(img);
  }
  return img;
}

PImage tentarCarregarImagem(String caminho) {
  if (caminho == null || caminho.length() == 0) return null;

  PImage img = loadImage(caminho);
  if (img != null && img.width > 0 && img.height > 0) return img;

  File arquivo = new File(caminho);
  if (!arquivo.isAbsolute()) {
    String caminhoData = dataPath(caminho);
    img = loadImage(caminhoData);
    if (img != null && img.width > 0 && img.height > 0) return img;
  }

  String caminhoUri = arquivo.isAbsolute() ? caminho : dataPath(caminho);
  String uri = "file:///" + caminhoUri.replace("\\", "/");
  img = loadImage(uri);
  if (img != null && img.width > 0 && img.height > 0) return img;

  img = carregarImagemViaJava(caminho);
  if (img != null && img.width > 0 && img.height > 0) return img;

  if (!arquivo.isAbsolute()) {
    img = carregarImagemViaJava(dataPath(caminho));
    if (img != null && img.width > 0 && img.height > 0) return img;
  }

  return null;
}

PImage carregarImagemViaJava(String caminho) {
  try {
    File arquivo = new File(caminho);
    if (!arquivo.exists()) return null;
    java.awt.image.BufferedImage buffered = javax.imageio.ImageIO.read(arquivo);
    if (buffered == null || buffered.getWidth() <= 0 || buffered.getHeight() <= 0) return null;

    PImage img = createImage(buffered.getWidth(), buffered.getHeight(), ARGB);
    img.loadPixels();
    buffered.getRGB(0, 0, buffered.getWidth(), buffered.getHeight(), img.pixels, 0, buffered.getWidth());
    img.updatePixels();
    return img;
  } catch (Exception e) {
    println("ImageIO falhou: " + e.getMessage());
    return null;
  }
}

String importarArquivoParaSketch(File origem, String prefixo) {
  if (origem == null || !origem.exists()) return null;

  File pasta = new File(dataPath("imports"));
  if (!pasta.exists()) pasta.mkdirs();

  String nome = origem.getName();
  int dot = nome.lastIndexOf('.');
  String ext = dot >= 0 ? nome.substring(dot).toLowerCase() : "";
  String destinoNome = prefixo + "_" + timeStamp() + ext;
  File destino = new File(pasta, destinoNome);

  FileInputStream in = null;
  FileOutputStream out = null;
  try {
    in = new FileInputStream(origem);
    out = new FileOutputStream(destino);
    byte[] buffer = new byte[8192];
    int read;
    while ((read = in.read(buffer)) != -1) {
      out.write(buffer, 0, read);
    }
    out.flush();
    return "imports/" + destinoNome;
  } catch (Exception e) {
    println("Falha ao importar arquivo: " + e.getMessage());
    return origem.getAbsolutePath();
  } finally {
    try {
      if (in != null) in.close();
    } catch (Exception e) {
    }
    try {
      if (out != null) out.close();
    } catch (Exception e) {
    }
  }
}

void normalizarMarcaRasterBranca(PImage img) {
  if (img == null) return;
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    int px = img.pixels[i];
    int a = (px >>> 24) & 0xFF;
    img.pixels[i] = (a << 24) | 0x00FFFFFF;
  }
  img.updatePixels();
}

void atualizarOutlinesMarca() {
  marcaRasterOutline = gerarOutlineRaster(marcaRaster);
  marcaRaster1bOutline = gerarOutlineRaster(marcaRaster1b);
  marcaRaster2Outline = gerarOutlineRaster(marcaRaster2);
  marcaRaster2bOutline = gerarOutlineRaster(marcaRaster2b);
  marcaRaster3Outline = gerarOutlineRaster(marcaRaster3);
}

PImage gerarOutlineRaster(PImage src) {
  if (src == null || src.width <= 0 || src.height <= 0) return null;

  PImage out = createImage(src.width, src.height, ARGB);
  src.loadPixels();
  out.loadPixels();

  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      int idx = y * src.width + x;
      int a = (src.pixels[idx] >>> 24) & 0xFF;
      if (a == 0) {
        out.pixels[idx] = 0;
        continue;
      }

      boolean edge = false;
      for (int yy = -1; yy <= 1 && !edge; yy++) {
        int ny = y + yy;
        if (ny < 0 || ny >= src.height) {
          edge = true;
          break;
        }
        for (int xx = -1; xx <= 1; xx++) {
          int nx = x + xx;
          if (nx < 0 || nx >= src.width) {
            edge = true;
            break;
          }
          int na = (src.pixels[ny * src.width + nx] >>> 24) & 0xFF;
          if (na == 0) {
            edge = true;
            break;
          }
        }
      }

      out.pixels[idx] = edge ? ((a << 24) | 0x00FFFFFF) : 0;
    }
  }

  out.updatePixels();
  return out;
}

void carregarMarcaPadraoInicial() {
  String[] candidatos = {
    sketchPath("logo.svg"),
    sketchPath("brand.svg"),
    sketchPath("sample.svg"),
    caminhoMarcaSVG
  };

  for (int i = 0; i < candidatos.length; i++) {
    if (candidatos[i] == null || candidatos[i].length() == 0) continue;
    File arquivo = new File(candidatos[i]);
    if (arquivo.exists()) {
      if (carregarMarcaSVGMutavel(candidatos[i])) return;
    }
  }

  activeBrand = null;
  activeBrandName = "Nenhum SVG";
  mostrarStatus("Carregue um SVG");
}

boolean carregarMarcaSVGMutavel(String caminho) {
  if (caminho == null || caminho.length() == 0) return false;

  MutableBrand asset = new MutableBrand();
  if (!asset.loadSVG(caminho)) {
    mostrarStatus("Falha ao carregar SVG: " + new File(caminho).getName());
    return false;
  }

  activeBrand = asset;
  activeBrandName = activeBrand.name;
  mostrarStatus("Marca ativa: " + activeBrandName);
  return true;
}

boolean carregarMarcaImagemMutavel(String caminho) {
  if (caminho == null || caminho.length() == 0) return false;

  MutableBrand asset = new MutableBrand();
  if (!asset.loadRaster(caminho)) {
    mostrarStatus("Falha ao carregar imagem: " + new File(caminho).getName());
    return false;
  }

  activeBrand = asset;
  activeBrandName = activeBrand.name;
  mostrarStatus("Imagem ativa: " + activeBrandName);
  return true;
}

boolean carregarMarcaDireta(File selection) {
  if (selection == null || !selection.exists()) return false;

  String nome = selection.getName();
  String lower = nome.toLowerCase();
  String caminhoOriginal = selection.getAbsolutePath();

  MutableBrand asset = new MutableBrand();
  boolean ok = false;

  if (lower.endsWith(".png") || lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
    PImage img = carregarImagemViaJava(caminhoOriginal);
    if (img == null || img.width <= 0 || img.height <= 0) {
      img = tentarCarregarImagem(caminhoOriginal);
    }
    if (img == null || img.width <= 0 || img.height <= 0) {
      String caminhoImportado = importarArquivoParaSketch(selection, "brand_img");
      if (caminhoImportado != null) {
        img = carregarImagemViaJava(dataPath(caminhoImportado));
        if (img == null || img.width <= 0 || img.height <= 0) {
          img = tentarCarregarImagem(caminhoImportado);
        }
      }
    }

    if (img != null && img.width > 0 && img.height > 0) {
      asset.sourceShape = null;
      asset.sourceImage = img;
      asset.isRaster = true;
      asset.pointCloudOnly = false;
      asset.name = nome;
      asset.originalPoints.clear();
      asset.currentPoints.clear();
      asset.breakBefore.clear();
      asset.pointLayer.clear();
      asset.prepararMalhaDeImagem();
      PImage base = asset.sourceImage != null ? asset.sourceImage : img;
      asset.minX = -base.width * 0.5;
      asset.maxX = base.width * 0.5;
      asset.minY = -base.height * 0.5;
      asset.maxY = base.height * 0.5;
      asset.center.set(0, 0);
      asset.prepararPontosRasterLeves(base);
      asset.pointCloudOnly = true;
      ok = true;
    }
  } else if (lower.endsWith(".svg")) {
    PShape shape = null;
    String caminhoImportado = importarArquivoParaSketch(selection, "brand_svg");
    if (caminhoImportado != null) {
      shape = carregarShapeComPrecisao(caminhoImportado);
      if (shape == null) shape = carregarShapeComPrecisao(dataPath(caminhoImportado));
    }
    if (shape == null) {
      String uri = "file:///" + caminhoOriginal.replace("\\", "/");
      shape = loadShape(uri);
    }
    if (shape == null) {
      shape = carregarShapeComPrecisao(caminhoOriginal);
    }

    if (shape != null) {
      PImage preview = rasterizarShapeComoImagem(shape);
      if (preview == null || preview.width <= 0 || preview.height <= 0) {
        mostrarStatus("SVG abriu, mas falhou na previa");
        return false;
      }
      asset.sourceShape = shape;
      asset.sourceImage = preview;
      asset.isRaster = true;
      asset.pointCloudOnly = false;
      asset.name = nome;
      asset.originalPoints.clear();
      asset.currentPoints.clear();
      asset.breakBefore.clear();
      asset.pointLayer.clear();
      asset.prepararMalhaDeImagem();
      PImage base = asset.sourceImage != null ? asset.sourceImage : preview;
      asset.minX = -base.width * 0.5;
      asset.minY = -base.height * 0.5;
      asset.maxX = base.width * 0.5;
      asset.maxY = base.height * 0.5;
      asset.center.set(0, 0);
      boolean pontosVetoriais = asset.prepararPontosSVGGeomerative(caminhoImportado != null ? caminhoImportado : caminhoOriginal, shape, base);
      if (!pontosVetoriais) asset.prepararPontosRasterLeves(base);
      asset.pointCloudOnly = true;
      ok = true;
    }
  }

  if (!ok) return false;

  activeBrand = asset;
  activeBrandName = asset.name;
  return true;
}

PImage rasterizarShapeComoImagem(PShape shape) {
  if (shape == null) return null;

  try {
    float sw = shape.width > 1 ? shape.width : 600;
    float sh = shape.height > 1 ? shape.height : 600;
    float maxSide = 3200.0;
    float scale = min(6.0, maxSide / max(sw, sh));
    int rw = max(32, ceil(sw * scale) + 8);
    int rh = max(32, ceil(sh * scale) + 8);

    // JAVA2D evita o erro GL 0x502 que acontece ao criar buffers P2D durante o load.
    PGraphics pg = createGraphics(rw, rh, P2D);
    pg.smooth(8);
    pg.beginDraw();
    pg.clear();
    pg.colorMode(RGB, 255, 255, 255, 255);
    pg.shapeMode(CORNER);
    pg.pushMatrix();
    pg.translate(4, 4);
    pg.scale(scale);
    shape.disableStyle();
    pg.fill(255, 255, 255, 255);
    pg.stroke(255, 255, 255, 255);
    pg.strokeWeight(max(0.65, 1.15 / max(0.001, scale)));
    pg.shape(shape, 0, 0);
    shape.enableStyle();
    pg.popMatrix();
    pg.endDraw();

    return pg.get();
  } catch (Exception e) {
    println("Falha ao rasterizar SVG: " + e.getMessage());
    return null;
  }
}

PShape carregarShapeComPrecisao(String caminho) {
  String preciso = prepararSVGComPrecisao(caminho);
  PShape shape = null;
  if (preciso != null && preciso.length() > 0) shape = loadShape(preciso);
  if (shape == null) shape = loadShape(caminho);
  return shape;
}

String prepararSVGComPrecisao(String caminho) {
  if (caminho == null || caminho.length() == 0) return caminho;
  String lower = caminho.toLowerCase();
  if (!lower.endsWith(".svg")) return caminho;

  File origem = new File(caminho);
  if (!origem.isAbsolute()) {
    File dataFile = new File(dataPath(caminho));
    File sketchFile = new File(sketchPath(caminho));
    if (dataFile.exists()) origem = dataFile;
    else if (sketchFile.exists()) origem = sketchFile;
  }
  if (!origem.exists()) return caminho;

  try {
    String[] linhas = loadStrings(origem.getAbsolutePath());
    if (linhas == null || linhas.length == 0) return caminho;
    String conteudo = join(linhas, "\n");
    int start = conteudo.indexOf("<svg");
    if (start < 0) return caminho;
    int end = conteudo.indexOf(">", start);
    if (end < 0) return caminho;

    String tag = conteudo.substring(start, end);
    String extra = "";
    if (tag.indexOf("shape-rendering") < 0) extra += " shape-rendering=\"geometricPrecision\"";
    if (tag.indexOf("text-rendering") < 0) extra += " text-rendering=\"geometricPrecision\"";
    if (tag.indexOf("image-rendering") < 0) extra += " image-rendering=\"optimizeQuality\"";
    if (tag.indexOf("color-rendering") < 0) extra += " color-rendering=\"optimizeQuality\"";
    if (extra.length() == 0) return origem.getAbsolutePath();

    conteudo = conteudo.substring(0, end) + extra + conteudo.substring(end);
    File pasta = new File(dataPath("imports"));
    if (!pasta.exists()) pasta.mkdirs();
    String nomeSeguro = origem.getName().replaceAll("[^A-Za-z0-9_.-]", "_");
    File destino = new File(pasta, "precision_" + abs(origem.getAbsolutePath().hashCode()) + "_" + nomeSeguro);
    saveStrings(destino.getAbsolutePath(), split(conteudo, "\n"));
    return destino.getAbsolutePath();
  } catch (Exception e) {
    println("Falha ao preparar SVG com geometricPrecision: " + e.getMessage());
    return caminho;
  }
}

void atualizarMarcaMutavel() {
  if (!brandSystemEnabled || activeBrand == null || audioData == null || gestureData == null || mutationParams == null) return;
  if (mutationParams.freezeState) return;
  activeBrand.updateMutation(audioData, gestureData, mutationParams);
}

void resetMarcaAtual() {
  if (activeBrand == null) return;
  activeBrand.resetToOriginal();
  if (audioData != null) audioData.energy = 0;
  if (mutationParams != null) mutationParams.freezeState = false;
  mostrarStatus("Marca restaurada");
}

void generateNewMutationDNA() {
  if (mutationParams == null) mutationParams = new MutationParams();
  mutationParams.randomize();
  aplicarPaletaControladaNaMarca();
  syncSlidersFromMutationParams();

  if (sliders != null && sliders.length > 35) {
    sliders[27][5] = mutationParams.intensity;
    sliders[28][5] = mutationParams.deformationAmount;
    sliders[29][5] = mutationParams.noiseAmount;
    sliders[30][5] = mutationParams.displacementAmount;
    sliders[31][5] = mutationParams.strokeAmount;
    sliders[32][5] = mutationParams.scaleAmount;
    sliders[33][5] = mutationParams.rotationAmount;
    sliders[34][5] = mutationParams.returnSpeed;
    sliders[35][5] = mutationParams.growthSpeed;
  }

  mostrarStatus("Nova variação generativa");
}

void applyIdentityPreset(int idx) {
  if (mutationParams == null) mutationParams = new MutationParams();

  mutationParams.angularity = 0.0;
  mutationParams.freezeState = false;
  mutationParams.opacityAmount = 0.92;
  mutationParams.saturationAmount = 1.0;
  mutationParams.visualNoiseAmount = 0.45;

  if (idx == 0) {
    mutationParams.mode = 0; // original
    mutationParams.deformationMode = 1; // pulso
    mutationParams.intensity = 1.15;
    mutationParams.deformationAmount = 34;
    mutationParams.noiseAmount = 0.42;
    mutationParams.displacementAmount = 24;
    mutationParams.strokeAmount = 3.0;
    mutationParams.scaleAmount = 0.16;
    mutationParams.fragmentationAmount = 0.28;
    mutationParams.growthSpeed = 0.14;
    mutationParams.returnSpeed = 0.08;
    mutationParams.bassInfluence = 1.18;
    mutationParams.midInfluence = 0.92;
    mutationParams.trebleInfluence = 0.82;
    mutationParams.solidness = 0.78;
  } else if (idx == 1) {
    mutationParams.mode = 5; // grid
    mutationParams.deformationMode = 1; // pulso
    mutationParams.intensity = 1.22;
    mutationParams.deformationAmount = 44;
    mutationParams.noiseAmount = 0.28;
    mutationParams.displacementAmount = 26;
    mutationParams.strokeAmount = 2.6;
    mutationParams.scaleAmount = 0.10;
    mutationParams.fragmentationAmount = 0.22;
    mutationParams.angularity = 0.82;
    mutationParams.growthSpeed = 0.12;
    mutationParams.returnSpeed = 0.09;
    mutationParams.bassInfluence = 1.32;
    mutationParams.midInfluence = 0.82;
    mutationParams.trebleInfluence = 0.55;
    mutationParams.solidness = 0.86;
  } else if (idx == 2) {
    mutationParams.mode = 4; // particulas
    mutationParams.deformationMode = 2; // explodir
    mutationParams.intensity = 1.55;
    mutationParams.deformationAmount = 86;
    mutationParams.noiseAmount = 0.85;
    mutationParams.displacementAmount = 78;
    mutationParams.strokeAmount = 2.2;
    mutationParams.scaleAmount = 0.08;
    mutationParams.fragmentationAmount = 0.95;
    mutationParams.growthSpeed = 0.18;
    mutationParams.returnSpeed = 0.055;
    mutationParams.bassInfluence = 1.42;
    mutationParams.midInfluence = 0.92;
    mutationParams.trebleInfluence = 1.22;
    mutationParams.solidness = 0.32;
  } else if (idx == 3) {
    mutationParams.mode = 6; // eco
    mutationParams.deformationMode = 3; // ondular
    mutationParams.intensity = 1.08;
    mutationParams.deformationAmount = 56;
    mutationParams.noiseAmount = 0.70;
    mutationParams.displacementAmount = 34;
    mutationParams.strokeAmount = 1.7;
    mutationParams.scaleAmount = 0.12;
    mutationParams.fragmentationAmount = 0.36;
    mutationParams.opacityAmount = 0.68;
    mutationParams.growthSpeed = 0.10;
    mutationParams.returnSpeed = 0.12;
    mutationParams.bassInfluence = 0.72;
    mutationParams.midInfluence = 1.36;
    mutationParams.trebleInfluence = 0.98;
    mutationParams.solidness = 0.42;
  } else if (idx == 4) {
    mutationParams.mode = 10; // fios
    mutationParams.deformationMode = 6; // glitch
    mutationParams.intensity = 1.42;
    mutationParams.deformationAmount = 72;
    mutationParams.noiseAmount = 1.05;
    mutationParams.displacementAmount = 58;
    mutationParams.strokeAmount = 1.4;
    mutationParams.scaleAmount = 0.06;
    mutationParams.fragmentationAmount = 0.52;
    mutationParams.visualNoiseAmount = 1.15;
    mutationParams.growthSpeed = 0.17;
    mutationParams.returnSpeed = 0.07;
    mutationParams.bassInfluence = 0.75;
    mutationParams.midInfluence = 1.12;
    mutationParams.trebleInfluence = 1.52;
    mutationParams.solidness = 0.28;
  }

  syncSlidersFromMutationParams();
  mostrarStatus("Estado: " + identityPresetLabels[idx]);
}

String nomePresetAtual() {
  if (mutationParams == null) return "Preset";
  String base = mutationParams.mode >= 0 && mutationParams.mode < mutationModeLabels.length ? mutationModeLabels[mutationParams.mode] : "BASE";
  String deform = mutationParams.deformationMode >= 0 && mutationParams.deformationMode < deformationModeLabels.length ? deformationModeLabels[mutationParams.deformationMode] : "SOM";
  return base + " + " + deform;
}

void setMeshDetailPreset(int idx) {
  if (activeBrand == null) return;
  if (idx == 0) {
    activeBrand.maxRenderPoints = 700;
    mutationParams.complexity = 0.22;
  } else if (idx == 1) {
    activeBrand.maxRenderPoints = 1700;
    mutationParams.complexity = 0.52;
  } else {
    activeBrand.maxRenderPoints = 4200;
    mutationParams.complexity = 0.92;
  }
  syncSlidersFromMutationParams();
  mostrarStatus("Mesh: " + meshDetailLabels[idx]);
}

void aplicarLayoutPanfleto(int idx) {
  panfletoLayoutAtivo = (int) constrain(idx, 0, panfletoLayoutLabels.length - 1);
  modoPanfleto = true;

  if (panfletoLayoutAtivo == 0) {
    panfletoFormatoAtivo = 0;
    panfletoMarcaAlign = 1;
    panfletoMarcaX = 0;
    panfletoMarcaY = -188;
    panfletoMarcaEscala = 0.52;
    panfletoMostrarTextos = true;
    panfletoTextosAgrupados = true;
    panfletoTituloY = 0;
    panfletoTituloX = 0;
    panfletoSubtituloY = 0;
    panfletoSubtituloX = 0;
    panfletoRodapeY = 0;
    panfletoRodapeX = 0;
    panfletoTextoGrupoY = 0;
    panfletoTextoGrupoX = 0;
    panfletoTituloAlign = 1;
    panfletoSubtituloAlign = 1;
    panfletoRodapeAlign = 1;
    panfletoTextoValores[0] = "SILENT OBJECTS";
    panfletoTextoValores[1] = "Editorial composition for mutable identity";
    panfletoTextoValores[2] = "CATALOGUE 01";
    panfletoTextoValores[3] = "54";
    panfletoTextoValores[4] = "18";
    panfletoTextoValores[5] = "12";
  } else if (panfletoLayoutAtivo == 1) {
    panfletoFormatoAtivo = 0;
    panfletoMarcaAlign = 1;
    panfletoMarcaX = 126;
    panfletoMarcaY = 190;
    panfletoMarcaEscala = 0.46;
    panfletoMostrarTextos = true;
    panfletoTextosAgrupados = true;
    panfletoTituloY = 0;
    panfletoTituloX = 0;
    panfletoSubtituloY = 0;
    panfletoSubtituloX = 0;
    panfletoRodapeY = 0;
    panfletoRodapeX = 0;
    panfletoTextoGrupoY = 0;
    panfletoTextoGrupoX = 0;
    panfletoTituloAlign = 1;
    panfletoSubtituloAlign = 0;
    panfletoRodapeAlign = 0;
    panfletoTextoValores[0] = "VERTICAL STUDY";
    panfletoTextoValores[1] = "A single image object anchors the page.";
    panfletoTextoValores[2] = "MUSEUM POSTER";
    panfletoTextoValores[3] = "42";
    panfletoTextoValores[4] = "17";
    panfletoTextoValores[5] = "12";
  } else if (panfletoLayoutAtivo == 2) {
    panfletoFormatoAtivo = 0;
    panfletoMarcaAlign = 0;
    panfletoMarcaX = 76;
    panfletoMarcaY = -72;
    panfletoMarcaEscala = 0.44;
    panfletoMostrarSimbolo = false;
    panfletoMostrarTextos = true;
    panfletoTextosAgrupados = true;
    panfletoTituloY = 0;
    panfletoTituloX = 0;
    panfletoSubtituloY = 0;
    panfletoSubtituloX = 0;
    panfletoRodapeY = 0;
    panfletoRodapeX = 0;
    panfletoTextoGrupoY = 0;
    panfletoTextoGrupoX = 0;
    panfletoTituloAlign = 0;
    panfletoSubtituloAlign = 0;
    panfletoRodapeAlign = 0;
    panfletoTextoValores[0] = "CUT FORM";
    panfletoTextoValores[1] = "Large image object crossing the lower edge.";
    panfletoTextoValores[2] = "ARCHIVE NOTES";
    panfletoTextoValores[3] = "58";
    panfletoTextoValores[4] = "16";
    panfletoTextoValores[5] = "12";
  } else if (panfletoLayoutAtivo == 3) {
    panfletoFormatoAtivo = 0;
    panfletoMarcaAlign = 1;
    panfletoMarcaX = 0;
    panfletoMarcaY = 195;
    panfletoMarcaEscala = 0.52;
    panfletoMostrarSimbolo = false;
    panfletoMostrarTextos = true;
    panfletoTextosAgrupados = true;
    panfletoTituloY = 0;
    panfletoTituloX = 0;
    panfletoSubtituloY = 0;
    panfletoSubtituloX = 0;
    panfletoRodapeY = 0;
    panfletoRodapeX = 0;
    panfletoTextoGrupoY = 0;
    panfletoTextoGrupoX = 0;
    panfletoTituloAlign = 1;
    panfletoSubtituloAlign = 0;
    panfletoRodapeAlign = 2;
    panfletoTextoValores[0] = "FRAGMENTED OBJECT";
    panfletoTextoValores[1] = "Deconstructed image with editorial balance.";
    panfletoTextoValores[2] = "EXHIBITION TEXT";
    panfletoTextoValores[3] = "45";
    panfletoTextoValores[4] = "15";
    panfletoTextoValores[5] = "12";
  } else {
    panfletoFormatoAtivo = 0;
    panfletoTemaAtivo = 1;
    panfletoMarcaAlign = 1;
    panfletoMarcaX = 0;
    panfletoMarcaY = 0;
    panfletoMarcaEscala = 0.72;
    panfletoMostrarSimbolo = false;
    panfletoMostrarTextos = true;
    panfletoTextosAgrupados = true;
    panfletoTituloY = 0;
    panfletoTituloX = 0;
    panfletoSubtituloY = 0;
    panfletoSubtituloX = 0;
    panfletoRodapeY = 0;
    panfletoRodapeX = 0;
    panfletoTextoGrupoY = 0;
    panfletoTextoGrupoX = 0;
    panfletoTituloAlign = 1;
    panfletoSubtituloAlign = 0;
    panfletoRodapeAlign = 2;
    panfletoEstampaAtiva = false;
    panfletoEstampaAplicacao = 3;
    panfletoEstampaBlend = 0;
    panfletoEstampaIntensidade = 0.72;
    panfletoEstampaEscala = 0.88;
    panfletoEstampaRepeticao = 1.85;
    panfletoEstampaX = 0;
    panfletoEstampaY = 0;
    panfletoEstampaW = 0.90;
    panfletoEstampaH = 0.70;
    panfletoMascaraAtiva[0] = true;
    panfletoMascaraAtiva[1] = true;
    panfletoMascaraAtiva[2] = true;
    panfletoMascaraSelecionada = 0;
    panfletoMascaraFluxo[0] = 0;
    panfletoMascaraFluxo[1] = 1;
    panfletoMascaraFluxo[2] = 2;
    panfletoMascaraConteudo[0] = 0;
    panfletoMascaraConteudo[1] = 1;
    panfletoMascaraConteudo[2] = 2;
    panfletoMascaraX[0] = -0.02;
    panfletoMascaraY[0] = -0.02;
    panfletoMascaraW[0] = 0.76;
    panfletoMascaraH[0] = 0.44;
    panfletoMascaraRot[0] = -0.08;
    panfletoMascaraX[1] = -0.22;
    panfletoMascaraY[1] = 0.22;
    panfletoMascaraW[1] = 0.54;
    panfletoMascaraH[1] = 0.22;
    panfletoMascaraRot[1] = 0.18;
    panfletoMascaraX[2] = 0.24;
    panfletoMascaraY[2] = -0.20;
    panfletoMascaraW[2] = 0.42;
    panfletoMascaraH[2] = 0.24;
    panfletoMascaraRot[2] = -0.28;
    formaPadraoAtiva = 24;
    panfletoTextoValores[0] = "FULL IMAGE STUDY";
    panfletoTextoValores[1] = "Background image as editorial atmosphere.";
    panfletoTextoValores[2] = "IDENTITY";
    panfletoTextoValores[3] = "46";
    panfletoTextoValores[4] = "16";
    panfletoTextoValores[5] = "12";
  }

  mostrarStatus("Layout panfleto: " + panfletoLayoutLabels[panfletoLayoutAtivo]);
}

float ratioFormatoPanfleto() {
  if (panfletoFormatoAtivo == 1) return 297.0 / 210.0;
  if (panfletoFormatoAtivo == 2) return 1080.0 / 1350.0;
  if (panfletoFormatoAtivo == 3) return 1080.0 / 1920.0;
  if (panfletoFormatoAtivo == 4) return 1920.0 / 1080.0;
  if (panfletoFormatoAtivo == 5) return 1063.0 / 591.0;
  if (panfletoFormatoAtivo == 6) return 4373.0 / 1640.0;
  return 210.0 / 297.0;
}

float[] valoresParametrosMutacao() {
  return new float[] {
    mutationParams.intensity,
    mutationParams.deformationAmount,
    mutationParams.noiseAmount,
    mutationParams.displacementAmount,
    mutationParams.strokeAmount,
    mutationParams.scaleAmount,
    mutationParams.rotationAmount,
    mutationParams.fragmentationAmount,
    mutationParams.returnSpeed,
    mutationParams.growthSpeed,
    activeBrand != null ? activeBrand.maxRenderPoints : 1200,
    mutationParams.gestureAmount,
    mutationParams.typographicWeight,
    mutationParams.angularity,
    mutationParams.complexity,
    mutationParams.fragmentationAmount,
    mutationParams.opacityAmount,
    mutationParams.hueAmount,
    mutationParams.saturationAmount,
    mutationParams.transformSpeed
  };
}

float[] minParametrosMutacao() {
  return new float[] {
    0.0, 0, 0.0, 0, 0.2, 0, -0.45, 0, 0.01, 0.02,
    150, 0, 0.2, 0.0, 0.1, 0.0, 0.05, -180, 0.0, 0.1
  };
}

float[] maxParametrosMutacao() {
  return new float[] {
    3.0, 160, 2.5, 160, 16, 0.8, 0.45, 1.4, 0.26, 0.36,
    5200, 2.0, 3.0, 1.0, 1.0, 1.4, 1.0, 180, 1.8, 3.0
  };
}

void setParametroMutacao(int idx, float val) {
  if (mutationParams == null) return;
  if (idx == 0) mutationParams.intensity = val;
  if (idx == 1) mutationParams.deformationAmount = val;
  if (idx == 2) mutationParams.noiseAmount = val;
  if (idx == 3) mutationParams.displacementAmount = val;
  if (idx == 4) mutationParams.strokeAmount = val;
  if (idx == 5) mutationParams.scaleAmount = val;
  if (idx == 6) mutationParams.rotationAmount = val;
  if (idx == 7) mutationParams.fragmentationAmount = val;
  if (idx == 8) mutationParams.returnSpeed = val;
  if (idx == 9) mutationParams.growthSpeed = val;
  if (idx == 10 && activeBrand != null) activeBrand.maxRenderPoints = val;
  if (idx == 11) mutationParams.gestureAmount = val;
  if (idx == 12) mutationParams.typographicWeight = val;
  if (idx == 13) mutationParams.angularity = val;
  if (idx == 14) mutationParams.complexity = val;
  if (idx == 15) mutationParams.fragmentationAmount = val;
  if (idx == 16) mutationParams.opacityAmount = val;
  if (idx == 17) mutationParams.hueAmount = val;
  if (idx == 18) mutationParams.saturationAmount = val;
  if (idx == 19) mutationParams.transformSpeed = val;

  if (sliders != null && sliders.length > 35) {
    if (idx == 0) sliders[27][5] = val;
    if (idx == 1) sliders[28][5] = val;
    if (idx == 2) sliders[29][5] = val;
    if (idx == 3) sliders[30][5] = val;
    if (idx == 4) sliders[31][5] = val;
    if (idx == 5) sliders[32][5] = val;
    if (idx == 6) sliders[33][5] = val;
    if (idx == 8) sliders[34][5] = val;
    if (idx == 9) sliders[35][5] = val;
  }
}

void salvarPresetPlaylist() {
  int slot = activePlaylistSlot >= 0 ? activePlaylistSlot : primeiroSlotPlaylistLivre();
  if (slot < 0) slot = 0;
  playlistParams[slot] = mutationParams.copy();
  playlistBrandNames[slot] = activeBrandName;
  playlistPresetNames[slot] = nomePresetAtual();
  activePlaylistSlot = slot;
  mostrarStatus("Preset salvo: " + playlistPresetNames[slot]);
}

int primeiroSlotPlaylistLivre() {
  for (int i = 0; i < playlistParams.length; i++) {
    if (playlistParams[i] == null) return i;
  }
  return -1;
}

void aplicarPresetPlaylist(int slot) {
  if (slot < 0 || slot >= playlistParams.length || playlistParams[slot] == null) {
    activePlaylistSlot = slot;
    mostrarStatus("Slot vazio");
    return;
  }
  mutationParams.setFrom(playlistParams[slot]);
  syncSlidersFromMutationParams();
  activePlaylistSlot = slot;
  mostrarStatus("Preset aplicado: " + (playlistPresetNames[slot] != null ? playlistPresetNames[slot] : playlistSlotNames[slot]));
}

void syncSlidersFromMutationParams() {
  if (sliders == null || sliders.length <= 35 || mutationParams == null) return;
  sliders[27][5] = mutationParams.intensity;
  sliders[28][5] = mutationParams.deformationAmount;
  sliders[29][5] = mutationParams.noiseAmount;
  sliders[30][5] = mutationParams.displacementAmount;
  sliders[31][5] = mutationParams.strokeAmount;
  sliders[32][5] = mutationParams.scaleAmount;
  sliders[33][5] = mutationParams.rotationAmount;
  sliders[34][5] = mutationParams.returnSpeed;
  sliders[35][5] = mutationParams.growthSpeed;
}

class AudioData {
  float volume;
  float bass;
  float mid;
  float treble;
  float energy;
  float threshold = 0.035;

  void update(float bassIn, float midIn, float trebleIn, float volumeIn) {
    bass = lerp(bass, constrain(bassIn, 0, 1), 0.16);
    mid = lerp(mid, constrain(midIn, 0, 1), 0.16);
    treble = lerp(treble, constrain(trebleIn, 0, 1), 0.20);
    volume = lerp(volume, constrain(volumeIn, 0, 1), 0.14);

    float target = (volume > threshold) ? constrain(volume * 1.35 + bass * 0.45 + mid * 0.35 + treble * 0.22, 0, 1) : 0;
    float speed = target > energy ? mutationParams.growthSpeed : mutationParams.returnSpeed;
    energy = constrain(lerp(energy, target, speed), 0, 1);
  }
}

class GestureData {
  float x = 0.5;
  float y = 0.5;
  float px = 0.5;
  float py = 0.5;
  float speed = 0;
  boolean active = true;

  void update(float mx, float my, float pmx, float pmy) {
    px = x;
    py = y;
    x = constrain(mx / float(max(1, width)), 0, 1);
    y = constrain(my / float(max(1, height)), 0, 1);
    float vx = mx - pmx;
    float vy = my - pmy;
    speed = lerp(speed, constrain(sqrt(vx * vx + vy * vy) / 80.0, 0, 1), 0.22);
    active = true;
  }

  float pullX() {
    return map(x, 0, 1, -1, 1);
  }

  float pullY() {
    return map(y, 0, 1, -1, 1);
  }
}

class MutationParams {
  int mode = 0;
  int deformationMode = 0;
  boolean freezeState = false;
  float intensity = 1.0;
  float bassInfluence = 1.0;
  float midInfluence = 1.0;
  float trebleInfluence = 1.0;
  float solidness = 0.62;
  float deformationAmount = 38;
  float noiseAmount = 0.65;
  float displacementAmount = 34;
  float strokeAmount = 2.2;
  float scaleAmount = 0.16;
  float rotationAmount = 0.04;
  float fragmentationAmount = 0.55;
  float gestureAmount = 1.0;
  float typographicWeight = 1.0;
  float angularity = 0.0;
  float complexity = 0.55;
  float opacityAmount = 0.95;
  float hueAmount = 0.0;
  float saturationAmount = 1.0;
  float visualNoiseAmount = 0.45;
  float transformSpeed = 1.0;
  float returnSpeed = 0.085;
  float growthSpeed = 0.13;
  color primaryColor = color(158, 76, 96, 100);
  color secondaryColor = color(210, 76, 100, 75);
  color backgroundColor = color(0, 0, 6, 100);

  void randomize() {
    int[] modosAtivos = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 17, 19 };
    mode = modosAtivos[floor(random(modosAtivos.length))];
    if (mode == 5) mode = floor(random(0, 5));
    deformationMode = floor(random(0, deformationModeLabels.length));
    freezeState = false;
    bassInfluence = random(0.65, 1.45);
    midInfluence = random(0.65, 1.45);
    trebleInfluence = random(0.65, 1.55);
    solidness = random(0.34, 0.92);
    intensity = random(0.55, 1.9);
    deformationAmount = random(8, 92);
    noiseAmount = random(0.12, 1.35);
    displacementAmount = random(6, 88);
    strokeAmount = random(0.8, 7.0);
    scaleAmount = random(0.02, 0.34);
    rotationAmount = random(-0.18, 0.18);
    fragmentationAmount = random(0.15, 1.0);
    gestureAmount = random(0.35, 1.55);
    typographicWeight = random(0.45, 2.2);
    angularity = random(0.0, 0.16);
    complexity = random(0.25, 1.0);
    opacityAmount = random(0.45, 1.0);
    hueAmount = random(-80, 80);
    saturationAmount = random(0.25, 1.4);
    visualNoiseAmount = random(0.0, 1.4);
    transformSpeed = random(0.45, 2.4);
    growthSpeed = random(0.055, 0.22);
    returnSpeed = random(0.025, 0.16);
    int paleta = floor(random(0, 4));
    applyPalette(paleta);
  }

  void applyPalette(int paleta) {
    if (paleta == 0) {
      primaryColor = color(0, 0, 100, 100);
      secondaryColor = color(0, 0, 62, 70);
    } else if (paleta == 1) {
      primaryColor = color(158, 76, 96, 100);
      secondaryColor = color(210, 76, 100, 78);
    } else if (paleta == 2) {
      primaryColor = color(18, 90, 100, 100);
      secondaryColor = color(38, 92, 96, 78);
    } else {
      primaryColor = color(210, 76, 100, 100);
      secondaryColor = color(188, 70, 95, 78);
    }
    hueAmount = 0;
    saturationAmount = 1.0;
  }

  MutationParams copy() {
    MutationParams p = new MutationParams();
    p.setFrom(this);
    return p;
  }

  void setFrom(MutationParams p) {
    mode = p.mode;
    deformationMode = p.deformationMode;
    freezeState = p.freezeState;
    bassInfluence = p.bassInfluence;
    midInfluence = p.midInfluence;
    trebleInfluence = p.trebleInfluence;
    solidness = p.solidness;
    intensity = p.intensity;
    deformationAmount = p.deformationAmount;
    noiseAmount = p.noiseAmount;
    displacementAmount = p.displacementAmount;
    strokeAmount = p.strokeAmount;
    scaleAmount = p.scaleAmount;
    rotationAmount = p.rotationAmount;
    fragmentationAmount = p.fragmentationAmount;
    gestureAmount = p.gestureAmount;
    typographicWeight = p.typographicWeight;
    angularity = p.angularity;
    complexity = p.complexity;
    opacityAmount = p.opacityAmount;
    hueAmount = p.hueAmount;
    saturationAmount = p.saturationAmount;
    visualNoiseAmount = p.visualNoiseAmount;
    transformSpeed = p.transformSpeed;
    returnSpeed = p.returnSpeed;
    growthSpeed = p.growthSpeed;
    primaryColor = p.primaryColor;
    secondaryColor = p.secondaryColor;
    backgroundColor = p.backgroundColor;
  }
}

class MutableBrand {
  PShape sourceShape;
  PImage sourceImage;
  ImageMask sourceMask;
  MeshLogo meshLogo;
  ArrayList<PVector> originalPoints = new ArrayList<PVector>();
  ArrayList<PVector> currentPoints = new ArrayList<PVector>();
  ArrayList<Boolean> breakBefore = new ArrayList<Boolean>();
  ArrayList<Integer> pointLayer = new ArrayList<Integer>();
  String name = "SVG";
  boolean hasPointData = false;
  boolean isRaster = false;
  boolean pointCloudOnly = false;
  float baseScale = 1.0;
  float currentScale = 1.0;
  float baseStroke = 1.0;
  float currentStroke = 1.0;
  float currentRotation = 0;
  float maxRenderPoints = 1800;
  float minX, maxX, minY, maxY;
  PVector center = new PVector();

  boolean loadSVG(String filename) {
    PShape svg = carregarShapeComPrecisao(filename);
    if (svg == null) {
      File arquivo = new File(filename);
      if (!arquivo.isAbsolute()) {
        svg = carregarShapeComPrecisao(dataPath(filename));
      }
    }
    if (svg == null) {
      File arquivo = new File(filename);
      String caminhoUri = arquivo.isAbsolute() ? filename : dataPath(filename);
      String uri = "file:///" + caminhoUri.replace("\\", "/");
      svg = loadShape(uri);
    }
    if (svg == null) return false;

    sourceShape = svg;
    sourceImage = rasterizarShapeComoImagem(svg);
    isRaster = sourceImage != null;
    pointCloudOnly = sourceImage != null;
    name = new File(filename).getName();
    originalPoints.clear();
    currentPoints.clear();
    breakBefore.clear();
    pointLayer.clear();
    prepararMalhaDeImagem();
    if (sourceImage != null && sourceImage.width > 0 && sourceImage.height > 0) {
      minX = -sourceImage.width * 0.5;
      maxX = sourceImage.width * 0.5;
      minY = -sourceImage.height * 0.5;
      maxY = sourceImage.height * 0.5;
      center.set(0, 0);
      boolean pontosVetoriais = prepararPontosSVGGeomerative(filename, sourceShape, sourceImage);
      if (!pontosVetoriais) prepararPontosRasterLeves(sourceImage);
    } else {
      extractPointsFromRenderedShape(sourceShape);
      pointCloudOnly = originalPoints.size() > 0;
    }
    if (originalPoints.size() == 0) {
      originalPoints.clear();
      breakBefore.clear();
      pointLayer.clear();
      extractPointsFromShape(sourceShape);
      pointCloudOnly = true;
    }
    if (sourceImage == null) updateBounds();

    if (currentPoints.size() == 0) {
      for (int i = 0; i < originalPoints.size(); i++) {
        currentPoints.add(originalPoints.get(i).copy());
      }
    }
    hasPointData = originalPoints.size() > 1;
    return true;
  }

  boolean loadRaster(String filename) {
    PImage img = tentarCarregarImagem(filename);
    if (img == null || img.width <= 0 || img.height <= 0) return false;

    sourceShape = null;
    sourceImage = img;
    isRaster = true;
    pointCloudOnly = true;
    name = new File(filename).getName();
    originalPoints.clear();
    currentPoints.clear();
    breakBefore.clear();
    pointLayer.clear();
    prepararMalhaDeImagem();
    PImage base = sourceImage != null ? sourceImage : img;
    minX = -base.width * 0.5;
    maxX = base.width * 0.5;
    minY = -base.height * 0.5;
    maxY = base.height * 0.5;
    center.set(0, 0);
    prepararPontosRasterLeves(base);
    hasPointData = originalPoints.size() > 1;
    return true;
  }

  void prepararMalhaDeImagem() {
    sourceMask = null;
    meshLogo = null;
    if (sourceImage == null || sourceImage.width <= 0 || sourceImage.height <= 0) return;
    sourceMask = new ImageMask(sourceImage);
    if (sourceMask != null && sourceMask.texture != null && sourceMask.texture.width > 0 && sourceMask.texture.height > 0) {
      sourceImage = sourceMask.texture;
      meshLogo = new MeshLogo(sourceImage);
    }
  }

  void extractPointsFromShape(PShape shape) {
    if (shape == null) return;

    int vertexCount = shape.getVertexCount();
    if (vertexCount > 0) {
      for (int i = 0; i < vertexCount; i++) {
        PVector v = shape.getVertex(i);
        if (v == null) continue;
        originalPoints.add(v.copy());
        breakBefore.add(i == 0);
        pointLayer.add(0);
      }
    }

    int childCount = shape.getChildCount();
    for (int i = 0; i < childCount; i++) {
      extractPointsFromShape(shape.getChild(i));
    }
  }

  void extractPointsFromImage(PImage img) {
    img.loadPixels();
    int maxSamples = 3600;
    int step = max(2, floor(sqrt((img.width * img.height) / float(maxSamples))));
    boolean transparentMode = imageHasTransparency(img);
    float bgR = 0;
    float bgG = 0;
    float bgB = 0;
    if (!transparentMode) {
      int[] corners = {
        img.pixels[0],
        img.pixels[max(0, img.width - 1)],
        img.pixels[max(0, img.height - 1) * img.width],
        img.pixels[max(0, img.height - 1) * img.width + max(0, img.width - 1)]
      };
      for (int i = 0; i < corners.length; i++) {
        bgR += (corners[i] >> 16) & 0xFF;
        bgG += (corners[i] >> 8) & 0xFF;
        bgB += corners[i] & 0xFF;
      }
      bgR /= corners.length;
      bgG /= corners.length;
      bgB /= corners.length;
    }

    for (int y = 0; y < img.height; y += step) {
      for (int x = 0; x < img.width; x += step) {
        if (activeRasterPixel(img, x, y, transparentMode, bgR, bgG, bgB) &&
            isRasterContourPixel(img, x, y, transparentMode, bgR, bgG, bgB)) {
          originalPoints.add(new PVector(x - img.width * 0.5, y - img.height * 0.5));
          breakBefore.add(true);
          pointLayer.add(0);
        }
      }
    }

    if (originalPoints.size() == 0) {
      for (int y = 0; y < img.height; y += step) {
        for (int x = 0; x < img.width; x += step) {
          if (activeRasterPixel(img, x, y, transparentMode, bgR, bgG, bgB)) {
            originalPoints.add(new PVector(x - img.width * 0.5, y - img.height * 0.5));
            breakBefore.add(true);
            pointLayer.add(classificarPixelCamada(img, x, y, transparentMode, bgR, bgG, bgB));
          }
        }
      }
    }
  }

  void extractPointsFromImageFill(PImage img) {
    img.loadPixels();
    int maxSamples = 3600;
    int step = max(2, floor(sqrt((img.width * img.height) / float(maxSamples))));
    boolean transparentMode = imageHasTransparency(img);
    float bgR = 0;
    float bgG = 0;
    float bgB = 0;
    if (!transparentMode) {
      int[] corners = {
        img.pixels[0],
        img.pixels[max(0, img.width - 1)],
        img.pixels[max(0, img.height - 1) * img.width],
        img.pixels[max(0, img.height - 1) * img.width + max(0, img.width - 1)]
      };
      for (int i = 0; i < corners.length; i++) {
        bgR += (corners[i] >> 16) & 0xFF;
        bgG += (corners[i] >> 8) & 0xFF;
        bgB += corners[i] & 0xFF;
      }
      bgR /= corners.length;
      bgG /= corners.length;
      bgB /= corners.length;
    }

    for (int y = 0; y < img.height; y += step) {
      for (int x = 0; x < img.width; x += step) {
        if (activeRasterPixel(img, x, y, transparentMode, bgR, bgG, bgB)) {
          originalPoints.add(new PVector(x - img.width * 0.5, y - img.height * 0.5));
          breakBefore.add(true);
          pointLayer.add(classificarPixelCamada(img, x, y, transparentMode, bgR, bgG, bgB));
        }
      }
    }
  }

  void prepararPontosRasterLeves(PImage img) {
    originalPoints.clear();
    currentPoints.clear();
    breakBefore.clear();
    pointLayer.clear();
    if (img == null || img.width <= 0 || img.height <= 0) {
      hasPointData = false;
      return;
    }

    img.loadPixels();
    boolean transparentMode = imageHasTransparency(img);
    float bgR = 0;
    float bgG = 0;
    float bgB = 0;

    if (!transparentMode) {
      int[] corners = {
        img.pixels[0],
        img.pixels[max(0, img.width - 1)],
        img.pixels[max(0, img.height - 1) * img.width],
        img.pixels[max(0, img.height - 1) * img.width + max(0, img.width - 1)]
      };
      for (int i = 0; i < corners.length; i++) {
        bgR += (corners[i] >> 16) & 0xFF;
        bgG += (corners[i] >> 8) & 0xFF;
        bgB += corners[i] & 0xFF;
      }
      bgR /= corners.length;
      bgG /= corners.length;
      bgB /= corners.length;
    }

    resamplePontosImagemSuave(img, transparentMode, bgR, bgG, bgB);

    for (int i = 0; i < originalPoints.size(); i++) {
      currentPoints.add(originalPoints.get(i).copy());
    }
    hasPointData = originalPoints.size() > 1;
    pointCloudOnly = hasPointData;
  }

  boolean prepararPontosSVGGeomerative(String filename, PShape shape, PImage rasterBase) {
    if (!geomerativeReady || filename == null || rasterBase == null || rasterBase.width <= 0 || rasterBase.height <= 0) return false;
    try {
      String caminho = caminhoArquivoExistente(filename);
      if (caminho == null) return false;

      float sw = shape != null && shape.width > 1 ? shape.width : rasterBase.width;
      float sh = shape != null && shape.height > 1 ? shape.height : rasterBase.height;
      float svgSpan = max(sw, sh);
      RG.setPolygonizer(RG.UNIFORMLENGTH);
      RG.setPolygonizerLength(max(1.0, svgSpan / 520.0));

      RShape rshape = RG.loadShape(caminho);
      if (rshape == null) return false;
      RPoint[][] paths = rshape.getPointsInPaths();
      if (paths == null || paths.length == 0) return false;

      originalPoints.clear();
      currentPoints.clear();
      breakBefore.clear();
      pointLayer.clear();

      float sx = max(0.001, (rasterBase.width - 8.0) / max(1.0, sw));
      float sy = max(0.001, (rasterBase.height - 8.0) / max(1.0, sh));
      float scale = min(sx, sy);
      float ox = 4.0 - rasterBase.width * 0.5;
      float oy = 4.0 - rasterBase.height * 0.5;

      for (int p = 0; p < paths.length; p++) {
        RPoint[] pts = paths[p];
        if (pts == null || pts.length < 2) continue;
        int pathStride = max(1, ceil(pts.length / 1800.0));
        for (int i = 0; i < pts.length; i += pathStride) {
          RPoint rp = pts[i];
          if (rp == null) continue;
          originalPoints.add(new PVector(rp.x * scale + ox, rp.y * scale + oy));
          breakBefore.add(i == 0);
          pointLayer.add(0);
        }
      }

      int contourCount = originalPoints.size();
      if (contourCount < 24) {
        originalPoints.clear();
        currentPoints.clear();
        breakBefore.clear();
        pointLayer.clear();
        return false;
      }

      adicionarPreenchimentoSVGDeMascara(rasterBase, contourCount);
      for (int i = 0; i < originalPoints.size(); i++) currentPoints.add(originalPoints.get(i).copy());
      hasPointData = originalPoints.size() > 1;
      pointCloudOnly = hasPointData;
      minX = -rasterBase.width * 0.5;
      maxX = rasterBase.width * 0.5;
      minY = -rasterBase.height * 0.5;
      maxY = rasterBase.height * 0.5;
      center.set(0, 0);
      return hasPointData;
    } catch (Exception e) {
      println("Falha na leitura vetorial Geomerative: " + e.getMessage());
      originalPoints.clear();
      currentPoints.clear();
      breakBefore.clear();
      pointLayer.clear();
      return false;
    }
  }

  void adicionarPreenchimentoSVGDeMascara(PImage img, int contourCount) {
    if (img == null) return;
    if (img.pixels == null || img.pixels.length == 0) img.loadPixels();
    int targetFill = constrain(round(contourCount * 0.62), 900, 4300);
    int maxAttempts = targetFill * 20;
    float minFillDist = max(2.0, min(img.width, img.height) / 155.0);
    for (int i = 0; i < maxAttempts && originalPoints.size() < contourCount + targetFill; i++) {
      int sx = constrain(floor(hash1D(i, 74.11) * img.width), 1, img.width - 2);
      int sy = constrain(floor(hash1D(i, 121.3) * img.height), 1, img.height - 2);
      if (alphaSVGGeomerative(img, sx, sy) < 38) continue;
      int layer = alphaSVGGeomerative(img, sx - 4, sy) < 38 || alphaSVGGeomerative(img, sx + 4, sy) < 38 ||
                  alphaSVGGeomerative(img, sx, sy - 4) < 38 || alphaSVGGeomerative(img, sx, sy + 4) < 38 ? 1 : 2;
      if (layer == 2 && hash1D(sx + sy * 13, 5.4) < 0.40) continue;
      if (pontoRasterTemEspaco(sx, sy, minFillDist, 1)) {
        originalPoints.add(new PVector(sx - img.width * 0.5, sy - img.height * 0.5));
        breakBefore.add(true);
        pointLayer.add(layer);
      }
    }
  }

  int alphaSVGGeomerative(PImage img, int x, int y) {
    x = constrain(x, 0, img.width - 1);
    y = constrain(y, 0, img.height - 1);
    return (img.pixels[y * img.width + x] >>> 24) & 0xFF;
  }

  String caminhoArquivoExistente(String filename) {
    if (filename == null || filename.length() == 0) return null;
    File f = new File(filename);
    if (f.exists()) return f.getAbsolutePath();
    f = new File(dataPath(filename));
    if (f.exists()) return f.getAbsolutePath();
    f = new File(sketchPath(filename));
    if (f.exists()) return f.getAbsolutePath();
    return null;
  }

  void resamplePontosImagemSuave(PImage img, boolean transparentMode, float bgR, float bgG, float bgB) {
    int targetContour = 6200;
    int targetFill = 5200;
    int maxAttempts = (targetContour + targetFill) * 18;
    float minContourDist = max(1.4, min(img.width, img.height) / 170.0);
    float minFillDist = max(2.0, min(img.width, img.height) / 130.0);

    for (int i = 0; i < maxAttempts && originalPoints.size() < targetContour; i++) {
      int sx = constrain(floor(hash1D(i, 14.73) * img.width), 1, img.width - 2);
      int sy = constrain(floor(hash1D(i, 91.7) * img.height), 1, img.height - 2);
      if (activeRasterPixel(img, sx, sy, transparentMode, bgR, bgG, bgB) &&
          isRasterContourPixel(img, sx, sy, transparentMode, bgR, bgG, bgB) &&
          pontoRasterTemEspaco(sx, sy, minContourDist, 0)) {
        adicionarPontoRasterSuave(img, sx, sy, 0, minContourDist);
      }
    }

    int fillStart = originalPoints.size();
    for (int i = 0; i < maxAttempts && originalPoints.size() < fillStart + targetFill; i++) {
      int sx = constrain(floor(hash1D(i, 74.11) * img.width), 1, img.width - 2);
      int sy = constrain(floor(hash1D(i, 121.3) * img.height), 1, img.height - 2);
      if (activeRasterPixel(img, sx, sy, transparentMode, bgR, bgG, bgB)) {
        int layer = classificarPixelCamada(img, sx, sy, transparentMode, bgR, bgG, bgB);
        if (layer == 2 && hash1D(sx + sy * 13, 5.4) < 0.45) continue;
        if (pontoRasterTemEspaco(sx, sy, minFillDist, 1)) {
          adicionarPontoRasterSuave(img, sx, sy, layer, minFillDist);
        }
      }
    }

    if (originalPoints.size() < 32) {
      int fallbackStep = max(2, floor(sqrt((img.width * img.height) / 1500.0)));
      for (int y = 0; y < img.height; y += fallbackStep) {
        for (int x = 0; x < img.width; x += fallbackStep) {
          if (activeRasterPixel(img, x, y, transparentMode, bgR, bgG, bgB)) {
            adicionarPontoRasterSuave(img, x, y, classificarPixelCamada(img, x, y, transparentMode, bgR, bgG, bgB), fallbackStep);
          }
        }
      }
    }
  }

  boolean pontoRasterTemEspaco(int sx, int sy, float minDist, int startLayer) {
    if (originalPoints.size() == 0) return true;
    float minSq = minDist * minDist;
    int checks = min(80, originalPoints.size());
    for (int j = 0; j < checks; j++) {
      int idx = constrain(floor(hash1D(sx * 3.1 + sy * 7.7 + j, 18.6) * originalPoints.size()), 0, originalPoints.size() - 1);
      PVector p = originalPoints.get(idx);
      float px = sx - p.x - (sourceImage != null ? sourceImage.width * 0.5 : 0);
      float py = sy - p.y - (sourceImage != null ? sourceImage.height * 0.5 : 0);
      if (px * px + py * py < minSq) return false;
    }
    return true;
  }

  void adicionarPontoRasterSuave(PImage img, int sx, int sy, int layer, float stepRef) {
    int idx = originalPoints.size();
    float jitter = max(0.10, min(0.38, stepRef * 0.18));
    float subX = map(hash1D(idx + sx * 0.37, 307.9), 0, 1, -jitter, jitter);
    float subY = map(hash1D(idx + sy * 0.41, 409.1), 0, 1, -jitter, jitter);
    originalPoints.add(new PVector(sx - img.width * 0.5 + subX, sy - img.height * 0.5 + subY));
    breakBefore.add(true);
    pointLayer.add(layer);
  }

  void extractPointsFromRenderedShape(PShape shape) {
    if (shape == null) return;

    float sw = shape.width;
    float sh = shape.height;
    if (sw <= 1 || sh <= 1 || Float.isNaN(sw) || Float.isNaN(sh)) {
      sw = 600;
      sh = 600;
    }

    float maxSide = 900.0;
    float maskScale = min(1.0, maxSide / max(sw, sh));
    int mw = max(32, ceil(sw * maskScale) + 4);
    int mh = max(32, ceil(sh * maskScale) + 4);

    PGraphics mask = createGraphics(mw, mh, P2D);
    mask.smooth(8);
    mask.beginDraw();
    mask.clear();
    mask.shapeMode(CORNER);
    mask.pushMatrix();
    mask.translate(2, 2);
    mask.scale(maskScale);
    mask.shape(shape, 0, 0);
    mask.popMatrix();
    mask.endDraw();

    mask.loadPixels();
    int maxSamples = 4200;
    int step = max(1, floor(sqrt((mw * mh) / float(maxSamples))));
    for (int y = 1; y < mh - 1; y += step) {
      for (int x = 1; x < mw - 1; x += step) {
        if (activeMaskPixel(mask, x, y) && isMaskContourPixel(mask, x, y)) {
          originalPoints.add(new PVector((x - 2) / maskScale, (y - 2) / maskScale));
          breakBefore.add(true);
          pointLayer.add(0);
        }
      }
    }
  }

  boolean imageHasTransparency(PImage img) {
    int step = max(1, floor(sqrt((img.width * img.height) / 600.0)));
    for (int y = 0; y < img.height; y += step) {
      for (int x = 0; x < img.width; x += step) {
        int a = (img.pixels[y * img.width + x] >>> 24) & 0xFF;
        if (a < 245) return true;
      }
    }
    return false;
  }

  boolean activeRasterPixel(PImage img, int x, int y, boolean transparentMode, float bgR, float bgG, float bgB) {
    if (x < 0 || y < 0 || x >= img.width || y >= img.height) return false;
    int c = img.pixels[y * img.width + x];
    int a = (c >>> 24) & 0xFF;
    if (a <= 28) return false;
    if (transparentMode) return true;

    float r = (c >> 16) & 0xFF;
    float g = (c >> 8) & 0xFF;
    float b = c & 0xFF;
    float d = dist(r, g, b, bgR, bgG, bgB);
    return d > 32;
  }

  boolean isRasterContourPixel(PImage img, int x, int y, boolean transparentMode, float bgR, float bgG, float bgB) {
    if (!activeRasterPixel(img, x, y, transparentMode, bgR, bgG, bgB)) return false;
    return !activeRasterPixel(img, x - 1, y, transparentMode, bgR, bgG, bgB) ||
           !activeRasterPixel(img, x + 1, y, transparentMode, bgR, bgG, bgB) ||
           !activeRasterPixel(img, x, y - 1, transparentMode, bgR, bgG, bgB) ||
           !activeRasterPixel(img, x, y + 1, transparentMode, bgR, bgG, bgB);
  }

  int classificarPixelCamada(PImage img, int x, int y, boolean transparentMode, float bgR, float bgG, float bgB) {
    if (isRasterContourPixel(img, x, y, transparentMode, bgR, bgG, bgB)) return 0;
    int raio = 5;
    boolean pertoBorda = false;
    for (int oy = -raio; oy <= raio; oy += raio) {
      for (int ox = -raio; ox <= raio; ox += raio) {
        if (!activeRasterPixel(img, x + ox, y + oy, transparentMode, bgR, bgG, bgB)) pertoBorda = true;
      }
    }
    if (pertoBorda) return 1;
    return 2;
  }

  boolean activeMaskPixel(PGraphics mask, int x, int y) {
    if (x < 0 || y < 0 || x >= mask.width || y >= mask.height) return false;
    int a = (mask.pixels[y * mask.width + x] >>> 24) & 0xFF;
    return a > 16;
  }

  boolean isMaskContourPixel(PGraphics mask, int x, int y) {
    if (!activeMaskPixel(mask, x, y)) return false;
    return !activeMaskPixel(mask, x - 1, y) ||
           !activeMaskPixel(mask, x + 1, y) ||
           !activeMaskPixel(mask, x, y - 1) ||
           !activeMaskPixel(mask, x, y + 1);
  }

  void resetToOriginal() {
    for (int i = 0; i < currentPoints.size(); i++) {
      currentPoints.get(i).set(originalPoints.get(i));
    }
    if (meshLogo != null) meshLogo.reset();
    currentScale = baseScale;
    currentStroke = baseStroke;
    currentRotation = 0;
  }

  void render(PGraphics pg, MutationParams params, AudioData audio, GestureData gesture, float seedValue, float scaleBase) {
    renderMutableBrand(pg, this, params, audio, gesture, seedValue, scaleBase);
  }

  void updateBounds() {
    if (originalPoints.size() == 0) {
      minX = -100;
      maxX = 100;
      minY = -100;
      maxY = 100;
      center.set(0, 0);
      return;
    }

    minX = maxX = originalPoints.get(0).x;
    minY = maxY = originalPoints.get(0).y;
    for (int i = 1; i < originalPoints.size(); i++) {
      PVector p = originalPoints.get(i);
      minX = min(minX, p.x);
      maxX = max(maxX, p.x);
      minY = min(minY, p.y);
      maxY = max(maxY, p.y);
    }
    center.set((minX + maxX) * 0.5, (minY + maxY) * 0.5);
  }

  float span() {
    return max(1, max(maxX - minX, maxY - minY));
  }

  void updateMutation(AudioData audio, GestureData gesture, MutationParams params) {
    if (audio == null || gesture == null || params == null) return;

    float unit = span() / 500.0;
    float bassDrive = constrain(audio.bass * 1.35 * params.bassInfluence, 0, 1.8);
    float midDrive = constrain(audio.mid * 1.25 * params.midInfluence, 0, 1.8);
    float trebleDrive = constrain(audio.treble * 1.1 * params.trebleInfluence, 0, 1.8);
    float audioDrive = max(max(audio.energy, audio.volume * 0.55), max(bassDrive * 0.45, max(midDrive * 0.35, trebleDrive * 0.25)));
    float drive = constrain(audioDrive * params.intensity, 0, 1.8);
    float audioFlow = max(0, params.gestureAmount);
    float pullX = sin(semente * 8.0 + bassDrive * 2.0) * midDrive * params.displacementAmount * unit * 0.38 * audioFlow;
    float pullY = cos(semente * 7.0 + trebleDrive * 2.0) * midDrive * params.displacementAmount * unit * 0.28 * audioFlow;
    float instability = 1.0 + trebleDrive * 0.8;
    float targetScale = baseScale + max(audio.volume, drive * 0.35) * params.scaleAmount * drive + bassDrive * params.scaleAmount * 0.18;
    float weight = max(0.1, params.typographicWeight);
    float targetStroke = baseStroke + params.strokeAmount * weight * 0.42 + params.strokeAmount * weight * (0.35 + bassDrive * 3.2) * max(0.2, drive);
    float targetRotation = sin(semente * 5.0) * midDrive * params.rotationAmount * drive + trebleDrive * params.rotationAmount * 0.12;
    if (params.mode == 0) {
      targetScale = baseScale;
      targetRotation *= 0.18;
    } else if (params.mode == 12) {
      targetScale = baseScale + (bassDrive * 0.010 + audio.volume * 0.006) * constrain(params.intensity, 0, 2.0);
      targetRotation *= 0.10;
    } else if (params.mode == 13) {
      targetScale = baseScale - (bassDrive * 0.008 + audio.volume * 0.005) * constrain(params.intensity, 0, 2.0);
      targetScale = max(baseScale * 0.965, targetScale);
      targetRotation *= 0.08;
    } else if (params.mode == 14) {
      targetScale = baseScale + midDrive * params.scaleAmount * 0.10;
      targetRotation *= 0.16;
    }
    float speedMul = max(0.1, params.transformSpeed);
    float lerpSpeed = (drive > 0.01 ? params.growthSpeed : params.returnSpeed) * speedMul;
    float tNoise = noiseDynamicTime + drive * 0.18;

    currentScale = lerp(currentScale, targetScale, lerpSpeed);
    currentStroke = lerp(currentStroke, targetStroke, lerpSpeed);
    currentRotation = lerp(currentRotation, targetRotation, lerpSpeed);
    if (meshLogo != null) meshLogo.update(audio, params);

    if (!hasPointData) return;

    int total = originalPoints.size();
    for (int i = 0; i < total; i++) {
      PVector origin = originalPoints.get(i);
      PVector current = currentPoints.get(i);
      float dx = origin.x - center.x;
      float dy = origin.y - center.y;
      float distNorm = constrain(sqrt(dx * dx + dy * dy) / span(), 0, 1.5);
      float radial = atan2(dy, dx);
      float n = noise(origin.x * 0.006 * params.noiseAmount, origin.y * 0.006 * params.noiseAmount, tNoise * 0.62);
      float n2 = noise(origin.y * 0.007 * params.noiseAmount + 19.0, origin.x * 0.007 * params.noiseAmount + 41.0, tNoise * 0.53);
      float vibration = sin(noiseDynamicTime * 55.0 + i * 0.31) * trebleDrive * params.noiseAmount * params.visualNoiseAmount * 12.0 * unit * drive;
      float organic = params.deformationAmount * max(midDrive, audio.volume * 0.25) * drive * unit * instability * (1.0 - params.angularity * 0.55);
      PVector normal = normalAproximadaDoPonto(i, origin);
      float normalNoise = map(noise(origin.x * 0.012 * params.noiseAmount + 8.0, origin.y * 0.012 * params.noiseAmount + 21.0, tNoise * 1.08), 0, 1, -1, 1);
      float normalWave = sin(noiseDynamicTime * 18.0 + i * 0.071) * 0.35;

      float targetX = origin.x;
      float targetY = origin.y;
      if (params.mode == 0) {
        targetX = origin.x;
        targetY = origin.y;
      } else {
        targetX += pullX * distNorm * drive * 0.22 + vibration * 0.28;
        targetY += pullY * distNorm * drive * 0.18;

        if (params.deformationMode == 0) {
          float subtleInflate = params.deformationAmount * bassDrive * drive * unit * 0.16;
          float normalThicken = subtleInflate * (0.65 + normalNoise * 0.42 + normalWave * trebleDrive);
          targetX += normal.x * normalThicken * (0.35 + distNorm * 0.45);
          targetY += normal.y * normalThicken * (0.35 + distNorm * 0.45);
          targetX += (n - 0.5) * organic * 0.20;
          targetY += (n2 - 0.5) * organic * 0.20;
        } else if (params.deformationMode == 1) {
          float attack = constrain(audio.volume * 1.6 + bassDrive * 0.9, 0, 1.8);
          float pulse = params.deformationAmount * drive * unit * (0.42 + bassDrive * 2.1);
          float breath = 0.72 + 0.28 * sin(semente * 22.0 + distNorm * 5.0);
          float nonUniformPulse = pulse * (0.72 + normalNoise * 0.34 + midDrive * 0.16) * breath;
          targetX += normal.x * nonUniformPulse * (0.38 + distNorm * 0.42);
          targetY += normal.y * nonUniformPulse * (0.38 + distNorm * 0.42);
          targetX += cos(radial) * params.scaleAmount * unit * 42.0 * attack;
          targetY += sin(radial) * params.scaleAmount * unit * 42.0 * attack;
        } else if (params.deformationMode == 2) {
          float burst = pow(constrain(drive, 0, 1.8), 1.18);
          float spread = params.fragmentationAmount * params.deformationAmount * burst * unit * (1.2 + bassDrive * 2.2 + trebleDrive * 0.9);
          float spiral = radial + (n - 0.5) * TWO_PI * (0.55 + trebleDrive);
          targetX += cos(spiral) * spread * (0.38 + distNorm);
          targetY += sin(spiral) * spread * (0.38 + distNorm);
        } else if (params.deformationMode == 3) {
          float waveY = sin(origin.x * 0.016 + semente * 16.0 + n * 2.0) * midDrive * params.deformationAmount * unit * drive;
          float waveX = sin(origin.y * 0.011 + semente * 10.0 + n2 * 2.0) * trebleDrive * params.deformationAmount * unit * 0.48 * drive;
          targetX += waveX;
          targetY += waveY;
          targetX += (n - 0.5) * organic * 0.34;
          targetY += (n2 - 0.5) * organic * 0.34;
        } else if (params.deformationMode == 4) {
          float slice = floor(map(origin.y, minY, maxY, 0, 18));
          float sliceMove = sin(slice * 1.21 + semente * 13.0) * (midDrive + trebleDrive * 0.45) * params.displacementAmount * unit * 0.92 * drive;
          float sliceLift = cos(slice * 0.77 + semente * 9.0) * bassDrive * params.displacementAmount * unit * 0.20 * drive;
          targetX += sliceMove;
          targetY += sliceLift;
        } else if (params.deformationMode == 5) {
          float fx = sin(semente * 4.0) * span() * 0.18;
          float fy = cos(semente * 3.4) * span() * 0.14;
          float ax = origin.x - fx;
          float ay = origin.y - fy;
          float ad = max(18 * unit, sqrt(ax * ax + ay * ay));
          float field = params.deformationAmount * drive * unit * (0.75 + bassDrive);
          float swirl = atan2(ay, ax) + HALF_PI;
          targetX += (ax / ad) * field * (0.44 + trebleDrive) + cos(swirl) * midDrive * field * 0.34;
          targetY += (ay / ad) * field * (0.44 + midDrive) + sin(swirl) * midDrive * field * 0.34;
        } else if (params.deformationMode == 6) {
          float letterBand = floor(map(origin.x, minX, maxX, 0, 9));
          float glitchGate = max(trebleDrive, audio.volume);
          float snap = params.displacementAmount * unit * drive * glitchGate * (0.45 + params.visualNoiseAmount);
          float rowBand = floor(map(origin.y, minY, maxY, 0, 11));
          targetX += sin(semente * 38.0 + letterBand * 2.3) * snap;
          targetY += cos(semente * 31.0 + rowBand * 1.7) * snap * 0.42;
          targetX += (hash1D(i + floor(semente * 14.0), 19.2) - 0.5) * trebleDrive * snap * 0.8;
        }
      }

      if (params.mode == 7) {
        float perlinA = noise(origin.x * 0.010 + 19.0, origin.y * 0.010 + 83.0, tNoise * (0.45 + midDrive * 0.18));
        float perlinB = noise(origin.x * 0.026 + 41.0, origin.y * 0.026 + 7.0, tNoise * (0.82 + trebleDrive * 0.20));
        float fieldAngle = perlinA * TWO_PI * (2.0 + params.noiseAmount * 0.55) + perlinB * PI;
        float fieldForce = params.deformationAmount * unit * drive * 0.018;
        float curlForce = params.displacementAmount * unit * drive * 0.006;
        targetX += cos(fieldAngle) * fieldForce + cos(fieldAngle + HALF_PI) * (perlinB - 0.5) * curlForce;
        targetY += sin(fieldAngle) * fieldForce + sin(fieldAngle + HALF_PI) * (perlinB - 0.5) * curlForce;
      }

      if (params.mode == 8) {
        float cellNoise = noise(origin.x * 0.018 + cos(tNoise * 0.9) * 1.2, origin.y * 0.018 + sin(tNoise * 0.7) * 1.2, tNoise * 0.55);
        float ring = sin(distNorm * 24.0 - tNoise * (5.5 + bassDrive * 4.0));
        float sandForce = params.deformationAmount * unit * drive * (0.45 + bassDrive * 0.95 + midDrive * 0.35);
        float tangent = (cellNoise - 0.5) * sandForce * (0.65 + trebleDrive * 0.45);
        float radialPush = ring * sandForce * 0.42 + bassDrive * sandForce * (0.28 - distNorm * 0.10);
        targetX += cos(radial) * radialPush + cos(radial + HALF_PI) * tangent;
        targetY += sin(radial) * radialPush + sin(radial + HALF_PI) * tangent;
        targetX += normal.x * (cellNoise - 0.5) * params.noiseAmount * unit * drive * 1.15;
        targetY += normal.y * (cellNoise - 0.5) * params.noiseAmount * unit * drive * 1.15;
      }

      if (params.mode == 9) {
        float fluffNoise = noise(origin.x * 0.030 + 18.0, origin.y * 0.030 + 43.0, tNoise * 0.44);
        float fluff = params.deformationAmount * unit * drive * (0.18 + bassDrive * 0.34 + midDrive * 0.22);
        targetX += normal.x * fluff * (0.35 + fluffNoise * 0.55);
        targetY += normal.y * fluff * (0.35 + fluffNoise * 0.55);
        targetX += cos(radial + HALF_PI) * (fluffNoise - 0.5) * trebleDrive * unit * params.noiseAmount * 1.8;
        targetY += sin(radial + HALF_PI) * (fluffNoise - 0.5) * trebleDrive * unit * params.noiseAmount * 1.8;
      }

      if (params.mode == 10) {
        float contourNoise = noise(origin.x * 0.014 + 61.0, origin.y * 0.014 + 17.0, tNoise * 0.46);
        float contourBreath = params.deformationAmount * unit * drive * (0.035 + bassDrive * 0.10 + midDrive * 0.07);
        float tangentWave = sin(tNoise * 3.4 + i * 0.031 + contourNoise * TWO_PI) * contourBreath * 0.34;
        targetX += normal.x * contourBreath * (contourNoise - 0.36) + cos(radial + HALF_PI) * tangentWave;
        targetY += normal.y * contourBreath * (contourNoise - 0.36) + sin(radial + HALF_PI) * tangentWave;
      }

      if (params.mode == 11) {
        float veinFlow = noise(origin.x * 0.020 + 44.0, origin.y * 0.020 + 12.0, tNoise * (0.42 + midDrive * 0.16));
        float veinPulse = sin((veinFlow * 4.0 + distNorm * 8.0 - tNoise * (1.2 + bassDrive)) * TWO_PI);
        float veinPush = params.deformationAmount * unit * drive * (0.050 + bassDrive * 0.11 + midDrive * 0.10);
        targetX += normal.x * veinPulse * veinPush;
        targetY += normal.y * veinPulse * veinPush;
      }

      if (params.angularity > 0.32 || params.mode == 5) {
        float gridMix = params.mode == 5 ? max(0.78, params.angularity) : params.angularity;
        float gridAudio = 1.0 + bassDrive * 0.65 + midDrive * 0.22;
        float angularGrid = max(4.0, lerp(46.0, 12.0, gridMix) * unit * gridAudio);
        targetX = lerp(targetX, round(targetX / angularGrid) * angularGrid, gridMix);
        targetY = lerp(targetY, round(targetY / angularGrid) * angularGrid, gridMix);
      }

      if (drive > 0.01) {
        current.x = lerp(current.x, targetX, constrain(params.growthSpeed * speedMul, 0.001, 1));
        current.y = lerp(current.y, targetY, constrain(params.growthSpeed * speedMul, 0.001, 1));
      } else {
        current.x = lerp(current.x, origin.x, constrain(params.returnSpeed * speedMul, 0.001, 1));
        current.y = lerp(current.y, origin.y, constrain(params.returnSpeed * speedMul, 0.001, 1));
      }
    }
  }

  PVector normalAproximadaDoPonto(int idx, PVector origin) {
    PVector normalImagem = normalDaImagemFonte(origin);
    if (normalImagem != null) return normalImagem;

    PVector tangent = null;
    float maxLink = span() * 0.08;
    if (idx > 0 && idx < originalPoints.size() - 1) {
      PVector prev = originalPoints.get(idx - 1);
      PVector next = originalPoints.get(idx + 1);
      boolean canUsePrev = !breakBefore.get(idx) && PVector.dist(prev, origin) < maxLink;
      boolean canUseNext = !breakBefore.get(idx + 1) && PVector.dist(next, origin) < maxLink;
      if (canUsePrev && canUseNext) {
        tangent = PVector.sub(next, prev);
      } else if (canUseNext) {
        tangent = PVector.sub(next, origin);
      } else if (canUsePrev) {
        tangent = PVector.sub(origin, prev);
      }
    }

    PVector normal;
    if (tangent != null && tangent.mag() > 0.0001) {
      tangent.normalize();
      normal = new PVector(-tangent.y, tangent.x);
      PVector outward = PVector.sub(origin, center);
      if (normal.dot(outward) < 0) normal.mult(-1);
    } else {
      normal = PVector.sub(origin, center);
      if (normal.mag() < 0.0001) normal.set(1, 0);
      normal.normalize();
    }
    return normal;
  }

  PVector normalDaImagemFonte(PVector origin) {
    if (sourceImage == null || sourceImage.width <= 1 || sourceImage.height <= 1) return null;
    if (sourceImage.pixels == null || sourceImage.pixels.length == 0) sourceImage.loadPixels();

    float u = origin.x + sourceImage.width * 0.5;
    float v = origin.y + sourceImage.height * 0.5;
    if (u < 1 || v < 1 || u >= sourceImage.width - 1 || v >= sourceImage.height - 1) return null;

    int x = constrain(round(u), 1, sourceImage.width - 2);
    int y = constrain(round(v), 1, sourceImage.height - 2);
    int r = max(2, round(span() * 0.004));
    float left = alphaFonte(x - r, y);
    float right = alphaFonte(x + r, y);
    float up = alphaFonte(x, y - r);
    float down = alphaFonte(x, y + r);
    PVector normal = new PVector(left - right, up - down);

    if (normal.mag() < 0.001) {
      normal.set(origin.x, origin.y);
    }
    if (normal.mag() < 0.001) normal.set(1, 0);
    normal.normalize();
    return normal;
  }

  float alphaFonte(int x, int y) {
    if (sourceImage == null) return 0;
    x = constrain(x, 0, sourceImage.width - 1);
    y = constrain(y, 0, sourceImage.height - 1);
    return (sourceImage.pixels[y * sourceImage.width + x] >>> 24) & 0xFF;
  }
}
