void mousePressed() {
  if (colorPickerAberto) {
    if (handleColorPickerMousePressed()) return;
  }

  float tabX = menuOffsetX + menuWidth;
  float tabY = height * 0.5 - 56;
  if (mouseX > tabX && mouseX < tabX + menuTabWidth && mouseY > tabY && mouseY < tabY + 112) {
    mostrarBarra = !mostrarBarra;
    return;
  }

  float tabPadraoX = width - painelPadraoWidth + painelPadraoOffsetX - painelPadraoTabWidth;
  float tabPadraoY = height * 0.5 - 56;
  if (mouseX > tabPadraoX && mouseX < tabPadraoX + painelPadraoTabWidth &&
      mouseY > tabPadraoY && mouseY < tabPadraoY + 112) {
    mostrarBarraPadroes = !mostrarBarraPadroes;
    return;
  }

  for (int i = 0; i < uiTopTabButtons.length; i++) {
    if (dentroDoBotao(uiTopTabButtons[i])) {
      appPage = uiTopTabPages[i];
      modoPanfleto = (appPage == 2);
      modoPadraoEstampa = false;
      exportMenuAberto = false;
      mostrarBarra = true;
      mostrarBarraPadroes = true;
      mostrarStatus(uiTopTabLabels[i]);
      return;
    }
  }

  if (handlePageMousePressed()) return;
  if (appPage >= 0) return;

  if (mostrarBarraPadroes) {
    if (dentroDoBotao(modoPadraoButton)) {
      modoPadraoEstampa = !modoPadraoEstampa;
      mostrarStatus(modoPadraoEstampa ? "Modo estampa ligado" : "Modo estampa desligado");
      return;
    }

    for (int i = 0; i < padraoFormaButtons.length; i++) {
      if (dentroDoBotao(padraoFormaButtons[i])) {
        formaPadraoAtiva = i;
        mostrarStatus("Padrão: " + padraoFormaLabels[i]);
        return;
      }
    }

    for (int i = 0; i < padraoSliders.length; i++) {
      if (!padraoSliderVisivel[i]) continue;
      if (mouseX > padraoSliders[i][0] && mouseX < padraoSliders[i][0] + padraoSliders[i][2] &&
          mouseY > padraoSliders[i][1] - 10 && mouseY < padraoSliders[i][1] + 12) {
        dragPadraoSlider = i;
        atualizarSliderPadrao();
        return;
      }
    }

    if (dentroDoBotao(panfletoModoButton)) {
      modoPanfleto = !modoPanfleto;
      if (modoPanfleto) panfletoCampoAtivo = 0;
      mostrarStatus(modoPanfleto ? "Editor de panfleto ligado" : "Editor de panfleto desligado");
      return;
    }

    for (int i = 0; i < panfletoFormatoButtons.length; i++) {
      if (dentroDoBotao(panfletoFormatoButtons[i])) {
        panfletoFormatoAtivo = i;
        mostrarStatus("Formato: " + panfletoFormatoLabels[i]);
        return;
      }
    }

    for (int i = 0; i < panfletoTemaButtons.length; i++) {
      if (dentroDoBotao(panfletoTemaButtons[i])) {
        if (panfletoTemaAtivo != i) {
          panfletoTemaAtivo = i;
          panfletoTemaPulse = 1.0;
        }
        mostrarStatus("Tema: " + panfletoTemaLabels[i]);
        return;
      }
    }

    if (dentroDoBotao(panfletoFotoAddButton)) {
      selectInput("Selecione a foto do panfleto", "onFotoSelecionadaPanfleto");
      return;
    }

    if (dentroDoBotao(panfletoMidiaAddButton)) {
      selectInput("Selecione GIF ou vídeo do panfleto", "onMidiaSelecionadaPanfleto");
      return;
    }

    if (dentroDoBotao(panfletoFotoLimparButton)) {
      panfletoFoto = null;
      panfletoFotoPath = "";
      limparMidiaPanfleto();
      mostrarStatus("Fundo removido");
      return;
    }

    for (int i = 0; i < panfletoMarcaSliders.length; i++) {
      if (mouseX > panfletoMarcaSliders[i][0] && mouseX < panfletoMarcaSliders[i][0] + panfletoMarcaSliders[i][2] &&
          mouseY > panfletoMarcaSliders[i][1] - 10 && mouseY < panfletoMarcaSliders[i][1] + 12) {
        dragPanfletoMarcaSlider = i;
        return;
      }
    }

    for (int i = 0; i < 3; i++) {
      if (dentroDoBotao(panfletoMarcaAlignButtons[i])) {
        panfletoMarcaAlign = i;
        return;
      }
    }

    if (dentroDoBotao(panfletoSimboloToggleButton)) {
      panfletoMostrarSimbolo = !panfletoMostrarSimbolo;
      mostrarStatus(panfletoMostrarSimbolo ? "Símbolo do panfleto ligado" : "Símbolo do panfleto desligado");
      return;
    }

    if (dentroDoBotao(panfletoSimboloAcimaButton)) {
      panfletoSimboloAcima = !panfletoSimboloAcima;
      mostrarStatus(panfletoSimboloAcima ? "Símbolo acima da marca" : "Símbolo livre");
      return;
    }

    for (int i = 0; i < panfletoSimboloSliders.length; i++) {
      if (mouseX > panfletoSimboloSliders[i][0] && mouseX < panfletoSimboloSliders[i][0] + panfletoSimboloSliders[i][2] &&
          mouseY > panfletoSimboloSliders[i][1] - 10 && mouseY < panfletoSimboloSliders[i][1] + 12) {
        dragPanfletoSimboloSlider = i;
        return;
      }
    }

    if (dentroDoBotao(panfletoTextoToggleButton)) {
      panfletoMostrarTextos = !panfletoMostrarTextos;
      mostrarStatus(panfletoMostrarTextos ? "Textos do panfleto ligados" : "Textos do panfleto desligados");
      return;
    }

    for (int i = 0; i < panfletoTextoCorButtons.length; i++) {
      if (dentroDoBotao(panfletoTextoCorButtons[i])) {
        panfletoTextoCorModo = i;
        mostrarStatus("Cor do texto: " + panfletoTextoCorLabels[i]);
        return;
      }
    }
    if (mouseX > panfletoTextoMatizSlider[0] && mouseX < panfletoTextoMatizSlider[0] + panfletoTextoMatizSlider[2] &&
        mouseY > panfletoTextoMatizSlider[1] - 10 && mouseY < panfletoTextoMatizSlider[1] + 12) {
      dragPanfletoTextoMatizSlider = 0;
      panfletoTextoCorModo = 4;
      panfletoCampoAtivo = -1;
      return;
    }

    for (int i = 0; i < panfletoTextoCampos.length; i++) {
      if (dentroDoBotao(panfletoTextoCampos[i])) {
        panfletoCampoAtivo = i;
        mostrarStatus("Editando: " + panfletoTextoRotulos[i]);
        return;
      }
    }

    for (int i = 0; i < 3; i++) {
      if (dentroDoBotao(panfletoTituloAlignButtons[i])) {
        panfletoTituloAlign = i;
        return;
      }
      if (dentroDoBotao(panfletoSubAlignButtons[i])) {
        panfletoSubtituloAlign = i;
        return;
      }
      if (dentroDoBotao(panfletoRodapeAlignButtons[i])) {
        panfletoRodapeAlign = i;
        return;
      }
    }

    for (int i = 0; i < panfletoTextoSliders.length; i++) {
      if (mouseX > panfletoTextoSliders[i][0] && mouseX < panfletoTextoSliders[i][0] + panfletoTextoSliders[i][2] &&
          mouseY > panfletoTextoSliders[i][1] - 10 && mouseY < panfletoTextoSliders[i][1] + 12) {
        dragPanfletoTextoSlider = i;
        panfletoCampoAtivo = -1;
        return;
      }
    }

    float panelX = width - painelPadraoWidth + painelPadraoOffsetX;
    if (mouseX >= panelX && mouseX <= panelX + painelPadraoWidth && mouseY >= 0 && mouseY <= height) {
      panfletoCampoAtivo = -1;
      return;
    }
  }

  if (!mostrarBarra) return;

  if (dentroDoBotao(exportMainButton)) {
    exportMenuAberto = !exportMenuAberto;
    return;
  }

  if (exportMenuAberto) {
    for (int i = 0; i < exportOptionButtons.length; i++) {
      if (dentroDoBotao(exportOptionButtons[i])) {
        executarAcaoExportacao(i);
        exportMenuAberto = false;
        return;
      }
    }
    exportMenuAberto = false;
  }

  if (dentroDoBotao(loadBrandButton)) {
    selectInput("Selecione uma marca SVG", "onSvgSelecionadoMarca");
    return;
  }

  if (dentroDoBotao(randomDNAButton)) {
    generateNewMutationDNA();
    return;
  }

  if (dentroDoBotao(resetBrandButton)) {
    resetMarcaAtual();
    return;
  }

  if (dentroDoBotao(freezeBrandButton)) {
    if (mutationParams != null) mutationParams.freezeState = !mutationParams.freezeState;
    mostrarStatus(mutationParams != null && mutationParams.freezeState ? "Mutação congelada" : "Mutação liberada");
    return;
  }

  if (dentroDoBotao(exportPngButton)) {
    salvarPNG();
    return;
  }

  if (dentroDoBotao(brandToggleButton)) {
    brandSystemEnabled = !brandSystemEnabled;
    mostrarStatus(brandSystemEnabled ? "Sistema de marca ligado" : "Sistema de marca desligado");
    return;
  }

  for (int i = 0; i < identityPresetButtons.length; i++) {
    if (dentroDoBotao(identityPresetButtons[i])) {
      applyIdentityPreset(i);
      return;
    }
  }

  if (mouseX > pointDensitySlider[0] && mouseX < pointDensitySlider[0] + pointDensitySlider[2] &&
      mouseY > pointDensitySlider[1] - 10 && mouseY < pointDensitySlider[1] + 12) {
    dragPointDensitySlider = 1;
    atualizarSliderDensidadePontos();
    return;
  }

  for (int i = 0; i < meshDetailButtons.length; i++) {
    if (dentroDoBotao(meshDetailButtons[i])) {
      setMeshDetailPreset(i);
      return;
    }
  }

  for (int i = 0; i < mutationModeButtons.length; i++) {
    if (dentroDoBotao(mutationModeButtons[i])) {
      mutationParams.mode = i;
      mostrarStatus("Camada visual: " + mutationModeLabels[i]);
      return;
    }
  }

  for (int i = 0; i < deformationModeButtons.length; i++) {
    if (dentroDoBotao(deformationModeButtons[i])) {
      mutationParams.deformationMode = i;
      mostrarStatus("Deformação: " + deformationModeLabels[i]);
      return;
    }
  }

  for (int i = 0; i < paletteButtons.length; i++) {
    if (dentroDoBotao(paletteButtons[i])) {
      mutationParams.applyPalette(i);
      marcaPaletaCores[0] = mutationParams.primaryColor;
      marcaPaletaCores[1] = mutationParams.secondaryColor;
      marcaPaletaCount = max(marcaPaletaCount, 3);
      marcaPaletaTravada = true;
      modoCorGlobal = 3;
      mostrarStatus("Paleta: " + paletteLabels[i]);
      return;
    }
  }

  if (dentroDoBotao(linhaReativosButton)) {
    modoLinhaReativos = !modoLinhaReativos;
    mostrarStatus(modoLinhaReativos ? "Modo palavra ligado" : "Modo palavra desligado");
    return;
  }

  if (dentroDoBotao(simboloPrincipalButton)) {
    mostrarSimboloPrincipal = !mostrarSimboloPrincipal;
    mostrarStatus(mostrarSimboloPrincipal ? "Símbolo principal ligado" : "Símbolo principal desligado");
    return;
  }

  if (dentroDoBotao(tipografiaPalavraButton)) {
    mostrarTipografiaPalavra = !mostrarTipografiaPalavra;
    mostrarStatus(mostrarTipografiaPalavra ? "Identidade ligada" : "Identidade desligada");
    return;
  }

  for (int i = 0; i < tipografiaVarianteButtons.length; i++) {
    if (dentroDoBotao(tipografiaVarianteButtons[i])) {
      tipografiaVarianteAtiva = i;
      mostrarStatus("Tipografia ativa: " + tipografiaVarianteLabels[i]);
      return;
    }
  }

  for (int i = 0; i < modoCorButtons.length; i++) {
    if (dentroDoBotao(modoCorButtons[i])) {
      modoCorGlobal = modoCorValores[i];
      mostrarStatus("Cor logo/símbolo: " + modoCorLabels[i]);
      return;
    }
  }

  for (int i = 0; i < modoFormaButtons.length; i++) {
    if (dentroDoBotao(modoFormaButtons[i])) {
      modoFormaManual = i;
      mostrarStatus(i == 0 ? "Modo automatico ativo" : ("Modo manual: " + modoFormaLabels[i]));
      return;
    }
  }

  for (int g = 0; g < sliderGrupoCabecalho.length; g++) {
    if (dentroDoBotao(sliderGrupoCabecalho[g])) {
      sliderGrupoAberto[g] = !sliderGrupoAberto[g];
      return;
    }
  }

  for (int i = 0; i < sliders.length; i++) {
    if (!sliderVisivel[i]) continue;
    if (mouseX > sliders[i][0] && mouseX < sliders[i][0] + sliders[i][2] &&
        mouseY > sliders[i][1] - 10 && mouseY < sliders[i][1] + 12) {
      dragSlider = i;
      return;
    }
  }
}

