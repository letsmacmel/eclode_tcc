PImage frameMidiaPanfletoAtual() {
  if (panfletoMidiaFrames == null || panfletoMidiaFrames.length == 0) return null;

  int idx;
  if (panfletoMidiaExportFrame >= 0) {
    idx = floor((panfletoMidiaExportFrame * panfletoMidiaFps) / max(1, panfletoMidiaExportFps));
  } else {
    idx = floor((millis() / 1000.0) * panfletoMidiaFps);
  }
  idx = ((idx % panfletoMidiaFrames.length) + panfletoMidiaFrames.length) % panfletoMidiaFrames.length;
  return panfletoMidiaFrames[idx];
}

void limparMidiaPanfleto() {
  panfletoMidiaFrames = null;
  panfletoMidiaPath = "";
  panfletoMidiaTipo = "";
  panfletoMidiaExportFrame = -1;
}

boolean carregarMidiaAnimadaPanfleto(File selection) {
  if (selection == null) return false;

  String path = selection.getAbsolutePath();
  String lower = path.toLowerCase();
  limparMidiaPanfleto();

  if (lower.endsWith(".gif")) {
    return carregarGifPanfleto(selection);
  }

  if (lower.endsWith(".mp4") || lower.endsWith(".mov") || lower.endsWith(".m4v") || lower.endsWith(".avi") || lower.endsWith(".webm")) {
    return carregarVideoPanfleto(selection);
  }

  PImage img = tentarCarregarImagem(path);
  if (img == null) return false;
  limitarFramePanfleto(img, 900);
  panfletoMidiaFrames = new PImage[] { img };
  panfletoMidiaPath = path;
  panfletoMidiaTipo = "imagem";
  panfletoMidiaFps = 1;
  return true;
}

boolean carregarGifPanfleto(File selection) {
  ArrayList<PImage> frames = new ArrayList<PImage>();
  try {
    Iterator<ImageReader> readers = ImageIO.getImageReadersByFormatName("gif");
    if (!readers.hasNext()) return false;

    ImageReader reader = readers.next();
    ImageInputStream stream = ImageIO.createImageInputStream(selection);
    reader.setInput(stream, false);

    int total = reader.getNumImages(true);
    int step = max(1, (int) ceil(total / 120.0));
    for (int i = 0; i < total; i += step) {
      BufferedImage buffered = reader.read(i);
      PImage frame = pimageFromBuffered(buffered);
      limitarFramePanfleto(frame, 900);
      frames.add(frame);
    }

    stream.close();
    reader.dispose();
  } catch (Exception e) {
    println("Erro carregando GIF: " + e.getMessage());
    return false;
  }

  if (frames.size() == 0) return false;
  panfletoMidiaFrames = frames.toArray(new PImage[frames.size()]);
  panfletoMidiaPath = selection.getAbsolutePath();
  panfletoMidiaTipo = "GIF";
  panfletoMidiaFps = 12;
  return true;
}

boolean carregarVideoPanfleto(File selection) {
  if (ffmpegPath == null || ffmpegPath.length() == 0 || !new File(ffmpegPath).exists()) {
    mostrarStatus("FFmpeg nao encontrado para video");
    return false;
  }

  File cache = new File(sketchPath("panfleto_media_cache"));
  if (!cache.exists()) cache.mkdirs();
  limparPastaFramesPanfleto(cache);

  try {
    ProcessBuilder pb = new ProcessBuilder(
      ffmpegPath,
      "-y",
      "-t", "10",
      "-i", selection.getAbsolutePath(),
      "-vf", "fps=12,scale=720:-2",
      "-q:v", "3",
      new File(cache, "frame_%04d.jpg").getAbsolutePath()
    );
    pb.redirectErrorStream(true);
    Process proc = pb.start();
    consumirSaida(proc.getInputStream());
    int exit = proc.waitFor();
    if (exit != 0) return false;
  } catch (Exception e) {
    println("Erro extraindo video: " + e.getMessage());
    return false;
  }

  File[] arquivos = cache.listFiles();
  if (arquivos == null || arquivos.length == 0) return false;
  java.util.Arrays.sort(arquivos);

  ArrayList<PImage> frames = new ArrayList<PImage>();
  for (int i = 0; i < arquivos.length && frames.size() < 120; i++) {
    if (!arquivos[i].getName().toLowerCase().endsWith(".jpg")) continue;
    PImage frame = loadImage(arquivos[i].getAbsolutePath());
    if (frame == null) continue;
    limitarFramePanfleto(frame, 900);
    frames.add(frame);
  }

  if (frames.size() == 0) return false;
  panfletoMidiaFrames = frames.toArray(new PImage[frames.size()]);
  panfletoMidiaPath = selection.getAbsolutePath();
  panfletoMidiaTipo = "video";
  panfletoMidiaFps = 12;
  return true;
}

void limparPastaFramesPanfleto(File cache) {
  File[] arquivos = cache.listFiles();
  if (arquivos == null) return;
  for (File arquivo : arquivos) {
    if (arquivo.isFile() && arquivo.getName().startsWith("frame_")) {
      arquivo.delete();
    }
  }
}

PImage pimageFromBuffered(BufferedImage buffered) {
  PImage img = createImage(buffered.getWidth(), buffered.getHeight(), ARGB);
  img.loadPixels();
  buffered.getRGB(0, 0, buffered.getWidth(), buffered.getHeight(), img.pixels, 0, buffered.getWidth());
  img.updatePixels();
  return img;
}

void limitarFramePanfleto(PImage img, int maxSide) {
  if (img == null || max(img.width, img.height) <= maxSide) return;
  if (img.width >= img.height) {
    img.resize(maxSide, 0);
  } else {
    img.resize(0, maxSide);
  }
}
