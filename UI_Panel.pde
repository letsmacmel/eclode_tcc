void desenharBarra() {
  colorMode(RGB, 255);
  if (fontHelv != null) textFont(fontHelv);
  desenharMenuLateral();
  desenharMenuPadroes();
  desenharBotaoMostrar();
  desenharBotaoMostrarPadroes();
  desenharTabsCentro();
  desenharHeaderApp();
  colorMode(HSB, 360, 100, 100, 100);
}

void desenharHeaderApp() {
  noStroke();
  fill(red(UI_DARK), green(UI_DARK), blue(UI_DARK), 252);
  rect(0, 0, width, uiHeaderHeight);
  fill(red(UI_PANEL_SOFT), green(UI_PANEL_SOFT), blue(UI_PANEL_SOFT), 190);
  rect(0, uiHeaderHeight - 12, width, 12);
  stroke(red(UI_LINE), green(UI_LINE), blue(UI_LINE), 150);
  line(0, uiHeaderHeight - 1, width, uiHeaderHeight - 1);
  noStroke();

  float logoX = 22;
  float logoY = uiHeaderHeight * 0.5;
  if (interfaceLogo != null && interfaceLogo.width > 0 && interfaceLogo.height > 0) {
    imageMode(CENTER);
    noTint();
    float logoH = min(40, uiHeaderHeight - 16);
    float logoW = logoH * interfaceLogo.width / float(interfaceLogo.height);
    image(interfaceLogo, logoX + logoW * 0.5, logoY, logoW, logoH);
  } else {
    fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT));
    textAlign(LEFT, CENTER);
    textSize(constrain(height * 0.021, 16, 19));
    text(APP_NAME, logoX, logoY);
  }
}

void desenharBotaoHeader(float x, float y, float w, float h, String label) {
  stroke(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN));
  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN), 34);
  rect(x, y, w, h, 6);
  noStroke();
  fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT));
  textoCentralizadoAjustado(label, x + w * 0.5, y + h * 0.5, w - 18, constrain(height * 0.013, 9.5, 11), 7);
}

void desenharTabsCentro() {
  float leftX = max(0, menuOffsetX + menuWidth);
  float rightX = width - painelPadraoWidth + painelPadraoOffsetX;
  float tabsX = leftX;
  float tabsW = max(0, rightX - leftX);
  float tabsY = uiHeaderHeight;
  if (tabsW < 80) return;

  noStroke();
  fill(red(UI_DARK), green(UI_DARK), blue(UI_DARK), 238);
  rect(tabsX, tabsY, tabsW, uiTabsHeight);
  stroke(red(UI_LINE), green(UI_LINE), blue(UI_LINE), 150);
  line(tabsX, tabsY + uiTabsHeight - 1, tabsX + tabsW, tabsY + uiTabsHeight - 1);
  noStroke();

  float tabW = tabsW / uiTopTabButtons.length;
  for (int i = 0; i < uiTopTabButtons.length; i++) {
    float x = tabsX + i * tabW;
    uiTopTabButtons[i][0] = x;
    uiTopTabButtons[i][1] = tabsY;
    uiTopTabButtons[i][2] = tabW;
    uiTopTabButtons[i][3] = uiTabsHeight;

    boolean ativo = (uiTopTabPages[i] == appPage);
    boolean hover = mouseX >= x && mouseX <= x + tabW && mouseY >= tabsY && mouseY <= tabsY + uiTabsHeight;
    if (ativo) {
      fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN), 95);
      rect(x + 6, tabsY + 7, tabW - 12, uiTabsHeight - 14, 7);
    } else if (hover) {
      fill(red(UI_BROWN), green(UI_BROWN), blue(UI_BROWN), 90);
      rect(x + 6, tabsY + 7, tabW - 12, uiTabsHeight - 14, 7);
    }
    if (ativo) fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT));
    else if (hover) fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT), 210);
    else fill(red(UI_MUTED), green(UI_MUTED), blue(UI_MUTED), 185);
    textoCentralizadoAjustado(uiTopTabLabels[i], x + tabW * 0.5, tabsY + uiTabsHeight * 0.5, tabW - 20, constrain(height * 0.0125, 9, 10.5), 7);

    if (ativo) {
      fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN));
      rect(x + tabW * 0.28, tabsY + uiTabsHeight - 4, tabW * 0.44, 3, 2);
    }
  }
}

void desenharMenuLateral() {
  float panelX = menuOffsetX;
  float panelInnerX = panelX + menuPadding;
  float trackWidth = max(96, menuWidth - (menuPadding * 2));
  float escalaUi = constrain(min(width, height) / 720.0, 0.70, 1.0);
  float y = uiHeaderHeight + 12 * escalaUi - menuScrollY;
  float buttonH = constrain(height * 0.039, 25, 34);
  float sectionGap = 8 * escalaUi;
  float labelSize = constrain(min(width, height) * 0.014, 8.8, 11.5);
  float titleSize = constrain(min(width, height) * 0.022, 13.5, 19);

  desenharPainelBase(panelX, menuWidth, true);
  clip(panelX, 0, menuWidth, height);
  limparBotoesPagina();

  if (appPage == 0) {
    y = desenharPainelDesignEsquerdo(panelInnerX, y, trackWidth, buttonH, labelSize, titleSize);
  } else if (appPage == 2) {
    y = desenharPainelPanfletoEsquerdo(panelInnerX, y, trackWidth, buttonH, labelSize, titleSize);
  } else if (appPage == 3) {
    y = desenharPainelEstampaEsquerdo(panelInnerX, y, trackWidth, buttonH, labelSize, titleSize);
  } else {
    y = desenharPainelExportEsquerdo(panelInnerX, y, trackWidth, buttonH, labelSize, titleSize);
  }

  noClip();
  float legacyContentHeight = y + menuScrollY + 22;
  menuMaxScrollY = max(0, legacyContentHeight - height);
  menuScrollY = constrain(menuScrollY, 0, menuMaxScrollY);
  desenharScrollMenu(panelX, menuMaxScrollY);
  if (appPage >= 0) return;

  linhaReativosButton[0] = panelInnerX;
  linhaReativosButton[1] = y;
  linhaReativosButton[2] = trackWidth;
  linhaReativosButton[3] = buttonH;
  desenharBotaoAcaoEstado(linhaReativosButton, modoLinhaReativos ? "Modo palavra: ON" : "Modo palavra: OFF", modoLinhaReativos);
  y += linhaReativosButton[3] + 8;

  simboloPrincipalButton[0] = panelInnerX;
  simboloPrincipalButton[1] = y;
  simboloPrincipalButton[2] = trackWidth;
  simboloPrincipalButton[3] = buttonH;
  desenharBotaoAcaoEstado(simboloPrincipalButton, mostrarSimboloPrincipal ? "Simbolo principal: ON" : "Simbolo principal: OFF", mostrarSimboloPrincipal);
  y += simboloPrincipalButton[3] + 8;

  tipografiaPalavraButton[0] = panelInnerX;
  tipografiaPalavraButton[1] = y;
  tipografiaPalavraButton[2] = trackWidth;
  tipografiaPalavraButton[3] = buttonH;
  desenharBotaoAcaoEstado(tipografiaPalavraButton, mostrarTipografiaPalavra ? "Identidade: ON" : "Identidade: OFF", mostrarTipografiaPalavra);
  y += tipografiaPalavraButton[3] + 8;

  float tGap = 8;
  int totalTipos = max(1, tipografiaVarianteButtons.length);
  float tW = (trackWidth - tGap * (totalTipos - 1)) / totalTipos;
  for (int i = 0; i < tipografiaVarianteButtons.length; i++) {
    tipografiaVarianteButtons[i][0] = panelInnerX + i * (tW + tGap);
    tipografiaVarianteButtons[i][1] = y;
    tipografiaVarianteButtons[i][2] = tW;
    tipografiaVarianteButtons[i][3] = buttonH;
    String tLabel = tipografiaVarianteLabels[i];
    desenharBotaoAcaoEstado(tipografiaVarianteButtons[i], tLabel, tipografiaVarianteAtiva == i);
  }
  y += buttonH + 12;

  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN));
  textAlign(LEFT, TOP);
  textSize(labelSize);
  text("Cor logo/simbolo", panelInnerX, y);
  y += 18;

  float corGap = 8;
  float corH = constrain(height * 0.038, 24, 32);
  float corW = (trackWidth - corGap) * 0.5;
  for (int i = 0; i < modoCorButtons.length; i++) {
    int col = i % 2;
    int row = i / 2;
    modoCorButtons[i][0] = panelInnerX + col * (corW + corGap);
    modoCorButtons[i][1] = y + row * (corH + corGap);
    modoCorButtons[i][2] = corW;
    modoCorButtons[i][3] = corH;
    desenharBotaoAcaoEstado(modoCorButtons[i], modoCorLabels[i], modoCorGlobal == modoCorValores[i]);
  }
  int corRows = (int) ceil(modoCorButtons.length / 2.0);
  y += corH * corRows + corGap * (corRows - 1) + 14;

  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN));
  textAlign(LEFT, TOP);
  textSize(labelSize);
  text("Modo forma", panelInnerX, y);
  y += 18;

  float smallH = constrain(height * 0.040, 26, 34);
  float gap = 8;
  float bw = (trackWidth - gap) * 0.5;
  for (int i = 0; i < 5; i++) {
    int col = i % 2;
    int row = i / 2;
    float bx = panelInnerX + col * (bw + gap);
    float by = y + row * (smallH + gap);
    if (i == 4) {
      bx = panelInnerX;
      bw = trackWidth;
    }

    modoFormaButtons[i][0] = bx;
    modoFormaButtons[i][1] = by;
    modoFormaButtons[i][2] = (i == 4) ? trackWidth : (trackWidth - gap) * 0.5;
    modoFormaButtons[i][3] = smallH;
    desenharBotaoAcaoEstado(modoFormaButtons[i], modoFormaLabels[i], modoFormaManual == i);
  }
  y += (smallH + gap) * 3 + sectionGap;

  for (int i = 0; i < sliderVisivel.length; i++) sliderVisivel[i] = false;

  float cabecalhoH = 28;
  for (int i = 0; i < sliders.length; i++) {
    sliders[i][0] = -9999;
    sliders[i][1] = -9999;
    sliders[i][2] = 0;
  }

  for (int g = 0; g < sliderGrupoNomes.length; g++) {
    sliderGrupoCabecalho[g][0] = panelInnerX;
    sliderGrupoCabecalho[g][1] = y;
    sliderGrupoCabecalho[g][2] = trackWidth;
    sliderGrupoCabecalho[g][3] = cabecalhoH;
    desenharCabecalhoGrupo(g);
    y += cabecalhoH + 8;

    if (!sliderGrupoAberto[g]) {
      y += 2;
      continue;
    }

    for (int j = 0; j < sliderGrupoIndices[g].length; j++) {
      int idx = sliderGrupoIndices[g][j];
      sliders[idx][0] = panelInnerX;
      sliders[idx][1] = y;
      sliders[idx][2] = trackWidth;
      sliderVisivel[idx] = true;
      desenharSlider(idx);
      y += constrain(height * 0.050, 30, 38);
    }
    y += sectionGap;
  }

  noClip();
  float contentHeight = y + menuScrollY + 22;
  menuMaxScrollY = max(0, contentHeight - height);
  menuScrollY = constrain(menuScrollY, 0, menuMaxScrollY);
  desenharScrollMenu(panelX, menuMaxScrollY);
}

void desenharScrollMenu(float panelX, float maxScroll) {
  if (maxScroll <= 1) return;

  float trackY = uiHeaderHeight + 12;
  float trackH = height - trackY - 12;
  float thumbH = max(36, trackH * (height / (height + maxScroll)));
  float thumbY = trackY + (trackH - thumbH) * (menuScrollY / maxScroll);

  noStroke();
  fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT), 22);
  rect(panelX + menuWidth - 7, trackY, 2, trackH, 2);
  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN), 185);
  rect(panelX + menuWidth - 9, thumbY, 5, thumbH, 4);
}

void desenharPainelBase(float panelX, float panelW, boolean esquerda) {
  noStroke();
  fill(red(UI_DARK), green(UI_DARK), blue(UI_DARK), 246);
  rect(panelX, 0, panelW, height);
  fill(red(UI_PANEL_SOFT), green(UI_PANEL_SOFT), blue(UI_PANEL_SOFT), 84);
  rect(panelX, uiHeaderHeight, panelW, height - uiHeaderHeight);
  stroke(red(UI_LINE), green(UI_LINE), blue(UI_LINE), 160);
  if (esquerda) line(panelX + panelW - 1, 0, panelX + panelW - 1, height);
  else line(panelX, 0, panelX, height);
  stroke(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT), 12);
  if (esquerda) line(panelX + panelW - 2, uiHeaderHeight, panelX + panelW - 2, height);
  else line(panelX + 1, uiHeaderHeight, panelX + 1, height);
  noStroke();
}