boolean dentroDoBotao(float[] buttonData) {
  return mouseX > buttonData[0] && mouseX < buttonData[0] + buttonData[2] &&
         mouseY > buttonData[1] && mouseY < buttonData[1] + buttonData[3];
}

boolean handlePageMousePressed() {
  if (appPage == 0) {
    if (dentroDoBotao(loadBrandButton)) {
      selectInput("Selecione uma marca SVG", "onSvgSelecionadoMarca");
      return true;
    }
    if (dentroDoBotao(loadImageBrandButton)) {
      selectInput("Selecione uma marca PNG ou JPG", "onImagemSelecionadaMarca");
      return true;
    }
    if (dentroDoBotao(randomDNAButton)) {
      generateNewMutationDNA();
      return true;
    }
    if (dentroDoBotao(resetBrandButton)) {
      resetMarcaAtual();
      return true;
    }
    if (dentroDoBotao(freezeBrandButton)) {
      if (mutationParams != null) mutationParams.freezeState = !mutationParams.freezeState;
      mostrarStatus(mutationParams != null && mutationParams.freezeState ? "Mutação congelada" : "Mutação liberada");
      return true;
    }
    if (dentroDoBotao(brandToggleButton)) {
      brandSystemEnabled = !brandSystemEnabled;
      mostrarStatus(brandSystemEnabled ? "Sistema de marca ligado" : "Sistema de marca desligado");
      return true;
    }
    for (int i = 0; i < identityPresetButtons.length; i++) {
      if (dentroDoBotao(identityPresetButtons[i])) {
        applyIdentityPreset(i);
        return true;
      }
    }
    if (mouseX > pointDensitySlider[0] && mouseX < pointDensitySlider[0] + pointDensitySlider[2] &&
        mouseY > pointDensitySlider[1] - 10 && mouseY < pointDensitySlider[1] + 12) {
      dragPointDensitySlider = 1;
      atualizarSliderDensidadePontos();
      return true;
    }
    for (int i = 0; i < meshDetailButtons.length; i++) {
      if (dentroDoBotao(meshDetailButtons[i])) {
        setMeshDetailPreset(i);
        return true;
      }
    }
    for (int i = 0; i < mutationModeButtons.length; i++) {
      if (dentroDoBotao(mutationModeButtons[i])) {
        mutationParams.mode = i;
        mostrarStatus("Camada visual: " + mutationModeLabels[i]);
        return true;
      }
    }
    for (int i = 0; i < deformationModeButtons.length; i++) {
      if (dentroDoBotao(deformationModeButtons[i])) {
        mutationParams.deformationMode = i;
        mostrarStatus("Deformação: " + deformationModeLabels[i]);
        return true;
      }
    }
    for (int i = 0; i < paletteButtons.length; i++) {
      if (dentroDoBotao(paletteButtons[i])) {
        mutationParams.applyPalette(i);
        marcaPaletaCores[0] = mutationParams.primaryColor;
        marcaPaletaCores[1] = mutationParams.secondaryColor;
        marcaPaletaCount = max(marcaPaletaCount, 3);
        marcaPaletaTravada = true;
        modoCorGlobal = 3;
        mostrarStatus("Paleta: " + paletteLabels[i]);
        return true;
      }
    }
    for (int i = 0; i < marcaHsvSliders.length; i++) {
      if (mouseX > marcaHsvSliders[i][0] && mouseX < marcaHsvSliders[i][0] + marcaHsvSliders[i][2] &&
          mouseY > marcaHsvSliders[i][1] - 10 && mouseY < marcaHsvSliders[i][1] + 12) {
        dragMarcaHsvSlider = i;
        atualizarSliderMarcaHSV();
        return true;
      }
    }
    if (dentroDoBotao(marcaPaletaToggleButton)) {
      marcaPaletaTravada = !marcaPaletaTravada;
      aplicarPaletaControladaNaMarca();
      mostrarStatus(marcaPaletaTravada ? "Paleta da marca ligada" : "Paleta da marca desligada");
      return true;
    }
    if (dentroDoBotao(marcaPaletaAddButton)) {
      adicionarCorAtualNaPaletaMarca();
      return true;
    }
    if (dentroDoBotao(marcaPaletaHexField)) {
      marcaPaletaHexAtivo = true;
      panfletoFundoPaletaHexAtivo = false;
      marcaPaletaSlotSelecionado = constrain(marcaPaletaSlotSelecionado, 0, max(0, marcaPaletaCount - 1));
      marcaPaletaHexValor = hexMarca(marcaPaletaCores[marcaPaletaSlotSelecionado]);
      mostrarStatus("Digite HEX e pressione Enter");
      return true;
    }
    if (dentroDoBotao(marcaPaletaHexApplyButton)) {
      aplicarHexMarca();
      return true;
    }
    if (dentroDoBotao(marcaPaletaPasteButton)) {
      colarHexMarca();
      return true;
    }
    for (int i = 0; i < marcaPaletaCountButtons.length; i++) {
      if (dentroDoBotao(marcaPaletaCountButtons[i])) {
        marcaPaletaCount = i + 3;
        marcaPaletaSlotSelecionado = constrain(marcaPaletaSlotSelecionado, 0, marcaPaletaCount - 1);
        marcaPaletaTravada = true;
        aplicarPaletaControladaNaMarca();
        mostrarStatus("Paleta com " + marcaPaletaCount + " cores");
        return true;
      }
    }
    for (int i = 0; i < marcaPaletaSlotButtons.length; i++) {
      if (dentroDoBotao(marcaPaletaSlotButtons[i])) {
        if (i >= marcaPaletaCount) {
          mostrarStatus("Aumente a quantidade de cores para liberar este slot");
          return true;
        }
        marcaPaletaSlotSelecionado = i;
        marcaPaletaHexValor = hexMarca(marcaPaletaCores[i]);
        aplicarSlotPaletaMarca(i);
        return true;
      }
    }
    for (int i = 0; i < designParamSliders.length; i++) {
      if (mouseX > designParamSliders[i][0] && mouseX < designParamSliders[i][0] + designParamSliders[i][2] &&
          mouseY > designParamSliders[i][1] - 10 && mouseY < designParamSliders[i][1] + 12) {
        dragDesignParamSlider = i;
        return true;
      }
    }
  } else if (appPage == 2) {
    if (dentroDoBotao(panfletoModoButton)) {
      modoPanfleto = true;
      mostrarStatus("Panfleto ativo");
      return true;
    }
    if (dentroDoBotao(panfletoExportPngButton)) {
      salvarPanfletoJPG();
      return true;
    }
    if (dentroDoBotao(panfletoExportMp4Button)) {
      salvarPanfletoMP4();
      return true;
    }
    for (int i = 0; i < panfletoLayoutButtons.length; i++) {
      if (dentroDoBotao(panfletoLayoutButtons[i])) {
        aplicarLayoutPanfleto(i);
        return true;
      }
    }
    for (int i = 0; i < panfletoObjetoFormaButtons.length; i++) {
      if (dentroDoBotao(panfletoObjetoFormaButtons[i])) {
        panfletoObjetoForma = i;
        mostrarStatus("Forma do layout: " + panfletoObjetoFormaLabels[i]);
        return true;
      }
    }
    for (int i = 0; i < panfletoObjetoQuantidadeButtons.length; i++) {
      if (dentroDoBotao(panfletoObjetoQuantidadeButtons[i])) {
        panfletoObjetoQuantidade = i + 1;
        mostrarStatus("Objetos do layout: " + panfletoObjetoQuantidade);
        return true;
      }
    }
    for (int i = 0; i < panfletoFormatoButtons.length; i++) {
      if (dentroDoBotao(panfletoFormatoButtons[i])) {
        panfletoFormatoAtivo = i;
        mostrarStatus("Formato: " + panfletoFormatoLabels[i]);
        return true;
      }
    }

    if (dentroDoBotao(panfletoFundoPaletaToggleButton)) {
      panfletoFundoPaletaTravada = !panfletoFundoPaletaTravada;
      aplicarPaletaFundoPanfleto();
      mostrarStatus(panfletoFundoPaletaTravada ? "Paleta do fundo ligada" : "Paleta do fundo desligada");
      return true;
    }
    if (dentroDoBotao(panfletoFundoPaletaAddButton)) {
      adicionarCorAtualNaPaletaFundoPanfleto();
      return true;
    }
    if (dentroDoBotao(panfletoFundoPaletaHexField)) {
      panfletoFundoPaletaHexAtivo = true;
      marcaPaletaHexAtivo = false;
      panfletoFundoPaletaSlotSelecionado = constrain(panfletoFundoPaletaSlotSelecionado, 0, max(0, panfletoFundoPaletaCount - 1));
      panfletoFundoPaletaHexValor = hexMarca(panfletoFundoPaletaCores[panfletoFundoPaletaSlotSelecionado]);
      mostrarStatus("Digite HEX do fundo e pressione Enter");
      return true;
    }
    if (dentroDoBotao(panfletoFundoPaletaHexApplyButton)) {
      aplicarHexFundoPanfleto();
      return true;
    }
    if (dentroDoBotao(panfletoFundoPaletaPasteButton)) {
      colarHexFundoPanfleto();
      return true;
    }
    for (int i = 0; i < panfletoFundoPaletaCountButtons.length; i++) {
      if (dentroDoBotao(panfletoFundoPaletaCountButtons[i])) {
        panfletoFundoPaletaCount = i + 3;
        panfletoFundoPaletaSlotSelecionado = constrain(panfletoFundoPaletaSlotSelecionado, 0, panfletoFundoPaletaCount - 1);
        panfletoFundoPaletaTravada = true;
        aplicarPaletaFundoPanfleto();
        mostrarStatus("Paleta do fundo com " + panfletoFundoPaletaCount + " cores");
        return true;
      }
    }
    for (int i = 0; i < panfletoFundoPaletaSlotButtons.length; i++) {
      if (dentroDoBotao(panfletoFundoPaletaSlotButtons[i])) {
        if (i >= panfletoFundoPaletaCount) {
          mostrarStatus("Aumente a quantidade de cores para liberar este slot");
          return true;
        }
        panfletoFundoPaletaSlotSelecionado = i;
        panfletoFundoPaletaHexValor = hexMarca(panfletoFundoPaletaCores[i]);
        aplicarSlotPaletaFundoPanfleto(i);
        return true;
      }
    }
    if (dentroDoBotao(panfletoFotoAddButton)) {
      selectInput("Selecione a foto do panfleto", "onFotoSelecionadaPanfleto");
      return true;
    }
    if (dentroDoBotao(panfletoMidiaAddButton)) {
      selectInput("Selecione GIF ou vídeo do panfleto", "onMidiaSelecionadaPanfleto");
      return true;
    }
    if (dentroDoBotao(panfletoFotoLimparButton)) {
      panfletoFoto = null;
      panfletoFotoPath = "";
      limparMidiaPanfleto();
      mostrarStatus("Fundo removido");
      return true;
    }
    if (dentroDoBotao(panfletoLogoExtraToggleButton)) {
      panfletoLogoExtraAtiva = !panfletoLogoExtraAtiva;
      mostrarStatus(panfletoLogoExtraAtiva ? "Segunda logo reativa ligada" : "Segunda logo reativa desligada");
      return true;
    }
    for (int i = 0; i < panfletoMarcaSliders.length; i++) {
      if (mouseX > panfletoMarcaSliders[i][0] && mouseX < panfletoMarcaSliders[i][0] + panfletoMarcaSliders[i][2] &&
          mouseY > panfletoMarcaSliders[i][1] - 10 && mouseY < panfletoMarcaSliders[i][1] + 12) {
        dragPanfletoMarcaSlider = i;
        return true;
      }
    }
    for (int i = 0; i < panfletoLogoExtraSliders.length; i++) {
      if (mouseX > panfletoLogoExtraSliders[i][0] && mouseX < panfletoLogoExtraSliders[i][0] + panfletoLogoExtraSliders[i][2] &&
          mouseY > panfletoLogoExtraSliders[i][1] - 10 && mouseY < panfletoLogoExtraSliders[i][1] + 12) {
        dragPanfletoLogoExtraSlider = i;
        return true;
      }
    }
    for (int i = 0; i < designParamSliders.length; i++) {
      if (mouseX > designParamSliders[i][0] && mouseX < designParamSliders[i][0] + designParamSliders[i][2] &&
          mouseY > designParamSliders[i][1] - 10 && mouseY < designParamSliders[i][1] + 12) {
        dragDesignParamSlider = i;
        return true;
      }
    }
    if (dentroDoBotao(panfletoSimboloToggleButton)) {
      panfletoMostrarSimbolo = !panfletoMostrarSimbolo;
      mostrarStatus(panfletoMostrarSimbolo ? "Símbolo do panfleto ligado" : "Símbolo do panfleto desligado");
      return true;
    }
    if (dentroDoBotao(panfletoSimboloAcimaButton)) {
      panfletoSimboloAcima = !panfletoSimboloAcima;
      mostrarStatus(panfletoSimboloAcima ? "Símbolo acima da marca" : "Símbolo livre");
      return true;
    }
    for (int i = 0; i < panfletoSimboloSliders.length; i++) {
      if (mouseX > panfletoSimboloSliders[i][0] && mouseX < panfletoSimboloSliders[i][0] + panfletoSimboloSliders[i][2] &&
          mouseY > panfletoSimboloSliders[i][1] - 10 && mouseY < panfletoSimboloSliders[i][1] + 12) {
        dragPanfletoSimboloSlider = i;
        return true;
      }
    }
    if (dentroDoBotao(panfletoTextoToggleButton)) {
      panfletoMostrarTextos = !panfletoMostrarTextos;
      mostrarStatus(panfletoMostrarTextos ? "Textos do panfleto ligados" : "Textos do panfleto desligados");
      return true;
    }
    if (dentroDoBotao(panfletoAgruparTextosButton)) {
      panfletoTextosAgrupados = !panfletoTextosAgrupados;
      mostrarStatus(panfletoTextosAgrupados ? "Grupo de textos ligado" : "Grupo de textos desligado");
      return true;
    }
    if (dentroDoBotao(panfletoTextoAddButton)) {
      adicionarCaixaTextoPanfleto();
      return true;
    }
    for (int i = 0; i < panfletoTextoCorButtons.length; i++) {
      if (dentroDoBotao(panfletoTextoCorButtons[i])) {
        panfletoTextoCorModo = i;
        mostrarStatus("Cor do texto: " + panfletoTextoCorLabels[i]);
        return true;
      }
    }
    for (int i = 0; i < panfletoTextoCampos.length; i++) {
      if (dentroDoBotao(panfletoTextoCampos[i])) {
        panfletoCampoAtivo = i;
        mostrarStatus("Editando: " + panfletoTextoRotulos[i]);
        return true;
      }
    }
    for (int i = 0; i < panfletoTextoSliders.length; i++) {
      if (mouseX > panfletoTextoSliders[i][0] && mouseX < panfletoTextoSliders[i][0] + panfletoTextoSliders[i][2] &&
          mouseY > panfletoTextoSliders[i][1] - 10 && mouseY < panfletoTextoSliders[i][1] + 12) {
        dragPanfletoTextoSlider = i;
        panfletoCampoAtivo = -1;
        return true;
      }
    }
    return false;
  } else if (appPage == 3) {
    if (dentroDoBotao(estampaFotoAddButton)) {
      selectInput("Selecione uma textura opcional para a estampa", "onFotoSelecionadaEstampa");
      return true;
    }
    if (dentroDoBotao(estampaFotoLimparButton)) {
      estampaFoto = null;
      estampaFotoPath = "";
      mostrarStatus("Textura da estampa removida");
      return true;
    }
    if (dentroDoBotao(estampaRandomButton)) {
      randomizarEstampa();
      return true;
    }
    for (int i = 0; i < estampaPreviewButtons.length; i++) {
      if (dentroDoBotao(estampaPreviewButtons[i])) {
        estampaPreviewAtivo = i;
        mostrarStatus("Prévia da estampa: " + estampaPreviewLabels[i]);
        return true;
      }
    }
    if (dentroDoBotao(estampaCoresMarcaButton)) {
      estampaUsarCoresMarca = !estampaUsarCoresMarca;
      mostrarStatus(estampaUsarCoresMarca ? "Estampa usa cores da marca" : "Estampa usa cores manuais");
      return true;
    }
    for (int i = 0; i < estampaColorButtons.length; i++) {
      if (dentroDoBotao(estampaColorButtons[i])) {
        estampaColorTarget = i;
        estampaUsarCoresMarca = false;
        mostrarStatus("Cor da estampa: " + estampaColorLabels[i]);
        return true;
      }
    }
    for (int i = 0; i < estampaHsvSliders.length; i++) {
      if (mouseX > estampaHsvSliders[i][0] && mouseX < estampaHsvSliders[i][0] + estampaHsvSliders[i][2] &&
          mouseY > estampaHsvSliders[i][1] - 10 && mouseY < estampaHsvSliders[i][1] + 12) {
        dragEstampaHsvSlider = i;
        atualizarSliderEstampaHSV();
        return true;
      }
    }
    if (dentroDoBotao(estampaExportPngButton)) {
      salvarEstampaPNG();
      return true;
    }
    if (dentroDoBotao(estampaExportJpgButton)) {
      salvarEstampaJPG();
      return true;
    }
    if (dentroDoBotao(estampaExportMp4Button)) {
      if (!videoEncoding) salvarEstampaMP4();
      return true;
    }
    for (int i = 0; i < padraoFormaButtons.length; i++) {
      if (dentroDoBotao(padraoFormaButtons[i])) {
        formaPadraoAtiva = i;
        mostrarStatus("Estampa: " + estampaModoLabels[i]);
        return true;
      }
    }
    for (int i = 0; i < padraoSliders.length; i++) {
      if (!padraoSliderVisivel[i]) continue;
      if (mouseX > padraoSliders[i][0] && mouseX < padraoSliders[i][0] + padraoSliders[i][2] &&
          mouseY > padraoSliders[i][1] - 10 && mouseY < padraoSliders[i][1] + 12) {
        dragPadraoSlider = i;
        atualizarSliderPadrao();
        return true;
      }
    }
  } else if (appPage == 4) {
    if (dentroDoBotao(freezeBrandButton)) {
      if (mutationParams != null) mutationParams.freezeState = !mutationParams.freezeState;
      mostrarStatus(mutationParams != null && mutationParams.freezeState ? "Mutação congelada" : "Mutação liberada");
      return true;
    }
    for (int i = 0; i < exportPageButtons.length; i++) {
      if (dentroDoBotao(exportPageButtons[i])) {
        executarAcaoExportacao(i);
        return true;
      }
    }
  }
  return false;
}

