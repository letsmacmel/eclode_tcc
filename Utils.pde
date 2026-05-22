void mostrarStatus(String message) {
  statusMessage = message;
  salvarFlash = true;
  salvarTimer = 120;
}

void windowResized() {
  atualizarLayout();
}

String timeStamp() {
  return year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
}