void limparBotoesPagina() {
  zerarBotao(loadBrandButton);
  zerarBotao(loadImageBrandButton);
  zerarBotao(randomDNAButton);
  zerarBotao(resetBrandButton);
  zerarBotao(freezeBrandButton);
  zerarBotao(exportPngButton);
  zerarBotao(brandToggleButton);
  zerarBotao(playlistSaveButton);
  zerarBotao(estampaFotoAddButton);
  zerarBotao(estampaFotoLimparButton);
  zerarBotao(estampaRandomButton);
  zerarBotao(estampaExportPngButton);
  zerarBotao(estampaExportJpgButton);
  zerarBotao(estampaExportMp4Button);
  zerarBotao(estampaCoresMarcaButton);
  for (int i = 0; i < estampaColorButtons.length; i++) zerarBotao(estampaColorButtons[i]);
  for (int i = 0; i < estampaPreviewButtons.length; i++) zerarBotao(estampaPreviewButtons[i]);
  for (int i = 0; i < estampaHsvSliders.length; i++) zerarSliderArray(estampaHsvSliders[i]);
  zerarBotao(panfletoExportPngButton);
  zerarBotao(panfletoExportMp4Button);
  zerarBotao(panfletoMidiaAddButton);
  zerarBotao(panfletoTextoAddButton);
  for (int i = 0; i < panfletoTextoCorButtons.length; i++) zerarBotao(panfletoTextoCorButtons[i]);
  for (int i = 0; i < panfletoTextoMatizSlider.length; i++) panfletoTextoMatizSlider[i] = 0;
  zerarBotao(panfletoFundoPaletaToggleButton);
  zerarBotao(panfletoFundoPaletaAddButton);
  zerarBotao(panfletoFundoPaletaHexField);
  zerarBotao(panfletoFundoPaletaHexApplyButton);
  zerarBotao(panfletoFundoPaletaPasteButton);
  for (int i = 0; i < panfletoFundoPaletaCountButtons.length; i++) zerarBotao(panfletoFundoPaletaCountButtons[i]);
  for (int i = 0; i < panfletoFundoPaletaSlotButtons.length; i++) zerarBotao(panfletoFundoPaletaSlotButtons[i]);
  zerarBotao(panfletoResetZoomButton);
  zerarBotao(panfletoAgruparTextosButton);
  zerarBotao(panfletoLogoExtraToggleButton);
  zerarBotao(panfletoEstampaToggleButton);
  zerarBotao(panfletoAvancadoButton);
  zerarBotao(panfletoSimboloToggleButton);
  zerarBotao(panfletoSimboloAcimaButton);
  zerarBotao(panfletoMascaraAddButton);
  for (int i = 0; i < panfletoLayoutButtons.length; i++) zerarBotao(panfletoLayoutButtons[i]);
  for (int i = 0; i < panfletoObjetoFormaButtons.length; i++) zerarBotao(panfletoObjetoFormaButtons[i]);
  for (int i = 0; i < panfletoObjetoQuantidadeButtons.length; i++) zerarBotao(panfletoObjetoQuantidadeButtons[i]);
  for (int i = 0; i < panfletoFormatoButtons.length; i++) zerarBotao(panfletoFormatoButtons[i]);
  for (int i = 0; i < panfletoEstampaAplicacaoButtons.length; i++) zerarBotao(panfletoEstampaAplicacaoButtons[i]);
  for (int i = 0; i < panfletoEstampaBlendButtons.length; i++) zerarBotao(panfletoEstampaBlendButtons[i]);
  for (int i = 0; i < panfletoEstampaMascaraButtons.length; i++) zerarBotao(panfletoEstampaMascaraButtons[i]);
  for (int i = 0; i < panfletoMascaraSelectButtons.length; i++) zerarBotao(panfletoMascaraSelectButtons[i]);
  for (int i = 0; i < panfletoMascaraFluxoButtons.length; i++) zerarBotao(panfletoMascaraFluxoButtons[i]);
  for (int i = 0; i < panfletoMascaraConteudoButtons.length; i++) zerarBotao(panfletoMascaraConteudoButtons[i]);
  for (int i = 0; i < panfletoLogoExtraSliders.length; i++) zerarSliderArray(panfletoLogoExtraSliders[i]);
  for (int i = 0; i < mutationModeButtons.length; i++) zerarBotao(mutationModeButtons[i]);
  for (int i = 0; i < deformationModeButtons.length; i++) zerarBotao(deformationModeButtons[i]);
  for (int i = 0; i < identityPresetButtons.length; i++) zerarBotao(identityPresetButtons[i]);
  for (int i = 0; i < meshDetailButtons.length; i++) zerarBotao(meshDetailButtons[i]);
  for (int i = 0; i < paletteButtons.length; i++) zerarBotao(paletteButtons[i]);
  for (int i = 0; i < frequencyInfluenceSliders.length; i++) zerarSliderArray(frequencyInfluenceSliders[i]);
  for (int i = 0; i < marcaHsvSliders.length; i++) zerarSliderArray(marcaHsvSliders[i]);
  zerarBotao(marcaPaletaToggleButton);
  zerarBotao(marcaPaletaAddButton);
  zerarBotao(marcaPaletaHexField);
  zerarBotao(marcaPaletaHexApplyButton);
  zerarBotao(marcaPaletaPasteButton);
  for (int i = 0; i < marcaPaletaCountButtons.length; i++) zerarBotao(marcaPaletaCountButtons[i]);
  for (int i = 0; i < marcaPaletaSlotButtons.length; i++) zerarBotao(marcaPaletaSlotButtons[i]);
  for (int i = 0; i < playlistSlotButtons.length; i++) zerarBotao(playlistSlotButtons[i]);
  for (int i = 0; i < exportPageButtons.length; i++) zerarBotao(exportPageButtons[i]);
}

void zerarBotao(float[] b) {
  if (b == null || b.length < 4) return;
  b[0] = -9999;
  b[1] = -9999;
  b[2] = 0;
  b[3] = 0;
}

void zerarSliderArray(float[] s) {
  if (s == null) return;
  for (int i = 0; i < s.length; i++) s[i] = 0;
}

float tamanhoTextoParaCaber(String texto, float tamanhoBase, float tamanhoMin, float larguraMax) {
  String t = texto == null ? "" : texto;
  float size = tamanhoBase;
  textSize(size);
  while (size > tamanhoMin && textWidth(t) > larguraMax) {
    size -= 0.5;
    textSize(size);
  }
  return size;
}

String textoComReticencias(String texto, float larguraMax, float tamanho) {
  String t = texto == null ? "" : texto;
  textSize(tamanho);
  if (textWidth(t) <= larguraMax) return t;
  String ell = "...";
  while (t.length() > 0 && textWidth(t + ell) > larguraMax) {
    t = t.substring(0, t.length() - 1);
  }
  return t.length() == 0 ? ell : t + ell;
}

void textoCentralizadoAjustado(String texto, float cx, float cy, float larguraMax, float tamanhoBase, float tamanhoMin) {
  String t = texto == null ? "" : texto;
  textAlign(CENTER, CENTER);
  float size = tamanhoTextoParaCaber(t, tamanhoBase, tamanhoMin, larguraMax);
  textSize(size);
  text(textoComReticencias(t, larguraMax, size), cx, cy);
}

float desenharTituloPainel(String titulo, float x, float y, float titleSize) {
  fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT));
  textAlign(LEFT, TOP);
  float titleMaxW = (x > width * 0.5) ? painelPadraoWidth - menuPadding * 2 : menuWidth - menuPadding * 2;
  float titleTextSize = tamanhoTextoParaCaber(titulo, titleSize, 11, titleMaxW);
  textSize(titleTextSize);
  text(textoComReticencias(titulo, titleMaxW, titleTextSize), x, y);
  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN));
  rect(x, y + titleSize + 7, 28, 2, 2);
  return y + 34;
}

float desenharSecaoLabel(String label, float x, float y, float labelSize) {
  float sectionW = (x > width * 0.5) ? painelPadraoWidth - menuPadding * 2 : menuWidth - menuPadding * 2;
  sectionW = max(40, sectionW);
  stroke(red(UI_LINE), green(UI_LINE), blue(UI_LINE), 150);
  strokeWeight(1);
  line(x, y, x + sectionW, y);
  noStroke();
  y += 11;
  fill(red(UI_MUTED), green(UI_MUTED), blue(UI_MUTED));
  textAlign(LEFT, TOP);
  float sectionTextSize = tamanhoTextoParaCaber(label, constrain(labelSize, 9, 10.5), 7.5, sectionW);
  textSize(sectionTextSize);
  text(textoComReticencias(label, sectionW, sectionTextSize), x, y);
  return y + 25;
}

float desenharPainelDesignEsquerdo(float x, float y, float w, float buttonH, float labelSize, float titleSize) {
  y = desenharTituloPainel("Entrada", x, y, titleSize);

  y = desenharSecaoLabel("Fonte sonora", x, y, labelSize);
  fill(audioInputAvailable ? 170 : 120);
  textAlign(LEFT, TOP);
  textSize(constrain(height * 0.012, 9, 11));
  text(audioInputAvailable ? "Microfone ao vivo" : "Sem microfone detectado", x, y);
  y += 16;
  desenharVisualizadorFrequencias(x, y, w, 22);
  y += 34;

  y = desenharSecaoLabel("Identidade importada", x, y, labelSize);
  loadBrandButton[0] = x;
  loadBrandButton[1] = y;
  loadBrandButton[2] = w;
  loadBrandButton[3] = buttonH;
  desenharBotaoAcao(loadBrandButton, "Carregar SVG");
  y += buttonH + 8;

  loadImageBrandButton[0] = x;
  loadImageBrandButton[1] = y;
  loadImageBrandButton[2] = w;
  loadImageBrandButton[3] = buttonH;
  desenharBotaoAcao(loadImageBrandButton, "Carregar PNG/JPG");
  y += buttonH + 8;

  fill(150);
  textAlign(LEFT, TOP);
  textSize(constrain(height * 0.014, 10, 12));
  text(activeBrandName, x, y);
  y += 24;

  y = desenharTituloPainel("Comportamento sonoro", x, y, titleSize);

  randomDNAButton[0] = x;
  randomDNAButton[1] = y;
  randomDNAButton[2] = w;
  randomDNAButton[3] = buttonH;
  desenharBotaoAcao(randomDNAButton, "Gerar variacao");
  y += buttonH + 8;

  resetBrandButton[0] = x;
  resetBrandButton[1] = y;
  resetBrandButton[2] = (w - 8) * 0.5;
  resetBrandButton[3] = buttonH;
  desenharBotaoAcao(resetBrandButton, "Restaurar");

  freezeBrandButton[0] = x + resetBrandButton[2] + 8;
  freezeBrandButton[1] = y;
  freezeBrandButton[2] = resetBrandButton[2];
  freezeBrandButton[3] = buttonH;
  desenharBotaoAcaoEstado(freezeBrandButton, mutationParams != null && mutationParams.freezeState ? "CONGELADO" : "CONGELAR", mutationParams != null && mutationParams.freezeState);
  y += buttonH + 8;

  brandToggleButton[0] = x;
  brandToggleButton[1] = y;
  brandToggleButton[2] = w;
  brandToggleButton[3] = buttonH;
  desenharBotaoAcaoEstado(brandToggleButton, brandSystemEnabled ? "SISTEMA LIGADO" : "SISTEMA DESLIGADO", brandSystemEnabled);
  y += buttonH + 16;

  float gap = max(5, 8 * constrain(w / 220.0, 0.70, 1.0));
  float bh = constrain(height * 0.038, 24, 32);
  int buttonCols = w < 190 ? 1 : 2;
  float bw = buttonCols == 1 ? w : (w - gap) * 0.5;

  y = desenharSecaoLabel("Densidade de pontos", x, y, labelSize);
  float densidadePontos = activeBrand != null ? activeBrand.maxRenderPoints : 1800;
  pointDensitySlider[0] = x;
  pointDensitySlider[1] = y + 18;
  pointDensitySlider[2] = w;
  pointDensitySlider[3] = 150;
  pointDensitySlider[4] = 5200;
  pointDensitySlider[5] = densidadePontos;
  desenharSliderGenerico(pointDensitySlider, "Quantidade", 0);
  y += 54;

  y = desenharSecaoLabel("Camada visual", x, y, labelSize);
  for (int i = 0; i < mutationModeButtons.length; i++) {
    int col = i % buttonCols;
    int row = i / buttonCols;
    mutationModeButtons[i][0] = x + col * (bw + gap);
    mutationModeButtons[i][1] = y + row * (bh + gap);
    boolean ultimoSozinho = (buttonCols == 2 && mutationModeButtons.length % 2 == 1) && i == mutationModeButtons.length - 1;
    mutationModeButtons[i][2] = ultimoSozinho ? w : bw;
    mutationModeButtons[i][3] = bh;
    boolean ativo = mutationParams != null && mutationParams.mode == i;
    desenharBotaoAcaoEstado(mutationModeButtons[i], mutationModeLabels[i], ativo);
  }
  int visualBaseRows = ceil(mutationModeButtons.length / float(buttonCols));
  y += (bh + gap) * visualBaseRows + 14;

  y = desenharSecaoLabel("Comportamento sonoro", x, y, labelSize);
  for (int i = 0; i < deformationModeButtons.length; i++) {
    int col = i % buttonCols;
    int row = i / buttonCols;
    deformationModeButtons[i][0] = x + col * (bw + gap);
    deformationModeButtons[i][1] = y + row * (bh + gap);
    deformationModeButtons[i][2] = (buttonCols == 2 && i == deformationModeButtons.length - 1) ? w : bw;
    deformationModeButtons[i][3] = bh;
    boolean ativo = mutationParams != null && mutationParams.deformationMode == i;
    desenharBotaoAcaoEstado(deformationModeButtons[i], deformationModeLabels[i], ativo);
  }
  int deformationRows = ceil(deformationModeButtons.length / float(buttonCols));
  return y + (bh + gap) * deformationRows + 14;
/*

  y = desenharSecaoLabel("Sensibilidade das frequências", x, y, labelSize);
  for (int i = 0; i < frequencyInfluenceSliders.length; i++) {
    float val = 1.0;
    if (mutationParams != null) {
      if (i == 0) val = mutationParams.bassInfluence;
      if (i == 1) val = mutationParams.midInfluence;
      if (i == 2) val = mutationParams.trebleInfluence;
      if (i == 3) val = mutationParams.solidness;
    }
    frequencyInfluenceSliders[i][0] = x;
    frequencyInfluenceSliders[i][1] = y + 18;
    frequencyInfluenceSliders[i][2] = w;
    frequencyInfluenceSliders[i][3] = 0.0;
    frequencyInfluenceSliders[i][4] = i == 3 ? 1.0 : 2.0;
    frequencyInfluenceSliders[i][5] = val;
    desenharSliderLinha(frequencyInfluenceLabels[i], frequencyInfluenceSliders[i], val);
    y += 44;
  }
  y += 8;

  y = desenharTituloPainel("Aparência da marca", x, y, titleSize);

  y = desenharSecaoLabel("Paleta de cor", x, y, labelSize);
  for (int i = 0; i < paletteButtons.length; i++) {
    int col = i % 2;
    int row = i / 2;
    paletteButtons[i][0] = x + col * (bw + gap);
    paletteButtons[i][1] = y + row * (bh + gap);
    paletteButtons[i][2] = bw;
    paletteButtons[i][3] = bh;
    desenharBotaoAcao(paletteButtons[i], paletteLabels[i]);
  }
  return y + (bh + gap) * 2 + 18;
*/
}