void executarAcaoExportacao(int opcaoIdx) {
  switch (opcaoIdx) {
    case 0:
      if (appPage == 2) salvarPanfletoJPG();
      else salvarPNG();
      break;
    case 1:
      salvarJPG();
      break;
    case 2:
      salvarSVG();
      break;
    case 3:
      if (!videoEncoding) {
        alternarCapturaVideo();
      }
      break;
  }
}

void randomizarEstampa() {
  padraoQtdFormas = random(8, 34);
  padraoEspacoX = random(36, 220);
  padraoEspacoY = random(36, 210);
  padraoEscala = random(0.16, 1.12);
  padraoRefX = random(-90, 90);
  padraoRefY = random(-70, 70);
  padraoDiagonal = random(-110, 110);
  estampaPreviewAtivo = floor(random(0, estampaPreviewLabels.length));
  formaPadraoAtiva = floor(random(0, estampaModoLabels.length));
  if (random(1) > 0.58) {
    estampaUsarCoresMarca = false;
    estampaCorA = corInterfacePaleta(floor(random(4)));
    estampaCorB = corInterfacePaleta(floor(random(4)));
  }
  mostrarStatus("Estampa gerada");
}

void abrirColorPicker(int target) {
  colorPickerTarget = target;
  int c = target == 0 ? estampaCorA : (target == 1 ? estampaCorB : estampaCorFundo);
  float[] hsb = java.awt.Color.RGBtoHSB((c >> 16) & 0xFF, (c >> 8) & 0xFF, c & 0xFF, null);
  colorPickerHue = hsb[0];
  colorPickerSat = hsb[1];
  colorPickerBri = hsb[2];
  colorPickerAberto = true;
  estampaUsarCoresMarca = false;
  mostrarStatus("Escolha a cor: " + estampaColorLabels[target]);
}

