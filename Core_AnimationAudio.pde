void atualizarAnimacao() {
  float audioMotion = constrain(sBass * 0.70 + sMid * 0.55 + sTreble * 0.90 + sPresence * 0.45, 0, 2.0);
  semente     += 0.0025 + audioMotion * 0.0018;
  noiseDynamicTime += 0.006 + audioMotion * 0.020;
  pulso       += 0.018;
  filTick     += 1.0;
  tempoFlutua += 0.004;
  faseFolego  += velFolego;

  flutuaX = map(noise(tempoFlutua, 50), 0, 1, -32, 32);
  flutuaY = map(noise(50, tempoFlutua), 0, 1, -22, 22);
  panfletoTemaPulse = lerp(panfletoTemaPulse, 0, 0.14);
}

void atualizarLayout() {
  float menorDimensao = min(width, height);
  uiHeaderHeight = constrain(height * 0.074, 44, 58);
  uiTabsHeight = constrain(height * 0.058, 34, 48);

  float centroMinimo = constrain(width * 0.46, 420, 760);
  float larguraLateralDisponivel = max(260, width - centroMinimo);
  float larguraMenuDesejada = constrain(width * 0.235, 260, 340);
  float larguraPainelDesejada = constrain(width * 0.235, 260, 340);
  float somaLaterais = larguraMenuDesejada + larguraPainelDesejada;
  if (somaLaterais > larguraLateralDisponivel) {
    float escalaLaterais = larguraLateralDisponivel / max(1, somaLaterais);
    larguraMenuDesejada = max(210, larguraMenuDesejada * escalaLaterais);
    larguraPainelDesejada = max(210, larguraPainelDesejada * escalaLaterais);
  }

  menuWidth = constrain(larguraMenuDesejada, 210, 340);
  painelPadraoWidth = constrain(larguraPainelDesejada, 210, 340);
  menuTabWidth = constrain(menorDimensao * 0.040, 22, 32);
  painelPadraoTabWidth = constrain(menorDimensao * 0.038, 22, 30);
  menuPadding = constrain(menuWidth * 0.055, 10, 20);

  if (exportLayer == null || exportLayer.width != width || exportLayer.height != height) {
    exportLayer = createGraphics(width, height, P2D);
  }

  if (videoRecording) {
    garantirVideoLayer();
  }
}

void garantirVideoLayer() {
  int targetVideoWidth = max(width * exportScale, 1280);
  int targetVideoHeight = max(height * exportScale, 720);
  if (videoLayer == null || videoLayer.width != targetVideoWidth || videoLayer.height != targetVideoHeight) {
    videoLayer = createGraphics(targetVideoWidth, targetVideoHeight, P2D);
    videoFrameBuffer = new byte[targetVideoWidth * targetVideoHeight * 4];
  }
}

