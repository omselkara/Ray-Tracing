import java.awt.Shape;
import java.io.FileReader;
import java.util.Arrays;
import java.util.List;

ArrayList<Character> downKeys;

int count = 0;
float totalFrameRate = 0;
float time = 0;

boolean preparedData = false;
boolean finishedSetup = false;
boolean loadedTheModel = false;
String loadingModelName = "None";

boolean showStats = false;

int imageIndex = 0;

Scene scene;

Vector center = new Vector(0);
float deltaFrameTime = 40;
float totalVideoTime = 21600;
float deltaAngle = 2*PI*deltaFrameTime/totalVideoTime;
float rotationRadius = 11;

void setup() {
  frameRate(1000);
  scene = new Scene();
  downKeys = new ArrayList<>();
  scene.cam = new Camera(new Vector(center.x+rotationRadius,-5,center.z),-PI/2.0,PI/1.75);
  size(1280, 720, P2D);
  //fullScreen(P3D);
  pgl = (PJOGL)beginPGL();
  gl = pgl.gl.getGL4();

  ArrayList<String> shaders = new ArrayList<>();
  shaders.add("shaders/structs.glsl");
  shaders.add("shaders/funcs.glsl");
  shaders.add("shaders/camera.glsl");
  shaders.add("shaders/shape.glsl");
  shaders.add("shaders/ray.glsl");
  shaders.add("shaders/rayTracer.glsl");
  checker = loadShader("shaders/checker.glsl");
  imageShader = loadShader("shaders/image.glsl");

  loadShaders(shaders);
  background(0);

  shader = loadShader("shaders/shader.glsl");
  shader.set("u_resolution", float(width), float(height));

  gl.glUseProgram(computeProgram);
  gl.glUniform1i(gl.glGetUniformLocation(computeProgram, "reflectCount"), 10);
  gl.glUniform1i(gl.glGetUniformLocation(computeProgram, "rayCount"), 1);
  gl.glUniform1f(gl.glGetUniformLocation(computeProgram, "blurStrength"), 2.0);
  gl.glUniform1i(gl.glGetUniformLocation(computeProgram, "showAmbientLight"), 1);
  time = millis();
  thread("setupScene");
  
}



void draw() {
  background(0);
  if (!finishedSetup) {
    background(0);
    textAlign(CENTER, CENTER);
    textSize(60);
    if (loadedTheModel) {
      text("Calculating BVH", width/2.0, height/2.0);
      text(String.format("%d", scene.splittedNodes.size()), width/2, height/2+60);
    } else {
      text("Loading the Model", width/2.0, height/2.0);
      text(loadingModelName, width/2, height/2+60);
    }
    if (preparedData) {
      initShaderValues(scene);
      finishedSetup = true;
      reset();
    }
  } else {
    updateShaderValues();
    runComputeShader();
    count++;

    shader(shader);
    rect(0, 0, width, height);
    resetShader();

    handleKeys();
    
        
    
    
    if ((millis()-time)/1000.0 >= deltaFrameTime){
      //saveFrame("images/frame"+imageIndex+".png");      
      imageIndex++;
      time = millis();
      float x = center.x+rotationRadius*cos(deltaAngle*imageIndex);
      float y = scene.cam.pos.y;
      float z = center.z+rotationRadius*sin(deltaAngle*imageIndex);
      scene.cam.pos.x = x;
      scene.cam.pos.y = y;
      scene.cam.pos.z = z;
      scene.cam.rotateX(-deltaAngle);
      scene.cam.update();
      scene.updateCameraValuesShader();
      reset();
      println(imageIndex/(totalVideoTime/deltaFrameTime)*100);
    }

    deltatime = min(1f/frameRate, 0.05);
    totalFrameRate += frameRate;
    if (showStats) {
      fill(255);
      textSize(30);
      textAlign(LEFT, TOP);
      float avg = totalFrameRate/(count);

      text(String.format("FPS:%.1f", frameRate), 5, 0);
      text(String.format("AVG:%.1f", avg), 5, 30);
      text(String.format("SECOND:%.1f", ((float)millis()-time)/1000.0), 5, 60);
    }
  }
}

void keyPressed() {
  if (finishedSetup) {
    downKeys.add((""+key).toLowerCase().charAt(0));
  }
  if (key=='r' || key=='R') {
    showStats = !showStats;
  }
}

void keyReleased() {
  if (finishedSetup) {
    for (int i=0; i<downKeys.size(); i++) {
      if (downKeys.get(i)==(""+key).toLowerCase().charAt(0)) {
        downKeys.remove(i);
        break;
      }
    }
  }
}

void reset() {
  if (finishedSetup) {
    count = 0;
    totalFrameRate = 0;
    gl.glBindBuffer(GL4.GL_SHADER_STORAGE_BUFFER, ssboId[ssboId.length-1]);
    gl.glClearBufferData(
      GL4.GL_SHADER_STORAGE_BUFFER,
      GL4.GL_R32F,
      GL4.GL_RED,
      GL4.GL_FLOAT,
      null
      );
    time = millis();
  }
}

