class Scene {
  ArrayList<BVHNode> nodes;
  ArrayList<BVHNode> splittedNodes = new ArrayList<>();

  Camera cam;

  Scene() {
    nodes = new ArrayList<>();
    cam = new Camera();
  }

  void splitNodes(int depth) {
    float time = millis();
    splittedNodes = new ArrayList<>();
    for (int i=0; i<nodes.size(); i++) {
      println(i, nodes.size());
      if (nodes.get(i).shapes.length>0) {
        nodes.get(i).calculateBbox();
        nodes.get(i).fix();
        splitNodes(depth-1, nodes.get(i));
      }
    }
    println(splittedNodes.size());
    println("BVH Took:", millis()-time);
  }

  void splitNodes(int step, BVHNode node) {
    node.index = splittedNodes.size();
    splittedNodes.add(node);
    if (step<0) {
      node.left = null;
      node.right = null;
      return;
    }
    if (!node.split()) {
      return;
    }

    if (step==0) {
      node.left.index = splittedNodes.size();
      node.right.index = splittedNodes.size()+1;
      splittedNodes.add(node.left);
      splittedNodes.add(node.right);
    } else {
      splitNodes(step-1, node.left);
      splitNodes(step-1, node.right);
    }
    return;
  }

  int setOrderedShapes(ArrayList<BVHNode> nodes) {
    int index = 0;
    for (BVHNode node : nodes) {
      if (node.left==null) {
        index += node.shapes.length;
      }
    }
    return index;
  }

  ArrayList<FloatBuffer> getBuffers() {
    ArrayList<BVHNode> nodes = splittedNodes;
    int shapeSize = setOrderedShapes(nodes);
    FloatBuffer shapeBuffer = FloatBuffer.allocate(shapeSize * shapeAttributes);
    FloatBuffer BVHBuffer = FloatBuffer.allocate(nodes.size() * BVHAttributes);
    int index = 0;
    for (int i = 0; i < nodes.size(); i++) {
      BVHNode node = nodes.get(i);
      BVHBuffer.put(i * BVHAttributes + 0, node.tMin.x);
      BVHBuffer.put(i * BVHAttributes + 1, node.tMin.y);
      BVHBuffer.put(i * BVHAttributes + 2, node.tMin.z);
      BVHBuffer.put(i * BVHAttributes + 3, node.tMax.x);
      BVHBuffer.put(i * BVHAttributes + 4, node.tMax.y);
      BVHBuffer.put(i * BVHAttributes + 5, node.tMax.z);
      if (node.left == null) {
        int index2 = index + node.shapes.length;
        BVHBuffer.put(i * BVHAttributes + 6, index2);
        BVHBuffer.put(i * BVHAttributes + 7, index);
        for (Shape shape : node.shapes) {
          
          shapeBuffer.put(index * shapeAttributes + 0, shape.vec1.x);
          shapeBuffer.put(index * shapeAttributes + 1, shape.vec1.y);
          shapeBuffer.put(index * shapeAttributes + 2, shape.vec1.z);
          shapeBuffer.put(index * shapeAttributes + 3, shape.vec2.x);
          shapeBuffer.put(index * shapeAttributes + 4, shape.vec2.y);
          shapeBuffer.put(index * shapeAttributes + 5, shape.vec2.z);
          shapeBuffer.put(index * shapeAttributes + 6, shape.vec3.x);
          shapeBuffer.put(index * shapeAttributes + 7, shape.vec3.y);
          shapeBuffer.put(index * shapeAttributes + 8, shape.vec3.z);
          
          shapeBuffer.put(index * shapeAttributes + 9, shape.material.col.r);
          shapeBuffer.put(index * shapeAttributes + 10, shape.material.col.g);
          shapeBuffer.put(index * shapeAttributes + 11, shape.material.col.b);
          shapeBuffer.put(index * shapeAttributes + 12, shape.material.lightCol.r * shape.material.isLight);
          shapeBuffer.put(index * shapeAttributes + 13, shape.material.lightCol.g * shape.material.isLight);
          shapeBuffer.put(index * shapeAttributes + 14, shape.material.lightCol.b * shape.material.isLight);
          shapeBuffer.put(index * shapeAttributes + 15, shape.material.smoothness);
          shapeBuffer.put(index * shapeAttributes + 16, shape.material.specularChance);
          shapeBuffer.put(index * shapeAttributes + 17, shape.material.specularColor.r);
          shapeBuffer.put(index * shapeAttributes + 18, shape.material.specularColor.g);
          shapeBuffer.put(index * shapeAttributes + 19, shape.material.specularColor.b);
          shapeBuffer.put(index * shapeAttributes + 20, shape.material.dielectric);
          shapeBuffer.put(index * shapeAttributes + 21, shape.normal1.x);
          shapeBuffer.put(index * shapeAttributes + 22, shape.normal1.y);
          shapeBuffer.put(index * shapeAttributes + 23, shape.normal1.z);
          shapeBuffer.put(index * shapeAttributes + 24, shape.normal2.x);
          shapeBuffer.put(index * shapeAttributes + 25, shape.normal2.y);
          shapeBuffer.put(index * shapeAttributes + 26, shape.normal2.z);
          shapeBuffer.put(index * shapeAttributes + 27, shape.normal3.x);
          shapeBuffer.put(index * shapeAttributes + 28, shape.normal3.y);
          shapeBuffer.put(index * shapeAttributes + 29, shape.normal3.z);
          index++;
        }
      } else {
        int index1 = node.left.index;
        int index2 = node.right.index;
        BVHBuffer.put(i * BVHAttributes + 6, index1);
        BVHBuffer.put(i * BVHAttributes + 7, index2);
      }
    }
    shapeBuffer.flip();
    BVHBuffer.flip();

    FloatBuffer mainNodeValues = FloatBuffer.allocate(this.nodes.size());

    for (int i=0; i<this.nodes.size(); i++) {
      mainNodeValues.put(this.nodes.get(i).index);
    }

    mainNodeValues.flip();


    ArrayList<FloatBuffer> buffers = new ArrayList<>();
    buffers.add(shapeBuffer);
    buffers.add(BVHBuffer);
    buffers.add(mainNodeValues);
    println("Shape Count: ", shapeSize);
    println("Node Count: ", nodes.size());
    this.nodes = null;
    return buffers;
  }

  void updateCameraValuesShader() {
    gl.glUseProgram(computeProgram);
    gl.glUniform3f(gl.glGetUniformLocation(computeProgram, "pos"), scene.cam.pos.x, scene.cam.pos.y, scene.cam.pos.z);
    gl.glUniform3f(gl.glGetUniformLocation(computeProgram, "povCenter"), scene.cam.povCenter.x, scene.cam.povCenter.y, scene.cam.povCenter.z);
    gl.glUniform3f(gl.glGetUniformLocation(computeProgram, "horizontalDirScreen"), scene.cam.horizontalDirScreen.x, scene.cam.horizontalDirScreen.y, scene.cam.horizontalDirScreen.z);
    gl.glUniform3f(gl.glGetUniformLocation(computeProgram, "verticalDirScreen"), scene.cam.verticalDirScreen.x, scene.cam.verticalDirScreen.y, scene.cam.verticalDirScreen.z);
  }
}
