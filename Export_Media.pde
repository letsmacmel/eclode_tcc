void salvarPNG() {
  String timestamp = timeStamp();
  exportLayer.beginDraw();
  exportLayer.clear();
  renderShapeLayerContent(exportLayer, semente, tempoFlutua, faseFolego, false);
  exportLayer.endDraw();
  exportLayer.save("shape_" + timestamp + ".png");
  mostrarStatus("PNG exportado com sucesso");
}

void salvarPanfletoPNG() {
  String timestamp = timeStamp();
  int[] tamanho = tamanhoExportPanfleto();
  int outW = tamanho[0];
  int outH = tamanho[1];

  PGraphics pg = createGraphics(outW, outH, P2D);
  pg.smooth(8);
  try {
    PImage recorte = capturarRecortePanfletoPreview(-1, false);
    if (recorte == null) {
      mostrarStatus("Falha ao capturar panfleto");
      return;
    }

    pg.beginDraw();
    preencherFundoSolidoPanfleto(pg);
    pg.imageMode(CORNER);
    pg.noTint();
    pg.image(recorte, 0, 0, outW, outH);
    pg.endDraw();

    pg.save(sketchPath("panfleto_" + timestamp + ".png"));
    mostrarStatus("Panfleto PNG exportado com sucesso");
  } catch (Exception e) {
    println("Erro exportando panfleto PNG: " + e.getMessage());
    mostrarStatus("Falha ao salvar panfleto PNG: " + e.getMessage());
  }
}

void salvarPanfletoJPG() {
  String timestamp = timeStamp();
  int[] tamanho = tamanhoExportPanfleto();
  int outW = tamanho[0];
  int outH = tamanho[1];

  PGraphics pg = createGraphics(outW, outH, P2D);
  pg.smooth(8);
  try {
    PImage recorte = capturarRecortePanfletoPreview(-1, false);
    if (recorte == null) {
      mostrarStatus("Falha ao capturar panfleto");
      return;
    }

    pg.beginDraw();
    preencherFundoSolidoPanfleto(pg);
    pg.imageMode(CORNER);
    pg.noTint();
    pg.image(recorte, 0, 0, outW, outH);
    pg.endDraw();

    String caminho = sketchPath("panfleto_" + timestamp + ".jpg");
    salvarPGraphicsComoJPG(pg, caminho);
    mostrarStatus("Panfleto JPG exportado com sucesso");
  } catch (Exception e) {
    println("Erro exportando panfleto: " + e.getMessage());
    mostrarStatus("Falha ao salvar panfleto: " + e.getMessage());
  }
}

void preencherFundoSolidoPanfleto(PGraphics pg) {
  int[] tema = temaPanfletoAtual();
  pg.pushStyle();
  pg.colorMode(RGB, 255);
  pg.background(tema[0], tema[1], tema[2]);
  pg.popStyle();
}

void salvarPGraphicsComoJPG(PGraphics pg, String caminho) {
  PGraphics jpg = createGraphics(pg.width, pg.height, P2D);
  jpg.smooth(8);
  jpg.beginDraw();
  preencherFundoSolidoPanfleto(jpg);
  jpg.imageMode(CORNER);
  jpg.noTint();
  jpg.image(pg, 0, 0);
  jpg.endDraw();
  jpg.save(caminho);
}

