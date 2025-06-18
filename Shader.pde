import com.jogamp.opengl.*;
import com.jogamp.opengl.awt.GLCanvas;
import com.jogamp.opengl.util.Animator;
import java.nio.FloatBuffer;

PJOGL pgl;
GL4 gl;

String fragCode = "";
String[] computeShaderCodes;

PShader shader;

int computeProgram;

Vector sunDir = Vector.normalize(new Vector(0,2,0.5));
Color sunColor = rgb(255*4);
float sunRadius = 0.3;
float sunBloomStrength = 0.5;

int[] ssboId;

int shapeAttributes = 30;
int BVHAttributes = 8;

void loadShaders(ArrayList<String> names){
  computeShaderCodes = new String[names.size()];
  int index = 0;
  for (String name : names){
    String file = join(loadStrings(name), "\n");
    fragCode += "//------------------------------  "+name+"  ------------------------------\n";
    fragCode += file;
    fragCode += "\n//------------------------------  "+name+"  ------------------------------\n";
    fragCode += "\n\n\n";
    computeShaderCodes[index] = file;
    index++;
  }
  String fragFilePath = sketchPath("shaders/combinedFragment.glsl");
  saveStrings(fragFilePath, new String[] { fragCode });

  computeProgram = createComputeShader();
  gl.glUseProgram(computeProgram);
  gl.glUniform2f(gl.glGetUniformLocation(computeProgram, "u_resolution"), width, height);
}

int createComputeShader() {
  
  int shader = gl.glCreateShader(GL4.GL_COMPUTE_SHADER);
  gl.glShaderSource(shader, computeShaderCodes.length, computeShaderCodes, null);
  gl.glCompileShader(shader);
  
  int[] compileStatus = new int[1];
  gl.glGetShaderiv(shader, GL4.GL_COMPILE_STATUS, compileStatus, 0);
  if (compileStatus[0] == GL4.GL_FALSE) {
    int[] logLength = new int[1];
    gl.glGetShaderiv(shader, GL4.GL_INFO_LOG_LENGTH, logLength, 0);
    
    byte[] log = new byte[logLength[0]];
    gl.glGetShaderInfoLog(shader, logLength[0], (int[])null, 0, log, 0);
    
    println("Shader compilation failed: " + new String(log));
    exit();
  }

  int program = gl.glCreateProgram();
  gl.glAttachShader(program, shader);
  gl.glLinkProgram(program);

  int[] linkStatus = new int[1];
  gl.glGetProgramiv(program, GL4.GL_LINK_STATUS, linkStatus, 0);
  if (linkStatus[0] == GL4.GL_FALSE) {
    int[] logLength = new int[1];
    gl.glGetProgramiv(program, GL4.GL_INFO_LOG_LENGTH, logLength, 0);
    
    byte[] log = new byte[logLength[0]];
    gl.glGetProgramInfoLog(program, logLength[0], (int[])null, 0, log, 0);
    
    println("Program linking failed: " + new String(log));
    exit();
  }
  
  return program;
}

void runComputeShader() {
  gl.glUseProgram(computeProgram);
  int localSizeX = 16;
  int localSizeY = 16;
  
  int groupCountX = (width + localSizeX - 1) / localSizeX;
  int groupCountY = (height + localSizeY - 1) / localSizeY;
  gl.glDispatchCompute(groupCountX, groupCountY, 1);
  gl.glMemoryBarrier(GL4.GL_SHADER_STORAGE_BARRIER_BIT);
}

void initShaderValues(Scene scene){
  ArrayList<FloatBuffer> buffers = scene.getBuffers();  
  ssboId = new int[buffers.size()+1];
  gl.glGenBuffers(buffers.size()+1, ssboId, 0);
  for (int i=0;i<buffers.size();i++){
    FloatBuffer buffer = buffers.get(i);
    gl.glBindBuffer(GL4.GL_SHADER_STORAGE_BUFFER, ssboId[i]);  
    gl.glBufferData(GL4.GL_SHADER_STORAGE_BUFFER, buffer.capacity() * Float.BYTES, buffer, GL4.GL_STATIC_DRAW);
    gl.glBindBufferBase(GL4.GL_SHADER_STORAGE_BUFFER, i, ssboId[i]);    
  }
  FloatBuffer pixelBUffer = FloatBuffer.allocate(width * height * 4);
  gl.glBindBuffer(GL4.GL_SHADER_STORAGE_BUFFER, ssboId[ssboId.length-1]);
  gl.glBufferData(GL4.GL_SHADER_STORAGE_BUFFER, pixelBUffer.capacity() * Float.BYTES, pixelBUffer, GL4.GL_DYNAMIC_COPY);
  gl.glBindBufferBase(GL4.GL_SHADER_STORAGE_BUFFER, ssboId.length-1, ssboId[ssboId.length-1]);
  endPGL();
  
  gl.glUseProgram(computeProgram);
  gl.glUniform1i(gl.glGetUniformLocation(computeProgram, "mainBVHCount"), buffers.get(2).capacity());
  gl.glUniform3f(gl.glGetUniformLocation(computeProgram, "sunDir"), sunDir.x,sunDir.y,sunDir.z);
  gl.glUniform3f(gl.glGetUniformLocation(computeProgram, "sunColor"), sunColor.r,sunColor.g,sunColor.b);
  gl.glUniform1f(gl.glGetUniformLocation(computeProgram, "sunRadius"), sunRadius);
  gl.glUniform1f(gl.glGetUniformLocation(computeProgram, "sunBloomStrength"), sunBloomStrength);
  scene.updateCameraValuesShader();
  scene.splittedNodes = null;
  scene.nodes = null;
  buffers = null;
  
}

void updateShaderValues(){  
  gl.glUseProgram(computeProgram);
  gl.glUniform1i(gl.glGetUniformLocation(computeProgram, "frame"), frameCount);
  
}