float desenharAudioMetersDesign(float x, float y, float w, float labelSize) {
  y = desenharSecaoLabel(audioInputAvailable ? "Entrada sonora" : "Entrada sonora indisponível", x, y, labelSize);
  float barH = 5;
  float gapY = 5;
  y = desenharAudioMeterLinha("Grave", audioData != null ? audioData.bass : 0, x, y, w, barH);
  y += gapY;
  y = desenharAudioMeterLinha("Médio", audioData != null ? audioData.mid : 0, x, y, w, barH);
  y += gapY;
  y = desenharAudioMeterLinha("Agudo", audioData != null ? audioData.treble : 0, x, y, w, barH);
  y += gapY;
  y = desenharAudioMeterLinha("Energia", audioData != null ? audioData.energy : 0, x, y, w, barH);
  return y + 8;
}

float desenharAudioMeterLinha(String label, float value, float x, float y, float w, float h) {
  fill(red(UI_MUTED), green(UI_MUTED), blue(UI_MUTED));
  textAlign(LEFT, CENTER);
  textSize(constrain(height * 0.0115, 9, 11));
  text(label, x, y + h * 0.5);
  float bx = x + 50;
  float bw = max(10, w - 50);
  noStroke();
  fill(red(UI_DARK), green(UI_DARK), blue(UI_DARK));
  rect(bx, y, bw, h, 3);
  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN));
  rect(bx, y, bw * constrain(value, 0, 1), h, 3);
  return y + h;
}

void desenharSliderLinha(String label, float[] sliderData, float value) {
  float x = sliderData[0];
  float y = sliderData[1];
  float w = sliderData[2];
  float mn = sliderData[3];
  float mx = sliderData[4];
  desenharSliderUi(x, y, w, mn, mx, value, label, 2);
}

float desenharPainelPanfletoEsquerdo(float x, float y, float w, float buttonH, float labelSize, float titleSize) {
  y = desenharTituloPainel("Panfleto", x, y, titleSize);

  y = desenharSecaoLabel("Exportar", x, y, labelSize);
  panfletoExportPngButton[0] = x;
  panfletoExportPngButton[1] = y;
  panfletoExportPngButton[2] = w;
  panfletoExportPngButton[3] = buttonH;
  desenharBotaoAcao(panfletoExportPngButton, "Exportar panfleto JPG");
  y += buttonH + 8;

  panfletoExportMp4Button[0] = x;
  panfletoExportMp4Button[1] = y;
  panfletoExportMp4Button[2] = w;
  panfletoExportMp4Button[3] = buttonH;
  desenharBotaoAcao(panfletoExportMp4Button, "Exportar MP4 10s");
  y += buttonH + 18;

  y = desenharSecaoLabel("Estado", x, y, labelSize);

  fill(175);
  textAlign(LEFT, TOP);
  textSize(labelSize + 1);
  text("Formato: " + panfletoFormatoLabels[panfletoFormatoAtivo], x, y);
  y += 24;
  text("Layout: " + panfletoLayoutLabels[panfletoLayoutAtivo], x, y);
  y += 24;
  text("Fundo: " + hexMarca(corFundoPanfletoAtual()), x, y);
  y += 24;
  text("Foto: " + (panfletoFoto != null ? "carregada" : "nenhuma"), x, y);
  y += 34;

  y = desenharSecaoLabel("Aplicacao", x, y, labelSize);
  text("Posicao: " + nf(panfletoMarcaX, 0, 0) + " / " + nf(panfletoMarcaY, 0, 0), x, y);
  y += 24;
  text("Tamanho: " + nf(panfletoMarcaEscala, 0, 2), x, y);
  y += 24;
  text("Textos: " + (panfletoMostrarTextos ? "ligados" : "desligados"), x, y);
  y += 24;
  text("Simbolo: " + (panfletoMostrarSimbolo ? "ligado" : "desligado"), x, y);
  return y + 22;
}

float desenharPainelEstampaEsquerdo(float x, float y, float w, float buttonH, float labelSize, float titleSize) {
  y = desenharTituloPainel("Estampa", x, y, titleSize);
  y = desenharSecaoLabel("Base da identidade", x, y, labelSize);

  estampaFotoAddButton[0] = x;
  estampaFotoAddButton[1] = y;
  estampaFotoAddButton[2] = w;
  estampaFotoAddButton[3] = buttonH;
  desenharBotaoAcao(estampaFotoAddButton, "Adicionar textura");
  y += buttonH + 8;

  estampaFotoLimparButton[0] = x;
  estampaFotoLimparButton[1] = y;
  estampaFotoLimparButton[2] = w;
  estampaFotoLimparButton[3] = buttonH;
  desenharBotaoAcao(estampaFotoLimparButton, "Remover textura");
  y += buttonH + 14;

  fill(175);
  textAlign(LEFT, TOP);
  textSize(labelSize + 1);
  text("Identidade: " + (activeBrand != null ? activeBrand.name : "nenhuma"), x, y);
  y += constrain(height * 0.022, 15, 20);
  text("Textura: " + (estampaFoto != null ? estampaFoto.width + "x" + estampaFoto.height : "opcional"), x, y);
  y += 32;

  y = desenharSecaoLabel("Previa", x, y, labelSize);
  float gap = 6;
  float smallH = constrain(height * 0.035, 23, 29);
  float bw = (w - gap) * 0.5;
  for (int i = 0; i < estampaPreviewButtons.length; i++) {
    int col = i % 2;
    int row = i / 2;
    estampaPreviewButtons[i][0] = x + col * (bw + gap);
    estampaPreviewButtons[i][1] = y + row * (smallH + gap);
    estampaPreviewButtons[i][2] = bw;
    estampaPreviewButtons[i][3] = smallH;
    desenharBotaoAcaoEstado(estampaPreviewButtons[i], estampaPreviewLabels[i], estampaPreviewAtivo == i);
  }
  y += (smallH + gap) * 2 + 14;

  y = desenharSecaoLabel("Aplicacao", x, y, labelSize);
  estampaRandomButton[0] = x;
  estampaRandomButton[1] = y;
  estampaRandomButton[2] = w;
  estampaRandomButton[3] = buttonH;
  desenharBotaoAcao(estampaRandomButton, "Gerar estampa");
  y += buttonH + 8;

  float exportGap = 6;
  float exportW = (w - exportGap) * 0.5;
  estampaExportPngButton[0] = x;
  estampaExportPngButton[1] = y;
  estampaExportPngButton[2] = exportW;
  estampaExportPngButton[3] = buttonH;
  desenharBotaoAcao(estampaExportPngButton, "PNG");

  estampaExportJpgButton[0] = x + exportW + exportGap;
  estampaExportJpgButton[1] = y;
  estampaExportJpgButton[2] = exportW;
  estampaExportJpgButton[3] = buttonH;
  desenharBotaoAcao(estampaExportJpgButton, "JPG");
  y += buttonH + 8;

  estampaExportMp4Button[0] = x;
  estampaExportMp4Button[1] = y;
  estampaExportMp4Button[2] = w;
  estampaExportMp4Button[3] = buttonH;
  desenharBotaoAcao(estampaExportMp4Button, videoRecording ? "Parar MP4" : (videoEncoding ? "Gerando MP4..." : "Exportar MP4"));
  return y + buttonH + 18;
}

float desenharPainelExportEsquerdo(float x, float y, float w, float buttonH, float labelSize, float titleSize) {
  y = desenharTituloPainel("5 Saida", x, y, titleSize);
  y = desenharSecaoLabel("Exportar", x, y, labelSize);
  for (int i = 0; i < exportPageButtons.length; i++) {
    exportPageButtons[i][0] = x;
    exportPageButtons[i][1] = y;
    exportPageButtons[i][2] = w;
    exportPageButtons[i][3] = buttonH;
    String label = exportPageLabels[i];
    if (i == 3 && videoRecording) label = "Parar MP4";
    if (i == 3 && videoEncoding) label = "Gerando MP4...";
    desenharBotaoAcao(exportPageButtons[i], label);
    y += buttonH + 8;
  }
  if (videoRecording) {
    fill(150);
    textAlign(LEFT, TOP);
    textSize(constrain(height * 0.014, 10, 12));
    text(recordedFrames + " / " + exportFrames + " quadros", x, y);
    y += 22;
  }
  return y + 12;
}