boolean handleColorPickerMousePressed() {
  if (dentroDoBotao(colorPickerOkButton)) {
    aplicarColorPicker();
    colorPickerAberto = false;
    mostrarStatus("Cor aplicada");
    return true;
  }
  if (dentroDoBotao(colorPickerCancelButton)) {
    colorPickerAberto = false;
    mostrarStatus("Cor cancelada");
    return true;
  }
  if (mouseX >= colorPickerArea[0] && mouseX <= colorPickerArea[0] + colorPickerArea[2] &&
      mouseY >= colorPickerArea[1] && mouseY <= colorPickerArea[1] + colorPickerArea[3]) {
    colorPickerSat = constrain((mouseX - colorPickerArea[0]) / max(1, colorPickerArea[2]), 0, 1);
    colorPickerBri = constrain(1.0 - (mouseY - colorPickerArea[1]) / max(1, colorPickerArea[3]), 0, 1);
    aplicarColorPicker();
    return true;
  }
  if (mouseX >= colorPickerHueArea[0] && mouseX <= colorPickerHueArea[0] + colorPickerHueArea[2] &&
      mouseY >= colorPickerHueArea[1] && mouseY <= colorPickerHueArea[1] + colorPickerHueArea[3]) {
    colorPickerHue = constrain((mouseX - colorPickerHueArea[0]) / max(1, colorPickerHueArea[2]), 0, 1);
    aplicarColorPicker();
    return true;
  }
  colorPickerAberto = false;
  return true;
}

