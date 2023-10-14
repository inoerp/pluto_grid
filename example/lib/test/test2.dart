void main(){
  Map<String, dynamic> mappedValue = {
    "a" : "A",
    "b" : "B",
  };
  var newMap = mappedValue;
  newMap["c"] = 123;

  print("value of newMap ${newMap.toString()}");
  print("value of mappedValue ${mappedValue.toString()}");
}