void desenharMenuPadroes() {
  painelPadraoOffsetX = lerp(painelPadraoOffsetX, mostrarBarraPadroes ? 0 : painelPadraoWidth, 0.20);

  float panelX = width - painelPadraoWidth + painelPadraoOffsetX;
  float pad = menuPadding;
  float innerX = panelX + pad;
  float trackWidth = max(96, painelPadraoWidth - (pad * 2));
  float escalaUi = constrain(min(width, height) / 720.0, 0.70, 1.0);
  float y = uiHeaderHeight + 12 * escalaUi - painelPadraoScrollY;
  float buttonH = constrain(height * 0.039, 25, 34);
  float labelSize = constrain(min(width, height) * 0.014, 8.8, 11.5);
  float titleSize = constrain(min(width, height) * 0.021, 13, 17.5);

  desenharPainelBase(panelX, painelPadraoWidth, false);
  clip(panelX, 0, painelPadraoWidth, height);

  if (appPage == 0) {
    y = desenharPainelDesignDireito(innerX, y, trackWidth, buttonH, labelSize, titleSize);
  } else if (appPage == 2) {
    y = desenharSecaoPanfleto(innerX, y, trackWidth, buttonH, labelSize);
  } else if (appPage == 3) {
    y = desenharPainelEstampaDireito(innerX, y, trackWidth, buttonH, labelSize, titleSize);
  } else {
    y = desenharPainelExportDireito(innerX, y, trackWidth, buttonH, labelSize, titleSize);
  }

  noClip();
  float contentHeightNew = y + painelPadraoScrollY + 20;
  painelPadraoMaxScrollY = max(0, contentHeightNew - height);
  painelPadraoScrollY = constrain(painelPadraoScrollY, 0, painelPadraoMaxScrollY);
  desenharScrollPadrao(panelX, painelPadraoMaxScrollY);
  if (appPage >= 0) return;

  noStroke();
  fill(26, 26, 26, 248);
  rect(panelX, 0, painelPadraoWidth, height);
  stroke(51);
  line(panelX, 0, panelX, height);
  noStroke();
  clip(panelX, 0, painelPadraoWidth, height);

  fill(224);
  textAlign(LEFT, TOP);
  textSize(constrain(height * 0.022, 15, 19));
  text("Panfleto", innerX, y);
  y += 34;

  modoPadraoButton[0] = innerX;
  modoPadraoButton[1] = y;
  modoPadraoButton[2] = trackWidth;
  modoPadraoButton[3] = buttonH;
  desenharBotaoAcaoEstado(modoPadraoButton, modoPadraoEstampa ? "Estampa: ON" : "Estampa: OFF", modoPadraoEstampa);
  y += buttonH + 12;

  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN));
  textAlign(LEFT, TOP);
  textSize(labelSize);
  text("Linguagem do padrao", innerX, y);
  y += 18;

  float gap = 8;
  float smallH = constrain(height * 0.040, 26, 34);
  float bw = (trackWidth - gap) * 0.5;

  for (int i = 0; i < padraoFormaButtons.length; i++) {
    int col = i % 2;
    int row = i / 2;
    padraoFormaButtons[i][0] = innerX + col * (bw + gap);
    padraoFormaButtons[i][1] = y + row * (smallH + gap);
    padraoFormaButtons[i][2] = (i == padraoFormaButtons.length - 1 && padraoFormaButtons.length % 2 == 1) ? trackWidth : bw;
    padraoFormaButtons[i][3] = smallH;
    desenharBotaoAcaoEstado(padraoFormaButtons[i], padraoFormaLabels[i], formaPadraoAtiva == i);
  }

  y += (smallH + gap) * ceil(padraoFormaButtons.length / 2.0f) + 6;
  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN));
  textAlign(LEFT, TOP);
  textSize(labelSize);
  text("Ajustes do sistema", innerX, y);
  y += 24;

  for (int i = 0; i < padraoSliderVisivel.length; i++) padraoSliderVisivel[i] = true;
  padraoSliders[0][0] = innerX;
  padraoSliders[0][1] = y;
  padraoSliders[0][2] = trackWidth;
  padraoSliders[0][3] = 6;
  padraoSliders[0][4] = 36;
  padraoSliders[0][5] = padraoQtdFormas;
  desenharSliderPadrao(0);
  y += constrain(height * 0.050, 30, 38);

  padraoSliders[1][0] = innerX;
  padraoSliders[1][1] = y;
  padraoSliders[1][2] = trackWidth;
  padraoSliders[1][3] = 32;
  padraoSliders[1][4] = 260;
  padraoSliders[1][5] = padraoEspacoX;
  desenharSliderPadrao(1);
  y += constrain(height * 0.050, 30, 38);

  padraoSliders[2][0] = innerX;
  padraoSliders[2][1] = y;
  padraoSliders[2][2] = trackWidth;
  padraoSliders[2][3] = 32;
  padraoSliders[2][4] = 260;
  padraoSliders[2][5] = padraoEspacoY;
  desenharSliderPadrao(2);
  y += constrain(height * 0.050, 30, 38);

  padraoSliders[3][0] = innerX;
  padraoSliders[3][1] = y;
  padraoSliders[3][2] = trackWidth;
  padraoSliders[3][3] = 0.12;
  padraoSliders[3][4] = 1.20;
  padraoSliders[3][5] = padraoEscala;
  desenharSliderPadrao(3);
  y += constrain(height * 0.050, 30, 38);

  padraoSliders[4][0] = innerX;
  padraoSliders[4][1] = y;
  padraoSliders[4][2] = trackWidth;
  padraoSliders[4][3] = -300;
  padraoSliders[4][4] = 300;
  padraoSliders[4][5] = padraoRefX;
  desenharSliderPadrao(4);
  y += constrain(height * 0.050, 30, 38);

  padraoSliders[5][0] = innerX;
  padraoSliders[5][1] = y;
  padraoSliders[5][2] = trackWidth;
  padraoSliders[5][3] = -260;
  padraoSliders[5][4] = 260;
  padraoSliders[5][5] = padraoRefY;
  desenharSliderPadrao(5);
  y += constrain(height * 0.050, 30, 38);

  padraoSliders[6][0] = innerX;
  padraoSliders[6][1] = y;
  padraoSliders[6][2] = trackWidth;
  padraoSliders[6][3] = -180;
  padraoSliders[6][4] = 180;
  padraoSliders[6][5] = padraoDiagonal;
  desenharSliderPadrao(6);

  y += constrain(height * 0.050, 30, 38) + 10;
  y = desenharSecaoPanfleto(innerX, y, trackWidth, buttonH, labelSize);

  noClip();
  float legacyPatternContentHeight = y + painelPadraoScrollY + 20;
  painelPadraoMaxScrollY = max(0, legacyPatternContentHeight - height);
  painelPadraoScrollY = constrain(painelPadraoScrollY, 0, painelPadraoMaxScrollY);
  desenharScrollPadrao(panelX, painelPadraoMaxScrollY);
}

void desenharSliderPadrao(int idx) {
  float sx = padraoSliders[idx][0];
  float sy = padraoSliders[idx][1];
  float sw = padraoSliders[idx][2];
  float mn = padraoSliders[idx][3];
  float mx = padraoSliders[idx][4];
  float val = padraoSliders[idx][5];
  desenharSliderUi(sx, sy, sw, mn, mx, val, padraoSliderLabels[idx], (idx == 3) ? 3 : 1);
}

float desenharPainelDesignDireito(float x, float y, float w, float buttonH, float labelSize, float titleSize) {
  y = desenharTituloPainel("Parâmetros", x, y, titleSize);

  if (mutationParams == null) return y;
  float[] values = valoresParametrosMutacao();
  float[] mins = minParametrosMutacao();
  float[] maxs = maxParametrosMutacao();

  for (int i = 0; i < designParamSliders.length; i++) {
    zerarSliderDesign(i);
  }

  y = desenharSecaoLabel("Aparência da marca", x, y, labelSize);
  float[] hsv = hsvAtualMarca();
  float[] hsvMin = { 0, 0, 0, 0 };
  float[] hsvMax = { 360, 100, 100, 100 };
  float stepHsv = constrain(height * 0.050, 30, 38);
  for (int i = 0; i < marcaHsvSliders.length; i++) {
    marcaHsvSliders[i][0] = x;
    marcaHsvSliders[i][1] = y;
    marcaHsvSliders[i][2] = max(40, w - 44);
    marcaHsvSliders[i][3] = hsvMin[i];
    marcaHsvSliders[i][4] = hsvMax[i];
    marcaHsvSliders[i][5] = hsv[i];
    desenharSliderGenerico(marcaHsvSliders[i], marcaHsvLabels[i], i == 0 ? 0 : 1);
    desenharFaixaCorMarca(i, marcaHsvSliders[i], hsv[0], hsv[1], hsv[2]);
    y += stepHsv;
  }
  noStroke();
  fill(mutationParams.primaryColor);
  rect(x + w - 32, y - stepHsv * 4 + 2, 32, stepHsv * 4 - 14, 6);
  y += 8;

  y = desenharControlePaletaMarca(x, y, w, buttonH, labelSize);
  y += 8;

  int[][] grupos = {
    { 1, 5, 4, 13 },
    { 6, 3, 19, 8, 9 },
    { 2, 7, 14 }
  };
  String[] nomes = { "Forma", "Movimento", "Textura" };

  for (int g = 0; g < grupos.length; g++) {
    y = desenharSecaoLabel(nomes[g], x, y, labelSize);
    for (int j = 0; j < grupos[g].length; j++) {
      int i = grupos[g][j];
      designParamSliders[i][0] = x;
      designParamSliders[i][1] = y;
      designParamSliders[i][2] = w;
      designParamSliders[i][3] = mins[i];
      designParamSliders[i][4] = maxs[i];
      designParamSliders[i][5] = values[i];
      int decimals = (i == 6 || i == 8 || i == 9 || i == 13 || i == 14 || i == 16 || i == 18 || i == 19) ? 3 : 2;
      if (i == 17) decimals = 0;
      desenharSliderGenerico(designParamSliders[i], designParamLabels[i], decimals);
      y += constrain(height * 0.050, 30, 38);
    }
    y += 10;
  }

  return y + 16;
}

float desenharControlePaletaMarca(float x, float y, float w, float buttonH, float labelSize) {
  y = desenharSecaoLabel("Paleta controlada", x, y, labelSize);

  marcaPaletaToggleButton[0] = x;
  marcaPaletaToggleButton[1] = y;
  marcaPaletaToggleButton[2] = w;
  marcaPaletaToggleButton[3] = buttonH;
  desenharBotaoAcaoEstado(marcaPaletaToggleButton, marcaPaletaTravada ? "Paleta ligada" : "Paleta desligada", marcaPaletaTravada);
  y += buttonH + 8;

  float gap = 6;
  float targetH = constrain(height * 0.034, 23, 28);
  float countW = (w - gap * 3) / 4.0;
  for (int i = 0; i < marcaPaletaCountButtons.length; i++) {
    marcaPaletaCountButtons[i][0] = x + i * (countW + gap);
    marcaPaletaCountButtons[i][1] = y;
    marcaPaletaCountButtons[i][2] = countW;
    marcaPaletaCountButtons[i][3] = targetH;
    int qtd = i + 3;
    desenharBotaoAcaoEstado(marcaPaletaCountButtons[i], marcaPaletaCountLabels[i] + " cores", marcaPaletaCount == qtd);
  }
  y += targetH + 8;

  marcaPaletaSlotSelecionado = constrain(marcaPaletaSlotSelecionado, 0, max(0, marcaPaletaCount - 1));
  if (!marcaPaletaHexAtivo) {
    marcaPaletaHexValor = hexMarca(marcaPaletaCores[marcaPaletaSlotSelecionado]);
  }

  float hexApplyW = min(76, w * 0.27);
  float pasteW = min(68, w * 0.24);
  marcaPaletaHexField[0] = x;
  marcaPaletaHexField[1] = y;
  marcaPaletaHexField[2] = w - hexApplyW - pasteW - gap * 2;
  marcaPaletaHexField[3] = buttonH;
  desenharCampoHexMarca(marcaPaletaHexField, marcaPaletaHexValor, marcaPaletaHexAtivo);

  marcaPaletaPasteButton[0] = x + marcaPaletaHexField[2] + gap;
  marcaPaletaPasteButton[1] = y;
  marcaPaletaPasteButton[2] = pasteW;
  marcaPaletaPasteButton[3] = buttonH;
  desenharBotaoAcao(marcaPaletaPasteButton, "Colar");

  marcaPaletaHexApplyButton[0] = marcaPaletaPasteButton[0] + pasteW + gap;
  marcaPaletaHexApplyButton[1] = y;
  marcaPaletaHexApplyButton[2] = hexApplyW;
  marcaPaletaHexApplyButton[3] = buttonH;
  desenharBotaoAcao(marcaPaletaHexApplyButton, "Aplicar");
  y += buttonH + 10;

  marcaPaletaAddButton[0] = x;
  marcaPaletaAddButton[1] = y;
  marcaPaletaAddButton[2] = w;
  marcaPaletaAddButton[3] = buttonH;
  desenharBotaoAcao(marcaPaletaAddButton, "+ Salvar cor no slot");
  y += buttonH + 10;

  float swatchGap = 7;
  float swatchW = (w - swatchGap * 2) / 3.0;
  float swatchH = constrain(height * 0.040, 26, 34);
  for (int i = 0; i < marcaPaletaSlotButtons.length; i++) {
    int col = i % 3;
    int row = i / 3;
    float bx = x + col * (swatchW + swatchGap);
    float by = y + row * (swatchH + swatchGap);
    marcaPaletaSlotButtons[i][0] = bx;
    marcaPaletaSlotButtons[i][1] = by;
    marcaPaletaSlotButtons[i][2] = swatchW;
    marcaPaletaSlotButtons[i][3] = swatchH;

    boolean liberado = i < marcaPaletaCount;
    boolean ativo = liberado && marcaPaletaSlotSelecionado == i;
    desenharBotaoAcaoEstado(marcaPaletaSlotButtons[i], liberado ? ("Cor " + (i + 1)) : "Bloq.", ativo);
    noStroke();
    int c = marcaPaletaCores[i];
    fill(red(c), green(c), blue(c), liberado ? alpha(c) : 46);
    rect(bx + 8, by + 7, swatchW - 16, swatchH - 14, 4);
  }
  y += (swatchH + swatchGap) * 2 + 8;

  return y + 8;
}