void aplicarColorPicker() {
  int c = java.awt.Color.HSBtoRGB(colorPickerHue, colorPickerSat, colorPickerBri);
  if (colorPickerTarget == 0) estampaCorA = c;
  else if (colorPickerTarget == 1) estampaCorB = c;
  else estampaCorFundo = c;
}

void resetarComposicaoPanfleto() {
  panfletoMarcaX = 0;
  panfletoMarcaY = 0;
  panfletoMarcaEscala = 1.0;
  panfletoMarcaAlign = 1;
  panfletoSimboloX = 0;
  panfletoSimboloY = -120;
  panfletoSimboloEscala = 1.0;
  panfletoSimboloAcima = true;
  panfletoTituloY = 0;
  panfletoTituloX = 0;
  panfletoSubtituloY = 0;
  panfletoSubtituloX = 0;
  panfletoRodapeY = 0;
  panfletoRodapeX = 0;
  panfletoTextoGrupoX = 0;
  panfletoTextoGrupoY = 0;
  panfletoCampoAtivo = -1;
  mostrarStatus("Panfleto recentralizado");
}

void adicionarMascaraOrganicaPanfleto() {
  int idx = -1;
  for (int i = 0; i < panfletoMascaraAtiva.length; i++) {
    if (!panfletoMascaraAtiva[i]) {
      idx = i;
      break;
    }
  }
  if (idx == -1) idx = (panfletoMascaraSelecionada + 1) % panfletoMascaraAtiva.length;

  panfletoMascaraSelecionada = idx;
  panfletoMascaraAtiva[idx] = true;
  panfletoEstampaAtiva = true;
  panfletoMascaraX[idx] = random(-0.28, 0.28);
  panfletoMascaraY[idx] = random(-0.24, 0.24);
  panfletoMascaraW[idx] = random(0.38, 0.82);
  panfletoMascaraH[idx] = random(0.18, 0.48);
  panfletoMascaraRot[idx] = random(-0.45, 0.45);
  panfletoMascaraCurvatura[idx] = random(0.38, 0.92);
  panfletoMascaraEspessura[idx] = random(0.34, 0.86);
  panfletoMascaraSom[idx] = random(0.45, 1.20);
  panfletoMascaraFluxo[idx] = floor(random(0, panfletoMascaraFluxoLabels.length));
  panfletoMascaraConteudo[idx] = floor(random(0, panfletoMascaraConteudoLabels.length));
  mostrarStatus("Nova mascara organica");
}

void mouseDragged() {
  if (colorPickerAberto) {
    handleColorPickerMousePressed();
    return;
  }

  if (dragPointDensitySlider != -1) {
    atualizarSliderDensidadePontos();
    return;
  }

  if (dragFrequencyInfluenceSlider != -1) {
    int i = dragFrequencyInfluenceSlider;
    float t = constrain((mouseX - frequencyInfluenceSliders[i][0]) / max(1, frequencyInfluenceSliders[i][2]), 0, 1);
    float val = frequencyInfluenceSliders[i][3] + t * (frequencyInfluenceSliders[i][4] - frequencyInfluenceSliders[i][3]);
    frequencyInfluenceSliders[i][5] = val;
    if (mutationParams != null) {
      if (i == 0) mutationParams.bassInfluence = val;
      if (i == 1) mutationParams.midInfluence = val;
      if (i == 2) mutationParams.trebleInfluence = val;
      if (i == 3) mutationParams.solidness = val;
    }
    return;
  }

  if (dragMarcaHsvSlider != -1) {
    atualizarSliderMarcaHSV();
    return;
  }

  if (dragDesignParamSlider != -1) {
    int i = dragDesignParamSlider;
    float t = constrain((mouseX - designParamSliders[i][0]) / max(1, designParamSliders[i][2]), 0, 1);
    float val = designParamSliders[i][3] + t * (designParamSliders[i][4] - designParamSliders[i][3]);
    designParamSliders[i][5] = val;
    setParametroMutacao(i, val);
    return;
  }

  if (dragSlider != -1) {
    float t = constrain((mouseX - sliders[(int) dragSlider][0]) / sliders[(int) dragSlider][2], 0, 1);
    sliders[(int) dragSlider][5] = sliders[(int) dragSlider][3] + t * (sliders[(int) dragSlider][4] - sliders[(int) dragSlider][3]);
  }

  if (dragPadraoSlider != -1) {
    atualizarSliderPadrao();
  }

  if (dragEstampaHsvSlider != -1) {
    atualizarSliderEstampaHSV();
    return;
  }

  if (dragPanfletoEstampaSlider != -1) {
    int i = dragPanfletoEstampaSlider;
    float t = constrain((mouseX - panfletoEstampaSliders[i][0]) / panfletoEstampaSliders[i][2], 0, 1);
    float mn = panfletoEstampaSliders[i][3];
    float mx = panfletoEstampaSliders[i][4];
    float val = mn + t * (mx - mn);
    panfletoEstampaSliders[i][5] = val;

    if (i == 0) panfletoEstampaIntensidade = val;
    if (i == 1) panfletoEstampaEscala = val;
    if (i == 2) panfletoEstampaRepeticao = val;
    if (i == 3) panfletoEstampaX = val;
    if (i == 4) panfletoEstampaY = val;
    if (i == 5) panfletoEstampaW = val;
    if (i == 6) panfletoEstampaH = val;
    return;
  }

  if (dragPanfletoMascaraSlider != -1) {
    int i = dragPanfletoMascaraSlider;
    int mi = constrain(panfletoMascaraSelecionada, 0, panfletoMascaraAtiva.length - 1);
    float t = constrain((mouseX - panfletoMascaraSliders[i][0]) / panfletoMascaraSliders[i][2], 0, 1);
    float mn = panfletoMascaraSliders[i][3];
    float mx = panfletoMascaraSliders[i][4];
    float val = mn + t * (mx - mn);
    panfletoMascaraSliders[i][5] = val;

    if (i == 0) panfletoMascaraX[mi] = val;
    if (i == 1) panfletoMascaraY[mi] = val;
    if (i == 2) panfletoMascaraW[mi] = val;
    if (i == 3) panfletoMascaraH[mi] = val;
    if (i == 4) panfletoMascaraRot[mi] = val;
    if (i == 5) panfletoMascaraCurvatura[mi] = val;
    if (i == 6) panfletoMascaraEspessura[mi] = val;
    if (i == 7) panfletoMascaraSom[mi] = val;
    return;
  }

  if (dragPanfletoMarcaSlider != -1) {
    int i = dragPanfletoMarcaSlider;
    float t = constrain((mouseX - panfletoMarcaSliders[i][0]) / panfletoMarcaSliders[i][2], 0, 1);
    float mn = panfletoMarcaSliders[i][3];
    float mx = panfletoMarcaSliders[i][4];
    float val = mn + t * (mx - mn);
    panfletoMarcaSliders[i][5] = val;

    if (i == 0) panfletoMarcaX = val;
    if (i == 1) panfletoMarcaY = val;
    if (i == 2) panfletoMarcaEscala = val;
  }

  if (dragPanfletoLogoExtraSlider != -1) {
    int i = dragPanfletoLogoExtraSlider;
    float t = constrain((mouseX - panfletoLogoExtraSliders[i][0]) / panfletoLogoExtraSliders[i][2], 0, 1);
    float mn = panfletoLogoExtraSliders[i][3];
    float mx = panfletoLogoExtraSliders[i][4];
    float val = mn + t * (mx - mn);
    panfletoLogoExtraSliders[i][5] = val;

    if (i == 0) panfletoLogoExtraX = val;
    if (i == 1) panfletoLogoExtraY = val;
    if (i == 2) panfletoLogoExtraEscala = val;
  }

  if (dragPanfletoSimboloSlider != -1) {
    int i = dragPanfletoSimboloSlider;
    float t = constrain((mouseX - panfletoSimboloSliders[i][0]) / panfletoSimboloSliders[i][2], 0, 1);
    float mn = panfletoSimboloSliders[i][3];
    float mx = panfletoSimboloSliders[i][4];
    float val = mn + t * (mx - mn);
    panfletoSimboloSliders[i][5] = val;

    if (i == 0) panfletoSimboloX = val;
    if (i == 1) panfletoSimboloY = val;
    if (i == 2) panfletoSimboloEscala = val;
  }

  if (dragPanfletoTextoSlider != -1) {
    int i = dragPanfletoTextoSlider;
    float t = constrain((mouseX - panfletoTextoSliders[i][0]) / panfletoTextoSliders[i][2], 0, 1);
    float mn = panfletoTextoSliders[i][3];
    float mx = panfletoTextoSliders[i][4];
    float val = mn + t * (mx - mn);
    panfletoTextoSliders[i][5] = val;

    if (i == 0) panfletoTituloY = val;
    if (i == 1) panfletoTituloX = val;
    if (i == 2) panfletoSubtituloY = val;
    if (i == 3) panfletoSubtituloX = val;
    if (i == 4) panfletoRodapeY = val;
    if (i == 5) panfletoRodapeX = val;
    if (i == 6) panfletoTextoGrupoY = val;
    if (i == 7) panfletoTextoGrupoX = val;
    if (i >= 8) {
      int extraIdx = (i - 8) / 2;
      if (extraIdx >= 0 && extraIdx < panfletoExtraTextoX.length) {
        if ((i - 8) % 2 == 0) panfletoExtraTextoY[extraIdx] = val;
        else panfletoExtraTextoX[extraIdx] = val;
      }
    }
  }

}

