import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.svg.*;
import processing.event.*;
import java.io.*;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import java.awt.image.BufferedImage;
import java.util.Iterator;

// Eclode: sistema generativo para identidades responsivas.
final String APP_NAME = "ECLODE";
final String APP_TAGLINE = "";
final int UI_LIGHT = 0xFFEDEFF4;
final int UI_GREEN = 0xFF2F80C8;
final int UI_BROWN = 0xFF403C8F;
final int UI_DARK = 0xFF111216;
final int UI_PANEL = 0xF5111216;
final int UI_PANEL_SOFT = 0xE61B1D24;
final int UI_LINE = 0x66464A55;
final int UI_MUTED = 0xFF8F949E;
PImage interfaceLogo;

// AUDIO
Minim      minim;
AudioInput mic;
FFT        fft;
boolean audioInputAvailable = false;
boolean audioInputWarningShown = false;

// LEVELS
float bassRaw, midRaw, trebleRaw, presenceRaw, noiseRaw;
float sBass, sMid, sTreble, sPresence, sNoise;
float trebleImpact = 0;

// STATE
int     formaAtiva      = 0;
int     formaAnterior   = 0;
int     ultimaForma     = 0;
boolean emHold          = false;
float   timerHold       = 0;
float   duracaoHold     = 5.0;
float   transicaoForma  = 1.0;
float   velTransicao    = 0.08;

// DISSOLVE
float alfaDissolve = 255;
float velDissolve  = 4.2;

// IDLE
float faseFolego = 0;
float velFolego  = 0.016;

// FLOATING MOTION
float tempoFlutua = 0;
float flutuaX, flutuaY;

// GATES
float gateB = 0.18, gateM = 0.14, gateT = 0.04;
// RUIDO desativado: gateN removido.
float boostT = 2.5, gateP = 0.10;

// WEIGHTS
// RUIDO desativado: pN removido.
float pB = 0.8, pM = 1.2, pT = 1.0, pP = 1.8;

// GLOBAL INTENSITY
float intensidade = 0;
float tempoSemAtivacao = 0;
float limiteInatividade = 30.0;
float microfoneSensibilidade = 1.9;

// NOISE SEED
float semente = 0;
float noiseDynamicTime = 0;