void salvarPanfletoMP4() {
  if (ffmpegPath == null || ffmpegPath.length() == 0 || !new File(ffmpegPath).exists()) {
    mostrarStatus("FFmpeg não encontrado");
    return;
  }

  String timestamp = timeStamp();
  int[] tamanho = tamanhoExportPanfleto();
  int outW = tamanho[0] - (tamanho[0] % 2);
  int outH = tamanho[1] - (tamanho[1] % 2);
  outW = max(2, outW);
  outH = max(2, outH);
  int fps = 24;
  int totalFrames = fps * 10;
  String caminho = sketchPath("panfleto_" + timestamp + ".mp4");

  PGraphics pg = createGraphics(outW, outH, P2D);
  pg.smooth(8);
  Process proc = null;
  OutputStream input = null;
  byte[] buffer = new byte[outW * outH * 4];

  int oldMediaExportFrame = panfletoMidiaExportFrame;
  float oldMediaExportFps = panfletoMidiaExportFps;

  try {
    ProcessBuilder pb = new ProcessBuilder(
      ffmpegPath,
      "-y",
      "-f", "rawvideo",
      "-pix_fmt", "rgba",
      "-s", outW + "x" + outH,
      "-r", str(fps),
      "-i", "-",
      "-an",
      "-c:v", "libx264",
      "-preset", "fast",
      "-crf", "20",
      "-pix_fmt", "yuv420p",
      "-movflags", "+faststart",
      caminho
    );
    pb.redirectErrorStream(true);
    proc = pb.start();
    consumirSaida(proc.getInputStream());
    input = proc.getOutputStream();

    panfletoMidiaExportFps = fps;

    for (int i = 0; i < totalFrames; i++) {
      atualizarAudio();
      atualizarMarcaMutavel();
      atualizarEstado();
      atualizarAnimacao();

      PImage recorte = capturarRecortePanfletoPreview(i, false);
      if (recorte == null) continue;
      pg.beginDraw();
      preencherFundoSolidoPanfleto(pg);
      pg.imageMode(CORNER);
      pg.noTint();
      pg.image(recorte, 0, 0, outW, outH);
      pg.endDraw();

      escreverFrameRGBA(input, pg, buffer);
      if (i % 12 == 0) {
        statusMessage = "Exportando MP4: " + i + " / " + totalFrames;
        salvarFlash = true;
        salvarTimer = 4;
      }
      delay(max(1, round(1000.0 / fps)));
    }

    input.flush();
    input.close();
    input = null;

    int exit = proc.waitFor();
    if (exit == 0) {
      mostrarStatus("Panfleto MP4 exportado com sucesso");
    } else {
      mostrarStatus("Falha ao salvar MP4");
    }
  } catch (Exception e) {
    println("Erro exportando MP4 do panfleto: " + e.getMessage());
    mostrarStatus("Erro no MP4 do panfleto");
  } finally {
    try {
      if (input != null) input.close();
    } catch (Exception e) {
    }
    panfletoMidiaExportFrame = oldMediaExportFrame;
    panfletoMidiaExportFps = oldMediaExportFps;
  }
}

void salvarEstampaPNG() {
  String timestamp = timeStamp();
  PImage recorte = capturarRecorteEstampaPreview();
  if (recorte == null) {
    mostrarStatus("Falha ao capturar estampa");
    return;
  }
  PGraphics pg = createGraphics(recorte.width, recorte.height, P2D);
  pg.smooth(8);
  pg.beginDraw();
  pg.colorMode(RGB, 255, 255, 255, 255);
  int fundo = estampaUsarCoresMarca ? 0xFFEFEBE8 : estampaCorFundo;
  pg.background(canalR(fundo), canalG(fundo), canalB(fundo));
  pg.imageMode(CORNER);
  pg.noTint();
  pg.image(recorte, 0, 0);
  pg.endDraw();
  String caminho = sketchPath("estampa_" + timestamp + ".png");
  pg.save(caminho);
  mostrarStatus("Estampa PNG exportada com sucesso");
}

void salvarEstampaJPG() {
  String timestamp = timeStamp();
  PImage recorte = capturarRecorteEstampaPreview();
  if (recorte == null) {
    mostrarStatus("Falha ao capturar estampa");
    return;
  }
  PGraphics pg = createGraphics(recorte.width, recorte.height, P2D);
  pg.smooth(8);
  pg.beginDraw();
  pg.colorMode(RGB, 255);
  int fundo = estampaUsarCoresMarca ? 0xFFEFEBE8 : estampaCorFundo;
  pg.background(canalR(fundo), canalG(fundo), canalB(fundo));
  pg.imageMode(CORNER);
  pg.noTint();
  pg.image(recorte, 0, 0);
  pg.endDraw();
  String caminho = sketchPath("estampa_" + timestamp + ".jpg");
  pg.save(caminho);
  mostrarStatus("Estampa JPG exportada com sucesso");
}

