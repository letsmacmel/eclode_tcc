void mostrarStatus(String message) {
  statusMessage = message;
  salvarFlash = true;
  salvarTimer = 120;
}

float canalR(int c) {
  return (c >> 16) & 0xFF;
}

float canalG(int c) {
  return (c >> 8) & 0xFF;
}

float canalB(int c) {
  return c & 0xFF;
}

float canalA(int c) {
  return (c >>> 24) & 0xFF;
}

int corHSBA(float h, float s, float b, float a) {
  float hh = ((h % 360.0) + 360.0) % 360.0;
  int rgb = java.awt.Color.HSBtoRGB(hh / 360.0, constrain(s / 100.0, 0, 1), constrain(b / 100.0, 0, 1));
  int aa = constrain(round(a / 100.0 * 255.0), 0, 255);
  return (aa << 24) | (rgb & 0x00FFFFFF);
}

int corRGBA255(float r, float g, float b, float a) {
  int rr = constrain(round(r), 0, 255);
  int gg = constrain(round(g), 0, 255);
  int bb = constrain(round(b), 0, 255);
  int aa = constrain(round(a), 0, 255);
  return (aa << 24) | (rr << 16) | (gg << 8) | bb;
}

int corInterfacePaleta(int idx) {
  int i = ((idx % 4) + 4) % 4;
  if (i == 0) return UI_LIGHT;
  if (i == 1) return UI_GREEN;
  if (i == 2) return UI_BROWN;
  return UI_DARK;
}

int corInterfacePaletaPorT(float t) {
  return corInterfacePaleta(floor(constrain(t, 0, 0.9999) * 4.0));
}

void windowResized() {
  atualizarLayout();
}

String timeStamp() {
  return year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
}