void atualizarAudio() {
  // Gate/peso por forma removidos da interface: valores fixos.
  gateB = 0.18;
  gateM = 0.14;
  gateT = 0.04;
  boostT = 2.5;
  gateP = 0.10;
  pB = 0.8;
  pM = 1.2;
  pT = 1.0;
  pP = 1.8;
  duracaoHold = sliders[9][5];
  velDissolve = sliders[10][5];
  velFolego = sliders[11][5];
  espacamentoPalavra = sliders[12][5];
  typoSize = sliders[13][5];
  typoOffsetY = sliders[14][5];
  typoReact = sliders[15][5];
  typoWordOffsetExtra = sliders[16][5];
  typoBaseWidthSolo = sliders[17][5];
  typoBaseWidthWord = sliders[18][5];
  typoTrailAlpha = sliders[19][5];
  typoMainAlpha = sliders[20][5];
  typoParGap = sliders[21][5];
  typoParYOffset = sliders[22][5];
  typoParXOffset = sliders[23][5];
  typoVar2YOffsetA = sliders[24][5];
  typoVar2YOffsetB = sliders[25][5];
  microfoneSensibilidade = sliders[26][5];
  if (mutationParams != null) {
    mutationParams.intensity = sliders[27][5];
    mutationParams.deformationAmount = sliders[28][5];
    mutationParams.noiseAmount = sliders[29][5];
    mutationParams.displacementAmount = sliders[30][5];
    mutationParams.strokeAmount = sliders[31][5];
    mutationParams.scaleAmount = sliders[32][5];
    mutationParams.rotationAmount = sliders[33][5];
    mutationParams.returnSpeed = sliders[34][5];
    mutationParams.growthSpeed = sliders[35][5];
  }

  if (!audioInputAvailable || mic == null || fft == null) {
    sBass = lerp(sBass, 0, 0.08);
    sMid = lerp(sMid, 0, 0.08);
    sTreble = lerp(sTreble, 0, 0.10);
    sPresence = lerp(sPresence, 0, 0.08);
    intensidade = lerp(intensidade, 0, 0.08);
    if (audioData != null) audioData.update(0, 0, 0, 0);
    if (!audioInputWarningShown) {
      audioInputWarningShown = true;
      mostrarStatus("Sem microfone: use controles e presets para mutar a marca");
    }
    return;
  }

  fft.forward(mic.mix);

  float sens = constrain(microfoneSensibilidade, 0.7, 4.0);
  float gateScale = map(sens, 0.7, 4.0, 1.08, 0.45);
  float gateBAdj = gateB * gateScale;
  float gateMAdj = gateM * gateScale;
  float gateTAdj = gateT * gateScale;
  float gatePAdj = gateP * gateScale;

  bassRaw     = energiaComSensibilidade(max(0, energiaBanda(20, 120) - gateBAdj), sens);
  midRaw      = energiaComSensibilidade(max(0, energiaBanda(200, 1000) - gateMAdj), sens);
  float trebleBand = energiaComSensibilidade(max(0, energiaBanda(4000, 12000) - gateTAdj), sens * 0.96);
  float trebleTransient = max(0, trebleBand - sTreble * 0.48);
  trebleImpact = lerp(trebleImpact, trebleTransient, 0.52);
  trebleRaw   = (trebleBand * boostT * 1.25) + (trebleTransient * boostT * 3.35) + (trebleImpact * 1.95);
  presenceRaw = energiaComSensibilidade(max(0, energiaBanda(1200, 4000) - gatePAdj), sens * 0.92);
  // RUIDO desativado.
  noiseRaw = 0;

  sBass     = lerp(sBass, bassRaw, 0.055);
  sMid      = lerp(sMid, midRaw, 0.055);
  sTreble   = lerp(sTreble, trebleRaw, 0.22);
  sPresence = lerp(sPresence, presenceRaw, 0.11);
  // RUIDO desativado.
  sNoise = 0;

  // Onsets: conta quantas bandas iniciaram ataque no frame.
  onsetCount = 0;
  if (sBass - prevSBass > 0.020 && sBass > 0.06) onsetCount++;
  if (sMid - prevSMid > 0.018 && sMid > 0.06) onsetCount++;
  if (sTreble - prevSTreble > 0.026 && sTreble > 0.06) onsetCount++;
  if (sPresence - prevSPresence > 0.020 && sPresence > 0.06) onsetCount++;
  prevSBass = sBass;
  prevSMid = sMid;
  prevSTreble = sTreble;
  prevSPresence = sPresence;

  intensidade = lerp(intensidade, constrain((sBass + sMid + sTreble + sPresence) * 0.45, 0, 1), 0.03);
  if (audioData != null) {
    audioData.update(sBass, sMid, sTreble, intensidade);
  }
}

float energiaComSensibilidade(float energia, float sens) {
  float base = max(0, energia) * sens;
  float curva = map(constrain(sens, 0.7, 4.0), 0.7, 4.0, 1.08, 0.72);
  float comp = pow(max(0.00001, base), curva);
  return min(comp, 6.0);
}
