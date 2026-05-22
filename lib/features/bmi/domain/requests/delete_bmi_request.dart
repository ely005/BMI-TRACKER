class DeleteBmiRequest {
  const DeleteBmiRequest({required this.id});

  final String id;

  String? validate() {
    if (id.trim().isEmpty) {
      return 'Record id is required';
    }
    return null;
  }
}
