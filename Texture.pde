PShader checker;
PShader imageShader;

PImage getCheckerTexture(Color col1,Color col2,float u,float v,float offsetX,float offsetY,int width,int height){
  checker.set("u_resolution", float(width), float(height));
  checker.set("col1",col1.r,col1.g,col1.b);
  checker.set("col2",col2.r,col2.g,col2.b);
  checker.set("uv",u,v);
  checker.set("offset",offsetX,offsetY);
  PGraphics pg = createGraphics(width, height, P2D);
  pg.beginDraw();
  pg.background(0);
  pg.shader(checker);
  pg.rect(0,0,width,height);
  pg.endDraw();
  return pg;
}

PImage getConstantColor(Color col){
  PImage pg = createImage(1, 1, RGB);
  pg.set(0,0,col.getColor());
  return pg;
}

PImage getImageTexture(String path,float offsetX,float offsetY){
  PImage img = loadImage(path);
  imageShader.set("u_resolution", float(img.width), float(img.height));
  imageShader.set("tex",img);
  imageShader.set("offset",offsetX,offsetY);
  PGraphics pg = createGraphics(img.width, img.height, P2D);
  pg.beginDraw();
  pg.background(0);
  pg.shader(imageShader);
  pg.rect(0,0,img.width,img.height);
  pg.endDraw();
  return pg;
}
