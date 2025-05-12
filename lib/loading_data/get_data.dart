class LoadData {
  late String name;
  late double value;
  LoadData(this.name, this.value);
  LoadData.fromJson(Map<String, dynamic> jsonObj) {
    name = jsonObj['expenseName'];
    value = jsonObj['expenseValue'];
  }
}