float desenharControlePaletaFundoPanfleto(float x, float y, float w, float buttonH, float labelSize) {
  y = desenharSecaoLabel("Cor do fundo", x, y, labelSize);

  panfletoFundoPaletaToggleButton[0] = x;
  panfletoFundoPaletaToggleButton[1] = y;
  panfletoFundoPaletaToggleButton[2] = w;
  panfletoFundoPaletaToggleButton[3] = buttonH;
  desenharBotaoAcaoEstado(panfletoFundoPaletaToggleButton, panfletoFundoPaletaTravada ? "Paleta ligada" : "Paleta desligada", panfletoFundoPaletaTravada);
  y += buttonH + 8;

  float gap = 6;
  float targetH = constrain(height * 0.035, 24, 30);
  float countW = (w - gap * 3) / 4.0;
  for (int i = 0; i < panfletoFundoPaletaCountButtons.length; i++) {
    panfletoFundoPaletaCountButtons[i][0] = x + i * (countW + gap);
    panfletoFundoPaletaCountButtons[i][1] = y;
    panfletoFundoPaletaCountButtons[i][2] = countW;
    panfletoFundoPaletaCountButtons[i][3] = targetH;
    int qtd = i + 3;
    desenharBotaoAcaoEstado(panfletoFundoPaletaCountButtons[i], marcaPaletaCountLabels[i] + " cores", panfletoFundoPaletaCount == qtd);
  }
  y += targetH + 8;

  panfletoFundoPaletaSlotSelecionado = constrain(panfletoFundoPaletaSlotSelecionado, 0, max(0, panfletoFundoPaletaCount - 1));
  if (!panfletoFundoPaletaHexAtivo) {
    panfletoFundoPaletaHexValor = hexMarca(panfletoFundoPaletaCores[panfletoFundoPaletaSlotSelecionado]);
  }

  float pasteW = 54;
  float hexApplyW = 64;
  panfletoFundoPaletaHexField[0] = x;
  panfletoFundoPaletaHexField[1] = y;
  panfletoFundoPaletaHexField[2] = w - hexApplyW - pasteW - gap * 2;
  panfletoFundoPaletaHexField[3] = buttonH;
  desenharCampoHexMarca(panfletoFundoPaletaHexField, panfletoFundoPaletaHexValor, panfletoFundoPaletaHexAtivo);

  panfletoFundoPaletaPasteButton[0] = x + panfletoFundoPaletaHexField[2] + gap;
  panfletoFundoPaletaPasteButton[1] = y;
  panfletoFundoPaletaPasteButton[2] = pasteW;
  panfletoFundoPaletaPasteButton[3] = buttonH;
  desenharBotaoAcao(panfletoFundoPaletaPasteButton, "Colar");

  panfletoFundoPaletaHexApplyButton[0] = panfletoFundoPaletaPasteButton[0] + pasteW + gap;
  panfletoFundoPaletaHexApplyButton[1] = y;
  panfletoFundoPaletaHexApplyButton[2] = hexApplyW;
  panfletoFundoPaletaHexApplyButton[3] = buttonH;
  desenharBotaoAcao(panfletoFundoPaletaHexApplyButton, "Aplicar");
  y += buttonH + 8;

  panfletoFundoPaletaAddButton[0] = x;
  panfletoFundoPaletaAddButton[1] = y;
  panfletoFundoPaletaAddButton[2] = w;
  panfletoFundoPaletaAddButton[3] = buttonH;
  desenharBotaoAcao(panfletoFundoPaletaAddButton, "+ Salvar cor no slot");
  y += buttonH + 8;

  float swatchGap = 6;
  float swatchW = (w - swatchGap * 2) / 3.0;
  float swatchH = constrain(height * 0.044, 30, 38);
  for (int i = 0; i < panfletoFundoPaletaSlotButtons.length; i++) {
    int col = i % 3;
    int row = i / 3;
    float bx = x + col * (swatchW + swatchGap);
    float by = y + row * (swatchH + swatchGap);
    panfletoFundoPaletaSlotButtons[i][0] = bx;
    panfletoFundoPaletaSlotButtons[i][1] = by;
    panfletoFundoPaletaSlotButtons[i][2] = swatchW;
    panfletoFundoPaletaSlotButtons[i][3] = swatchH;

    boolean liberado = i < panfletoFundoPaletaCount;
    boolean ativo = liberado && panfletoFundoPaletaSlotSelecionado == i;
    desenharBotaoAcaoEstado(panfletoFundoPaletaSlotButtons[i], liberado ? ("Cor " + (i + 1)) : "Bloq.", ativo);
    int c = panfletoFundoPaletaCores[i];
    noStroke();
    fill(red(c), green(c), blue(c), liberado ? 245 : 62);
    rect(bx + 8, by + swatchH - 11, swatchW - 16, 4, 2);
  }
  y += (swatchH + swatchGap) * 2 + 8;

  return y + 8;
}

void desenharCampoHexMarca(float[] campo, String valor, boolean ativo) {
  float x = campo[0];
  float y = campo[1];
  float w = campo[2];
  float h = campo[3];
  stroke(ativo ? color(86, 170, 248) : color(48, 53, 63));
  fill(ativo ? color(28, 32, 39) : color(18, 20, 25));
  rect(x, y, w, h, 6);
  noStroke();
  fill(ativo ? 238 : 178);
  textAlign(LEFT, CENTER);
  textSize(constrain(height * 0.014, 10, 12));
  String exibido = (valor == null || valor.length() == 0) ? "#RRGGBB" : valor.toUpperCase();
  if (ativo && (frameCount / 28) % 2 == 0) exibido += "|";
  text(exibido, x + 10, y + h * 0.5);
}

void desenharFaixaCorMarca(int tipo, float[] s, float hueBase, float satBase, float briBase) {
  float sx = s[0];
  float sy = s[1] + 6;
  float sw = max(24, s[2] - 64);
  float t = constrain((s[5] - s[3]) / max(0.0001, s[4] - s[3]), 0, 1);
  if (tipo == 0) desenharFaixaMatiz(sx, sy, sw, 5);
  if (tipo == 1) desenharFaixaSaturacao(sx, sy, sw, 5, hueBase, briBase);
  if (tipo == 2) desenharFaixaLuminosidade(sx, sy, sw, 5, hueBase, satBase);
  if (tipo == 3) desenharFaixaAlpha(sx, sy, sw, 5, hueBase, satBase, briBase);
  noStroke();
  fill(245);
  ellipse(sx + sw * t, sy + 2.5, 11, 11);
}

void desenharFaixaMatiz(float x, float y, float w, float h) {
  colorMode(HSB, 360, 100, 100, 100);
  noStroke();
  int passos = max(12, int(w));
  for (int i = 0; i < passos; i++) {
    float hVal = map(i, 0, passos - 1, 0, 360);
    fill(hVal, 90, 95, 100);
    rect(x + i * (w / passos), y, ceil(w / passos) + 1, h);
  }
  colorMode(RGB, 255);
}

void desenharFaixaSaturacao(float x, float y, float w, float h, float hueBase, float briBase) {
  colorMode(HSB, 360, 100, 100, 100);
  noStroke();
  int passos = max(12, int(w));
  for (int i = 0; i < passos; i++) {
    float satVal = map(i, 0, passos - 1, 0, 100);
    fill(hueBase, satVal, briBase, 100);
    rect(x + i * (w / passos), y, ceil(w / passos) + 1, h);
  }
  colorMode(RGB, 255);
}

void desenharFaixaLuminosidade(float x, float y, float w, float h, float hueBase, float satBase) {
  colorMode(HSB, 360, 100, 100, 100);
  noStroke();
  int passos = max(12, int(w));
  for (int i = 0; i < passos; i++) {
    float briVal = map(i, 0, passos - 1, 0, 100);
    fill(hueBase, satBase, briVal, 100);
    rect(x + i * (w / passos), y, ceil(w / passos) + 1, h);
  }
  colorMode(RGB, 255);
}

void desenharFaixaAlpha(float x, float y, float w, float h, float hueBase, float satBase, float briBase) {
  noStroke();
  int blocos = max(8, int(w / 8));
  for (int i = 0; i < blocos; i++) {
    fill(i % 2 == 0 ? 42 : 78);
    rect(x + i * (w / blocos), y, ceil(w / blocos) + 1, h);
  }
  colorMode(HSB, 360, 100, 100, 100);
  int passos = max(12, int(w));
  for (int i = 0; i < passos; i++) {
    float alphaVal = map(i, 0, passos - 1, 0, 100);
    fill(hueBase, satBase, briBase, alphaVal);
    rect(x + i * (w / passos), y, ceil(w / passos) + 1, h);
  }
  colorMode(RGB, 255);
}

void zerarSliderDesign(int idx) {
  if (idx < 0 || idx >= designParamSliders.length) return;
  for (int j = 0; j < designParamSliders[idx].length; j++) {
    designParamSliders[idx][j] = 0;
  }
}

float desenharPainelExportDireito(float x, float y, float w, float buttonH, float labelSize, float titleSize) {
  y = desenharTituloPainel("O que levar", x, y, titleSize);
  y = desenharSecaoLabel("Modulos de saida", x, y, labelSize);
  fill(150);
  textAlign(LEFT, TOP);
  textSize(constrain(height * 0.015, 11, 13));
  text("Panfleto: layout editorial gerado com a identidade.", x, y, w, 54);
  y += 56;
  text("Estampa: superficie/padrao derivado da identidade.", x, y, w, 54);
  y += 56;
  text("Exportar: SVG, PNG, JPG ou MP4 do canvas central.", x, y, w, 54);
  y += 56;
  y = desenharSecaoLabel("Embed / API", x, y, labelSize);
  fill(115);
  text("Modulo previsto para live stream, ainda nao implementado nesta versao.", x, y, w, 90);
  return y + 100;
}

float desenharPainelEstampaDireito(float x, float y, float w, float buttonH, float labelSize, float titleSize) {
  y = desenharTituloPainel("Estampa", x, y, titleSize);
  y = desenharSecaoLabel("Cor da estampa", x, y, labelSize);
  y = desenharControleCorEstampa(x, y, w, buttonH);
  y += 10;

  y = desenharSecaoLabel("Sistema visual", x, y, labelSize);

  for (int i = 0; i < padraoSliderVisivel.length; i++) padraoSliderVisivel[i] = true;
  float step = constrain(height * 0.050, 30, 38);
  float[][] ranges = {
    { 3, 26 },
    { 40, 280 },
    { 36, 240 },
    { 0.10, 1.05 },
    { -360, 360 },
    { -300, 300 },
    { -260, 260 }
  };
  for (int i = 0; i < padraoSliders.length; i++) {
    padraoSliders[i][0] = x;
    padraoSliders[i][1] = y;
    padraoSliders[i][2] = w;
    padraoSliders[i][3] = ranges[i][0];
    padraoSliders[i][4] = ranges[i][1];
    if (i == 0) padraoSliders[i][5] = padraoQtdFormas;
    if (i == 1) padraoSliders[i][5] = padraoEspacoX;
    if (i == 2) padraoSliders[i][5] = padraoEspacoY;
    if (i == 3) padraoSliders[i][5] = padraoEscala;
    if (i == 4) padraoSliders[i][5] = padraoRefX;
    if (i == 5) padraoSliders[i][5] = padraoRefY;
    if (i == 6) padraoSliders[i][5] = padraoDiagonal;
    desenharSliderPadrao(i);
    y += step;
  }

  y += 12;
  y = desenharSecaoLabel("Linguagem generativa", x, y, labelSize);
  float gap = 6;
  float smallH = constrain(height * 0.036, 24, 30);
  float bw = (w - gap) * 0.5;
  for (int i = 0; i < padraoFormaButtons.length; i++) {
    int col = i % 2;
    int row = i / 2;
    padraoFormaButtons[i][0] = x + col * (bw + gap);
    padraoFormaButtons[i][1] = y + row * (smallH + gap);
    padraoFormaButtons[i][2] = (i == padraoFormaButtons.length - 1 && padraoFormaButtons.length % 2 == 1) ? w : bw;
    padraoFormaButtons[i][3] = smallH;
    desenharBotaoAcaoEstado(padraoFormaButtons[i], estampaModoLabels[i], formaPadraoAtiva == i);
  }
  y += (smallH + gap) * ceil(padraoFormaButtons.length / 2.0f) + 14;
  return y;
}

float desenharControleCorEstampa(float x, float y, float w, float buttonH) {
  estampaCoresMarcaButton[0] = x;
  estampaCoresMarcaButton[1] = y;
  estampaCoresMarcaButton[2] = w;
  estampaCoresMarcaButton[3] = buttonH;
  desenharBotaoAcaoEstado(estampaCoresMarcaButton, estampaUsarCoresMarca ? "Cores da marca" : "Cores manuais", estampaUsarCoresMarca);
  y += buttonH + 8;

  float gap = 6;
  float btnH = constrain(height * 0.035, 23, 29);
  float btnW = (w - gap * 2) / 3.0;
  for (int i = 0; i < estampaColorButtons.length; i++) {
    estampaColorButtons[i][0] = x + i * (btnW + gap);
    estampaColorButtons[i][1] = y;
    estampaColorButtons[i][2] = btnW;
    estampaColorButtons[i][3] = btnH;
    desenharBotaoAcaoEstado(estampaColorButtons[i], estampaColorLabels[i], estampaColorTarget == i);
    int c = corAtualEstampa(i);
    noStroke();
    fill(red(c), green(c), blue(c), alpha(c));
    rect(estampaColorButtons[i][0] + 7, y + 7, 12, btnH - 14, 3);
  }
  y += btnH + 26;

  float[] hsv = hsvAtualEstampa();
  float[] hsvMin = { 0, 0, 0, 0 };
  float[] hsvMax = { 360, 100, 100, 100 };
  float step = constrain(height * 0.050, 30, 38);
  for (int i = 0; i < estampaHsvSliders.length; i++) {
    estampaHsvSliders[i][0] = x;
    estampaHsvSliders[i][1] = y;
    estampaHsvSliders[i][2] = max(40, w - 44);
    estampaHsvSliders[i][3] = hsvMin[i];
    estampaHsvSliders[i][4] = hsvMax[i];
    estampaHsvSliders[i][5] = hsv[i];
    desenharSliderGenerico(estampaHsvSliders[i], estampaHsvLabels[i], i == 0 ? 0 : 1);
    desenharFaixaCorEstampa(i, estampaHsvSliders[i], hsv[0], hsv[1]);
    y += step;
  }
  int c = corAtualEstampa(estampaColorTarget);
  noStroke();
  fill(red(c), green(c), blue(c), alpha(c));
  rect(x + w - 32, y - step * 4 + 2, 32, step * 4 - 14, 6);
  return y + 8;
}