void adicionarCaixaTextoPanfleto() {
  if (panfletoTextoExtraCount >= 4) {
    mostrarStatus("Limite de textos extras atingido");
    return;
  }
  int idx = panfletoTextoExtraCount;
  panfletoTextoValores[6 + idx] = "Novo texto " + (idx + 1);
  panfletoTextoValores[10 + idx] = "18";
  panfletoExtraTextoX[idx] = 0;
  panfletoExtraTextoY[idx] = 0;
  panfletoTextoExtraCount++;
  panfletoCampoAtivo = 6 + idx;
  panfletoTextosAgrupados = false;
  mostrarStatus("Caixa de texto adicionada");
}

void mouseReleased() {
  dragDesignParamSlider = -1;
  dragMarcaHsvSlider = -1;
  dragFrequencyInfluenceSlider = -1;
  dragPointDensitySlider = -1;
  dragSlider = -1;
  dragPadraoSlider = -1;
  dragEstampaHsvSlider = -1;
  dragPanfletoEstampaSlider = -1;
  dragPanfletoMascaraSlider = -1;
  dragPanfletoMarcaSlider = -1;
  dragPanfletoLogoExtraSlider = -1;
  dragPanfletoSimboloSlider = -1;
  dragPanfletoTextoSlider = -1;
  dragPanfletoTextoMatizSlider = -1;
}

void atualizarSliderDensidadePontos() {
  float t = constrain((mouseX - pointDensitySlider[0]) / max(1, pointDensitySlider[2]), 0, 1);
  float val = pointDensitySlider[3] + t * (pointDensitySlider[4] - pointDensitySlider[3]);
  pointDensitySlider[5] = val;
  if (activeBrand != null) activeBrand.maxRenderPoints = val;
  if (mutationParams != null) mutationParams.complexity = map(val, 150, 5200, 0.1, 1.0);
  mostrarStatus("Pontos: " + int(val));
}

float[] hsvAtualMarca() {
  color c = mutationParams != null ? mutationParams.primaryColor : UI_LIGHT;
  int r = int(canalR(c));
  int g = int(canalG(c));
  int b = int(canalB(c));
  float[] out = java.awt.Color.RGBtoHSB(r, g, b, null);
  return new float[] { out[0] * 360.0, out[1] * 100.0, out[2] * 100.0, canalA(c) / 255.0 * 100.0 };
}

void atualizarSliderMarcaHSV() {
  if (dragMarcaHsvSlider < 0 || dragMarcaHsvSlider >= marcaHsvSliders.length) return;
  int i = dragMarcaHsvSlider;
  float t = constrain((mouseX - marcaHsvSliders[i][0]) / max(1, marcaHsvSliders[i][2]), 0, 1);
  marcaHsvSliders[i][5] = marcaHsvSliders[i][3] + t * (marcaHsvSliders[i][4] - marcaHsvSliders[i][3]);
  aplicarCorMarcaHSV();
}

void aplicarCorMarcaHSV() {
  if (mutationParams == null) return;
  float h = marcaHsvSliders[0][5];
  float s = marcaHsvSliders[1][5];
  float b = marcaHsvSliders[2][5];
  float a = marcaHsvSliders[3][5];
  mutationParams.primaryColor = corHSBA(h, s, b, a);
  mutationParams.secondaryColor = corSecundariaDaMarca(h, s, b, a);
  mutationParams.hueAmount = 0;
  mutationParams.saturationAmount = 1.0;
  modoCorGlobal = 3;
  if (marcaPaletaTravada) {
    marcaPaletaCores[0] = mutationParams.primaryColor;
    if (marcaPaletaCount < 3) marcaPaletaCount = 3;
    marcaPaletaCores[1] = mutationParams.secondaryColor;
  }
}

int corSecundariaDaMarca(float h, float s, float b, float a) {
  if (s < 1 || b < 1 || b > 99) return corHSBA(h, s, b, max(0, a * 0.78));
  return corHSBA((h + 32) % 360, max(0, s * 0.82), b, max(0, a * 0.78));
}

boolean marcaPaletaCoresIguais(int a, int b) {
  return abs(canalR(a) - canalR(b)) < 1 && abs(canalG(a) - canalG(b)) < 1 && abs(canalB(a) - canalB(b)) < 1;
}

String hexMarca(int c) {
  int r = constrain(round(canalR(c)), 0, 255);
  int g = constrain(round(canalG(c)), 0, 255);
  int b = constrain(round(canalB(c)), 0, 255);
  return "#" + hex(r, 2) + hex(g, 2) + hex(b, 2);
}

boolean charHexValido(char c) {
  return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F') || c == '#';
}

String limparHexColado(String valor) {
  if (valor == null) return "";
  String out = "";
  for (int i = 0; i < valor.length(); i++) {
    char c = valor.charAt(i);
    if (charHexValido(c)) out += Character.toUpperCase(c);
    if (out.length() >= 7) break;
  }
  if (out.length() > 0 && out.charAt(0) != '#') out = "#" + out;
  if (out.length() > 7) out = out.substring(0, 7);
  return out;
}

String lerClipboardTexto() {
  try {
    java.awt.datatransfer.Clipboard cb = java.awt.Toolkit.getDefaultToolkit().getSystemClipboard();
    Object data = cb.getData(java.awt.datatransfer.DataFlavor.stringFlavor);
    return data != null ? data.toString() : "";
  } catch (Exception e) {
    return "";
  }
}

void colarHexMarca() {
  String colado = limparHexColado(lerClipboardTexto());
  if (colado.length() > 0) {
    marcaPaletaHexValor = colado;
    marcaPaletaHexAtivo = true;
    aplicarHexMarca();
  } else {
    mostrarStatus("Clipboard sem HEX válido");
  }
}

int parseHexMarca(String valor) {
  if (valor == null) return -1;
  String h = trim(valor);
  if (h.startsWith("#")) h = h.substring(1);
  if (h.length() == 3) {
    h = "" + h.charAt(0) + h.charAt(0) + h.charAt(1) + h.charAt(1) + h.charAt(2) + h.charAt(2);
  }
  if (h.length() != 6) return -1;
  try {
    int r = unhex(h.substring(0, 2));
    int g = unhex(h.substring(2, 4));
    int b = unhex(h.substring(4, 6));
    if (r < 0 || g < 0 || b < 0) return -1;
    return 0xFF000000 | (r << 16) | (g << 8) | b;
  } catch (Exception e) {
    return -1;
  }
}

void aplicarHexMarca() {
  if (mutationParams == null) return;
  int c = parseHexMarca(marcaPaletaHexValor);
  if (c == -1) {
    mostrarStatus("HEX inválido");
    return;
  }
  aplicarCorDiretaMarca(c);
  marcaPaletaHexValor = hexMarca(c);
  marcaPaletaHexAtivo = false;
  mostrarStatus("HEX aplicado: " + marcaPaletaHexValor);
}

