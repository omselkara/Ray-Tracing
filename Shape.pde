class Shape {
  Vector vec1, vec2, vec3;
  Vector center;
  Vector normal1 = new Vector(0);
  Vector normal2 = new Vector(0);
  Vector normal3 = new Vector(0);
  Vector minPos, maxPos;
  Material material = new Material();

  Shape(Vector vec1, Vector vec2, Vector vec3) {
    this.vec1 = vec1;
    this.vec2 = vec2;
    this.vec3 = vec3;
    calculateCenter();
    minPos = new Vector(
      min(vec1.x, vec2.x, vec3.x),
      min(vec1.y, vec2.y, vec3.y),
      min(vec1.z, vec2.z, vec3.z));

    maxPos = new Vector(
      max(vec1.x, vec2.x, vec3.x),
      max(vec1.y, vec2.y, vec3.y),
      max(vec1.z, vec2.z, vec3.z));
  }

  void calculateCenter() {
    center = new Vector((vec1.x+vec2.x+vec3.x)/3f, (vec1.y+vec2.y+vec3.y)/3f, (vec1.z+vec2.z+vec3.z)/3f);
  }

  void calculateNormal() {
    this.normal1 = Vector.normalize(Vector.cross(Vector.substract(vec2, vec1), Vector.substract(vec3, vec2)));
    this.normal2 = Vector.normalize(Vector.cross(Vector.substract(vec2, vec1), Vector.substract(vec3, vec2)));
    this.normal3 = Vector.normalize(Vector.cross(Vector.substract(vec2, vec1), Vector.substract(vec3, vec2)));
  }
}

float[][] createRotationMatrix(float angleX, float angleY, float angleZ) {
  float[][] rotateX = {
    {1, 0, 0},
    {0, cos(angleX), -sin(angleX)},
    {0, sin(angleX), cos(angleX)}
  };

  float[][] rotateY = {
    {cos(angleY), 0, sin(angleY)},
    {0, 1, 0},
    {-sin(angleY), 0, cos(angleY)}
  };

  float[][] rotateZ = {
    {cos(angleZ), -sin(angleZ), 0},
    {sin(angleZ), cos(angleZ), 0},
    {0, 0, 1}
  };

  return multiplyMatrices(rotateZ, multiplyMatrices(rotateY, rotateX));
}

float[][] multiplyMatrices(float[][] a, float[][] b) {
  float[][] result = new float[3][3];
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      result[i][j] = 0;
      for (int k = 0; k < 3; k++) {
        result[i][j] += a[i][k] * b[k][j];
      }
    }
  }
  return result;
}

float[] getVectorFloat(String line) {
  String[] values = line.split(" ");
  float[] array = new float[values.length];
  for (int i=0; i<values.length; i++) {
    array[i] = Float.parseFloat(values[i]);
  }
  return array;
}

Color getColor(String line) {
  String[] values = line.split(" ");
  return new Color(Float.parseFloat(values[1]), Float.parseFloat(values[2]), Float.parseFloat(values[3]));
}