void desenharFaixaCorEstampa(int tipo, float[] s, float hueBase, float satBase) {
  float sx = s[0];
  float sy = s[1] + 6;
  float sw = max(24, s[2] - 64);
  float t = constrain((s[5] - s[3]) / max(0.0001, s[4] - s[3]), 0, 1);
  if (tipo == 0) desenharFaixaMatiz(sx, sy, sw, 5);
  if (tipo == 1) desenharFaixaSaturacao(sx, sy, sw, 5, hueBase, 100);
  if (tipo == 2) desenharFaixaLuminosidade(sx, sy, sw, 5, hueBase, satBase);
  if (tipo == 3) desenharFaixaAlpha(sx, sy, sw, 5, hueBase, satBase, estampaHsvSliders[2][5]);
  noStroke();
  fill(245);
  ellipse(sx + sw * t, sy + 2.5, 11, 11);
}

void desenharSliderUi(float sx, float sy, float sw, float mn, float mx, float val, String label, int decimals) {
  float t = constrain((val - mn) / max(0.0001, mx - mn), 0, 1);
  float valueW = 54;
  float trackY = sy + 8;
  float trackW = max(24, sw - valueW - 10);
  boolean hover = mouseX >= sx && mouseX <= sx + trackW && mouseY >= trackY - 8 && mouseY <= trackY + 12;

  fill(red(UI_MUTED), green(UI_MUTED), blue(UI_MUTED));
  textAlign(LEFT, TOP);
  float sliderLabelSize = tamanhoTextoParaCaber(label, constrain(height * 0.0118, 8.5, 10.5), 7, trackW);
  textSize(sliderLabelSize);
  text(textoComReticencias(label, trackW, sliderLabelSize), sx, sy - 15);

  fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT), 220);
  textAlign(RIGHT, TOP);
  textSize(constrain(height * 0.0118, 8.5, 10.5));
  text(nf(val, 1, decimals), sx + sw, sy - 15);

  noStroke();
  fill(red(UI_DARK), green(UI_DARK), blue(UI_DARK));
  rect(sx, trackY, trackW, 6, 3);
  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN), hover ? 245 : 210);
  rect(sx, trackY, trackW * t, 6, 3);
  fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT));
  ellipse(sx + trackW * t, trackY + 3, hover ? 12 : 10, hover ? 12 : 10);
}

void desenharSliderGenerico(float[] s, String label, int decimals) {
  float sx = s[0];
  float sy = s[1];
  float sw = s[2];
  float mn = s[3];
  float mx = s[4];
  float val = s[5];
  desenharSliderUi(sx, sy, sw, mn, mx, val, label, decimals);
}

void desenharColorPicker() {
  if (!colorPickerAberto) return;

  float boxW = min(360, width * 0.42);
  float boxH = min(390, height * 0.64);
  float boxX = width * 0.5 - boxW * 0.5;
  float boxY = height * 0.5 - boxH * 0.5;

  noStroke();
  fill(0, 178);
  rect(0, 0, width, height);
  fill(24, 24, 26, 252);
  rect(boxX, boxY, boxW, boxH, 8);
  stroke(78);
  noFill();
  rect(boxX, boxY, boxW, boxH, 8);

  fill(238);
  textAlign(LEFT, TOP);
  textSize(15);
  text("Janela de cores - " + estampaColorLabels[colorPickerTarget], boxX + 18, boxY + 16);

  colorPickerArea[0] = boxX + 18;
  colorPickerArea[1] = boxY + 52;
  colorPickerArea[2] = boxW - 36;
  colorPickerArea[3] = boxH - 150;

  int cols = 30;
  int rows = 22;
  float cw = colorPickerArea[2] / cols;
  float ch = colorPickerArea[3] / rows;
  noStroke();
  for (int gy = 0; gy < rows; gy++) {
    for (int gx = 0; gx < cols; gx++) {
      float s = gx / float(max(1, cols - 1));
      float b = 1.0 - gy / float(max(1, rows - 1));
      int c = java.awt.Color.HSBtoRGB(colorPickerHue, s, b);
      fill((c >> 16) & 0xFF, (c >> 8) & 0xFF, c & 0xFF);
      rect(colorPickerArea[0] + gx * cw, colorPickerArea[1] + gy * ch, cw + 0.5, ch + 0.5);
    }
  }
  stroke(255);
  strokeWeight(1.5);
  float pickX = colorPickerArea[0] + colorPickerSat * colorPickerArea[2];
  float pickY = colorPickerArea[1] + (1.0 - colorPickerBri) * colorPickerArea[3];
  noFill();
  ellipse(pickX, pickY, 12, 12);

  colorPickerHueArea[0] = boxX + 18;
  colorPickerHueArea[1] = colorPickerArea[1] + colorPickerArea[3] + 18;
  colorPickerHueArea[2] = boxW - 36;
  colorPickerHueArea[3] = 18;
  noStroke();
  for (int i = 0; i < 80; i++) {
    float h = i / 79.0;
    int c = java.awt.Color.HSBtoRGB(h, 1, 1);
    fill((c >> 16) & 0xFF, (c >> 8) & 0xFF, c & 0xFF);
    rect(colorPickerHueArea[0] + i * colorPickerHueArea[2] / 80.0, colorPickerHueArea[1], colorPickerHueArea[2] / 80.0 + 1, colorPickerHueArea[3]);
  }
  fill(255);
  rect(colorPickerHueArea[0] + colorPickerHue * colorPickerHueArea[2] - 1, colorPickerHueArea[1] - 3, 2, colorPickerHueArea[3] + 6);

  int preview = java.awt.Color.HSBtoRGB(colorPickerHue, colorPickerSat, colorPickerBri);
  fill((preview >> 16) & 0xFF, (preview >> 8) & 0xFF, preview & 0xFF);
  rect(boxX + 18, boxY + boxH - 56, 54, 34, 5);

  colorPickerCancelButton[0] = boxX + boxW - 178;
  colorPickerCancelButton[1] = boxY + boxH - 56;
  colorPickerCancelButton[2] = 76;
  colorPickerCancelButton[3] = 34;
  colorPickerOkButton[0] = boxX + boxW - 94;
  colorPickerOkButton[1] = boxY + boxH - 56;
  colorPickerOkButton[2] = 76;
  colorPickerOkButton[3] = 34;
  desenharBotaoAcao(colorPickerCancelButton, "Cancelar");
  desenharBotaoAcao(colorPickerOkButton, "Aplicar");
}