void aplicarCorDiretaMarca(int c) {
  if (mutationParams == null) return;
  marcaPaletaSlotSelecionado = constrain(marcaPaletaSlotSelecionado, 0, max(0, marcaPaletaCount - 1));
  marcaPaletaCores[marcaPaletaSlotSelecionado] = c;
  mutationParams.primaryColor = marcaPaletaCores[marcaPaletaSlotSelecionado];
  mutationParams.secondaryColor = marcaPaletaCores[min(1, marcaPaletaCount - 1)];
  mutationParams.hueAmount = 0;
  mutationParams.saturationAmount = 1.0;
  marcaPaletaTravada = true;
  modoCorGlobal = 3;
}

void adicionarCorAtualNaPaletaMarca() {
  if (mutationParams == null) return;
  int idx = constrain(marcaPaletaSlotSelecionado, 0, max(0, marcaPaletaCount - 1));
  marcaPaletaCores[idx] = parseHexMarca(marcaPaletaHexValor) != -1 ? parseHexMarca(marcaPaletaHexValor) : marcaPaletaCores[idx];
  marcaPaletaTravada = true;
  aplicarPaletaControladaNaMarca();
  mutationParams.hueAmount = 0;
  mutationParams.saturationAmount = 1.0;
  modoCorGlobal = 3;
  mostrarStatus("Cor salva no slot " + (idx + 1));
}

void aplicarSlotPaletaMarca(int idx) {
  if (idx < 0 || idx >= marcaPaletaCores.length || mutationParams == null) return;
  if (idx >= marcaPaletaCount) return;
  marcaPaletaSlotSelecionado = idx;
  marcaPaletaHexValor = hexMarca(marcaPaletaCores[idx]);
  marcaPaletaTravada = true;
  aplicarPaletaControladaNaMarca();
  mutationParams.hueAmount = 0;
  mutationParams.saturationAmount = 1.0;
  modoCorGlobal = 3;
  mostrarStatus("Slot " + (idx + 1) + " selecionado");
}

void aplicarPaletaControladaNaMarca() {
  if (mutationParams == null || !marcaPaletaTravada) return;
  marcaPaletaCount = constrain(marcaPaletaCount, 3, marcaPaletaCores.length);
  marcaPaletaSlotSelecionado = constrain(marcaPaletaSlotSelecionado, 0, marcaPaletaCount - 1);
  mutationParams.primaryColor = marcaPaletaCores[marcaPaletaSlotSelecionado];
  mutationParams.secondaryColor = marcaPaletaCores[min(1, marcaPaletaCount - 1)];
  mutationParams.hueAmount = 0;
  mutationParams.saturationAmount = 1.0;
  modoCorGlobal = 3;
}

int corFundoPanfletoAtual() {
  panfletoFundoPaletaCount = constrain(panfletoFundoPaletaCount, 3, panfletoFundoPaletaCores.length);
  panfletoFundoPaletaSlotSelecionado = constrain(panfletoFundoPaletaSlotSelecionado, 0, panfletoFundoPaletaCount - 1);
  return panfletoFundoPaletaCores[panfletoFundoPaletaSlotSelecionado];
}

void colarHexFundoPanfleto() {
  String colado = limparHexColado(lerClipboardTexto());
  if (colado.length() > 0) {
    panfletoFundoPaletaHexValor = colado;
    panfletoFundoPaletaHexAtivo = true;
    aplicarHexFundoPanfleto();
  } else {
    mostrarStatus("Clipboard sem HEX valido");
  }
}

void aplicarHexFundoPanfleto() {
  int c = parseHexMarca(panfletoFundoPaletaHexValor);
  if (c == -1) {
    mostrarStatus("HEX invalido");
    return;
  }
  aplicarCorDiretaFundoPanfleto(c);
  panfletoFundoPaletaHexValor = hexMarca(c);
  panfletoFundoPaletaHexAtivo = false;
  mostrarStatus("Fundo aplicado: " + panfletoFundoPaletaHexValor);
}

void aplicarCorDiretaFundoPanfleto(int c) {
  panfletoFundoPaletaSlotSelecionado = constrain(panfletoFundoPaletaSlotSelecionado, 0, max(0, panfletoFundoPaletaCount - 1));
  panfletoFundoPaletaCores[panfletoFundoPaletaSlotSelecionado] = c;
  panfletoFundoPaletaTravada = true;
}

void adicionarCorAtualNaPaletaFundoPanfleto() {
  int idx = constrain(panfletoFundoPaletaSlotSelecionado, 0, max(0, panfletoFundoPaletaCount - 1));
  int c = parseHexMarca(panfletoFundoPaletaHexValor);
  if (c != -1) panfletoFundoPaletaCores[idx] = c;
  panfletoFundoPaletaTravada = true;
  mostrarStatus("Cor do fundo salva no slot " + (idx + 1));
}

void aplicarSlotPaletaFundoPanfleto(int idx) {
  if (idx < 0 || idx >= panfletoFundoPaletaCores.length) return;
  if (idx >= panfletoFundoPaletaCount) return;
  panfletoFundoPaletaSlotSelecionado = idx;
  panfletoFundoPaletaHexValor = hexMarca(panfletoFundoPaletaCores[idx]);
  panfletoFundoPaletaTravada = true;
  mostrarStatus("Fundo: slot " + (idx + 1));
}

void aplicarPaletaFundoPanfleto() {
  panfletoFundoPaletaCount = constrain(panfletoFundoPaletaCount, 3, panfletoFundoPaletaCores.length);
  panfletoFundoPaletaSlotSelecionado = constrain(panfletoFundoPaletaSlotSelecionado, 0, panfletoFundoPaletaCount - 1);
  panfletoFundoPaletaHexValor = hexMarca(panfletoFundoPaletaCores[panfletoFundoPaletaSlotSelecionado]);
}

int corAtualEstampa(int target) {
  if (target == 0) return estampaCorA;
  if (target == 1) return estampaCorB;
  return estampaCorFundo;
}

void setCorAtualEstampa(int target, int c) {
  if (target == 0) estampaCorA = c;
  else if (target == 1) estampaCorB = c;
  else estampaCorFundo = c;
}

float[] hsvAtualEstampa() {
  int c = corAtualEstampa(estampaColorTarget);
  int r = int(canalR(c));
  int g = int(canalG(c));
  int b = int(canalB(c));
  float[] out = java.awt.Color.RGBtoHSB(r, g, b, null);
  return new float[] { out[0] * 360.0, out[1] * 100.0, out[2] * 100.0, canalA(c) / 255.0 * 100.0 };
}

void atualizarSliderEstampaHSV() {
  if (dragEstampaHsvSlider < 0 || dragEstampaHsvSlider >= estampaHsvSliders.length) return;
  int i = dragEstampaHsvSlider;
  float t = constrain((mouseX - estampaHsvSliders[i][0]) / max(1, estampaHsvSliders[i][2]), 0, 1);
  estampaHsvSliders[i][5] = estampaHsvSliders[i][3] + t * (estampaHsvSliders[i][4] - estampaHsvSliders[i][3]);
  aplicarCorEstampaHSV();
}

void aplicarCorEstampaHSV() {
  float h = estampaHsvSliders[0][5];
  float s = estampaHsvSliders[1][5];
  float b = estampaHsvSliders[2][5];
  float a = estampaHsvSliders[3][5];
  setCorAtualEstampa(estampaColorTarget, corHSBA(h, s, b, a));
  estampaUsarCoresMarca = false;
}

void atualizarSliderPadrao() {
  if (dragPadraoSlider < 0 || dragPadraoSlider >= padraoSliders.length) return;
  int i = dragPadraoSlider;
  float t = constrain((mouseX - padraoSliders[i][0]) / max(1, padraoSliders[i][2]), 0, 1);
  float mn = padraoSliders[i][3];
  float mx = padraoSliders[i][4];
  float val = mn + t * (mx - mn);
  padraoSliders[i][5] = val;

  if (i == 0) padraoQtdFormas = round(val);
  if (i == 1) padraoEspacoX = val;
  if (i == 2) padraoEspacoY = val;
  if (i == 3) padraoEscala = val;
  if (i == 4) padraoRefX = val;
  if (i == 5) padraoRefY = val;
  if (i == 6) padraoDiagonal = val;
}

void mouseWheel(MouseEvent event) {
  boolean sobrePainel = mostrarBarra &&
    mouseX >= menuOffsetX &&
    mouseX <= menuOffsetX + menuWidth &&
    mouseY >= 0 &&
    mouseY <= height;

  if (sobrePainel && menuMaxScrollY > 0) {
    menuScrollY = constrain(menuScrollY + event.getCount() * 28, 0, menuMaxScrollY);
  }

  float panelX = width - painelPadraoWidth + painelPadraoOffsetX;
  boolean sobrePadrao = mostrarBarraPadroes &&
    mouseX >= panelX &&
    mouseX <= panelX + painelPadraoWidth &&
    mouseY >= 0 &&
    mouseY <= height;

  if (sobrePadrao && painelPadraoMaxScrollY > 0) {
    painelPadraoScrollY = constrain(painelPadraoScrollY + event.getCount() * 28, 0, painelPadraoMaxScrollY);
  }
}