// SIDE MENU
boolean mostrarBarra = true;
float   menuWidth    = 330;
float   menuOffsetX  = 0;
float   menuTabWidth = 36;
float   menuPadding  = 22;
float   menuScrollY = 0;
float   menuMaxScrollY = 0;
float   uiHeaderHeight = 60;
float   uiTabsHeight = 52;
float[][] uiTopTabButtons = new float[4][4];
String[] uiTopTabLabels = { "Mutacao", "Panfleto", "Estampa", "Saida" };
int[] uiTopTabPages = { 0, 2, 3, 4 };
int appPage = 0; // 0=Mutacao, 2=Panfleto, 3=Estampa, 4=Saida
float[] exportMainButton  = new float[4];
float[][] exportOptionButtons = new float[4][4];
String[] exportOptionLabels = { "PNG", "JPG (preto)", "SVG", "MP4 (5s)" };
boolean exportMenuAberto = false;
float[] linhaReativosButton = new float[4];
float[] simboloPrincipalButton = new float[4];
float[] tipografiaPalavraButton = new float[4];
float[][] tipografiaVarianteButtons = new float[2][4];
String[] tipografiaVarianteLabels = { "PRINCIPAL", "VERSAO 2" };
float[][] modoCorButtons = new float[3][4];
String[] modoCorLabels = { "PRETO", "BRANCO", "ORIGINAL" };
int[] modoCorValores = { 0, 1, 3 };
int modoCorGlobal = 3;
float[][] modoFormaButtons = new float[5][4];
String[] modoFormaLabels = { "AUTO", "GRAVE", "MEDIO", "AGUDO", "PRESENCA" };
float[] loadBrandButton = new float[4];
float[] loadImageBrandButton = new float[4];
File marcaArquivoPendente = null;
boolean marcaArquivoPendenteAtivo = false;
String marcaArquivoPendenteTipo = "";
float[] randomDNAButton = new float[4];
float[] resetBrandButton = new float[4];
float[] freezeBrandButton = new float[4];
float[] exportPngButton = new float[4];
float[] brandToggleButton = new float[4];
float[][] mutationModeButtons = new float[13][4];
String[] mutationModeLabels = { "ORIGINAL", "MASSA", "PONTOS", "LINHAS", "PARTICULAS", "GRID", "ECO", "PERLIN", "AREIA", "PELUCIA", "FIOS", "DIFUSAO", "GOSMA" };
float[][] rdA, rdB, rdNextA, rdNextB, rdMask;
int rdCols = 0, rdRows = 0, rdBrandSignature = -1;
float rdMinX = 0, rdMinY = 0, rdMaxX = 0, rdMaxY = 0, rdComplexityKey = -1;
float[][] deformationModeButtons = new float[7][4];
String[] deformationModeLabels = { "SUTIL", "PULSO", "EXPLODIR", "ONDULAR", "FATIAR", "CAMPO", "GLITCH" };
float[][] identityPresetButtons = new float[5][4];
String[] identityPresetLabels = { "PULSO", "MODULAR", "ECLOSAO", "FANTASMA", "NERVOSO" };
float[][] meshDetailButtons = new float[0][4];
String[] meshDetailLabels = {};
float[] pointDensitySlider = new float[6];
float[][] frequencyInfluenceSliders = new float[4][6];
String[] frequencyInfluenceLabels = { "Grave", "Médio", "Agudo", "Suavização" };
float[][] paletteButtons = new float[4][4];
String[] paletteLabels = { "BRANCO", "VIVO", "QUENTE", "AZUL" };
float[][] designParamSliders = new float[20][6];
String[] designParamLabels = {
  "Reacao", "Deformacao", "Ruido", "Deslocamento", "Traco", "Escala", "Rotacao", "Fragmentacao", "Retorno", "Ataque",
  "Densidade", "Fluxo sonoro", "Peso tipográfico", "Curvatura", "Complexidade", "Dispersão", "Opacidade", "Matiz", "Saturação", "Velocidade"
};
int dragDesignParamSlider = -1;
float[][] marcaHsvSliders = new float[4][6];
String[] marcaHsvLabels = { "Matiz", "Saturação", "Luminosidade", "Alpha" };
int dragMarcaHsvSlider = -1;
boolean marcaPaletaTravada = false;
int marcaPaletaCount = 3;
int marcaPaletaSlotSelecionado = 0;
int[] marcaPaletaCores = {
  0xFFFFFFFF, 0xFF111111, 0xFF23D6C0, 0xFFF35C9A, 0xFFFFC857, 0xFF4C7DFF
};
float[] marcaPaletaToggleButton = new float[4];
float[] marcaPaletaAddButton = new float[4];
float[] marcaPaletaHexField = new float[4];
float[] marcaPaletaHexApplyButton = new float[4];
float[] marcaPaletaPasteButton = new float[4];
float[][] marcaPaletaCountButtons = new float[4][4];
String[] marcaPaletaCountLabels = { "3", "4", "5", "6" };
float[][] marcaPaletaSlotButtons = new float[6][4];
String marcaPaletaHexValor = "#FFFFFF";
boolean marcaPaletaHexAtivo = false;
int dragFrequencyInfluenceSlider = -1;
int dragPointDensitySlider = -1;
float[][] playlistSlotButtons = new float[6][4];
float[] playlistSaveButton = new float[4];
String[] playlistSlotNames = { "Estado 1", "Estado 2", "Estado 3", "Estado 4", "Estado 5", "Estado 6" };
MutationParams[] playlistParams = new MutationParams[6];
String[] playlistBrandNames = new String[6];
String[] playlistPresetNames = new String[6];
int activePlaylistSlot = -1;
float[][] exportPageButtons = new float[4][4];
String[] exportPageLabels = { "PNG", "JPG", "SVG", "MP4" };
boolean mostrarBarraPadroes = true;
float painelPadraoWidth = 310;
float painelPadraoOffsetX = 0;
float painelPadraoTabWidth = 34;
float painelPadraoScrollY = 0;
float painelPadraoMaxScrollY = 0;
float[] modoPadraoButton = new float[4];
float[] estampaFotoAddButton = new float[4];
float[] estampaFotoLimparButton = new float[4];
float[] estampaRandomButton = new float[4];
float[] estampaExportPngButton = new float[4];
float[] estampaExportJpgButton = new float[4];
float[] estampaExportMp4Button = new float[4];
float[] estampaCoresMarcaButton = new float[4];
float[][] estampaColorButtons = new float[3][4];
String[] estampaColorLabels = { "Cor A", "Cor B", "Fundo" };
String[] estampaModoLabels = {
  "Pixel Grad.", "Compressao V.", "Grade Optica",
  "Barras Irreg.", "Losangos", "Compressao R.",
  "Ondas Fluidas", "Grade Ponto", "Fluxo V.",
  "Interf. H.", "Refracao V.", "Faixas Liquidas",
  "Ritmo Min.", "Diagonal Frag.", "Malha Geo.",
  "Campo Diag.", "Grade Compr.", "Zig Zag",
  "Angular Disp.", "Expansao", "Ruido Modular",
  "Barras Disp.", "Linhas Dados", "Labirinto"
};
float[][] padraoFormaButtons = new float[24][4];
String[] padraoFormaLabels = {
  "Pixel", "Comp. V", "Optica",
  "Barras", "Losango", "Comp. R",
  "Ondas", "Pontos", "Fluxo V",
  "Interf.", "Refracao", "Liquido",
  "Min.", "Diag.", "Geo.",
  "Cinetico", "Modulo", "ZigZag",
  "Disperso", "Expande", "Ruido",
  "Barras 2", "Dados", "Labirinto"
};
int formaPadraoAtiva = 0;
float[][] estampaPreviewButtons = new float[4][4];
String[] estampaPreviewLabels = { "Padrao", "Tile", "Editorial", "Superficie" };
int estampaPreviewAtivo = 0;
boolean modoPadraoEstampa = false;
boolean estampaUsarCoresMarca = true;
int estampaCorA = 0xFF111111;
int estampaCorB = 0xFFF3EFE7;
int estampaCorFundo = 0xFFF0ECE2;
boolean colorPickerAberto = false;
int colorPickerTarget = 0;
float colorPickerHue = 0;
float colorPickerSat = 0;
float colorPickerBri = 0;
float[] colorPickerArea = new float[4];
float[] colorPickerHueArea = new float[4];
float[] colorPickerOkButton = new float[4];
float[] colorPickerCancelButton = new float[4];
float[][] estampaHsvSliders = new float[4][6];
String[] estampaHsvLabels = { "Matiz", "Saturação", "Luminosidade", "Alpha" };
int dragEstampaHsvSlider = -1;
int estampaColorTarget = 0;
float[][] padraoSliders = new float[7][7];
String[] padraoSliderLabels = { "Densidade", "Espac. X", "Espac. Y", "Escala", "Desloc. X", "Desloc. Y", "Diagonal" };
boolean[] padraoSliderVisivel = new boolean[7];
int dragPadraoSlider = -1;
PImage estampaFoto = null;
String estampaFotoPath = "";
float estampaRenderX = 0;
float estampaRenderY = 0;
float estampaRenderW = 0;
float estampaRenderH = 0;
float[] panfletoModoButton = new float[4];
float[][] panfletoLayoutButtons = new float[5][4];
String[] panfletoLayoutLabels = { "Cartaz", "Editorial", "Manifesto", "Evento", "Foto Fundo" };
int panfletoLayoutAtivo = 0;
float[][] panfletoObjetoFormaButtons = new float[7][4];
String[] panfletoObjetoFormaLabels = { "Circulo", "Oval", "Quadrado", "Losango", "Retangulo", "Marca", "Marca live" };
int panfletoObjetoForma = 0;
float[][] panfletoObjetoQuantidadeButtons = new float[6][4];
int panfletoObjetoQuantidade = 3;
float[][] panfletoFormatoButtons = new float[5][4];
String[] panfletoFormatoLabels = { "A4 V", "A4 H", "1080x1350", "1080x1920", "5x15 V" };
int panfletoFormatoAtivo = 0;
float[] panfletoAvancadoButton = new float[4];
boolean panfletoAvancadoAberto = false;
float[] panfletoFotoAddButton = new float[4];
float[] panfletoFotoLimparButton = new float[4];
float[] panfletoExportPngButton = new float[4];
float[] panfletoExportMp4Button = new float[4];
float[] panfletoMidiaAddButton = new float[4];
float[] panfletoResetZoomButton = new float[4];
float[] panfletoAgruparTextosButton = new float[4];
float[] panfletoEstampaToggleButton = new float[4];
float[][] panfletoEstampaAplicacaoButtons = new float[4][4];
String[] panfletoEstampaAplicacaoLabels = { "Fundo", "Area", "Mascara", "Overlay" };
int panfletoEstampaAplicacao = 0;
float[][] panfletoEstampaBlendButtons = new float[4][4];
String[] panfletoEstampaBlendLabels = { "Normal", "Multiply", "Screen", "Overlay" };
int panfletoEstampaBlend = 0;
float[][] panfletoEstampaMascaraButtons = new float[3][4];
String[] panfletoEstampaMascaraLabels = { "Retang", "Circulo", "Organico" };
int panfletoEstampaMascara = 0;
float[][] panfletoEstampaSliders = new float[7][6];
String[] panfletoEstampaSliderLabels = { "Intensidade", "Escala", "Repeticao", "Area X", "Area Y", "Largura", "Altura" };
int dragPanfletoEstampaSlider = -1;
boolean panfletoEstampaAtiva = false;
float panfletoEstampaIntensidade = 0.68;
float panfletoEstampaEscala = 0.46;
float panfletoEstampaRepeticao = 0.70;
float panfletoEstampaX = 0;
float panfletoEstampaY = 0;
float panfletoEstampaW = 0.86;
float panfletoEstampaH = 0.34;
float[] panfletoMascaraAddButton = new float[4];
float[][] panfletoMascaraSelectButtons = new float[3][4];
float[][] panfletoMascaraFluxoButtons = new float[3][4];
String[] panfletoMascaraFluxoLabels = { "Organica", "Ondulado", "Rastro" };
float[][] panfletoMascaraConteudoButtons = new float[4][4];
String[] panfletoMascaraConteudoLabels = { "Campo", "Ritmo", "Recorte", "Marca" };
float[][] panfletoMascaraSliders = new float[8][6];
String[] panfletoMascaraSliderLabels = { "Mascara X", "Mascara Y", "Largura", "Altura", "Rotacao", "Fluidez", "Peso visual", "Resposta" };
int dragPanfletoMascaraSlider = -1;
int panfletoMascaraSelecionada = 0;
boolean[] panfletoMascaraAtiva = { true, false, false };
int[] panfletoMascaraFluxo = { 0, 1, 2 };
int[] panfletoMascaraConteudo = { 0, 1, 2 };
float[] panfletoMascaraX = { 0.02, -0.22, 0.25 };
float[] panfletoMascaraY = { -0.02, 0.20, -0.18 };
float[] panfletoMascaraW = { 0.72, 0.54, 0.46 };
float[] panfletoMascaraH = { 0.42, 0.25, 0.22 };
float[] panfletoMascaraRot = { -0.08, 0.18, -0.26 };
float[] panfletoMascaraCurvatura = { 0.62, 0.52, 0.78 };
float[] panfletoMascaraEspessura = { 0.72, 0.45, 0.36 };
float[] panfletoMascaraSom = { 0.80, 0.65, 0.92 };
float[][] panfletoTemaButtons = new float[4][4];
String[] panfletoTemaLabels = { "Noite", "Claro", "Areia", "Azul" };
int panfletoTemaAtivo = 0;
float panfletoTemaPulse = 0;
boolean panfletoFundoPaletaTravada = true;
int panfletoFundoPaletaCount = 3;
int panfletoFundoPaletaSlotSelecionado = 0;
int[] panfletoFundoPaletaCores = {
  0xFF101218, 0xFFF1ECE3, 0xFFE8DDC2, 0xFF1C2C4A, 0xFFFFFFFF, 0xFF000000
};
float[] panfletoFundoPaletaToggleButton = new float[4];
float[] panfletoFundoPaletaAddButton = new float[4];
float[] panfletoFundoPaletaHexField = new float[4];
float[] panfletoFundoPaletaHexApplyButton = new float[4];
float[] panfletoFundoPaletaPasteButton = new float[4];
float[][] panfletoFundoPaletaCountButtons = new float[4][4];
float[][] panfletoFundoPaletaSlotButtons = new float[6][4];
String panfletoFundoPaletaHexValor = "#101218";
boolean panfletoFundoPaletaHexAtivo = false;
boolean modoPanfleto = false;
boolean exportandoPanfletoLimpo = false;
float panfletoRenderX = 0;
float panfletoRenderY = 0;
float panfletoRenderW = 0;
float panfletoRenderH = 0;
PImage panfletoFoto = null;
String panfletoFotoPath = "";
PImage[] panfletoMidiaFrames = null;
String panfletoMidiaPath = "";
String panfletoMidiaTipo = "";
float panfletoMidiaFps = 12;
int panfletoMidiaExportFrame = -1;
float panfletoMidiaExportFps = 24;
float[][] panfletoMarcaSliders = new float[3][6];
String[] panfletoMarcaSliderLabels = { "Posicao horizontal", "Posicao vertical", "Tamanho" };
int dragPanfletoMarcaSlider = -1;
float panfletoMarcaX = 0;
float panfletoMarcaY = 0;
float panfletoMarcaEscala = 1.0;
float[][] panfletoMarcaAlignButtons = new float[3][4];
int panfletoMarcaAlign = 1;
float[] panfletoLogoExtraToggleButton = new float[4];
float[][] panfletoLogoExtraSliders = new float[3][6];
String[] panfletoLogoExtraSliderLabels = { "Logo extra horizontal", "Logo extra vertical", "Logo extra tamanho" };
int dragPanfletoLogoExtraSlider = -1;
boolean panfletoLogoExtraAtiva = false;
float panfletoLogoExtraX = -180;
float panfletoLogoExtraY = 180;
float panfletoLogoExtraEscala = 0.42;
float[] panfletoSimboloToggleButton = new float[4];
float[] panfletoSimboloAcimaButton = new float[4];
float[][] panfletoSimboloSliders = new float[3][6];
String[] panfletoSimboloSliderLabels = { "Simbolo X", "Simbolo Y", "Tamanho simbolo" };
int dragPanfletoSimboloSlider = -1;
boolean panfletoMostrarSimbolo = false;
boolean panfletoSimboloAcima = true;
float panfletoSimboloX = 0;
float panfletoSimboloY = -120;
float panfletoSimboloEscala = 1.0;
float[][] panfletoTextoCampos = new float[14][4];
float[] panfletoTextoAddButton = new float[4];
float[] panfletoTextoToggleButton = new float[4];
String[] panfletoTextoRotulos = {
  "Titulo",
  "Subtitulo",
  "Rodape",
  "Tam titulo",
  "Tam subtitulo",
  "Tam rodape",
  "Texto extra 1",
  "Texto extra 2",
  "Texto extra 3",
  "Texto extra 4",
  "Tam extra 1",
  "Tam extra 2",
  "Tam extra 3",
  "Tam extra 4"
};
String[] panfletoTextoValores = {
  "Eclode",
  "Identidade em tempo real",
  "som + sistema aberto",
  "62",
  "28",
  "16",
  "Novo texto",
  "Novo texto",
  "Novo texto",
  "Novo texto",
  "18",
  "18",
  "18",
  "18"
};
boolean[] panfletoCampoNumerico = {
  false, false, false, true, true, true,
  false, false, false, false, true, true, true, true
};
int panfletoCampoAtivo = -1;
boolean panfletoMostrarTextos = true;
boolean panfletoTextosAgrupados = true;
int panfletoTextoExtraCount = 0;
float[][] panfletoTextoCorButtons = new float[4][4];
String[] panfletoTextoCorLabels = { "Tema", "Preto", "Branco", "Bege" };
int panfletoTextoCorModo = 0;
float[] panfletoTextoMatizSlider = new float[6];
float panfletoTextoMatiz = 210;
int dragPanfletoTextoMatizSlider = -1;
float[][] panfletoTextoSliders = new float[16][6];
String[] panfletoTextoSliderLabels = {
  "Titulo vertical", "Titulo horizontal", "Subtitulo vertical", "Subtitulo horizontal", "Rodape vertical", "Rodape horizontal", "Grupo vertical", "Grupo horizontal",
  "Extra 1 vertical", "Extra 1 horizontal", "Extra 2 vertical", "Extra 2 horizontal", "Extra 3 vertical", "Extra 3 horizontal", "Extra 4 vertical", "Extra 4 horizontal"
};
int dragPanfletoTextoSlider = -1;
float panfletoTituloY = 0;
float panfletoTituloX = 0;
float panfletoSubtituloY = 0;
float panfletoSubtituloX = 0;
float panfletoRodapeY = 0;
float panfletoRodapeX = 0;
float panfletoTextoGrupoY = 0;
float panfletoTextoGrupoX = 0;
float[] panfletoExtraTextoY = { 0, 0, 0, 0 };
float[] panfletoExtraTextoX = { 0, 0, 0, 0 };
float[][] panfletoTituloAlignButtons = new float[3][4];
float[][] panfletoSubAlignButtons = new float[3][4];
float[][] panfletoRodapeAlignButtons = new float[3][4];
String[] panfletoAlignLabels = { "Esq", "Centro", "Dir" };
int panfletoTituloAlign = 1;
int panfletoSubtituloAlign = 1;
int panfletoRodapeAlign = 1;
boolean modoLinhaReativos = false;
boolean mostrarSimboloPrincipal = true;
boolean mostrarTipografiaPalavra = true;
int modoFormaManual = 0; // 0=auto, 1..4 forca forma especifica
int tipografiaVarianteAtiva = 0;