void mouseDragged() {
  if (finishedSetup) {
    float dx = mouseX-pmouseX;
    float dy = mouseY-pmouseY;
    scene.cam.rotateX(dx/720f);
    scene.cam.rotateY(dy/720.0);
    scene.cam.update();
    scene.updateCameraValuesShader();
    reset();
  }
}

void mouseWheel(MouseEvent event) {
  if (finishedSetup) {
    float e = event.getCount();
    povDst -= e/10.0;
    povDst = max(0.70, min(povDst, 2.5));
    scene.cam.update();
    scene.updateCameraValuesShader();
    reset();
  }
}

void handleKeys() {
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
    if (i==' ') {
      reset();
    }
  }
  if (x != 0 || y != 0 || z != 0) {
    scene.cam.moveX(x);
    scene.cam.moveY(y);
    scene.cam.moveZ(z);
    scene.cam.update();
    scene.updateCameraValuesShader();
    reset();
    if (showStats) {
      println(scene.cam.pos);
      println(scene.cam.angleX);
      println(scene.cam.angleY);
    }
  }
}

void setupScene() {
  float time = millis();
  List<Shape> shapes = new ArrayList<>();  

  Material mat = new Material();
  mat.smoothness = 1;
  mat.specularChance = 0.1;
  mat.col = rgb(0,0,255);
  addModel("models/Monkey.obj", new Vector(0, -4), new Vector(4), new Vector(0,PI/2,0),mat, shapes, false);
  
  BVHNode node = new BVHNode(shapes);
  scene.nodes.add(node);

  println("Loading Took: ", millis()-time);
  Material matLeft = new Material();
  matLeft.col = rgb(200);
  matLeft.smoothness = 1;
  matLeft.specularChance = 0.3;
  matLeft.specularColor = rgb(255);
  Material matRight = new Material();
  matRight.col = rgb(50, 50, 255);
  matRight.smoothness = 1;
  matRight.specularChance = 0.995;
  matRight.specularColor = rgb(50, 50, 255);
  Material matTop = new Material();
  matTop.col = rgb(255);
  matTop.smoothness = 1;
  matTop.specularChance = 0.995;
  matTop.specularColor = rgb(255);
  Material matBottom = new Material();
  matBottom.col = rgb(50, 255, 50);
  matBottom.smoothness = 1;
  matBottom.specularChance = 0.995;
  matBottom.specularColor = rgb(50, 255, 50);
  Material matFront = new Material();
  matFront.col = rgb(120,255,50);
  matFront.smoothness = 1;
  matFront.specularChance = 0.995;
  matFront.specularColor = rgb(120,255,50);
  Material matRear = new Material();
  matRear.col = rgb(255,50,50);
  matRear.smoothness = 1;
  matRear.specularChance = 0.995;
  matRear.specularColor = rgb(255,50,50);
  Material light = new Material();
  light.col = rgb(0);
  light.lightCol = rgb(255);
  light.isLight = 3;

  
  List<Shape> roomShapes = new ArrayList<>();
  
  float x1 = -30;
  float x2 = 30;
  float y1 = -10;
  float y2 = 10;
  float z1 = -30;
  float z2 = 30;

  addRectangle(new Vector(x1, y1, z2), new Vector(x1, y1, z1), new Vector(x1, y2, z1), new Vector(x1, y2, z2), matLeft, roomShapes);
  addRectangle(new Vector(x2, y2, z2), new Vector(x2, y2, z1), new Vector(x2, y1, z1), new Vector(x2, y1, z2), matLeft, roomShapes);
  addRectangle(new Vector(x1, y2, z2), new Vector(x1, y2, z1), new Vector(x2, y2, z1), new Vector(x2, y2, z2), matLeft, roomShapes);
  addRectangle(new Vector(x2, y1, z2), new Vector(x2, y1, z1), new Vector(x1, y1, z1), new Vector(x1, y1, z2), matLeft, roomShapes);
  addRectangle(new Vector(x1, y2, z2), new Vector(x2, y2, z2), new Vector(x2, y1, z2), new Vector(x1, y1, z2), matLeft, roomShapes);
  addRectangle(new Vector(x1, y1, z1), new Vector(x2, y1, z1), new Vector(x2, y2, z1), new Vector(x1, y2, z1), matLeft, roomShapes);
  
  for (int z=0;z<60;z+=20){
    for (int x=0;x<60;x+=20){
      addRectangle(new Vector(-25+x, +9.75, -25+z), new Vector(-25+x, +9.75, -20+z), new Vector(-20+x, +9.75, -20+z), new Vector(-20+x, +9.75, -25+z), light, roomShapes);
    }
  }
  
  
  
  BVHNode roomNode = new BVHNode(roomShapes);
  //roomNode.dontSplit = true;
  scene.nodes.add(roomNode);
  loadedTheModel = true;


  scene.splitNodes(32);
  preparedData = true;
  
}