void atualizarEntradaGestual() {
  if (gestureData != null) {
    gestureData.update(mouseX, mouseY, pmouseX, pmouseY);
  }
}

void keyPressed() {
  if (panfletoFundoPaletaHexAtivo) {
    if (key == 22 || ((key == 'v' || key == 'V') && keyEvent != null && keyEvent.isControlDown())) {
      colarHexFundoPanfleto();
      return;
    }
    if (keyCode == ENTER || keyCode == RETURN) {
      aplicarHexFundoPanfleto();
      key = 0;
      return;
    }
    if (keyCode == BACKSPACE) {
      if (panfletoFundoPaletaHexValor != null && panfletoFundoPaletaHexValor.length() > 0) {
        panfletoFundoPaletaHexValor = panfletoFundoPaletaHexValor.substring(0, panfletoFundoPaletaHexValor.length() - 1);
      }
      return;
    }
    if (keyCode == DELETE) {
      panfletoFundoPaletaHexValor = "";
      return;
    }
    if (key == ESC) {
      key = 0;
      panfletoFundoPaletaHexAtivo = false;
      return;
    }
    if (key == CODED) return;
    if (panfletoFundoPaletaHexValor == null) panfletoFundoPaletaHexValor = "";
    if (charHexValido(key) && panfletoFundoPaletaHexValor.length() < 7) {
      if (key == '#') {
        panfletoFundoPaletaHexValor = "#";
      } else {
        if (panfletoFundoPaletaHexValor == null || panfletoFundoPaletaHexValor.length() == 0) panfletoFundoPaletaHexValor = "#";
        panfletoFundoPaletaHexValor += Character.toUpperCase(key);
      }
    }
    return;
  }

  if (marcaPaletaHexAtivo) {
    if (key == 22 || ((key == 'v' || key == 'V') && keyEvent != null && keyEvent.isControlDown())) {
      colarHexMarca();
      return;
    }
    if (keyCode == ENTER || keyCode == RETURN) {
      aplicarHexMarca();
      key = 0;
      return;
    }
    if (keyCode == BACKSPACE) {
      if (marcaPaletaHexValor != null && marcaPaletaHexValor.length() > 0) {
        marcaPaletaHexValor = marcaPaletaHexValor.substring(0, marcaPaletaHexValor.length() - 1);
      }
      return;
    }
    if (keyCode == DELETE) {
      marcaPaletaHexValor = "";
      return;
    }
    if (key == ESC) {
      key = 0;
      marcaPaletaHexAtivo = false;
      return;
    }
    if (key == CODED) return;
    if (marcaPaletaHexValor == null) marcaPaletaHexValor = "";
    if (charHexValido(key) && marcaPaletaHexValor.length() < 7) {
      if (key == '#') {
        marcaPaletaHexValor = "#";
      } else {
        if (marcaPaletaHexValor == null || marcaPaletaHexValor.length() == 0) marcaPaletaHexValor = "#";
        marcaPaletaHexValor += Character.toUpperCase(key);
      }
    }
    return;
  }

  if (panfletoCampoAtivo != -1) {
    if (keyCode == ENTER || keyCode == RETURN) {
      panfletoCampoAtivo = (panfletoCampoAtivo + 1) % panfletoTextoCampos.length;
      key = 0;
      return;
    }

    if (keyCode == TAB) {
      panfletoCampoAtivo = (panfletoCampoAtivo + 1) % panfletoTextoCampos.length;
      key = 0;
      return;
    }

    if (keyCode == BACKSPACE) {
      String atual = panfletoTextoValores[panfletoCampoAtivo];
      if (atual != null && atual.length() > 0) {
        panfletoTextoValores[panfletoCampoAtivo] = atual.substring(0, atual.length() - 1);
      }
      return;
    }

    if (keyCode == DELETE) {
      panfletoTextoValores[panfletoCampoAtivo] = "";
      return;
    }

    if (key == ESC) {
      key = 0;
      panfletoCampoAtivo = -1;
      return;
    }

    if (key == CODED) return;
    char c = key;
    boolean numerico = panfletoCampoNumerico[panfletoCampoAtivo];
    if (numerico) {
      boolean ok = (c >= '0' && c <= '9') || c == '-' || c == '.' || c == ',';
      if (ok) panfletoTextoValores[panfletoCampoAtivo] += c;
    } else {
      if (c >= 32 && c != 127) panfletoTextoValores[panfletoCampoAtivo] += c;
    }
    return;
  }

  if (key == 'h' || key == 'H') mostrarBarra = !mostrarBarra;
}

void onSvgSelecionadoMarca(File selection) {
  enfileirarMarcaSelecionada(selection, "svg");
}

void onImagemSelecionadaMarca(File selection) {
  enfileirarMarcaSelecionada(selection, "imagem");
}

void enfileirarMarcaSelecionada(File selection, String tipo) {
  marcaArquivoPendente = selection;
  marcaArquivoPendenteTipo = tipo;
  marcaArquivoPendenteAtivo = true;
  mostrarStatus(selection == null ? "Selecao cancelada" : "Arquivo selecionado: " + selection.getName());
}

void processarMarcaPendente() {
  if (!marcaArquivoPendenteAtivo) return;
  File selection = marcaArquivoPendente;
  String tipo = marcaArquivoPendenteTipo;
  marcaArquivoPendente = null;
  marcaArquivoPendenteTipo = "";
  marcaArquivoPendenteAtivo = false;
  carregarMarcaSelecionadaComFiltro(selection, tipo);
}

void carregarMarcaSelecionadaComFiltro(File selection, String tipo) {
  if (selection == null) {
    mostrarStatus("Selecao cancelada");
    return;
  }

  String nome = selection.getName().toLowerCase();
  if (tipo.equals("svg") && !nome.endsWith(".svg")) {
    mostrarStatus("Escolha um arquivo SVG");
    return;
  }
  if (tipo.equals("imagem") && !(nome.endsWith(".png") || nome.endsWith(".jpg") || nome.endsWith(".jpeg"))) {
    mostrarStatus("Escolha PNG ou JPG");
    return;
  }
  onBrandFileSelected(selection);
}

void onBrandFileSelected(File selection) {
  if (selection == null) {
    mostrarStatus("Selecao cancelada");
    return;
  }

  String nome = selection.getName().toLowerCase();
  if (!(nome.endsWith(".svg") || nome.endsWith(".png") || nome.endsWith(".jpg") || nome.endsWith(".jpeg"))) {
    mostrarStatus("Escolha SVG, PNG ou JPG");
    return;
  }

  mostrarStatus("Carregando: " + selection.getName());

  try {
    if (carregarMarcaDireta(selection)) {
      brandSystemEnabled = true;
      appPage = 0;
      mostrarStatus("Marca importada com sucesso");
    } else {
      mostrarStatus("Nao carregou: " + selection.getName());
    }
  } catch (Exception e) {
    println("Erro ao carregar marca: " + e.getMessage());
    mostrarStatus("Erro ao carregar: " + e.getMessage());
  }
}

void onFotoSelecionadaPanfleto(File selection) {
  if (selection == null) {
    mostrarStatus("Selecao de foto cancelada");
    return;
  }

  PImage img = tentarCarregarImagem(selection.getAbsolutePath());
  if (img == null || img.width <= 0 || img.height <= 0) {
    mostrarStatus("Falha ao carregar foto");
    return;
  }

  panfletoFoto = img;
  panfletoFotoPath = selection.getAbsolutePath();
  limparMidiaPanfleto();
  mostrarStatus("Foto importada com sucesso");
}

void onMidiaSelecionadaPanfleto(File selection) {
  if (selection == null) {
    mostrarStatus("Selecao de midia cancelada");
    return;
  }

  mostrarStatus("Carregando midia...");
  boolean ok = carregarMidiaAnimadaPanfleto(selection);
  if (ok) {
    panfletoFoto = null;
    panfletoFotoPath = "";
    mostrarStatus("Mídia importada com sucesso");
  } else {
    mostrarStatus("Falha ao carregar GIF/vídeo");
  }
}

void onFotoSelecionadaEstampa(File selection) {
  if (selection == null) {
    mostrarStatus("Selecao de textura cancelada");
    return;
  }

  PImage img = tentarCarregarImagem(selection.getAbsolutePath());
  if (img == null || img.width <= 0 || img.height <= 0) {
    mostrarStatus("Falha ao carregar textura");
    return;
  }

  estampaFoto = img;
  estampaFotoPath = selection.getAbsolutePath();
  mostrarStatus("Textura importada com sucesso");
}