// GENERATIVE BRAND SYSTEM
MutableBrand activeBrand;
MutationParams mutationParams;
AudioData audioData;
GestureData gestureData;
boolean brandSystemEnabled = true;
String activeBrandName = "Nenhuma marca";

// TYPOGRAPHY
String nomeMarca = "Brand";
float[] desvioLetras, escalaLetras;
PFont fontHelv, fontHelvBold;
float pulso = 0;
PShape marcaSVG;
PImage marcaRaster;
PImage marcaRaster1b;
PImage marcaRaster2;
PImage marcaRaster2b;
PImage marcaRaster3;
PImage marcaRasterOutline;
PImage marcaRaster1bOutline;
PImage marcaRaster2Outline;
PImage marcaRaster2bOutline;
PImage marcaRaster3Outline;
String caminhoMarcaPNG = "";
String caminhoMarcaPNG1B = "";
String caminhoMarcaPNG2 = "";
String caminhoMarcaPNG2B = "";
String caminhoMarcaPNG3 = "";
String caminhoMarcaSVG = "";

// CONTROLS
float[][] sliders;
String[]  sliderLabels;
boolean[] sliderVisivel;
String[] sliderGrupoNomes = { "Som", "Marca", "Mutacao" };
int[][] sliderGrupoIndices = {
  { 26 },
  { 13, 14, 18, 20, 21, 24 },
  { 27, 28, 29, 30, 31, 32, 33, 34, 35 }
};
boolean[] sliderGrupoAberto = { true, true, true };
float[][] sliderGrupoCabecalho = new float[3][4];
boolean   salvarFlash = false;
int       salvarTimer = 0;
String    statusMessage = "";
float     dragSlider = -1;