float desenharSecaoPanfleto(float innerX, float y, float trackWidth, float buttonH, float labelSize) {
  float sectionGap = 22;
  float rowGap = 11;
  float sliderStep = constrain(height * 0.056, 36, 46);
  for (int i = 0; i < designParamSliders.length; i++) zerarSliderDesign(i);
  for (int i = 0; i < panfletoEstampaSliders.length; i++) zerarSliderPanfletoEstampa(i);

  y = desenharSecaoLabel("Layout", innerX, y, labelSize);

  float gap = 6;
  float layoutW = (trackWidth - gap) * 0.5;
  float layoutH = constrain(height * 0.036, 24, 30);
  for (int i = 0; i < panfletoLayoutButtons.length; i++) {
    int col = i % 2;
    int row = i / 2;
    panfletoLayoutButtons[i][0] = innerX + col * (layoutW + gap);
    panfletoLayoutButtons[i][1] = y + row * (layoutH + gap);
    panfletoLayoutButtons[i][2] = layoutW;
    panfletoLayoutButtons[i][3] = layoutH;
    desenharBotaoAcaoEstado(panfletoLayoutButtons[i], panfletoLayoutLabels[i], panfletoLayoutAtivo == i);
  }
  y += layoutH * ceil(panfletoLayoutButtons.length / 2.0f) + gap * max(0, ceil(panfletoLayoutButtons.length / 2.0f) - 1) + sectionGap;

  y = desenharSecaoLabel("Objetos do layout", innerX, y, labelSize);
  float formaW = (trackWidth - gap) * 0.5;
  for (int i = 0; i < panfletoObjetoFormaButtons.length; i++) {
    int col = i % 2;
    int row = i / 2;
    panfletoObjetoFormaButtons[i][0] = innerX + col * (formaW + gap);
    panfletoObjetoFormaButtons[i][1] = y + row * (layoutH + gap);
    panfletoObjetoFormaButtons[i][2] = (i == panfletoObjetoFormaButtons.length - 1) ? trackWidth : formaW;
    panfletoObjetoFormaButtons[i][3] = layoutH;
    desenharBotaoAcaoEstado(panfletoObjetoFormaButtons[i], panfletoObjetoFormaLabels[i], panfletoObjetoForma == i);
  }
  y += layoutH * ceil(panfletoObjetoFormaButtons.length / 2.0f) + gap * max(0, ceil(panfletoObjetoFormaButtons.length / 2.0f) - 1) + rowGap;

  float qtdGap = 5;
  float qtdW = (trackWidth - qtdGap * 5) / 6.0;
  for (int i = 0; i < panfletoObjetoQuantidadeButtons.length; i++) {
    panfletoObjetoQuantidadeButtons[i][0] = innerX + i * (qtdW + qtdGap);
    panfletoObjetoQuantidadeButtons[i][1] = y;
    panfletoObjetoQuantidadeButtons[i][2] = qtdW;
    panfletoObjetoQuantidadeButtons[i][3] = layoutH;
    desenharBotaoAcaoEstado(panfletoObjetoQuantidadeButtons[i], str(i + 1), panfletoObjetoQuantidade == i + 1);
  }
  y += layoutH + sectionGap;

  y = desenharSecaoLabel("Formato", innerX, y, labelSize);

  float formatoW = (trackWidth - gap) * 0.5;
  float formatoH = constrain(height * 0.036, 24, 30);
  for (int i = 0; i < panfletoFormatoButtons.length; i++) {
    int col = i % 2;
    int row = i / 2;
    panfletoFormatoButtons[i][0] = innerX + col * (formatoW + gap);
    panfletoFormatoButtons[i][1] = y + row * (formatoH + gap);
    panfletoFormatoButtons[i][2] = formatoW;
    panfletoFormatoButtons[i][3] = formatoH;
    desenharBotaoAcaoEstado(panfletoFormatoButtons[i], panfletoFormatoLabels[i], panfletoFormatoAtivo == i);
  }
  y += formatoH * ceil(panfletoFormatoButtons.length / 2.0f) + gap * max(0, ceil(panfletoFormatoButtons.length / 2.0f) - 1) + sectionGap;

  y = desenharControlePaletaFundoPanfleto(innerX, y, trackWidth, buttonH, labelSize);
  y += sectionGap - 4;

  y = desenharSecaoLabel("Imagem de fundo", innerX, y, labelSize);

  panfletoFotoAddButton[0] = innerX;
  panfletoFotoAddButton[1] = y;
  panfletoFotoAddButton[2] = trackWidth;
  panfletoFotoAddButton[3] = formatoH;
  desenharBotaoAcao(panfletoFotoAddButton, "Adicionar foto/fundo");
  y += formatoH + rowGap;

  panfletoMidiaAddButton[0] = innerX;
  panfletoMidiaAddButton[1] = y;
  panfletoMidiaAddButton[2] = trackWidth;
  panfletoMidiaAddButton[3] = formatoH;
  desenharBotaoAcao(panfletoMidiaAddButton, "Adicionar GIF/video");
  y += formatoH + rowGap;

  panfletoFotoLimparButton[0] = innerX;
  panfletoFotoLimparButton[1] = y;
  panfletoFotoLimparButton[2] = trackWidth;
  panfletoFotoLimparButton[3] = formatoH;
  desenharBotaoAcao(panfletoFotoLimparButton, "Remover fundo");
  y += formatoH + rowGap;

  fill(102);
  textAlign(LEFT, TOP);
  textSize(constrain(height * 0.0135, 10, 12));
  String fotoInfo = (panfletoMidiaFrames != null && panfletoMidiaFrames.length > 0) ?
    "Midia: " + panfletoMidiaTipo + " / " + panfletoMidiaFrames.length + " frames" :
    ((fotoEditorialPanfleto() != null) ? "Foto: " + fotoEditorialPanfleto().width + "x" + fotoEditorialPanfleto().height : "Foto: nenhuma");
  text(fotoInfo, innerX, y);
  y += sectionGap + 8;

  y = desenharSecaoLabel("Marca", innerX, y, labelSize);

  for (int i = 0; i < panfletoMarcaSliders.length; i++) {
    panfletoMarcaSliders[i][0] = innerX;
    panfletoMarcaSliders[i][1] = y;
    panfletoMarcaSliders[i][2] = trackWidth;
    if (i == 0) {
      panfletoMarcaSliders[i][3] = -380;
      panfletoMarcaSliders[i][4] = 380;
      panfletoMarcaSliders[i][5] = panfletoMarcaX;
    } else if (i == 1) {
      panfletoMarcaSliders[i][3] = -380;
      panfletoMarcaSliders[i][4] = 380;
      panfletoMarcaSliders[i][5] = panfletoMarcaY;
    } else {
      panfletoMarcaSliders[i][3] = 0.25;
      panfletoMarcaSliders[i][4] = 9.0;
      panfletoMarcaSliders[i][5] = panfletoMarcaEscala;
    }
    desenharSliderPanfletoMarca(i);
    y += sliderStep;
  }

  if (mutationParams != null) {
    float[] marcaBasicos = {
      mutationParams.deformationAmount,
      mutationParams.strokeAmount,
      mutationParams.opacityAmount
    };
    float[][] marcaRanges = {
      { 0, 140 },
      { 0.4, 12 },
      { 0.05, 1.0 }
    };
    String[] marcaLabels = { "Deformacao", "Peso visual", "Opacidade" };
    int[] paramIdx = { 1, 4, 16 };
    for (int j = 0; j < marcaBasicos.length; j++) {
      int idx = paramIdx[j];
      designParamSliders[idx][0] = innerX;
      designParamSliders[idx][1] = y;
      designParamSliders[idx][2] = trackWidth;
      designParamSliders[idx][3] = marcaRanges[j][0];
      designParamSliders[idx][4] = marcaRanges[j][1];
      designParamSliders[idx][5] = marcaBasicos[j];
      desenharSliderGenerico(designParamSliders[idx], marcaLabels[j], j == 1 || j == 2 ? 2 : 1);
      y += sliderStep;
    }
  }

  panfletoLogoExtraToggleButton[0] = innerX;
  panfletoLogoExtraToggleButton[1] = y;
  panfletoLogoExtraToggleButton[2] = trackWidth;
  panfletoLogoExtraToggleButton[3] = formatoH;
  desenharBotaoAcaoEstado(panfletoLogoExtraToggleButton, panfletoLogoExtraAtiva ? "Segunda logo reativa ligada" : "+ Segunda logo reativa", panfletoLogoExtraAtiva);
  y += formatoH + rowGap;

  if (panfletoLogoExtraAtiva) {
    for (int i = 0; i < panfletoLogoExtraSliders.length; i++) {
      panfletoLogoExtraSliders[i][0] = innerX;
      panfletoLogoExtraSliders[i][1] = y;
      panfletoLogoExtraSliders[i][2] = trackWidth;
      if (i == 0) {
        panfletoLogoExtraSliders[i][3] = -900;
        panfletoLogoExtraSliders[i][4] = 900;
        panfletoLogoExtraSliders[i][5] = panfletoLogoExtraX;
      } else if (i == 1) {
        panfletoLogoExtraSliders[i][3] = -900;
        panfletoLogoExtraSliders[i][4] = 900;
        panfletoLogoExtraSliders[i][5] = panfletoLogoExtraY;
      } else {
        panfletoLogoExtraSliders[i][3] = 0.12;
        panfletoLogoExtraSliders[i][4] = 4.0;
        panfletoLogoExtraSliders[i][5] = panfletoLogoExtraEscala;
      }
      desenharSliderPanfletoLogoExtra(i);
      y += sliderStep;
    }
  }

  y += sectionGap - 2;
  y = desenharSecaoLabel("Textos", innerX, y, labelSize);

  panfletoTextoToggleButton[0] = innerX;
  panfletoTextoToggleButton[1] = y;
  panfletoTextoToggleButton[2] = trackWidth;
  panfletoTextoToggleButton[3] = formatoH;
  desenharBotaoAcaoEstado(panfletoTextoToggleButton, panfletoMostrarTextos ? "Textos ligados" : "Textos desligados", panfletoMostrarTextos);
  y += formatoH + rowGap;

  panfletoAgruparTextosButton[0] = innerX;
  panfletoAgruparTextosButton[1] = y;
  panfletoAgruparTextosButton[2] = trackWidth;
  panfletoAgruparTextosButton[3] = formatoH;
  desenharBotaoAcaoEstado(panfletoAgruparTextosButton, panfletoTextosAgrupados ? "Grupo de textos ligado" : "Grupo de textos desligado", panfletoTextosAgrupados);
  y += formatoH + rowGap;

  panfletoTextoAddButton[0] = innerX;
  panfletoTextoAddButton[1] = y;
  panfletoTextoAddButton[2] = trackWidth;
  panfletoTextoAddButton[3] = formatoH;
  desenharBotaoAcaoEstado(panfletoTextoAddButton, panfletoTextoExtraCount < 4 ? "+ Adicionar caixa de texto" : "Limite de textos extras", panfletoTextoExtraCount > 0);
  y += formatoH + rowGap;

  y = desenharSecaoLabel("Cor do texto", innerX, y, labelSize);
  float corGap = 5;
  float corBtnW = (trackWidth - corGap) * 0.5;
  float corBtnH = formatoH;
  for (int i = 0; i < panfletoTextoCorButtons.length; i++) {
    int col = i % 2;
    int row = i / 2;
    panfletoTextoCorButtons[i][0] = innerX + col * (corBtnW + corGap);
    panfletoTextoCorButtons[i][1] = y + row * (corBtnH + corGap);
    panfletoTextoCorButtons[i][2] = corBtnW;
    panfletoTextoCorButtons[i][3] = corBtnH;
    desenharBotaoAcaoEstado(panfletoTextoCorButtons[i], panfletoTextoCorLabels[i], panfletoTextoCorModo == i);
  }
  y += corBtnH * ceil(panfletoTextoCorButtons.length / 2.0f) + corGap * max(0, ceil(panfletoTextoCorButtons.length / 2.0f) - 1) + rowGap;

  float campoH = constrain(height * 0.044, 30, 38);
  for (int i = 0; i < 6; i++) {
    panfletoTextoCampos[i][0] = innerX;
    panfletoTextoCampos[i][1] = y;
    panfletoTextoCampos[i][2] = trackWidth;
    panfletoTextoCampos[i][3] = campoH;
    desenharCampoTextoPanfleto(i);
    y += campoH + sectionGap;
  }
  for (int e = 0; e < panfletoTextoExtraCount; e++) {
    int textoIdx = 6 + e;
    int sizeIdx = 10 + e;
    panfletoTextoCampos[textoIdx][0] = innerX;
    panfletoTextoCampos[textoIdx][1] = y;
    panfletoTextoCampos[textoIdx][2] = trackWidth;
    panfletoTextoCampos[textoIdx][3] = campoH;
    desenharCampoTextoPanfleto(textoIdx);
    y += campoH + rowGap;

    panfletoTextoCampos[sizeIdx][0] = innerX;
    panfletoTextoCampos[sizeIdx][1] = y;
    panfletoTextoCampos[sizeIdx][2] = trackWidth;
    panfletoTextoCampos[sizeIdx][3] = campoH;
    desenharCampoTextoPanfleto(sizeIdx);
    y += campoH + sectionGap;
  }

  y += sectionGap - 6;
  y = desenharSecaoLabel(panfletoTextosAgrupados ? "Mover grupo de textos" : "Mover textos individualmente", innerX, y, labelSize);

  if (panfletoTextosAgrupados) {
    for (int i = 0; i < 6; i++) zerarSliderPanfletoTexto(i);
    for (int i = 6; i < 8; i++) {
      panfletoTextoSliders[i][0] = innerX;
      panfletoTextoSliders[i][1] = y;
      panfletoTextoSliders[i][2] = trackWidth;
      panfletoTextoSliders[i][3] = -1600;
      panfletoTextoSliders[i][4] = 1600;
      if (i == 6) panfletoTextoSliders[i][5] = panfletoTextoGrupoY;
      if (i == 7) panfletoTextoSliders[i][5] = panfletoTextoGrupoX;
      desenharSliderPanfletoTexto(i);
      y += sliderStep;
    }
  } else {
    for (int i = 6; i < panfletoTextoSliders.length; i++) zerarSliderPanfletoTexto(i);
    for (int i = 0; i < 6; i++) {
      panfletoTextoSliders[i][0] = innerX;
      panfletoTextoSliders[i][1] = y;
      panfletoTextoSliders[i][2] = trackWidth;
      panfletoTextoSliders[i][3] = -1600;
      panfletoTextoSliders[i][4] = 1600;
      if (i == 0) panfletoTextoSliders[i][5] = panfletoTituloY;
      if (i == 1) panfletoTextoSliders[i][5] = panfletoTituloX;
      if (i == 2) panfletoTextoSliders[i][5] = panfletoSubtituloY;
      if (i == 3) panfletoTextoSliders[i][5] = panfletoSubtituloX;
      if (i == 4) panfletoTextoSliders[i][5] = panfletoRodapeY;
      if (i == 5) panfletoTextoSliders[i][5] = panfletoRodapeX;
      desenharSliderPanfletoTexto(i);
      y += sliderStep;
    }
    for (int i = 8; i < 8 + panfletoTextoExtraCount * 2; i++) {
      panfletoTextoSliders[i][0] = innerX;
      panfletoTextoSliders[i][1] = y;
      panfletoTextoSliders[i][2] = trackWidth;
      panfletoTextoSliders[i][3] = -1600;
      panfletoTextoSliders[i][4] = 1600;
      int extraIdx = (i - 8) / 2;
      if ((i - 8) % 2 == 0) panfletoTextoSliders[i][5] = panfletoExtraTextoY[extraIdx];
      else panfletoTextoSliders[i][5] = panfletoExtraTextoX[extraIdx];
      desenharSliderPanfletoTexto(i);
      y += sliderStep;
    }
  }

  for (int i = 0; i < panfletoMascaraSliders.length; i++) zerarSliderPanfletoMascara(i);
  for (int i = 0; i < panfletoEstampaSliders.length; i++) zerarSliderPanfletoEstampa(i);
  return y;
}

void zerarSliderPanfletoTexto(int idx) {
  if (idx < 0 || idx >= panfletoTextoSliders.length) return;
  for (int j = 0; j < panfletoTextoSliders[idx].length; j++) panfletoTextoSliders[idx][j] = 0;
}

void zerarSliderPanfletoMascara(int idx) {
  if (idx < 0 || idx >= panfletoMascaraSliders.length) return;
  for (int j = 0; j < panfletoMascaraSliders[idx].length; j++) panfletoMascaraSliders[idx][j] = 0;
}

void zerarSliderPanfletoEstampa(int idx) {
  if (idx < 0 || idx >= panfletoEstampaSliders.length) return;
  for (int j = 0; j < panfletoEstampaSliders[idx].length; j++) panfletoEstampaSliders[idx][j] = 0;
}

void desenharSliderPanfletoMarca(int idx) {
  float sx = panfletoMarcaSliders[idx][0];
  float sy = panfletoMarcaSliders[idx][1];
  float sw = panfletoMarcaSliders[idx][2];
  float mn = panfletoMarcaSliders[idx][3];
  float mx = panfletoMarcaSliders[idx][4];
  float val = panfletoMarcaSliders[idx][5];
  desenharSliderUi(sx, sy, sw, mn, mx, val, panfletoMarcaSliderLabels[idx], idx == 2 ? 3 : 1);
}

void desenharSliderPanfletoLogoExtra(int idx) {
  float sx = panfletoLogoExtraSliders[idx][0];
  float sy = panfletoLogoExtraSliders[idx][1];
  float sw = panfletoLogoExtraSliders[idx][2];
  float mn = panfletoLogoExtraSliders[idx][3];
  float mx = panfletoLogoExtraSliders[idx][4];
  float val = panfletoLogoExtraSliders[idx][5];
  desenharSliderUi(sx, sy, sw, mn, mx, val, panfletoLogoExtraSliderLabels[idx], idx == 2 ? 3 : 1);
}

void desenharSliderPanfletoEstampa(int idx) {
  float sx = panfletoEstampaSliders[idx][0];
  float sy = panfletoEstampaSliders[idx][1];
  float sw = panfletoEstampaSliders[idx][2];
  float mn = panfletoEstampaSliders[idx][3];
  float mx = panfletoEstampaSliders[idx][4];
  float val = panfletoEstampaSliders[idx][5];
  desenharSliderUi(sx, sy, sw, mn, mx, val, panfletoEstampaSliderLabels[idx], 2);
}

void desenharSliderPanfletoMascara(int idx) {
  float sx = panfletoMascaraSliders[idx][0];
  float sy = panfletoMascaraSliders[idx][1];
  float sw = panfletoMascaraSliders[idx][2];
  float mn = panfletoMascaraSliders[idx][3];
  float mx = panfletoMascaraSliders[idx][4];
  float val = panfletoMascaraSliders[idx][5];
  desenharSliderUi(sx, sy, sw, mn, mx, val, panfletoMascaraSliderLabels[idx], 2);
}

