void addRectangle(Vector vec1,Vector vec2,Vector vec3,Vector vec4,Material material,List<Shape> shapes){
  Shape triangle1 = new Triangle(vec1,vec2,vec3);
  triangle1.material = material;
  Shape triangle2 = new Triangle(vec3,vec4,vec1);
  triangle2.material = material;
  triangle1.type = 3;
  triangle2.type = 3;
  triangle2.isSecondPart = true;
  shapes.add(triangle1);
  shapes.add(triangle2);
}