void salvarEstampaMP4() {
  if (ffmpegPath == null || ffmpegPath.length() == 0 || !new File(ffmpegPath).exists()) {
    mostrarStatus("FFmpeg não encontrado");
    return;
  }

  PImage base = capturarRecorteEstampaPreview();
  if (base == null) {
    mostrarStatus("Falha ao capturar estampa");
    return;
  }

  String timestamp = timeStamp();
  int outW = max(2, base.width - (base.width % 2));
  int outH = max(2, base.height - (base.height % 2));
  int fps = 24;
  int totalFrames = fps * 10;
  String caminho = sketchPath("estampa_" + timestamp + ".mp4");
  PGraphics pg = createGraphics(outW, outH, P2D);
  pg.smooth(8);
  Process proc = null;
  OutputStream input = null;
  byte[] buffer = new byte[outW * outH * 4];
  int oldAppPage = appPage;

  try {
    ProcessBuilder pb = new ProcessBuilder(
      ffmpegPath,
      "-y",
      "-f", "rawvideo",
      "-pix_fmt", "rgba",
      "-s", outW + "x" + outH,
      "-r", str(fps),
      "-i", "-",
      "-an",
      "-c:v", "libx264",
      "-preset", "fast",
      "-crf", "20",
      "-pix_fmt", "yuv420p",
      "-movflags", "+faststart",
      caminho
    );
    pb.redirectErrorStream(true);
    proc = pb.start();
    consumirSaida(proc.getInputStream());
    input = proc.getOutputStream();

    appPage = 3;
    for (int i = 0; i < totalFrames; i++) {
      atualizarAudio();
      atualizarMarcaMutavel();
      atualizarEstado();
      atualizarAnimacao();
      PImage recorte = capturarRecorteEstampaPreview();
      if (recorte == null) continue;
      pg.beginDraw();
      pg.colorMode(RGB, 255, 255, 255, 255);
      int fundo = estampaUsarCoresMarca ? 0xFFEFEBE8 : estampaCorFundo;
      pg.background(canalR(fundo), canalG(fundo), canalB(fundo));
      pg.imageMode(CORNER);
      pg.noTint();
      pg.image(recorte, 0, 0, outW, outH);
      pg.endDraw();
      escreverFrameRGBA(input, pg, buffer);
      if (i % 12 == 0) {
        statusMessage = "Exportando estampa MP4: " + i + " / " + totalFrames;
        salvarFlash = true;
        salvarTimer = 4;
      }
    }
    input.flush();
    input.close();
    input = null;
    int exit = proc.waitFor();
    if (exit == 0) mostrarStatus("Estampa MP4 exportada com sucesso");
    else mostrarStatus("Falha ao salvar estampa MP4");
  } catch (Exception e) {
    println("Erro exportando MP4 da estampa: " + e.getMessage());
    mostrarStatus("Erro no MP4 da estampa");
  } finally {
    appPage = oldAppPage;
    try {
      if (input != null) input.close();
    } catch (Exception e) {
    }
  }
}

PImage capturarRecorteEstampaPreview() {
  int oldAppPage = appPage;
  appPage = 3;
  atualizarLayout();
  renderShapeLayer(exportLayer, semente, tempoFlutua, faseFolego);
  int sx = constrain(round(estampaRenderX), 0, max(0, exportLayer.width - 1));
  int sy = constrain(round(estampaRenderY), 0, max(0, exportLayer.height - 1));
  int sw = constrain(round(estampaRenderW), 1, exportLayer.width - sx);
  int sh = constrain(round(estampaRenderH), 1, exportLayer.height - sy);
  PImage recorte = exportLayer.get(sx, sy, sw, sh);
  appPage = oldAppPage;
  return recorte;
}

PImage capturarRecortePanfletoPreview(int mediaFrame, boolean limpo) {
  int oldAppPage = appPage;
  boolean oldExportando = exportandoPanfletoLimpo;
  int oldMediaFrame = panfletoMidiaExportFrame;

  appPage = 2;
  exportandoPanfletoLimpo = limpo;
  if (mediaFrame >= 0) panfletoMidiaExportFrame = mediaFrame;
  atualizarLayout();

  renderShapeLayer(exportLayer, semente, tempoFlutua, faseFolego);

  int sx = constrain(round(panfletoRenderX), 0, max(0, exportLayer.width - 1));
  int sy = constrain(round(panfletoRenderY), 0, max(0, exportLayer.height - 1));
  int sw = constrain(round(panfletoRenderW), 1, exportLayer.width - sx);
  int sh = constrain(round(panfletoRenderH), 1, exportLayer.height - sy);
  PImage recorte = exportLayer.get(sx, sy, sw, sh);

  appPage = oldAppPage;
  exportandoPanfletoLimpo = oldExportando;
  panfletoMidiaExportFrame = oldMediaFrame;
  return recorte;
}

