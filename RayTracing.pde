ArrayList<Character> downKeys;
Camera cam;

int count = 0;
float totalFrameRate = 0;
float time = 0;

Scene scene;

PShader correcter;


void setup() {
  frameRate(1000);
  scene = new Scene();
  downKeys = new ArrayList<>();
  cam = new Camera(new Vector(14.633389 ,-4.374190 ,13.297768),2.53,2.05);
  
  size(1280,720,P3D);
  //fullScreen(P3D);
  mainTex = createGraphics(width, height, P3D);
  mainTexOld = createGraphics(width, height, P3D);
  
  ArrayList<String> shaders = new ArrayList<>();
  shaders.add("shaders/structs.glsl");
  shaders.add("shaders/funcs.glsl");
  shaders.add("shaders/camera.glsl");
  shaders.add("shaders/shape.glsl");
  shaders.add("shaders/ray.glsl");
  shaders.add("shaders/shader.glsl");
  checker = loadShader("shaders/checker.glsl");
  imageShader = loadShader("shaders/image.glsl");
  correcter = loadShader("shaders/correcter.glsl");
  
  loadShaders(shaders);
  background(0);
  
  rayTracer = loadShader("shaders/rayTracer.glsl");  
  rayTracer.set("u_resolution", float(width), float(height));
  correcter.set("u_resolution", float(width), float(height));
    
  shader.set("reflectCount",3);
  shader.set("rayCount",100);
  shader.set("blurStrength",2.0);
  shader.set("showAmbientLight",true);
  time = millis();
}



void draw() {
if (frameCount==2){
    
    cam = new Camera(new Vector(5.3,1.6,-2.8),-0.866,1.92);
  
    Material ground = new Material();
    ground.col = getConstantColor(new Color(0.5));
    
    Material mat1 = new Material();
    mat1.col = getConstantColor(rgb(255));
    mat1.dielectric = 1.5;
    
    Material mat2 = new Material();
    mat2.col = getConstantColor(new Color(0.4,0.2,0.1));
    
    Material mat3 = new Material();
    mat3.col = getConstantColor(new Color(0.7,0.6,0.5));
    mat3.specularColor = new Color(0.7,0.6,0.5);
    mat3.smoothness = 1.0;
    mat3.specularChance = 1.0;
    
    BVHNode node = new BVHNode();
    node.shapes.add(new Sphere(new Vector(0,-1000,0),ground,1000));
    node.shapes.add(new Sphere(new Vector(0,1,0),mat1,1));
    node.shapes.add(new Sphere(new Vector(-4,1,0),mat2,1));
    node.shapes.add(new Sphere(new Vector(4,1,0),mat3,1));
    
    for (int a=-11;a<11;a++){
      for (int b=-11;b<11;b++){
        float matType = random(0,1);
        Vector center = new Vector(a+0.9*random(0,1),0.2,b+0.9*random(0,1));
        if (Vector.distance(center,new Vector(4,0.2,0))>0.9){
          Material mat = new Material();
          if (matType<0.8){
            Color col = new Color(random(0,1)*random(0,1),random(0,1)*random(0,1),random(0,1)*random(0,1));
            mat.col = getConstantColor(col);
            mat.smoothness = random(0.75,1);
            mat.specularChance = random(0,0.2);
            mat.specularColor = col;
          }
          else if (matType<0.95){
            Color col = new Color(random(0.5,1),random(0.5,1),random(0.5,1));
            mat.col = getConstantColor(col);
            mat.specularColor = col;
            mat.smoothness = random(0,0.5);
            mat.specularChance = 1.0;
          }
          else{
            mat.col = getConstantColor(rgb(255));
            mat.dielectric = 1.5;
          }
          node.shapes.add(new Sphere(center,mat,0.2));
        }
      }
    }
    scene.nodes.add(node);    
    initShaderValues(scene,32);
    reset();
  }
  background(0);
  updateShaderValues();     
  mainTex.beginDraw();
  mainTex.shader(shader);
  mainTex.rect(0, 0, width, height);
  mainTex.resetShader();
  mainTex.endDraw();
  
  rayTracer.set("MainTexOld",mainTexOld);
  rayTracer.set("MainTex",mainTex);
  
  rayTracer.set("numRenderedFrames",(float)count);
  
  mainTexOld.beginDraw();
  mainTexOld.shader(rayTracer);
  mainTexOld.rect(0, 0, width, height);
  mainTexOld.resetShader();
  mainTexOld.endDraw();
  count++;
  
  correcter.set("MainTexOld",mainTexOld);  
  shader(correcter);
  rect(0,0,width,height);
  resetShader();
  
  fill(255);
  textSize(30);
  textAlign(LEFT, TOP);
  text(String.format("FPS:%.1f",frameRate),5,0);
  float x = 0;
  float y = 0;
  float z = 0;
  for (char i : downKeys) {
    if (i=='w') {
      z += 1;
    } else if (i=='s') {
      z -= 1;
    } else if (i=='a') {
      x -= 1;
    } else if (i=='d') {
      x += 1;
    } else if (i=='e') {
      y -= 1;
    } else if (i=='q') {
      y += 1;
    }
    if (i==' '){
      reset();
    }
  }
  if (x != 0 || y != 0 || z != 0) {
    cam.moveX(x);
    cam.moveY(y);
    cam.moveZ(z);
    cam.update();
    reset();
    println(cam.pos);
    println(cam.angleX);
    println(cam.angleY);
  }
  deltatime = min(1f/frameRate,0.05);
  totalFrameRate += frameRate;
  float avg = totalFrameRate/(count);
  text(String.format("AVG:%.1f",avg),5,30);
  text(String.format("SECOND:%.1f",((float)millis()-time)/1000.0),5,60);
  
}

void keyPressed() {
  downKeys.add(key);
}

void keyReleased() {
  for (int i=0; i<downKeys.size(); i++) {
    if (downKeys.get(i)==key) {
      downKeys.remove(i);
      break;
    }
  }
}

void reset(){
  count = 0;
  totalFrameRate = 0;
  mainTexOld.beginDraw();
  mainTexOld.fill(0,0,0);
  mainTexOld.rect(0,0,width,height);
  mainTexOld.endDraw();
  time = millis();
}

void mouseDragged() {
  float dx = mouseX-pmouseX;
  float dy = mouseY-pmouseY;
  cam.rotateX(dx/720f);
  cam.rotateY(dy/720.0);
  cam.update();
  reset();
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  povDst -= e/10.0;
  povDst = max(0.70,min(povDst,2.5));
  cam.update();
  reset();
}
