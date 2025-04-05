import com.jogamp.opengl.*;
import com.jogamp.opengl.awt.GLCanvas;
import com.jogamp.opengl.util.Animator;
import java.nio.FloatBuffer;

PJOGL pgl;
GL4 gl;

String fragCode = "";

PShader rayTracer;
PShader shader;

PGraphics mainTexOld;
PGraphics mainTex;

Vector sunDir = Vector.normalize(new Vector(0,2,0.5));
Color sunColor = rgb(255*4);
float sunRadius = 0.3;
float sunBloomStrength = 0.5;

int shapeAttributes = (3*3+3+1+1+3+1+1+3+1+1+1+3*3);
int BVHAttributes = (3+3+2);

void loadShaders(ArrayList<String> names){
  for (String name : names){
    fragCode += "//------------------------------  "+name+"  ------------------------------\n";
    fragCode += join(loadStrings(name), "\n");
    fragCode += "\n//------------------------------  "+name+"  ------------------------------\n";
    fragCode += "\n\n\n";
  }
  String fragFilePath = sketchPath("shaders/combinedFragment.glsl");
  saveStrings(fragFilePath, new String[] { fragCode });

  // Load the Shader
  shader = loadShader(fragFilePath);
  shader.set("u_resolution", float(width), float(height));
}

void initShaderValues(Scene scene,int depth){
  ArrayList<FloatBuffer> buffers = scene.getBuffers(depth);
  pgl = (PJOGL)beginPGL();
  gl = pgl.gl.getGL4();
  int[] ssboId = new int[buffers.size()];
  gl.glGenBuffers(buffers.size(), ssboId, 0);
  for (int i=0;i<buffers.size();i++){
    FloatBuffer buffer = buffers.get(i);
    gl.glBindBuffer(GL4.GL_SHADER_STORAGE_BUFFER, ssboId[i]);  
    gl.glBufferData(GL4.GL_SHADER_STORAGE_BUFFER, buffer.capacity() * Float.BYTES, buffer, GL4.GL_STATIC_DRAW);
    gl.glBindBufferBase(GL4.GL_SHADER_STORAGE_BUFFER, i, ssboId[i]);    
  }
  endPGL();
  shader.set("mainBVHCount",buffers.get(2).capacity());
}

void updateShaderValues(){  
  shader.set("pos", cam.pos.x,cam.pos.y,cam.pos.z);
  shader.set("povCenter", cam.povCenter.x,cam.povCenter.y,cam.povCenter.z);
  shader.set("horizontalDirScreen", cam.horizontalDirScreen.x,cam.horizontalDirScreen.y,cam.horizontalDirScreen.z);
  shader.set("verticalDirScreen", cam.verticalDirScreen.x,cam.verticalDirScreen.y,cam.verticalDirScreen.z);
  shader.set("frame",frameCount);
  shader.set("sunDir",sunDir.x,sunDir.y,sunDir.z);
  shader.set("sunColor",sunColor.r,sunColor.g,sunColor.b);
  shader.set("sunRadius",sunRadius);
  shader.set("sunBloomStrength",sunBloomStrength);
}