void escreverFrameRGBA(OutputStream input, PGraphics pg, byte[] buffer) throws IOException {
  pg.loadPixels();
  int b = 0;
  for (int i = 0; i < pg.pixels.length; i++) {
    int c = pg.pixels[i];
    buffer[b++] = (byte) ((c >> 16) & 0xFF);
    buffer[b++] = (byte) ((c >> 8) & 0xFF);
    buffer[b++] = (byte) (c & 0xFF);
    buffer[b++] = (byte) ((c >> 24) & 0xFF);
  }
  input.write(buffer, 0, b);
}

int[] tamanhoExportPanfleto() {
  if (panfletoFormatoAtivo == 1) return new int[] { 1754, 1240 };
  if (panfletoFormatoAtivo == 2) return new int[] { 1080, 1350 };
  if (panfletoFormatoAtivo == 3) return new int[] { 1080, 1920 };
  if (panfletoFormatoAtivo == 4) return new int[] { 1920, 1080 };
  if (panfletoFormatoAtivo == 5) return new int[] { 1063, 591 };
  if (panfletoFormatoAtivo == 6) return new int[] { 2186, 820 };
  return new int[] { 1240, 1754 };
}

void salvarJPG() {
  String timestamp = timeStamp();
  renderShapeLayer(exportLayer, semente, tempoFlutua, faseFolego);

  PGraphics jpgLayer = createGraphics(width, height, P2D);
  jpgLayer.smooth(8);
  jpgLayer.beginDraw();
  jpgLayer.background(0);
  jpgLayer.image(exportLayer, 0, 0);
  jpgLayer.endDraw();
  jpgLayer.save("shape_" + timestamp + ".jpg");
  mostrarStatus("JPG exportado com sucesso");
}

void salvarSVG() {
  String timestamp = timeStamp();
  String caminho = sketchPath("shape_" + timestamp + ".svg");
  try {
    if (marcaOriginalSemEfeito() && salvarMarcaSVGVetorial(caminho)) {
      mostrarStatus("SVG vetorial exportado com sucesso");
      return;
    }

    PGraphics svg = createGraphics(width, height, SVG, caminho);
    svg.beginDraw();
    renderShapeLayerContent(svg, semente, tempoFlutua, faseFolego, false);
    svg.dispose();
    svg.endDraw();
    mostrarStatus("SVG com efeito exportado com sucesso");
  } catch (Exception e) {
    println("Falha no SVG vetorial, usando compatibilidade: " + e);
    salvarSVGCompatibilidadeRaster(caminho);
  }
}

void salvarSVGCompatibilidadeRaster(String caminho) {
  PGraphics svg = createGraphics(width, height, SVG, caminho);
  renderShapeLayer(exportLayer, semente, tempoFlutua, faseFolego);
  svg.beginDraw();
  svg.imageMode(CORNER);
  svg.image(exportLayer, 0, 0, width, height);
  svg.dispose();
  svg.endDraw();
  mostrarStatus("SVG exportado em modo compatível");
}

boolean marcaOriginalSemEfeito() {
  return appPage != 2 && appPage != 3 && activeBrand != null && activeBrand.sourceShape != null && mutationParams != null && mutationParams.mode == 0;
}

boolean salvarMarcaSVGVetorial(String caminho) {
  if (activeBrand == null || activeBrand.sourceShape == null || mutationParams == null) return false;

  float assetW = max(1, activeBrand.maxX - activeBrand.minX);
  float assetH = max(1, activeBrand.maxY - activeBrand.minY);
  float fit = min((width * 0.62) / assetW, (height * 0.54) / assetH);
  fit = constrain(fit, 0.04, 7.0);
  int c = corMarcaRenderAjustada(mutationParams, false, 100);

  PGraphics svg = createGraphics(width, height, SVG, caminho);
  svg.beginDraw();
  svg.colorMode(RGB, 255, 255, 255, 255);
  svg.noStroke();
  svg.fill(canalR(c), canalG(c), canalB(c), canalA(c));
  svg.pushMatrix();
  svg.translate(width * 0.5, height * 0.5);
  svg.rotate(activeBrand.currentRotation);
  svg.scale(fit * activeBrand.currentScale);
  svg.shapeMode(CORNER);
  activeBrand.sourceShape.disableStyle();
  svg.shape(activeBrand.sourceShape, -activeBrand.center.x, -activeBrand.center.y);
  activeBrand.sourceShape.enableStyle();
  svg.popMatrix();
  svg.dispose();
  svg.endDraw();
  return true;
}