// EXPORT
PGraphics exportLayer;
PGraphics videoLayer;
PGraphics panfletoMarcaLiveLayer;
int exportDurationSeconds = 5;
int exportFrameRate = 30;
int exportFrames = exportDurationSeconds * exportFrameRate;
boolean videoRecording = false;
boolean videoEncoding  = false;
int recordedFrames = 0;
String videoFolderName = "";
String ffmpegPath = "";
int exportScale = 2;
Process videoFFmpegProcess = null;
OutputStream videoFFmpegInput = null;
byte[] videoFrameBuffer = null;
String videoOutputPath = "";
float baseWidth = 1100.0;
float baseHeight = 680.0;
float espacamentoPalavra = 150;
float typoSize = 18;
float typoOffsetY = 0;
float typoReact = 12;
float typoWordOffsetExtra = 0;
float typoBaseWidthSolo = 520;
float typoBaseWidthWord = 760;
float typoTrailAlpha = 10;
float typoMainAlpha = 92;
float typoParGap = -12;
float typoParYOffset = 0;
float typoParXOffset = 0;
float typoVar2YOffsetA = 0;
float typoVar2YOffsetB = 0;
float padraoQtdFormas = 9;
float padraoEspacoX = 210;
float padraoEspacoY = 170;
float padraoEscala = 0.30;
float padraoRefX = 0;
float padraoRefY = 0;
float padraoDiagonal = 0;

