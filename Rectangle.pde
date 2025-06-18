void addRectangle(Vector vec1,Vector vec2,Vector vec3,Vector vec4,Material material,List<Shape> shapes){
  Shape shape1 = new Shape(vec1,vec2,vec3);
  shape1.material = material;
  Shape shape2 = new Shape(vec3,vec4,vec1);
  shape2.material = material;  
  shape1.calculateNormal();  
  shape2.calculateNormal();
  shapes.add(shape1);
  shapes.add(shape2);
}