void alternarCapturaVideo() {
  if (videoRecording) {
    finalizarCapturaVideo();
    return;
  }

  if (!new File(ffmpegPath).exists()) {
    mostrarStatus("FFmpeg não encontrado");
    return;
  }

  garantirVideoLayer();
  videoFolderName = "shape_video_" + timeStamp();
  videoOutputPath = sketchPath(videoFolderName + ".mp4");

  try {
    ProcessBuilder pb = new ProcessBuilder(
      ffmpegPath,
      "-y",
      "-f", "rawvideo",
      "-pix_fmt", "rgba",
      "-s", videoLayer.width + "x" + videoLayer.height,
      "-r", str(exportFrameRate),
      "-i", "-",
      "-an",
      "-c:v", "libx264",
      "-preset", "medium",
      "-crf", "15",
      "-pix_fmt", "yuv420p",
      "-movflags", "+faststart",
      videoOutputPath
    );
    pb.redirectErrorStream(true);
    videoFFmpegProcess = pb.start();
    consumirSaida(videoFFmpegProcess.getInputStream());
    videoFFmpegInput = videoFFmpegProcess.getOutputStream();
  } catch (Exception e) {
    videoFFmpegProcess = null;
    videoFFmpegInput = null;
    mostrarStatus("Falha ao iniciar FFmpeg");
    return;
  }

  videoRecording = true;
  recordedFrames = 0;
  mostrarStatus("Capturando MP4");
}

void atualizarExportacaoVideo() {
  if (!videoRecording || videoFFmpegInput == null) return;

  renderShapeLayer(videoLayer, semente, tempoFlutua, faseFolego);
  enviarFrameParaFFmpeg(videoLayer);
  recordedFrames++;

  if (recordedFrames >= exportFrames) {
    finalizarCapturaVideo();
  } else {
    statusMessage = "Capturando MP4: " + recordedFrames + " / " + exportFrames;
    salvarFlash = true;
    salvarTimer = 2;
  }
}

void finalizarCapturaVideo() {
  if (!videoRecording) return;
  videoRecording = false;
  videoEncoding = true;
  mostrarStatus("Gerando MP4...");
  thread("finalizarProcessoVideo");
}

void finalizarProcessoVideo() {
  try {
    if (videoFFmpegInput != null) {
      videoFFmpegInput.flush();
      videoFFmpegInput.close();
    }
    int exitCode = (videoFFmpegProcess != null) ? videoFFmpegProcess.waitFor() : -1;
    if (exitCode == 0) {
      mostrarStatus("MP4 exportado com sucesso");
    } else {
      mostrarStatus("Falha ao gerar MP4");
    }
  } catch (Exception e) {
    mostrarStatus("Erro no MP4");
  }

  videoFFmpegInput = null;
  videoFFmpegProcess = null;
  videoEncoding = false;
}

void enviarFrameParaFFmpeg(PGraphics pg) {
  if (videoFFmpegInput == null) return;
  pg.loadPixels();
  int total = pg.pixels.length;
  int b = 0;
  for (int i = 0; i < total; i++) {
    int c = pg.pixels[i];
    videoFrameBuffer[b++] = (byte) ((c >> 16) & 0xFF);
    videoFrameBuffer[b++] = (byte) ((c >> 8) & 0xFF);
    videoFrameBuffer[b++] = (byte) (c & 0xFF);
    videoFrameBuffer[b++] = (byte) ((c >> 24) & 0xFF);
  }
  try {
    videoFFmpegInput.write(videoFrameBuffer, 0, b);
  } catch (IOException e) {
    mostrarStatus("Falha escrevendo frame");
    finalizarCapturaVideo();
  }
}

void consumirSaida(final InputStream input) {
  Thread leitor = new Thread(new Runnable() {
    public void run() {
      try {
        BufferedReader br = new BufferedReader(new InputStreamReader(input));
        while (br.readLine() != null) {
        }
        br.close();
      } catch (IOException e) {
      }
    }
  });
  leitor.start();
}

void apagarFrames(File pasta) {
  File[] arquivos = pasta.listFiles();
  if (arquivos == null) return;
  for (File arquivo : arquivos) {
    if (arquivo.isFile() && arquivo.getName().toLowerCase().endsWith(".png")) {
      arquivo.delete();
    }
  }
}