// TREBLE FILAMENT (nova forma vermelha reativa)
ArrayList<Filament> filamentsModel = new ArrayList<Filament>();
int filamentsN = 280;
int onsetCount = 0;
float prevSBass = 0, prevSMid = 0, prevSTreble = 0, prevSPresence = 0;
float filTick = 0;
float filDisplay = 0;
float filHoldTimer = 0;
float filExplosion = 0;
int[] redPaletteHex = {
  0xFF2A0202, 0xFF6C0605, 0xFFA10F0A, 0xFFD61D10, 0xFFEE3A15,
  0xFFF45A1A, 0xFFFF7A22, 0xFFFF9C33, 0xFFFFBE4A
};

// BASS ORGANICO (forma verde)
ArrayList<BassVeinLayer> bassVeins = new ArrayList<BassVeinLayer>();
int bassLastSpawnMs = 0;
int bassStateUpdatedFrame = -1;
float bassSpawnEnergy = 0;
float bassPrevDrive = 0;

void buildFilamentsModel() {
  filamentsModel.clear();

  for (int i = 0; i < filamentsN; i++) {
    float t = i / float(filamentsN);
    float angle = t * TWO_PI + (hash1D(i, 3) - 0.5) * 0.38 + smoothNoise1D(t * 6.0, 7) * 0.22;
    float lenF = 0.42 + hash1D(i, 5) * 0.52 + smoothNoise1D(t * 4.3, 11) * 0.18;
    float thick = 0.35 + hash1D(i, 13) * 1.15;
    float curvDir = hash1D(i, 19) > 0.5 ? 1 : -1;
    float curvAmt = (0.18 + hash1D(i, 23) * 0.55) * curvDir;
    float tipT = 0.55 + hash1D(i, 31) * 0.42;
    float baseT = 0.05 + hash1D(i, 37) * 0.18;
    float alpha = 0.38 + hash1D(i, 41) * 0.58;
    float z = sin(angle);

    filamentsModel.add(new Filament(angle, lenF, thick, curvAmt, tipT, baseT, alpha, z, i, t));
  }

  filamentsModel.sort(new java.util.Comparator<Filament>() {
    public int compare(Filament a, Filament b) {
      return Float.compare(a.z, b.z);
    }
  });
}

