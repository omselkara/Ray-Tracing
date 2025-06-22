import java.nio.*;

int hdrWidth = -1, hdrHeight = -1;

FloatBuffer loadHDRtoFloatBuffer(String path) {  
  byte[] bytes = loadBytes(path);
  int pos = 0;

  while (pos < bytes.length-1) {
    if (bytes[pos] == '\n' && bytes[pos+1] == '\n') {
      pos += 2;
      break;
    }
    pos++;
  }

  StringBuilder sb = new StringBuilder();
  while (bytes[pos] != '\n') sb.append((char)bytes[pos++]);
  pos++;
  String[] tokens = sb.toString().trim().split("\\s+");
  for (int i = 0; i < tokens.length-1; i+=2) {
    if      (tokens[i].equals("-Y")) hdrHeight = Integer.parseInt(tokens[i+1]);
    else if (tokens[i].equals("+Y")) hdrHeight = Integer.parseInt(tokens[i+1]);
    else if (tokens[i].equals("+X")) hdrWidth  = Integer.parseInt(tokens[i+1]);
    else if (tokens[i].equals("-X")) hdrWidth  = Integer.parseInt(tokens[i+1]);
  }

  FloatBuffer buffer = ByteBuffer.allocateDirect(hdrWidth * hdrHeight * 3 * 4)
                          .order(ByteOrder.nativeOrder())
                          .asFloatBuffer();

  for (int y = 0; y < hdrHeight; y++) {
    if ((bytes[pos++] & 0xFF) != 2 || (bytes[pos++] & 0xFF) != 2) {
      println("Unsupported scanline encoding");
      break;
    }
    int scanW = ((bytes[pos++] & 0xFF) << 8) | (bytes[pos++] & 0xFF);
    if (scanW != hdrWidth) {
      println("Scanline width mismatch");
      break;
    }

    int[][] channel = new int[4][hdrWidth];
    for (int c = 0; c < 4; c++) {
      int x = 0;
      while (x < hdrWidth) {
        int count = bytes[pos++] & 0xFF;
        if (count > 128) {
          int run = count - 128;
          int value = bytes[pos++] & 0xFF;
          for (int i = 0; i < run; i++) channel[c][x++] = value;
        } else {
          for (int i = 0; i < count; i++) channel[c][x++] = bytes[pos++] & 0xFF;
        }
      }
    }

    for (int x = 0; x < hdrWidth; x++) {
      int r = channel[0][x];
      int g = channel[1][x];
      int b = channel[2][x];
      int e = channel[3][x];

      if (e != 0) {
        float f = pow(2.0, e - (128 + 8));
        buffer.put(r * f);
        buffer.put(g * f);
        buffer.put(b * f);
      } else {
        buffer.put(0);
        buffer.put(0);
        buffer.put(0);
      }
    }
  }

  buffer.rewind();
  return buffer;
}
