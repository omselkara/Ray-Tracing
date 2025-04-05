class Scene {
  ArrayList<BVHNode> nodes;

  Scene() {
    nodes = new ArrayList<>();
  }

  ArrayList<BVHNode> splitNodes(int depth) {
    ArrayList<BVHNode> splittedNodes = new ArrayList<>();
    for (int i=0; i<nodes.size(); i++) {
      println(i, nodes.size());
      if (nodes.get(i).shapes.size()>0){
       nodes.get(i).calculateBbox();
       nodes.get(i).fix();
       splitNodes(depth-1, nodes.get(i),splittedNodes);
      }
    }
    return splittedNodes;
  }

  void splitNodes(int step, BVHNode node,ArrayList<BVHNode> splittedNodes) {
    node.depth = step;
    node.index = splittedNodes.size();
    splittedNodes.add(node);
    if (step<0) {
      node.left = null;
      node.right = null;
      return;
    }
    node.split();
    if (node.left==null) {
      return;
    }

    if (step==0) {
      node.left.depth = 0;
      node.right.depth = 0;
      node.left.depth = splittedNodes.size();
      node.right.depth = splittedNodes.size()+1;
      splittedNodes.add(node.left);
      splittedNodes.add(node.right);
    } else {
      splitNodes(step-1, node.left,splittedNodes);
      splitNodes(step-1, node.right,splittedNodes);
    }
    return;
  }

  int setOrderedShapes(ArrayList<BVHNode> nodes) {
    int index = 0;
    for (BVHNode node : nodes) {
      if (node.left==null) {
        index += node.shapes.size();
      }
    }
    return index;
  }

  ArrayList<FloatBuffer> getBuffers(int depth) {
    float an = millis();
    ArrayList<BVHNode> nodes = splitNodes(depth);    
    int shapeSize = setOrderedShapes(nodes);
    FloatBuffer shapeBuffer = FloatBuffer.allocate(shapeSize * shapeAttributes);
    int totalPixels = 0;
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
        int index1 = index;
        int index2 = index1 + node.shapes.size();
        BVHBuffer.put(i * BVHAttributes + 6, index2);
        BVHBuffer.put(i * BVHAttributes + 7, index1);
        for (Shape shape : node.shapes){
          totalPixels += 3*shape.material.col.width*shape.material.col.height;
          if (shape.type == 1 || shape.type==3) {
            for (int lineIndex = 0; lineIndex < 3; lineIndex++) {
              Vector line = shape.lines[lineIndex];
              shapeBuffer.put(index * shapeAttributes + lineIndex * 3 + 0, line.x);
              shapeBuffer.put(index * shapeAttributes + lineIndex * 3 + 1, line.y);
              shapeBuffer.put(index * shapeAttributes + lineIndex * 3 + 2, line.z);
            }
          }
          if (shape.type == 2) {
            shapeBuffer.put(index * shapeAttributes + 0, shape.center.x);
            shapeBuffer.put(index * shapeAttributes + 1, shape.center.y);
            shapeBuffer.put(index * shapeAttributes + 2, shape.center.z);
          } else {
            shapeBuffer.put(index * shapeAttributes + 3 * 3 + 0, shape.normal.x);
            shapeBuffer.put(index * shapeAttributes + 3 * 3 + 1, shape.normal.y);
            shapeBuffer.put(index * shapeAttributes + 3 * 3 + 2, shape.normal.z);
          }
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 3, (float) shape.type);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 4, shape.radius);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 5, shape.material.lightCol.r * shape.material.isLight);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 6, shape.material.lightCol.g * shape.material.isLight);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 7, shape.material.lightCol.b * shape.material.isLight);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 8, shape.material.smoothness);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 9, shape.material.specularChance);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 10, shape.material.specularColor.r);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 11, shape.material.specularColor.g);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 12, shape.material.specularColor.b);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 13, shape.material.dielectric);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 14, shape.isSecondPart ? 1f:0f);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 15, shape.baryCenteric ? 1f:0f);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 16, shape.normal1.x);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 17, shape.normal1.y);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 18, shape.normal1.z);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 19, shape.normal2.x);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 20, shape.normal2.y);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 21, shape.normal2.z);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 22, shape.normal3.x);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 23, shape.normal3.y);
          shapeBuffer.put(index * shapeAttributes + 3 * 3 + 24, shape.normal3.z);
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

    FloatBuffer imageBuffer = FloatBuffer.allocate(totalPixels);
    FloatBuffer imageIdBuffer = FloatBuffer.allocate(3*shapeSize);
    index = 0;
    for (int i = 0; i < nodes.size(); i++) {
      BVHNode node = nodes.get(i);
      if (node.left==null){
        for (Shape shape : node.shapes) {
          
          shape.material.col.loadPixels();
          for (int j = 0; j < shape.material.col.pixels.length; j++) {
            int pixel = shape.material.col.pixels[j];
            imageBuffer.put(red(pixel) / 255.0);
            imageBuffer.put(green(pixel) / 255.0);
            imageBuffer.put(blue(pixel) / 255.0);
          }
          imageIdBuffer.put(float(index));
          imageIdBuffer.put(float(shape.material.col.width));
          imageIdBuffer.put(float(shape.material.col.height));
          index += 3*shape.material.col.width*shape.material.col.height;
        }
      }
    }
    imageBuffer.flip();
    imageIdBuffer.flip();


    ArrayList<FloatBuffer> buffers = new ArrayList<>();
    buffers.add(shapeBuffer);
    buffers.add(BVHBuffer);
    buffers.add(mainNodeValues);
    buffers.add(imageBuffer);
    buffers.add(imageIdBuffer);
    println("Took: "+(millis()-an));
    println("Shape Count: ",shapeSize);
    println("Node Count: ",nodes.size());
    this.nodes = null;
    return buffers;
  }
}