void setup() {
  size(1100, 680, P2D);
  surface.setResizable(true);
  surface.setSize(1100, 680);
  pixelDensity(1);
  smooth(4);
  colorMode(HSB, 360, 100, 100, 100);
  frameRate(exportFrameRate);

  minim = new Minim(this);
  try {
    mic = minim.getLineIn(Minim.MONO, 1024);
    fft = new FFT(1024, mic.sampleRate());
    audioInputAvailable = true;
  } catch (Exception e) {
    mic = null;
    fft = null;
    audioInputAvailable = false;
    println("Entrada de audio indisponivel: " + e.getMessage());
  }

  atualizarLayout();
  ffmpegPath = sketchPath("tools/ffmpeg.exe");

  fontHelv     = carregarFonteInterface(64);
  fontHelvBold = fontHelv;
  interfaceLogo = null;
  audioData = new AudioData();
  gestureData = new GestureData();
  mutationParams = new MutationParams();
  for (int i = 0; i < playlistParams.length; i++) {
    playlistBrandNames[i] = "";
  }

  desvioLetras = new float[nomeMarca.length()];
  escalaLetras = new float[nomeMarca.length()];
  for (int i = 0; i < nomeMarca.length(); i++) {
    desvioLetras[i] = random(-2, 2);
    escalaLetras[i] = random(0.93, 1.07);
  }

  carregarMarcaPadraoInicial();
  if (activeBrand == null) {
    carregarMarcaSVG();
  }
  buildFilamentsModel();
  resetBassVeinsModel();

  configurarControles();
  mostrarStatus(audioInputAvailable ? "Eclode pronto" : "Sem microfone: mutacao manual ativa");
}