void addModel(String modelName, Vector pos, Vector scale, Vector orient, List<Shape> shapes) {
  loadingModelName = modelName;
  float[][] rotationMatrix = createRotationMatrix(orient.x, orient.y, orient.z);

  try {
    BufferedReader reader = new BufferedReader(new FileReader(modelName));
    List<Vector> vertices = new ArrayList<>();
    List<Vector> normals = new ArrayList<>();
    HashMap<String, Material> materials = new HashMap<>();
    Material mat = new Material();
    mat.col = rgb(255);

    String line;
    while ((line = reader.readLine()) != null) {
      if (line.startsWith("usemtl ")) {
        mat = materials.get(line.split(" ")[1]);
      } else if (line.startsWith("v ")) {
        float[] vertex = getVectorFloat(line.substring(2, line.length()));
        Vector position = new Vector(
          pos.x+scale.x*(rotationMatrix[0][0] * -vertex[0] + rotationMatrix[0][1] * vertex[1] + rotationMatrix[0][2] * vertex[2]),
          pos.y+scale.y*(rotationMatrix[1][0] * -vertex[0] + rotationMatrix[1][1] * vertex[1] + rotationMatrix[1][2] * vertex[2]),
          pos.z+scale.z*(rotationMatrix[2][0] * -vertex[0] + rotationMatrix[2][1] * vertex[1] + rotationMatrix[2][2] * vertex[2]));
        vertices.add(position);
      } else if (line.startsWith("vn ")) {
        float[] normal = getVectorFloat(line.substring(3, line.length()));
        Vector normal1 = new Vector(
          rotationMatrix[0][0] * -normal[0] + rotationMatrix[0][1] * normal[1] + rotationMatrix[0][2] * normal[2],
          rotationMatrix[1][0] * -normal[0] + rotationMatrix[1][1] * normal[1] + rotationMatrix[1][2] * normal[2],
          rotationMatrix[2][0] * -normal[0] + rotationMatrix[2][1] * normal[1] + rotationMatrix[2][2] * normal[2]);
        normals.add(normal1);
      } else if (line.startsWith("f ")) {
        String[] tokens = line.split(" ");
        String[] token1 = tokens[1].split("/");
        String[] token2 = tokens[2].split("/");
        String[] token3 = tokens[3].split("/");
        int vert1 = Integer.parseInt(token1[0]) - 1;
        int vert2 = Integer.parseInt(token2[0]) - 1;
        int vert3 = Integer.parseInt(token3[0]) - 1;
        int norm1 = Integer.parseInt(token1[2]) - 1;
        int norm2 = Integer.parseInt(token2[2]) - 1;
        int norm3 = Integer.parseInt(token3[2]) - 1;

        Shape shape = new Shape(vertices.get(vert3), vertices.get(vert2), vertices.get(vert1));
        shape.normal1 = normals.get(norm3);
        shape.normal2 = normals.get(norm2);
        shape.normal3 = normals.get(norm1);
        shape.material = mat;
        shapes.add(shape);
      } else if (line.startsWith("mtllib ")) {
        try {
          int slashIndex = modelName.lastIndexOf("/");
          String mtlName = line.split(" ")[1];
          if (slashIndex!=-1) {
            mtlName = modelName.substring(0, slashIndex+1)+mtlName;
          }

          BufferedReader materialReader = new BufferedReader(new FileReader(mtlName));

          String materialLine;
          Material newMat = null;
          String matName = null;
          while ((materialLine = materialReader.readLine()) != null) {
            if (materialLine.startsWith("newmtl ")) {
              if (newMat != null) {
                materials.put(matName, newMat);
              }

              matName = materialLine.split(" ")[1];
              newMat = new Material();
            } else if (materialLine.startsWith("col ")) {
              newMat.col = getColor(materialLine);
            } else if (materialLine.startsWith("Kd ")) {
              newMat.col = getColor(materialLine);
            }else if (materialLine.startsWith("lightCol ")) {
              newMat.lightCol = getColor(materialLine);
            } else if (materialLine.startsWith("isLight ")) {
              newMat.isLight = Float.parseFloat(materialLine.split(" ")[1]);
            } else if (materialLine.startsWith("smoothness ")) {
              newMat.smoothness = Float.parseFloat(materialLine.split(" ")[1]);
            } else if (materialLine.startsWith("specularChance ")) {
              newMat.specularChance = Float.parseFloat(materialLine.split(" ")[1]);
            } else if (materialLine.startsWith("specularColor ")) {
              newMat.specularColor = getColor(materialLine);
            } else if (materialLine.startsWith("dielectric ")) {
              newMat.dielectric = Float.parseFloat(materialLine.split(" ")[1]);
            }
          }
          if (newMat != null) {
            materials.put(matName, newMat);
          }
        }
        catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

void addModel(String modelName, Vector pos, Vector scale, Vector orient, Material originalMat, List<Shape> shapes, boolean useFileColor) {
  loadingModelName = modelName;
  float[][] rotationMatrix = createRotationMatrix(orient.x, orient.y, orient.z);

  try {
    BufferedReader reader = new BufferedReader(new FileReader(modelName));
    List<Vector> vertices = new ArrayList<>();
    List<Vector> normals = new ArrayList<>();
    HashMap<String, Material> materials = new HashMap<>();
    Material mat = new Material();
    mat.col = rgb(255);

    String line;
    while ((line = reader.readLine()) != null) {
      if (line.startsWith("usemtl ")) {
        mat = materials.get(line.split(" ")[1]);
      } else if (line.startsWith("v ")) {
        float[] vertex = getVectorFloat(line.substring(2, line.length()));
        Vector position = new Vector(
          pos.x+scale.x*(rotationMatrix[0][0] * -vertex[0] + rotationMatrix[0][1] * vertex[1] + rotationMatrix[0][2] * vertex[2]),
          pos.y+scale.y*(rotationMatrix[1][0] * -vertex[0] + rotationMatrix[1][1] * vertex[1] + rotationMatrix[1][2] * vertex[2]),
          pos.z+scale.z*(rotationMatrix[2][0] * -vertex[0] + rotationMatrix[2][1] * vertex[1] + rotationMatrix[2][2] * vertex[2]));
        vertices.add(position);
      } else if (line.startsWith("vn ")) {
        float[] normal = getVectorFloat(line.substring(3, line.length()));
        Vector normal1 = new Vector(
          rotationMatrix[0][0] * -normal[0] + rotationMatrix[0][1] * normal[1] + rotationMatrix[0][2] * normal[2],
          rotationMatrix[1][0] * -normal[0] + rotationMatrix[1][1] * normal[1] + rotationMatrix[1][2] * normal[2],
          rotationMatrix[2][0] * -normal[0] + rotationMatrix[2][1] * normal[1] + rotationMatrix[2][2] * normal[2]);
        normals.add(normal1);
      } else if (line.startsWith("f ")) {
        String[] tokens = line.split(" ");
        String[] token1 = tokens[1].split("/");
        String[] token2 = tokens[2].split("/");
        String[] token3 = tokens[3].split("/");
        int vert1 = Integer.parseInt(token1[0]) - 1;
        int vert2 = Integer.parseInt(token2[0]) - 1;
        int vert3 = Integer.parseInt(token3[0]) - 1;
        int norm1 = Integer.parseInt(token1[2]) - 1;
        int norm2 = Integer.parseInt(token2[2]) - 1;
        int norm3 = Integer.parseInt(token3[2]) - 1;

        Shape shape = new Shape(vertices.get(vert3), vertices.get(vert2), vertices.get(vert1));
        shape.normal1 = normals.get(norm3);
        shape.normal2 = normals.get(norm2);
        shape.normal3 = normals.get(norm1);
        Material copyMat = new Material();
        copyMat.col = originalMat.col;
        copyMat.lightCol = originalMat.lightCol;
        copyMat.isLight = originalMat.isLight;
        copyMat.smoothness = originalMat.smoothness;
        copyMat.specularChance = originalMat.specularChance;
        copyMat.specularColor = originalMat.specularColor;
        copyMat.dielectric = originalMat.dielectric;
        if (useFileColor){
          copyMat.col = mat.col;
        }
        
        shape.material = copyMat;        
        shapes.add(shape);
      } else if (line.startsWith("mtllib ")) {
        try {
          int slashIndex = modelName.lastIndexOf("/");
          String mtlName = line.split(" ")[1];
          if (slashIndex!=-1) {
            mtlName = modelName.substring(0, slashIndex+1)+mtlName;
          }

          BufferedReader materialReader = new BufferedReader(new FileReader(mtlName));

          String materialLine;
          Material newMat = null;
          String matName = null;
          while ((materialLine = materialReader.readLine()) != null) {
            if (materialLine.startsWith("newmtl ")) {
              if (newMat != null) {
                materials.put(matName, newMat);
              }

              matName = materialLine.split(" ")[1];
              newMat = new Material();
            } else if (materialLine.startsWith("col ")) {
              newMat.col = getColor(materialLine);
            } else if (materialLine.startsWith("Kd ")) {
              newMat.col = getColor(materialLine);
            }else if (materialLine.startsWith("lightCol ")) {
              newMat.lightCol = getColor(materialLine);
            } else if (materialLine.startsWith("isLight ")) {
              newMat.isLight = Float.parseFloat(materialLine.split(" ")[1]);
            } else if (materialLine.startsWith("smoothness ")) {
              newMat.smoothness = Float.parseFloat(materialLine.split(" ")[1]);
            } else if (materialLine.startsWith("specularChance ")) {
              newMat.specularChance = Float.parseFloat(materialLine.split(" ")[1]);
            } else if (materialLine.startsWith("specularColor ")) {
              newMat.specularColor = getColor(materialLine);
            } else if (materialLine.startsWith("dielectric ")) {
              newMat.dielectric = Float.parseFloat(materialLine.split(" ")[1]);
            }
          }
          if (newMat != null) {
            materials.put(matName, newMat);
          }
        }
        catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
