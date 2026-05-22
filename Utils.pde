void mostrarStatus(String message) {
  statusMessage = message;
  salvarFlash = true;
  salvarTimer = 120;
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