PFont carregarFonteInterface(float tamanho) {
  String[] candidatos = {
    "Montserrat-Regular.ttf",
    "Arial",
    "Segoe UI",
    "SansSerif"
  };
  for (int i = 0; i < candidatos.length; i++) {
    String candidato = candidatos[i];
    try {
      File arquivoFonte = new File(dataPath(candidato));
      if (arquivoFonte.exists()) {
        PFont fonte = createFont(arquivoFonte.getAbsolutePath(), tamanho, true);
        if (fonte != null) return fonte;
      }
    } catch (Exception e) {
      println("Fonte local indisponivel: " + candidato);
    }
    try {
      PFont fonte = createFont(candidato, tamanho, true);
      if (fonte != null) return fonte;
    } catch (Exception e) {
      println("Fonte do sistema indisponivel: " + candidato);
    }
  }
  return createFont("SansSerif", tamanho, true);
}

void draw() {
  if (width < 1100 || height < 680) {
    surface.setSize(max(width, 1100), max(height, 680));
    return;
  }
  colorMode(RGB, 255);
  background(red(UI_DARK), green(UI_DARK), blue(UI_DARK));
  processarMarcaPendente();
  atualizarAnimacao();
  atualizarAudio();
  atualizarEntradaGestual();
  atualizarMarcaMutavel();
  atualizarEstado();

  atualizarLayout();
  menuOffsetX = lerp(menuOffsetX, mostrarBarra ? 0 : -menuWidth, 0.18);

  renderShapeLayer(exportLayer, semente, tempoFlutua, faseFolego);
  image(exportLayer, 0, 0);
  desenharBarra();
  desenharColorPicker();
  atualizarExportacaoVideo();

  if (salvarFlash) {
    salvarTimer--;
    if (salvarTimer <= 0) {
      salvarFlash = false;
      statusMessage = "";
    }
  }
}