void desenharCampoTextoPanfleto(int idx) {
  float x = panfletoTextoCampos[idx][0];
  float y = panfletoTextoCampos[idx][1];
  float w = panfletoTextoCampos[idx][2];
  float h = panfletoTextoCampos[idx][3];
  boolean ativo = (panfletoCampoAtivo == idx);

  fill(red(UI_MUTED), green(UI_MUTED), blue(UI_MUTED));
  textAlign(LEFT, TOP);
  String rotulo = panfletoTextoRotulos[idx];
  float rotuloSize = tamanhoTextoParaCaber(rotulo, constrain(height * 0.0125, 9, 10.5), 7, w);
  textSize(rotuloSize);
  text(textoComReticencias(rotulo, w, rotuloSize), x, y - 14);

  if (ativo) fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN), 76);
  else fill(red(UI_PANEL_SOFT), green(UI_PANEL_SOFT), blue(UI_PANEL_SOFT), 232);
  stroke(ativo ? UI_GREEN : UI_LINE);
  strokeWeight(1.2);
  rect(x, y, w, h, 7);
  noStroke();

  fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT));
  textAlign(LEFT, CENTER);
  String valor = panfletoTextoValores[idx];
  if (valor == null) valor = "";
  float campoSize = tamanhoTextoParaCaber(valor, constrain(height * 0.013, 9.5, 11), 7, w - 16);
  textSize(campoSize);
  text(textoComReticencias(valor, w - 16, campoSize), x + 8, y + h * 0.5);
}

void desenharSliderPanfletoSimbolo(int idx) {
  float sx = panfletoSimboloSliders[idx][0];
  float sy = panfletoSimboloSliders[idx][1];
  float sw = panfletoSimboloSliders[idx][2];
  float mn = panfletoSimboloSliders[idx][3];
  float mx = panfletoSimboloSliders[idx][4];
  float val = panfletoSimboloSliders[idx][5];
  desenharSliderUi(sx, sy, sw, mn, mx, val, panfletoSimboloSliderLabels[idx], idx == 2 ? 3 : 1);
}

void desenharSliderPanfletoTexto(int idx) {
  float sx = panfletoTextoSliders[idx][0];
  float sy = panfletoTextoSliders[idx][1];
  float sw = panfletoTextoSliders[idx][2];
  float mn = panfletoTextoSliders[idx][3];
  float mx = panfletoTextoSliders[idx][4];
  float val = panfletoTextoSliders[idx][5];
  desenharSliderUi(sx, sy, sw, mn, mx, val, panfletoTextoSliderLabels[idx], 1);
}

void desenharScrollPadrao(float panelX, float maxScroll) {
  if (maxScroll <= 1) return;

  float trackY = uiHeaderHeight + 12;
  float trackH = height - trackY - 12;
  float thumbH = max(36, trackH * (height / (height + maxScroll)));
  float thumbY = trackY + (trackH - thumbH) * (painelPadraoScrollY / maxScroll);

  noStroke();
  fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT), 22);
  rect(panelX + painelPadraoWidth - 7, trackY, 2, trackH, 2);
  fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN), 185);
  rect(panelX + painelPadraoWidth - 9, thumbY, 5, thumbH, 4);
}

void desenharBotaoAcao(float[] buttonData, String label) {
  desenharBotaoAcaoEstado(buttonData, label, false);
}

void desenharBotaoAcaoEstado(float[] buttonData, String label, boolean ativo) {
  if (buttonData[2] <= 0 || buttonData[3] <= 0) return;
  boolean hover = mouseX >= buttonData[0] && mouseX <= buttonData[0] + buttonData[2] &&
    mouseY >= buttonData[1] && mouseY <= buttonData[1] + buttonData[3];
  stroke(ativo ? UI_GREEN : (hover ? UI_BROWN : UI_LINE));
  strokeWeight(1);
  if (ativo) {
    fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN), 122);
  } else if (hover) {
    fill(red(UI_BROWN), green(UI_BROWN), blue(UI_BROWN), 88);
  } else {
    fill(red(UI_PANEL_SOFT), green(UI_PANEL_SOFT), blue(UI_PANEL_SOFT), 232);
  }
  rect(buttonData[0], buttonData[1], buttonData[2], buttonData[3], 6);
  if (ativo) {
    noStroke();
    fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT), 190);
    rect(buttonData[0] + 1, buttonData[1] + 1, 3, buttonData[3] - 2, 5);
  }
  noStroke();
  if (ativo || hover) fill(red(UI_LIGHT), green(UI_LIGHT), blue(UI_LIGHT));
  else fill(red(UI_MUTED), green(UI_MUTED), blue(UI_MUTED));
  textoCentralizadoAjustado(label, buttonData[0] + buttonData[2] * 0.5, buttonData[1] + buttonData[3] * 0.5, max(20, buttonData[2] - 10), constrain(height * 0.0122, 8.0, 10.2), 5.6);
}

void desenharCabecalhoGrupo(int groupIdx) {
  float[] b = sliderGrupoCabecalho[groupIdx];
  boolean hover = mouseX >= b[0] && mouseX <= b[0] + b[2] && mouseY >= b[1] && mouseY <= b[1] + b[3];
  stroke(sliderGrupoAberto[groupIdx] ? UI_GREEN : UI_LINE);
  if (hover) fill(red(UI_BROWN), green(UI_BROWN), blue(UI_BROWN), 75);
  else fill(red(UI_PANEL_SOFT), green(UI_PANEL_SOFT), blue(UI_PANEL_SOFT), 220);
  rect(b[0], b[1], b[2], b[3], 6);
  noStroke();
  fill(sliderGrupoAberto[groupIdx] ? UI_LIGHT : UI_MUTED);
  textAlign(LEFT, CENTER);
  String seta = sliderGrupoAberto[groupIdx] ? "v" : ">";
  float grupoSize = tamanhoTextoParaCaber(seta + " " + sliderGrupoNomes[groupIdx], constrain(height * 0.012, 8.5, 10.5), 7, b[2] - 22);
  textSize(grupoSize);
  text(textoComReticencias(seta + " " + sliderGrupoNomes[groupIdx], b[2] - 22, grupoSize), b[0] + 10, b[1] + b[3] * 0.5);
}

void desenharVisualizadorFrequencias(float x, float y, float w, float h) {
  fill(red(UI_DARK), green(UI_DARK), blue(UI_DARK), 238);
  rect(x, y, w, h, 10);

  if (!audioInputAvailable || fft == null || mic == null) {
    fill(red(UI_MUTED), green(UI_MUTED), blue(UI_MUTED));
    textAlign(CENTER, CENTER);
    textSize(constrain(height * 0.0135, 10, 12));
    text("SEM MICROFONE", x + w * 0.5, y + h * 0.5);
    return;
  }

  int barras = 24;
  float bw = w / barras;
  for (int i = 0; i < barras; i++) {
    float p = (float) i / max(barras - 1, 1);
    int idx = (int) map(p * p, 0, 1, 1, fft.specSize() - 1);
    float amp = sqrt(max(fft.getBand(idx), 0));
    float n = constrain(map(amp, 0, 5, 0, 1), 0, 1);
    float bh = n * (h - 10);

    fill(red(UI_GREEN), green(UI_GREEN), blue(UI_GREEN), 150 + 80 * n);
    rect(x + i * bw + 1, y + h - 6 - bh, max(1, bw - 2), bh, 2);
  }
}

void desenharSlider(int idx) {
  float sx = sliders[idx][0];
  float sy = sliders[idx][1];
  float sw = sliders[idx][2];
  float val = sliders[idx][5];
  float mn = sliders[idx][3];
  float mx = sliders[idx][4];
  desenharSliderUi(sx, sy, sw, mn, mx, val, sliderLabels[idx], 3);
}

float energiaBanda(int fMin, int fMax) {
  if (!audioInputAvailable || fft == null || mic == null) return 0;
  float soma = 0;
  int cont = 0;
  for (int i = 0; i < fft.specSize(); i++) {
    float freq = i * (mic.sampleRate() / 2.0) / fft.specSize();
    if (freq >= fMin && freq <= fMax) {
      soma += fft.getBand(i);
      cont++;
    }
  }
  return (cont > 0) ? soma / cont : 0;
}

void configurarControles() {
  int sy = 0;
  int sw = 0;
  sliders = new float[][] {
    { 0, sy, sw, 0, 0.5, gateB },
    { 0, sy, sw, 0, 0.5, gateM },
    { 0, sy, sw, 0, 0.3, gateT },
    { 0, sy, sw, 1, 6, boostT },
    { 0, sy, sw, 0, 0.5, gateP },
    { 0, sy, sw, 0.1, 3, pB },
    { 0, sy, sw, 0.1, 3, pM },
    { 0, sy, sw, 0.1, 3, pT },
    { 0, sy, sw, 0.1, 3, pP },
    { 0, sy, sw, 1, 12, duracaoHold },
    { 0, sy, sw, 1, 20, velDissolve },
    { 0, sy, sw, 0.004, 0.05, velFolego },
    { 0, sy, sw, 90, 240, espacamentoPalavra },
    { 0, sy, sw, 6, 30, typoSize },
    { 0, sy, sw, -220, 360, typoOffsetY },
    { 0, sy, sw, 0, 26, typoReact },
    { 0, sy, sw, -260, 260, typoWordOffsetExtra },
    { 0, sy, sw, 240, 900, typoBaseWidthSolo },
    { 0, sy, sw, 320, 1200, typoBaseWidthWord },
    { 0, sy, sw, 0, 40, typoTrailAlpha },
    { 0, sy, sw, 40, 100, typoMainAlpha },
    { 0, sy, sw, -260, 260, typoParGap },
    { 0, sy, sw, -180, 180, typoParYOffset },
    { 0, sy, sw, -320, 320, typoParXOffset },
    { 0, sy, sw, -260, 260, typoVar2YOffsetA },
    { 0, sy, sw, -260, 260, typoVar2YOffsetB },
    { 0, sy, sw, 0.7, 4.0, microfoneSensibilidade },
    { 0, sy, sw, 0.2, 3.0, mutationParams.intensity },
    { 0, sy, sw, 0, 140, mutationParams.deformationAmount },
    { 0, sy, sw, 0.05, 2.0, mutationParams.noiseAmount },
    { 0, sy, sw, 0, 140, mutationParams.displacementAmount },
    { 0, sy, sw, 0.4, 12, mutationParams.strokeAmount },
    { 0, sy, sw, 0, 0.55, mutationParams.scaleAmount },
    { 0, sy, sw, -0.35, 0.35, mutationParams.rotationAmount },
    { 0, sy, sw, 0.01, 0.22, mutationParams.returnSpeed },
    { 0, sy, sw, 0.02, 0.32, mutationParams.growthSpeed }
  };

  sliderLabels = new String[] {
    "Gate grave",
    "Gate medio",
    "Gate agudo",
    "Boost agudo",
    "Gate presenca",
    "Peso grave",
    "Peso medio",
    "Peso agudo",
    "Peso presenca",
    "Tempo hold",
    "Velocidade fade",
    "Velocidade pulso",
    "Espaco palavra",
    "Tamanho marca",
    "Offset Y marca",
    "Controle interno",
    "Offset Y palavra",
    "Controle interno",
    "Largura marca palavra",
    "Controle interno",
    "Opacidade marca",
    "Gap par",
    "Offset Y par",
    "Offset X par",
    "Ajuste conexao V2",
    "Y var2 direita",
    "Sensibilidade mic",
    "Intensidade de reacao",
    "Deformacao",
    "Ruido",
    "Deslocamento",
    "Traco",
    "Escala",
    "Rotacao",
    "Velocidade de retorno",
    "Velocidade de crescimento"
  };

  sliderVisivel = new boolean[sliders.length];
}

void desenharBotaoMostrar() {
  colorMode(RGB, 255);
  float tabX = menuOffsetX + menuWidth;
  float tabY = height * 0.5 - 56;
  boolean hover = mouseX >= tabX && mouseX <= tabX + menuTabWidth && mouseY >= tabY && mouseY <= tabY + 112;

  noStroke();
  fill(hover ? 32 : 18, hover ? 35 : 20, hover ? 42 : 25, 245);
  rect(tabX, tabY, menuTabWidth, 112, 0, 10, 10, 0);

  fill(hover ? 118 : 72, hover ? 190 : 166, 250);
  textAlign(CENTER, CENTER);
  textSize(constrain(height * 0.017, 11, 14));
  pushMatrix();
  translate(tabX + menuTabWidth * 0.5, tabY + 56);
  rotate(-HALF_PI);
  text(mostrarBarra ? "OCULTAR" : "ABRIR", 0, 0);
  popMatrix();

  colorMode(HSB, 360, 100, 100, 100);
}

void desenharBotaoMostrarPadroes() {
  colorMode(RGB, 255);
  float tabX = width - painelPadraoWidth + painelPadraoOffsetX - painelPadraoTabWidth;
  float tabY = height * 0.5 - 56;
  boolean hover = mouseX >= tabX && mouseX <= tabX + painelPadraoTabWidth && mouseY >= tabY && mouseY <= tabY + 112;

  noStroke();
  fill(hover ? 32 : 18, hover ? 35 : 20, hover ? 42 : 25, 245);
  rect(tabX, tabY, painelPadraoTabWidth, 112, 10, 0, 0, 10);

  fill(hover ? 118 : 72, hover ? 190 : 166, 250);
  textAlign(CENTER, CENTER);
  textSize(constrain(height * 0.017, 11, 14));
  pushMatrix();
  translate(tabX + painelPadraoTabWidth * 0.5, tabY + 56);
  rotate(HALF_PI);
  text(mostrarBarraPadroes ? "OCULTAR" : "ABRIR", 0, 0);
  popMatrix();

  colorMode(HSB, 360, 100, 100, 100);
}
